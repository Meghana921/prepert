const { pool } = require("../../config/db");

const view_program = async (req, res) => {
  try {
    const { creator_id, program_id } = req.body;

    if (!creator_id || !program_id) {
      return res.status(400).json({
        status: false,
        error: "Both creator_id and program_id are required"
      });
    }

    const [result] = await pool.query("CALL view_program(?, ?)", [
      creator_id,
      program_id
    ]);

 

    if (result[0]?.[0]?.message) {
      return res.status(400).json({ error: result[0][0] });
    }


    res.status(201).json({ data: result[0][0].data, status: true, message: "Program fetched successfully!" });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
};
module.exports = view_program;