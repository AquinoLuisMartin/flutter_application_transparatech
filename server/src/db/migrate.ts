import { migrate } from "drizzle-orm/better-sqlite3/migrator";
import { drizzle } from "drizzle-orm/better-sqlite3";
import DatabaseConstructor from "better-sqlite3";
import dotenv from 'dotenv';

dotenv.config();

async function runMigrations() {
  console.log("Starting migrations...");
  try {
    const dbPath = process.env.DATABASE_URL || "sqlite.db";
    const sqlite = new DatabaseConstructor(dbPath);
    
    // Disable foreign keys for the duration of the migration transaction
    sqlite.pragma("foreign_keys = OFF");

    const migrationDb = drizzle(sqlite);
    migrate(migrationDb, { migrationsFolder: "./drizzle" });
    
    sqlite.close();
    console.log("Migrations applied successfully!");
  } catch (error) {
    console.error("Error running migrations:", error);
  }
}

runMigrations();
