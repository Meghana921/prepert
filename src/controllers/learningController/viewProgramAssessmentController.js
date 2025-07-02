const { pool } = require("../../config/db");

const viewProgramAssessment = async (req, res) => {
  try {
    const { program_id:in_program_id } = req.body;

    if (!in_program_id) {
      return res.status(400).json({
        status: false,
        error: "Program ID is required",
      });
    }


    const [result] = await pool.query(
      "CALL view_program_assessment(?)",
      [in_program_id]
    );
    
   

    return res.status(200).json({
      data: result[0][0] || {},
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