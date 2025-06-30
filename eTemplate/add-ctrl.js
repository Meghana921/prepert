const { pool } = require("../db");

const addEligibilityTemplate = async (req, res) => {
  try {
    const { creator_id, template_name, eligibility_questions } = req.body;

    if (!creator_id || !template_name || !eligibility_questions) {
      return res.status(400).json({
        error: "Missing required fields",
      });
    }

    const [result] = await pool.query(
      "CALL save_eligibility_template(?, ?, ?)",
      [creator_id, template_name, JSON.stringify(eligibility_questions)]
    );

    if (
      result[0] &&
      result[0][0] &&
      result[0][0].error
    ) {
      return res.status(409).json({
        error: result[0][0].error,
      });
    }

    if (
      result[0] &&
      result[0][0] &&
      result[0][0].template_id
    ) {
      return res.status(201).json({
        template_id: result[0][0].template_id,
        template_name: result[0][0].template_name,
      });
    }
  } catch (error) {
    console.error("Error in addEligibilityTemplate:", error);
    return res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = addEligibilityTemplate;
