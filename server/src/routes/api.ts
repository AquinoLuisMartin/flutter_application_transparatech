import express from "express";
import { db } from "../db/index.js";
import { accounts, roles } from "../db/schema.js";
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
    const allAccounts = await db.select().from(accounts);
    res.json(allAccounts);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch accounts" });
  }
});

export default router;
