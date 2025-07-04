import { pool } from "../../config/db.js";
import sendEmail from "../../utils/sendEmail.js";

const addProgram = async (req, res) => {
  try {
    const {
      title:in_title,
      description:in_description,
      creator_tid:in_creator_id,
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
      eligibility_template_tid:in_eligibility_template_id,
      invite_template_tid:in_invite_template_id,
      invitee:in_invitee,
    } = req.body;

    const [result] = await pool.query(
      `CALL add_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)`,
      [
        in_title,
        in_description,
        in_creator_id,
        in_difficulty_level,
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
        in_invite_template_id || null,
        JSON.stringify(in_invitee) || null
      ]
    );
    // Update and email invitees
    if (in_invitee && Array.isArray(in_invitee)) {
      for (const invitee of in_invitee) {
        // Update invitee status to 'invited'
        const [updateResult] = await pool.query(
          `CALL email_update_invitees(?, ?)`,
          [result[0][0].program_id, invitee.email]
        );
        if (updateResult[0][0].message) {
          return res.status(400).json({ error: updateResult[0][0] });
        }

        // Send email using the invite template
        const [emailTemplateResult] = await pool.query(
          `CALL get_email_template(?)`,
          [in_invite_template_id]
        );
        
        // Use the data object directly (no JSON.parse)
        let templateData = emailTemplateResult[0][0].data;
        if (typeof templateData === 'string') {
          templateData = JSON.parse(templateData);
        }
        
        if (!templateData.status) {
          return res.status(400).json({ error: templateData.message });
        }

        // Send email with the template content
        await sendEmail({
          to: invitee.email,
          name: invitee.name,
          programTitle: in_title,
          templateContent: templateData.template_content
        });
      }
    }

    if (result[0]?.[0]?.message) {
      return res.status(400).json({ error: result[0][0] });
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

export default addProgram;