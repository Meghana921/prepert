const db = require('../db');

exports.listCourses = async (req, res) => {
  try {
    const {
      creator_tid = null,
      difficulty_level = null,
      sponsored = null,
      limit = 20,
      offset = 0
    } = req.query;
    const params = [
      creator_tid ? Number(creator_tid) : null,
      difficulty_level || null,
      sponsored !== null ? (sponsored === 'true' ? 1 : 0) : null,
      Number(limit),
      Number(offset)
    ];
    const result = await db.callProcedure('sp_view_all_learning_courses', params);
    res.json(result[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 