const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  toiletId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Toilet',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  reviewText: {
    type: String,
    trim: true,
    maxlength: 1000
  },
  images: [{
    type: String // URLs to review images
  }]
}, {
  timestamps: true
});

// Index for efficient queries
reviewSchema.index({ toiletId: 1, createdAt: -1 });
reviewSchema.index({ userId: 1 });
reviewSchema.index({ rating: 1 });

module.exports = mongoose.model('Review', reviewSchema);