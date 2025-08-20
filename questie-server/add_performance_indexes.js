// Add performance indexes to improve query performance
require('dotenv').config();
const { query } = require('./utils/database');

async function addPerformanceIndexes() {
  try {
    console.log('🚀 Adding performance indexes...');
    
    const indexes = [
      // User Quest Assignment indexes (most critical for performance)
      {
        name: 'idx_user_quest_assignment_user_type_date',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_type_date ON user_quest_assignment(user_id, assignment_type, assigned_date)'
      },
      {
        name: 'idx_user_quest_assignment_user_completed',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_completed ON user_quest_assignment(user_id, is_completed)'
      },
      {
        name: 'idx_user_quest_assignment_user_completed_at',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_completed_at ON user_quest_assignment(user_id, completed_at) WHERE completed_at IS NOT NULL'
      },
      
      // Quest and category indexes
      {
        name: 'idx_quest_category_active',
        sql: 'CREATE INDEX IF NOT EXISTS idx_quest_category_active ON quest(category_id, is_active)'
      },
      {
        name: 'idx_quest_active_difficulty',
        sql: 'CREATE INDEX IF NOT EXISTS idx_quest_active_difficulty ON quest(is_active, difficulty_level)'
      },
      
      // User badge indexes
      {
        name: 'idx_user_badge_user_completed',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_badge_user_completed ON user_badge(user_id, is_completed)'
      },
      {
        name: 'idx_user_badge_user_badge_completed',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_badge_user_badge_completed ON user_badge(user_id, badge_id, is_completed)'
      },
      
      // User stats index
      {
        name: 'idx_user_stats_user_id',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id)'
      },
      
      // Quest completion tracking indexes
      {
        name: 'idx_user_quest_completed_category',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_quest_completed_category ON user_quest_assignment(user_id, is_completed) WHERE is_completed = true'
      },
      
      // Composite index for badge checking queries
      {
        name: 'idx_badge_requirement_type_value',
        sql: 'CREATE INDEX IF NOT EXISTS idx_badge_requirement_type_value ON badge(requirement_type, requirement_value)'
      },
      
      // Index for quest history queries
      {
        name: 'idx_user_quest_assignment_history',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_history ON user_quest_assignment(user_id, assigned_date DESC, completed_at DESC)'
      },
      
      // Index for reroll log
      {
        name: 'idx_user_reroll_log_user_type_date',
        sql: 'CREATE INDEX IF NOT EXISTS idx_user_reroll_log_user_type_date ON user_reroll_log(user_id, assignment_type, reroll_date)'
      }
    ];
    
    let successCount = 0;
    let skipCount = 0;
    
    for (const index of indexes) {
      try {
        console.log(`  Creating index: ${index.name}...`);
        await query(index.sql);
        console.log('    ✅ Success');
        successCount++;
      } catch (error) {
        if (error.code === '42P07') { // duplicate index
          console.log('    ⚠️  Index already exists');
          skipCount++;
        } else {
          console.log(`    ❌ Error: ${error.message}`);
        }
      }
    }
    
    console.log(`\n🎉 Performance indexes completed!`);
    console.log(`   ✅ Created: ${successCount}`);
    console.log(`   ⚠️  Skipped: ${skipCount}`);
    console.log(`   📊 Total: ${indexes.length}`);
    
  } catch (error) {
    console.error('❌ Error adding performance indexes:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

addPerformanceIndexes();
