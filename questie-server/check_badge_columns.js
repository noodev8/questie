// Check badge table columns
require('dotenv').config();
const { query } = require('./utils/database');

async function checkBadgeColumns() {
  try {
    const result = await query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'badge' 
      ORDER BY ordinal_position
    `);
    
    console.log('📊 Badge table columns:');
    result.rows.forEach(row => {
      console.log(`  ${row.column_name}: ${row.data_type} (${row.is_nullable})`);
    });
    
    // Check if we have the new columns
    const newColumns = [
      'requirement_category',
      'requirement_time_start', 
      'requirement_time_end',
      'requirement_days',
      'requirement_season',
      'requirement_date_start',
      'requirement_date_end',
      'requirement_recurring'
    ];
    
    console.log('\n🔍 New column status:');
    newColumns.forEach(col => {
      const exists = result.rows.some(row => row.column_name === col);
      console.log(`  ${col}: ${exists ? '✅ EXISTS' : '❌ MISSING'}`);
    });
    
  } catch (error) {
    console.error('❌ Error checking columns:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

checkBadgeColumns();
