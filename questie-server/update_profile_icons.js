// Update existing profile icons to use new naming convention
const { Pool } = require('pg');

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'questie_prod_user',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'questie_prod',
  password: process.env.DB_PASSWORD || 'questie_prod_password',
  port: process.env.DB_PORT || 5432,
});

async function updateProfileIcons() {
  try {
    console.log('Updating profile icons to new naming convention...');
    
    // Update old naming to new naming
    const updates = [
      { old: 'assets/icons/questie1.png', new: 'assets/icons/questie-pic1.png' },
      { old: 'assets/icons/questie2.png', new: 'assets/icons/questie-pic2.png' },
      { old: 'assets/icons/questie3.png', new: 'assets/icons/questie-pic3.png' },
      { old: 'assets/icons/questie4.png', new: 'assets/icons/questie-pic4.png' },
    ];
    
    for (const update of updates) {
      const result = await pool.query(
        'UPDATE app_user SET profile_icon = $1 WHERE profile_icon = $2',
        [update.new, update.old]
      );
      console.log(`Updated ${result.rowCount} users from ${update.old} to ${update.new}`);
    }
    
    console.log('Profile icon update completed successfully!');
    
  } catch (error) {
    console.error('Profile icon update failed:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the update
updateProfileIcons();
