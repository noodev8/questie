// Fix badge requirements to match their names and purposes
require('dotenv').config();
const { query } = require('./utils/database');

async function fixBadgeRequirements() {
  try {
    console.log('🏆 Fixing badge requirements to match their names...');
    
    // Define the badge requirement fixes
    const badgeFixes = [
      // Holiday badges - should require completing quests during holidays
      {
        name: 'Holiday Spirit',
        requirement_type: 'holiday_quest',
        requirement_date_start: '12-20',
        requirement_date_end: '01-05',
        requirement_recurring: true,
        requirement_value: 5
      },
      {
        name: 'New Year Champion',
        requirement_type: 'holiday_quest',
        requirement_date_start: '12-31',
        requirement_date_end: '01-02',
        requirement_recurring: true,
        requirement_value: 3
      },
      
      // Seasonal badges - should require completing quests in specific seasons
      {
        name: 'Spring Awakening',
        requirement_type: 'seasonal_quest',
        requirement_season: 'spring',
        requirement_value: 15
      },
      {
        name: 'Summer Warrior',
        requirement_type: 'seasonal_quest',
        requirement_season: 'summer',
        requirement_value: 20
      },
      {
        name: 'Autumn Achiever',
        requirement_type: 'seasonal_quest',
        requirement_season: 'autumn',
        requirement_value: 12
      },
      {
        name: 'Winter Survivor',
        requirement_type: 'seasonal_quest',
        requirement_season: 'winter',
        requirement_value: 25
      },
      
      // Time-based badges - should require completing quests at specific times
      {
        name: 'Early Bird',
        requirement_type: 'time_of_day_quest',
        requirement_time_start: '06:00:00',
        requirement_time_end: '09:00:00',
        requirement_value: 10
      },
      {
        name: 'Dawn Breaker',
        requirement_type: 'time_of_day_quest',
        requirement_time_start: '05:00:00',
        requirement_time_end: '07:00:00',
        requirement_value: 5
      },
      {
        name: 'Night Owl',
        requirement_type: 'time_of_day_quest',
        requirement_time_start: '21:00:00',
        requirement_time_end: '23:59:59',
        requirement_value: 10
      },
      {
        name: 'Midnight Runner',
        requirement_type: 'time_of_day_quest',
        requirement_time_start: '23:00:00',
        requirement_time_end: '02:00:00',
        requirement_value: 5
      },
      
      // Day-of-week badges
      {
        name: 'Weekend Warrior',
        requirement_type: 'day_of_week_quest',
        requirement_days: 'weekend',
        requirement_value: 20
      },
      {
        name: 'Weekday Champion',
        requirement_type: 'day_of_week_quest',
        requirement_days: 'weekday',
        requirement_value: 30
      },
      
      // Fitness category badges
      {
        name: 'First Workout',
        requirement_type: 'category_quest',
        requirement_category: 'fitness',
        requirement_value: 1
      },
      {
        name: 'Gym Regular',
        requirement_type: 'category_quest',
        requirement_category: 'fitness',
        requirement_value: 15
      },
      {
        name: 'Health Warrior',
        requirement_type: 'category_quest',
        requirement_category: 'fitness',
        requirement_value: 25
      },
      {
        name: 'Fitness Enthusiast',
        requirement_type: 'category_quest',
        requirement_category: 'fitness',
        requirement_value: 50
      },
      {
        name: 'Fitness Legend',
        requirement_type: 'category_quest',
        requirement_category: 'fitness',
        requirement_value: 100
      },
      
      // Social category badges
      {
        name: 'Social Butterfly',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 5
      },
      {
        name: 'Friend Maker',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 10
      },
      {
        name: 'Social Leader',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 25
      },
      {
        name: 'Social Master',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 50
      },
      {
        name: 'Community Builder',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 75
      },
      {
        name: 'Community Champion',
        requirement_type: 'category_quest',
        requirement_category: 'social',
        requirement_value: 100
      },

      // Creative category badges
      {
        name: 'Creative Spark',
        requirement_type: 'category_quest',
        requirement_category: 'creative',
        requirement_value: 3
      },
      {
        name: 'Imagination',
        requirement_type: 'category_quest',
        requirement_category: 'creative',
        requirement_value: 10
      },
      {
        name: 'Artist',
        requirement_type: 'category_quest',
        requirement_category: 'creative',
        requirement_value: 25
      },
      {
        name: 'Creative Genius',
        requirement_type: 'category_quest',
        requirement_category: 'creative',
        requirement_value: 50
      },
      {
        name: 'Artistic Legend',
        requirement_type: 'category_quest',
        requirement_category: 'creative',
        requirement_value: 100
      },

      // Nature category badges
      {
        name: 'Nature Lover',
        requirement_type: 'category_quest',
        requirement_category: 'nature',
        requirement_value: 5
      },
      {
        name: 'Outdoor Explorer',
        requirement_type: 'category_quest',
        requirement_category: 'nature',
        requirement_value: 15
      },
      {
        name: 'Nature Guardian',
        requirement_type: 'category_quest',
        requirement_category: 'nature',
        requirement_value: 30
      },
      {
        name: 'Eco Warrior',
        requirement_type: 'category_quest',
        requirement_category: 'nature',
        requirement_value: 50
      },

      // Learning category badges
      {
        name: 'Student',
        requirement_type: 'category_quest',
        requirement_category: 'learning',
        requirement_value: 10
      },
      {
        name: 'Academic',
        requirement_type: 'category_quest',
        requirement_category: 'learning',
        requirement_value: 20
      },
      {
        name: 'Scholar',
        requirement_type: 'category_quest',
        requirement_category: 'learning',
        requirement_value: 50
      },
      {
        name: 'Zen Student',
        requirement_type: 'category_quest',
        requirement_category: 'learning',
        requirement_value: 30
      },

      // Mindfulness category badges
      {
        name: 'Inner Peace',
        requirement_type: 'category_quest',
        requirement_category: 'mindfulness',
        requirement_value: 5
      },
      {
        name: 'Peaceful Heart',
        requirement_type: 'category_quest',
        requirement_category: 'mindfulness',
        requirement_value: 10
      },
      {
        name: 'Mindful Warrior',
        requirement_type: 'category_quest',
        requirement_category: 'mindfulness',
        requirement_value: 25
      },
      {
        name: 'Meditation Master',
        requirement_type: 'category_quest',
        requirement_category: 'mindfulness',
        requirement_value: 50
      }
    ];
    
    console.log(`\n🔧 Applying ${badgeFixes.length} badge requirement fixes...`);
    
    for (const fix of badgeFixes) {
      try {
        const updateSQL = `
          UPDATE badge 
          SET 
            requirement_type = $1,
            requirement_value = $2,
            requirement_category = $3,
            requirement_time_start = $4,
            requirement_time_end = $5,
            requirement_days = $6,
            requirement_season = $7,
            requirement_date_start = $8,
            requirement_date_end = $9,
            requirement_recurring = $10
          WHERE name = $11
          RETURNING id, name, requirement_type, requirement_value
        `;
        
        const result = await query(updateSQL, [
          fix.requirement_type,
          fix.requirement_value,
          fix.requirement_category || null,
          fix.requirement_time_start || null,
          fix.requirement_time_end || null,
          fix.requirement_days || null,
          fix.requirement_season || null,
          fix.requirement_date_start || null,
          fix.requirement_date_end || null,
          fix.requirement_recurring || false,
          fix.name
        ]);
        
        if (result.rows.length > 0) {
          const badge = result.rows[0];
          console.log(`  ✅ Fixed "${badge.name}": ${badge.requirement_type} (${badge.requirement_value})`);
        } else {
          console.log(`  ⚠️  Badge not found: "${fix.name}"`);
        }
        
      } catch (error) {
        console.log(`  ❌ Error fixing "${fix.name}": ${error.message}`);
      }
    }
    
    console.log('\n🎉 Badge requirement fixes completed!');
    console.log('📋 Badges now have proper requirements that match their names and purposes.');
    
  } catch (error) {
    console.error('❌ Error fixing badge requirements:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

fixBadgeRequirements();
