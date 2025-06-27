const mongoose = require('mongoose');

const toiletSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  address: {
    type: String,
    required: true,
    trim: true
  },
  city: {
    type: String,
    required: true,
    trim: true
  },
  state: {
    type: String,
    trim: true
  },
  country: {
    type: String,
    default: 'India',
    trim: true
  },
  postalCode: {
    type: String,
    trim: true
  },
  latitude: {
    type: Number,
    required: true,
    min: -90,
    max: 90
  },
  longitude: {
    type: Number,
    required: true,
    min: -180,
    max: 180
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  reviewCount: {
    type: Number,
    default: 0,
    min: 0
  },
  workingHours: {
    type: String,
    default: 'Not specified'
  },
  isPaid: {
    type: String,
    enum: ['Yes', 'No', 'Unknown'],
    default: 'Unknown'
  },
  wheelchair: {
    type: String,
    enum: ['Yes', 'No', 'Unknown'],
    default: 'Unknown'
  },
  gender: {
    type: String,
    enum: ['Male', 'Female', 'Unisex', 'Separate', 'Unknown'],
    default: 'Unknown'
  },
  baby: {
    type: String,
    enum: ['Yes', 'No', 'Unknown'],
    default: 'Unknown'
  },
  shower: {
    type: String,
    enum: ['Yes', 'No', 'Unknown'],
    default: 'Unknown'
  },
  westernOrIndian: {
    type: String,
    enum: ['Western', 'Indian', 'Both', 'Unknown'],
    default: 'Unknown'
  },
  napkinVendor: {
    type: String,
    enum: ['Yes', 'No', 'Unknown'],
    default: 'Unknown'
  },
  imageUrl: {
    type: String,
    default: 'https://images.pexels.com/photos/6585757/pexels-photo-6585757.jpeg?auto=compress&cs=tinysrgb&w=400'
  },
  businessStatus: {
    type: String,
    enum: ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'],
    default: 'OPERATIONAL'
  },
  type: {
    type: String,
    default: 'Public Toilet'
  }
}, {
  timestamps: true
});

// Index for geospatial queries
toiletSchema.index({ latitude: 1, longitude: 1 });
toiletSchema.index({ rating: -1 });
toiletSchema.index({ reviewCount: -1 });
toiletSchema.index({ city: 1 });

module.exports = mongoose.model('Toilet', toiletSchema);