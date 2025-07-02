const { pool } = require("../../config/db");


const listInviteTemplates = async (req, res) => {
  try {
    const { creator_id } = req.body;
    const [result] = await pool.query("CALL list_invite_template(?)", [
      creator_id
    ]);
    res.status(200).json({ data: result[0], status: true, message: "Templates fetched successfully" });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch template due to a server error.",
      details: error.message,
    });
  }
};

module.exports = listInviteTemplates;