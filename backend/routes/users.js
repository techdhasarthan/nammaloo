const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Register user
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Create user
    const user = new User({ name, email, password });
    await user.save();

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      user,
      token
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(400).json({ error: 'Failed to register user' });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      user,
      token
    });
  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

// Create anonymous user
router.post('/anonymous', async (req, res) => {
  try {
    const anonymousUser = new User({
      name: 'Anonymous User',
      email: `anonymous_${Date.now()}@temp.com`,
      password: 'temporary_password',
      isAnonymous: true
    });

    await anonymousUser.save();

    res.status(201).json(anonymousUser);
  } catch (error) {
    console.error('Error creating anonymous user:', error);
    res.status(400).json({ error: 'Failed to create anonymous user' });
  }
});

// Get user profile
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Update user profile
router.put('/:id', async (req, res) => {
  try {
    const { name, bio, avatarUrl, preferences } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { name, bio, avatarUrl, preferences },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(400).json({ error: 'Failed to update user' });
  }
});

// Save toilet
router.post('/:id/save-toilet', async (req, res) => {
  try {
    const { toiletId, notes } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if toilet is already saved
    const existingSave = user.savedToilets.find(
      save => save.toiletId.toString() === toiletId
    );

    if (existingSave) {
      return res.status(400).json({ error: 'Toilet already saved' });
    }

    user.savedToilets.push({
      toiletId,
      notes: notes || '',
      savedAt: new Date()
    });

    await user.save();
    res.json({ message: 'Toilet saved successfully' });
  } catch (error) {
    console.error('Error saving toilet:', error);
    res.status(400).json({ error: 'Failed to save toilet' });
  }
});

// Unsave toilet
router.delete('/:id/save-toilet/:toiletId', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.savedToilets = user.savedToilets.filter(
      save => save.toiletId.toString() !== req.params.toiletId
    );

    await user.save();
    res.json({ message: 'Toilet unsaved successfully' });
  } catch (error) {
    console.error('Error unsaving toilet:', error);
    res.status(400).json({ error: 'Failed to unsave toilet' });
  }
});

// Get saved toilets
router.get('/:id/saved-toilets', async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('savedToilets.toiletId');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user.savedToilets);
  } catch (error) {
    console.error('Error fetching saved toilets:', error);
    res.status(500).json({ error: 'Failed to fetch saved toilets' });
  }
});

module.exports = router;