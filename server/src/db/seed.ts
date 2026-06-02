import { db } from "./index.js";
import { roles, documentStatuses } from "./schema.js";

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

    console.log("Seeding completed successfully!");
  } catch (error) {
    console.error("Error seeding database:", error);
  }
}

seed();
