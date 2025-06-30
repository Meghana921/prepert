const { pool } = require("../db");


const listInviteTemplates = async (req, res) => {
  try {
    const { creator_id } = req.body;
    const [result] = await pool.query("CALL list_invite_template(?)", [
      creator_id
    ]);
    const list = result[0];
    res.status(200).json( list);
  } catch (error) {
    return res.status(500).json({
      error_message: "Failed to fetch template due to a server error.",
      details: error.message,
    });
  }
};

module.exports = listInviteTemplates ;