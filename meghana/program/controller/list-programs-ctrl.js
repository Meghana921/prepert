const { pool } = require("../../../db");

const view_created_programs = async (req, res) => {
  try {
    const { creator_id } = req.body;
    const [result] = await pool.query("CALL view_created_program(?)", [
      creator_id,
    ]);
    const program_list = result[0];
    res.status(200).json(program_list);
  } catch (error) {
    return res.status(500).json({
      error_message: "Failed to fetch program due to a server error.",
      details: error.message,
    });
  }
};

module.exports = view_created_programs;
