import express from "express";
import { db } from "../db/index.js";
import { accounts, roles, organizations, documents, documentStatuses } from "../db/schema.js";
import { eq, desc, and, sql } from "drizzle-orm";
import authRoutes from "./auth.routes.js";
import officerRoutes from "./officer.routes.js";

const router = express.Router();

// GET /api/status - Health check
router.get("/status", (req, res) => {
  res.json({ status: "Server is running", database: "connected" });
});

// Auth routes
router.use("/auth", authRoutes);

// Officer routes
router.use("/officer", officerRoutes);

// GET /api/roles - Fetch all roles from SQLite
router.get("/roles", async (req, res) => {
  try {
    const allRoles = await db.select().from(roles);
    res.json(allRoles);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch roles" });
  }
});

// GET /api/accounts - Fetch all accounts
router.get("/accounts", async (req, res) => {
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
      .leftJoin(organizations, eq(accounts.organizationId, organizations.organizationId));
    res.json(allAccounts);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch accounts" });
  }
});

// GET /api/admin/organizations - Fetch all organizations with real officers and documents
router.get("/admin/organizations", async (req, res) => {
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
        .filter(a => a.roleName === "Officer")
        .map(a => ({
          role: "Officer",
          name: `${a.firstName} ${a.lastName}`,
          contact: a.email,
        }));

      // Find documents uploaded by accounts of this org
      let orgDocs: any[] = [];
      if (orgAccounts.length > 0) {
        const ids = orgAccounts.map(a => a.accountId);
        orgDocs = await db
          .select({
            documentId: documents.documentId,
            documentTitle: documents.documentTitle,
            submissionDate: documents.submissionDate,
            statusName: documentStatuses.statusName,
          })
          .from(documents)
          .leftJoin(documentStatuses, eq(documents.statusId, documentStatuses.statusId))
          .where(
            and(
              sql`${documents.uploadedBy} IN (${sql.raw(ids.join(","))})`,
              eq(documents.isDeleted, 0)
            )
          );
      }

      const formattedDocs = orgDocs.map(d => ({
        title: d.documentTitle,
        date: d.submissionDate ? new Date(d.submissionDate).toLocaleDateString() : "",
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
});

// GET /api/admin/documents - Fetch all documents for the admin queue
router.get("/admin/documents", async (req, res) => {
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
      .leftJoin(documentStatuses, eq(documents.statusId, documentStatuses.statusId))
      .leftJoin(accounts, eq(documents.uploadedBy, accounts.accountId))
      .leftJoin(organizations, eq(accounts.organizationId, organizations.organizationId))
      .where(eq(documents.isDeleted, 0))
      .orderBy(desc(documents.submissionDate));

    const result = docs.map(d => {
      const hasSpent = d.description?.includes("Total Amount Spent") || false;
      const accuracy = hasSpent ? 98.2 : 94.5;
      const flags = hasSpent ? [] : ["Missing amount breakdown"];
      
      return {
        id: d.id.toString(),
        title: d.title,
        organization: d.orgCode || "ISITE",
        senderName: `${d.senderFirstName} ${d.senderLastName}`,
        documentType: d.fileType === "application/pdf" ? "Audit Report" : "Financial Document",
        uploadDate: d.uploadDate ? new Date(d.uploadDate).toISOString() : new Date().toISOString(),
        fileSize: d.fileSize ? `${(d.fileSize / 1024).toFixed(1)} KB` : "120 KB",
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
});

// GET /api/admin/users - Fetch all users formatted for admin view
router.get("/admin/users", async (req, res) => {
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
      .leftJoin(organizations, eq(accounts.organizationId, organizations.organizationId));

    const result = users.map(u => ({
      fullName: `${u.firstName} ${u.lastName}`,
      email: u.email,
      role: u.roleName === "Officer" ? "Officers" : u.roleName || "Student",
      organization: u.orgCode || "ISITE",
      lastLogin: u.lastLogin ? `Last login: ${new Date(u.lastLogin).toLocaleDateString()}` : "Never logged in",
      isActive: u.isActive === 1,
      systemFlag: u.isActive === 1 ? "ACTIVE" : "ARCHIVED",
    }));

    res.json(result);
  } catch (error) {
    console.error("Error fetching admin users:", error);
    res.status(500).json({ error: "Failed to fetch admin users" });
  }
});

// PUT /api/admin/documents/:id/status - Update document status
router.put("/admin/documents/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'APPROVED' or 'REJECTED' or 'PENDING'

    // Get statusId from statusName
    const docStatus = await db
      .select()
      .from(documentStatuses)
      .where(eq(documentStatuses.statusName, status.toUpperCase()))
      .limit(1);

    if (docStatus.length === 0) {
      return res.status(400).json({ error: "Invalid status name" });
    }

    const statusId = docStatus[0].statusId;

    // Update document status
    const updatedDoc = await db
      .update(documents)
      .set({
        statusId: statusId,
        lastModified: new Date(),
      })
      .where(eq(documents.documentId, parseInt(id)))
      .returning();

    if (updatedDoc.length === 0) {
      return res.status(404).json({ error: "Document not found" });
    }

    res.json({ message: `Document status updated to ${status} successfully`, document: updatedDoc[0] });
  } catch (error) {
    console.error("Error updating document status:", error);
    res.status(500).json({ error: "Failed to update document status" });
  }
});

export default router;
