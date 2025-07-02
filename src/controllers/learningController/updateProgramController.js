const { pool } = require("../../config/db");

const updateLearningProgram = async (req, res) => {
  try {
    const {
      in_program_id,
      in_title,
      in_description,
      in_creator_id,
      in_difficulty_level,
      in_image_path,
      in_price,
      in_access_period_months,
      in_available_slots,
      in_campus_hiring,
      in_sponsored,
      in_minimum_score,
      in_experience_from,
      in_experience_to,
      in_locations,
      in_employer_name,
      in_regret_message,
      in_eligibility_template_id,
      in_invite_template_id
    } = req.body;

    // Validate required fields
    if (!in_program_id || !in_creator_id) {
      return res.status(400).json({
        error: "program_id and creator_id are required"
      });
    }

    const [result] = await pool.query(
      "CALL update_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        in_program_id,
        in_title || null,
        in_description || null,
        in_creator_id,
        in_difficulty_level || null,
        in_image_path || null,
        in_price || null,
        in_access_period_months || null,
        in_available_slots || null,
        in_campus_hiring || false,
        in_sponsored || false,
        in_minimum_score || null,
        in_experience_from || null,
        in_experience_to || null,
        in_locations || null,
        in_employer_name || null,
        in_regret_message || null,
        in_eligibility_template_id || null,
        in_invite_template_id || null
      ]
    );

    // Handle stored procedure response
    if (!result || !result[0] || !result[0][0]) {
      return res.status(500).json({
        error: "No response from database"
      });
    }

    const procedureResult = result[0][0];
    console.log(procedureResult);
    if (procedureResult.error) {
      return res.status(404).json({
        error: procedureResult.error
      });
    }

    // Return the complete response from the procedure
    return res.status(200).json(procedureResult.data || procedureResult);

  } catch (error) {
    console.error("Error updating program:", error);
    return res.status(500).json({
      error: "Internal server error",
      details: process.env.NODE_ENV === "development" ? error.message : undefined
    });
  }
};

module.exports = updateLearningProgram;