import { pool } from "../../config/db.js";

const viewProgramController = async (req, res) => {
  try {
    const {program_tid:program_id } = req.body;

    if (!program_id) {
      return res.status(400).json({
        status: false,
        error: "Both creator_id and program_id are required"
      });
    }

    const [result] = await pool.query("CALL view_program(?)", [

      program_id
    ]);



    if (result[0]?.[0]?.message) {
      return res.status(400).json({ error: result[0][0] });
    }


    res.status(201).json({
      data: result[0][0].data,
      status: true,
      message: "Program fetched successfully!"
    });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
};

export default viewProgramController;