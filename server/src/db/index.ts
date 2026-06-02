import { Database } from "better-sqlite3";
import DatabaseConstructor from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";
import * as schema from "./schema.js";
import dotenv from 'dotenv';

dotenv.config();

const dbPath = process.env.DATABASE_URL || "sqlite.db";

// Initialize SQLite database
const sqlite = new DatabaseConstructor(dbPath);

// ENFORCE FOREIGN KEYS FOR SQLITE
sqlite.pragma("foreign_keys = ON");

// Initialize Drizzle ORM
export const db = drizzle(sqlite, { schema });
