import * as Location from 'expo-location';

export const locationUtils = {
  // Get user's current location
  async getCurrentLocation() {
    try {
      console.log('📍 Requesting location permission...');
      
      // Check if location services are enabled
      const enabled = await Location.hasServicesEnabledAsync();
      if (!enabled) {
        console.log('❌ Location services are disabled');
        return null;
      }
      
      // Request permission
      const { status } = await Location.requestForegroundPermissionsAsync();
      
      if (status !== 'granted') {
        console.log('❌ Location permission denied, status:', status);
        return null;
      }

      console.log('✅ Location permission granted, getting position...');
      
      // Get current position
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
        timeout: 15000,
        maximumAge: 60000,
      });

      const locationData = {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        accuracy: location.coords.accuracy,
      };

      console.log('✅ Location obtained:', {
        lat: locationData.latitude.toFixed(6),
        lng: locationData.longitude.toFixed(6),
        accuracy: locationData.accuracy + 'm'
      });
      
      return locationData;
    } catch (error) {
      console.error('❌ Error getting location:', error);
      return null;
    }
  },

  // Calculate distance between two points using Haversine formula
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    
    return distance;
  },

  // Format distance for display
  formatDistance(distance) {
    if (distance === undefined || distance === null || isNaN(distance)) {
      return 'Unknown';
    }
    
    if (distance >= 999) {
      return 'Unknown';
    }
    
    if (distance < 1) {
      const meters = Math.round(distance * 1000);
      return `${meters}m`;
    } else {
      return `${distance.toFixed(1)}km`;
    }
  },

  // Validate coordinates
  isValidCoordinate(lat, lng) {
    return (
      typeof lat === 'number' &&
      typeof lng === 'number' &&
      !isNaN(lat) &&
      !isNaN(lng) &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180 &&
      !(lat === 0 && lng === 0)
    );
  }
};