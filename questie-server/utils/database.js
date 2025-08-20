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
      INSERT INTO app_user (email, display_name, password_hash, is_anonymous, profile_icon, created_at, last_active_at)
      VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id, email, display_name, is_anonymous, email_verified, profile_icon, created_at
    `;
    const values = [email, displayName, passwordHash, isAnonymous, 'assets/icons/questie-pic1.png'];
    const result = await query(text, values);
    return result.rows[0];
  },

  // Find user by email
  async findByEmail(email) {
    const text = `
      SELECT id, email, display_name, password_hash, is_anonymous, email_verified,
             profile_icon, auth_token, auth_token_expires, created_at, last_active_at
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
             profile_icon, created_at, last_active_at
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
             profile_icon, auth_token_expires, created_at, last_active_at
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

  // Update profile icon
  async updateProfileIcon(userId, profileIcon) {
    const text = `
      UPDATE app_user
      SET profile_icon = $2
      WHERE id = $1
    `;
    await query(text, [userId, profileIcon]);
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

  // Get or create user stats
  async getUserStats(userId) {
    // First try to get existing stats
    let text = `
      SELECT * FROM user_stats WHERE user_id = $1
    `;
    let result = await query(text, [userId]);

    if (result.rows.length === 0) {
      // Create initial stats record
      text = `
        INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days)
        VALUES ($1, 0, 0, 0, 0)
        RETURNING *
      `;
      result = await query(text, [userId]);
    }

    return result.rows[0];
  },

  // Update user stats after quest completion
  async updateUserStats(userId, pointsEarned) {
    console.log(`📊 Starting updateUserStats for user ${userId}, points: ${pointsEarned}`);
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Get current stats
      const statsText = `
        SELECT * FROM user_stats WHERE user_id = $1
      `;
      let statsResult = await client.query(statsText, [userId]);

      if (statsResult.rows.length === 0) {
        // Create initial stats if they don't exist
        const createText = `
          INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days)
          VALUES ($1, 0, 0, 0, 0)
          RETURNING *
        `;
        statsResult = await client.query(createText, [userId]);
      }

      const currentStats = statsResult.rows[0];
      const today = new Date().toISOString().split('T')[0];
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      // Calculate new streak
      let newCurrentStreak = currentStats.current_streak_days;
      let newLongestStreak = currentStats.longest_streak_days;

      // Check if user completed a quest yesterday or today
      const lastCompletedStr = currentStats.last_quest_completed_at
        ? currentStats.last_quest_completed_at.toISOString().split('T')[0]
        : null;

      if (lastCompletedStr === yesterdayStr) {
        // Continuing streak
        newCurrentStreak += 1;
      } else if (lastCompletedStr !== today) {
        // Starting new streak
        newCurrentStreak = 1;
      }
      // If lastCompletedStr === today, streak stays the same (already completed today)

      // Update longest streak if current is higher
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }

      // Update stats
      const updateText = `
        UPDATE user_stats
        SET total_quests_completed = total_quests_completed + 1,
            total_points = total_points + $2,
            current_streak_days = $3,
            longest_streak_days = $4,
            last_quest_completed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $1
        RETURNING *
      `;
      const updateResult = await client.query(updateText, [userId, pointsEarned, newCurrentStreak, newLongestStreak]);

      await client.query('COMMIT');
      return updateResult.rows[0];
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  },

  // Complete a quest
  async completeQuest(userId, assignmentId, completionNotes = null) {
    const startTime = Date.now();
    console.log(`🚀 Starting quest completion for user ${userId}, assignment ${assignmentId}`);

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

      // Update user stats within the same transaction for better performance
      console.log(`🎯 Updating user stats for user ${userId} with ${points} points`);

      // Get current stats
      const statsText = `
        SELECT * FROM user_stats WHERE user_id = $1
      `;
      let statsResult = await client.query(statsText, [userId]);

      if (statsResult.rows.length === 0) {
        // Create initial stats if they don't exist
        const createText = `
          INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days)
          VALUES ($1, 0, 0, 0, 0)
          RETURNING *
        `;
        statsResult = await client.query(createText, [userId]);
      }

      const currentStats = statsResult.rows[0];
      const today = new Date().toISOString().split('T')[0];
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      // Calculate new streak
      let newCurrentStreak = currentStats.current_streak_days;
      let newLongestStreak = currentStats.longest_streak_days;

      // Check if user completed a quest yesterday or today
      const lastCompletedStr = currentStats.last_quest_completed_at
        ? currentStats.last_quest_completed_at.toISOString().split('T')[0]
        : null;

      if (lastCompletedStr === yesterdayStr) {
        // Continuing streak
        newCurrentStreak += 1;
      } else if (lastCompletedStr !== today) {
        // Starting new streak
        newCurrentStreak = 1;
      }
      // If lastCompletedStr === today, streak stays the same (already completed today)

      // Update longest streak if current is higher
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }

      // Update stats within the same transaction
      const updateStatsText = `
        UPDATE user_stats
        SET total_quests_completed = total_quests_completed + 1,
            total_points = total_points + $2,
            current_streak_days = $3,
            longest_streak_days = $4,
            last_quest_completed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $1
        RETURNING *
      `;
      await client.query(updateStatsText, [userId, points, newCurrentStreak, newLongestStreak]);

      console.log(`✅ User stats updated successfully`);

      await client.query('COMMIT');
      const dbTime = Date.now() - startTime;
      console.log(`⚡ Database operations completed in ${dbTime}ms`);

      // Check and award badges after successful quest completion
      let newlyEarnedBadges = [];
      try {
        const badgeStartTime = Date.now();
        console.log(`🏆 Checking badges for user ${userId}`);
        newlyEarnedBadges = await badgeManager.checkAndAwardBadges(userId);
        const badgeTime = Date.now() - badgeStartTime;
        if (newlyEarnedBadges.length > 0) {
          console.log(`🎉 User ${userId} earned ${newlyEarnedBadges.length} new badges in ${badgeTime}ms:`, newlyEarnedBadges.map(b => b.name));
        } else {
          console.log(`🏆 Badge check completed in ${badgeTime}ms - no new badges`);
        }
      } catch (badgeError) {
        console.error('Error checking badges after quest completion:', badgeError);
        // Don't fail the quest completion if badge checking fails
      }

      const totalTime = Date.now() - startTime;
      console.log(`✅ Quest completion finished in ${totalTime}ms total`);

      return {
        assignment,
        completion: completionResult.rows[0],
        points_earned: points,
        newly_earned_badges: newlyEarnedBadges
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
};

// Badge management functions
const badgeManager = {
  // Get all badges with user's progress
  async getAllBadgesForUser(userId) {
    const text = `
      SELECT b.id, b.name, b.description, b.icon, b.requirement_type, b.requirement_value,
             ub.id as user_badge_id, ub.progress_value, ub.is_completed, ub.earned_at,
             qc.name as category_name
      FROM badge b
      LEFT JOIN quest_category qc ON b.category_id = qc.id
      LEFT JOIN user_badge ub ON b.id = ub.badge_id AND ub.user_id = $1
      ORDER BY b.requirement_type, b.requirement_value, b.name
    `;
    const result = await query(text, [userId]);
    return result.rows;
  },

  // Get user's earned badges
  async getUserEarnedBadges(userId) {
    const text = `
      SELECT b.id, b.name, b.description, b.icon, b.requirement_type, b.requirement_value,
             ub.progress_value, ub.earned_at, qc.name as category_name
      FROM badge b
      JOIN user_badge ub ON b.id = ub.badge_id
      LEFT JOIN quest_category qc ON b.category_id = qc.id
      WHERE ub.user_id = $1 AND ub.is_completed = true
      ORDER BY ub.earned_at DESC
    `;
    const result = await query(text, [userId]);
    return result.rows;
  },

  // Get badge count for user
  async getUserBadgeCount(userId) {
    const text = `
      SELECT COUNT(*) as badge_count
      FROM user_badge
      WHERE user_id = $1 AND is_completed = true
    `;
    const result = await query(text, [userId]);
    return parseInt(result.rows[0].badge_count) || 0;
  },

  // Check and award badges for a user
  async checkAndAwardBadges(userId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Get user's current stats
      const statsText = `
        SELECT total_quests_completed, total_points, current_streak_days, longest_streak_days
        FROM user_stats
        WHERE user_id = $1
      `;
      const statsResult = await client.query(statsText, [userId]);

      if (statsResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return [];
      }

      const userStats = statsResult.rows[0];
      const newlyEarnedBadges = [];

      // Get only badges that the user can potentially earn based on current stats
      // This is much more efficient than checking all badges
      const badgesText = `
        SELECT b.id, b.name, b.requirement_type, b.requirement_value
        FROM badge b
        LEFT JOIN user_badge ub ON b.id = ub.badge_id AND ub.user_id = $1
        WHERE (ub.id IS NULL OR ub.is_completed = false)
        AND (
          (b.requirement_type = 'quests_completed' AND b.requirement_value <= $2) OR
          (b.requirement_type = 'total_points' AND b.requirement_value <= $3) OR
          (b.requirement_type = 'current_streak' AND b.requirement_value <= $4) OR
          (b.requirement_type = 'streak_days' AND b.requirement_value <= $5)
        )
        ORDER BY b.requirement_value
      `;
      const badgesResult = await client.query(badgesText, [
        userId,
        userStats.total_quests_completed,
        userStats.total_points,
        userStats.current_streak_days,
        userStats.longest_streak_days
      ]);

      // Check each badge requirement
      for (const badge of badgesResult.rows) {
        let shouldAward = false;
        let progressValue = 0;

        switch (badge.requirement_type) {
          case 'quests_completed':
            progressValue = userStats.total_quests_completed;
            shouldAward = progressValue >= badge.requirement_value;
            break;
          case 'total_points':
            progressValue = userStats.total_points;
            shouldAward = progressValue >= badge.requirement_value;
            break;
          case 'current_streak':
            progressValue = userStats.current_streak_days;
            shouldAward = progressValue >= badge.requirement_value;
            break;
          case 'streak_days':
            progressValue = userStats.longest_streak_days;
            shouldAward = progressValue >= badge.requirement_value;
            break;
        }

        // Update or create user_badge record
        if (shouldAward) {
          // Check if badge already exists for this user
          const existingBadgeText = `
            SELECT id, is_completed FROM user_badge
            WHERE user_id = $1 AND badge_id = $2
          `;
          const existingResult = await client.query(existingBadgeText, [userId, badge.id]);

          if (existingResult.rows.length > 0) {
            // Update existing record
            const existingBadge = existingResult.rows[0];
            if (!existingBadge.is_completed) {
              const updateText = `
                UPDATE user_badge
                SET progress_value = $3, is_completed = true, earned_at = CURRENT_TIMESTAMP
                WHERE user_id = $1 AND badge_id = $2
                RETURNING id, badge_id
              `;
              const updateResult = await client.query(updateText, [userId, badge.id, progressValue]);

              if (updateResult.rows.length > 0) {
                newlyEarnedBadges.push({
                  id: badge.id,
                  name: badge.name,
                  requirement_type: badge.requirement_type,
                  requirement_value: badge.requirement_value,
                  progress_value: progressValue
                });
              }
            }
          } else {
            // Insert new record
            const insertText = `
              INSERT INTO user_badge (user_id, badge_id, progress_value, is_completed, earned_at)
              VALUES ($1, $2, $3, true, CURRENT_TIMESTAMP)
              RETURNING id, badge_id
            `;
            const insertResult = await client.query(insertText, [userId, badge.id, progressValue]);

            if (insertResult.rows.length > 0) {
              newlyEarnedBadges.push({
                id: badge.id,
                name: badge.name,
                requirement_type: badge.requirement_type,
                requirement_value: badge.requirement_value,
                progress_value: progressValue
              });
            }
          }
        } else {
          // Update progress without awarding
          const existingBadgeText = `
            SELECT id, is_completed FROM user_badge
            WHERE user_id = $1 AND badge_id = $2
          `;
          const existingResult = await client.query(existingBadgeText, [userId, badge.id]);

          if (existingResult.rows.length > 0) {
            // Update existing record if not completed
            const existingBadge = existingResult.rows[0];
            if (!existingBadge.is_completed) {
              const updateText = `
                UPDATE user_badge
                SET progress_value = $3
                WHERE user_id = $1 AND badge_id = $2
              `;
              await client.query(updateText, [userId, badge.id, progressValue]);
            }
          } else {
            // Insert new progress record
            const insertText = `
              INSERT INTO user_badge (user_id, badge_id, progress_value, is_completed)
              VALUES ($1, $2, $3, false)
            `;
            await client.query(insertText, [userId, badge.id, progressValue]);
          }
        }
      }

      await client.query('COMMIT');
      return newlyEarnedBadges;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  },

  // Award a specific badge to a user
  async awardBadge(userId, badgeId) {
    // Check if badge already exists for this user
    const existingText = `
      SELECT id, is_completed FROM user_badge
      WHERE user_id = $1 AND badge_id = $2
    `;
    const existingResult = await query(existingText, [userId, badgeId]);

    if (existingResult.rows.length > 0) {
      // Update existing record if not completed
      const existingBadge = existingResult.rows[0];
      if (!existingBadge.is_completed) {
        const updateText = `
          UPDATE user_badge
          SET is_completed = true, earned_at = CURRENT_TIMESTAMP
          WHERE user_id = $1 AND badge_id = $2
          RETURNING id
        `;
        const result = await query(updateText, [userId, badgeId]);
        return result.rows.length > 0;
      }
      return false; // Already completed
    } else {
      // Insert new record
      const insertText = `
        INSERT INTO user_badge (user_id, badge_id, is_completed, earned_at)
        VALUES ($1, $2, true, CURRENT_TIMESTAMP)
        RETURNING id
      `;
      const result = await query(insertText, [userId, badgeId]);
      return result.rows.length > 0;
    }
  }
};

// Add uncompleteQuest to questManager
questManager.uncompleteQuest = async function(userId, assignmentId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Check if assignment exists and is completed
      const checkText = `
        SELECT quest_id, assignment_type, is_completed
        FROM user_quest_assignment
        WHERE id = $1 AND user_id = $2
      `;
      const checkResult = await client.query(checkText, [assignmentId, userId]);

      if (checkResult.rows.length === 0) {
        throw new Error('Quest assignment not found');
      }

      const assignment = checkResult.rows[0];
      if (!assignment.is_completed) {
        throw new Error('Quest is not completed');
      }

      // Get quest details for points
      const questText = `
        SELECT points FROM quest WHERE id = $1
      `;
      const questResult = await client.query(questText, [assignment.quest_id]);
      const points = questResult.rows[0]?.points || 0;

      // Mark assignment as not completed
      const updateText = `
        UPDATE user_quest_assignment
        SET is_completed = false, completed_at = NULL
        WHERE id = $1 AND user_id = $2
        RETURNING quest_id, assignment_type
      `;
      const updateResult = await client.query(updateText, [assignmentId, userId]);

      // Remove completion record
      const deleteCompletionText = `
        DELETE FROM user_quest_completion
        WHERE assignment_id = $1 AND user_id = $2
        RETURNING points_earned
      `;
      const deleteResult = await client.query(deleteCompletionText, [assignmentId, userId]);
      const pointsToDeduct = deleteResult.rows[0]?.points_earned || points;

      // Update user stats (subtract points and quest count)
      console.log(`🎯 Updating user stats for user ${userId} - deducting ${pointsToDeduct} points`);
      await questManager.updateUserStats(userId, -pointsToDeduct);
      console.log(`✅ User stats updated successfully`);

      await client.query('COMMIT');

      return {
        assignment: updateResult.rows[0],
        points_deducted: pointsToDeduct
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  };

// Add quest history methods to questManager
questManager.getUserQuestHistory = async function(userId, limit = 50) {
  const text = `
    SELECT
      uqa.id as assignment_id,
      uqa.quest_id,
      uqa.assignment_type,
      uqa.assigned_date,
      uqa.is_completed,
      uqa.completed_at,
      q.title,
      q.description,
      q.points,
      q.difficulty_level,
      qc.name as category_name,
      uqc.completion_notes,
      uqc.points_earned,
      uqc.completed_at as completion_date
    FROM user_quest_assignment uqa
    JOIN quest q ON uqa.quest_id = q.id
    JOIN quest_category qc ON q.category_id = qc.id
    LEFT JOIN user_quest_completion uqc ON uqa.id = uqc.assignment_id
    WHERE uqa.user_id = $1
    ORDER BY
      CASE WHEN uqa.is_completed THEN uqa.completed_at ELSE uqa.assigned_date END DESC
    LIMIT $2
  `;
  const result = await query(text, [userId, limit]);
  return result.rows;
};

questManager.getUserCompletedQuests = async function(userId, limit = 50) {
  const text = `
    SELECT
      uqa.id as assignment_id,
      uqa.quest_id,
      uqa.assignment_type,
      uqa.assigned_date,
      uqa.is_completed,
      uqa.completed_at,
      q.title,
      q.description,
      q.points,
      q.difficulty_level,
      qc.name as category_name,
      uqc.completion_notes,
      uqc.points_earned,
      uqc.completed_at as completion_date
    FROM user_quest_assignment uqa
    JOIN quest q ON uqa.quest_id = q.id
    JOIN quest_category qc ON q.category_id = qc.id
    JOIN user_quest_completion uqc ON uqa.id = uqc.assignment_id
    WHERE uqa.user_id = $1 AND uqa.is_completed = true
    ORDER BY uqa.completed_at DESC
    LIMIT $2
  `;
  const result = await query(text, [userId, limit]);
  return result.rows;
};

module.exports = {
  query,
  userAuth,
  questManager,
  badgeManager,
  pool
};
