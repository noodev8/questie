const { pool } = require('./utils/database');
const questManager = require('./utils/database').questManager;

async function testUncompletionFix() {
  console.log('🧪 Testing quest uncompletion fix...\n');
  
  const client = await pool.connect();
  let testUserId = null;
  let testAssignmentId = null;
  
  try {
    await client.query('BEGIN');
    
    // 1. Create a test user
    console.log('1️⃣ Creating test user...');
    const userResult = await client.query(`
      INSERT INTO app_user (email, password_hash, display_name, is_anonymous, email_verified)
      VALUES ('test_uncompletion@example.com', 'dummy_hash', 'Test User', false, true)
      RETURNING id
    `);
    testUserId = userResult.rows[0].id;
    console.log(`   ✅ Created test user with ID: ${testUserId}`);
    
    // 2. Create initial user stats
    console.log('2️⃣ Creating initial user stats...');
    await client.query(`
      INSERT INTO user_stats (user_id, total_quests_completed, total_points, current_streak_days, longest_streak_days)
      VALUES ($1, 5, 100, 2, 5)
    `, [testUserId]);
    console.log('   ✅ Initial stats: 5 quests completed, 100 points');
    
    // 3. Get a quest and create an assignment
    console.log('3️⃣ Creating quest assignment...');
    const questResult = await client.query(`
      SELECT id, points FROM quest WHERE is_active = true LIMIT 1
    `);
    
    if (questResult.rows.length === 0) {
      throw new Error('No active quests found');
    }
    
    const quest = questResult.rows[0];
    const assignmentResult = await client.query(`
      INSERT INTO user_quest_assignment (user_id, quest_id, assignment_type, assigned_date, is_completed)
      VALUES ($1, $2, 'daily', CURRENT_DATE, false)
      RETURNING id
    `, [testUserId, quest.id]);
    testAssignmentId = assignmentResult.rows[0].id;
    console.log(`   ✅ Created assignment ID: ${testAssignmentId} for quest with ${quest.points} points`);
    
    await client.query('COMMIT');
    
    // 4. Complete the quest
    console.log('4️⃣ Completing quest...');
    await questManager.completeQuest(testUserId, testAssignmentId, 'Test completion');
    
    // Check stats after completion
    const statsAfterCompletion = await client.query(`
      SELECT total_quests_completed, total_points FROM user_stats WHERE user_id = $1
    `, [testUserId]);
    const afterCompletion = statsAfterCompletion.rows[0];
    console.log(`   ✅ After completion: ${afterCompletion.total_quests_completed} quests, ${afterCompletion.total_points} points`);
    
    // 5. Uncomplete the quest (this is what we're testing)
    console.log('5️⃣ Uncompleting quest (testing the fix)...');
    await questManager.uncompleteQuest(testUserId, testAssignmentId);
    
    // Check stats after uncompletion
    const statsAfterUncompletion = await client.query(`
      SELECT total_quests_completed, total_points FROM user_stats WHERE user_id = $1
    `, [testUserId]);
    const afterUncompletion = statsAfterUncompletion.rows[0];
    console.log(`   ✅ After uncompletion: ${afterUncompletion.total_quests_completed} quests, ${afterUncompletion.total_points} points`);
    
    // 6. Verify the fix worked correctly
    console.log('6️⃣ Verifying fix...');
    const expectedQuests = 5; // Should be back to original 5
    const expectedPoints = 100; // Should be back to original 100
    
    if (afterUncompletion.total_quests_completed === expectedQuests && 
        afterUncompletion.total_points === expectedPoints) {
      console.log('   🎉 SUCCESS! Quest uncompletion correctly:');
      console.log(`      - Decremented quest count to ${afterUncompletion.total_quests_completed}`);
      console.log(`      - Decremented points to ${afterUncompletion.total_points}`);
    } else {
      console.log('   ❌ FAILED! Expected:');
      console.log(`      - Quests: ${expectedQuests}, got: ${afterUncompletion.total_quests_completed}`);
      console.log(`      - Points: ${expectedPoints}, got: ${afterUncompletion.total_points}`);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    // Cleanup
    if (testUserId) {
      console.log('\n🧹 Cleaning up test data...');
      await client.query('DELETE FROM user_quest_completion WHERE user_id = $1', [testUserId]);
      await client.query('DELETE FROM user_quest_assignment WHERE user_id = $1', [testUserId]);
      await client.query('DELETE FROM user_stats WHERE user_id = $1', [testUserId]);
      await client.query('DELETE FROM app_user WHERE id = $1', [testUserId]);
      console.log('   ✅ Cleanup complete');
    }
    client.release();
  }
}

// Run the test
testUncompletionFix()
  .then(() => {
    console.log('\n✅ Test completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Test failed:', error);
    process.exit(1);
  });
