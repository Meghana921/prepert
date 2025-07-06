import { pool } from "../../config/db.js";

const addTopicAssessment = async (req, res) => {
  try {
    // Destructure and rename request body fields for internal use
    const { user_id: in_user_tid, topic_id: in_topic_tid, questions_json: in_questions_json } = req.body;

    // Validate required input fields
    if (!in_user_tid || !in_topic_tid || !in_questions_json) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields!"
      });
    }

    // Call stored procedure to insert topic assessment
    const [result] = await pool.query(
      "CALL add_topic_assessment(?, ?, ?)",
      [in_user_tid, in_topic_tid, JSON.stringify(in_questions_json)]
    );

    // If stored procedure returns expected data, send success response
    if (result[0][0]) {
      return res.status(201).json({
        status: true,
        data: result[0][0].data,
        message: "Assessment created successfully"
      });
    }
    // If response format is not as expected, send error
    else {
      return res.status(500).json({
        status: false,
        error: "Unexpected database response"
      });
    }

  } catch (error) {
    // Catch and handle unexpected errors
    console.error("Failed to create assessment:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default addTopicAssessment;
