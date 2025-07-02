const { pool } = require("../../../db");

const add_program = async (req, res) => {
  try {
    const {
      in_title,
      description,
      creator_id,
      difficulty_level,
      image_path,
      price,
      access_period_months,
      available_slots,
      campus_hiring,
      sponsored,
      minimum_score,
      experience_from,
      experience_to,
      locations,
      employer_name,
      regret_message,
      eligibility_template_id,
      invite_template_id,
      invitee,
    } = req.body;

    const [result] = await pool.query(
      `CALL add_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)`,
      [
        in_title,
        description,
        creator_id,
        difficulty_level,
        image_path || null,
        price || null,
        access_period_months || null,
        available_slots || null,
        campus_hiring || false,
        sponsored || false,
        minimum_score || null,
        experience_from || null,
        experience_to || null,
        locations || null,
        employer_name || null,
        regret_message || null,
        eligibility_template_id || null,
        invite_template_id || null,
        JSON.stringify(invitee) || null
      ]
    );


    if (result[0] && result[0][0] && result[0][0].error) {
      return res.status(400).json({ error: result[0][0].error });
    }


    res.status(201).json({ data: result[0][0], status: true, message: "Program created successfully!" });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
};

module.exports = add_program;