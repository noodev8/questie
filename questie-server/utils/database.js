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

// Quest management functions
const questManager = {
  // Get all active quests
  async getAllActiveQuests() {
    const text = `
      SELECT q.id, q.category_id, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM quest q
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE q.is_active = true AND qc.is_active = true
      ORDER BY q.difficulty_level, q.title
    `;
    const result = await query(text);
    return result.rows;
  },

  // Get random quest by difficulty
  async getRandomQuestByDifficulty(difficulty, excludeQuestIds = []) {
    let excludeClause = '';
    let params = [difficulty];

    if (excludeQuestIds.length > 0) {
      excludeClause = `AND q.id NOT IN (${excludeQuestIds.map((_, i) => `$${i + 2}`).join(',')})`;
      params = params.concat(excludeQuestIds);
    }

    const text = `
      SELECT q.id, q.category_id, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM quest q
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE q.is_active = true AND qc.is_active = true
      AND q.difficulty_level = $1 ${excludeClause}
      ORDER BY RANDOM()
      LIMIT 1
    `;
    const result = await query(text, params);
    return result.rows[0];
  },

  // Get random quest by difficulty for specific user (ensures different users get different quests)
  async getRandomQuestByDifficultyForUser(userId, difficulty, excludeQuestIds = []) {
    let excludeClause = '';
    let params = [difficulty, userId];

    if (excludeQuestIds.length > 0) {
      excludeClause = `AND q.id NOT IN (${excludeQuestIds.map((_, i) => `$${i + 3}`).join(',')})`;
      params = params.concat(excludeQuestIds);
    }

    // Use user ID as seed for consistent randomization per user per day
    const text = `
      SELECT q.id, q.category_id, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM quest q
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE q.is_active = true AND qc.is_active = true
      AND q.difficulty_level = $1 ${excludeClause}
      ORDER BY (q.id * $2 * EXTRACT(DOY FROM CURRENT_DATE)) % 1000
      LIMIT 1
    `;
    const result = await query(text, params);
    return result.rows[0];
  },

  // Get quest by ID
  async getQuestById(questId) {
    const text = `
      SELECT q.id, q.category_id, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM quest q
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE q.id = $1 AND q.is_active = true AND qc.is_active = true
    `;
    const result = await query(text, [questId]);
    return result.rows[0];
  },

  // Get user's current daily quest
  async getUserDailyQuest(userId, date = new Date()) {
    const dateStr = date.toISOString().split('T')[0]; // YYYY-MM-DD format

    const text = `
      SELECT uqa.id as assignment_id, uqa.quest_id, uqa.assigned_date, uqa.is_completed,
             uqa.completed_at, uqa.expires_at, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM user_quest_assignment uqa
      JOIN quest q ON uqa.quest_id = q.id
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE uqa.user_id = $1
      AND uqa.assignment_type = 'daily'
      AND uqa.assigned_date = $2
      ORDER BY uqa.created_at DESC
      LIMIT 1
    `;
    const result = await query(text, [userId, dateStr]);
    return result.rows[0];
  },

  // Get user's current weekly quests
  async getUserWeeklyQuests(userId, weekStart = null) {
    if (!weekStart) {
      // Calculate Monday of current week
      const now = new Date();
      const dayOfWeek = now.getDay();
      const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Sunday = 0, Monday = 1
      weekStart = new Date(now);
      weekStart.setDate(now.getDate() - daysToMonday);
    }
    const weekStartStr = weekStart.toISOString().split('T')[0];

    const text = `
      SELECT uqa.id as assignment_id, uqa.quest_id, uqa.assigned_date, uqa.is_completed,
             uqa.completed_at, uqa.expires_at, q.title, q.description, q.difficulty_level,
             q.points, q.estimated_duration_minutes, qc.name as category_name
      FROM user_quest_assignment uqa
      JOIN quest q ON uqa.quest_id = q.id
      JOIN quest_category qc ON q.category_id = qc.id
      WHERE uqa.user_id = $1
      AND uqa.assignment_type = 'weekly'
      AND uqa.assigned_date = $2
      ORDER BY uqa.created_at DESC, q.difficulty_level, q.title
      LIMIT 5
    `;
    const result = await query(text, [userId, weekStartStr]);
    return result.rows;
  },

  // Assign daily quest to user
  async assignDailyQuest(userId, questId, date = new Date()) {
    const dateStr = date.toISOString().split('T')[0];
    const expiresAt = new Date(date);
    expiresAt.setDate(expiresAt.getDate() + 1); // Expires at end of day
    expiresAt.setHours(23, 59, 59, 999);

    const text = `
      INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date, expires_at)
      VALUES ($1, $2, 'daily', $3, $4)
      RETURNING id, quest_id, assignment_type, assigned_date, expires_at, is_completed
    `;
    const result = await query(text, [userId, questId, dateStr, expiresAt]);
    return result.rows[0];
  },

  // Assign weekly quests to user
  async assignWeeklyQuests(userId, questIds, weekStart = null) {
    if (!weekStart) {
      // Calculate Monday of current week
      const now = new Date();
      const dayOfWeek = now.getDay();
      const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
      weekStart = new Date(now);
      weekStart.setDate(now.getDate() - daysToMonday);
    }
    const weekStartStr = weekStart.toISOString().split('T')[0];
    const expiresAt = new Date(weekStart);
    expiresAt.setDate(expiresAt.getDate() + 7); // Expires at end of week
    expiresAt.setHours(23, 59, 59, 999);

    const assignments = [];
    for (const questId of questIds) {
      const text = `
        INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date, expires_at)
        VALUES ($1, $2, 'weekly', $3, $4)
        RETURNING id, quest_id, assignment_type, assigned_date, expires_at, is_completed
      `;
      const result = await query(text, [userId, questId, weekStartStr, expiresAt]);
      assignments.push(result.rows[0]);
    }
    return assignments;
  },

  // Check if user has rerolled quest today/this week
  async hasUserRerolledToday(userId, assignmentType, date = new Date()) {
    const dateStr = date.toISOString().split('T')[0];

    // Check reroll log table for this user, assignment type, and date
    const text = `
      SELECT COUNT(*) as reroll_count
      FROM user_reroll_log
      WHERE user_id = $1
      AND assignment_type = $2
      AND reroll_date = $3
    `;

    try {
      const result = await query(text, [userId, assignmentType, dateStr]);
      return parseInt(result.rows[0].reroll_count) > 0;
    } catch (error) {
      // If table doesn't exist, create it and return false
      if (error.code === '42P01') { // Table doesn't exist
        await this.createRerollLogTable();
        return false;
      }
      throw error;
    }
  },

  // Create reroll log table if it doesn't exist
  async createRerollLogTable() {
    const text = `
      CREATE TABLE IF NOT EXISTS user_reroll_log (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        assignment_type VARCHAR(10) NOT NULL CHECK (assignment_type IN ('daily', 'weekly')),
        reroll_date DATE NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, assignment_type, reroll_date)
      )
    `;
    await query(text);
  },

  // Log a reroll
  async logReroll(userId, assignmentType, date = new Date()) {
    const dateStr = date.toISOString().split('T')[0];

    const text = `
      INSERT INTO user_reroll_log (user_id, assignment_type, reroll_date)
      VALUES ($1, $2, $3)
      ON CONFLICT (user_id, assignment_type, reroll_date) DO NOTHING
    `;
    await query(text, [userId, assignmentType, dateStr]);
  },

  // Delete weekly quest assignments for a specific week
  async deleteWeeklyQuests(userId, weekStart) {
    const weekStartStr = weekStart.toISOString().split('T')[0];

    const text = `
      DELETE FROM user_quest_assignment
      WHERE user_id = $1
      AND assignment_type = 'weekly'
      AND assigned_date = $2
    `;
    const result = await query(text, [userId, weekStartStr]);
    return result.rowCount;
  },

  // Complete a quest
  async completeQuest(userId, assignmentId, completionNotes = null) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Mark assignment as completed
      const updateText = `
        UPDATE user_quest_assignment
        SET is_completed = true, completed_at = CURRENT_TIMESTAMP
        WHERE id = $1 AND user_id = $2
        RETURNING quest_id, assignment_type, assigned_date
      `;
      const updateResult = await client.query(updateText, [assignmentId, userId]);

      if (updateResult.rows.length === 0) {
        throw new Error('Quest assignment not found');
      }

      const assignment = updateResult.rows[0];

      // Get quest details for points
      const questText = `
        SELECT points FROM quest WHERE id = $1
      `;
      const questResult = await client.query(questText, [assignment.quest_id]);
      const points = questResult.rows[0]?.points || 0;

      // Record completion
      const completionText = `
        INSERT INTO user_quest_completion (user_id, quest_id, assignment_id, completion_notes, points_earned)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, points_earned, completed_at
      `;
      const completionResult = await client.query(completionText, [
        userId, assignment.quest_id, assignmentId, completionNotes, points
      ]);

      await client.query('COMMIT');
      return {
        assignment,
        completion: completionResult.rows[0],
        points_earned: points
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
};

module.exports = {
  query,
  userAuth,
  questManager,
  pool
};
