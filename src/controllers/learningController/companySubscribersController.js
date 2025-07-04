import { pool } from "../../config/db.js";

const viewCompanySubscribers = async (req, res) => {
  try {
    const { company_user_tid, learning_program_tid = null, status = null } = req.query;
    if (!company_user_tid) {
      return res.status(400).json({ error: 'company_user_tid is required' });
    }
    const params = [company_user_tid, learning_program_tid || null, status || null];
    const [result] = await pool.query('call sp_view_company_subscribers(?,?,?)', params);
    // const [result] = await pool.query(
    //   "CALL add_eligibility_template(?, ?, ?)",
    //   [in_creator_id, in_template_name, JSON.stringify(in_eligibility_questions)]
    // );
    res.json(result[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 

export default viewCompanySubscribers;