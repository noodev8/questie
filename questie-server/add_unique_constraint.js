// Add unique constraint to user_badge table
require('dotenv').config();
const { query } = require('./utils/database');

async function addUniqueConstraint() {
  try {
    console.log('🔧 Adding unique constraint to user_badge table...');
    
    // Add unique constraint on (user_id, badge_id)
    const constraintSQL = `
      ALTER TABLE user_badge 
      ADD CONSTRAINT user_badge_user_badge_unique 
      UNIQUE (user_id, badge_id);
    `;
    
    await query(constraintSQL);
    console.log('✅ Unique constraint added successfully!');
    
  } catch (error) {
    if (error.code === '23505' || error.message.includes('already exists')) {
      console.log('ℹ️ Unique constraint already exists, skipping...');
    } else {
      console.error('❌ Error adding unique constraint:', error);
      process.exit(1);
    }
  }
  
  process.exit(0);
}

// Run the script
addUniqueConstraint();
