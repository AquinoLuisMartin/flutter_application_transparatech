PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_accounts` (
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
	`organization_id` integer,
	FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`organization_id`) REFERENCES `organizations`(`organization_id`) ON UPDATE no action ON DELETE set null,
	CONSTRAINT "accounts_is_active_check" CHECK("__new_accounts"."is_active" IN (0, 1)),
	CONSTRAINT "accounts_is_verified_check" CHECK("__new_accounts"."is_verified" IN (0, 1)),
	CONSTRAINT "accounts_email_domain_check" CHECK("__new_accounts"."email" LIKE '%@pup.edu.ph' OR "__new_accounts"."email" LIKE '%@iskolarngbayan.pup.edu.ph' OR "__new_accounts"."email" LIKE '%@iskolarngbayang.pup.edu.ph'),
	CONSTRAINT "accounts_student_id_format_check" CHECK("__new_accounts"."student_id" LIKE '____-_____-SM-_' OR "__new_accounts"."student_id" LIKE 'FA-____-SM-____')
);
--> statement-breakpoint
INSERT INTO `__new_accounts`("account_id", "student_id", "username", "email", "password_hash", "first_name", "last_name", "phone_number", "profile_picture_url", "date_of_birth", "role_id", "is_active", "is_verified", "last_login", "created_at", "updated_at", "deactivated_at", "organization_id") SELECT "account_id", "student_id", "username", "email", "password_hash", "first_name", "last_name", "phone_number", "profile_picture_url", "date_of_birth", "role_id", "is_active", "is_verified", "last_login", "created_at", "updated_at", "deactivated_at", "organization_id" FROM `accounts`;--> statement-breakpoint
DROP TABLE `accounts`;--> statement-breakpoint
ALTER TABLE `__new_accounts` RENAME TO `accounts`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_student_id_unique` ON `accounts` (`student_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_username_unique` ON `accounts` (`username`);--> statement-breakpoint
CREATE UNIQUE INDEX `accounts_email_unique` ON `accounts` (`email`);--> statement-breakpoint
CREATE INDEX `idx_acc_username` ON `accounts` (`username`);--> statement-breakpoint
CREATE INDEX `idx_acc_student_id` ON `accounts` (`student_id`);--> statement-breakpoint
CREATE INDEX `idx_acc_email` ON `accounts` (`email`);--> statement-breakpoint
CREATE INDEX `idx_acc_role_id` ON `accounts` (`role_id`);--> statement-breakpoint
CREATE INDEX `idx_acc_org_id` ON `accounts` (`organization_id`);--> statement-breakpoint
CREATE INDEX `idx_acc_is_active` ON `accounts` (`is_active`);--> statement-breakpoint
CREATE INDEX `idx_acc_created_at` ON `accounts` (`created_at`);--> statement-breakpoint
CREATE TABLE `__new_organizations` (
	`organization_id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`org_name` text NOT NULL,
	`org_code` text NOT NULL,
	`org_email` text,
	`description` text,
	`logo_url` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "organizations_is_active_check" CHECK("__new_organizations"."is_active" IN (0, 1)),
	CONSTRAINT "organizations_email_domain_check" CHECK("__new_organizations"."org_email" IS NULL OR "__new_organizations"."org_email" LIKE '%@pup.edu.ph')
);
--> statement-breakpoint
INSERT INTO `__new_organizations`("organization_id", "org_name", "org_code", "org_email", "description", "logo_url", "is_active", "created_at") SELECT "organization_id", "org_name", "org_code", NULL, "description", "logo_url", "is_active", "created_at" FROM `organizations`;--> statement-breakpoint
DROP TABLE `organizations`;--> statement-breakpoint
ALTER TABLE `__new_organizations` RENAME TO `organizations`;--> statement-breakpoint
CREATE UNIQUE INDEX `organizations_org_name_unique` ON `organizations` (`org_name`);--> statement-breakpoint
CREATE UNIQUE INDEX `organizations_org_code_unique` ON `organizations` (`org_code`);--> statement-breakpoint
CREATE UNIQUE INDEX `organizations_org_email_unique` ON `organizations` (`org_email`);--> statement-breakpoint
CREATE INDEX `idx_org_code` ON `organizations` (`org_code`);--> statement-breakpoint
CREATE INDEX `idx_org_email` ON `organizations` (`org_email`);
