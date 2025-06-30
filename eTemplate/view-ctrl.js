const { pool } = require("../db");

const viewEligibilityTemplate = async (req, res) => {
  try {
    const { template_id } = req.body; 

    if (!template_id) {
      return res.status(400).json({
        error: "Template ID is required",
      });
    }

    const [result] = await pool.query(
      "CALL view_eligibility_template(?)",
      [template_id]
    );

    if (result[0] && result[0][0] && result[0][0].error) {
      return res.status(404).json({
        error: result[0][0].error,
      });
    }

    if (result[0] && result[0][0] && result[0][0].eligibility_template) {

      return res.status(200).json({
        message: "Template retrieved successfully",
        template_data:result[0][0].eligibility_template
      });
    }

    // If no data found but no error returned
    return res.status(404).json({
      error: "Template not found",
    });

  } catch (error) {
    return res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = viewEligibilityTemplate;