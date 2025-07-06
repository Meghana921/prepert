import { pool } from "../../config/db.js";

const viewProgramAssessment = async (req, res) => {
  try {
    // Extract program ID from request body
    const { program_tid: in_program_id } = req.body;

    // Validate required input
    if (!in_program_id) {
      return res.status(400).json({
        status: false,
        error: "Program ID is required",
      });
    }

    // Call stored procedure to retrieve assessment
    const [result] = await pool.query(
      "CALL view_program_assessment(?)",
      [in_program_id]
    );

    // Return success response with data
    return res.status(200).json({
      data: result[0][0].data,
      status: true,
      message: "Assessment retrieved successfully"
    });

  } catch (error) {
    // Handle unexpected errors
    console.error("Failed to retrieve assessment:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default viewProgramAssessment;
