# Verifi

## Version Information

**Current Version:** 2.2.0 (June 2026)  
**Status:** AI & Interactive Chatbot Integration Complete  

> **IMPORTANT:** The system now incorporates automated AI document auditing and an interactive chatbot helper. These services run securely using Google Gemini on the server, avoiding any client-side API key exposure.

---

## Project Setup

- **Frontend:** Flutter (Dart) - v3.11.0+
- **Backend:** Node.js + Express v5.2.1
- **Database:** SQLite with better-sqlite3
- **ORM:** Drizzle ORM v0.45.2
- **AI Integration:** Google Gen AI SDK (`@google/generative-ai` v0.24.1) powered by `gemini-2.5-flash`
- **Tunnel Service:** ngrok integration for easy mobile-to-local testing

---

## Project Overview

Verifi is an AI-powered financial transparency and audit verification system designed for student organizations at the Polytechnic University of the Philippines Sta. Maria Bulacan Campus. The application enables digital document submission, automated AI analysis, and secure hash-based integrity verification to eliminate manual errors and prevent financial mismanagement.

---

## Key Features

- **Officer Portal:** Specialized dashboard for organization officers to submit and manage financial reports.
- **AI-Powered File Scanning:** Automated data auditing and extraction from uploaded documents using Google Gemini 2.5. Upon upload, Gemini automatically parses the document type/title to construct a realistic financial audit breakdown:
  * **Proposed Budget**
  * **Total Amount Spent**
  * **Ending Balance**
  * **Categorization & Scanned Items List**
  * **Verification Warning Flags**
- **Interactive AI Chatbot (VeriFi AI):** Real-time conversational assistant equipped with **RAG (Retrieval-Augmented Generation)** context.
  * Injects active organization document summaries directly into Gemini's system instructions.
  * Answers specific compliance, ledger validation, budget status, and integrity questions in real-time.
  * Designed with conversational memory, suggested chip queries, typing indicators, and support for light/dark theme aesthetics.
- **Secure Vault:** Document repository with SHA-256 integrity verification.
- **Compliance Tracking:** Real-time statistics on submission rates and transparency indices.
- **Audit Verification:** Hash-based data integrity checks to ensure documents haven't been tampered with.

---

## Project Structure

```text
flutter_application_transparatech/
├── client/                          # Flutter mobile application
│   ├── lib/                         # Main Flutter application code
│   │   ├── features/               # Feature modules
│   │   │   ├── auth/               # Authentication & User Management
│   │   │   ├── officer/            # Officer Dashboard, Vault, & Insights
│   │   │   └── dashboard/          # Shared views
│   │   │       └── presentation/pages/
│   │   │           └── ai_chatbot_page.dart # Interactive AI Chatbot Page (NEW)
│   │   ├── core/                   # Core functionality (Network, Theme, Utils)
│   │   │   ├── network/http_client.dart # Exposes the server base & tunnel URL configurations
│   │   │   └── widgets/profile_header.dart # Custom header with AI Chatbot bubble trigger
│   │   └── main.dart               # Entry point
│
├── server/                          # Node.js + Express backend
│   ├── src/
│   │   ├── db/                     # Drizzle ORM Schema & Migrations
│   │   ├── routes/                 # API endpoints
│   │   │   ├── api.ts              # Contains /api/chat RAG route (NEW)
│   │   │   ├── auth.routes.ts      # Authentication routes
│   │   │   └── officer.routes.ts   # Document ingestion routes calling AI analysis
│   │   ├── services/
│   │   │   └── ai.service.ts       # Gemini API client, Doc Scanner & Chat interfaces (NEW)
│   │   ├── middleware/            # JWT Auth & Validation
│   │   └── index.ts                # Application entry point
│   ├── .env                        # Secret environment variables
│   ├── sqlite.db                  # Local SQLite database
│   └── package.json               # Dependencies & scripts
```

---

## Database Schema (Current)

The system utilizes a comprehensive relational schema managed by Drizzle ORM:
- **Accounts & Roles:** Secure user management with role-based access control (Officer, Member, etc.).
- **Organizations:** Tracks registered campus orgs (e.g., COSC, ISITE).
- **Documents:** Metadata tracking including titles, descriptions (populated with Gemini scans), file paths, sizes, and integrity hashes.
- **Document Statuses:** Lifecycle management (DRAFT, PENDING, APPROVED, REJECTED, ARCHIVED).
- **Activity Logs:** Audit trails for all system actions.

---

## Development Setup

### 1. Environment Configuration (Server)
Create a `.env` file in the `server/` directory and configure the following variables:
```env
PORT=3000
JWT_SECRET=your-secure-jwt-secret-key
DATABASE_URL=transparatech.db
NODE_ENV=development

# Ngrok Authtoken (Required for running local server tunnel to mobile devices)
NGROK_AUTHTOKEN=your-ngrok-token

# Google Gemini API Key (Required for AI features)
GEMINI_API_KEY=your-gemini-api-key
```

### 2. Run the Backend Server
1. Navigate to the server directory:
   ```bash
   cd server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Initialize the database and seeds:
   ```bash
   npm run db:setup
   ```
4. Start the server (this automatically opens an ngrok tunnel):
   ```bash
   npm run dev
   ```
5. Copy the generated ngrok URL from the terminal log (e.g., `https://xxxx-xxxx.ngrok-free.app`).

### 3. Run the Mobile Client
1. Open [http_client.dart](file:///C:/flutter_application_transparatech/client/lib/core/network/http_client.dart#L79).
2. Update the `tunnelUrl` variable with your copied ngrok URL:
   ```dart
   const String tunnelUrl = 'https://xxxx-xxxx.ngrok-free.app';
   ```
3. Navigate to the client directory:
   ```bash
   cd client
   ```
4. Fetch dependencies:
   ```bash
   flutter pub get
   ```
5. Run the application:
   ```bash
   flutter run
   ```
   *(Or build release APKs using `flutter build apk --split-per-abi`)*

---

## Project Phases Status

- [COMPLETED] **Phase 1:** Core Infrastructure (SQLite + Drizzle + Express)
- [COMPLETED] **Phase 2:** Authentication System (JWT + Bcrypt)
- [COMPLETED] **Phase 3:** Officer Portal (Dashboard, Vault, Search, & Stats)
- [COMPLETED] **Phase 4:** AI Document Analysis & Extraction (Gemini 2.5 Flash Scanning)
- [COMPLETED] **Phase 5:** Interactive AI Assistant (RAG Chatbot integrated)

---

Developed by: **HEXADEVS**
