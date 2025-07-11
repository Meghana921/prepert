import {pool} from "../../config/db.js";

// Controller to handle listing all invitations for a user
const listAllInvitations = async (req, res) => {
  try {
    // Extract user ID from route parameters
    const { user_tid: in_user_id } = req.body;

    // Validate required input
    if (!in_user_id) {
      return res.status(400).json({
        error: "Missing user ID ",
        status: false
      });
    }


    // Call the stored procedure to get all invitations
    const [result] = await pool.query(
      "CALL list_all_invitations(?)",
      [in_user_id]
    );

    // Extract invitation data
    const resData = result[0][0]?.invitations;

    // Send response to client
    return res.status(200).json({
      data: resData,
      status: true,
      message: "Invitations retrieved successfully"
    });

  } catch (error) {
    // Handle any server or SQL errors
    console.error("Failed to fetch invitations:", error);
    return res.status(500).json({
      error: error.message,
      status: false
    });
  }
};

export default listAllInvitations;