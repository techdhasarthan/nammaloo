import api from './api';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const userService = {
  // Register user
  async register(userData) {
    try {
      const response = await api.post('/users/register', userData);
      const { user, token } = response.data;
      
      // Store token and user data
      await AsyncStorage.setItem('authToken', token);
      await AsyncStorage.setItem('currentUser', JSON.stringify(user));
      
      return { user, token };
    } catch (error) {
      console.error('Error registering user:', error);
      throw error;
    }
  },

  // Login user
  async login(credentials) {
    try {
      const response = await api.post('/users/login', credentials);
      const { user, token } = response.data;
      
      // Store token and user data
      await AsyncStorage.setItem('authToken', token);
      await AsyncStorage.setItem('currentUser', JSON.stringify(user));
      
      return { user, token };
    } catch (error) {
      console.error('Error logging in user:', error);
      throw error;
    }
  },

  // Create anonymous user
  async createAnonymousUser() {
    try {
      const response = await api.post('/users/anonymous');
      const user = response.data;
      
      // Store anonymous user data
      await AsyncStorage.setItem('currentUser', JSON.stringify(user));
      
      return user;
    } catch (error) {
      console.error('Error creating anonymous user:', error);
      throw error;
    }
  },

  // Get user profile
  async getUserProfile(userId) {
    try {
      const response = await api.get(`/users/${userId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      throw error;
    }
  },

  // Update user profile
  async updateUserProfile(userId, userData) {
    try {
      const response = await api.put(`/users/${userId}`, userData);
      const user = response.data;
      
      // Update stored user data
      await AsyncStorage.setItem('currentUser', JSON.stringify(user));
      
      return user;
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  },

  // Save toilet
  async saveToilet(userId, toiletId, notes) {
    try {
      await api.post(`/users/${userId}/save-toilet`, { toiletId, notes });
      return true;
    } catch (error) {
      console.error('Error saving toilet:', error);
      throw error;
    }
  },

  // Unsave toilet
  async unsaveToilet(userId, toiletId) {
    try {
      await api.delete(`/users/${userId}/save-toilet/${toiletId}`);
      return true;
    } catch (error) {
      console.error('Error unsaving toilet:', error);
      throw error;
    }
  },

  // Get saved toilets
  async getSavedToilets(userId) {
    try {
      const response = await api.get(`/users/${userId}/saved-toilets`);
      return response.data;
    } catch (error) {
      console.error('Error fetching saved toilets:', error);
      throw error;
    }
  },

  // Logout
  async logout() {
    try {
      await AsyncStorage.removeItem('authToken');
      await AsyncStorage.removeItem('currentUser');
      return true;
    } catch (error) {
      console.error('Error logging out:', error);
      throw error;
    }
  },

  // Get current user from storage
  async getCurrentUser() {
    try {
      const userString = await AsyncStorage.getItem('currentUser');
      return userString ? JSON.parse(userString) : null;
    } catch (error) {
      console.error('Error getting current user:', error);
      return null;
    }
  },

  // Check if user is authenticated
  async isAuthenticated() {
    try {
      const token = await AsyncStorage.getItem('authToken');
      return !!token;
    } catch (error) {
      console.error('Error checking authentication:', error);
      return false;
    }
  }
};