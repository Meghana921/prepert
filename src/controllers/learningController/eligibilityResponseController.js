import { pool } from "../../config/db.js";

const submitEligibilityResponse = async (req, res) => {
  try {
    const { user_tid: in_user_id, program_tid: in_program_id, questions: in_questions } = req.body;


    if (!in_user_id || !in_program_id || !in_questions) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields",
        details: "Please provide user_id, program_id, and questions"
      });
    }


    const [result] = await pool.query(
      'CALL eligibility_response(?, ?, ?)',
      [in_user_id, in_program_id, JSON.stringify(in_questions)]
    );
    console.log(result)

    if (results[0]?.[0]?.message) {
      return res.status(409).json({
        status:true,
        error: result[0][0].message
      });
    }

    return res.status(201).json({
      data:result[0][0],
      status:true
    });

  } catch (error) {
    return res.status(500).json({
      status:true,
      error: error.message
    });
  }
};

export default submitEligibilityResponse;




