-- Performance optimization indexes for Questie app
-- Run this script to add missing indexes that will significantly improve query performance

-- User Quest Assignment indexes (most critical for performance)
CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_type_date 
ON user_quest_assignment(user_id, assignment_type, assigned_date);

CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_completed 
ON user_quest_assignment(user_id, is_completed);

CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_user_completed_at 
ON user_quest_assignment(user_id, completed_at) WHERE completed_at IS NOT NULL;

-- Quest and category indexes
CREATE INDEX IF NOT EXISTS idx_quest_category_active 
ON quest(category_id, is_active);

CREATE INDEX IF NOT EXISTS idx_quest_active_difficulty 
ON quest(is_active, difficulty_level);

-- User badge indexes
CREATE INDEX IF NOT EXISTS idx_user_badge_user_completed 
ON user_badge(user_id, is_completed);

CREATE INDEX IF NOT EXISTS idx_user_badge_user_badge_completed 
ON user_badge(user_id, badge_id, is_completed);

-- User stats index
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id 
ON user_stats(user_id);

-- Quest completion tracking indexes
CREATE INDEX IF NOT EXISTS idx_user_quest_completed_category 
ON user_quest_assignment(user_id, is_completed) 
WHERE is_completed = true;

-- Composite index for badge checking queries
CREATE INDEX IF NOT EXISTS idx_badge_requirement_type_value 
ON badge(requirement_type, requirement_value);

-- Index for quest history queries
CREATE INDEX IF NOT EXISTS idx_user_quest_assignment_history 
ON user_quest_assignment(user_id, assigned_date DESC, completed_at DESC);

-- Index for reroll log
CREATE INDEX IF NOT EXISTS idx_user_reroll_log_user_type_date 
ON user_reroll_log(user_id, assignment_type, reroll_date);

-- Print completion message
SELECT 'Performance indexes created successfully!' as status;
