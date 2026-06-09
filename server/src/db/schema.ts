import {
  sqliteTable,
  text,
  integer,
  index,
  unique,
  check
} from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";

// ============================================
// 1. ROLES TABLE
// ============================================
export const roles = sqliteTable("roles", {
  roleId: integer("role_id").primaryKey({ autoIncrement: true }),
  roleName: text("role_name").unique().notNull(),
  description: text("description"),
  isActive: integer("is_active").default(1).notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  updatedAt: integer("updated_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxRoleName: index("idx_roles_role_name").on(table.roleName),
  idxIsActive: index("idx_roles_is_active").on(table.isActive),
  checkIsActive: check("roles_is_active_check", sql`${table.isActive} IN (0, 1)`),
}));

// ============================================
// 2. PERMISSIONS TABLE
// ============================================
export const permissions = sqliteTable("permissions", {
  permissionId: integer("permission_id").primaryKey({ autoIncrement: true }),
  permissionName: text("permission_name").unique().notNull(),
  moduleName: text("module_name").notNull(),
  actionType: text("action_type").notNull(),
  description: text("description"),
  isActive: integer("is_active").default(1).notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxModuleName: index("idx_perms_module").on(table.moduleName),
  idxActionType: index("idx_perms_action").on(table.actionType),
  checkIsActive: check("permissions_is_active_check", sql`${table.isActive} IN (0, 1)`),
  checkActionType: check("permissions_action_type_check", sql`${table.actionType} IN ('CREATE', 'READ', 'EDIT', 'DELETE', 'DEACTIVATE', 'APPROVE', 'REJECT', 'ARCHIVE', 'ROLLBACK', 'ACCESS')`),
}));

// ============================================
// 3. ACCOUNTS TABLE
// ============================================
export const accounts = sqliteTable("accounts", {
  accountId: integer("account_id").primaryKey({ autoIncrement: true }),
  studentId: text("student_id").unique(), // Added student_id to match client form
  username: text("username").unique().notNull(),
  email: text("email").unique().notNull(),
  passwordHash: text("password_hash").notNull(),
  firstName: text("first_name").notNull(),
  lastName: text("last_name").notNull(),
  phoneNumber: text("phone_number"),
  profilePictureUrl: text("profile_picture_url"),
  dateOfBirth: text("date_of_birth"),
  roleId: integer("role_id").notNull().references(() => roles.roleId, { onDelete: "restrict" }),
  isActive: integer("is_active").default(1).notNull(),
  isVerified: integer("is_verified").default(0).notNull(),
  lastLogin: integer("last_login", { mode: "timestamp" }),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  updatedAt: integer("updated_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  deactivatedAt: integer("deactivated_at", { mode: "timestamp" }),
  organizationId: integer("organization_id").references(() => organizations.organizationId, { onDelete: "set null" }),
}, (table) => ({
  idxUsername: index("idx_acc_username").on(table.username),
  idxStudentId: index("idx_acc_student_id").on(table.studentId),
  idxEmail: index("idx_acc_email").on(table.email),
  idxRoleId: index("idx_acc_role_id").on(table.roleId),
  idxOrganizationId: index("idx_acc_org_id").on(table.organizationId),
  idxIsActive: index("idx_acc_is_active").on(table.isActive),
  idxCreatedAt: index("idx_acc_created_at").on(table.createdAt),
  checkIsActive: check("accounts_is_active_check", sql`${table.isActive} IN (0, 1)`),
  checkIsVerified: check("accounts_is_verified_check", sql`${table.isVerified} IN (0, 1)`),
  checkEmailDomain: check("accounts_email_domain_check", sql`${table.email} LIKE '%@pup.edu.ph'`),
  checkStudentIdFormat: check("accounts_student_id_format_check", sql`${table.studentId} LIKE '____-_____-SM-_' OR ${table.studentId} LIKE 'FA-____-SM-____'`),
}));

// ============================================
// 3.5 ORGANIZATIONS TABLE
// ============================================
export const organizations = sqliteTable("organizations", {
  organizationId: integer("organization_id").primaryKey({ autoIncrement: true }),
  orgName: text("org_name").unique().notNull(),
  orgCode: text("org_code").unique().notNull(), // e.g. COSC, ISITE
  orgEmail: text("org_email").unique(), // Added orgEmail field
  description: text("description"),
  logoUrl: text("logo_url"),
  isActive: integer("is_active").default(1).notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxOrgCode: index("idx_org_code").on(table.orgCode),
  idxOrgEmail: index("idx_org_email").on(table.orgEmail),
  checkIsActive: check("organizations_is_active_check", sql`${table.isActive} IN (0, 1)`),
  checkOrgEmailDomain: check("organizations_email_domain_check", sql`${table.orgEmail} IS NULL OR ${table.orgEmail} LIKE '%@pup.edu.ph'`),
}));

// ============================================
// 3.6 BUDGETS TABLE
// ============================================
export const budgets = sqliteTable("budgets", {
  budgetId: integer("budget_id").primaryKey({ autoIncrement: true }),
  organizationId: integer("organization_id").notNull().references(() => organizations.organizationId, { onDelete: "cascade" }),
  academicYear: text("academic_year").notNull(), // e.g. 2025-2026
  totalBudget: integer("total_budget").notNull(), // in cents or smallest unit
  spentAmount: integer("spent_amount").default(0).notNull(),
  remainingAmount: integer("remaining_amount").notNull(),
  lastUpdated: integer("last_updated", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxOrgYear: index("idx_budget_org_year").on(table.organizationId, table.academicYear),
}));

// ============================================
// 4. ROLE PERMISSIONS MAPPING
// ============================================
export const rolePermissions = sqliteTable("role_permissions", {
  rolePermissionId: integer("role_permission_id").primaryKey({ autoIncrement: true }),
  roleId: integer("role_id").notNull().references(() => roles.roleId, { onDelete: "cascade" }),
  permissionId: integer("permission_id").notNull().references(() => permissions.permissionId, { onDelete: "cascade" }),
  assignedAt: integer("assigned_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  assignedBy: integer("assigned_by").references(() => accounts.accountId, { onDelete: "set null" }),
}, (table) => ({
  idxRoleId: index("idx_role_permissions_role_id").on(table.roleId),
  idxPermissionId: index("idx_role_permissions_permission_id").on(table.permissionId),
  unqRolePermission: unique("unique_role_permission").on(table.roleId, table.permissionId),
}));

// ============================================
// 5. DOCUMENT STATUSES TABLE
// ============================================
export const documentStatuses = sqliteTable("document_statuses", {
  statusId: integer("status_id").primaryKey({ autoIncrement: true }),
  statusName: text("status_name").unique().notNull(),
  statusColor: text("status_color"),
  description: text("description"),
  isActive: integer("is_active").default(1).notNull(),
}, (table) => ({
  checkStatusName: check("document_statuses_name_check", sql`${table.statusName} IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'ARCHIVED')`),
  checkIsActive: check("document_statuses_is_active_check", sql`${table.isActive} IN (0, 1)`),
}));

// ============================================
// 6. DOCUMENTS TABLE
// ============================================
export const documents = sqliteTable("documents", {
  documentId: integer("document_id").primaryKey({ autoIncrement: true }),
  documentTitle: text("document_title").notNull(),
  documentDescription: text("document_description"),
  filePath: text("file_path").notNull(),
  fileSize: integer("file_size"),
  fileType: text("file_type"),
  uploadedBy: integer("uploaded_by").notNull().references(() => accounts.accountId, { onDelete: "restrict" }),
  statusId: integer("status_id").notNull().references(() => documentStatuses.statusId, { onDelete: "restrict" }),
  submissionDate: integer("submission_date", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  lastModified: integer("last_modified", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  isDeleted: integer("is_deleted").default(0).notNull(),
  deletedAt: integer("deleted_at", { mode: "timestamp" }),
}, (table) => ({
  idxUploadedBy: index("idx_documents_uploaded_by").on(table.uploadedBy),
  idxStatusId: index("idx_documents_status_id").on(table.statusId),
  idxSubmissionDate: index("idx_documents_submission_date").on(table.submissionDate),
  idxIsDeleted: index("idx_documents_is_deleted").on(table.isDeleted),
  idxStatusDate: index("idx_documents_status_date").on(table.statusId, table.submissionDate),
  checkIsDeleted: check("documents_is_deleted_check", sql`${table.isDeleted} IN (0, 1)`),
}));

// ============================================
// 7. DOCUMENT REVIEWS
// ============================================
export const documentReviews = sqliteTable("document_reviews", {
  reviewId: integer("review_id").primaryKey({ autoIncrement: true }),
  documentId: integer("document_id").notNull().references(() => documents.documentId, { onDelete: "cascade" }),
  reviewedBy: integer("reviewed_by").notNull().references(() => accounts.accountId, { onDelete: "restrict" }),
  previousStatusId: integer("previous_status_id").references(() => documentStatuses.statusId, { onDelete: "set null" }),
  newStatusId: integer("new_status_id").notNull().references(() => documentStatuses.statusId, { onDelete: "restrict" }),
  reviewComments: text("review_comments"),
  reviewDate: integer("review_date", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxDocumentId: index("idx_document_reviews_doc_id").on(table.documentId),
  idxReviewedBy: index("idx_document_reviews_reviewed_by").on(table.reviewedBy),
  idxReviewDate: index("idx_document_reviews_review_date").on(table.reviewDate),
  idxNewStatusId: index("idx_document_reviews_new_status_id").on(table.newStatusId),
  idxDocDate: index("idx_document_reviews_doc_date").on(table.documentId, table.reviewDate),
}));

// ============================================
// 8. ACTIVITY LOGS TABLE
// ============================================
export const activityLogs = sqliteTable("activity_logs", {
  logId: integer("log_id").primaryKey({ autoIncrement: true }),
  userId: integer("user_id").references(() => accounts.accountId, { onDelete: "set null" }),
  action: text("action").notNull(),
  module: text("module").notNull(),
  resourceType: text("resource_type"),
  resourceId: integer("resource_id"),
  description: text("description"),
  ipAddress: text("ip_address"),
  userAgent: text("user_agent"),
  changesData: text("changes_data"),
  status: text("status"),
  actionDate: integer("action_date", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxUserId: index("idx_activity_logs_user_id").on(table.userId),
  idxAction: index("idx_activity_logs_action").on(table.action),
  idxModule: index("idx_activity_logs_module").on(table.module),
  idxActionDate: index("idx_activity_logs_action_date").on(table.actionDate),
  idxResourceType: index("idx_activity_logs_resource_type").on(table.resourceType),
  idxResourceId: index("idx_activity_logs_resource_id").on(table.resourceId),
  idxUserDate: index("idx_activity_logs_user_date").on(table.userId, table.actionDate),
}));

// ============================================
// 9. ASSETS TABLE
// ============================================
export const assets = sqliteTable("assets", {
  assetId: integer("asset_id").primaryKey({ autoIncrement: true }),
  assetName: text("asset_name").notNull(),
  assetType: text("asset_type"),
  category: text("category"),
  description: text("description"),
  createdBy: integer("created_by").notNull().references(() => accounts.accountId, { onDelete: "restrict" }),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  isActive: integer("is_active").default(1).notNull(),
  lastModified: integer("last_modified", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  modifiedBy: integer("modified_by").references(() => accounts.accountId, { onDelete: "set null" }),
}, (table) => ({
  idxAssetType: index("idx_assets_asset_type").on(table.assetType),
  idxCreatedBy: index("idx_assets_created_by").on(table.createdBy),
  idxIsActive: index("idx_assets_is_active").on(table.isActive),
  checkIsActive: check("assets_is_active_check", sql`${table.isActive} IN (0, 1)`),
}));

// ============================================
// 10. THIRD-PARTY APPS
// ============================================
export const thirdPartyApps = sqliteTable("third_party_apps", {
  appId: integer("app_id").primaryKey({ autoIncrement: true }),
  appName: text("app_name").unique().notNull(),
  appType: text("app_type"),
  apiKey: text("api_key"),
  apiSecret: text("api_secret"),
  isActive: integer("is_active").default(1).notNull(),
  createdBy: integer("created_by").notNull().references(() => accounts.accountId, { onDelete: "restrict" }),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
  lastModified: integer("last_modified", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxAppName: index("idx_third_party_apps_app_name").on(table.appName),
  idxIsActive: index("idx_third_party_apps_is_active").on(table.isActive),
  checkIsActive: check("third_party_apps_is_active_check", sql`${table.isActive} IN (0, 1)`),
}));

// ============================================
// 11. APP PERMISSIONS
// ============================================
export const appPermissions = sqliteTable("app_permissions", {
  appPermissionId: integer("app_permission_id").primaryKey({ autoIncrement: true }),
  appId: integer("app_id").notNull().references(() => thirdPartyApps.appId, { onDelete: "cascade" }),
  roleId: integer("role_id").notNull().references(() => roles.roleId, { onDelete: "cascade" }),
  canAdd: integer("can_add").default(0).notNull(),
  canRead: integer("can_read").default(1).notNull(),
  canEdit: integer("can_edit").default(0).notNull(),
  canDelete: integer("can_delete").default(0).notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }).default(sql`CURRENT_TIMESTAMP`).notNull(),
}, (table) => ({
  idxAppId: index("idx_app_permissions_app_id").on(table.appId),
  idxRoleId: index("idx_app_permissions_role_id").on(table.roleId),
  unqAppRole: unique("unique_app_role").on(table.appId, table.roleId),
  checkCanAdd: check("app_permissions_can_add_check", sql`${table.canAdd} IN (0, 1)`),
  checkCanRead: check("app_permissions_can_read_check", sql`${table.canRead} IN (0, 1)`),
  checkCanEdit: check("app_permissions_can_edit_check", sql`${table.canEdit} IN (0, 1)`),
  checkCanDelete: check("app_permissions_can_delete_check", sql`${table.canDelete} IN (0, 1)`),
}));
