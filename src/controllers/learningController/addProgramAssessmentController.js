import { pool } from "../../config/db.js";

const addProgramAssessment = async (req, res) => {
  try {
    const { 
      program_tid: in_program_id,
      title: in_title,
      description: in_description,
      question_count: in_question_count,
      passing_score: in_passing_score,
      questions: in_questions
    } = req.body;

  
    if (!in_program_id || !in_title || !in_description || 
        in_question_count === undefined || in_passing_score === undefined) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields: program_id, title, description, question_count, and passing_score are required",
      });
    }

 
    if (in_questions && (!Array.isArray(in_questions) || in_questions.length !== in_question_count)) {
      return res.status(400).json({
        status: false,
        error: "Questions array must match the specified question_count",
      });
    }

 
    const [result] = await pool.query(
      "CALL add_program_assessment(?, ?, ?, ?, ?, ?)",
      [
        in_program_id,
        in_title,
        in_description,
        in_question_count,
        in_passing_score,
        in_questions ? JSON.stringify(in_questions) : null
      ]
    );

   console.log(result[0][0])
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }

   
    else if(result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Assessment created successfully!"
      });
    }

   else {
      return res.status(500).json({
        status: false,
        error: "Unexpected response from stored procedure"
      })
    }

  } catch (error) {
    console.error("Failed to add learning assessment:", error);
    return res.status(500).json({
      status: false,
      error:error.message,
    });
  }
};

export default addProgramAssessment;