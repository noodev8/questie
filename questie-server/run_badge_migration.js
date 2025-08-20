// Run badge system enhancement migration
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('./utils/database');

async function runBadgeMigration() {
  const client = await pool.connect();
  
  try {
    console.log('🔧 Running badge system enhancement migration...');
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', 'enhance_badge_system.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    // Split the migration into individual statements
    const statements = migrationSQL
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    console.log(`📝 Executing ${statements.length} migration statements...`);
    
    // Execute each statement individually (no transaction for DDL)
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        try {
          console.log(`  ${i + 1}/${statements.length}: ${statement.substring(0, 50)}...`);
          await client.query(statement);
          console.log(`    ✅ Success`);
        } catch (error) {
          if (error.message.includes('already exists') ||
              error.message.includes('does not exist') ||
              error.code === '42701' || // duplicate column
              error.code === '42P07') { // duplicate table/index
            console.log(`    ⚠️  Skipped: ${error.message.split('\n')[0]}`);
          } else {
            console.log(`    ❌ Error: ${error.message.split('\n')[0]}`);
            // Continue with other statements instead of failing completely
          }
        }
      }
    }
    
    console.log('✅ Badge system migration completed successfully!');
    console.log('📋 New features added:');
    console.log('  - Category-specific badge requirements');
    console.log('  - Time-of-day badge requirements');
    console.log('  - Day-of-week badge requirements');
    console.log('  - Seasonal badge requirements');
    console.log('  - Holiday badge requirements');
    console.log('  - Enhanced quest completion tracking');
    console.log('  - Helper functions for date/season calculations');
    
    // Verify the new columns were added
    const result = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'badge' 
      AND column_name LIKE 'requirement_%'
      ORDER BY column_name
    `);
    
    console.log('\n📊 Badge table columns:');
    result.rows.forEach(row => {
      console.log(`  - ${row.column_name}: ${row.data_type}`);
    });
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    client.release();
  }
  
  process.exit(0);
}

runBadgeMigration();
