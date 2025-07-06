import { pool } from "../../config/db.js";
import sendEmail from "../../utils/sendEmail.js";

const updateLearningProgram = async (req, res) => {
  try {
    // Destructure and rename request body fields for internal use
    const {
      program_tid: in_program_id,
      title: in_title,
      description: in_description,
      creator_tid: in_creator_id,
      difficulty_level: in_difficulty_level,
      image_path: in_image_path,
      price: in_price,
      access_period_months: in_access_period_months,
      available_slots: in_available_slots,
      campus_hiring: in_campus_hiring,
      sponsored: in_sponsored,
      minimum_score: in_minimum_score,
      experience_from: in_experience_from,
      experience_to: in_experience_to,
      locations: in_locations,
      employer_name: in_employer_name,
      regret_message: in_regret_message,
      eligibility_template_tid: in_eligibility_template_id,
      invite_template_tid: in_invite_template_id,
      invitees: in_invitees,
    } = req.body;

    // Validate required fields
    if (!in_program_id || !in_creator_id) {
      return res.status(400).json({
        status: false,
        error: "program_id and creator_id are required"
      });
    }

    // Call stored procedure to update the learning program
    const [result] = await pool.query(
      "CALL update_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        in_program_id,
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
        JSON.stringify(in_invitees) || null
      ]
    );

    const programData = result?.[0]?.[0]?.data;

    if (!programData) {
      return res.status(500).json({
        status: false,
        error: "Failed to update program or no response returned."
      });
    }

    // Prepare invite template details
    let emailSubject, emailBody;
    if (in_invite_template_id) {
      const [emailTemplateResult] = await pool.query(
        "CALL view_invite_template(?)",
        [in_invite_template_id]
      );

      const templateData = emailTemplateResult?.[0]?.[0]?.data;

      if (!templateData) {
        return res.status(404).json({
          status: false,
          error: "Invite template not found"
        });
      }

      emailSubject = templateData.subject;
      emailBody = templateData.body;
    }

    // Send invite emails and track confirmation
    let emailConfirmations = [];
    if (Array.isArray(in_invitees) && emailSubject && emailBody) {
      for (const invitee of in_invitees) {
        try {
          await sendEmail({
            to: invitee.email,
            subject: emailSubject,
            text: emailBody
          });
          emailConfirmations.push({
            email: invitee.email,
            status: "sent"
          });
        } catch (err) {
          emailConfirmations.push({
            email: invitee.email,
            status: "failed",
            error: err.message
          });
        }
      }
    }

    // Return final response
    return res.status(200).json({
      status: true,
      data: programData,
      message: "Program updated successfully",
      invites: emailConfirmations.length > 0 ? emailConfirmations : "No invites sent"
    });

  } catch (error) {
    console.error("Error updating program:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default updateLearningProgram;
