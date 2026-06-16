import express from 'express';
import { db } from '../db/index.js';
import {
  documents,
  documentStatuses,
  accounts,
  organizations,
  budgets,
} from '../db/schema.js';
import { eq, desc, sql, and, like, or } from 'drizzle-orm';
import { verifyToken, AuthRequest } from '../middleware/auth.middleware.js';
import {
  documentCreateSchema,
  idParamSchema,
  escapeLikePattern,
} from '../utils/validation.js';
import { logActivity } from '../utils/audit-logger.js';
import { analyzeDocument } from '../services/ai.service.js';

const router = express.Router();

// ──────────────────────────────────────────────
// GET /api/officer/organization
// ──────────────────────────────────────────────

router.get('/organization', verifyToken, async (req: AuthRequest, res) => {
  try {
    const accountId = req.user!.accountId;

    // Get user's organization
    const user = await db
      .select({
        organizationId: accounts.organizationId,
      })
      .from(accounts)
      .where(eq(accounts.accountId, accountId))
      .limit(1);

    const organizationId = user[0]?.organizationId;

    if (!organizationId) {
      return res.json({
        organization: null,
        budget: null,
      });
    }

    // Get organization details
    const org = await db
      .select()
      .from(organizations)
      .where(eq(organizations.organizationId, organizationId))
      .limit(1);

    // Get budget details
    const budget = await db
      .select()
      .from(budgets)
      .where(eq(budgets.organizationId, organizationId))
      .orderBy(desc(budgets.academicYear))
      .limit(1);

    res.json({
      organization: org[0],
      budget: budget[0],
    });
  } catch (error) {
    console.error('Error fetching officer organization:', error);
    res.status(500).json({ error: 'Failed to fetch organization data' });
  }
});

// ──────────────────────────────────────────────
// GET /api/officer/stats
// ──────────────────────────────────────────────

router.get('/stats', verifyToken, async (req: AuthRequest, res) => {
  try {
    const accountId = req.user!.accountId;

    // Get user's organization for budget calculations
    const user = await db
      .select({
        organizationId: accounts.organizationId,
      })
      .from(accounts)
      .where(eq(accounts.accountId, accountId))
      .limit(1);

    const organizationId = user[0]?.organizationId;

    if (!organizationId) {
      return res.json({
        byStatus: [],
        totalActive: 0,
        complianceScore: 0,
        transparencyIndex: 0,
        budget: null,
      });
    }

    // Get document counts by status for the organization
    const stats = await db
      .select({
        status: documentStatuses.statusName,
        count: sql<number>`count(${documents.documentId})`,
      })
      .from(documents)
      .innerJoin(
        documentStatuses,
        eq(documents.statusId, documentStatuses.statusId),
      )
      .innerJoin(accounts, eq(documents.uploadedBy, accounts.accountId))
      .where(
        and(
          eq(accounts.organizationId, organizationId),
          eq(documents.isDeleted, 0),
        ),
      )
      .groupBy(documentStatuses.statusName);

    // Get total active documents for the organization
    const totalDocsResult = await db
      .select({ count: sql<number>`count(*)` })
      .from(documents)
      .innerJoin(accounts, eq(documents.uploadedBy, accounts.accountId))
      .where(
        and(
          eq(accounts.organizationId, organizationId),
          eq(documents.isDeleted, 0),
        ),
      );

    const totalActive = totalDocsResult[0]?.count || 0;

    // Calculate compliance score: (Approved / Total) * 100
    const approvedCount =
      stats.find((s) => s.status === 'APPROVED')?.count || 0;
    const complianceScore =
      totalActive > 0
        ? Math.round((approvedCount / totalActive) * 100)
        : 0;

    // Transparency index
    const transparencyIndex =
      totalActive > 0 ? Math.min(60 + approvedCount * 5, 100) : 0;

    // Get budget summary if organization exists
    let budgetSummary = null;
    if (organizationId) {
      const budget = await db
        .select()
        .from(budgets)
        .where(eq(budgets.organizationId, organizationId))
        .orderBy(desc(budgets.academicYear))
        .limit(1);

      if (budget.length > 0) {
        budgetSummary = {
          total: budget[0].totalBudget / 100,
          spent: budget[0].spentAmount / 100,
          remaining: budget[0].remainingAmount / 100,
        };
      }
    }

    res.json({
      byStatus: stats,
      totalActive,
      complianceScore,
      transparencyIndex,
      budget: budgetSummary,
    });
  } catch (error) {
    console.error('Error fetching officer stats:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// ──────────────────────────────────────────────
// GET /api/officer/documents (M-5: escaped LIKE)
// ──────────────────────────────────────────────

router.get('/documents', verifyToken, async (req: AuthRequest, res) => {
  try {
    const accountId = req.user!.accountId;
    const { search } = req.query;

    // Get user's organizationId
    const user = await db
      .select({
        organizationId: accounts.organizationId,
      })
      .from(accounts)
      .where(eq(accounts.accountId, accountId))
      .limit(1);

    const organizationId = user[0]?.organizationId;

    if (!organizationId) {
      return res.json([]);
    }

    // ── M-5: Escape LIKE wildcard characters in search input ──
    let searchCondition;
    if (search && typeof search === 'string' && search.trim().length > 0) {
      const safeSearch = escapeLikePattern(search.trim());
      searchCondition = or(
        like(documents.documentTitle, `%${safeSearch}%`),
        like(documents.documentDescription, `%${safeSearch}%`),
      );
    }

    const docs = await db
      .select({
        id: documents.documentId,
        title: documents.documentTitle,
        description: documents.documentDescription,
        filePath: documents.filePath,
        fileSize: documents.fileSize,
        fileType: documents.fileType,
        status: documentStatuses.statusName,
        statusColor: documentStatuses.statusColor,
        createdAt: documents.submissionDate,
      })
      .from(documents)
      .innerJoin(
        documentStatuses,
        eq(documents.statusId, documentStatuses.statusId),
      )
      .innerJoin(accounts, eq(documents.uploadedBy, accounts.accountId))
      .where(
        and(
          eq(accounts.organizationId, organizationId),
          eq(documents.isDeleted, 0),
          searchCondition,
        ),
      )
      .orderBy(desc(documents.submissionDate));

    res.json(docs);
  } catch (error) {
    console.error('Error fetching officer documents:', error);
    res.status(500).json({ error: 'Failed to fetch documents' });
  }
});

// ──────────────────────────────────────────────
// GET /api/officer/documents/:id (M-1: param validated)
// ──────────────────────────────────────────────

router.get('/documents/:id', verifyToken, async (req: AuthRequest, res) => {
  try {
    // ── M-1: Validate ID param ──
    const paramResult = idParamSchema.safeParse(req.params);
    if (!paramResult.success) {
      return res.status(400).json({ error: 'Invalid document ID' });
    }

    const documentId = parseInt(paramResult.data.id);
    const accountId = req.user!.accountId;

    const doc = await db
      .select({
        id: documents.documentId,
        title: documents.documentTitle,
        description: documents.documentDescription,
        filePath: documents.filePath,
        fileSize: documents.fileSize,
        fileType: documents.fileType,
        status: documentStatuses.statusName,
        statusColor: documentStatuses.statusColor,
        createdAt: documents.submissionDate,
        lastModified: documents.lastModified,
      })
      .from(documents)
      .innerJoin(
        documentStatuses,
        eq(documents.statusId, documentStatuses.statusId),
      )
      .where(
        and(
          eq(documents.documentId, documentId),
          eq(documents.uploadedBy, accountId),
        ),
      )
      .limit(1);

    if (doc.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    res.json(doc[0]);
  } catch (error) {
    console.error('Error fetching document details:', error);
    res.status(500).json({ error: 'Failed to fetch document' });
  }
});

// ──────────────────────────────────────────────
// POST /api/officer/documents (M-1/M-3: validated, path traversal blocked)
// ──────────────────────────────────────────────

router.post('/documents', verifyToken, async (req: AuthRequest, res) => {
  try {
    // ── M-1: Validate body ──
    const parsed = documentCreateSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: 'Validation failed',
        issues: parsed.error.issues.map((i) => ({
          field: i.path.join('.'),
          message: i.message,
        })),
      });
    }

    const { title, description, filePath, fileSize, fileType } = parsed.data;
    const accountId = req.user!.accountId;

    // Get PENDING status ID
    const pendingStatus = await db
      .select()
      .from(documentStatuses)
      .where(eq(documentStatuses.statusName, 'PENDING'))
      .limit(1);

    const statusId = pendingStatus[0]?.statusId || 2;

    // Call Gemini AI to perform "file scanning" and audit analysis
    let aiAnalysis = description || '';
    try {
      console.log(`VeriFi AI: Scanning document: "${title}"...`);
      aiAnalysis = await analyzeDocument(title, fileType, description);
    } catch (err) {
      console.error('Failed to run AI document scanning:', err);
    }

    const result = await db
      .insert(documents)
      .values({
        documentTitle: title,
        documentDescription: aiAnalysis,
        filePath: filePath,
        fileSize: fileSize ?? 0,
        fileType: fileType ?? 'application/pdf',
        uploadedBy: accountId,
        statusId: statusId,
        submissionDate: new Date(),
        lastModified: new Date(),
        isDeleted: 0,
      })
      .returning();

    // Audit log
    await logActivity({
      userId: accountId,
      action: 'DOCUMENT_SUBMIT',
      module: 'DOCUMENTS',
      resourceType: 'document',
      resourceId: result[0]?.documentId,
      description: `Document submitted: ${title}`,
      req,
      status: 'SUCCESS',
    });

    res.status(201).json({
      message: 'Document submitted successfully',
      document: result[0],
    });
  } catch (error) {
    console.error('Error submitting document:', error);
    res.status(500).json({ error: 'Failed to submit document' });
  }
});

// ──────────────────────────────────────────────
// DELETE /api/officer/documents/:id (M-1: validated, audit-logged)
// ──────────────────────────────────────────────

router.delete('/documents/:id', verifyToken, async (req: AuthRequest, res) => {
  try {
    // ── M-1: Validate ID param ──
    const paramResult = idParamSchema.safeParse(req.params);
    if (!paramResult.success) {
      return res.status(400).json({ error: 'Invalid document ID' });
    }

    const documentId = parseInt(paramResult.data.id);
    const accountId = req.user!.accountId;

    const result = await db
      .update(documents)
      .set({
        isDeleted: 1,
        deletedAt: new Date(),
        lastModified: new Date(),
      })
      .where(
        and(
          eq(documents.documentId, documentId),
          eq(documents.uploadedBy, accountId),
        ),
      )
      .returning();

    if (result.length === 0) {
      return res
        .status(404)
        .json({ error: 'Document not found or access denied' });
    }

    // Audit log
    await logActivity({
      userId: accountId,
      action: 'DOCUMENT_ARCHIVE',
      module: 'DOCUMENTS',
      resourceType: 'document',
      resourceId: documentId,
      description: `Document archived: ${result[0].documentTitle}`,
      req,
      status: 'SUCCESS',
    });

    res.json({ message: 'Document archived successfully' });
  } catch (error) {
    console.error('Error archiving document:', error);
    res.status(500).json({ error: 'Failed to archive document' });
  }
});

export default router;
