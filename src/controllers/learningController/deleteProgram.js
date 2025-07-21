import { pool } from "../../config/db.js";

const deleteProgramController = async (req, res) => {
  try {
    // Extract program_id and creator_id from request body
    const { program_tid:program_id, creator_tid: creator_id } = req.body;

    // Validate required fields
    if (!program_id || !creator_id) {
      return res.status(400).json({
        status: false,
        message: "program_id and creator_id are required!",
      });
    }

    // Call the delete_program stored procedure
    await pool.query("CALL delete_program(?, ?)", [program_id, creator_id]);

    // Send success response
    res.status(200).json({
      status: true,
      message: "Program deleted successfully!",
    });
  } catch (error) {
    // Handle and return SQL error or SIGNAL messages from procedure
    res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default deleteProgramController;
