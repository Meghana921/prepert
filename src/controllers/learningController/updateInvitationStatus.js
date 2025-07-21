import { pool } from "../../config/db.js";

const updateInvitationStatus = async (req, res) => {
  try {
    const { invite_tid:in_invite_id, status:in_status } = req.body;
   if(!in_invite_id || !in_status ){
    return res.status(400).json({
      status: false,
      error: "Missing required fields!"
    });

   }
    // Call the stored procedure 
    await pool.query(
      "CALL update_invitation_status(?, ?)",
      [in_invite_id, in_status]
    );

    return res.status(200).json({
      status: true,
      message: "Invitation status updated"
    });

  } catch (error) {
    return res.status(500).json({
      error: error.message,
      status: false
    });
  }
};

export default updateInvitationStatus;