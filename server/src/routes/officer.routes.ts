import express from 'express';
import { db } from '../db/index.js';
import { documents, documentStatuses, accounts, organizations, budgets } from '../db/schema.js';
import { eq, desc, sql, and, like, or } from 'drizzle-orm';
import { verifyToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// GET /api/officer/organization - Get organization and budget info
router.get('/organization', verifyToken, async (req: any, res) => {
  try {
    const accountId = req.user.accountId;

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
      return res.status(404).json({ error: 'User is not assigned to any organization' });
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
      budget: budget[0]
    });
  } catch (error) {
    console.error('Error fetching officer organization:', error);
    res.status(500).json({ error: 'Failed to fetch organization data' });
  }
});

// GET /api/officer/stats - Get dashboard statistics
router.get('/stats', verifyToken, async (req: any, res) => {
  try {
    const accountId = req.user.accountId;

    // Get user's organization for budget calculations
    const user = await db
      .select({
        organizationId: accounts.organizationId,
      })
      .from(accounts)
      .where(eq(accounts.accountId, accountId))
      .limit(1);
    
    const organizationId = user[0]?.organizationId;

    // Get document counts by status
    const stats = await db
      .select({
        status: documentStatuses.statusName,
        count: sql<number>`count(${documents.documentId})`,
      })
      .from(documents)
      .innerJoin(documentStatuses, eq(documents.statusId, documentStatuses.statusId))
      .where(and(eq(documents.uploadedBy, accountId), eq(documents.isDeleted, 0)))
      .groupBy(documentStatuses.statusName);

    // Get total active documents
    const totalDocsResult = await db
      .select({ count: sql<number>`count(*)` })
      .from(documents)
      .where(and(eq(documents.uploadedBy, accountId), eq(documents.isDeleted, 0)));

    const totalActive = totalDocsResult[0]?.count || 0;

    // Calculate compliance score: (Approved / Total) * 100
    const approvedCount = stats.find(s => s.status === 'APPROVED')?.count || 0;
    const complianceScore = totalActive > 0 
      ? Math.round((approvedCount / totalActive) * 100) 
      : 0;

    // Transparency index: Logic based on verified documents and metadata completeness
    // For now, let's use a slightly more realistic formula
    const transparencyIndex = totalActive > 0 
      ? Math.min(60 + (approvedCount * 5), 100) 
      : 0;

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
          total: budget[0].totalBudget / 100, // Convert cents to whole units
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
      budget: budgetSummary
    });
  } catch (error) {
    console.error('Error fetching officer stats:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// GET /api/officer/documents - Get all documents for the officer
router.get('/documents', verifyToken, async (req: any, res) => {
  try {
    const accountId = req.user.accountId;
    const { search } = req.query;

    let conditions = [
      eq(documents.uploadedBy, accountId),
      eq(documents.isDeleted, 0)
    ];

    if (search) {
      conditions.push(
        or(
          like(documents.documentTitle, `%${search}%`),
          like(documents.documentDescription, `%${search}%`)
        ) as any
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
      .innerJoin(documentStatuses, eq(documents.statusId, documentStatuses.statusId))
      .where(and(...conditions))
      .orderBy(desc(documents.submissionDate));

    res.json(docs);
  } catch (error) {
    console.error('Error fetching officer documents:', error);
    res.status(500).json({ error: 'Failed to fetch documents' });
  }
});

// GET /api/officer/documents/:id - Get document details
router.get('/documents/:id', verifyToken, async (req: any, res) => {
  try {
    const { id } = req.params;
    const accountId = req.user.accountId;

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
      .innerJoin(documentStatuses, eq(documents.statusId, documentStatuses.statusId))
      .where(and(
        eq(documents.documentId, parseInt(id)),
        eq(documents.uploadedBy, accountId)
      ))
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

// POST /api/officer/documents - Upload a new document
router.post('/documents', verifyToken, async (req: any, res) => {
  try {
    const { title, description, filePath, fileSize, fileType } = req.body;
    const accountId = req.user.accountId;

    // Get PENDING status ID
    const pendingStatus = await db
      .select()
      .from(documentStatuses)
      .where(eq(documentStatuses.statusName, 'PENDING'))
      .limit(1);

    const statusId = pendingStatus[0]?.statusId || 2;

    const result = await db.insert(documents).values({
      documentTitle: title,
      documentDescription: description,
      filePath: filePath,
      fileSize: fileSize || 0,
      fileType: fileType || 'application/pdf',
      uploadedBy: accountId,
      statusId: statusId,
      submissionDate: new Date(),
      lastModified: new Date(),
      isDeleted: 0,
    }).returning();

    res.status(201).json({ 
      message: 'Document submitted successfully',
      document: result[0]
    });
  } catch (error) {
    console.error('Error submitting document:', error);
    res.status(500).json({ error: 'Failed to submit document' });
  }
});

// DELETE /api/officer/documents/:id - Archive a document
router.delete('/documents/:id', verifyToken, async (req: any, res) => {
  try {
    const { id } = req.params;
    const accountId = req.user.accountId;

    const result = await db
      .update(documents)
      .set({ 
        isDeleted: 1,
        deletedAt: new Date(),
        lastModified: new Date()
      })
      .where(and(
        eq(documents.documentId, parseInt(id)),
        eq(documents.uploadedBy, accountId)
      ))
      .returning();

    if (result.length === 0) {
      return res.status(404).json({ error: 'Document not found or access denied' });
    }

    res.json({ message: 'Document archived successfully' });
  } catch (error) {
    console.error('Error archiving document:', error);
    res.status(500).json({ error: 'Failed to archive document' });
  }
});

export default router;
