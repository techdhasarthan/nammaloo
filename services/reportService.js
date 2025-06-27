import api from './api';

export const reportService = {
  // Create a new report
  async createReport(reportData) {
    try {
      const response = await api.post('/reports', reportData);
      return response.data;
    } catch (error) {
      console.error('Error creating report:', error);
      throw error;
    }
  },

  // Get reports for a toilet
  async getReportsForToilet(toiletId) {
    try {
      const response = await api.get(`/reports/toilet/${toiletId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching reports:', error);
      throw error;
    }
  }
};