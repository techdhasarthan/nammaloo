import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Star, DollarSign, Users, User, Baby, Droplets, Chrome as Home, Square, Package, Armchair as Wheelchair } from 'lucide-react-native';
import { featuresUtils } from '../utils/features';

export default function FeatureBadges({ toilet, maxBadges = 4, size = 'medium', showAll = false }) {
  const allBadges = featuresUtils.getFeatureBadges(toilet);
  const badges = showAll ? allBadges : allBadges.slice(0, maxBadges);
  
  if (badges.length === 0) {
    return (
      <View style={[styles.container, sizeStyles[size].container]}>
        <View style={[styles.badge, sizeStyles[size].badge, { backgroundColor: '#f0f0f0' }]}>
          <Text style={[styles.badgeText, sizeStyles[size].text, { color: '#999' }]}>
            No features listed
          </Text>
        </View>
      </View>
    );
  }
  
  const getIconComponent = (iconName, color, iconSize) => {
    const iconProps = { size: iconSize, color };
    
    switch (iconName) {
      case 'star': return <Star {...iconProps} fill={color} />;
      case 'dollar-sign': return <DollarSign {...iconProps} />;
      case 'wheelchair': return <Wheelchair {...iconProps} />;
      case 'users': return <Users {...iconProps} />;
      case 'user': return <User {...iconProps} />;
      case 'baby': return <Baby {...iconProps} />;
      case 'droplets': return <Droplets {...iconProps} />;
      case 'home': return <Home {...iconProps} />;
      case 'square': return <Square {...iconProps} />;
      case 'package': return <Package {...iconProps} />;
      default: return <Star {...iconProps} />;
    }
  };
  
  const sizeStyles = {
    small: {
      container: styles.smallContainer,
      badge: styles.smallBadge,
      text: styles.smallText,
      iconSize: 10
    },
    medium: {
      container: styles.mediumContainer,
      badge: styles.mediumBadge,
      text: styles.mediumText,
      iconSize: 12
    },
    large: {
      container: styles.largeContainer,
      badge: styles.largeBadge,
      text: styles.largeText,
      iconSize: 14
    }
  };
  
  const currentSize = sizeStyles[size];
  
  return (
    <View style={[styles.container, currentSize.container]}>
      {badges.map((badge, index) => (
        <View 
          key={`${badge.id}-${index}`} 
          style={[
            styles.badge, 
            currentSize.badge,
            { backgroundColor: badge.backgroundColor }
          ]}
        >
          {getIconComponent(badge.icon, badge.color, currentSize.iconSize)}
          <Text style={[styles.badgeText, currentSize.text, { color: badge.color }]}>
            {badge.label}
          </Text>
        </View>
      ))}
      
      {!showAll && allBadges.length > maxBadges && (
        <View style={[styles.badge, currentSize.badge, { backgroundColor: '#e0e0e0' }]}>
          <Text style={[styles.badgeText, currentSize.text, { color: '#666' }]}>
            +{allBadges.length - maxBadges}
          </Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 12,
    marginRight: 6,
    marginBottom: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  badgeText: {
    fontWeight: '600',
    marginLeft: 4,
  },
  
  // Small size
  smallContainer: {
    gap: 4,
  },
  smallBadge: {
    paddingHorizontal: 6,
    paddingVertical: 3,
    borderRadius: 8,
  },
  smallText: {
    fontSize: 9,
  },
  
  // Medium size
  mediumContainer: {
    gap: 6,
  },
  mediumBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
  },
  mediumText: {
    fontSize: 11,
  },
  
  // Large size
  largeContainer: {
    gap: 8,
  },
  largeBadge: {
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 12,
  },
  largeText: {
    fontSize: 12,
  },
});