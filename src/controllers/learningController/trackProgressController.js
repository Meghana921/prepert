const db = require("../../config/db");

exports.trackProgress = async (req, res) => {
  try {
    const { enrollment_tid, topic_tid, status } = req.body;
    if (!enrollment_tid || !topic_tid || !status) {
      return res.status(400).json({ error: 'enrollment_tid, topic_tid, and status are required' });
    }
    const params = [enrollment_tid, topic_tid, status];
    const result = await db.callProcedure('sp_track_learning_progress', params);
    res.json(result[0][0] || {});
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 