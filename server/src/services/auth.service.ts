import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { db } from '../db/index.js';
import { roles } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import { config } from '../config.js';

// ──────────────────────────────────────────────
// Password helpers
// ──────────────────────────────────────────────

export const validatePasswordStrength = (password: string): { valid: boolean; message?: string } => {
  if (password.length < 8) {
    return { valid: false, message: 'Password must be at least 8 characters' };
  }
  if (!/[A-Z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one uppercase letter' };
  }
  if (!/[0-9]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one number' };
  }
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one special character' };
  }
  return { valid: true };
};

export const hashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(12); // bumped from 10 for stronger hashing
  return bcrypt.hash(password, salt);
};

export const comparePassword = async (password: string, hash: string): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

// ──────────────────────────────────────────────
// Role helpers
// ──────────────────────────────────────────────

export const getRoleIdByName = async (roleName: string): Promise<number> => {
  const role = await db.select().from(roles).where(eq(roles.roleName, roleName)).limit(1);
  if (role.length > 0) return role[0].roleId;

  // Default to Student if not found
  const studentRole = await db.select().from(roles).where(eq(roles.roleName, 'Student')).limit(1);
  return studentRole[0]?.roleId || 1;
};

// ──────────────────────────────────────────────
// Name / username helpers
// ──────────────────────────────────────────────

export const splitFullName = (fullName: string): { firstName: string; lastName: string } => {
  const parts = fullName.trim().split(/\s+/);
  const firstName = parts[0];
  const lastName = parts.slice(1).join(' ');
  return { firstName, lastName };
};

export const generateUsername = (email: string): string => {
  return email.split('@')[0].toLowerCase();
};

// ──────────────────────────────────────────────
// JWT helpers (C-3, H-5, H-7)
// ──────────────────────────────────────────────

/**
 * Token payload now includes role information so the
 * auth middleware can do fast authorization checks.
 * Expiry shortened from 7d → 1h.
 */
export const generateToken = (payload: {
  accountId: number;
  email: string;
  roleId: number;
  roleName: string;
}): string => {
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpiry,
    algorithm: 'HS256',
  });
};
