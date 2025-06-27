final List<Map<String, dynamic>> mockToilets = [
  {
    'name': 'Phoenix MarketCity Mall Restroom',
    'address': 'Whitefield Main Road, Mahadevapura, Bangalore',
    'rating': 4.5,
    'reviews': 127,
    'distance': '2.3 km',
    'image_url':
        'https://images.pexels.com/photos/6585757/pexels-photo-6585757.jpeg?auto=compress&cs=tinysrgb&w=400',
    'status': 'open',
    'features': ['Accessible', 'Sanitized', 'Family Friendly'],
    'latitude': 12.9908,
    'longitude': 77.6974,
    'phone': '+918088882222',
  },
  {
    'name': 'Cubbon Park Public Toilet',
    'address': 'Cubbon Park, Kasturba Road, Bangalore',
    'rating': 4.2,
    'reviews': 89,
    'distance': '1.8 km',
    'image_url':
        'https://images.pexels.com/photos/6585756/pexels-photo-6585756.jpeg?auto=compress&cs=tinysrgb&w=400',
    'status': 'open',
    'features': ['Accessible', 'Nature Nearby'],
    'latitude': 12.9763,
    'longitude': 77.5929,
    'phone': '+918088882222',
  },
  {
    'name': 'UB City Mall Premium Restroom',
    'address': 'UB City Mall, Vittal Mallya Road, Bangalore',
    'rating': 4.8,
    'reviews': 156,
    'distance': '1.2 km',
    'image_url':
        'https://images.pexels.com/photos/6585759/pexels-photo-6585759.jpeg?auto=compress&cs=tinysrgb&w=400',
    'status': 'open',
    'features': ['Luxurious', 'Air Conditioned', 'Fragrance Dispensers'],
    'latitude': 12.9716,
    'longitude': 77.5951,
    'phone': '+918088882222',
  },
  {
    'name': 'Bangalore Railway Station Restroom',
    'address': 'Kempegowda Railway Station, Bangalore',
    'rating': 3.8,
    'reviews': 234,
    'distance': '3.1 km',
    'image_url':
        'https://images.pexels.com/photos/6585758/pexels-photo-6585758.jpeg?auto=compress&cs=tinysrgb&w=400',
    'status': 'open',
    'features': ['High Traffic', 'Basic Utilities'],
    'latitude': 12.9778,
    'longitude': 77.5713,
    'phone': '+918088882222',
  },
  {
    'name': 'Orion Mall Restroom',
    'address': 'Dr. Rajkumar Road, Rajajinagar, Bangalore',
    'rating': 4.6,
    'reviews': 98,
    'distance': '4.0 km',
    'image_url':
        'https://images.pexels.com/photos/6585760/pexels-photo-6585760.jpeg?auto=compress&cs=tinysrgb&w=400',
    'status': 'closed',
    'features': ['Clean', 'Premium Hygiene'],
    'latitude': 13.0096,
    'longitude': 77.5536,
    'phone': '+918088882222',
  },
];

final List<Map<String, dynamic>> topRatedToilets = mockToilets
    .where((t) => (t['rating'] ?? 0) >= 4.5)
    .toList();

final List<Map<String, dynamic>> openNowToilets = mockToilets
    .where((t) => (t['status'] ?? '').toLowerCase() == 'open')
    .toList();
