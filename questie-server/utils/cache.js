// Simple in-memory cache for frequently accessed data
// This will significantly improve performance by reducing database queries

class SimpleCache {
  constructor() {
    this.cache = new Map();
    this.ttl = new Map(); // Time to live for each key
    this.defaultTTL = 5 * 60 * 1000; // 5 minutes default TTL
    
    // Clean up expired entries every minute
    setInterval(() => {
      this.cleanup();
    }, 60 * 1000);
  }

  // Set a value in cache with optional TTL
  set(key, value, ttlMs = this.defaultTTL) {
    this.cache.set(key, value);
    this.ttl.set(key, Date.now() + ttlMs);
    console.log(`📦 Cache SET: ${key} (TTL: ${ttlMs}ms)`);
  }

  // Get a value from cache
  get(key) {
    const expiry = this.ttl.get(key);
    
    if (!expiry || Date.now() > expiry) {
      // Expired or doesn't exist
      this.delete(key);
      console.log(`📦 Cache MISS: ${key}`);
      return null;
    }
    
    const value = this.cache.get(key);
    console.log(`📦 Cache HIT: ${key}`);
    return value;
  }

  // Delete a key from cache
  delete(key) {
    this.cache.delete(key);
    this.ttl.delete(key);
    console.log(`📦 Cache DELETE: ${key}`);
  }

  // Clear all cache
  clear() {
    this.cache.clear();
    this.ttl.clear();
    console.log('📦 Cache CLEARED');
  }

  // Clean up expired entries
  cleanup() {
    const now = Date.now();
    let cleanedCount = 0;
    
    for (const [key, expiry] of this.ttl.entries()) {
      if (now > expiry) {
        this.cache.delete(key);
        this.ttl.delete(key);
        cleanedCount++;
      }
    }
    
    if (cleanedCount > 0) {
      console.log(`📦 Cache cleanup: removed ${cleanedCount} expired entries`);
    }
  }

  // Get cache stats
  getStats() {
    return {
      size: this.cache.size,
      keys: Array.from(this.cache.keys())
    };
  }

  // Cache key generators for common data
  static keys = {
    userStats: (userId) => `user_stats_${userId}`,
    userBadges: (userId) => `user_badges_${userId}`,
    dailyQuest: (userId, date) => `daily_quest_${userId}_${date}`,
    weeklyQuests: (userId, weekStart) => `weekly_quests_${userId}_${weekStart}`,
    questDetails: (questId) => `quest_details_${questId}`,
    userBadgeCount: (userId) => `user_badge_count_${userId}`,
    questHistory: (userId, filter, limit) => `quest_history_${userId}_${filter}_${limit}`,
    canReroll: (userId, type, date) => `can_reroll_${userId}_${type}_${date}`
  };
}

// Create singleton instance
const cache = new SimpleCache();

// Helper functions for common cache operations
const cacheHelpers = {
  // Cache user stats with 2 minute TTL (frequently updated)
  setUserStats: (userId, stats) => {
    cache.set(cache.constructor.keys.userStats(userId), stats, 2 * 60 * 1000);
  },
  
  getUserStats: (userId) => {
    return cache.get(cache.constructor.keys.userStats(userId));
  },
  
  clearUserStats: (userId) => {
    cache.delete(cache.constructor.keys.userStats(userId));
  },

  // Cache user badges with 5 minute TTL
  setUserBadges: (userId, badges) => {
    cache.set(cache.constructor.keys.userBadges(userId), badges, 5 * 60 * 1000);
  },
  
  getUserBadges: (userId) => {
    return cache.get(cache.constructor.keys.userBadges(userId));
  },
  
  clearUserBadges: (userId) => {
    cache.delete(cache.constructor.keys.userBadges(userId));
  },

  // Cache daily quest with 10 minute TTL
  setDailyQuest: (userId, date, quest) => {
    cache.set(cache.constructor.keys.dailyQuest(userId, date), quest, 10 * 60 * 1000);
  },
  
  getDailyQuest: (userId, date) => {
    return cache.get(cache.constructor.keys.dailyQuest(userId, date));
  },
  
  clearDailyQuest: (userId, date) => {
    cache.delete(cache.constructor.keys.dailyQuest(userId, date));
  },

  // Cache weekly quests with 10 minute TTL
  setWeeklyQuests: (userId, weekStart, quests) => {
    cache.set(cache.constructor.keys.weeklyQuests(userId, weekStart), quests, 10 * 60 * 1000);
  },
  
  getWeeklyQuests: (userId, weekStart) => {
    return cache.get(cache.constructor.keys.weeklyQuests(userId, weekStart));
  },
  
  clearWeeklyQuests: (userId, weekStart) => {
    cache.delete(cache.constructor.keys.weeklyQuests(userId, weekStart));
  },

  // Cache quest details with 30 minute TTL (rarely changes)
  setQuestDetails: (questId, quest) => {
    cache.set(cache.constructor.keys.questDetails(questId), quest, 30 * 60 * 1000);
  },
  
  getQuestDetails: (questId) => {
    return cache.get(cache.constructor.keys.questDetails(questId));
  },

  // Clear user-related cache when user completes a quest
  clearUserCache: (userId) => {
    const dateStr = new Date().toISOString().split('T')[0];
    const weekStart = getMonday(new Date()).toISOString().split('T')[0];
    
    cacheHelpers.clearUserStats(userId);
    cacheHelpers.clearUserBadges(userId);
    cacheHelpers.clearDailyQuest(userId, dateStr);
    cacheHelpers.clearWeeklyQuests(userId, weekStart);
    
    console.log(`📦 Cleared all cache for user ${userId}`);
  }
};

// Helper function to get Monday of current week
function getMonday(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  return new Date(d.setDate(diff));
}

module.exports = {
  cache,
  cacheHelpers
};
