const { pool } = require("../../../db");

const addEligibilityTemplate = async (req, res) => {
  try {
    const {
      creator_id: in_creator_id,
      template_name: in_template_name,
      eligibility_questions: in_eligibility_questions,
    } = req.body;

    if (!in_creator_id || !in_template_name || !in_eligibility_questions) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields",
      });
    }

    const [result] = await pool.query(
      "CALL add_eligibility_template(?, ?, ?)",
      [in_creator_id, in_template_name, JSON.stringify(in_eligibility_questions)]
    );
    console.log([result[0][0].message]);
    if (result[0] && result[0][0] && result[0][0].message) {
      return res
        .status(409)
        .json({ status: false, message: result[0][0].message });
    }

    if (result[0] && result[0][0] && result[0][0].data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Template saved successfully!",
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
