import { pool } from "../../config/db.js";

const submitProgramAssessment = async (req, res) => {
  try {
    // Extract and rename variables from request body
    const { 
      user_tid: p_user_id, 
      assessment_tid: p_assessment_id, 
      responses 
    } = req.body;

    // Validate required fields
    if (!p_user_id || !p_assessment_id || !responses || !Array.isArray(responses)) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields: user_id, assessment_id, and responses array are required",
      });
    }

    // Call the stored procedure to submit the assessment
    const [result] = await pool.query(
      "CALL submit_program_assessment(?, ?, ?)",
      [
        p_user_id, 
        p_assessment_id, 
        JSON.stringify(responses) // Convert responses array to JSON string
      ]
    );

    // If the procedure returns a message (e.g., duplicate submission or error)
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }

    // If the procedure returns success data
    if (result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Assessment submitted successfully!"
      });
    }

    // Fallback response if no expected output is returned
    return res.status(500).json({
      status: false,
      error: "Unexpected response from stored procedure"
    });

  } catch (error) {
    // Catch and return any runtime errors
    console.error("Error in submitProgramAssessment:", error);
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default submitProgramAssessment;
