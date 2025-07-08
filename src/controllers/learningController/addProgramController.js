import { pool } from "../../config/db.js";
import sendEmail from "../../utils/sendEmail.js";

const BATCH_SIZE = 5;

const addProgram = async (req, res) => {
  try {
    const {
      title: in_title,
      description: in_description,
      creator_tid: in_creator_id,
      difficulty_level: in_difficulty_level,
      image_path: in_image_path = null,
      price: in_price = null,
      access_period_months: in_access_period_months = null,
      available_slots: in_available_slots = null,
      campus_hiring: in_campus_hiring = false,
      sponsored: in_sponsored = false,
      minimum_score: in_minimum_score = null,
      experience_from: in_experience_from = null,
      experience_to: in_experience_to = null,
      locations: in_locations = null,
      employer_name: in_employer_name = null,
      regret_message: in_regret_message = null,
      eligibility_template_tid: in_eligibility_template_id = null,
      invite_template_tid: in_invite_template_id = null,
      invitees: in_invitees = [],
    } = req.body;

    // 1. Create Program
    const [result] = await pool.query(
      `CALL add_learning_program(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
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
        in_invite_template_id,
        in_invitees.length ? JSON.stringify(in_invitees) : null,
      ]
    );

    const programData = result?.[0]?.[0]?.data;
    if (!programData) {
      return res
        .status(500)
        .json({ status: false, error: "Failed to create program" });
    }

    // 2. Respond Immediately
    res.status(200).json({
      status: true,
      data: programData,
      message:
        "Program created successfully. Email invites are being processed.",
    });
    const in_learning_program_tid = programData.program_id;
    // 3. Background email processing
    if (!in_invite_template_id || !in_invitees.length) return;

    setImmediate(async () => {
      try {
        // Fetch email template
        const [emailTemplateResult] = await pool.query(
          `CALL view_invite_template(?)`,
          [in_invite_template_id]
        );

        const templateData = emailTemplateResult?.[0]?.[0]?.data;
        if (!templateData) return;

        // Batch processing
        const batches = [];
        for (let i = 0; i < in_invitees.length; i += BATCH_SIZE) {
          batches.push(in_invitees.slice(i, i + BATCH_SIZE));
        }

        for (const batch of batches) {
          await Promise.all(
            batch.map(async (invitee) => {
              try {
                await sendEmail({
                  to: invitee.email,
                  subject: templateData.subject,
                  text: templateData.body,
                  programCode: programData.program_code,
                  programTitle: in_title,
                  recipientName: invitee.name,
                });

                await pool.query(`CALL update_invitee_email_status(?, ?, ?)`, [
                  in_learning_program_tid,
                  invitee.email,
                  "1",
                ]);
              } catch (err) {
                await pool.query(`CALL update_invitee_email_status(?, ?, ?)`, [
                  in_learning_program_tid,
                  invitee.email,
                  "2",
                ]);
                console.error(
                  `Failed to send to ${invitee.email}:`,
                  err.message
                );
              }
            })
          );
        }
      } catch (err) {
        console.error("Email background process failed:", err.message);
      }
    });
  } catch (error) {
    console.error("Program creation error:", error.message);
    return res.status(500).json({ status: false, error: error.message });
  }
};

export default addProgram;
