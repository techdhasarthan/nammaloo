const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  photoUrl: String, // ✅ Save avatar URL
  googleId: { type: String, unique: true },
  preferences: String,
  bio: String,
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("User", userSchema);
