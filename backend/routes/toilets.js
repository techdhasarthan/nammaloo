const express = require('express');
const router = express.Router();
const Toilet = require('../models/Toilet');

// Get all toilets with optional filtering
router.get('/', async (req, res) => {
  try {
    const {
      search,
      city,
      rating,
      isPaid,
      wheelchair,
      gender,
      baby,
      shower,
      napkinVendor,
      limit = 50,
      page = 1,
      sortBy = 'rating',
      sortOrder = 'desc'
    } = req.query;

    // Build query
    let query = {};
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { address: { $regex: search, $options: 'i' } },
        { city: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (city) query.city = { $regex: city, $options: 'i' };
    if (rating) query.rating = { $gte: parseFloat(rating) };
    if (isPaid && isPaid !== 'Unknown') query.isPaid = isPaid;
    if (wheelchair && wheelchair !== 'Unknown') query.wheelchair = wheelchair;
    if (gender && gender !== 'Unknown') query.gender = gender;
    if (baby && baby !== 'Unknown') query.baby = baby;
    if (shower && shower !== 'Unknown') query.shower = shower;
    if (napkinVendor && napkinVendor !== 'Unknown') query.napkinVendor = napkinVendor;

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const toilets = await Toilet.find(query)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Toilet.countDocuments(query);

    res.json({
      toilets,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching toilets:', error);
    res.status(500).json({ error: 'Failed to fetch toilets' });
  }
});

// Get toilet by ID
router.get('/:id', async (req, res) => {
  try {
    const toilet = await Toilet.findById(req.params.id);
    if (!toilet) {
      return res.status(404).json({ error: 'Toilet not found' });
    }
    res.json(toilet);
  } catch (error) {
    console.error('Error fetching toilet:', error);
    res.status(500).json({ error: 'Failed to fetch toilet' });
  }
});

// Get toilets near location
router.get('/near/:lat/:lng', async (req, res) => {
  try {
    const { lat, lng } = req.params;
    const { radius = 10 } = req.query; // radius in km

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }

    // Convert radius from km to radians (divide by earth radius in km)
    const radiusInRadians = parseFloat(radius) / 6371;

    const toilets = await Toilet.find({
      latitude: {
        $gte: latitude - radiusInRadians * (180 / Math.PI),
        $lte: latitude + radiusInRadians * (180 / Math.PI)
      },
      longitude: {
        $gte: longitude - radiusInRadians * (180 / Math.PI) / Math.cos(latitude * Math.PI / 180),
        $lte: longitude + radiusInRadians * (180 / Math.PI) / Math.cos(latitude * Math.PI / 180)
      }
    }).sort({ rating: -1 });

    // Calculate actual distances and sort by distance
    const toiletsWithDistance = toilets.map(toilet => {
      const distance = calculateDistance(latitude, longitude, toilet.latitude, toilet.longitude);
      return {
        ...toilet.toObject(),
        distance: distance,
        distanceText: formatDistance(distance)
      };
    }).filter(toilet => toilet.distance <= parseFloat(radius))
      .sort((a, b) => a.distance - b.distance);

    res.json(toiletsWithDistance);
  } catch (error) {
    console.error('Error fetching nearby toilets:', error);
    res.status(500).json({ error: 'Failed to fetch nearby toilets' });
  }
});

// Get top rated toilets
router.get('/top-rated/:limit?', async (req, res) => {
  try {
    const limit = parseInt(req.params.limit) || 10;
    
    const toilets = await Toilet.find({ rating: { $gte: 4.0 } })
      .sort({ rating: -1, reviewCount: -1 })
      .limit(limit);

    res.json(toilets);
  } catch (error) {
    console.error('Error fetching top rated toilets:', error);
    res.status(500).json({ error: 'Failed to fetch top rated toilets' });
  }
});

// Create new toilet (admin only - you might want to add auth middleware)
router.post('/', async (req, res) => {
  try {
    const toilet = new Toilet(req.body);
    await toilet.save();
    res.status(201).json(toilet);
  } catch (error) {
    console.error('Error creating toilet:', error);
    res.status(400).json({ error: 'Failed to create toilet' });
  }
});

// Update toilet (admin only - you might want to add auth middleware)
router.put('/:id', async (req, res) => {
  try {
    const toilet = await Toilet.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!toilet) {
      return res.status(404).json({ error: 'Toilet not found' });
    }
    
    res.json(toilet);
  } catch (error) {
    console.error('Error updating toilet:', error);
    res.status(400).json({ error: 'Failed to update toilet' });
  }
});

// Helper function to calculate distance between two points
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Helper function to format distance
function formatDistance(distance) {
  if (distance < 1) {
    return `${Math.round(distance * 1000)}m`;
  }
  return `${distance.toFixed(1)}km`;
}

module.exports = router;