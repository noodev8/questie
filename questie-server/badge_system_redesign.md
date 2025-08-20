# Badge System Redesign Plan

## Current Problems
- 41 badges have misleading names that don't match their requirements
- All badges use generic `quests_completed`, `total_points`, or `streak` requirements
- No support for category-specific, time-based, or date-based requirements

## New Badge Requirement Types

### 1. **Category-Based Requirements**
- `category_quest` - Requires completing quests in specific categories
- Examples: Fitness badges require fitness quests, Social badges require social quests

### 2. **Time-of-Day Requirements**
- `time_of_day_quest` - Requires completing quests at specific times
- Examples: "Early Bird" (6 AM - 9 AM), "Night Owl" (9 PM - 12 AM)

### 3. **Day-of-Week Requirements**
- `day_of_week_quest` - Requires completing quests on specific days
- Examples: "Weekend Warrior" (Saturday/Sunday), "Weekday Champion" (Monday-Friday)

### 4. **Seasonal Requirements**
- `seasonal_quest` - Requires completing quests during specific seasons
- Examples: "Spring Awakening" (March-May), "Summer Warrior" (June-August)

### 5. **Holiday Requirements**
- `holiday_quest` - Requires completing quests during specific holidays
- Examples: "Holiday Spirit" (Dec 20-Jan 5), "New Year Champion" (Dec 31-Jan 2)

### 6. **Existing Requirements (Keep)**
- `quests_completed` - Total quest count (for general progression badges)
- `total_points` - Total points earned
- `current_streak` - Current daily streak
- `streak_days` - Longest streak achieved

## Database Schema Changes

### New Badge Table Columns
```sql
ALTER TABLE badge ADD COLUMN requirement_category VARCHAR(50);     -- fitness, social, creative, etc.
ALTER TABLE badge ADD COLUMN requirement_time_start TIME;          -- 06:00:00 for early bird
ALTER TABLE badge ADD COLUMN requirement_time_end TIME;            -- 09:00:00 for early bird
ALTER TABLE badge ADD COLUMN requirement_days VARCHAR(20);         -- 'weekend', 'weekday', 'monday,tuesday'
ALTER TABLE badge ADD COLUMN requirement_date_start DATE;          -- For seasonal/holiday badges
ALTER TABLE badge ADD COLUMN requirement_date_end DATE;            -- For seasonal/holiday badges
ALTER TABLE badge ADD COLUMN requirement_recurring BOOLEAN DEFAULT false; -- For yearly recurring badges
```

### Enhanced User Quest Assignment Table
```sql
ALTER TABLE user_quest_assignment ADD COLUMN completed_time TIME;
ALTER TABLE user_quest_assignment ADD COLUMN completed_day_of_week INTEGER; -- 0=Sunday, 6=Saturday
ALTER TABLE user_quest_assignment ADD COLUMN completed_season VARCHAR(10);  -- spring, summer, autumn, winter
```

## Badge Requirement Examples

### Category-Based Badges
```
"First Workout" -> category_quest: fitness, requirement_value: 1
"Social Butterfly" -> category_quest: social, requirement_value: 5
"Creative Spark" -> category_quest: creative, requirement_value: 3
"Nature Lover" -> category_quest: nature, requirement_value: 1
```

### Time-Based Badges
```
"Early Bird" -> time_of_day_quest, time_start: 06:00, time_end: 09:00, requirement_value: 10
"Night Owl" -> time_of_day_quest, time_start: 21:00, time_end: 23:59, requirement_value: 10
"Dawn Breaker" -> time_of_day_quest, time_start: 05:00, time_end: 07:00, requirement_value: 5
```

### Day-of-Week Badges
```
"Weekend Warrior" -> day_of_week_quest, requirement_days: 'weekend', requirement_value: 20
"Weekday Champion" -> day_of_week_quest, requirement_days: 'weekday', requirement_value: 50
```

### Seasonal Badges
```
"Spring Awakening" -> seasonal_quest, requirement_season: 'spring', requirement_value: 15
"Summer Warrior" -> seasonal_quest, requirement_season: 'summer', requirement_value: 25
"Autumn Achiever" -> seasonal_quest, requirement_season: 'autumn', requirement_value: 20
"Winter Survivor" -> seasonal_quest, requirement_season: 'winter', requirement_value: 30
```

### Holiday Badges
```
"Holiday Spirit" -> holiday_quest, date_start: '12-20', date_end: '01-05', recurring: true, requirement_value: 5
"New Year Champion" -> holiday_quest, date_start: '12-31', date_end: '01-02', recurring: true, requirement_value: 3
```

## Implementation Strategy

1. **Phase 1**: Add new database columns
2. **Phase 2**: Update badge checking logic to handle new requirement types
3. **Phase 3**: Migrate existing badges to use proper requirements
4. **Phase 4**: Enhance quest completion tracking
5. **Phase 5**: Test and validate the new system

## Benefits

- **Accurate badges**: Badge names will match their actual requirements
- **Meaningful achievements**: Users earn badges for specific behaviors
- **Better engagement**: Encourages diverse quest completion patterns
- **Seasonal variety**: Promotes activity during different times/seasons
- **Clear expectations**: Users know exactly what they need to do
