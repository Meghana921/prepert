const db = require('../../db');

exports.listSubscribedCourses = async (req, res) => {
  try {
    const user_tid = req.params.user_tid;
    if (!user_tid) {
      return res.status(400).json({ error: 'user_tid is required' });
    }
    const params = [user_tid];
    const result = await db.callProcedure('sp_list_subscribed_courses', params);
    res.json(result[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 