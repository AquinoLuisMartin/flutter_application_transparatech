# Verifi

## Version Information

**Current Version:** 2.1.0 (June 2026)
**Status:** Active Development - Features Implementation Phase

> **IMPORTANT:** This project is under active development. The system now includes a fully functional Officer Portal and enhanced document management backend.

## Project Setup

- **Frontend:** Flutter (Dart) - v3.11.0+
- **Backend:** Node.js + Express v5.2.1
- **Database:** SQLite with better-sqlite3
- **ORM:** Drizzle ORM v0.45.2
- **Authentication:** JWT (jsonwebtoken v9.0.3)
- **Password Hashing:** bcryptjs v3.0.3

## Project Overview

Verifi is an AI-powered financial transparency and audit verification system designed for student organizations at the Polytechnic University of the Philippines Sta. Maria Bulacan Campus. The application enables digital document submission, automated AI analysis, and secure hash-based integrity verification to eliminate manual errors and prevent financial mismanagement.

## Key Features

- **Officer Portal:** Specialized dashboard for organization officers to submit and manage financial reports.
- **AI-Powered Analysis:** Automated data extraction from uploaded documents (PDF, Images).
- **Secure Vault:** Document repository with SHA-256 integrity verification.
- **Compliance Tracking:** Real-time statistics on submission rates and transparency indices.
- **Audit Verification:** Hash-based data integrity checks to ensure documents haven't been tampered with.

## Project Structure

```
flutter_application_transparatech/
├── client/                          # Flutter mobile application
│   ├── lib/                         # Main Flutter application code
│   │   ├── features/               # Feature modules
│   │   │   ├── auth/               # Authentication & User Management
│   │   │   ├── officer/            # Officer Dashboard, Vault, & Insights (LATEST)
│   │   │   ├── document_analysis/  # AI scanning & data extraction
│   │   │   └── ...                 # Other features
│   │   ├── core/                   # Core functionality (Network, Theme, Utils)
│   │   └── main.dart               # Entry point
│
├── server/                          # Node.js + Express backend
│   ├── src/
│   │   ├── db/                     # Drizzle ORM Schema & Migrations
│   │   ├── routes/                 # API endpoints (Auth, Officer, etc.)
│   │   ├── controllers/           # Business logic handlers
│   │   └── middleware/            # JWT Auth & Validation
│   ├── sqlite.db                  # Local SQLite database
│   └── package.json               # Dependencies & scripts
```

## Database Schema (Current)

The system utilizes a comprehensive relational schema managed by Drizzle ORM:
- **Accounts & Roles:** Secure user management with role-based access control (Officer, Member, etc.).
- **Documents:** Metadata tracking including titles, file paths, and current status.
- **Document Statuses:** Lifecycle management (DRAFT, PENDING, APPROVED, REJECTED, ARCHIVED).
- **Activity Logs:** Audit trails for all system actions.

## Development Setup

### Server Setup
1. Navigate to server directory: `cd server`
2. Install dependencies: `npm install`
3. Initialize/Update database: `npx drizzle-kit push` (or `npm run db:setup` for fresh start)
4. Start development server: `npm run dev`

### Client Setup
1. Ensure Flutter SDK v3.11.0+ is installed.
2. Run `flutter pub get`.
3. Start the application: `flutter run`.

## Project Phases Status

- [COMPLETED] **Phase 1:** Core Infrastructure (SQLite + Drizzle + Express)
- [COMPLETED] **Phase 2:** Authentication System (JWT + Bcrypt)
- [COMPLETED] **Phase 3:** Officer Portal (Dashboard, Vault, Search, & Stats)
- [IN PROGRESS] **Phase 4:** AI Document Analysis & Extraction
- [TODO] **Phase 5:** Audit & Verification Module (SHA-256 Integrity)

---

Developed by: HEXADEVS


