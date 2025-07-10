import { pool } from "../../config/db.js";

const viewProgramController = async (req, res) => {
  try {
    // Extract program ID from request body
    const { program_tid: program_id } = req.body;

    // Validate presence of program ID
    if (!program_id) {
      return res.status(400).json({
        status: false,
        error: "Required fields missing!!"
      });
    }

    // Execute stored procedure to fetch program data
    const [result] = await pool.query("CALL view_program(?)", [
      program_id
    ]);

    // Send success response with program data
    res.status(201).json({
      data: result[0][0].data,
      status: true,
      message: "Program fetched successfully!"
    });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      status:false,
      error: error.message
    });
  }
};

export default viewProgramController;
