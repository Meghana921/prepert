const { pool } = require("../../../db");

const submitProgramAssessment = async (req, res) => {
  try {
    const { programId } = req.params;
    const { userId, responses } = req.body;

    // Validate required fields
    if (!userId || !responses || !Array.isArray(responses)) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields: userId and responses array are required",
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      "CALL submit_program_assessment(?, ?, ?)",
      [userId, programId, JSON.stringify(responses)]
    );

    // Handle error message from stored procedure
    if (result[0]?.[0]?.error) {
      return res.status(409).json({
        status: false,
        message: result[0][0].error,
      });
    }

    // Handle successful response
    if (result[0]?.[0]?.assessment_result) {
      return res.status(201).json({
        data: JSON.parse(result[0][0].assessment_result),
        status: true,
        message: "Assessment submitted successfully!"
      });
    }

    // Handle unexpected response format
    return res.status(500).json({
      status: false,
      error: "Unexpected response format from database",
    });

  } catch (error) {
    console.error("Error in submitProgramAssessment:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = submitProgramAssessment;