const { pool } = require("../db");

const updateEligibilityTemplate = async (req, res) => {
  try {
    const { template_id, template_name, eligibility_questions } = req.body;

    if (!template_id || !template_name || !eligibility_questions) {
      return res.status(400).json({
        error: "Missing required fields",
      });
    }

    const [result] = await pool.query(
      "CALL update_eligibility_template(?, ?, ?)",
      [template_id, template_name, JSON.stringify(eligibility_questions)]
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
        message: "Template updated successfully",
        template_id: result[0][0].template_id,
        template_name: result[0][0].template_name,
      });
    }
  } catch (error) {
    return res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = updateEligibilityTemplate;
