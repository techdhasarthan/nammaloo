const express = require('express');
const router = express.Router();
const Review = require('../models/Review');
const Toilet = require('../models/Toilet');

// Get reviews for a toilet
router.get('/toilet/:toiletId', async (req, res) => {
  try {
    const reviews = await Review.find({ toiletId: req.params.toiletId })
      .populate('userId', 'name avatarUrl')
      .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({ error: 'Failed to fetch reviews' });
  }
});

// Create a new review
router.post('/', async (req, res) => {
  try {
    const { toiletId, userId, rating, reviewText, images } = req.body;

    // Validate required fields
    if (!toiletId || !userId || !rating) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if toilet exists
    const toilet = await Toilet.findById(toiletId);
    if (!toilet) {
      return res.status(404).json({ error: 'Toilet not found' });
    }

    // Create review
    const review = new Review({
      toiletId,
      userId,
      rating,
      reviewText,
      images: images || []
    });

    await review.save();

    // Update toilet rating and review count
    await updateToiletStats(toiletId);

    // Populate user data before returning
    await review.populate('userId', 'name avatarUrl');

    res.status(201).json(review);
  } catch (error) {
    console.error('Error creating review:', error);
    res.status(400).json({ error: 'Failed to create review' });
  }
});

// Update a review
router.put('/:id', async (req, res) => {
  try {
    const { rating, reviewText, images } = req.body;

    const review = await Review.findByIdAndUpdate(
      req.params.id,
      { rating, reviewText, images },
      { new: true, runValidators: true }
    ).populate('userId', 'name avatarUrl');

    if (!review) {
      return res.status(404).json({ error: 'Review not found' });
    }

    // Update toilet stats
    await updateToiletStats(review.toiletId);

    res.json(review);
  } catch (error) {
    console.error('Error updating review:', error);
    res.status(400).json({ error: 'Failed to update review' });
  }
});

// Delete a review
router.delete('/:id', async (req, res) => {
  try {
    const review = await Review.findByIdAndDelete(req.params.id);

    if (!review) {
      return res.status(404).json({ error: 'Review not found' });
    }

    // Update toilet stats
    await updateToiletStats(review.toiletId);

    res.json({ message: 'Review deleted successfully' });
  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({ error: 'Failed to delete review' });
  }
});

// Helper function to update toilet statistics
async function updateToiletStats(toiletId) {
  try {
    const reviews = await Review.find({ toiletId });
    
    const reviewCount = reviews.length;
    const averageRating = reviewCount > 0 
      ? reviews.reduce((sum, review) => sum + review.rating, 0) / reviewCount 
      : 0;

    await Toilet.findByIdAndUpdate(toiletId, {
      reviewCount,
      rating: Math.round(averageRating * 10) / 10 // Round to 1 decimal place
    });
  } catch (error) {
    console.error('Error updating toilet stats:', error);
  }
}

module.exports = router;