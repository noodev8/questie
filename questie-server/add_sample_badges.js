// Script to add sample badges to the database
require('dotenv').config();
const { query } = require('./utils/database');

const sampleBadges = [
  // Quest completion badges
  { name: 'First Steps', description: 'Complete your very first quest', icon: '🚶', requirement_type: 'quests_completed', requirement_value: 1 },
  { name: 'Getting Started', description: 'Complete 5 quests', icon: '🌟', requirement_type: 'quests_completed', requirement_value: 5 },
  { name: 'Quest Explorer', description: 'Complete 10 quests', icon: '🗺️', requirement_type: 'quests_completed', requirement_value: 10 },
  { name: 'Dedicated Adventurer', description: 'Complete 25 quests', icon: '⚔️', requirement_type: 'quests_completed', requirement_value: 25 },
  { name: 'Quest Master', description: 'Complete 50 quests', icon: '🏆', requirement_type: 'quests_completed', requirement_value: 50 },
  { name: 'Legendary Hero', description: 'Complete 100 quests', icon: '👑', requirement_type: 'quests_completed', requirement_value: 100 },

  // Points badges
  { name: 'Point Collector', description: 'Earn 100 total points', icon: '💎', requirement_type: 'total_points', requirement_value: 100 },
  { name: 'Point Accumulator', description: 'Earn 500 total points', icon: '💰', requirement_type: 'total_points', requirement_value: 500 },
  { name: 'Point Master', description: 'Earn 1000 total points', icon: '🎯', requirement_type: 'total_points', requirement_value: 1000 },
  { name: 'Point Legend', description: 'Earn 2500 total points', icon: '⭐', requirement_type: 'total_points', requirement_value: 2500 },

  // Streak badges
  { name: 'Consistency', description: 'Maintain a 3-day streak', icon: '🔥', requirement_type: 'current_streak', requirement_value: 3 },
  { name: 'Dedication', description: 'Maintain a 7-day streak', icon: '🔥', requirement_type: 'current_streak', requirement_value: 7 },
  { name: 'Commitment', description: 'Maintain a 14-day streak', icon: '🔥', requirement_type: 'current_streak', requirement_value: 14 },
  { name: 'Unstoppable', description: 'Maintain a 30-day streak', icon: '🔥', requirement_type: 'current_streak', requirement_value: 30 },

  // Longest streak badges
  { name: 'Week Warrior', description: 'Achieve a 7-day longest streak', icon: '📅', requirement_type: 'streak_days', requirement_value: 7 },
  { name: 'Month Champion', description: 'Achieve a 30-day longest streak', icon: '🗓️', requirement_type: 'streak_days', requirement_value: 30 },
  { name: 'Season Master', description: 'Achieve a 90-day longest streak', icon: '🏅', requirement_type: 'streak_days', requirement_value: 90 },
  { name: 'Year Legend', description: 'Achieve a 365-day longest streak', icon: '🎖️', requirement_type: 'streak_days', requirement_value: 365 }
];

async function addSampleBadges() {
  try {
    console.log('🎖️ Adding sample badges to database...');
    
    // Check if badges already exist
    const existingBadges = await query('SELECT COUNT(*) as count FROM badge');
    const badgeCount = parseInt(existingBadges.rows[0].count);
    
    if (badgeCount > 0) {
      console.log(`ℹ️ Found ${badgeCount} existing badges. Skipping badge creation.`);
      console.log('✅ Badge setup complete!');
      process.exit(0);
    }
    
    // Add each badge
    for (const badge of sampleBadges) {
      const text = `
        INSERT INTO badge (name, description, icon, requirement_type, requirement_value)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, name
      `;
      const result = await query(text, [
        badge.name,
        badge.description,
        badge.icon,
        badge.requirement_type,
        badge.requirement_value
      ]);
      
      console.log(`✅ Added badge: ${result.rows[0].name} (ID: ${result.rows[0].id})`);
    }
    
    console.log(`🎉 Successfully added ${sampleBadges.length} sample badges!`);
    console.log('✅ Badge setup complete!');
    
  } catch (error) {
    console.error('❌ Error adding sample badges:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

// Run the script
addSampleBadges();
