import { pool } from "../../config/db.js";

// Controller to submit user responses for eligibility check
const submitEligibilityResponse = async (req, res) => {
  try {
    // Extract input fields from the request body
    const { user_tid: in_user_id, program_tid: in_program_id, questions: in_questions } = req.body;

    // Validate that all required fields are provided
    if (!in_user_id || !in_program_id || !in_questions) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields"
      });
    }

    // Call the stored procedure 
    const [result] = await pool.query(
      'CALL eligibility_response(?, ?, ?)',
      [in_user_id, in_program_id, JSON.stringify(in_questions)]
    );


    // Return the stored procedure's output as the response
    return res.status(201).json({
      data: result[0][0].data,
      status: true
    });

  } catch (error) {
    // Handle any errors during the DB call or response formatting
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};


export default submitEligibilityResponse;
