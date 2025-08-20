// Add missing badge columns
require('dotenv').config();
const { query } = require('./utils/database');

async function addMissingColumns() {
  try {
    console.log('🔧 Adding missing badge columns...');
    
    // Add missing columns one by one
    const missingColumns = [
      'ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_category VARCHAR(50)',
      'ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_date_end VARCHAR(10)',
      'ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_recurring BOOLEAN DEFAULT false',
      'ALTER TABLE user_quest_assignment ADD COLUMN IF NOT EXISTS completed_time TIME',
      'ALTER TABLE user_quest_assignment ADD COLUMN IF NOT EXISTS completed_season VARCHAR(10)'
    ];
    
    for (const sql of missingColumns) {
      try {
        console.log(`  Executing: ${sql.substring(0, 60)}...`);
        await query(sql);
        console.log('    ✅ Success');
      } catch (error) {
        if (error.code === '42701') { // duplicate column
          console.log('    ⚠️  Column already exists');
        } else {
          console.log(`    ❌ Error: ${error.message}`);
        }
      }
    }
    
    // Create indexes
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_badge_requirement_category ON badge(requirement_category)',
      'CREATE INDEX IF NOT EXISTS idx_user_quest_completed_time ON user_quest_assignment(completed_time) WHERE completed_at IS NOT NULL',
      'CREATE INDEX IF NOT EXISTS idx_user_quest_completed_season ON user_quest_assignment(completed_season) WHERE completed_at IS NOT NULL'
    ];
    
    console.log('\n🔍 Creating indexes...');
    for (const sql of indexes) {
      try {
        console.log(`  Creating index: ${sql.substring(0, 60)}...`);
        await query(sql);
        console.log('    ✅ Success');
      } catch (error) {
        if (error.code === '42P07') { // duplicate index
          console.log('    ⚠️  Index already exists');
        } else {
          console.log(`    ❌ Error: ${error.message}`);
        }
      }
    }
    
    console.log('\n✅ Missing columns added successfully!');
    
  } catch (error) {
    console.error('❌ Error adding columns:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

addMissingColumns();
