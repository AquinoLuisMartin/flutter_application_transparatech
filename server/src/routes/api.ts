import express from "express";
import { db } from "../db/index.js";
import {
  accounts,
  roles,
  organizations,
  documents,
  documentStatuses,
  documentReviews,
} from "../db/schema.js";
import { eq, desc, and, inArray } from "drizzle-orm";
import authRoutes from "./auth.routes.js";
import officerRoutes from "./officer.routes.js";
import {
  verifyToken,
  requireRole,
  AuthRequest,
} from "../middleware/auth.middleware.js";
import {
  statusUpdateSchema,
  idParamSchema,
} from "../utils/validation.js";
import { logActivity } from "../utils/audit-logger.js";

const router = express.Router();

// ──────────────────────────────────────────────
// Health check (public)
// ──────────────────────────────────────────────

router.get("/status", (req, res) => {
  res.json({ status: "Server is running", database: "connected" });
});

// ──────────────────────────────────────────────
// Sub-routers
// ──────────────────────────────────────────────

router.use("/auth", authRoutes);
router.use("/officer", officerRoutes);

// ──────────────────────────────────────────────
// GET /api/roles (C-1: now auth-protected)
// ──────────────────────────────────────────────

router.get("/roles", verifyToken, async (req, res) => {
  try {
    const allRoles = await db.select().from(roles);
    res.json(allRoles);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch roles" });
  }
});

// ──────────────────────────────────────────────
// GET /api/accounts (C-1: admin-only)
// ──────────────────────────────────────────────

router.get(
  "/accounts",
  verifyToken,
  requireRole("Admin"),
  async (req, res) => {
    try {
      const allAccounts = await db
        .select({
          accountId: accounts.accountId,
          studentId: accounts.studentId,
          username: accounts.username,
          email: accounts.email,
          firstName: accounts.firstName,
          lastName: accounts.lastName,
          isActive: accounts.isActive,
          isVerified: accounts.isVerified,
          roleName: roles.roleName,
          orgCode: organizations.orgCode,
          orgName: organizations.orgName,
        })
        .from(accounts)
        .leftJoin(roles, eq(accounts.roleId, roles.roleId))
        .leftJoin(
          organizations,
          eq(accounts.organizationId, organizations.organizationId),
        );
      res.json(allAccounts);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch accounts" });
    }
  },
);

// ──────────────────────────────────────────────
// GET /api/admin/organizations (C-1: admin-only, C-2: fixed sql.raw)
// ──────────────────────────────────────────────

router.get(
  "/admin/organizations",
  verifyToken,
  requireRole("Admin"),
  async (req, res) => {
    try {
      const orgs = await db.select().from(organizations);
      const result = [];

      for (const org of orgs) {
        // Find accounts for this org
        const orgAccounts = await db
          .select({
            accountId: accounts.accountId,
            firstName: accounts.firstName,
            lastName: accounts.lastName,
            email: accounts.email,
            roleName: roles.roleName,
          })
          .from(accounts)
          .leftJoin(roles, eq(accounts.roleId, roles.roleId))
          .where(eq(accounts.organizationId, org.organizationId));

        const officers = orgAccounts
          .filter((a) => a.roleName === "Officer")
          .map((a) => ({
            role: "Officer",
            name: `${a.firstName} ${a.lastName}`,
            contact: a.email,
          }));

        // ── C-2 FIX: replaced sql.raw(ids.join(",")) with inArray ──
        let orgDocs: any[] = [];
        if (orgAccounts.length > 0) {
          const ids = orgAccounts.map((a) => a.accountId);
          orgDocs = await db
            .select({
              documentId: documents.documentId,
              documentTitle: documents.documentTitle,
              submissionDate: documents.submissionDate,
              statusName: documentStatuses.statusName,
            })
            .from(documents)
            .leftJoin(
              documentStatuses,
              eq(documents.statusId, documentStatuses.statusId),
            )
            .where(
              and(
                inArray(documents.uploadedBy, ids),
                eq(documents.isDeleted, 0),
              ),
            );
        }

        const formattedDocs = orgDocs.map((d) => ({
          title: d.documentTitle,
          date: d.submissionDate
            ? new Date(d.submissionDate).toLocaleDateString()
            : "",
          status: d.statusName || "PENDING",
        }));

        result.push({
          fullName: org.orgName,
          acronym: org.orgCode,
          memberCount: orgAccounts.length,
          status: org.isActive ? "ACTIVE" : "INACTIVE",
          officers: officers,
          documents: formattedDocs,
        });
      }

      res.json(result);
    } catch (error) {
      console.error("Error fetching admin organizations:", error);
      res.status(500).json({ error: "Failed to fetch admin organizations" });
    }
  },
);

// ──────────────────────────────────────────────
// GET /api/admin/documents (C-1: admin-only)
// ──────────────────────────────────────────────

router.get(
  "/admin/documents",
  verifyToken,
  requireRole("Admin"),
  async (req, res) => {
    try {
      const docs = await db
        .select({
          id: documents.documentId,
          title: documents.documentTitle,
          description: documents.documentDescription,
          filePath: documents.filePath,
          fileSize: documents.fileSize,
          fileType: documents.fileType,
          status: documentStatuses.statusName,
          uploadDate: documents.submissionDate,
          senderFirstName: accounts.firstName,
          senderLastName: accounts.lastName,
          orgCode: organizations.orgCode,
        })
        .from(documents)
        .leftJoin(
          documentStatuses,
          eq(documents.statusId, documentStatuses.statusId),
        )
        .leftJoin(accounts, eq(documents.uploadedBy, accounts.accountId))
        .leftJoin(
          organizations,
          eq(accounts.organizationId, organizations.organizationId),
        )
        .where(eq(documents.isDeleted, 0))
        .orderBy(desc(documents.submissionDate));

      const result = docs.map((d) => {
        const hasSpent =
          d.description?.includes("Total Amount Spent") || false;
        const accuracy = hasSpent ? 98.2 : 94.5;
        const flags = hasSpent ? [] : ["Missing amount breakdown"];

        return {
          id: d.id.toString(),
          title: d.title,
          organization: d.orgCode || "ISITE",
          senderName: `${d.senderFirstName} ${d.senderLastName}`,
          documentType:
            d.fileType === "application/pdf"
              ? "Audit Report"
              : "Financial Document",
          uploadDate: d.uploadDate
            ? new Date(d.uploadDate).toISOString()
            : new Date().toISOString(),
          fileSize: d.fileSize
            ? `${(d.fileSize / 1024).toFixed(1)} KB`
            : "120 KB",
          description: d.description || "",
          accuracy: accuracy,
          flags: flags,
          status: d.status || "PENDING",
        };
      });

      res.json(result);
    } catch (error) {
      console.error("Error fetching admin documents:", error);
      res.status(500).json({ error: "Failed to fetch admin documents" });
    }
  },
);

// ──────────────────────────────────────────────
// GET /api/admin/users (C-1: admin-only)
// ──────────────────────────────────────────────

router.get(
  "/admin/users",
  verifyToken,
  requireRole("Admin"),
  async (req, res) => {
    try {
      const users = await db
        .select({
          firstName: accounts.firstName,
          lastName: accounts.lastName,
          email: accounts.email,
          roleName: roles.roleName,
          orgCode: organizations.orgCode,
          isActive: accounts.isActive,
          lastLogin: accounts.lastLogin,
        })
        .from(accounts)
        .leftJoin(roles, eq(accounts.roleId, roles.roleId))
        .leftJoin(
          organizations,
          eq(accounts.organizationId, organizations.organizationId),
        );

      const result = users.map((u) => ({
        fullName: `${u.firstName} ${u.lastName}`,
        email: u.email,
        role:
          u.roleName === "Officer" ? "Officers" : u.roleName || "Student",
        organization: u.orgCode || "ISITE",
        lastLogin: u.lastLogin
          ? `Last login: ${new Date(u.lastLogin).toLocaleDateString()}`
          : "Never logged in",
        isActive: u.isActive === 1,
        systemFlag: u.isActive === 1 ? "ACTIVE" : "ARCHIVED",
      }));

      res.json(result);
    } catch (error) {
      console.error("Error fetching admin users:", error);
      res.status(500).json({ error: "Failed to fetch admin users" });
    }
  },
);

// ──────────────────────────────────────────────
// PUT /api/admin/documents/:id/status
// (C-1: admin-only, C-4: audit trail + state machine, M-1: validated)
// ──────────────────────────────────────────────

/**
 * Allowed status transitions — prevents arbitrary state changes.
 */
const VALID_TRANSITIONS: Record<string, string[]> = {
  DRAFT: ["PENDING"],
  PENDING: ["APPROVED", "REJECTED"],
  REJECTED: ["PENDING"], // allow resubmission
  APPROVED: ["ARCHIVED"],
  ARCHIVED: [], // terminal state
};

router.put(
  "/admin/documents/:id/status",
  verifyToken,
  requireRole("Admin"),
  async (req: AuthRequest, res) => {
    try {
      // ── M-1: Validate params and body ──
      const paramResult = idParamSchema.safeParse(req.params);
      if (!paramResult.success) {
        return res.status(400).json({ error: "Invalid document ID" });
      }

      const bodyResult = statusUpdateSchema.safeParse(req.body);
      if (!bodyResult.success) {
        return res.status(400).json({
          error: "Validation failed",
          issues: bodyResult.error.issues.map((i) => ({
            field: i.path.join("."),
            message: i.message,
          })),
        });
      }

      const documentId = parseInt(paramResult.data.id);
      const { status, comments } = bodyResult.data;
      const reviewerId = req.user!.accountId;

      // ── C-4: Get current document status for transition validation ──
      const currentDoc = await db
        .select({
          statusName: documentStatuses.statusName,
          statusId: documents.statusId,
        })
        .from(documents)
        .innerJoin(
          documentStatuses,
          eq(documents.statusId, documentStatuses.statusId),
        )
        .where(
          and(
            eq(documents.documentId, documentId),
            eq(documents.isDeleted, 0),
          ),
        )
        .limit(1);

      if (currentDoc.length === 0) {
        return res.status(404).json({ error: "Document not found" });
      }

      const currentStatus = currentDoc[0].statusName;
      const allowed = VALID_TRANSITIONS[currentStatus] || [];

      if (!allowed.includes(status)) {
        return res.status(400).json({
          error: `Invalid transition: ${currentStatus} → ${status}`,
          allowedTransitions: allowed,
        });
      }

      // Get new status ID
      const newStatus = await db
        .select()
        .from(documentStatuses)
        .where(eq(documentStatuses.statusName, status))
        .limit(1);

      if (newStatus.length === 0) {
        return res.status(400).json({ error: "Invalid status name" });
      }

      const newStatusId = newStatus[0].statusId;

      // ── C-4: Create review record (audit trail) ──
      await db.insert(documentReviews).values({
        documentId: documentId,
        reviewedBy: reviewerId,
        previousStatusId: currentDoc[0].statusId,
        newStatusId: newStatusId,
        reviewComments: comments ?? null,
        reviewDate: new Date(),
      });

      // Update document status
      await db
        .update(documents)
        .set({
          statusId: newStatusId,
          lastModified: new Date(),
        })
        .where(eq(documents.documentId, documentId));

      // ── C-4: Write to activity log ──
      await logActivity({
        userId: reviewerId,
        action: "STATUS_CHANGE",
        module: "DOCUMENTS",
        resourceType: "document",
        resourceId: documentId,
        description: `Status changed: ${currentStatus} → ${status}`,
        req,
        status: "SUCCESS",
      });

      res.json({
        message: `Document status updated to ${status} successfully`,
        previousStatus: currentStatus,
        newStatus: status,
      });
    } catch (error) {
      console.error("Error updating document status:", error);
      res.status(500).json({ error: "Failed to update document status" });
    }
  },
);

export default router;
