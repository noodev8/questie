-- Sample badges for the Questie app
-- Run this script to populate the badge table with sample badges

INSERT INTO badge (name, description, icon, requirement_type, requirement_value) VALUES
-- Quest completion badges
('First Steps', 'Complete your very first quest', '🚶', 'quests_completed', 1),
('Getting Started', 'Complete 5 quests', '🌟', 'quests_completed', 5),
('Quest Explorer', 'Complete 10 quests', '🗺️', 'quests_completed', 10),
('Dedicated Adventurer', 'Complete 25 quests', '⚔️', 'quests_completed', 25),
('Quest Master', 'Complete 50 quests', '🏆', 'quests_completed', 50),
('Legendary Hero', 'Complete 100 quests', '👑', 'quests_completed', 100),

-- Points badges
('Point Collector', 'Earn 100 total points', '💎', 'total_points', 100),
('Point Accumulator', 'Earn 500 total points', '💰', 'total_points', 500),
('Point Master', 'Earn 1000 total points', '🎯', 'total_points', 1000),
('Point Legend', 'Earn 2500 total points', '⭐', 'total_points', 2500),

-- Streak badges
('Consistency', 'Maintain a 3-day streak', '🔥', 'current_streak', 3),
('Dedication', 'Maintain a 7-day streak', '🔥', 'current_streak', 7),
('Commitment', 'Maintain a 14-day streak', '🔥', 'current_streak', 14),
('Unstoppable', 'Maintain a 30-day streak', '🔥', 'current_streak', 30),

-- Longest streak badges
('Week Warrior', 'Achieve a 7-day longest streak', '📅', 'streak_days', 7),
('Month Champion', 'Achieve a 30-day longest streak', '🗓️', 'streak_days', 30),
('Season Master', 'Achieve a 90-day longest streak', '🏅', 'streak_days', 90),
('Year Legend', 'Achieve a 365-day longest streak', '🎖️', 'streak_days', 365);
