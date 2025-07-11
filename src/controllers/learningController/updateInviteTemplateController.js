import { pool } from "../../config/db.js";

// Updates an invite template's details in the database
const updateInviteTemplate = async (req, res) => {
  try {
    // Extract template data from request body
    const {
      template_tid: in_template_id,
      template_name: in_new_name,
      subject: in_new_subject,
      body: in_new_body,
    } = req.body;

    // Validate all required fields are present
    if (!in_template_id || !in_new_name || !in_new_subject || !in_new_body) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields!",
      });
    }

    // Execute stored procedure to update template
    const [result] = await pool.query(
      "CALL update_invite_template(?, ?,?)",
      [in_template_id, in_new_name, in_new_subject, in_new_body]
    );

    // Return success response with updated template data
    if (result[0]?.[0]?.data) {
      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Template updated successfully!",
      });
    }
    
  } catch (error) {
    // Catch and return internal server errors
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default updateInviteTemplate;