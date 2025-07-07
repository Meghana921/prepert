import { pool } from "../../config/db.js";

const viewProgramWithProgress = async (req, res) => {
  try {
    const { program_tid: program_id, user_tid: user_id } = req.body;

    // Validate required inputs
    if (!program_id || !user_id) {
      return res.status(400).json({
        status: false,
        error: "Both program_id and user_id are required.",
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      `CALL view_learning_program_with_progress(?, ?)`,
      [program_id, user_id]
    );

    // Extract the returned JSON object
    const programData = result?.[0]?.[0]?.program_json;

    // If no data returned
    if (!programData) {
      return res.status(404).json({
        status: false,
        error: "Program not found or no progress data available.",
      });
    }



    // Success response
    return res.status(200).json({
      status: true,
      data: programData,
    });

  } catch (error) {
    console.error("Error fetching program with progress:", error);
    return res.status(500).json({
      status: false,
      error: error.message ,
    });
  }
};

export default viewProgramWithProgress;
