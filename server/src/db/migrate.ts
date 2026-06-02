import { migrate } from "drizzle-orm/better-sqlite3/migrator";
import { db } from "./index.js";

async function runMigrations() {
  console.log("Starting migrations...");
  try {
    // This will run migrations on the database, skipping the ones already applied
    migrate(db, { migrationsFolder: "./drizzle" });
    console.log("Migrations applied successfully!");
  } catch (error) {
    console.error("Error running migrations:", error);
  }
}

runMigrations();
