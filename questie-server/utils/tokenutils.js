// =======================================================================================================================================
// Token Utilities: JWT and Authentication Token Management
// =======================================================================================================================================
// Purpose: Provides secure token generation, validation, and management for JWT access tokens and auth tokens
// =======================================================================================================================================

const jwt = require('jsonwebtoken');
const crypto = require('crypto');

// JWT token utilities
const jwtUtils = {
  // Generate JWT access token
  generateAccessToken(user) {
    const payload = {
      userId: user.id,
      email: user.email,
      displayName: user.display_name,
      isAnonymous: user.is_anonymous,
      emailVerified: user.email_verified
    };

    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '1d',
      issuer: 'questie-server',
      audience: 'questie-app'
    });
  },

  // Verify JWT access token
  verifyAccessToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET, {
        issuer: 'questie-server',
        audience: 'questie-app'
      });
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('TOKEN_EXPIRED');
      } else if (error.name === 'JsonWebTokenError') {
        throw new Error('INVALID_TOKEN');
      } else {
        throw new Error('TOKEN_VERIFICATION_FAILED');
      }
    }
  },

  // Decode JWT token without verification (for debugging)
  decodeToken(token) {
    return jwt.decode(token);
  }
};

// Authentication token utilities (for email verification and password reset)
const authTokenUtils = {
  // Generate secure random token with prefix
  generateToken(prefix = '') {
    const randomBytes = crypto.randomBytes(32);
    const token = randomBytes.toString('hex');
    return prefix ? `${prefix}_${token}` : token;
  },

  // Generate email verification token
  generateVerificationToken() {
    return authTokenUtils.generateToken('verify');
  },

  // Generate password reset token
  generatePasswordResetToken() {
    return authTokenUtils.generateToken('reset');
  },

  // Check if token has expired
  isTokenExpired(expiresAt) {
    if (!expiresAt) return true;
    return new Date() > new Date(expiresAt);
  },

  // Get token expiry timestamp
  getTokenExpiry(hours = 24) {
    const expiry = new Date();
    expiry.setHours(expiry.getHours() + hours);
    return expiry;
  },

  // Get verification token expiry (24 hours)
  getVerificationTokenExpiry() {
    return authTokenUtils.getTokenExpiry(24);
  },

  // Get password reset token expiry (1 hour)
  getPasswordResetTokenExpiry() {
    return authTokenUtils.getTokenExpiry(1);
  },

  // Validate token format
  validateTokenFormat(token, expectedPrefix = null) {
    if (!token || typeof token !== 'string') {
      return false;
    }

    if (expectedPrefix) {
      return token.startsWith(`${expectedPrefix}_`) && token.length > expectedPrefix.length + 10;
    }

    return token.length >= 32;
  },

  // Extract token type from prefixed token
  getTokenType(token) {
    if (!token || typeof token !== 'string') {
      return null;
    }

    const parts = token.split('_');
    if (parts.length >= 2) {
      return parts[0];
    }

    return null;
  }
};

// Middleware for JWT authentication
const authMiddleware = {
  // Require valid JWT token
  requireAuth(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
          return_code: 'UNAUTHORIZED',
          message: 'Access token required'
        });
      }

      const token = authHeader.substring(7); // Remove 'Bearer ' prefix
      const decoded = jwtUtils.verifyAccessToken(token);
      
      req.user = decoded;
      next();
    } catch (error) {
      let return_code = 'UNAUTHORIZED';
      let message = 'Invalid access token';

      if (error.message === 'TOKEN_EXPIRED') {
        return_code = 'TOKEN_EXPIRED';
        message = 'Access token has expired';
      } else if (error.message === 'INVALID_TOKEN') {
        return_code = 'INVALID_TOKEN';
        message = 'Invalid access token format';
      }

      return res.status(401).json({
        return_code,
        message
      });
    }
  },

  // Require verified email (for non-anonymous users)
  requireVerifiedEmail(req, res, next) {
    if (!req.user) {
      return res.status(401).json({
        return_code: 'UNAUTHORIZED',
        message: 'Authentication required'
      });
    }

    if (!req.user.isAnonymous && !req.user.emailVerified) {
      return res.status(403).json({
        return_code: 'EMAIL_NOT_VERIFIED',
        message: 'Email verification required'
      });
    }

    next();
  },

  // Optional authentication (sets req.user if token is valid)
  optionalAuth(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      
      if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.substring(7);
        const decoded = jwtUtils.verifyAccessToken(token);
        req.user = decoded;
      }
    } catch (error) {
      // Ignore authentication errors for optional auth
      console.log('Optional auth failed:', error.message);
    }
    
    next();
  }
};

module.exports = {
  jwtUtils,
  authTokenUtils,
  authMiddleware
};
