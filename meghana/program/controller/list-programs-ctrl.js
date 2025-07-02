const { pool } = require("../../../db");

const view_created_programs = async (req, res) => {
  try {
    const { creator_id } = req.body;
    const [result] = await pool.query("CALL view_created_program(?)", [
      creator_id,
    ]);
  
    res.status(201).json({ data: result[0][0] || "No programs found for this user", status: true, message: "Programs fetched successfully!" });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
};

module.exports = view_created_programs;
