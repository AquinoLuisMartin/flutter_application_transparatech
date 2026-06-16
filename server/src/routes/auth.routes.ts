import express from 'express';
import rateLimit from 'express-rate-limit';
import { signup, login, getProfile } from '../controllers/auth.controller.js';
import { verifyToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// ── H-1: Rate limiters ──

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,                   // 10 attempts per window per IP
  message: { error: 'Too many login attempts, please try again after 15 minutes' },
  standardHeaders: true,
  legacyHeaders: false,
});

const signupLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,                    // 5 signups per hour per IP
  message: { error: 'Too many accounts created, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Public routes (rate-limited)
router.post('/signup', signupLimiter, signup);
router.post('/login', loginLimiter, login);

// Protected routes
router.get('/profile', verifyToken, getProfile);

export default router;
