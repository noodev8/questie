// Simple migration runner to add profile_icon column
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'questie_prod_user',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'questie_prod',
  password: process.env.DB_PASSWORD || 'questie_prod_password',
  port: process.env.DB_PORT || 5432,
});

async function runMigration() {
  try {
    console.log('Running profile_icon migration...');
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', 'add_profile_icon.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    // Execute the migration
    await pool.query(migrationSQL);
    
    console.log('Migration completed successfully!');
    console.log('- Added profile_icon column to app_user table');
    console.log('- Added index on profile_icon column');
    console.log('- Set default profile_icon for existing users');
    
  } catch (error) {
    if (error.message.includes('already exists')) {
      console.log('Migration already applied - profile_icon column exists');
    } else {
      console.error('Migration failed:', error.message);
      process.exit(1);
    }
  } finally {
    await pool.end();
  }
}

// Run the migration
runMigration();
