import { pool } from "../../config/db.js";

const editAssessmentQuestions = async (req, res) => {
  try {
    const {
      assessment_tid: in_assessment_id,
      title: in_title,
      description: in_description,
      question_count: in_question_count,
      passing_score: in_passing_score,
      questions: in_questions
    } = req.body;

    // Input validation
    if (
  !in_assessment_id ||
  !in_title ||
  !in_description ||
  in_question_count === undefined ||
  in_passing_score === undefined ||
  !Array.isArray(in_questions) ||
  in_questions.length === 0
){
      return res.status(400).json({
        status: false,
        error: "Missing required fields!."
      });
    }


    // Call the stored procedure
    const [result] = await pool.query(
      "CALL update_program_assessment(?, ?, ?, ?, ?, ?)",
      [
        in_assessment_id,
        in_title,
        in_description,
        in_question_count,
        in_passing_score,
        JSON.stringify(in_questions)
      ]
    );

    return res.status(200).json({
      data: result[0][0]?.data,
      status: true,
      message: "Assessment updated successfully!"
    });

  } catch (error) {
    console.error("Error in editAssessmentQuestions:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default editAssessmentQuestions;
