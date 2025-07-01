const { pool } = require("../../db");

const addTopicAssessment = async (req, res) => {
  try {
    const { user_tid, topic_tid, questions_json } = req.body;

    // Validate required fields
    if (!user_tid || !topic_tid || !questions_json) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields (user_tid, topic_tid, questions_json)"
      });
    }

    const [result] = await pool.query(
      "CALL add_and_show_questions(?, ?, ?)",
      [user_tid, topic_tid, JSON.stringify(questions_json)]
    );

    // Handle error message from procedure
    if (result[0]?.[0]?.message) {
      return res.status(400).json({
        status: false,
        error: result[0][0].message
      });
    }

    // Successful response
    if (result[0][0]) {
      return res.status(201).json({
        status: true,
        data: result[0][0],
        message: "Assessment created successfully"
      });
    }

    // Fallback for unexpected responses
    return res.status(500).json({
      status: false,
      error: "Unexpected database response"
    });

  } catch (error) {
    console.error("Failed to create assessment:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message
    });
  }
};

module.exports = addTopicAssessment ;