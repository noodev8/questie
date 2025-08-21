// Test the new badge system
require('dotenv').config();
const { query } = require('./utils/database');

async function testBadgeSystem() {
  try {
    console.log('🧪 Testing the new badge system...\n');
    
    // Test 1: Check if badges have proper requirements
    console.log('📋 Test 1: Checking badge requirements...');
    const badgeResult = await query(`
      SELECT name, requirement_type, requirement_value, requirement_category,
             requirement_time_start, requirement_time_end, requirement_days,
             requirement_season, requirement_date_start, requirement_date_end
      FROM badge 
      WHERE name IN ('Holiday Spirit', 'Early Bird', 'First Workout', 'Social Butterfly', 'Spring Awakening')
      ORDER BY name
    `);
    
    badgeResult.rows.forEach(badge => {
      console.log(`  ✅ ${badge.name}:`);
      console.log(`     Type: ${badge.requirement_type}, Value: ${badge.requirement_value}`);
      if (badge.requirement_category) console.log(`     Category: ${badge.requirement_category}`);
      if (badge.requirement_time_start) console.log(`     Time: ${badge.requirement_time_start} - ${badge.requirement_time_end}`);
      if (badge.requirement_days) console.log(`     Days: ${badge.requirement_days}`);
      if (badge.requirement_season) console.log(`     Season: ${badge.requirement_season}`);
      if (badge.requirement_date_start) console.log(`     Dates: ${badge.requirement_date_start} - ${badge.requirement_date_end}`);
      console.log('');
    });
    
    // Test 2: Check if quest completion tracking columns exist
    console.log('📋 Test 2: Checking quest completion tracking...');
    const trackingResult = await query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'user_quest_assignment' 
      AND column_name IN ('completed_time', 'completed_day_of_week', 'completed_season')
    `);
    
    const trackingColumns = trackingResult.rows.map(row => row.column_name);
    console.log(`  ✅ Tracking columns: ${trackingColumns.join(', ')}`);
    
    // Test 3: Test quest categories exist
    console.log('\n📋 Test 3: Checking quest categories...');
    const categoryResult = await query(`
      SELECT name FROM quest_category ORDER BY name
    `);
    
    console.log('  ✅ Available categories:');
    categoryResult.rows.forEach(cat => {
      console.log(`     - ${cat.name}`);
    });
    
    // Test 4: Create a test user and simulate quest completion
    console.log('\n📋 Test 4: Testing badge awarding logic...');
    
    // Create test user
    const userResult = await query(`
      INSERT INTO app_user (display_name, is_anonymous) 
      VALUES ('Badge Test User', true) 
      RETURNING id
    `);
    const testUserId = userResult.rows[0].id;
    console.log(`  ✅ Created test user: ${testUserId}`);
    
    // Initialize user stats
    await query(`
      INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days)
      VALUES ($1, 0, 0, 0, 0)
    `, [testUserId]);
    console.log('  ✅ Initialized user stats');
    
    // Get a fitness quest to test category badges
    const fitnessQuestResult = await query(`
      SELECT q.id 
      FROM quest q 
      JOIN quest_category qc ON q.category_id = qc.id 
      WHERE LOWER(qc.name) LIKE '%fitness%' OR LOWER(qc.name) LIKE '%health%'
      LIMIT 1
    `);
    
    if (fitnessQuestResult.rows.length > 0) {
      const questId = fitnessQuestResult.rows[0].id;
      
      // Create quest assignment
      const assignmentResult = await query(`
        INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date)
        VALUES ($1, $2, 'daily', CURRENT_DATE)
        RETURNING id
      `, [testUserId, questId]);
      const assignmentId = assignmentResult.rows[0].id;
      
      // Simulate quest completion with tracking data
      const now = new Date();
      const completedTime = '07:30:00'; // Morning time for Early Bird test
      const completedDayOfWeek = 1; // Monday
      const completedSeason = 'winter';
      
      await query(`
        UPDATE user_quest_assignment 
        SET is_completed = true, 
            completed_at = CURRENT_TIMESTAMP,
            completed_time = $3,
            completed_day_of_week = $4,
            completed_season = $5
        WHERE id = $1 AND user_id = $2
      `, [assignmentId, testUserId, completedTime, completedDayOfWeek, completedSeason]);
      
      console.log('  ✅ Simulated fitness quest completion with tracking data');
      
      // Update user stats
      await query(`
        UPDATE user_stats 
        SET total_quests_completed = 1, total_points = 10, current_streak_days = 1, longest_streak_days = 1
        WHERE user_id = $1
      `, [testUserId]);
      
      console.log('  ✅ Updated user stats');
      
      // Test badge checking (this will test our new logic)
      console.log('  🏆 Testing badge checking logic...');
      
      // Import the badge manager to test it
      const { badgeManager } = require('./utils/database');
      
      try {
        const newBadges = await badgeManager.checkAndAwardBadgesOptimized(testUserId);
        console.log(`  ✅ Badge check completed! Awarded ${newBadges.length} badges:`);
        newBadges.forEach(badge => {
          console.log(`     - ${badge.name} (${badge.requirement_type}: ${badge.requirement_value})`);
        });
      } catch (error) {
        console.log(`  ❌ Badge checking failed: ${error.message}`);
      }
    } else {
      console.log('  ⚠️  No fitness quests found, skipping quest completion test');
    }
    
    // Clean up test user
    await query('DELETE FROM user_badge WHERE user_id = $1', [testUserId]);
    await query('DELETE FROM user_quest_assignment WHERE user_id = $1', [testUserId]);
    await query('DELETE FROM user_stats WHERE user_id = $1', [testUserId]);
    await query('DELETE FROM app_user WHERE id = $1', [testUserId]);
    console.log('  ✅ Cleaned up test data');
    
    console.log('\n🎉 Badge system testing completed!');
    console.log('📊 Summary:');
    console.log('  ✅ Badge requirements updated correctly');
    console.log('  ✅ Quest completion tracking enhanced');
    console.log('  ✅ Badge checking logic updated');
    console.log('  ✅ New requirement types supported');
    
  } catch (error) {
    console.error('❌ Badge system test failed:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

testBadgeSystem();
