// =======================================================================================================================================
// API Route: Authentication Routes
// =======================================================================================================================================
// Method: POST (and GET for verification endpoints)
// Purpose: Handle user authentication including register, login, email verification, and password reset
// =======================================================================================================================================

const express = require('express');
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');

const { userAuth } = require('../utils/database');
const { jwtUtils, authTokenUtils, authMiddleware } = require('../utils/tokenutils');
const emailService = require('../services/emailservice');

const router = express.Router();

// Rate limiting for auth endpoints
const authLimiter = rateLimit({
  windowMs: 30 * 1000, // 30 seconds
  max: 5, // limit each IP to 5 requests per windowMs for auth endpoints
  message: {
    return_code: 'RATE_LIMIT_EXCEEDED',
    message: 'Too many attempts, please try again later.'
  }
});

// Validation rules
const registerValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('display_name').trim().isLength({ min: 1, max: 100 }).withMessage('Display name required (1-100 characters)'),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
];

const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password').notEmpty().withMessage('Password required')
];

const forgotPasswordValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required')
];

const resetPasswordValidation = [
  body('token').notEmpty().withMessage('Reset token required'),
  body('new_password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
];

// Helper function to handle validation errors
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      return_code: 'VALIDATION_ERROR',
      message: 'Invalid input data',
      errors: errors.array()
    });
  }
  next();
}

// Helper function to capitalize first letter
function capitalizeFirstLetter(str) {
  if (!str) return str;
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// POST /api/auth/register
router.post('/register', authLimiter, registerValidation, handleValidationErrors, async (req, res) => {
  try {
    const { email, display_name, password } = req.body;

    // Check if user already exists
    const existingUser = await userAuth.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({
        return_code: 'USER_EXISTS',
        message: 'User with this email already exists'
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS) || 12);

    // Capitalize display name
    const capitalizedDisplayName = capitalizeFirstLetter(display_name.trim());

    // Create user
    const user = await userAuth.createUser(email, capitalizedDisplayName, passwordHash, false);

    // Generate verification token
    const verificationToken = authTokenUtils.generateVerificationToken();
    const tokenExpiry = authTokenUtils.getVerificationTokenExpiry();
    
    // Store verification token
    await userAuth.setAuthToken(user.id, verificationToken, tokenExpiry);

    // Send verification email
    try {
      await emailService.sendVerificationEmail(email, capitalizedDisplayName, verificationToken);
    } catch (emailError) {
      console.error('Failed to send verification email:', emailError);
      // Continue with registration even if email fails
    }

    res.status(201).json({
      return_code: 'SUCCESS',
      message: 'User registered successfully. Please check your email to verify your account.',
      user: {
        id: user.id,
        email: user.email,
        display_name: user.display_name,
        email_verified: user.email_verified
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Registration failed'
    });
  }
});

// POST /api/auth/login
router.post('/login', authLimiter, loginValidation, handleValidationErrors, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await userAuth.findByEmail(email);
    if (!user) {
      return res.status(401).json({
        return_code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({
        return_code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Check email verification for non-anonymous users
    if (!user.is_anonymous && !user.email_verified) {
      return res.status(403).json({
        return_code: 'EMAIL_NOT_VERIFIED',
        message: 'Email not verified. Please check your email or continue as guest.'
      });
    }

    // Update last active
    await userAuth.updateLastActive(user.id);

    // Generate JWT token
    const accessToken = jwtUtils.generateAccessToken(user);

    res.json({
      return_code: 'SUCCESS',
      message: 'Login successful',
      access_token: accessToken,
      user: {
        id: user.id,
        email: user.email,
        display_name: user.display_name,
        is_anonymous: user.is_anonymous,
        email_verified: user.email_verified,
        profile_icon: user.profile_icon
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Login failed'
    });
  }
});

// POST /api/auth/guest-login
router.post('/guest-login', async (req, res) => {
  try {
    const { display_name } = req.body;

    if (!display_name || display_name.trim().length === 0) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Display name required for guest login'
      });
    }

    // Capitalize display name
    const capitalizedDisplayName = capitalizeFirstLetter(display_name.trim());

    // Create anonymous user
    const user = await userAuth.createAnonymousUser(capitalizedDisplayName);

    // Generate JWT token
    const accessToken = jwtUtils.generateAccessToken({
      id: user.id,
      display_name: user.display_name,
      is_anonymous: true,
      email_verified: false
    });

    res.status(201).json({
      return_code: 'SUCCESS',
      message: 'Guest login successful',
      access_token: accessToken,
      user: {
        id: user.id,
        display_name: user.display_name,
        is_anonymous: user.is_anonymous,
        email_verified: false,
        profile_icon: user.profile_icon
      }
    });

  } catch (error) {
    console.error('Guest login error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Guest login failed'
    });
  }
});

// GET /api/auth/verify-email
router.get('/verify-email', async (req, res) => {
  try {
    const { token } = req.query;

    if (!token || !authTokenUtils.validateTokenFormat(token, 'verify')) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Invalid Verification Link</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #e74c3c; margin-bottom: 20px; }
            p { color: #555; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Invalid Verification Link</h1>
            <p>This verification link is invalid or has expired. Please request a new verification email.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Find user by token
    const user = await userAuth.findByAuthToken(token);
    if (!user) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Invalid Verification Link</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #e74c3c; margin-bottom: 20px; }
            p { color: #555; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Invalid Verification Link</h1>
            <p>This verification link is invalid or has expired. Please request a new verification email.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Check if token has expired
    if (authTokenUtils.isTokenExpired(user.auth_token_expires)) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Verification Link Expired</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #f39c12; margin-bottom: 20px; }
            p { color: #555; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>⏰ Verification Link Expired</h1>
            <p>This verification link has expired. Please request a new verification email from the app.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Mark email as verified
    await userAuth.markEmailVerified(user.id);

    // Return success page
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Email Verified Successfully</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
          .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
          h1 { color: #27ae60; margin-bottom: 20px; font-size: 28px; }
          p { color: #555; line-height: 1.6; margin-bottom: 15px; }
          .success-icon { font-size: 48px; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="success-icon">✅</div>
          <h1>Email Verified Successfully!</h1>
          <p>Welcome to Questie, ${user.display_name}!</p>
          <p>Your email has been verified and your account is now active. You can now log in to the app and start your quest adventure.</p>
          <p>You can safely close this window and return to the app.</p>
        </div>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Verification Error</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
          .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
          h1 { color: #e74c3c; margin-bottom: 20px; }
          p { color: #555; line-height: 1.6; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>❌ Verification Error</h1>
          <p>An error occurred while verifying your email. Please try again or contact support.</p>
        </div>
      </body>
      </html>
    `);
  }
});

// POST /api/auth/resend-verification
router.post('/resend-verification', authLimiter, [
  body('email').isEmail().normalizeEmail().withMessage('Valid email required')
], handleValidationErrors, async (req, res) => {
  try {
    const { email } = req.body;

    // Find user (don't reveal if user exists or not for security)
    const user = await userAuth.findByEmail(email);

    // Always return success to prevent user enumeration
    if (!user || user.email_verified) {
      return res.json({
        return_code: 'SUCCESS',
        message: 'If an unverified account exists with this email, a verification email has been sent.'
      });
    }

    // Generate new verification token
    const verificationToken = authTokenUtils.generateVerificationToken();
    const tokenExpiry = authTokenUtils.getVerificationTokenExpiry();

    // Store verification token
    await userAuth.setAuthToken(user.id, verificationToken, tokenExpiry);

    // Send verification email
    try {
      await emailService.sendVerificationEmail(email, user.display_name, verificationToken);
    } catch (emailError) {
      console.error('Failed to resend verification email:', emailError);
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'If an unverified account exists with this email, a verification email has been sent.'
    });

  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to resend verification email'
    });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', authLimiter, forgotPasswordValidation, handleValidationErrors, async (req, res) => {
  try {
    const { email } = req.body;

    // Find user (don't reveal if user exists or not for security)
    const user = await userAuth.findByEmail(email);

    // Always return success to prevent user enumeration
    if (!user) {
      return res.json({
        return_code: 'SUCCESS',
        message: 'If an account exists with this email, a password reset link has been sent.'
      });
    }

    // Generate password reset token
    const resetToken = authTokenUtils.generatePasswordResetToken();
    const tokenExpiry = authTokenUtils.getPasswordResetTokenExpiry();

    // Store reset token
    await userAuth.setAuthToken(user.id, resetToken, tokenExpiry);

    // Send password reset email
    try {
      await emailService.sendPasswordResetEmail(email, user.display_name, resetToken);
    } catch (emailError) {
      console.error('Failed to send password reset email:', emailError);
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'If an account exists with this email, a password reset link has been sent.'
    });

  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to process password reset request'
    });
  }
});

// GET /api/auth/reset-password (serves HTML form)
router.get('/reset-password', async (req, res) => {
  try {
    const { token } = req.query;

    if (!token || !authTokenUtils.validateTokenFormat(token, 'reset')) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Invalid Reset Link</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #e74c3c; margin-bottom: 20px; text-align: center; }
            p { color: #555; line-height: 1.6; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Invalid Reset Link</h1>
            <p>This password reset link is invalid or has expired. Please request a new password reset.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Find user by token
    const user = await userAuth.findByAuthToken(token);
    if (!user) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Invalid Reset Link</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #e74c3c; margin-bottom: 20px; text-align: center; }
            p { color: #555; line-height: 1.6; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Invalid Reset Link</h1>
            <p>This password reset link is invalid or has expired. Please request a new password reset.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Check if token has expired
    if (authTokenUtils.isTokenExpired(user.auth_token_expires)) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Reset Link Expired</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
            .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
            h1 { color: #f39c12; margin-bottom: 20px; text-align: center; }
            p { color: #555; line-height: 1.6; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>⏰ Reset Link Expired</h1>
            <p>This password reset link has expired. Please request a new password reset from the app.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Serve password reset form
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Reset Your Password - Questie</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
          .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
          h1 { color: #333; margin-bottom: 30px; text-align: center; font-size: 28px; }
          .form-group { margin-bottom: 20px; }
          label { display: block; margin-bottom: 8px; color: #555; font-weight: 500; }
          input[type="password"] { width: 100%; padding: 12px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 16px; box-sizing: border-box; }
          input[type="password"]:focus { outline: none; border-color: #2563eb; }
          .btn { width: 100%; padding: 15px; background: #2563eb; color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; }
          .btn:hover { background: #1d4ed8; }
          .btn:disabled { background: #9ca3af; cursor: not-allowed; }
          .message { padding: 15px; border-radius: 8px; margin-bottom: 20px; text-align: center; }
          .error { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
          .success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #16a34a; }
          .requirements { background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
          .requirements ul { margin: 0; padding-left: 20px; }
          .requirements li { color: #666; margin-bottom: 5px; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Reset Your Password</h1>
          <div class="requirements">
            <strong>Password Requirements:</strong>
            <ul>
              <li>At least 8 characters long</li>
            </ul>
          </div>
          <div id="message" class="message" style="display: none;"></div>
          <form id="resetForm" method="post" action="javascript:void(0)">
            <div class="form-group">
              <label for="password">New Password:</label>
              <input type="password" id="password" name="new_password" required minlength="8">
            </div>
            <div class="form-group">
              <label for="confirmPassword">Confirm New Password:</label>
              <input type="password" id="confirmPassword" name="confirm_password" required minlength="8">
            </div>
            <button type="submit" class="btn" id="submitBtn">Reset Password</button>
          </form>
        </div>
        <script>
          document.getElementById('resetForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const messageDiv = document.getElementById('message');
            const submitBtn = document.getElementById('submitBtn');

            // Validation
            if (password.length < 8) {
              showMessage('Password must be at least 8 characters long.', 'error');
              return;
            }

            if (password !== confirmPassword) {
              showMessage('Passwords do not match.', 'error');
              return;
            }

            // Submit form
            submitBtn.disabled = true;
            submitBtn.textContent = 'Resetting...';

            try {
              const response = await fetch('/api/auth/reset-password', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  token: '${token}',
                  new_password: password
                })
              });

              const data = await response.json();

              if (data.return_code === 'SUCCESS') {
                showMessage('Password reset successfully! You can now log in with your new password.', 'success');
                document.getElementById('resetForm').style.display = 'none';
              } else {
                showMessage(data.message || 'Password reset failed. Please try again.', 'error');
              }
            } catch (error) {
              showMessage('An error occurred. Please try again.', 'error');
            }

            submitBtn.disabled = false;
            submitBtn.textContent = 'Reset Password';
          });

          function showMessage(text, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.textContent = text;
            messageDiv.className = 'message ' + type;
            messageDiv.style.display = 'block';
          }
        </script>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Password reset form error:', error);
    res.status(500).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Reset Error</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
          .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 12px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
          h1 { color: #e74c3c; margin-bottom: 20px; }
          p { color: #555; line-height: 1.6; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>❌ Reset Error</h1>
          <p>An error occurred while loading the password reset form. Please try again or contact support.</p>
        </div>
      </body>
      </html>
    `);
  }
});

// POST /api/auth/reset-password (processes password reset)
router.post('/reset-password', resetPasswordValidation, handleValidationErrors, async (req, res) => {
  try {
    const { token, new_password } = req.body;

    if (!authTokenUtils.validateTokenFormat(token, 'reset')) {
      return res.status(400).json({
        return_code: 'INVALID_TOKEN',
        message: 'Invalid reset token format'
      });
    }

    // Find user by token
    const user = await userAuth.findByAuthToken(token);
    if (!user) {
      return res.status(400).json({
        return_code: 'INVALID_TOKEN',
        message: 'Invalid or expired reset token'
      });
    }

    // Check if token has expired
    if (authTokenUtils.isTokenExpired(user.auth_token_expires)) {
      return res.status(400).json({
        return_code: 'TOKEN_EXPIRED',
        message: 'Reset token has expired'
      });
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(new_password, parseInt(process.env.BCRYPT_ROUNDS) || 12);

    // Update password and clear token
    await userAuth.updatePassword(user.id, newPasswordHash);

    res.json({
      return_code: 'SUCCESS',
      message: 'Password reset successfully'
    });

  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Password reset failed'
    });
  }
});

// POST /api/auth/update-profile (protected route)
router.post('/update-profile', authMiddleware.requireAuth, [
  body('display_name').optional().trim().isLength({ min: 1, max: 100 }).withMessage('Display name must be 1-100 characters'),
  body('profile_icon').optional().trim().isLength({ min: 1, max: 255 }).withMessage('Profile icon must be 1-255 characters')
], handleValidationErrors, async (req, res) => {
  try {
    const { display_name, profile_icon } = req.body;
    const userId = req.user.userId;

    if (display_name) {
      const capitalizedDisplayName = capitalizeFirstLetter(display_name);
      await userAuth.updateDisplayName(userId, capitalizedDisplayName);
    }

    if (profile_icon) {
      await userAuth.updateProfileIcon(userId, profile_icon);
    }

    // Update last active
    await userAuth.updateLastActive(userId);

    // Get updated user info
    const updatedUser = await userAuth.findById(userId);

    res.json({
      return_code: 'SUCCESS',
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        display_name: updatedUser.display_name,
        is_anonymous: updatedUser.is_anonymous,
        email_verified: updatedUser.email_verified,
        profile_icon: updatedUser.profile_icon
      }
    });

  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Profile update failed'
    });
  }
});

// POST /api/auth/verify-token (check if token is valid)
router.post('/verify-token', authMiddleware.optionalAuth, async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        return_code: 'INVALID_TOKEN',
        message: 'Invalid or expired token'
      });
    }

    // Update last active
    await userAuth.updateLastActive(req.user.userId);

    res.json({
      return_code: 'SUCCESS',
      message: 'Token is valid',
      user: {
        id: req.user.userId,
        email: req.user.email,
        display_name: req.user.displayName,
        is_anonymous: req.user.isAnonymous,
        email_verified: req.user.emailVerified,
        profile_icon: req.user.profileIcon
      }
    });

  } catch (error) {
    console.error('Token verification error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Token verification failed'
    });
  }
});

module.exports = router;
