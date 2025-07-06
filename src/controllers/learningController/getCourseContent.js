import { pool } from "../../config/db.js";

const viewProgramWithProgress = async (req, res) => {
  try {
    const { program_tid: program_id, user_tid: user_id } = req.body;

    if (!program_id || !user_id) {
      return res.status(400).json({
        status: false,
        error: "Both program_id and user_id are required",
      });
    }

    // Call stored procedure
    const [result] = await pool.query(
      `CALL view_learning_program_with_progress(?, ?)`,
      [program_id, user_id]
    );

    // Extract JSON result from stored procedure
    const programData = result?.[0]?.[0]?.program_json;

    if (!programData) {
      return res.status(404).json({
        status: false,
        error: "Program not found or no data available",
      });
    }

    // Parse JSON and return
    return res.status(200).json({
      status: true,
      data: JSON.parse(programData),
    });
  } catch (error) {
    console.error("Error fetching program with progress:", error);
    return res.status(500).json({
      status: false,
      error: error.message || "Internal Server Error",
    });
  }
};

export default viewProgramWithProgress;
