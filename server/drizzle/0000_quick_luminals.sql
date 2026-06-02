CREATE TABLE `accounts` (
	`account_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`student_id` text,
	`username` text NOT NULL,
	`email` text NOT NULL,
	`password_hash` text NOT NULL,
	`first_name` text NOT NULL,
	`last_name` text NOT NULL,
	`phone_number` text,
	`profile_picture_url` text,
	`date_of_birth` text,
	`role_id` integer NOT NULL,
	`is_active` integer DEFAULT 1 NOT NULL,
	`is_verified` integer DEFAULT 0 NOT NULL,
	`last_login` integer,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`deactivated_at` integer,
	FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) ON UPDATE no action ON DELETE restrict,
	CONSTRAINT "accounts_is_active_check" CHECK("accounts"."is_active" IN (0, 1)),
	CONSTRAINT "accounts_is_verified_check" CHECK("accounts"."is_verified" IN (0, 1)),
	CONSTRAINT "accounts_email_domain_check" CHECK("accounts"."email" LIKE '%@iskolarngbayan.pup.edu.ph'),
	CONSTRAINT "accounts_student_id_format_check" CHECK("accounts"."student_id" LIKE '____-_____-SM-_')
);
--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_student_id_unique` ON `accounts` (`student_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_username_unique` ON `accounts` (`username`);--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_email_unique` ON `accounts` (`email`);--> statement-breakpoint
CREATE INDEX `idx_acc_username` ON `accounts` (`username`);--> statement-breakpoint
CREATE INDEX `idx_acc_student_id` ON `accounts` (`student_id`);--> statement-breakpoint
CREATE INDEX `idx_acc_email` ON `accounts` (`email`);--> statement-breakpoint
CREATE INDEX `idx_acc_role_id` ON `accounts` (`role_id`);--> statement-breakpoint
CREATE INDEX `idx_acc_is_active` ON `accounts` (`is_active`);--> statement-breakpoint
CREATE INDEX `idx_acc_created_at` ON `accounts` (`created_at`);--> statement-breakpoint
CREATE TABLE `activity_logs` (
	`log_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`user_id` integer,
	`action` text NOT NULL,
	`module` text NOT NULL,
	`resource_type` text,
	`resource_id` integer,
	`description` text,
	`ip_address` text,
	`user_agent` text,
	`changes_data` text,
	`status` text,
	`action_date` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `idx_activity_logs_user_id` ON `activity_logs` (`user_id`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_action` ON `activity_logs` (`action`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_module` ON `activity_logs` (`module`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_action_date` ON `activity_logs` (`action_date`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_resource_type` ON `activity_logs` (`resource_type`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_resource_id` ON `activity_logs` (`resource_id`);--> statement-breakpoint
CREATE INDEX `idx_activity_logs_user_date` ON `activity_logs` (`user_id`,`action_date`);--> statement-breakpoint
CREATE TABLE `app_permissions` (
	`app_permission_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`app_id` integer NOT NULL,
	`role_id` integer NOT NULL,
	`can_add` integer DEFAULT 0 NOT NULL,
	`can_read` integer DEFAULT 1 NOT NULL,
	`can_edit` integer DEFAULT 0 NOT NULL,
	`can_delete` integer DEFAULT 0 NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY (`app_id`) REFERENCES `third_party_apps`(`app_id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) ON UPDATE no action ON DELETE cascade,
	CONSTRAINT "app_permissions_can_add_check" CHECK("app_permissions"."can_add" IN (0, 1)),
	CONSTRAINT "app_permissions_can_read_check" CHECK("app_permissions"."can_read" IN (0, 1)),
	CONSTRAINT "app_permissions_can_edit_check" CHECK("app_permissions"."can_edit" IN (0, 1)),
	CONSTRAINT "app_permissions_can_delete_check" CHECK("app_permissions"."can_delete" IN (0, 1))
);
--> statement-breakpoint
CREATE INDEX `idx_app_permissions_app_id` ON `app_permissions` (`app_id`);--> statement-breakpoint
CREATE INDEX `idx_app_permissions_role_id` ON `app_permissions` (`role_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `unique_app_role` ON `app_permissions` (`app_id`,`role_id`);--> statement-breakpoint
CREATE TABLE `assets` (
	`asset_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`asset_name` text NOT NULL,
	`asset_type` text,
	`category` text,
	`description` text,
	`created_by` integer NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`is_active` integer DEFAULT 1 NOT NULL,
	`last_modified` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`modified_by` integer,
	FOREIGN KEY (`created_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`modified_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE set null,
	CONSTRAINT "assets_is_active_check" CHECK("assets"."is_active" IN (0, 1))
);
--> statement-breakpoint
CREATE INDEX `idx_assets_asset_type` ON `assets` (`asset_type`);--> statement-breakpoint
CREATE INDEX `idx_assets_created_by` ON `assets` (`created_by`);--> statement-breakpoint
CREATE INDEX `idx_assets_is_active` ON `assets` (`is_active`);--> statement-breakpoint
CREATE TABLE `document_reviews` (
	`review_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`document_id` integer NOT NULL,
	`reviewed_by` integer NOT NULL,
	`previous_status_id` integer,
	`new_status_id` integer NOT NULL,
	`review_comments` text,
	`review_date` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY (`document_id`) REFERENCES `documents`(`document_id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`reviewed_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`previous_status_id`) REFERENCES `document_statuses`(`status_id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`new_status_id`) REFERENCES `document_statuses`(`status_id`) ON UPDATE no action ON DELETE restrict
);
--> statement-breakpoint
CREATE INDEX `idx_document_reviews_doc_id` ON `document_reviews` (`document_id`);--> statement-breakpoint
CREATE INDEX `idx_document_reviews_reviewed_by` ON `document_reviews` (`reviewed_by`);--> statement-breakpoint
CREATE INDEX `idx_document_reviews_review_date` ON `document_reviews` (`review_date`);--> statement-breakpoint
CREATE INDEX `idx_document_reviews_new_status_id` ON `document_reviews` (`new_status_id`);--> statement-breakpoint
CREATE INDEX `idx_document_reviews_doc_date` ON `document_reviews` (`document_id`,`review_date`);--> statement-breakpoint
CREATE TABLE `document_statuses` (
	`status_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`status_name` text NOT NULL,
	`status_color` text,
	`description` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	CONSTRAINT "document_statuses_name_check" CHECK("document_statuses"."status_name" IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'ARCHIVED')),
	CONSTRAINT "document_statuses_is_active_check" CHECK("document_statuses"."is_active" IN (0, 1))
);
--> statement-breakpoint
CREATE UNIQUE INDEX `document_statuses_status_name_unique` ON `document_statuses` (`status_name`);--> statement-breakpoint
CREATE TABLE `documents` (
	`document_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`document_title` text NOT NULL,
	`document_description` text,
	`file_path` text NOT NULL,
	`file_size` integer,
	`file_type` text,
	`uploaded_by` integer NOT NULL,
	`status_id` integer NOT NULL,
	`submission_date` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`last_modified` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`is_deleted` integer DEFAULT 0 NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`uploaded_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`status_id`) REFERENCES `document_statuses`(`status_id`) ON UPDATE no action ON DELETE restrict,
	CONSTRAINT "documents_is_deleted_check" CHECK("documents"."is_deleted" IN (0, 1))
);
--> statement-breakpoint
CREATE INDEX `idx_documents_uploaded_by` ON `documents` (`uploaded_by`);--> statement-breakpoint
CREATE INDEX `idx_documents_status_id` ON `documents` (`status_id`);--> statement-breakpoint
CREATE INDEX `idx_documents_submission_date` ON `documents` (`submission_date`);--> statement-breakpoint
CREATE INDEX `idx_documents_is_deleted` ON `documents` (`is_deleted`);--> statement-breakpoint
CREATE INDEX `idx_documents_status_date` ON `documents` (`status_id`,`submission_date`);--> statement-breakpoint
CREATE TABLE `permissions` (
	`permission_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`permission_name` text NOT NULL,
	`module_name` text NOT NULL,
	`action_type` text NOT NULL,
	`description` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "permissions_is_active_check" CHECK("permissions"."is_active" IN (0, 1)),
	CONSTRAINT "permissions_action_type_check" CHECK("permissions"."action_type" IN ('CREATE', 'READ', 'EDIT', 'DELETE', 'DEACTIVATE', 'APPROVE', 'REJECT', 'ARCHIVE', 'ROLLBACK', 'ACCESS'))
);
--> statement-breakpoint
CREATE UNIQUE INDEX `permissions_permission_name_unique` ON `permissions` (`permission_name`);--> statement-breakpoint
CREATE INDEX `idx_perms_module` ON `permissions` (`module_name`);--> statement-breakpoint
CREATE INDEX `idx_perms_action` ON `permissions` (`action_type`);--> statement-breakpoint
CREATE TABLE `role_permissions` (
	`role_permission_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`role_id` integer NOT NULL,
	`permission_id` integer NOT NULL,
	`assigned_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`assigned_by` integer,
	FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`permission_id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`assigned_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `idx_role_permissions_role_id` ON `role_permissions` (`role_id`);--> statement-breakpoint
CREATE INDEX `idx_role_permissions_permission_id` ON `role_permissions` (`permission_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `unique_role_permission` ON `role_permissions` (`role_id`,`permission_id`);--> statement-breakpoint
CREATE TABLE `roles` (
	`role_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`role_name` text NOT NULL,
	`description` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "roles_is_active_check" CHECK("roles"."is_active" IN (0, 1))
);
--> statement-breakpoint
CREATE UNIQUE INDEX `roles_role_name_unique` ON `roles` (`role_name`);--> statement-breakpoint
CREATE INDEX `idx_roles_role_name` ON `roles` (`role_name`);--> statement-breakpoint
CREATE INDEX `idx_roles_is_active` ON `roles` (`is_active`);--> statement-breakpoint
CREATE TABLE `third_party_apps` (
	`app_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`app_name` text NOT NULL,
	`app_type` text,
	`api_key` text,
	`api_secret` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	`created_by` integer NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`last_modified` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY (`created_by`) REFERENCES `accounts`(`account_id`) ON UPDATE no action ON DELETE restrict,
	CONSTRAINT "third_party_apps_is_active_check" CHECK("third_party_apps"."is_active" IN (0, 1))
);
--> statement-breakpoint
CREATE UNIQUE INDEX `third_party_apps_app_name_unique` ON `third_party_apps` (`app_name`);--> statement-breakpoint
CREATE INDEX `idx_third_party_apps_app_name` ON `third_party_apps` (`app_name`);--> statement-breakpoint
CREATE INDEX `idx_third_party_apps_is_active` ON `third_party_apps` (`is_active`);