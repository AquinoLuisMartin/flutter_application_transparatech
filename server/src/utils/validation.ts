import { z } from 'zod';

// ──────────────────────────────────────────────
// Auth schemas
// ──────────────────────────────────────────────

export const signupSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .max(255)
    .refine(
      (e) =>
        e.endsWith('@pup.edu.ph') ||
        e.endsWith('@iskolarngbayan.pup.edu.ph') ||
        e.endsWith('@iskolarngbayang.pup.edu.ph'),
      'Email must be a PUP Iskolar ng Bayan address',
    ),
  studentId: z
    .string()
    .min(1)
    .max(50)
    .regex(
      /^(\d{4}-\d{5}-SM-\d|FA-\d{4}-SM-\d{4})$/,
      'Invalid student ID format',
    ),
  password: z.string().min(8).max(128),
  fullName: z.string().min(1).max(255).optional(),
  organizationCode: z.string().max(20).optional(),
  role: z.string().max(50).optional(),
});

export const loginSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(1).max(128),
});

// ──────────────────────────────────────────────
// Document schemas
// ──────────────────────────────────────────────

export const documentCreateSchema = z.object({
  title: z.string().min(1, 'Title is required').max(255),
  description: z.string().max(5000).optional(),
  filePath: z
    .string()
    .min(1)
    .max(500)
    .refine((p) => !p.includes('..'), 'Path traversal is not allowed'),
  fileSize: z.number().int().nonnegative().optional(),
  fileType: z
    .enum([
      'application/pdf',
      'image/jpeg',
      'image/png',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    ])
    .optional(),
});

export const statusUpdateSchema = z.object({
  status: z.enum(['PENDING', 'APPROVED', 'REJECTED', 'ARCHIVED']),
  comments: z.string().max(1000).optional(),
});

// ──────────────────────────────────────────────
// Param schemas
// ──────────────────────────────────────────────

export const idParamSchema = z.object({
  id: z.string().regex(/^\d+$/, 'ID must be a positive integer'),
});

// ──────────────────────────────────────────────
// Search helpers
// ──────────────────────────────────────────────

/**
 * Escape SQL LIKE wildcard characters in user input (M-5).
 */
export function escapeLikePattern(input: string): string {
  return input.replace(/[%_\\]/g, '\\$&');
}
