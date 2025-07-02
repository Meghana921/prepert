const db = require('../../db');

exports.addLearningQuestion = async (req, res) => {
  try {
    const { enrollment_tid, topic_tid, question } = req.body;
    if (!enrollment_tid || !topic_tid || !question) {
      return res.status(400).json({ error: 'enrollment_tid, topic_tid, and question are required' });
    }
    // Pass 6 arguments: 3 IN, 3 OUT (dummy values)
    const params = [enrollment_tid, topic_tid, JSON.stringify(question)];
    const result = await db.callProcedure('sp_add_learning_question', params);
    res.json(result[0][0] || {});
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 