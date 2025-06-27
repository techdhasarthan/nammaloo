import api from './api';

export const reviewService = {
  // Get reviews for a toilet
  async getReviewsForToilet(toiletId) {
    try {
      const response = await api.get(`/reviews/toilet/${toiletId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching reviews:', error);
      throw error;
    }
  },

  // Create a new review
  async createReview(reviewData) {
    try {
      const response = await api.post('/reviews', reviewData);
      return response.data;
    } catch (error) {
      console.error('Error creating review:', error);
      throw error;
    }
  },

  // Update a review
  async updateReview(reviewId, reviewData) {
    try {
      const response = await api.put(`/reviews/${reviewId}`, reviewData);
      return response.data;
    } catch (error) {
      console.error('Error updating review:', error);
      throw error;
    }
  },

  // Delete a review
  async deleteReview(reviewId) {
    try {
      await api.delete(`/reviews/${reviewId}`);
      return true;
    } catch (error) {
      console.error('Error deleting review:', error);
      throw error;
    }
  }
};