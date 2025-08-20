// Update badge requirements to make them more challenging
require('dotenv').config();
const { query } = require('./utils/database');

async function updateBadgeRequirements() {
  try {
    console.log('🏆 Updating badge requirements to make them more challenging...');
    
    // First, let's see what badges currently exist
    const currentBadges = await query(`
      SELECT id, name, requirement_type, requirement_value, description
      FROM badge 
      ORDER BY requirement_type, requirement_value
    `);
    
    console.log('\n📋 Current badges:');
    currentBadges.rows.forEach(badge => {
      console.log(`  ${badge.id}: ${badge.name} - ${badge.requirement_type}: ${badge.requirement_value}`);
    });
    
    // Update badge requirements to be more challenging
    const updates = [
      // Quest completion badges - make them much harder
      { type: 'quests_completed', oldValue: 1, newValue: 5, name: 'First Steps' },
      { type: 'quests_completed', oldValue: 3, newValue: 10, name: 'Getting Started' },
      { type: 'quests_completed', oldValue: 5, newValue: 25, name: 'Quest Explorer' },
      { type: 'quests_completed', oldValue: 10, newValue: 50, name: 'Quest Master' },
      { type: 'quests_completed', oldValue: 25, newValue: 100, name: 'Quest Legend' },
      { type: 'quests_completed', oldValue: 50, newValue: 250, name: 'Quest Champion' },
      { type: 'quests_completed', oldValue: 100, newValue: 500, name: 'Quest Hero' },
      
      // Points badges - make them much harder
      { type: 'total_points', oldValue: 10, newValue: 50, name: 'Point Collector' },
      { type: 'total_points', oldValue: 25, newValue: 150, name: 'Point Gatherer' },
      { type: 'total_points', oldValue: 50, newValue: 300, name: 'Point Hunter' },
      { type: 'total_points', oldValue: 100, newValue: 750, name: 'Point Master' },
      { type: 'total_points', oldValue: 250, newValue: 1500, name: 'Point Legend' },
      { type: 'total_points', oldValue: 500, newValue: 3000, name: 'Point Champion' },
      { type: 'total_points', oldValue: 1000, newValue: 5000, name: 'Point Hero' },
      
      // Streak badges - make them more challenging
      { type: 'current_streak', oldValue: 2, newValue: 3, name: 'Streak Starter' },
      { type: 'current_streak', oldValue: 3, newValue: 7, name: 'Week Warrior' },
      { type: 'current_streak', oldValue: 7, newValue: 14, name: 'Consistency King' },
      { type: 'current_streak', oldValue: 14, newValue: 30, name: 'Month Master' },
      { type: 'current_streak', oldValue: 30, newValue: 60, name: 'Streak Legend' },
      { type: 'current_streak', oldValue: 60, newValue: 100, name: 'Streak Champion' },
      
      // Longest streak badges - make them more challenging
      { type: 'streak_days', oldValue: 2, newValue: 5, name: 'First Streak' },
      { type: 'streak_days', oldValue: 5, newValue: 10, name: 'Streak Builder' },
      { type: 'streak_days', oldValue: 7, newValue: 21, name: 'Habit Former' },
      { type: 'streak_days', oldValue: 14, newValue: 50, name: 'Dedication Master' },
      { type: 'streak_days', oldValue: 30, newValue: 100, name: 'Persistence Legend' },
      { type: 'streak_days', oldValue: 60, newValue: 200, name: 'Streak Hero' },
    ];
    
    console.log('\n🔧 Applying updates...');
    
    for (const update of updates) {
      try {
        const result = await query(`
          UPDATE badge 
          SET requirement_value = $1
          WHERE requirement_type = $2 AND requirement_value = $3
          RETURNING id, name, requirement_type, requirement_value
        `, [update.newValue, update.type, update.oldValue]);
        
        if (result.rows.length > 0) {
          const badge = result.rows[0];
          console.log(`  ✅ Updated "${badge.name}": ${update.type} ${update.oldValue} → ${update.newValue}`);
        } else {
          console.log(`  ⚠️  No badge found for ${update.type}: ${update.oldValue} (${update.name})`);
        }
      } catch (error) {
        console.error(`  ❌ Error updating ${update.name}:`, error.message);
      }
    }
    
    // Show updated badges
    console.log('\n📋 Updated badges:');
    const updatedBadges = await query(`
      SELECT id, name, requirement_type, requirement_value, description
      FROM badge 
      ORDER BY requirement_type, requirement_value
    `);
    
    updatedBadges.rows.forEach(badge => {
      console.log(`  ${badge.id}: ${badge.name} - ${badge.requirement_type}: ${badge.requirement_value}`);
    });
    
    console.log('\n🎉 Badge requirements updated successfully!');
    console.log('📈 Badges are now much more challenging to earn!');
    
  } catch (error) {
    console.error('❌ Error updating badge requirements:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

// Run the update
updateBadgeRequirements();
