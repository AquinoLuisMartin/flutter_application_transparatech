import { db } from "./index.js";
import { roles, documentStatuses, organizations, budgets, accounts, documents } from "./schema.js";
import { eq, or } from "drizzle-orm";
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
    console.log("Seeding organizations...");
    const orgsToSeed = [
      { orgCode: "ACES", orgName: "Alliance of Computer Engineering Students", description: "Official organization for Computer Engineering students" },
      { orgCode: "iSITE", orgName: "Integrated Students in Information Technology Education", description: "Official organization for Information Technology students" },
      { orgCode: "AFT", orgName: "Association of Future Teachers", description: "Official organization for Education students" },
      { orgCode: "HMSOC", orgName: "Hospitality Management Society", description: "Official organization for Hospitality Management students" },
      { orgCode: "CEM", orgName: "Chamber of Entrepreneurs and Managers", description: "Official organization for Business Administration students" },
      { orgCode: "JPIA", orgName: "Junior Philippine Institute of Accountancy - Sta Maria", description: "Official organization for Accountancy students" },
      { orgCode: "DOMT", orgName: "Diploma in Office Management SY-Quest", description: "Official organization for Office Management students" },
    ];

    for (const orgData of orgsToSeed) {
      let org = await db.select().from(organizations).where(eq(organizations.orgCode, orgData.orgCode)).limit(1);
      let orgId: number;
      if (org.length === 0) {
        console.log(`Seeding organization ${orgData.orgCode}...`);
        const inserted = await db.insert(organizations).values({
          orgName: orgData.orgName,
          orgCode: orgData.orgCode,
          description: orgData.description,
        }).returning();
        orgId = inserted[0].organizationId;

        // Seed budget for this organization
        await db.insert(budgets).values({
          organizationId: orgId,
          academicYear: "2025-2026",
          totalBudget: 15000000, // 150,000.00 in cents
          spentAmount: 0,        // start clean
          remainingAmount: 15000000,
        }).run();
      }
    }


    const allOrgs = await db.select().from(organizations);
    const isiteOrgId = allOrgs.find(o => o.orgCode === "iSITE")?.organizationId;
    const acesOrgId = allOrgs.find(o => o.orgCode === "ACES")?.organizationId;

    // Seed a Test Officer Account
    const existingOfficer = await db.select().from(accounts).where(
      or(
        eq(accounts.email, "officer@pup.edu.ph"),
        eq(accounts.username, "officer_test")
      )
    ).limit(1);
    if (existingOfficer.length === 0 && officerRole && isiteOrgId) {
      console.log("Seeding test officer account...");
      const hashedPassword = await authService.hashPassword("Password123!");
      await db.insert(accounts).values({
        email: "officer@pup.edu.ph",
        username: "officer_test",
        studentId: "2023-00001-SM-0",
        passwordHash: hashedPassword,
        firstName: "Officer",
        lastName: "Test",
        roleId: officerRole.roleId,
        organizationId: isiteOrgId,
        isActive: 1,
        isVerified: 1,
      }).run();
      console.log("Test officer created: officer@pup.edu.ph / Password123!");
    }

    // Assign correct organization IDs to existing test/registered accounts
    console.log("Updating existing accounts with correct organization associations...");
    if (isiteOrgId) {
      // Update aira to iSITE
      await db.update(accounts)
        .set({ organizationId: isiteOrgId })
        .where(eq(accounts.username, "aira"))
        .run();
      
      // Update officer_test to iSITE (if email is different or username exists)
      await db.update(accounts)
        .set({ organizationId: isiteOrgId })
        .where(eq(accounts.username, "officer_test"))
        .run();
    }

    if (acesOrgId) {
      // Update leo to ACES
      await db.update(accounts)
        .set({ organizationId: acesOrgId })
        .where(eq(accounts.username, "leo"))
        .run();
    }


    // Seed a Test Admin Account
    const existingAdmin = await db.select().from(accounts).where(eq(accounts.email, "admin@pup.edu.ph")).limit(1);
    const adminRole = allRoles.find(r => r.roleName === "Admin");
    if (existingAdmin.length === 0 && adminRole) {
      console.log("Seeding test admin account...");
      const hashedPassword = await authService.hashPassword("AdminPassword123!");
      await db.insert(accounts).values({
        email: "admin@pup.edu.ph",
        username: "admin_test",
        studentId: "FA-2023-SM-0001",
        passwordHash: hashedPassword,
        firstName: "System",
        lastName: "Administrator",
        roleId: adminRole.roleId,
        isActive: 1,
        isVerified: 1,
      }).run();
      console.log("Test admin created: admin@pup.edu.ph / AdminPassword123!");
    }



    console.log("Seeding completed successfully!");
  } catch (error) {
    console.error("Error seeding database:", error);
  }
}

seed();
