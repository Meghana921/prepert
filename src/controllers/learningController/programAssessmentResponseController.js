const { pool } = require("../../config/db");

const submitProgramAssessment = async (req, res) => {
  try {
    
    const { user_id,program_id, responses } = req.body;

   
    if (!user_id ||!program_id|| !responses || !Array.isArray(responses)) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields:user_id,program_id and responses array are required",
      });
    }

    
    const [result] = await pool.query(
      "CALL submit_program_assessment(?, ?, ?)",
      [user_id, program_id, JSON.stringify(responses)]
    );

  
    if (result[0]?.[0]?.error) {
      return res.status(409).json({
        status: false,
        message: result[0][0].error,
      });
    }

   
    if (result[0][0]) {
      return res.status(201).json({
        data: result[0][0],
        status: true,
        message: "Assessment submitted successfully!"
      });
    }

   

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