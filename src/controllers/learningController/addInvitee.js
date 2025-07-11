import { pool } from "../../config/db.js";
import sendMail from "../../utils/sendEmail.js";

const addInvitee = async (req, res) => {
  try {
    // Destructure invitee details from the request body
    const {
      program_type,
      program_tid,
      name,
      email
    } = req.body;

    // Call stored procedure to insert invitee 
    const [result] = await pool.query(`CALL add_invitee(${Array(4).fill("?").join(",")})`, [
      program_type,
      program_tid,
      name,
      email
    ]);

    // Extract the returned JSON data from the stored procedure
    const resData = result?.[0]?.[0]?.data;

    let emailStatus = '2'; // Default to "2" => failed, will be updated if successful

    // Try sending the invitation email
    try {
      await sendMail({
        to: email,
        subject: resData.subject,
        text: resData.body,
        programCode: resData.program_code || null,
        programTitle: resData.program_title,
        recipientName: name
      });

      emailStatus = '1'; // Email sent successfully

      // Update the invitee's email status in the database
      await pool.query(`CALL update_invitee_email_status(?, ?)`, [
        resData.invite_tid,
        emailStatus
      ]);
      console.log(resData.invite_tid)
    } catch (mailErr) {
      // If email fails to send, respond with error and terminate
      return res.status(500).json({
        status: false,
        error: mailErr.message
      });
    }

    // Final response to the client after email is sent and status updated
    res.status(201).json({
      status: true,
      data: { inviteeTID: resData.invite_tid },
      message: `${emailStatus === '1' ? 'sent email' : 'failed to send email'}!`
    });

  } catch (error) {
    // Catch any database or unexpected server errors
    res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default addInvitee;
