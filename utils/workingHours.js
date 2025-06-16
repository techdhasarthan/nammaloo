export const workingHoursUtils = {
  // Parse working hours from string
  parseWorkingHours(workingHours) {
    if (!workingHours) {
      return {
        isOpen24Hours: false,
        isClosed: true,
        currentStatus: 'unknown'
      };
    }

    const hoursLower = workingHours.toLowerCase().trim();
    
    // Check for 24-hour operations
    if (hoursLower.includes('24 hours') || 
        hoursLower.includes('24/7') || 
        hoursLower.includes('open 24 hours') ||
        hoursLower.includes('always open')) {
      return {
        isOpen24Hours: true,
        isClosed: false,
        currentStatus: 'open'
      };
    }
    
    // Check if explicitly closed
    if (hoursLower.includes('closed') && 
        !hoursLower.includes('never closed') &&
        !hoursLower.includes('not closed')) {
      return {
        isOpen24Hours: false,
        isClosed: true,
        currentStatus: 'closed'
      };
    }
    
    // For other cases, assume open during daytime hours
    const now = new Date();
    const currentHour = now.getHours();
    const isOpen = currentHour >= 6 && currentHour <= 22;
    
    return {
      isOpen24Hours: false,
      isClosed: false,
      currentStatus: isOpen ? 'open' : 'closed'
    };
  },

  // Format working hours for display
  formatWorkingHours(workingHours) {
    if (!workingHours) {
      return 'Hours not available';
    }

    const parsed = this.parseWorkingHours(workingHours);
    
    if (parsed.isOpen24Hours) {
      return 'Open 24 Hours';
    }
    
    if (parsed.isClosed) {
      return 'Closed';
    }
    
    return workingHours;
  },

  // Get status color for UI
  getStatusColor(workingHours) {
    const parsed = this.parseWorkingHours(workingHours);
    
    switch (parsed.currentStatus) {
      case 'open':
        return '#34C759'; // Green
      case 'closed':
        return '#FF3B30'; // Red
      default:
        return '#FF9500'; // Orange
    }
  },

  // Get status text for UI
  getStatusText(workingHours) {
    const parsed = this.parseWorkingHours(workingHours);
    
    switch (parsed.currentStatus) {
      case 'open':
        return parsed.isOpen24Hours ? 'Open 24/7' : 'Open Now';
      case 'closed':
        return 'Closed';
      default:
        return 'Hours Unknown';
    }
  },

  // Check if toilet is currently open
  isCurrentlyOpen(workingHours) {
    if (!workingHours) {
      return true; // If no hours data, assume it might be open
    }

    const parsed = this.parseWorkingHours(workingHours);
    return parsed.currentStatus === 'open';
  }
};