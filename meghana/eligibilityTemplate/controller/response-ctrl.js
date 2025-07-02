const { pool } = require('../../../db');

const submitEligibilityResponse = async (req, res) => {
  try {
    const { user_id: in_user_id, program_id: in_program_id, question: in_questions } = req.body;


    if (!in_user_id || !in_program_id || !in_questions) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields",
        details: "Please provide user_id, program_id, and questions"
      });
    }


    const [results] = await pool.query(
      'CALL eligibility_response(?, ?, ?)',
      [in_user_id, in_program_id, JSON.stringify(in_questions)]
    );
    console.log(results)

    if (results[0] && results[0][0] && results[0][0].error) {
      return res.status(409).json({
        error: results[0][0].error
      });
    }


    const responseData = results[0][0];
    return res.status(201).json({
      data: {
        passed: responseData.passed,
        message: responseData.message,
      }
    });

  } catch (error) {
    return res.status(500).json({
      error: "Internal server error",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = submitEligibilityResponse;




