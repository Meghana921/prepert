const db = require('../../db');

exports.viewCourseContentWithProgress = async (req, res) => {
  try {
    const { learning_program_tid, user_tid } = req.query;
    if (!learning_program_tid || !user_tid) {
      return res.status(400).json({ error: 'learning_program_tid and user_tid are required' });
    }
    const params = [learning_program_tid, user_tid];
    const result = await db.callProcedure('sp_view_course_content_with_progress', params);
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 