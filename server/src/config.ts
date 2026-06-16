import dotenv from 'dotenv';
dotenv.config();

/**
 * Centralized, validated configuration.
 * The server will refuse to start if critical secrets are missing or weak.
 */
export const config = {
  /** JWT signing secret — must be ≥ 32 characters in production. */
  jwtSecret: (() => {
    const secret = process.env.JWT_SECRET;
    if (!secret || secret.length < 32) {
      throw new Error(
        'FATAL: JWT_SECRET environment variable must be set and at least 32 characters long. ' +
        'Generate one with: node -e "console.log(require(\'crypto\').randomBytes(64).toString(\'hex\'))"'
      );
    }
    return secret;
  })(),

  /** Short-lived access token expiry (H-7). */
  jwtExpiry: '1h' as const,

  port: parseInt(process.env.PORT || '3000', 10),

  databaseUrl: process.env.DATABASE_URL || 'transparatech.db',

  /** Toggle verbose error details (H-4). */
  isProduction: process.env.NODE_ENV === 'production',

  /** Allowed CORS origins (H-2). */
  corsOrigins: (process.env.CORS_ORIGINS || 'http://localhost:3000,http://localhost:8080')
    .split(',')
    .map(s => s.trim()),
} as const;
