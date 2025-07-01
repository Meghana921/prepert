const { pool } = require("../../db");

const submitTopicAssessment = async (req, res) => {
  try {
    const { assessment_tid, user_tid, responses } = req.body;

    // Validate required fields
    if (!assessment_tid || !user_tid || !responses) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields (assessment_tid, user_tid, responses)"
      });
    }

    // Validate responses structure
    const isValid = Array.isArray(responses) && 
                   responses.every(r => 
                     r.question_id && 
                     typeof r.selected_option === 'number'
                   );

    if (!isValid) {
      return res.status(400).json({
        status: false,
        error: "Each response must have question_id and selected_option"
      });
    }

    const [result] = await pool.query(
      "CALL evaluate_assessment(?, ?, ?)",
      [assessment_tid, user_tid, JSON.stringify(responses)]
    );

    // Handle error message from procedure
    if (result[0]?.[0]?.error) {
      return res.status(400).json({
        status: false,
        error: result[0][0].error
      });
    }

    return res.status(200).json({
        data: result[0][0],
      status: true,
      message: "Assessment evaluated successfully",
    
    });

  } catch (error) {
    console.error("Error in evaluateAssessment:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message
    });
  }
};

module.exports = submitTopicAssessment;


// {
//   "assessment_tid": 2,
//   "user_tid": 123,
//   "responses": [
//     {
//       "question_id": 101,
//       "selected_option": 1
//     },
//     {
//       "question_id": 102,
//       "selected_option": 2
//     }
//   ]
// }