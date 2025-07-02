const { pool } = require("../../../db");

const editAssessmentQuestions = async (req, res) => {
  try {
    const {
      assessment_id: p_assessment_id,
      questions: p_questions
    } = req.body;

    // Input validation
    if (!p_assessment_id) {
      return res.status(400).json({
        status: false,
        error: "Assessment ID is required."
      });
    }

    if (!p_questions || !Array.isArray(p_questions)) {
      return res.status(400).json({
        status: false,
        error: "Questions array (p_questions) is required and must be a valid JSON array."
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      "CALL edit_assessment_questions(?, ?)",
      [
        p_assessment_id,
        JSON.stringify(p_questions) 
      ]
    )
    
     

      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Assessment questions updated successfully!"
      });
    

  } catch (error) {
    console.error("Error in editAssessmentQuestions:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = editAssessmentQuestions;