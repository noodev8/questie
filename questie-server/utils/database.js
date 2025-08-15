// =======================================================================================================================================
// Database Utilities: Authentication and User Management
// =======================================================================================================================================
// Purpose: Provides database connection and authentication-related database operations
// =======================================================================================================================================

const { Pool } = require('pg');

// Database connection pool
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test database connection
pool.on('connect', () => {
  console.log('📊 Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ Database connection error:', err);
});

// Generic query function
async function query(text, params) {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('🔍 Query executed', { text: text.substring(0, 50) + '...', duration, rows: res.rowCount });
    return res;
  } catch (error) {
    console.error('❌ Database query error:', error);
    throw error;
  }
}

// User authentication functions
const userAuth = {
  // Create new user
  async createUser(email, displayName, passwordHash, isAnonymous = false) {
    const text = `
      INSERT INTO app_user (email, display_name, password_hash, is_anonymous, created_at, last_active_at)
      VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id, email, display_name, is_anonymous, email_verified, created_at
    `;
    const values = [email, displayName, passwordHash, isAnonymous];
    const result = await query(text, values);
    return result.rows[0];
  },

  // Find user by email
  async findByEmail(email) {
    const text = `
      SELECT id, email, display_name, password_hash, is_anonymous, email_verified, 
             auth_token, auth_token_expires, created_at, last_active_at
      FROM app_user 
      WHERE email = $1 AND is_anonymous = false
    `;
    const result = await query(text, [email]);
    return result.rows[0];
  },

  // Find user by ID
  async findById(userId) {
    const text = `
      SELECT id, email, display_name, is_anonymous, email_verified, 
             created_at, last_active_at
      FROM app_user 
      WHERE id = $1
    `;
    const result = await query(text, [userId]);
    return result.rows[0];
  },

  // Update last active timestamp
  async updateLastActive(userId) {
    const text = `
      UPDATE app_user 
      SET last_active_at = CURRENT_TIMESTAMP 
      WHERE id = $1
    `;
    await query(text, [userId]);
  },

  // Set authentication token (for email verification or password reset)
  async setAuthToken(userId, token, expiresAt) {
    const text = `
      UPDATE app_user 
      SET auth_token = $2, auth_token_expires = $3 
      WHERE id = $1
    `;
    await query(text, [userId, token, expiresAt]);
  },

  // Find user by auth token
  async findByAuthToken(token) {
    const text = `
      SELECT id, email, display_name, is_anonymous, email_verified, 
             auth_token_expires, created_at, last_active_at
      FROM app_user 
      WHERE auth_token = $1
    `;
    const result = await query(text, [token]);
    return result.rows[0];
  },

  // Clear auth token
  async clearAuthToken(userId) {
    const text = `
      UPDATE app_user 
      SET auth_token = NULL, auth_token_expires = NULL 
      WHERE id = $1
    `;
    await query(text, [userId]);
  },

  // Mark email as verified
  async markEmailVerified(userId) {
    const text = `
      UPDATE app_user 
      SET email_verified = true, auth_token = NULL, auth_token_expires = NULL 
      WHERE id = $1
    `;
    await query(text, [userId]);
  },

  // Update password and clear token
  async updatePassword(userId, newPasswordHash) {
    const text = `
      UPDATE app_user 
      SET password_hash = $2, auth_token = NULL, auth_token_expires = NULL 
      WHERE id = $1
    `;
    await query(text, [userId, newPasswordHash]);
  },

  // Update display name
  async updateDisplayName(userId, displayName) {
    const text = `
      UPDATE app_user 
      SET display_name = $2 
      WHERE id = $1
    `;
    await query(text, [userId, displayName]);
  },

  // Create anonymous user
  async createAnonymousUser(displayName) {
    const text = `
      INSERT INTO app_user (display_name, is_anonymous, created_at, last_active_at)
      VALUES ($1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id, display_name, is_anonymous, created_at
    `;
    const result = await query(text, [displayName]);
    return result.rows[0];
  },

  // Clean up expired tokens
  async cleanupExpiredTokens() {
    const text = `
      UPDATE app_user 
      SET auth_token = NULL, auth_token_expires = NULL 
      WHERE auth_token_expires < CURRENT_TIMESTAMP
    `;
    const result = await query(text);
    return result.rowCount;
  },

  // Delete inactive anonymous users (older than 30 days)
  async cleanupInactiveAnonymousUsers() {
    const text = `
      DELETE FROM app_user 
      WHERE is_anonymous = true 
      AND last_active_at < CURRENT_TIMESTAMP - INTERVAL '30 days'
    `;
    const result = await query(text);
    return result.rowCount;
  }
};

module.exports = {
  query,
  userAuth,
  pool
};
