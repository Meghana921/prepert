import { pool } from "../../config/db.js";

const userController = async (req, res) => {
  try {
    const {user_tid:in_user_tid} = req.body;
    if (!in_user_tid) {
      return res.status(400).json({ error: 'user_tid is required' });
    }
    const params = [in_user_tid];
    const [result] = await pool.query(' CALL list_user_subscribed_programs(?)',[in_user_tid]);
    res.json(result[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};

export default userController;