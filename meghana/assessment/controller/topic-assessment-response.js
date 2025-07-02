const { pool } = require("../../../db");

const submitTopicAssessment = async (req, res) => {
  try {
    const { assessment_tid, user_tid, responses } = req.body;


    if (!assessment_tid || !user_tid || !responses) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields (assessment_tid, user_tid, responses)"
      });
    }

    const [result] = await pool.query(
      "CALL evaluate_assessment(?, ?, ?)",
      [assessment_tid, user_tid, JSON.stringify(responses)]
    );


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
    console.error("Failed to evaluate!:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message
    });
  }
};

module.exports = submitTopicAssessment;
