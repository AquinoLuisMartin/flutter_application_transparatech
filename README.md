# Verifi

## Version Information

**Current Version:** 2.0.0 (May 2026)
**Status:** Active Development - Follow Latest Updates

> **IMPORTANT:** This project is under active development. Please follow the latest version and updates documented in this README. Database schema and dependencies may change with new releases.

## Project Setup

- **Frontend:** Flutter (Dart) - v3.11.0+
- **Backend:** Node.js + Express v5.2.1
- **Database:** SQLite with better-sqlite3
- **ORM:** Drizzle ORM v0.45.2
- **Authentication:** JWT (jsonwebtoken v9.0.3)
- **Password Hashing:** bcryptjs v3.0.3

## Project Overview

This study looks into the Verifi mobile app, designed to improve financial transparency and accountability in student organizations at the Polytechnic University of the Philippines Sta. Maria Bulacan Campus. The app lets students submit, track, and verify financial documents (like financial reports and asset records) digitally, making the process easier, faster, and more secure.

The system is created in response to common issues in the government and other organizations, where lack of transparency in budgeting and auditing leads to corruption and mismanagement of funds. Similarly, many student organizations still rely on manual paper-based methods for submitting financial records, which can lead to mistakes, delays, and even tampering. Verifi aims to solve these problems by offering a modern, digital solution for financial transparency.

## General Objective

To develop a secure mobile-based audit verification system that enhances financial transparency and accountability.

## Specific Objectives

- To develop a mobile application for digital financial document submission and tracking.
- To implement AI-powered document analysis for automatic data extraction.
- To ensure document and data integrity using hashing and secure authentication.
- To optimize financial record retrieval using efficient database indexing algorithms.
- To increase trust and transparency among organization members.

## Project Structure

```
flutter_application_transparatech/
├── client/                          # Flutter mobile application
│   ├── android/                     # Android native code and configuration
│   ├── ios/                         # iOS native code and configuration
│   ├── lib/                         # Main Flutter application code
│   │   ├── main.dart               # Application entry point
│   │   ├── core/                   # Core functionality and utilities
│   │   │   ├── config/             # Build configuration
│   │   │   ├── constants/          # Application constants
│   │   │   ├── error/              # Error handling
│   │   │   ├── network/            # Network configuration
│   │   │   ├── utils/              # Utility functions (logging, etc.)
│   │   │   └── widgets/            # Reusable core widgets
│   │   ├── features/               # Feature modules
│   │   │   ├── auth/               # Authentication feature
│   │   │   ├── dashboard/          # Dashboard feature
│   │   │   ├── document_analysis/  # Document analysis feature
│   │   │   ├── document_security/  # Document security feature
│   │   │   ├── document_submission/# Document submission feature
│   │   │   ├── landing/            # Landing page feature
│   │   │   └── records/            # Records verification feature
│   │   ├── injection/              # Dependency injection setup
│   │   └── routes/                 # Application routing
│   ├── assets/                     # Static assets
│   │   ├── fonts/                  # Custom fonts
│   │   ├── icons/                  # Icon assets
│   │   └── images/                 # Image assets
│   ├── test/                       # Unit and widget tests
│   ├── web/                        # Web platform configuration
│   ├── linux/                      # Linux platform configuration
│   ├── macos/                      # macOS platform configuration
│   ├── windows/                    # Windows platform configuration
│   ├── pubspec.yaml               # Flutter dependencies and configuration
│   ├── analysis_options.yaml      # Dart analysis configuration
│   └── README.md                  # Client documentation
│
├── server/                          # Node.js + Express backend
│   ├── src/
│   │   ├── db/                     # Database setup with Drizzle ORM
│   │   │   ├── schema.ts          # Database schema (users, sessions)
│   │   │   └── ...                # Database utilities
│   │   ├── controllers/           # Request handlers
│   │   ├── routes/                # API routes
│   │   ├── services/              # Business logic
│   │   ├── middleware/            # Express middleware
│   │   └── utils/                 # Utility functions
│   ├── drizzle.config.js          # Drizzle ORM configuration
│   ├── package.json               # Node dependencies
│   └── sqlite.db                  # SQLite database file
│
├── drizzle.config.js              # Root Drizzle configuration (legacy)
└── .gitignore                     # Git ignore rules
```

---

## Recent Updates & Changes

### Database & Backend Infrastructure (May 2026)

#### Database Migration
- **Previous:** PostgreSQL + Prisma ORM
- **Current:** SQLite + Drizzle ORM v0.45.2
- **Benefits:** Simplified local development, reduced deployment complexity, faster prototyping
- **Database Files:**
  - `server/drizzle.config.js` - Drizzle ORM configuration
  - `server/src/db/schema.ts` - Database schema definition
  - `server/sqlite.db` - SQLite database file

#### Database Schema
The application currently uses the following tables:

**Users Table:**
- `id` (PRIMARY KEY) - Unique user identifier
- `email` (UNIQUE, NOT NULL) - User email address
- `password` (NOT NULL) - Hashed password using bcryptjs
- `name` - User's display name
- `createdAt` - Account creation timestamp
- `updatedAt` - Last update timestamp

**Sessions Table:**
- `id` (PRIMARY KEY) - Unique session identifier
- `userId` (FOREIGN KEY → users.id) - Associated user
- `token` (UNIQUE, NOT NULL) - JWT session token
- `expiresAt` (NOT NULL) - Token expiration timestamp
- `createdAt` - Session creation timestamp

#### Backend Dependencies
- **express** v5.2.1 - Web framework
- **better-sqlite3** v12.9.0 - SQLite driver
- **drizzle-orm** v0.45.2 - ORM
- **jsonwebtoken** v9.0.3 - JWT authentication
- **bcryptjs** v3.0.3 - Password hashing
- **dotenv** v17.4.2 - Environment configuration
- **typescript** v6.0.3 - Type safety
- **tsx** v4.21.0 - TypeScript execution

#### Frontend Dependencies
- **google_fonts** v8.1.0 - Custom fonts
- **crypto** v3.0.7 - Hashing utilities
- **get_it** v9.2.1 - Service locator/DI
- **http** v1.6.0 - HTTP client
- **provider** v6.1.5+1 - State management
- **json_annotation** v4.11.0 - JSON serialization

### Development Setup

#### Server Setup
1. Navigate to server directory: `cd server`
2. Install dependencies: `npm install`
3. Configure environment variables in `.env` file
4. Initialize database: `npm run drizzle-kit push`
5. Start development server: `npm run dev` (once scripts are configured)

#### Client Setup
1. Ensure Flutter SDK v3.11.0+ is installed
2. Run `flutter pub get` to fetch dependencies
3. Configure backend API endpoint in environment configuration
4. Run `flutter run` for development

### Project Phases Status

- [COMPLETED] **Phase 1:** Core Infrastructure - COMPLETED
- [IN PROGRESS] **Phase 2:** Dependency Injection - IN PROGRESS
- [TODO] **Phase 3-9:** Features (Authentication, Dashboard, Document Features, etc.) - TODO

---

## Version Guide

### Current Version: 2.0.0 (May 2026)

**Key Changes in v2.0.0:**
- [DONE] Migrated database from PostgreSQL + Prisma to SQLite + Drizzle ORM
- [DONE] Updated backend stack (Express v5.2.1)
- [DONE] Simplified local development environment
- [DONE] Implemented Drizzle ORM for type-safe database operations
- [DONE] Added JWT authentication and bcryptjs password hashing
- [NOTE] Database schema still being refined (subject to change)

### Version Compatibility Matrix

| Component | Version | Status | Notes |
|-----------|---------|--------|-------|
| Flutter SDK | v3.11.0+ | STABLE | Minimum required |
| Node.js | v18+ | STABLE | Recommended for backend |
| Express | v5.2.1 | LATEST | ESM support required |
| SQLite | Latest | STABLE | Via better-sqlite3 |
| Drizzle ORM | v0.45.2 | LATEST | Active updates expected |
| TypeScript | v6.0.3 | LATEST | Full type coverage |

### Breaking Changes from Previous Versions

**v1.x → v2.0:**
- Database: PostgreSQL → SQLite
- ORM: Prisma → Drizzle ORM
- Connection strings and migration scripts have changed
- API endpoints unchanged (backward compatible)

### How to Update

1. **Pull Latest Changes:** `git pull origin main`
2. **Backend:** 
   - `cd server`
   - `npm install` (to update dependencies)
   - `npx drizzle-kit push` (to sync schema with database)
3. **Frontend:** 
   - `flutter pub get` (to update Flutter dependencies)
   - Clear build cache: `flutter clean`
   - Run: `flutter run`

### Upcoming Changes (Planned)

- Database schema expansion for document management (Phase 3+)
- API authentication middleware
- Document upload and verification endpoints
- AI-powered document analysis integration

---

Developed by: HEXADEVS
