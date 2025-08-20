// Check for badge requirement inconsistencies
require('dotenv').config();
const { query } = require('./utils/database');

async function checkBadgeInconsistencies() {
  try {
    console.log('🔍 Checking badge requirement inconsistencies...\n');
    
    const result = await query(`
      SELECT id, name, description, requirement_type, requirement_value 
      FROM badge 
      ORDER BY name
    `);
    
    console.log('Badge Inconsistencies Found:');
    console.log('=' .repeat(100));
    
    const inconsistencies = [];
    
    result.rows.forEach(badge => {
      const name = badge.name.toLowerCase();
      const desc = (badge.description || '').toLowerCase();
      const reqType = badge.requirement_type;
      const reqValue = badge.requirement_value;
      
      // Check for time-based badges that should have different requirements
      if (name.includes('holiday') || name.includes('christmas') || name.includes('new year')) {
        if (reqType !== 'holiday_quest' && reqType !== 'seasonal_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Holiday badge should require completing quests during holidays, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use date-based requirement or special holiday quest completion'
          });
        }
      }
      
      if (name.includes('spring') || name.includes('summer') || name.includes('autumn') || name.includes('winter')) {
        if (reqType !== 'seasonal_quest' && reqType !== 'date_range_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Seasonal badge should require completing quests in specific season, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use seasonal date-based requirement'
          });
        }
      }
      
      if (name.includes('weekend') && reqType !== 'weekend_quest') {
        inconsistencies.push({
          id: badge.id,
          name: badge.name,
          issue: `Weekend badge should require completing quests on weekends, not just ${reqType}: ${reqValue}`,
          suggestion: 'Should use weekend-specific requirement'
        });
      }
      
      if (name.includes('weekday') && reqType !== 'weekday_quest') {
        inconsistencies.push({
          id: badge.id,
          name: badge.name,
          issue: `Weekday badge should require completing quests on weekdays, not just ${reqType}: ${reqValue}`,
          suggestion: 'Should use weekday-specific requirement'
        });
      }
      
      if ((name.includes('early bird') || name.includes('dawn')) && reqType !== 'morning_quest') {
        inconsistencies.push({
          id: badge.id,
          name: badge.name,
          issue: `Morning badge should require completing quests in the morning, not just ${reqType}: ${reqValue}`,
          suggestion: 'Should use time-of-day requirement (e.g., before 9 AM)'
        });
      }
      
      if ((name.includes('night owl') || name.includes('midnight')) && reqType !== 'night_quest') {
        inconsistencies.push({
          id: badge.id,
          name: badge.name,
          issue: `Night badge should require completing quests at night, not just ${reqType}: ${reqValue}`,
          suggestion: 'Should use time-of-day requirement (e.g., after 9 PM)'
        });
      }
      
      if (name.includes('streak') && !reqType.includes('streak')) {
        inconsistencies.push({
          id: badge.id,
          name: badge.name,
          issue: `Streak badge should use streak requirement, not ${reqType}: ${reqValue}`,
          suggestion: 'Should use current_streak or streak_days requirement'
        });
      }
      
      // Check for category-specific badges
      if (name.includes('fitness') || name.includes('workout') || name.includes('gym') || name.includes('health')) {
        if (reqType !== 'category_quest' && reqType !== 'fitness_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Fitness badge should require completing fitness quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for fitness quests'
          });
        }
      }
      
      if (name.includes('social') || name.includes('friend') || name.includes('community')) {
        if (reqType !== 'category_quest' && reqType !== 'social_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Social badge should require completing social quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for social quests'
          });
        }
      }
      
      if (name.includes('creative') || name.includes('artist') || name.includes('imagination')) {
        if (reqType !== 'category_quest' && reqType !== 'creative_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Creative badge should require completing creative quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for creative quests'
          });
        }
      }
      
      if (name.includes('nature') || name.includes('outdoor') || name.includes('eco')) {
        if (reqType !== 'category_quest' && reqType !== 'nature_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Nature badge should require completing nature/outdoor quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for nature quests'
          });
        }
      }
      
      if (name.includes('learning') || name.includes('student') || name.includes('academic') || name.includes('scholar')) {
        if (reqType !== 'category_quest' && reqType !== 'learning_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Learning badge should require completing learning quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for learning quests'
          });
        }
      }
      
      if (name.includes('mindful') || name.includes('meditation') || name.includes('zen') || name.includes('peace')) {
        if (reqType !== 'category_quest' && reqType !== 'mindfulness_quest') {
          inconsistencies.push({
            id: badge.id,
            name: badge.name,
            issue: `Mindfulness badge should require completing mindfulness quests, not just ${reqType}: ${reqValue}`,
            suggestion: 'Should use category-specific requirement for mindfulness quests'
          });
        }
      }
    });
    
    if (inconsistencies.length === 0) {
      console.log('✅ No major inconsistencies found!');
    } else {
      inconsistencies.forEach((issue, index) => {
        console.log(`${index + 1}. Badge ID ${issue.id}: "${issue.name}"`);
        console.log(`   Issue: ${issue.issue}`);
        console.log(`   Suggestion: ${issue.suggestion}`);
        console.log('');
      });
      
      console.log(`\n📊 Total inconsistencies found: ${inconsistencies.length}`);
      console.log('\n💡 These badges should have more specific requirements that match their names and purposes.');
    }
    
  } catch (error) {
    console.error('❌ Error checking badge inconsistencies:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

checkBadgeInconsistencies();
