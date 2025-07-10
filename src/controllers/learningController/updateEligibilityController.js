import { pool } from "../../config/db.js";

const updateEligibilityTemplate = async (req, res) => {
  try {
    // Destructure required fields from request body
    const {
      template_tid: in_template_id,
      template_name: in_template_name,
      eligibility_questions: in_eligibility_questions
    } = req.body;

    // Validation: Ensure all required fields are present
    if (!in_template_id || !in_template_name || !in_eligibility_questions) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields!",
      });
    }

    // Call stored procedure to update template and questions
    const [result] = await pool.query(
      "CALL update_eligibility_template(?, ?, ?)",
      [
        in_template_id,
        in_template_name,
        JSON.stringify(in_eligibility_questions),
      ]
    );
    
    // Check if the stored procedure returned a valid response
    if (result?.[0]?.[0]?.data) {
      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Template updated successfully",
      });
    }
  } catch (error) {
    // Catch and handle any exceptions during execution
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default updateEligibilityTemplate;
