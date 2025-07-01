const db = require('../db');

exports.viewCompanySubscribers = async (req, res) => {
  try {
    const { company_user_tid, learning_program_tid = null, status = null } = req.query;
    if (!company_user_tid) {
      return res.status(400).json({ error: 'company_user_tid is required' });
    }
    const params = [company_user_tid, learning_program_tid || null, status || null];
    const result = await db.callProcedure('sp_view_company_subscribers', params);
    res.json(result[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 