import api from './api';

export const toiletService = {
  // Get all toilets with optional filters
  async getToilets(filters = {}) {
    try {
      const response = await api.get('/toilets', { params: filters });
      return response.data;
    } catch (error) {
      console.error('Error fetching toilets:', error);
      throw error;
    }
  },

  // Get toilet by ID
  async getToiletById(id) {
    try {
      const response = await api.get(`/toilets/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching toilet:', error);
      throw error;
    }
  },

  // Get toilets near location
  async getNearbyToilets(latitude, longitude, radius = 10) {
    try {
      const response = await api.get(`/toilets/near/${latitude}/${longitude}`, {
        params: { radius }
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching nearby toilets:', error);
      throw error;
    }
  },

  // Get top rated toilets
  async getTopRatedToilets(limit = 10) {
    try {
      const response = await api.get(`/toilets/top-rated/${limit}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching top rated toilets:', error);
      throw error;
    }
  },

  // Search toilets
  async searchToilets(query, filters = {}) {
    try {
      const params = { search: query, ...filters };
      const response = await api.get('/toilets', { params });
      return response.data;
    } catch (error) {
      console.error('Error searching toilets:', error);
      throw error;
    }
  }
};