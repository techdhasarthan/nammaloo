const express = require("express");
const router = express.Router();
const User = require("../models/User");

router.post("/login", async (req, res) => {
  const { name, email, photoUrl, googleId } = req.body;

  try {
    let user = await User.findOne({ email });

    if (!user) {
      user = new User({ name, email, photoUrl, googleId });
      await user.save();
    }

    res.status(200).json({ message: "Login data stored successfully", user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});
router.put("/update/:googleId", async (req, res) => {
  const { name, preferences, bio, photoUrl } = req.body;

  try {
    const updatedUser = await User.findOneAndUpdate(
      { googleId: req.params.googleId },
      {
        $set: {
          name,
          preferences,
          bio,
          photoUrl, // ✅ Store the new avatar URL
        },
      },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      message: "User profile updated successfully",
      user: updatedUser,
    });
  } catch (err) {
    console.error("Profile update error:", err);
    res
      .status(500)
      .json({ message: "Failed to update profile", error: err.message });
  }
});

router.get("/user/:googleId", async (req, res) => {
  console.log("Fetching user with Google ID:", req.params.googleId);
  try {
    const user = await User.findOne({ googleId: req.params.googleId });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ message: "User data fetched successfully", user });
  } catch (err) {
    console.error("Get user error:", err);
    res
      .status(500)
      .json({ message: "Failed to fetch user", error: err.message });
  }
});

module.exports = router;
