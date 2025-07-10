import { pool } from "../../config/db.js";

// Controller function to add a new invite email template
const addInviteTemplate = async (req, res) => {
  try {
    // Destructure inputs from request body
    const { creator_tid: in_creator_tid, name: in_name, subject: in_subject, body: in_body } = req.body;

    // Validate required fields
    if (!in_creator_tid || !in_name || !in_subject || !in_body) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields !",
      });
    }

    // Call the stored procedure to insert a new invite template
    const [result] = await pool.query(
      "CALL add_invite_template(?, ?, ?, ?)",
      [in_creator_tid, in_name, in_subject, in_body]
    );

    // Success response with newly created template data
    if (result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Invite template created successfully!"
      });
    }

  } catch (error) {
    // Catch and handle any internal server errors
    console.error("Error in addInviteTemplate:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default addInviteTemplate;
