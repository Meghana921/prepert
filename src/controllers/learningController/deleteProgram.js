import { pool } from "../../config/db.js";

const deleteProgram = async (req, res) => {
  try {
    const { program_tid:program_id } = req.body;

    if (!program_id) {
      return res.status(400).json({
        status: false,
        error: "Program ID is required",
      });
    }

    // Call the stored procedure
    await pool.query(`CALL delete_program(?)`, [program_id]);

    return res.status(200).json({
      status: true,
      message: `Program ID ${program_id} and all its related data have been deleted successfully.`,
    });

  } catch (error) {
    console.error("Error deleting program:", error.message);
    return res.status(500).json({
      status: false,
      error: error.message || "Internal Server Error",
    });
  }
};

export default deleteProgram;
