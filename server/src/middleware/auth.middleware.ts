import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { db } from '../db/index.js';
import { accounts, roles } from '../db/schema.js';
import { eq } from 'drizzle-orm';

// ──────────────────────────────────────────────
// Typed JWT payload (L-3)
// ──────────────────────────────────────────────

export interface JwtPayload {
  accountId: number;
  email: string;
  roleId: number;
  roleName: string;
  iat: number;
  exp: number;
}

export interface AuthRequest extends Request {
  user?: JwtPayload;
}

// ──────────────────────────────────────────────
// Token verification middleware
// ──────────────────────────────────────────────

export const verifyToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, config.jwtSecret, {
      algorithms: ['HS256'], // H-5: explicitly restrict algorithm
    }) as JwtPayload;

    req.user = decoded;
    next();
  } catch (error: any) {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
};

// ──────────────────────────────────────────────
// Role-based authorization guard (C-1)
// ──────────────────────────────────────────────

/**
 * Middleware factory that restricts access to users whose DB role
 * is one of the supplied `allowedRoles`.
 *
 * Must be placed AFTER `verifyToken` in the middleware chain.
 *
 * Usage:
 *   router.get('/admin/route', verifyToken, requireRole('Admin'), handler);
 */
export const requireRole = (...allowedRoles: string[]) => {
  return async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const accountId = req.user?.accountId;
      if (!accountId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      // Verify role from DB (not just JWT) for defense-in-depth
      const account = await db
        .select({ roleName: roles.roleName })
        .from(accounts)
        .innerJoin(roles, eq(accounts.roleId, roles.roleId))
        .where(eq(accounts.accountId, accountId))
        .limit(1);

      if (
        account.length === 0 ||
        !allowedRoles.includes(account[0].roleName)
      ) {
        return res
          .status(403)
          .json({ error: 'Forbidden: insufficient permissions' });
      }

      next();
    } catch {
      res.status(500).json({ error: 'Authorization check failed' });
    }
  };
};
