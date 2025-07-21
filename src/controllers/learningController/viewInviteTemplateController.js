import { pool } from "../../config/db.js";

// Controller to view a specific invite template by ID
const viewInviteTemplate = async (req, res) => {
  try {
    const { template_tid: in_template_id } = req.body;
    // Validate input
    if (!in_template_id) {
      return res.status(400).json({
        status: false,
        error: "Template ID is required",
      });
    }

    const [result] = await pool.query("CALL view_invite_template(?)", [
      in_template_id,
    ]);

    // Extract the returned JSON data
    const dataJson = result[0]?.[0]?.data;

    // If result is null or not found
    if (!dataJson) {
      return res.status(404).json({
        status: false,
        error: "Template not found",
      });
    }
    // If successful, return the response data
    else if (dataJson) {
      return res.status(200).json({
        status: true,
        data: dataJson,
        message: "Template retrieved successfully",
      });
    }
  } catch (error) {
    // Catch and return internal server errors
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default viewInviteTemplate;
