import { pool } from "../../config/db.js";

const updateLearningProgram = async (req, res) => {
  try {
    const {
      program_id:in_program_id,
      title:in_title,
      description:in_description,
      creator_id:in_creator_id,
      difficulty_level:in_difficulty_level,
      image_path:in_image_path,
      price:in_price,
      access_period_months:in_access_period_months,
      available_slots:in_available_slots,
      campus_hiring:in_campus_hiring,
      sponsored:in_sponsored,
      minimum_score:in_minimum_score,
      experience_from:in_experience_from,
      experience_to:in_experience_to,
      locations:in_locations,
      employer_name:in_employer_name,
      regret_message:in_regret_message,
      eligibility_template_id:in_eligibility_template_id,
      invite_template_id:in_invite_template_id,
      invitees:in_invitees,
    } = req.body;

    
    if (!in_program_id || !in_creator_id) {
      return res.status(400).json({
        error: "program_id and creator_id are required"
      });
    }

    const [result] = await pool.query(
      "CALL update_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)",
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
        in_invite_template_id|| null,
        JSON.stringify(in_invitees) || null
      ]
    );

    

    if (result[0]?.[0]?.message) {
      return res.status(400).json({ error: result[0][0] });
    }


    res.status(201).json({ data: result[0][0].data, status: true, message: "Program updated successfully!" });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
};

export default updateLearningProgram;