import { Database } from "better-sqlite3";
import DatabaseConstructor from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";
import * as schema from "./schema.js";

// Initialize SQLite database
const sqlite = new DatabaseConstructor("sqlite.db");

// ENFORCE FOREIGN KEYS FOR SQLITE
sqlite.pragma("foreign_keys = ON");

// Initialize Drizzle ORM
export const db = drizzle(sqlite, { schema });
