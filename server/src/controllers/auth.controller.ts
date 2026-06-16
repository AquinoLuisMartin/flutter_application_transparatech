import { Request, Response } from 'express';
import { db } from '../db/index.js';
import { accounts, organizations, roles } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import * as authService from '../services/auth.service.js';
import { AuthRequest } from '../middleware/auth.middleware.js';
import { signupSchema, loginSchema } from '../utils/validation.js';
import { logActivity } from '../utils/audit-logger.js';
import { config } from '../config.js';

// ──────────────────────────────────────────────
// Sign up (C-5 fix: role is NEVER user-supplied)
// ──────────────────────────────────────────────

export const signup = async (req: Request, res: Response) => {
  try {
    // ── M-1: Validate input with zod ──
    const parsed = signupSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: 'Validation failed',
        issues: parsed.error.issues.map((i) => ({
          field: i.path.join('.'),
          message: i.message,
        })),
      });
    }

    const { email, studentId, password, fullName, organizationCode } = parsed.data;

    // Validate password strength
    const passwordCheck = authService.validatePasswordStrength(password);
    if (!passwordCheck.valid) {
      return res.status(400).json({ error: passwordCheck.message });
    }

    // Check if email already exists
    const existingEmail = await db
      .select()
      .from(accounts)
      .where(eq(accounts.email, email.toLowerCase()))
      .limit(1);

    if (existingEmail.length > 0) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Check if student ID already exists
    const existingStudentId = await db
      .select()
      .from(accounts)
      .where(eq(accounts.studentId, studentId))
      .limit(1);

    if (existingStudentId.length > 0) {
      return res.status(409).json({ error: 'Student ID already registered' });
    }

    // Hash password
    const hashedPassword = await authService.hashPassword(password);

    // Generate username
    const username = authService.generateUsername(email);

    // Split full name
    const { firstName, lastName } = authService.splitFullName(
      fullName || email.split('@')[0],
    );

    // ── C-5: Always force Student role for self-registration ──
    const roleId = await authService.getRoleIdByName('Student');

    // Get organization if provided
    let organizationId: number | null = null;
    if (organizationCode) {
      const org = await db
        .select()
        .from(organizations)
        .where(eq(organizations.orgCode, organizationCode))
        .limit(1);
      if (org.length > 0) {
        organizationId = org[0].organizationId;
      }
    }

    // Create new account
    try {
      await db
        .insert(accounts)
        .values({
          email: email.toLowerCase(),
          username: username,
          studentId: studentId,
          passwordHash: hashedPassword,
          firstName: firstName,
          lastName: lastName,
          roleId: roleId,
          organizationId: organizationId,
          isActive: 1,
          isVerified: 0,
          createdAt: new Date(),
          updatedAt: new Date(),
        })
        .run();

      // Fetch the newly created account
      const newAccount = await db
        .select()
        .from(accounts)
        .where(eq(accounts.email, email.toLowerCase()))
        .limit(1);

      if (!newAccount || newAccount.length === 0) {
        return res.status(500).json({ error: 'Failed to create account' });
      }

      const user = newAccount[0];

      // Fetch role name for JWT (H-5)
      const userRole = await db
        .select({ roleName: roles.roleName })
        .from(roles)
        .where(eq(roles.roleId, user.roleId))
        .limit(1);

      // Generate JWT token with role info
      const token = authService.generateToken({
        accountId: user.accountId,
        email: user.email,
        roleId: user.roleId,
        roleName: userRole[0]?.roleName || 'Student',
      });

      // Audit log
      await logActivity({
        userId: user.accountId,
        action: 'SIGNUP',
        module: 'AUTH',
        resourceType: 'account',
        resourceId: user.accountId,
        description: `New account created for ${user.email}`,
        req,
        status: 'SUCCESS',
      });

      // Return response without password (strip sensitive fields)
      const { passwordHash, ...accountData } = user;
      res.status(201).json({
        message: 'Account created successfully',
        token,
        account: accountData,
      });
    } catch (error: any) {
      console.error('Database insertion error:', error);

      // ── H-4: Sanitized error messages — no raw DB details ──
      if (error.message?.includes('CHECK constraint failed')) {
        if (error.message.includes('email')) {
          return res.status(400).json({ error: 'Email must be a PUP Iskolar ng Bayan address' });
        }
        if (error.message.includes('student_id')) {
          return res.status(400).json({ error: 'Invalid student ID format' });
        }
      }

      if (error.message?.includes('UNIQUE constraint failed')) {
        if (error.message.includes('email')) {
          return res.status(409).json({ error: 'Email already registered' });
        }
        if (error.message.includes('student_id')) {
          return res.status(409).json({ error: 'Student ID already registered' });
        }
      }

      res.status(500).json({ error: 'Internal server error' });
    }
  } catch (error: any) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// Login
// ──────────────────────────────────────────────

export const login = async (req: Request, res: Response) => {
  try {
    // ── M-1: Validate input with zod ──
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const { email, password } = parsed.data;

    // Find account by email
    const account = await db
      .select()
      .from(accounts)
      .where(eq(accounts.email, email.toLowerCase()))
      .limit(1);

    if (account.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = account[0];

    // Check if account is active
    if (!user.isActive) {
      return res.status(401).json({ error: 'Account is inactive' });
    }

    // Compare password
    const isPasswordValid = await authService.comparePassword(
      password,
      user.passwordHash || '',
    );

    if (!isPasswordValid) {
      // Audit log failed login
      await logActivity({
        userId: user.accountId,
        action: 'LOGIN_FAILED',
        module: 'AUTH',
        resourceType: 'account',
        resourceId: user.accountId,
        description: `Failed login attempt for ${user.email}`,
        req,
        status: 'FAILURE',
      });

      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Fetch role name for JWT (H-5)
    const userRole = await db
      .select({ roleName: roles.roleName })
      .from(roles)
      .where(eq(roles.roleId, user.roleId))
      .limit(1);

    // Generate JWT token with role info
    const token = authService.generateToken({
      accountId: user.accountId,
      email: user.email,
      roleId: user.roleId,
      roleName: userRole[0]?.roleName || 'Student',
    });

    // Update lastLogin (H-7)
    await db
      .update(accounts)
      .set({ lastLogin: new Date() })
      .where(eq(accounts.accountId, user.accountId));

    // Audit log successful login
    await logActivity({
      userId: user.accountId,
      action: 'LOGIN',
      module: 'AUTH',
      resourceType: 'account',
      resourceId: user.accountId,
      description: `Successful login for ${user.email}`,
      req,
      status: 'SUCCESS',
    });

    // Return response without password
    const { passwordHash, ...accountData } = user;
    res.status(200).json({
      message: 'Login successful',
      token,
      account: accountData,
    });
  } catch (error: any) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// Get current user profile
// ──────────────────────────────────────────────

export const getProfile = async (req: AuthRequest, res: Response) => {
  try {
    const accountId = req.user?.accountId;

    if (!accountId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const account = await db
      .select()
      .from(accounts)
      .where(eq(accounts.accountId, accountId))
      .limit(1);

    if (account.length === 0) {
      return res.status(404).json({ error: 'Account not found' });
    }

    const { passwordHash, ...accountData } = account[0];
    res.status(200).json(accountData);
  } catch (error: any) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
