// Test script for account deletion functionality
// This script creates a test user with sample data and then tests the deletion process

require('dotenv').config();
const { userAuth, questManager, badgeManager, pool } = require('./utils/database');
const bcrypt = require('bcrypt');

async function createTestUser() {
  console.log('🧪 Creating test user with sample data...');
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Create test user
    const email = `test-delete-${Date.now()}@example.com`;
    const displayName = 'Test Delete User';
    const passwordHash = await bcrypt.hash('testpassword123', 12);
    
    const userResult = await client.query(`
      INSERT INTO app_user (email, display_name, password_hash, is_anonymous, profile_icon, created_at, last_active_at, email_verified)
      VALUES ($1, $2, $3, false, 'assets/icons/questie-pic1.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, true)
      RETURNING id, email, display_name
    `, [email, displayName, passwordHash]);
    
    const user = userResult.rows[0];
    console.log(`✅ Created test user: ${user.email} (ID: ${user.id})`);
    
    // Create user stats
    await client.query(`
      INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days, updated_at)
      VALUES ($1, 5, 150, 3, 7, CURRENT_TIMESTAMP)
    `, [user.id]);
    console.log(`✅ Created user stats`);
    
    // Create some quest assignments
    const questResult = await client.query(`
      SELECT id FROM quest WHERE is_active = true LIMIT 3
    `);
    
    if (questResult.rows.length > 0) {
      for (const quest of questResult.rows) {
        await client.query(`
          INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date, is_completed, created_at)
          VALUES ($1, $2, 'daily', CURRENT_DATE, true, CURRENT_TIMESTAMP)
        `, [user.id, quest.id]);
        
        // Create completion record
        await client.query(`
          INSERT INTO user_quest_completion (user_id, quest_id, assignment_id, points_earned, completed_at)
          VALUES ($1, $2, (SELECT id FROM user_quest_assignment WHERE user_id = $1 AND quest_id = $2 ORDER BY id DESC LIMIT 1), 50, CURRENT_TIMESTAMP)
        `, [user.id, quest.id]);
      }
      console.log(`✅ Created ${questResult.rows.length} quest assignments and completions`);
    }
    
    // Create some badge progress
    const badgeResult = await client.query(`
      SELECT id FROM badge LIMIT 2
    `);
    
    if (badgeResult.rows.length > 0) {
      for (const badge of badgeResult.rows) {
        await client.query(`
          INSERT INTO user_badge (user_id, badge_id, progress_value, is_completed, earned_at)
          VALUES ($1, $2, 75, false, CURRENT_TIMESTAMP)
        `, [user.id, badge.id]);
      }
      console.log(`✅ Created ${badgeResult.rows.length} badge progress records`);
    }
    
    // Create daily activity
    await client.query(`
      INSERT INTO user_daily_activity (user_id, activity_date, quests_completed, points_earned, created_at)
      VALUES ($1, CURRENT_DATE, 3, 150, CURRENT_TIMESTAMP)
    `, [user.id]);
    console.log(`✅ Created daily activity record`);
    
    // Create reroll log (if table exists)
    try {
      await client.query(`
        INSERT INTO user_reroll_log (user_id, assignment_type, reroll_date, created_at)
        VALUES ($1, 'daily', CURRENT_DATE, CURRENT_TIMESTAMP)
      `, [user.id]);
      console.log(`✅ Created reroll log record`);
    } catch (error) {
      if (error.code === '42P01') {
        console.log(`ℹ️ user_reroll_log table doesn't exist, skipping...`);
      } else {
        throw error;
      }
    }
    
    await client.query('COMMIT');
    
    return user;
    
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function verifyUserDataExists(userId) {
  console.log(`🔍 Verifying user data exists for user ${userId}...`);
  
  const checks = [
    { table: 'app_user', query: 'SELECT COUNT(*) as count FROM app_user WHERE id = $1' },
    { table: 'user_stats', query: 'SELECT COUNT(*) as count FROM user_stats WHERE user_id = $1' },
    { table: 'user_quest_assignment', query: 'SELECT COUNT(*) as count FROM user_quest_assignment WHERE user_id = $1' },
    { table: 'user_quest_completion', query: 'SELECT COUNT(*) as count FROM user_quest_completion WHERE user_id = $1' },
    { table: 'user_badge', query: 'SELECT COUNT(*) as count FROM user_badge WHERE user_id = $1' },
    { table: 'user_daily_activity', query: 'SELECT COUNT(*) as count FROM user_daily_activity WHERE user_id = $1' }
  ];
  
  const results = {};
  
  for (const check of checks) {
    try {
      const result = await pool.query(check.query, [userId]);
      const count = parseInt(result.rows[0].count);
      results[check.table] = count;
      console.log(`  ${check.table}: ${count} records`);
    } catch (error) {
      console.log(`  ${check.table}: Error - ${error.message}`);
      results[check.table] = 'ERROR';
    }
  }
  
  // Check reroll log separately
  try {
    const rerollResult = await pool.query('SELECT COUNT(*) as count FROM user_reroll_log WHERE user_id = $1', [userId]);
    const count = parseInt(rerollResult.rows[0].count);
    results['user_reroll_log'] = count;
    console.log(`  user_reroll_log: ${count} records`);
  } catch (error) {
    if (error.code === '42P01') {
      console.log(`  user_reroll_log: Table doesn't exist`);
      results['user_reroll_log'] = 'N/A';
    } else {
      console.log(`  user_reroll_log: Error - ${error.message}`);
      results['user_reroll_log'] = 'ERROR';
    }
  }
  
  return results;
}

async function testAccountDeletion() {
  try {
    console.log('🚀 Starting account deletion test...\n');
    
    // Step 1: Create test user with data
    const testUser = await createTestUser();
    console.log('\n📊 Test user created successfully!\n');
    
    // Step 2: Verify data exists before deletion
    console.log('📋 Data before deletion:');
    const beforeData = await verifyUserDataExists(testUser.id);
    console.log('\n');
    
    // Step 3: Simulate the deletion process (same logic as in auth.js)
    console.log('🗑️ Starting deletion process...');
    
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      // Delete in the same order as the auth route
      const deletionResults = {};
      
      // 1. Delete user reroll log
      try {
        const rerollResult = await client.query('DELETE FROM user_reroll_log WHERE user_id = $1', [testUser.id]);
        deletionResults.user_reroll_log = rerollResult.rowCount;
        console.log(`✅ Deleted ${rerollResult.rowCount} reroll log entries`);
      } catch (error) {
        if (error.code === '42P01') {
          console.log(`ℹ️ user_reroll_log table doesn't exist, skipping...`);
          deletionResults.user_reroll_log = 'N/A';
        } else {
          throw error;
        }
      }
      
      // 2. Delete user quest completions
      const completionsResult = await client.query('DELETE FROM user_quest_completion WHERE user_id = $1', [testUser.id]);
      deletionResults.user_quest_completion = completionsResult.rowCount;
      console.log(`✅ Deleted ${completionsResult.rowCount} quest completion records`);
      
      // 3. Delete user quest assignments
      const assignmentsResult = await client.query('DELETE FROM user_quest_assignment WHERE user_id = $1', [testUser.id]);
      deletionResults.user_quest_assignment = assignmentsResult.rowCount;
      console.log(`✅ Deleted ${assignmentsResult.rowCount} quest assignment records`);
      
      // 4. Delete user badges
      const badgesResult = await client.query('DELETE FROM user_badge WHERE user_id = $1', [testUser.id]);
      deletionResults.user_badge = badgesResult.rowCount;
      console.log(`✅ Deleted ${badgesResult.rowCount} badge records`);
      
      // 5. Delete user daily activity
      const dailyActivityResult = await client.query('DELETE FROM user_daily_activity WHERE user_id = $1', [testUser.id]);
      deletionResults.user_daily_activity = dailyActivityResult.rowCount;
      console.log(`✅ Deleted ${dailyActivityResult.rowCount} daily activity records`);
      
      // 6. Delete user stats
      const statsResult = await client.query('DELETE FROM user_stats WHERE user_id = $1', [testUser.id]);
      deletionResults.user_stats = statsResult.rowCount;
      console.log(`✅ Deleted ${statsResult.rowCount} user stats records`);
      
      // 7. Delete user account
      const userResult = await client.query('DELETE FROM app_user WHERE id = $1 RETURNING email', [testUser.id]);
      deletionResults.app_user = userResult.rowCount;
      console.log(`✅ Deleted user account: ${userResult.rows[0]?.email}`);
      
      await client.query('COMMIT');
      
      console.log('\n📊 Deletion Results:');
      Object.entries(deletionResults).forEach(([table, count]) => {
        console.log(`  ${table}: ${count} records deleted`);
      });
      
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
    
    // Step 4: Verify all data is deleted
    console.log('\n🔍 Verifying data after deletion:');
    const afterData = await verifyUserDataExists(testUser.id);
    
    // Step 5: Check for orphaned records
    console.log('\n🧹 Checking for orphaned records...');
    let orphanedRecords = false;
    
    Object.entries(afterData).forEach(([table, count]) => {
      if (typeof count === 'number' && count > 0) {
        console.log(`❌ ORPHANED RECORDS FOUND: ${table} has ${count} records for deleted user`);
        orphanedRecords = true;
      } else if (count === 0) {
        console.log(`✅ ${table}: Clean (0 records)`);
      } else {
        console.log(`ℹ️ ${table}: ${count}`);
      }
    });
    
    if (!orphanedRecords) {
      console.log('\n🎉 SUCCESS: Account deletion test completed successfully!');
      console.log('✅ All user data has been completely removed');
      console.log('✅ No orphaned records found');
    } else {
      console.log('\n❌ FAILURE: Orphaned records found after deletion');
    }
    
  } catch (error) {
    console.error('\n❌ Test failed:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

// Run the test
testAccountDeletion();
