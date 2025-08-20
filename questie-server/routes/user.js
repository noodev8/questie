// =======================================================================================================================================
// API Route: User Data Routes
// =======================================================================================================================================
// Method: GET
// Purpose: Handle user stats, badges, and profile data retrieval
// =======================================================================================================================================

const express = require('express');
const rateLimit = require('express-rate-limit');
const { authMiddleware } = require('../utils/tokenutils');
const { questManager, badgeManager } = require('../utils/database');

const router = express.Router();

// Rate limiting for user data endpoints
const userLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 30, // limit each IP to 30 requests per minute
  message: {
    return_code: 'RATE_LIMIT_EXCEEDED',
    message: 'Too many user data requests, please try again later.'
  }
});

// GET /api/user/stats - Get user's statistics
router.get('/stats', authMiddleware.requireAuth, userLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Get user stats
    const stats = await questManager.getUserStats(userId);
    
    // Get badge count
    const badgeCount = await badgeManager.getUserBadgeCount(userId);
    
    res.json({
      return_code: 'SUCCESS',
      message: 'User stats retrieved successfully',
      stats: {
        total_quests_completed: stats.total_quests_completed,
        total_points: stats.total_points,
        current_streak_days: stats.current_streak_days,
        longest_streak_days: stats.longest_streak_days,
        badge_count: badgeCount,
        last_quest_completed_at: stats.last_quest_completed_at,
        updated_at: stats.updated_at
      }
    });

  } catch (error) {
    console.error('User stats error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve user stats'
    });
  }
});

// GET /api/user/badges - Get all badges with user's progress
router.get('/badges', authMiddleware.requireAuth, userLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Get all badges with user progress
    const badges = await badgeManager.getAllBadgesForUser(userId);
    
    // Format badges for frontend
    const formattedBadges = badges.map(badge => ({
      id: badge.id,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      category: badge.category_name,
      requirement_type: badge.requirement_type,
      requirement_value: badge.requirement_value,
      progress_value: badge.progress_value || 0,
      is_earned: badge.is_completed || false,
      earned_at: badge.earned_at
    }));
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Badges retrieved successfully',
      badges: formattedBadges
    });

  } catch (error) {
    console.error('User badges error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve badges'
    });
  }
});

// GET /api/user/badges/earned - Get user's earned badges only
router.get('/badges/earned', authMiddleware.requireAuth, userLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Get earned badges
    const earnedBadges = await badgeManager.getUserEarnedBadges(userId);
    
    // Format badges for frontend
    const formattedBadges = earnedBadges.map(badge => ({
      id: badge.id,
      name: badge.name,
      description: badge.description,
      icon: badge.icon,
      category: badge.category_name,
      requirement_type: badge.requirement_type,
      requirement_value: badge.requirement_value,
      progress_value: badge.progress_value,
      earned_at: badge.earned_at
    }));
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Earned badges retrieved successfully',
      badges: formattedBadges
    });

  } catch (error) {
    console.error('User earned badges error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve earned badges'
    });
  }
});

// POST /api/user/badges/check - Manually check and award badges
router.post('/badges/check', authMiddleware.requireAuth, userLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;

    // Check and award badges
    const newlyEarnedBadges = await badgeManager.checkAndAwardBadges(userId);

    res.json({
      return_code: 'SUCCESS',
      message: 'Badge check completed',
      newly_earned_badges: newlyEarnedBadges,
      count: newlyEarnedBadges.length
    });

  } catch (error) {
    console.error('Badge check error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to check badges'
    });
  }
});

module.exports = router;
