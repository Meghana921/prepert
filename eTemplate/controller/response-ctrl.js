const { pool } = require('../../db');

const submitEligibilityResponse = async (req, res) => {
  try {
    const { in_user_id, in_program_id, in_questions } = req.body;

    // Validate required fields
    if (!in_user_id || !in_program_id || !in_questions) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields",
        details: "Please provide user_id, program_id, and questions"
      });
    }

    // Execute stored procedure
    const [results] = await pool.query(
      'CALL eligibility_response(?, ?, ?)',
      [in_user_id, in_program_id, JSON.stringify(in_questions)]
    );
     console.log(results)
    // Handle procedure errors
    if (results[0] && results[0][0] && results[0][0].error) {
      return res.status(409).json({
        error: results[0][0].error
      });
    }

    // Successful response
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



'{\"questions\": [{\"question\": \"Do you have 3+ years of professional software development experience?\", \"deciding_answer\": \"yes\", \"sequence_number\": 1}, {\"question\": \"Are you proficient in Python or Java?\", \"deciding_answer\": \"yes\", \"sequence_number\": 2}, {\"question\": \"Have you worked with cloud platforms (AWS/Azure/GCP)?\", \"deciding_answer\": \"yes\", \"sequence_number\": 3}, {\"question\": \"Can you demonstrate experience with CI/CD pipelines?\", \"deciding_answer\": \"no\", \"sequence_number\": 4}], \"template_id\": 11, \"template_name\": \"Data Engineer Eligibility 2025\"}'
