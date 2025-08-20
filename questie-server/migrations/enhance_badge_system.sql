-- Enhance Badge System Migration
-- Adds support for category-specific, time-based, and date-based badge requirements

-- Add new columns to badge table for enhanced requirements
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_category VARCHAR(50);
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_time_start TIME;
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_time_end TIME;
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_days VARCHAR(20);
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_season VARCHAR(10);
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_date_start VARCHAR(10); -- MM-DD format for recurring dates
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_date_end VARCHAR(10);   -- MM-DD format for recurring dates
ALTER TABLE badge ADD COLUMN IF NOT EXISTS requirement_recurring BOOLEAN DEFAULT false;

-- Add new columns to user_quest_assignment for tracking completion details
ALTER TABLE user_quest_assignment ADD COLUMN IF NOT EXISTS completed_time TIME;
ALTER TABLE user_quest_assignment ADD COLUMN IF NOT EXISTS completed_day_of_week INTEGER; -- 0=Sunday, 6=Saturday
ALTER TABLE user_quest_assignment ADD COLUMN IF NOT EXISTS completed_season VARCHAR(10);

-- Create indexes for better performance on new columns
CREATE INDEX IF NOT EXISTS idx_badge_requirement_category ON badge(requirement_category);
CREATE INDEX IF NOT EXISTS idx_badge_requirement_type_category ON badge(requirement_type, requirement_category);
CREATE INDEX IF NOT EXISTS idx_user_quest_completed_time ON user_quest_assignment(completed_time) WHERE completed_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_quest_completed_day ON user_quest_assignment(completed_day_of_week) WHERE completed_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_quest_completed_season ON user_quest_assignment(completed_season) WHERE completed_at IS NOT NULL;

-- Add comments to document the new columns
COMMENT ON COLUMN badge.requirement_category IS 'Category required for category_quest badges (fitness, social, creative, nature, learning, mindfulness)';
COMMENT ON COLUMN badge.requirement_time_start IS 'Start time for time_of_day_quest badges (e.g., 06:00 for early bird)';
COMMENT ON COLUMN badge.requirement_time_end IS 'End time for time_of_day_quest badges (e.g., 09:00 for early bird)';
COMMENT ON COLUMN badge.requirement_days IS 'Days required for day_of_week_quest badges (weekend, weekday, or specific days)';
COMMENT ON COLUMN badge.requirement_season IS 'Season required for seasonal_quest badges (spring, summer, autumn, winter)';
COMMENT ON COLUMN badge.requirement_date_start IS 'Start date for holiday_quest badges in MM-DD format (e.g., 12-20 for holiday season)';
COMMENT ON COLUMN badge.requirement_date_end IS 'End date for holiday_quest badges in MM-DD format (e.g., 01-05 for holiday season)';
COMMENT ON COLUMN badge.requirement_recurring IS 'Whether date-based requirements recur yearly (true for holidays/seasons)';

COMMENT ON COLUMN user_quest_assignment.completed_time IS 'Time of day when quest was completed (for time-based badges)';
COMMENT ON COLUMN user_quest_assignment.completed_day_of_week IS 'Day of week when completed (0=Sunday, 1=Monday, ..., 6=Saturday)';
COMMENT ON COLUMN user_quest_assignment.completed_season IS 'Season when quest was completed (spring, summer, autumn, winter)';

-- Create a function to determine season from date
CREATE OR REPLACE FUNCTION get_season(date_input DATE) RETURNS VARCHAR(10) AS $$
BEGIN
    CASE 
        WHEN EXTRACT(MONTH FROM date_input) IN (3, 4, 5) THEN RETURN 'spring';
        WHEN EXTRACT(MONTH FROM date_input) IN (6, 7, 8) THEN RETURN 'summer';
        WHEN EXTRACT(MONTH FROM date_input) IN (9, 10, 11) THEN RETURN 'autumn';
        WHEN EXTRACT(MONTH FROM date_input) IN (12, 1, 2) THEN RETURN 'winter';
        ELSE RETURN 'unknown';
    END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create a function to check if a date falls within a recurring date range
CREATE OR REPLACE FUNCTION is_date_in_range(
    check_date DATE,
    start_date_str VARCHAR(10),
    end_date_str VARCHAR(10)
) RETURNS BOOLEAN AS $$
DECLARE
    start_month INTEGER;
    start_day INTEGER;
    end_month INTEGER;
    end_day INTEGER;
    check_month INTEGER;
    check_day INTEGER;
BEGIN
    -- Parse start date (MM-DD format)
    start_month := CAST(SPLIT_PART(start_date_str, '-', 1) AS INTEGER);
    start_day := CAST(SPLIT_PART(start_date_str, '-', 2) AS INTEGER);
    
    -- Parse end date (MM-DD format)
    end_month := CAST(SPLIT_PART(end_date_str, '-', 1) AS INTEGER);
    end_day := CAST(SPLIT_PART(end_date_str, '-', 2) AS INTEGER);
    
    -- Get check date components
    check_month := EXTRACT(MONTH FROM check_date);
    check_day := EXTRACT(DAY FROM check_date);
    
    -- Handle year-crossing ranges (e.g., Dec 20 - Jan 5)
    IF start_month > end_month THEN
        RETURN (check_month > start_month OR check_month < end_month) OR
               (check_month = start_month AND check_day >= start_day) OR
               (check_month = end_month AND check_day <= end_day);
    ELSE
        -- Normal range within same year
        RETURN (check_month > start_month OR check_month < end_month) OR
               (check_month = start_month AND check_day >= start_day) OR
               (check_month = end_month AND check_day <= end_day);
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
