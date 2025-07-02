const { pool } = require("../../config/db");

const addLearningAssessment = async (req, res) => {
  try {
    const { 
      program_id: in_program_id,
      title: in_title,
      description: in_description,
      question_count: in_question_count,
      passing_score: in_passing_score,
      questions: in_questions
    } = req.body;

    // Validate required fields
    if (!in_program_id || !in_title || !in_description || 
        in_question_count === undefined || in_passing_score === undefined) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields: program_id, title, description, question_count, and passing_score are required",
      });
    }

    // Validate questions array if provided
    if (in_questions && (!Array.isArray(in_questions) || in_questions.length !== in_question_count)) {
      return res.status(400).json({
        status: false,
        error: "Questions array must match the specified question_count",
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      "CALL add_learning_assessment(?, ?, ?, ?, ?, ?)",
      [
        in_program_id,
        in_title,
        in_description,
        in_question_count,
        in_passing_score,
        in_questions ? JSON.stringify(in_questions) : null
      ]
    );

    // Handle error message from stored procedure
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }

    // Handle successful response
    if (result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Assessment created successfully!"
      });
    }

    // Handle unexpected response format
    return res.status(500).json({
      status: false,
      error: "Unexpected response format from database",
    });

  } catch (error) {
    console.error("Error in addLearningAssessment:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = addLearningAssessment;