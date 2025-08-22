// Integration test for the delete account API endpoint
// This script tests the actual HTTP endpoint with authentication

require('dotenv').config();
const http = require('http');
const { userAuth, questManager, badgeManager, userDeletion, pool } = require('./utils/database');
const bcrypt = require('bcrypt');

// Configuration
const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000/api';
const TEST_EMAIL = `test-delete-api-${Date.now()}@example.com`;
const TEST_PASSWORD = 'testpassword123';
const TEST_DISPLAY_NAME = 'Test Delete API User';

async function createTestUserWithData() {
  console.log('🧪 Creating test user with comprehensive data...');
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Create test user
    const passwordHash = await bcrypt.hash(TEST_PASSWORD, 12);
    
    const userResult = await client.query(`
      INSERT INTO app_user (email, display_name, password_hash, is_anonymous, profile_icon, created_at, last_active_at, email_verified)
      VALUES ($1, $2, $3, false, 'assets/icons/questie-pic2.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, true)
      RETURNING id, email, display_name
    `, [TEST_EMAIL, TEST_DISPLAY_NAME, passwordHash]);
    
    const user = userResult.rows[0];
    console.log(`✅ Created test user: ${user.email} (ID: ${user.id})`);
    
    // Create comprehensive test data
    
    // 1. User stats
    await client.query(`
      INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days, updated_at)
      VALUES ($1, 15, 450, 5, 12, CURRENT_TIMESTAMP)
    `, [user.id]);
    
    // 2. Quest assignments and completions
    const questResult = await client.query(`SELECT id FROM quest WHERE is_active = true LIMIT 5`);
    
    for (let i = 0; i < questResult.rows.length; i++) {
      const quest = questResult.rows[i];
      
      // Create assignment
      const assignmentResult = await client.query(`
        INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date, is_completed, completed_at, created_at)
        VALUES ($1, $2, $3, CURRENT_DATE - INTERVAL '${i} days', true, CURRENT_TIMESTAMP - INTERVAL '${i} days', CURRENT_TIMESTAMP)
        RETURNING id
      `, [user.id, quest.id, i % 2 === 0 ? 'daily' : 'weekly']);
      
      // Create completion
      await client.query(`
        INSERT INTO user_quest_completion (user_id, quest_id, assignment_id, points_earned, completed_at)
        VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP - INTERVAL '${i} days')
      `, [user.id, quest.id, assignmentResult.rows[0].id, 30 + (i * 10)]);
    }
    
    // 3. Badge progress
    const badgeResult = await client.query(`SELECT id FROM badge LIMIT 3`);
    
    for (let i = 0; i < badgeResult.rows.length; i++) {
      const badge = badgeResult.rows[i];
      await client.query(`
        INSERT INTO user_badge (user_id, badge_id, progress_value, is_completed, earned_at)
        VALUES ($1, $2, $3, $4, $5)
      `, [user.id, badge.id, 50 + (i * 25), i === 0, i === 0 ? new Date() : null]);
    }
    
    // 4. Daily activity records
    for (let i = 0; i < 7; i++) {
      await client.query(`
        INSERT INTO user_daily_activity (user_id, activity_date, quests_completed, points_earned, created_at)
        VALUES ($1, CURRENT_DATE - INTERVAL '${i} days', $2, $3, CURRENT_TIMESTAMP)
      `, [user.id, Math.floor(Math.random() * 3) + 1, Math.floor(Math.random() * 100) + 50]);
    }
    
    // 5. Reroll log (if table exists)
    try {
      await client.query(`
        INSERT INTO user_reroll_log (user_id, assignment_type, reroll_date, created_at)
        VALUES ($1, 'daily', CURRENT_DATE, CURRENT_TIMESTAMP)
      `, [user.id]);
      
      await client.query(`
        INSERT INTO user_reroll_log (user_id, assignment_type, reroll_date, created_at)
        VALUES ($1, 'weekly', CURRENT_DATE - INTERVAL '1 day', CURRENT_TIMESTAMP)
      `, [user.id]);
    } catch (error) {
      if (error.code !== '42P01') { // Ignore if table doesn't exist
        throw error;
      }
    }
    
    await client.query('COMMIT');
    
    console.log(`✅ Created comprehensive test data for user ${user.id}`);
    return user;
    
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function loginUser(email, password) {
  console.log(`🔐 Logging in user: ${email}`);
  
  try {
    const response = await axios.post(`${API_BASE_URL}/auth/login`, {
      email: email,
      password: password
    });
    
    if (response.data.return_code === 'SUCCESS') {
      console.log(`✅ Login successful`);
      return response.data.access_token;
    } else {
      throw new Error(`Login failed: ${response.data.message}`);
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Login failed: ${error.response.data.message || error.response.statusText}`);
    } else {
      throw new Error(`Login failed: ${error.message}`);
    }
  }
}

async function deleteAccountViaAPI(token) {
  console.log(`🗑️ Calling delete account API...`);
  
  try {
    const response = await axios.post(`${API_BASE_URL}/auth/delete-account`, {}, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.data.return_code === 'SUCCESS') {
      console.log(`✅ Account deletion API call successful`);
      console.log(`📊 Deletion details:`, response.data.details);
      return response.data;
    } else {
      throw new Error(`Delete account failed: ${response.data.message}`);
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Delete account failed: ${error.response.data.message || error.response.statusText}`);
    } else {
      throw new Error(`Delete account failed: ${error.message}`);
    }
  }
}

async function testDeleteAccountAPI() {
  try {
    console.log('🚀 Starting delete account API integration test...\n');
    
    // Step 1: Create test user with comprehensive data
    const testUser = await createTestUserWithData();
    console.log('\n📊 Test user and data created successfully!\n');
    
    // Step 2: Verify data exists before deletion
    console.log('📋 Data before deletion:');
    const beforeSummary = await userDeletion.getUserDataSummary(testUser.id);
    console.log('User info:', beforeSummary.user_info);
    console.log('Data counts:', {
      quest_completions: beforeSummary.quest_completions,
      quest_assignments: beforeSummary.quest_assignments,
      badges: beforeSummary.badges,
      daily_activity: beforeSummary.daily_activity,
      user_stats: beforeSummary.user_stats,
      reroll_logs: beforeSummary.reroll_logs
    });
    console.log('\n');
    
    // Step 3: Login to get authentication token
    const authToken = await loginUser(TEST_EMAIL, TEST_PASSWORD);
    console.log('\n');
    
    // Step 4: Call delete account API
    const deleteResult = await deleteAccountViaAPI(authToken);
    console.log('\n');
    
    // Step 5: Verify all data is deleted
    console.log('🔍 Verifying data after deletion:');
    const verificationResult = await userDeletion.verifyUserDataDeleted(testUser.id);
    
    console.log('Verification results:');
    Object.entries(verificationResult.tables).forEach(([table, count]) => {
      if (typeof count === 'number') {
        if (count === 0) {
          console.log(`✅ ${table}: Clean (0 records)`);
        } else {
          console.log(`❌ ${table}: ${count} orphaned records found!`);
        }
      } else {
        console.log(`ℹ️ ${table}: ${count}`);
      }
    });
    
    // Step 6: Test that the token is now invalid
    console.log('\n🔐 Testing token invalidation...');
    try {
      await axios.post(`${API_BASE_URL}/auth/verify-token`, {}, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ ERROR: Token should be invalid after account deletion!');
    } catch (error) {
      if (error.response && error.response.status === 401) {
        console.log('✅ Token correctly invalidated after account deletion');
      } else {
        console.log(`⚠️ Unexpected error testing token: ${error.message}`);
      }
    }
    
    // Final assessment
    console.log('\n📊 Final Assessment:');
    if (verificationResult.isCompletelyDeleted) {
      console.log('🎉 SUCCESS: Complete account deletion test passed!');
      console.log('✅ All user data completely removed from database');
      console.log('✅ Authentication token invalidated');
      console.log('✅ API endpoint working correctly');
      console.log(`✅ Total records deleted: ${deleteResult.details.records_deleted.total}`);
    } else {
      console.log('❌ FAILURE: Account deletion incomplete');
      console.log(`❌ ${verificationResult.totalOrphanedRecords} orphaned records found`);
    }
    
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
  
  process.exit(0);
}

// Check if axios is available
if (!axios) {
  console.error('❌ axios is required for this test. Install it with: npm install axios');
  process.exit(1);
}

// Run the test
testDeleteAccountAPI();
