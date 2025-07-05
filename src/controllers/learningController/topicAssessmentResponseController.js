import { pool } from "../../config/db.js";

const submitTopicAssessment = async (req, res) => {
  try {
    const { assessment_tid:assessment_id, user_tid:user_id, responses:responses_json } = req.body;


    if (!assessment_id || !user_id || !responses_json) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields!"
      });
    }

    const [result] = await pool.query(
      "CALL evaluate_assessment(?, ?, ?)",
      [assessment_id, user_id, JSON.stringify(responses_json)]
    );


    if (result[0]?.[0]?.message) {
      return res.status(400).json({
        status: false,
        error: result[0][0].message
      });
    }

    return res.status(200).json({
      data: result[0][0].data,
      status: true,
      message: "Assessment evaluated successfully",

    });

  } catch (error) {
    console.error("Failed to evaluate!:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default submitTopicAssessment;
