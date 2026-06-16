import { Request } from 'express';
import { db } from '../db/index.js';
import { activityLogs } from '../db/schema.js';

/**
 * Write an immutable activity-log row (C-4 / L-2).
 *
 * Call this after every state-changing operation so there
 * is a forensic trail of who did what and when.
 */
export async function logActivity(params: {
  userId: number | null;
  action: string;
  module: string;
  resourceType?: string;
  resourceId?: number;
  description?: string;
  req: Request;
  status?: string;
}): Promise<void> {
  try {
    await db.insert(activityLogs).values({
      userId: params.userId,
      action: params.action,
      module: params.module,
      resourceType: params.resourceType ?? null,
      resourceId: params.resourceId ?? null,
      description: params.description ?? null,
      ipAddress: params.req.ip ?? null,
      userAgent: params.req.headers['user-agent'] ?? null,
      status: params.status ?? 'SUCCESS',
    });
  } catch (err) {
    // Never let audit-log failures crash the request — but always log them.
    console.error('[AUDIT-LOG] Failed to write activity log:', err);
  }
}
