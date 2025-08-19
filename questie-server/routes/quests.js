// =======================================================================================================================================
// API Route: Quest Management Routes
// =======================================================================================================================================
// Method: GET, POST
// Purpose: Handle daily and weekly quest assignments, rerolling, and completion
// =======================================================================================================================================

const express = require('express');
const { body, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');

const { questManager, query } = require('../utils/database');
const { authMiddleware } = require('../utils/tokenutils');

const router = express.Router();

// Rate limiting for quest endpoints
const questLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // limit each IP to 30 requests per windowMs for quest endpoints
  message: {
    return_code: 'RATE_LIMIT_EXCEEDED',
    message: 'Too many quest requests, please try again later.'
  }
});

// Helper function to handle validation errors
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      return_code: 'VALIDATION_ERROR',
      message: 'Invalid input data',
      errors: errors.array()
    });
  }
  next();
}

// Helper function to get Monday of current week
function getMondayOfWeek(date = new Date()) {
  const d = new Date(date);
  const dayOfWeek = d.getDay();
  const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Sunday = 0, Monday = 1
  d.setDate(d.getDate() - daysToMonday);
  d.setHours(0, 0, 0, 0);
  return d;
}

// Helper function to select 5 random weekly quests with balanced difficulty
async function selectWeeklyQuests(userId, excludeQuestIds = []) {
  const quests = [];

  // Get 2 easy, 2 medium, 1 hard quest
  const difficulties = [
    { level: 'easy', count: 2 },
    { level: 'medium', count: 2 },
    { level: 'hard', count: 1 }
  ];

  for (const { level, count } of difficulties) {
    for (let i = 0; i < count; i++) {
      const quest = await questManager.getRandomQuestByDifficultyForUser(userId, level, excludeQuestIds);
      if (quest) {
        quests.push(quest);
        excludeQuestIds.push(quest.id);
      }
    }
  }

  return quests;
}

// GET /api/quests/daily - Get user's daily quest
router.get('/daily', authMiddleware.requireAuth, questLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    
    // Check if user already has a daily quest for today
    let dailyQuest = await questManager.getUserDailyQuest(userId, today);
    
    if (!dailyQuest) {
      // Assign a new random daily quest (medium difficulty) specific to this user
      const randomQuest = await questManager.getRandomQuestByDifficultyForUser(userId, 'medium');

      if (!randomQuest) {
        return res.status(500).json({
          return_code: 'NO_QUESTS_AVAILABLE',
          message: 'No quests available for assignment'
        });
      }

      // Assign the quest
      const assignment = await questManager.assignDailyQuest(userId, randomQuest.id, today);

      // Get the full quest details
      dailyQuest = await questManager.getUserDailyQuest(userId, today);
    }

    // Check if user can reroll (hasn't rerolled today)
    const canReroll = !(await questManager.hasUserRerolledToday(userId, 'daily', today));

    res.json({
      return_code: 'SUCCESS',
      message: 'Daily quest retrieved successfully',
      quest: {
        assignment_id: dailyQuest.assignment_id,
        quest_id: dailyQuest.quest_id,
        title: dailyQuest.title,
        description: dailyQuest.description,
        category: dailyQuest.category_name,
        difficulty: dailyQuest.difficulty_level,
        points: dailyQuest.points,
        estimated_duration_minutes: dailyQuest.estimated_duration_minutes,
        assigned_date: dailyQuest.assigned_date,
        is_completed: dailyQuest.is_completed,
        completed_at: dailyQuest.completed_at,
        expires_at: dailyQuest.expires_at,
        can_reroll: canReroll
      }
    });

  } catch (error) {
    console.error('Daily quest error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve daily quest'
    });
  }
});

// GET /api/quests/weekly - Get user's weekly quests
router.get('/weekly', authMiddleware.requireAuth, questLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    const weekStart = getMondayOfWeek();
    
    // Check if user already has weekly quests for this week
    let weeklyQuests = await questManager.getUserWeeklyQuests(userId, weekStart);
    
    if (weeklyQuests.length === 0) {
      // Assign 5 new random weekly quests specific to this user
      const selectedQuests = await selectWeeklyQuests(userId);

      if (selectedQuests.length < 5) {
        return res.status(500).json({
          return_code: 'INSUFFICIENT_QUESTS',
          message: 'Not enough quests available for weekly assignment'
        });
      }

      // Assign the quests
      const questIds = selectedQuests.map(q => q.id);
      await questManager.assignWeeklyQuests(userId, questIds, weekStart);

      // Get the full quest details
      weeklyQuests = await questManager.getUserWeeklyQuests(userId, weekStart);
    }

    // Check if user can reroll (hasn't rerolled this week)
    const canReroll = !(await questManager.hasUserRerolledToday(userId, 'weekly', weekStart));

    const questsWithRerollInfo = weeklyQuests.map(quest => ({
      assignment_id: quest.assignment_id,
      quest_id: quest.quest_id,
      title: quest.title,
      description: quest.description,
      category: quest.category_name,
      difficulty: quest.difficulty_level,
      points: quest.points,
      estimated_duration_minutes: quest.estimated_duration_minutes,
      assigned_date: quest.assigned_date,
      is_completed: quest.is_completed,
      completed_at: quest.completed_at,
      expires_at: quest.expires_at,
      can_reroll: canReroll
    }));

    res.json({
      return_code: 'SUCCESS',
      message: 'Weekly quests retrieved successfully',
      quests: questsWithRerollInfo,
      week_start: weekStart.toISOString().split('T')[0],
      can_reroll: canReroll
    });

  } catch (error) {
    console.error('Weekly quests error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve weekly quests'
    });
  }
});

// POST /api/quests/daily/reroll - Reroll daily quest
router.post('/daily/reroll', authMiddleware.requireAuth, questLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    
    // Check if user can reroll (hasn't rerolled today)
    const hasRerolled = await questManager.hasUserRerolledToday(userId, 'daily', today);
    if (hasRerolled) {
      return res.status(400).json({
        return_code: 'REROLL_LIMIT_EXCEEDED',
        message: 'You can only reroll your daily quest once per day'
      });
    }

    // Get current daily quest to exclude it
    const currentQuest = await questManager.getUserDailyQuest(userId, today);
    if (!currentQuest) {
      return res.status(404).json({
        return_code: 'NO_DAILY_QUEST',
        message: 'No daily quest found to reroll'
      });
    }

    if (currentQuest.is_completed) {
      return res.status(400).json({
        return_code: 'QUEST_ALREADY_COMPLETED',
        message: 'Cannot reroll a completed quest'
      });
    }

    // Get a new random quest (excluding current one) specific to this user
    const newQuest = await questManager.getRandomQuestByDifficultyForUser(userId, 'medium', [currentQuest.quest_id]);

    if (!newQuest) {
      return res.status(500).json({
        return_code: 'NO_ALTERNATIVE_QUEST',
        message: 'No alternative quest available for reroll'
      });
    }

    // Assign the new quest (this will create a second assignment for today)
    await questManager.assignDailyQuest(userId, newQuest.id, today);
    
    // Get the updated daily quest
    const updatedQuest = await questManager.getUserDailyQuest(userId, today);

    res.json({
      return_code: 'SUCCESS',
      message: 'Daily quest rerolled successfully',
      quest: {
        assignment_id: updatedQuest.assignment_id,
        quest_id: updatedQuest.quest_id,
        title: updatedQuest.title,
        description: updatedQuest.description,
        category: updatedQuest.category_name,
        difficulty: updatedQuest.difficulty_level,
        points: updatedQuest.points,
        estimated_duration_minutes: updatedQuest.estimated_duration_minutes,
        assigned_date: updatedQuest.assigned_date,
        is_completed: updatedQuest.is_completed,
        completed_at: updatedQuest.completed_at,
        expires_at: updatedQuest.expires_at,
        can_reroll: false // Can't reroll again
      }
    });

  } catch (error) {
    console.error('Daily quest reroll error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to reroll daily quest'
    });
  }
});

// POST /api/quests/weekly/reroll - Reroll weekly quests
router.post('/weekly/reroll', authMiddleware.requireAuth, questLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    const weekStart = getMondayOfWeek();

    // Check if user can reroll (hasn't rerolled this week)
    const hasRerolled = await questManager.hasUserRerolledToday(userId, 'weekly', weekStart);
    if (hasRerolled) {
      return res.status(400).json({
        return_code: 'REROLL_LIMIT_EXCEEDED',
        message: 'You can only reroll your weekly quests once per week'
      });
    }

    // Get current weekly quests to exclude them
    const currentQuests = await questManager.getUserWeeklyQuests(userId, weekStart);
    if (currentQuests.length === 0) {
      return res.status(404).json({
        return_code: 'NO_WEEKLY_QUESTS',
        message: 'No weekly quests found to reroll'
      });
    }

    // Check if any quest is completed
    const hasCompletedQuest = currentQuests.some(quest => quest.is_completed);
    if (hasCompletedQuest) {
      return res.status(400).json({
        return_code: 'QUEST_ALREADY_COMPLETED',
        message: 'Cannot reroll weekly quests when one or more are already completed'
      });
    }

    // Get current quest IDs to exclude
    const currentQuestIds = currentQuests.map(q => q.quest_id);

    // Select new weekly quests (excluding current ones) specific to this user
    const newQuests = await selectWeeklyQuests(userId, currentQuestIds);

    if (newQuests.length < 5) {
      return res.status(500).json({
        return_code: 'INSUFFICIENT_ALTERNATIVE_QUESTS',
        message: 'Not enough alternative quests available for reroll'
      });
    }

    // Assign the new quests (this will create new assignments for this week)
    const newQuestIds = newQuests.map(q => q.id);
    await questManager.assignWeeklyQuests(userId, newQuestIds, weekStart);

    // Get the updated weekly quests
    const updatedQuests = await questManager.getUserWeeklyQuests(userId, weekStart);

    const questsWithRerollInfo = updatedQuests.map(quest => ({
      assignment_id: quest.assignment_id,
      quest_id: quest.quest_id,
      title: quest.title,
      description: quest.description,
      category: quest.category_name,
      difficulty: quest.difficulty_level,
      points: quest.points,
      estimated_duration_minutes: quest.estimated_duration_minutes,
      assigned_date: quest.assigned_date,
      is_completed: quest.is_completed,
      completed_at: quest.completed_at,
      expires_at: quest.expires_at
    }));

    res.json({
      return_code: 'SUCCESS',
      message: 'Weekly quests rerolled successfully',
      quests: questsWithRerollInfo,
      week_start: weekStart.toISOString().split('T')[0],
      can_reroll: false // Can't reroll again this week
    });

  } catch (error) {
    console.error('Weekly quests reroll error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to reroll weekly quests'
    });
  }
});

// GET /api/quests/:questId - Get quest details by ID
router.get('/:questId', authMiddleware.requireAuth, questLimiter, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { questId } = req.params;

    // Get quest details
    const quest = await questManager.getQuestById(parseInt(questId));

    if (!quest) {
      return res.status(404).json({
        return_code: 'QUEST_NOT_FOUND',
        message: 'Quest not found'
      });
    }

    // Check if user has this quest assigned (daily or weekly)
    const today = new Date().toISOString().split('T')[0];
    const weekStart = new Date();
    const dayOfWeek = weekStart.getDay();
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    weekStart.setDate(weekStart.getDate() - daysToMonday);
    const weekStartStr = weekStart.toISOString().split('T')[0];

    // Check for daily assignment
    let assignment = null;
    const dailyAssignmentQuery = `
      SELECT id as assignment_id, assignment_type, is_completed, completed_at
      FROM user_quest_assignment
      WHERE user_id = $1 AND quest_id = $2 AND assignment_type = 'daily' AND assigned_date = $3
      ORDER BY created_at DESC
      LIMIT 1
    `;
    let result = await query(dailyAssignmentQuery, [userId, parseInt(questId), today]);

    if (result.rows.length === 0) {
      // Check for weekly assignment
      const weeklyAssignmentQuery = `
        SELECT id as assignment_id, assignment_type, is_completed, completed_at
        FROM user_quest_assignment
        WHERE user_id = $1 AND quest_id = $2 AND assignment_type = 'weekly' AND assigned_date = $3
        ORDER BY created_at DESC
        LIMIT 1
      `;
      result = await query(weeklyAssignmentQuery, [userId, parseInt(questId), weekStartStr]);
    }

    if (result.rows.length > 0) {
      assignment = result.rows[0];
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'Quest details retrieved successfully',
      quest: {
        id: quest.id,
        title: quest.title,
        description: quest.description,
        category: quest.category_name,
        difficulty: quest.difficulty_level,
        points: quest.points,
        estimated_duration_minutes: quest.estimated_duration_minutes,
        assignment: assignment
      }
    });

  } catch (error) {
    console.error('Quest details error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve quest details'
    });
  }
});

// POST /api/quests/complete - Complete a quest
router.post('/complete', authMiddleware.requireAuth, questLimiter, [
  body('assignment_id').isInt({ min: 1 }).withMessage('Valid assignment ID required'),
  body('completion_notes').optional().isString().isLength({ max: 500 }).withMessage('Completion notes must be 500 characters or less')
], handleValidationErrors, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { assignment_id, completion_notes } = req.body;

    // Complete the quest
    const result = await questManager.completeQuest(userId, assignment_id, completion_notes);

    res.json({
      return_code: 'SUCCESS',
      message: 'Quest completed successfully',
      completion: {
        assignment_id: assignment_id,
        quest_id: result.assignment.quest_id,
        assignment_type: result.assignment.assignment_type,
        points_earned: result.points_earned,
        completed_at: result.completion.completed_at
      }
    });

  } catch (error) {
    console.error('Quest completion error:', error);

    if (error.message === 'Quest assignment not found') {
      return res.status(404).json({
        return_code: 'ASSIGNMENT_NOT_FOUND',
        message: 'Quest assignment not found or does not belong to user'
      });
    }

    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to complete quest'
    });
  }
});

module.exports = router;
