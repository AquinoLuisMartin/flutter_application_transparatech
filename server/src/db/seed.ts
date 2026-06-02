import { db } from "./index.js";
import { roles, documentStatuses, organizations, budgets, accounts } from "./schema.js";
import { eq } from "drizzle-orm";
import * as authService from "../services/auth.service.js";

async function seed() {
  console.log("Seeding database...");

  try {
    // Seed Roles
    const existingRoles = await db.select().from(roles);
    if (existingRoles.length === 0) {
      console.log("Seeding roles...");
      await db.insert(roles).values([
        { roleName: "Admin", description: "System Administrator" },
        { roleName: "Student", description: "Default Student User" },
        { roleName: "Officer", description: "Organization Officer" },
      ]).run();
    }

    const allRoles = await db.select().from(roles);
    const officerRole = allRoles.find(r => r.roleName === "Officer");

    // Seed Document Statuses
    const existingStatuses = await db.select().from(documentStatuses);
    if (existingStatuses.length === 0) {
      console.log("Seeding document statuses...");
      await db.insert(documentStatuses).values([
        { statusName: "DRAFT", statusColor: "#9E9E9E", description: "Document is a draft" },
        { statusName: "PENDING", statusColor: "#FFC107", description: "Document is awaiting review" },
        { statusName: "APPROVED", statusColor: "#4CAF50", description: "Document has been approved" },
        { statusName: "REJECTED", statusColor: "#F44336", description: "Document has been rejected" },
        { statusName: "ARCHIVED", statusColor: "#607D8B", description: "Document has been archived" },
      ]).run();
    }

    // Seed Organizations
    const existingOrgs = await db.select().from(organizations);
    let coscOrgId: number | undefined;

    if (existingOrgs.length === 0) {
      console.log("Seeding organizations...");
      const orgs = await db.insert(organizations).values([
        { orgName: "Computer Science Society", orgCode: "COSC", description: "Official organization for CS students" },
        { orgName: "Information Systems and Information Technology Educators", orgCode: "ISITE", description: "Official organization for IS/IT students" },
      ]).returning();

      coscOrgId = orgs.find(o => o.orgCode === "COSC")?.organizationId;

      // Seed Budgets for these organizations
      console.log("Seeding budgets...");
      for (const org of orgs) {
        await db.insert(budgets).values({
          organizationId: org.organizationId,
          academicYear: "2025-2026",
          totalBudget: 15000000, // 150,000.00 in cents
          spentAmount: 2500000,  // 25,000.00 spent
          remainingAmount: 12500000,
        }).run();
      }
    } else {
      coscOrgId = existingOrgs.find(o => o.orgCode === "COSC")?.organizationId;
    }

    // Seed a Test Officer Account
    const existingOfficer = await db.select().from(accounts).where(eq(accounts.email, "officer@iskolarngbayan.pup.edu.ph")).limit(1);
    if (existingOfficer.length === 0 && officerRole && coscOrgId) {
      console.log("Seeding test officer account...");
      const hashedPassword = await authService.hashPassword("Password123!");
      await db.insert(accounts).values({
        email: "officer@iskolarngbayan.pup.edu.ph",
        username: "officer_test",
        studentId: "2023-00001-SM-0",
        passwordHash: hashedPassword,
        firstName: "Officer",
        lastName: "Test",
        roleId: officerRole.roleId,
        organizationId: coscOrgId,
        isActive: 1,
        isVerified: 1,
      }).run();
      console.log("Test officer created: officer@iskolarngbayan.pup.edu.ph / Password123!");
    }

    console.log("Seeding completed successfully!");
  } catch (error) {
    console.error("Error seeding database:", error);
  }
}

seed();
