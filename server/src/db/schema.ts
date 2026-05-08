import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const users = sqliteTable("users", {
  id: integer("id").primaryKey(),
  email: text("email").unique().notNull(),
  password: text("password").notNull(),
  name: text("name"),
  createdAt: integer("created_at", { mode: "timestamp" }).defaultNow(),
  updatedAt: integer("updated_at", { mode: "timestamp" }).defaultNow(),
});

export const sessions = sqliteTable("sessions", {
  id: integer("id").primaryKey(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id),
  token: text("token").unique().notNull(),
  expiresAt: integer("expires_at", { mode: "timestamp" }).notNull(),
  createdAt: integer("created_at", { mode: "timestamp" }).defaultNow(),
});
