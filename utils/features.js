export const featuresUtils = {
  // Parse toilet features from data
  parseToiletFeatures(toilet) {
    return {
      paid: toilet.isPaid === 'Yes',
      wheelchair: toilet.wheelchair === 'Yes',
      gender: this.parseGender(toilet.gender),
      baby: toilet.baby === 'Yes',
      shower: toilet.shower === 'Yes',
      toiletType: this.parseToiletType(toilet.westernOrIndian),
      napkinVendor: toilet.napkinVendor === 'Yes'
    };
  },

  // Parse gender type
  parseGender(gender) {
    if (!gender) return 'unisex';
    const g = gender.toLowerCase().trim();
    
    if (g === 'male' || g === 'men' || g === 'gents' || g === 'man') return 'male';
    if (g === 'female' || g === 'women' || g === 'ladies' || g === 'woman') return 'female';
    if (g === 'separate' || g === 'both genders' || g === 'male and female') return 'separate';
    if (g === 'unisex' || g === 'mixed' || g === 'all' || g === 'common') return 'unisex';
    
    return 'unisex';
  },

  // Parse toilet type
  parseToiletType(type) {
    if (!type) return 'western';
    const t = type.toLowerCase().trim();
    
    if (t === 'both' || t.includes('both') || (t.includes('western') && t.includes('indian'))) return 'both';
    if (t === 'indian' || t === 'squat' || t.includes('indian')) return 'indian';
    if (t === 'western' || t === 'sitting' || t.includes('western')) return 'western';
    
    return 'western';
  },

  // Get feature badges for display
  getFeatureBadges(toilet) {
    const badges = [];

    // Payment status
    if (toilet.isPaid === 'No' || toilet.isPaid === 'Free' || !toilet.isPaid) {
      badges.push({
        id: 'free',
        label: 'Free',
        icon: 'star',
        color: '#FFFFFF',
        backgroundColor: '#34C759'
      });
    } else if (toilet.isPaid === 'Yes') {
      badges.push({
        id: 'paid',
        label: 'Paid',
        icon: 'dollar-sign',
        color: '#FFFFFF',
        backgroundColor: '#FF9500'
      });
    }

    // Wheelchair accessibility
    if (toilet.wheelchair === 'Yes') {
      badges.push({
        id: 'wheelchair',
        label: 'Accessible',
        icon: 'wheelchair',
        color: '#FFFFFF',
        backgroundColor: '#007AFF'
      });
    }

    // Gender facilities
    const genderType = this.parseGender(toilet.gender);
    switch (genderType) {
      case 'male':
        badges.push({
          id: 'gender-male',
          label: 'Men Only',
          icon: 'user',
          color: '#FFFFFF',
          backgroundColor: '#2196F3'
        });
        break;
      case 'female':
        badges.push({
          id: 'gender-female',
          label: 'Women Only',
          icon: 'user',
          color: '#FFFFFF',
          backgroundColor: '#E91E63'
        });
        break;
      case 'separate':
        badges.push({
          id: 'gender-separate',
          label: 'Separate',
          icon: 'users',
          color: '#FFFFFF',
          backgroundColor: '#8E44AD'
        });
        break;
      case 'unisex':
        badges.push({
          id: 'gender-unisex',
          label: 'Unisex',
          icon: 'user',
          color: '#FFFFFF',
          backgroundColor: '#6C757D'
        });
        break;
    }

    // Baby changing
    if (toilet.baby === 'Yes') {
      badges.push({
        id: 'baby',
        label: 'Baby Care',
        icon: 'baby',
        color: '#FFFFFF',
        backgroundColor: '#E91E63'
      });
    }

    // Shower facilities
    if (toilet.shower === 'Yes') {
      badges.push({
        id: 'shower',
        label: 'Shower',
        icon: 'droplets',
        color: '#FFFFFF',
        backgroundColor: '#00BCD4'
      });
    }

    // Napkin vendor
    if (toilet.napkinVendor === 'Yes') {
      badges.push({
        id: 'napkin-vendor',
        label: 'Napkin Vendor',
        icon: 'package',
        color: '#FFFFFF',
        backgroundColor: '#9C27B0'
      });
    }

    // Toilet type
    const toiletType = this.parseToiletType(toilet.westernOrIndian);
    switch (toiletType) {
      case 'western':
        badges.push({
          id: 'western',
          label: 'Western',
          icon: 'home',
          color: '#FFFFFF',
          backgroundColor: '#FF6B35'
        });
        break;
      case 'indian':
        badges.push({
          id: 'indian',
          label: 'Indian',
          icon: 'square',
          color: '#FFFFFF',
          backgroundColor: '#795548'
        });
        break;
      case 'both':
        badges.push({
          id: 'western-type',
          label: 'Western',
          icon: 'home',
          color: '#FFFFFF',
          backgroundColor: '#FF6B35'
        });
        badges.push({
          id: 'indian-type',
          label: 'Indian',
          icon: 'square',
          color: '#FFFFFF',
          backgroundColor: '#795548'
        });
        break;
    }

    return badges;
  }
};