import { pool } from "../../config/db.js";

const addTopicAssessment = async (req, res) => {
  try {
    const { user_id: in_user_tid, topic_id: in_topic_tid, questions_json: in_questions_json } = req.body;


    if (!in_user_tid || !in_topic_tid || !in_questions_json) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields (user_tid, topic_tid, questions_json)"
      });
    }

    const [result] = await pool.query(
      "CALL add_topic_assessment(?, ?, ?)",
      [in_user_tid, in_topic_tid, JSON.stringify(in_questions_json)]
    );


    if (result[0]?.[0]?.message) {
      return res.status(400).json({
        status: false,
        error: result[0][0].message
      });
    }

    if (result[0][0]) {
      return res.status(201).json({
        status: true,
        data: result[0][0],
        message: "Assessment created successfully"
      });
    }

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

export default addTopicAssessment;