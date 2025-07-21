import { pool } from "../../config/db.js";
import sendMail from "../../utils/sendEmail.js";
import { v4 as uuidv4 } from "uuid";

const addInvitees = async (req, res) => {
  // Validate required input parameters
  const { program_type, program_tid, invitees } = req.body;
  if (
    !program_type ||
    !program_tid ||
    !Array.isArray(invitees) ||
    invitees.length === 0
  ) {
    return res.status(400).json({
      status: false,
      error: "Missing required fields!",
    });
  }

  // Generate unique identifier for this batch operation
  const request_id = uuidv4();
  let conn;

  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    //Bulk insert all invitees into database

    const [resultSets] = await conn.query("CALL add_invitees(?, ?, ?, ?)", [
      program_type,
      program_tid,
      request_id,
      JSON.stringify(invitees),
    ]);

    // Extract and validate the returned invitee data
    const inviteData = resultSets?.[0]?.[0]?.data;
    if (!Array.isArray(inviteData) || inviteData.length === 0) {
      throw new Error("No invitee data returned from procedure.");
    }

    // Process email sending in parallel for all invitees

    const emailProcessing = inviteData.map(async (invitee) => {
      const {
        email,
        name,
        subject,
        body,
        program_title,
        program_code,
        invite_tid,
      } = invitee;
      let emailStatus = "0"; // Default to failed status

      try {
        await sendMail({
          to: email,
          subject,
          text: body,
          programTitle: program_title,
          programCode: program_code || null,
          recipientName: name,
        });
        emailStatus = "1"; // Update to success status if sent
      } catch (emailErr) {
        console.error(`Email failed for ${email}: ${emailErr.message}`);
      }

      return {
        invite_tid,
        name,
        email,
        email_status: emailStatus,
      };
    });

    // Wait for all email operations to complete
    const emailResults = await Promise.all(emailProcessing);

    // Converts results to JSON format for stored procedure

    await conn.query("CALL update_invitee_email_status(?)", [
      JSON.stringify(
        emailResults.map((r) => ({
          id: r.invite_tid,
          status: r.email_status,
        }))
      ),
    ]);

    // Commit transaction if all operations succeeded
    await conn.commit();

    // Return success response with detailed results
    res.status(201).json({
      status: true,
      message: "Invite processing complete",
      data: emailResults,
    });
  } catch (err) {
    // Rollback transaction on any error
    if (conn) await conn.rollback();

    // Return error response
    res.status(500).json({
      status: false,
      error: err.message,
    });
  } finally {
    // Release database connection
    if (conn) conn.release();
  }
};

export default addInvitees;
