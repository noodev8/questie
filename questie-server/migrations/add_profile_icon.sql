-- Add profile_icon column to app_user table
-- This allows users to select their profile icon

ALTER TABLE app_user
ADD COLUMN profile_icon VARCHAR(255) DEFAULT 'assets/icons/questie-pic1.png';

-- Add index for profile_icon for potential future queries
CREATE INDEX idx_app_user_profile_icon ON app_user(profile_icon);

-- Update existing users to have a default profile icon
UPDATE app_user
SET profile_icon = 'assets/icons/questie-pic1.png'
WHERE profile_icon IS NULL;
