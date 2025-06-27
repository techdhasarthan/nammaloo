import { storageUtils } from './storage';

const CACHE_KEY = 'recent_toilet_cache';
const MAX_RECENT_TOILETS = 20;

export const recentToiletCache = {
  listeners: new Set(),

  // Subscribe to cache updates
  subscribe(callback) {
    this.listeners.add(callback);
    // Immediately call with current data
    this.getRecentToilets().then(callback);
    return () => this.listeners.delete(callback);
  },

  // Notify all listeners of cache updates
  notifyListeners() {
    this.getRecentToilets().then(recentToilets => {
      this.listeners.forEach(callback => callback(recentToilets));
    });
  },

  // Add a toilet to recent views (only when user actually views toilet detail)
  async addRecentView(toilet) {
    try {
      const now = Date.now();
      const toiletId = toilet._id || toilet.id;
      
      if (!toiletId) {
        console.warn('⚠️ Cannot add toilet to recent views: missing ID');
        return;
      }

      const cache = await storageUtils.getItem(CACHE_KEY) || {};
      const existing = cache[toiletId];
      
      const entry = {
        toiletId,
        name: toilet.name || 'Public Toilet',
        address: toilet.address || 'Address not available',
        rating: toilet.rating,
        imageUrl: toilet.imageUrl,
        viewedAt: now,
        viewCount: (existing?.viewCount || 0) + 1
      };

      cache[toiletId] = entry;
      
      // Trim cache to maximum size
      await this.trimCache(cache);
      await storageUtils.setItem(CACHE_KEY, cache);
      this.notifyListeners();
      
      console.log(`👁️ Added toilet to recent views: ${entry.name} (view count: ${entry.viewCount})`);
    } catch (error) {
      console.error('❌ Error adding recent view:', error);
    }
  },

  // Get recent toilets sorted by most recent view
  async getRecentToilets() {
    try {
      const cache = await storageUtils.getItem(CACHE_KEY) || {};
      const entries = Object.values(cache);
      
      // Sort by most recent view
      entries.sort((a, b) => b.viewedAt - a.viewedAt);
      
      return entries;
    } catch (error) {
      console.error('❌ Error getting recent toilets:', error);
      return [];
    }
  },

  // Get most viewed toilets
  async getMostViewed() {
    try {
      const cache = await storageUtils.getItem(CACHE_KEY) || {};
      const entries = Object.values(cache);
      
      // Sort by view count
      entries.sort((a, b) => b.viewCount - a.viewCount);
      
      return entries.slice(0, 10); // Top 10 most viewed
    } catch (error) {
      console.error('❌ Error getting most viewed toilets:', error);
      return [];
    }
  },

  // Check if a toilet is in recent cache
  async isRecentToilet(toiletId) {
    try {
      const cache = await storageUtils.getItem(CACHE_KEY) || {};
      return !!cache[toiletId];
    } catch (error) {
      console.error('❌ Error checking recent toilet:', error);
      return false;
    }
  },

  // Remove a toilet from recent cache
  async removeRecentToilet(toiletId) {
    try {
      const cache = await storageUtils.getItem(CACHE_KEY) || {};
      if (cache[toiletId]) {
        delete cache[toiletId];
        await storageUtils.setItem(CACHE_KEY, cache);
        this.notifyListeners();
        console.log(`🗑️ Removed toilet from recent cache: ${toiletId}`);
      }
    } catch (error) {
      console.error('❌ Error removing recent toilet:', error);
    }
  },

  // Clear all recent toilets
  async clearRecentToilets() {
    try {
      await storageUtils.removeItem(CACHE_KEY);
      this.notifyListeners();
      console.log('🗑️ Cleared all recent toilets');
    } catch (error) {
      console.error('❌ Error clearing recent toilets:', error);
    }
  },

  // Trim cache to maximum size
  async trimCache(cache) {
    const entries = Object.values(cache);
    if (entries.length <= MAX_RECENT_TOILETS) {
      return cache;
    }

    // Sort by most recent and keep only the top entries
    entries.sort((a, b) => b.viewedAt - a.viewedAt);
    const toKeep = entries.slice(0, MAX_RECENT_TOILETS);
    
    // Rebuild cache with only entries to keep
    const trimmedCache = {};
    toKeep.forEach(entry => {
      trimmedCache[entry.toiletId] = entry;
    });
    
    console.log(`✂️ Trimmed recent toilet cache to ${Object.keys(trimmedCache).length} entries`);
    return trimmedCache;
  },

  // Get cache statistics
  async getStats() {
    try {
      const entries = await this.getRecentToilets();
      
      return {
        totalEntries: entries.length,
        totalViews: entries.reduce((sum, entry) => sum + entry.viewCount, 0),
        oldestEntry: entries.length > 0 ? new Date(Math.min(...entries.map(e => e.viewedAt))) : null,
        newestEntry: entries.length > 0 ? new Date(Math.max(...entries.map(e => e.viewedAt))) : null
      };
    } catch (error) {
      console.error('❌ Error getting cache stats:', error);
      return {
        totalEntries: 0,
        totalViews: 0,
        oldestEntry: null,
        newestEntry: null
      };
    }
  }
};