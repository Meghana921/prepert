const { pool } = require("../../../db");

const viewProgramAssessment = async (req, res) => {
  try {
    const { programId } = req.params;

    // Validate programId is provided
    if (!programId) {
      return res.status(400).json({
        status: false,
        error: "Program ID is required",
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      "CALL view_program_assessment(?)",
      [programId]
    );

    // Handle case when no assessment exists
    if (!result[0]?.[0]?.data) {
      return res.status(404).json({
        status: false,
        message: "No assessment found for this program",
      });
    }

    // Parse the JSON data from the database
    const assessmentData = JSON.parse(result[0][0].data);

    // Return successful response
    return res.status(200).json({
      data: assessmentData,
      status: true,
      message: "Assessment retrieved successfully"
    });

  } catch (error) {
    console.error("Error in viewProgramAssessment:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = viewProgramAssessment;