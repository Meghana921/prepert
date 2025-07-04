import { pool } from "../../config/db.js";
import sendEmail from "../../utils/sendEmail.js";
const updateLearningProgram = async (req, res) => {
  try {
    const {
      program_tid:in_program_id,
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
        in_title ,
        in_description ,
        in_creator_id,
        in_difficulty_level ,
        in_image_path || null,
        in_price || null,
        in_access_period_months || null,
        in_available_slots || null,
        in_campus_hiring || false,
        in_sponsored || false,
        in_minimum_score || null,
        in_experience_from ,
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
      return res.status(409).json({
        status: false,
        error: result[0][0].message
      });
    }
   else{
    // Fetch email template for invitations
    const [emailTemplateResult] = await pool.query(
      `CALL view_invite_template(?)`,
      [in_invite_template_id]
    );

    // Extract subject and body from the template
    const emailSubject = emailTemplateResult[0][0].data.subject;
    const emailBody = emailTemplateResult[0][0].data.body;

    // Send invite emails to each invitee
    if (Array.isArray(in_invitees)) {
      for (const invitee of in_invitees) {
        await sendEmail({
          to: invitee.email,
          subject: emailSubject,
          text: emailBody
        });
        console.log("Invite sent to", invitee.email);
      }
    }

    // Return success response after everything is done
    return res.status(200).json({
      status: true,
      data: result[0][0].data,
      message: "Program updated successfully"
    });}

  } catch (error) {
    // Handle any unexpected errors
    console.error('Error updating program:', error);
    res.status(500).json({
      status: false,
      error: error.message
    });
  }
};


export default updateLearningProgram;