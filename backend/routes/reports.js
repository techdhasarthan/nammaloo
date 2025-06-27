const express = require('express');
const router = express.Router();
const Report = require('../models/Report');

// Get reports for a toilet
router.get('/toilet/:toiletId', async (req, res) => {
  try {
    const reports = await Report.find({ toiletId: req.params.toiletId })
      .populate('userId', 'name')
      .sort({ createdAt: -1 });

    res.json(reports);
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
});

// Create a new report
router.post('/', async (req, res) => {
  try {
    const { toiletId, userId, issueText } = req.body;

    if (!toiletId || !userId || !issueText) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const report = new Report({
      toiletId,
      userId,
      issueText
    });

    await report.save();
    await report.populate('userId', 'name');

    res.status(201).json(report);
  } catch (error) {
    console.error('Error creating report:', error);
    res.status(400).json({ error: 'Failed to create report' });
  }
});

// Update report status (admin only)
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;

    if (!['PENDING', 'REVIEWED', 'RESOLVED', 'DISMISSED'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const report = await Report.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).populate('userId', 'name');

    if (!report) {
      return res.status(404).json({ error: 'Report not found' });
    }

    res.json(report);
  } catch (error) {
    console.error('Error updating report status:', error);
    res.status(400).json({ error: 'Failed to update report status' });
  }
});

module.exports = router;