const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
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
  issueText: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  status: {
    type: String,
    enum: ['PENDING', 'REVIEWED', 'RESOLVED', 'DISMISSED'],
    default: 'PENDING'
  }
}, {
  timestamps: true
});

// Index for efficient queries
reportSchema.index({ toiletId: 1, createdAt: -1 });
reportSchema.index({ userId: 1 });
reportSchema.index({ status: 1 });

module.exports = mongoose.model('Report', reportSchema);