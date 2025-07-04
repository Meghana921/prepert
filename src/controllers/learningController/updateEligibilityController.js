import { pool } from "../../config/db.js";

const updateEligibilityTemplate = async (req, res) => {
  try {
    const { template_tid: in_template_id, template_name: in_template_name, eligibility_questions: in_eligibility_questions } = req.body;

    if (!in_template_id || !in_template_name || !in_eligibility_questions) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields",
      });
    }

    const [result] = await pool.query(
      "CALL update_eligibility_template(?, ?, ?)",
      [in_template_id, in_template_name, JSON.stringify(in_eligibility_questions)]
    );

    if (
      result[0]?.[0]?.message
    ) {
      return res.status(409).json({
        status: false,
        error: result[0][0].message,
      });
    }

    else if (
      result[0]?.[0]?.data
    ) {
      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Template updated successfully"
      });
    }

    else {
      return res.status(500).json({
        status: false,
        error: "Unexpected response from stored procedure"
      })
    }
  } catch (error) {
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default updateEligibilityTemplate;
