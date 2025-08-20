-- 100 Badges for Questie App
-- Clear existing badges and reset sequence
DELETE FROM user_badge;
DELETE FROM badge;
ALTER SEQUENCE badge_id_seq RESTART WITH 1;

-- Quest Completion Badges (15 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('First Steps', 'Complete your very first quest', 'walk', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Getting Started', 'Complete 5 quests', 'star', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Quest Explorer', 'Complete 10 quests', 'map', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Dedicated Adventurer', 'Complete 25 quests', 'sword', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'adventure' LIMIT 1)),
('Quest Master', 'Complete 50 quests', 'trophy', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Legendary Hero', 'Complete 100 quests', 'crown', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Epic Adventurer', 'Complete 200 quests', 'medal', 'quests_completed', 200, (SELECT id FROM quest_category WHERE LOWER(name) = 'adventure' LIMIT 1)),
('Quest Deity', 'Complete 500 quests', 'lightning', 'quests_completed', 500, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Centurion', 'Complete 1000 quests', 'shield', 'quests_completed', 1000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Quest Immortal', 'Complete 2000 quests', 'infinity', 'quests_completed', 2000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Novice Adventurer', 'Complete 3 quests', 'compass', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'adventure' LIMIT 1)),
('Journey Begins', 'Complete 7 quests', 'path', 'quests_completed', 7, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Persistent Explorer', 'Complete 15 quests', 'mountain', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Seasoned Veteran', 'Complete 75 quests', 'veteran', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Quest Champion', 'Complete 150 quests', 'champion', 'quests_completed', 150, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1));

-- Points Badges (12 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Point Collector', 'Earn 100 total points', 'gem', 'total_points', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Accumulator', 'Earn 500 total points', 'coins', 'total_points', 500, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Master', 'Earn 1000 total points', 'target', 'total_points', 1000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Legend', 'Earn 2500 total points', 'star_outline', 'total_points', 2500, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Titan', 'Earn 5000 total points', 'sparkle', 'total_points', 5000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point God', 'Earn 10000 total points', 'bright_star', 'total_points', 10000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Millionaire', 'Earn 25000 total points', 'treasure', 'total_points', 25000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Billionaire', 'Earn 50000 total points', 'vault', 'total_points', 50000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('First Points', 'Earn your first 50 points', 'first_coin', 'total_points', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Starter', 'Earn 250 total points', 'coin_stack', 'total_points', 250, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Enthusiast', 'Earn 750 total points', 'gold_coin', 'total_points', 750, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Point Virtuoso', 'Earn 1500 total points', 'diamond_coin', 'total_points', 1500, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1));

-- Streak Badges (10 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Consistency', 'Maintain a 3-day streak', 'flame', 'current_streak', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Dedication', 'Maintain a 7-day streak', 'fire', 'current_streak', 7, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Commitment', 'Maintain a 14-day streak', 'torch', 'current_streak', 14, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Unstoppable', 'Maintain a 30-day streak', 'bonfire', 'current_streak', 30, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Inferno', 'Maintain a 60-day streak', 'wildfire', 'current_streak', 60, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Eternal Flame', 'Maintain a 100-day streak', 'eternal_fire', 'current_streak', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Phoenix Rising', 'Maintain a 200-day streak', 'phoenix', 'current_streak', 200, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Fire God', 'Maintain a 365-day streak', 'fire_god', 'current_streak', 365, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Spark Starter', 'Maintain a 2-day streak', 'spark', 'current_streak', 2, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Flame Keeper', 'Maintain a 21-day streak', 'flame_keeper', 'current_streak', 21, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1));

-- Fitness & Health Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('First Workout', 'Complete your first fitness quest', 'muscle', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Gym Regular', 'Complete 10 fitness quests', 'dumbbell', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Fitness Enthusiast', 'Complete 25 fitness quests', 'runner', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Health Warrior', 'Complete 50 fitness quests', 'strong', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Wellness Master', 'Complete 100 fitness quests', 'wellness', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Iron Will', 'Complete 5 fitness quests', 'iron', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Body Builder', 'Complete 75 fitness quests', 'bodybuilder', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1)),
('Fitness Legend', 'Complete 200 fitness quests', 'legend', 'quests_completed', 200, (SELECT id FROM quest_category WHERE LOWER(name) = 'fitness' LIMIT 1));

-- Learning & Education Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Curious Mind', 'Complete your first learning quest', 'book', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Knowledge Seeker', 'Complete 10 learning quests', 'graduation', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Scholar', 'Complete 25 learning quests', 'scroll', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Wisdom Keeper', 'Complete 50 learning quests', 'owl', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Master Teacher', 'Complete 100 learning quests', 'teacher', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Student', 'Complete 3 learning quests', 'student', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Academic', 'Complete 15 learning quests', 'academic', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Professor', 'Complete 75 learning quests', 'professor', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1));

-- Social & Community Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Social Butterfly', 'Complete your first social quest', 'butterfly', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Friend Maker', 'Complete 10 social quests', 'friends', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Community Builder', 'Complete 25 social quests', 'community', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Social Leader', 'Complete 50 social quests', 'leader', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Community Champion', 'Complete 100 social quests', 'champion_social', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Team Player', 'Complete 5 social quests', 'team', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Networker', 'Complete 15 social quests', 'network', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1)),
('Social Master', 'Complete 75 social quests', 'social_master', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1));

-- Creative & Art Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Creative Spark', 'Complete your first creative quest', 'sparkle', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Artist', 'Complete 10 creative quests', 'palette', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Creative Genius', 'Complete 25 creative quests', 'brush', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Master Creator', 'Complete 50 creative quests', 'theater', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Artistic Legend', 'Complete 100 creative quests', 'rainbow', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Imagination', 'Complete 3 creative quests', 'imagination', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Innovator', 'Complete 15 creative quests', 'innovation', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1)),
('Visionary', 'Complete 75 creative quests', 'vision', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'creativity' LIMIT 1));

-- Nature & Outdoor Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Nature Lover', 'Complete your first outdoor quest', 'seedling', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Outdoor Explorer', 'Complete 10 outdoor quests', 'tree', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Wilderness Guide', 'Complete 25 outdoor quests', 'mountain_peak', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Nature Guardian', 'Complete 50 outdoor quests', 'earth', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Earth Protector', 'Complete 100 outdoor quests', 'leaf', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Fresh Air', 'Complete 3 outdoor quests', 'wind', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Trail Blazer', 'Complete 15 outdoor quests', 'trail', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Eco Warrior', 'Complete 75 outdoor quests', 'eco', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1));

-- Mindfulness & Wellness Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Inner Peace', 'Complete your first mindfulness quest', 'meditation', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Zen Student', 'Complete 10 mindfulness quests', 'yin_yang', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Mindful Warrior', 'Complete 25 mindfulness quests', 'candle', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Meditation Master', 'Complete 50 mindfulness quests', 'lotus', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Enlightened Soul', 'Complete 100 mindfulness quests', 'enlightenment', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Calm Mind', 'Complete 3 mindfulness quests', 'calm', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Peaceful Heart', 'Complete 15 mindfulness quests', 'peace', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1)),
('Serenity', 'Complete 75 mindfulness quests', 'serenity', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'mindfulness' LIMIT 1));

-- Challenge & Quest Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Challenge Accepted', 'Complete your first challenge quest', 'challenge', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Challenge Crusher', 'Complete 10 challenge quests', 'crusher', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Obstacle Overcomer', 'Complete 25 challenge quests', 'hurdle', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Challenge Champion', 'Complete 50 challenge quests', 'challenge_medal', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Ultimate Challenger', 'Complete 100 challenge quests', 'ultimate', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Brave Heart', 'Complete 3 challenge quests', 'brave', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Fearless', 'Complete 15 challenge quests', 'fearless', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1)),
('Conqueror', 'Complete 75 challenge quests', 'conqueror', 'quests_completed', 75, (SELECT id FROM quest_category WHERE LOWER(name) = 'challenge' LIMIT 1));

-- Time-based Achievement Badges (6 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Early Bird', 'Complete a quest before 8 AM', 'sunrise', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Night Owl', 'Complete a quest after 10 PM', 'night_owl', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Weekend Warrior', 'Complete quests on weekends', 'weekend', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Weekday Champion', 'Complete quests on weekdays', 'weekday', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Midnight Runner', 'Complete a quest at midnight', 'midnight', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Dawn Breaker', 'Complete a quest at dawn', 'dawn', 'quests_completed', 1, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1));

-- Milestone Badges (6 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('First Week', 'Complete quests for 7 consecutive days', 'calendar', 'streak_days', 7, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1)),
('First Month', 'Complete quests for 30 consecutive days', 'month', 'streak_days', 30, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1)),
('Quarter Master', 'Complete quests for 90 consecutive days', 'quarter', 'streak_days', 90, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1)),
('Year Legend', 'Complete quests for 365 consecutive days', 'year', 'streak_days', 365, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1)),
('Half Year Hero', 'Complete quests for 180 consecutive days', 'half_year', 'streak_days', 180, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1)),
('Decade Master', 'Complete quests for 3650 consecutive days', 'decade', 'streak_days', 3650, (SELECT id FROM quest_category WHERE LOWER(name) = 'milestone' LIMIT 1));

-- Exploration Badges (6 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Pathfinder', 'Explore new quest categories', 'compass_explore', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Territory Mapper', 'Complete quests in multiple categories', 'map_explore', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('World Explorer', 'Master diverse quest types', 'world', 'quests_completed', 50, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Universe Traveler', 'Conquer all quest categories', 'rocket', 'quests_completed', 100, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Pioneer', 'Complete 3 different quest types', 'pioneer', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1)),
('Adventurous Spirit', 'Complete 25 exploration quests', 'spirit', 'quests_completed', 25, (SELECT id FROM quest_category WHERE LOWER(name) = 'exploration' LIMIT 1));

-- Habit Formation Badges (6 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Habit Starter', 'Build your first habit', 'habit_start', 'current_streak', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1)),
('Routine Builder', 'Maintain consistent habits', 'routine', 'current_streak', 14, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1)),
('Lifestyle Changer', 'Transform through habits', 'transform', 'current_streak', 30, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1)),
('Habit Master', 'Perfect your daily routine', 'habit_master', 'current_streak', 90, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1)),
('Discipline', 'Maintain habits for 2 weeks', 'discipline', 'current_streak', 14, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1)),
('Consistency King', 'Maintain habits for 6 months', 'consistency', 'current_streak', 180, (SELECT id FROM quest_category WHERE LOWER(name) = 'habit' LIMIT 1));

-- Special Achievement Badges (8 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Speed Demon', 'Complete 5 quests in one day', 'speed', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Marathon Runner', 'Complete 10 quests in one day', 'marathon', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Perfectionist', 'Complete 100% of daily quests for a week', 'perfect', 'quests_completed', 7, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Overachiever', 'Exceed daily quest goals', 'overachiever', 'quests_completed', 20, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Comeback Kid', 'Return after a break and complete quests', 'comeback', 'quests_completed', 5, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Multitasker', 'Complete multiple quest types in one day', 'multitask', 'quests_completed', 3, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Goal Crusher', 'Exceed weekly quest targets', 'goal_crusher', 'quests_completed', 35, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Unstoppable Force', 'Complete quests without missing a day for 2 weeks', 'unstoppable', 'current_streak', 14, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1));

-- Seasonal & Special Event Badges (6 badges)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('New Year Champion', 'Complete quests during New Year week', 'new_year', 'quests_completed', 7, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Spring Awakening', 'Complete nature quests in spring', 'spring', 'quests_completed', 10, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Summer Warrior', 'Complete outdoor quests in summer', 'summer', 'quests_completed', 15, (SELECT id FROM quest_category WHERE LOWER(name) = 'nature' LIMIT 1)),
('Autumn Achiever', 'Complete learning quests in autumn', 'autumn', 'quests_completed', 12, (SELECT id FROM quest_category WHERE LOWER(name) = 'learning' LIMIT 1)),
('Winter Survivor', 'Complete indoor quests in winter', 'winter', 'quests_completed', 20, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Holiday Spirit', 'Complete social quests during holidays', 'holiday', 'quests_completed', 8, (SELECT id FROM quest_category WHERE LOWER(name) = 'social' LIMIT 1));

-- Final Elite Badges (4 badges to reach 100 total)
INSERT INTO badge (name, description, icon, requirement_type, requirement_value, category_id) VALUES
('Elite Performer', 'Reach top 1% of all users', 'elite', 'total_points', 100000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Legendary Status', 'Complete 5000 total quests', 'legendary', 'quests_completed', 5000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1)),
('Immortal Streak', 'Maintain a 1000-day streak', 'immortal', 'current_streak', 1000, (SELECT id FROM quest_category WHERE LOWER(name) = 'daily' LIMIT 1)),
('Questie Master', 'Unlock all other badges', 'questie_master', 'quests_completed', 10000, (SELECT id FROM quest_category WHERE LOWER(name) = 'achievement' LIMIT 1));

-- Verify we have exactly 100 badges
-- SELECT COUNT(*) as total_badges FROM badge;
