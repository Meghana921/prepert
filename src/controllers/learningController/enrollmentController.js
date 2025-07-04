import { pool } from "../../config/db.js";

const listInviteTemplates = async (req, res) => {
  try {
    const { creator_id } = req.body;

    if (!creator_id) {
      return res.status(400).json({
        error: "Missing required field: creator_id",
      });
    }

    const [result] = await pool.query(
      "CALL list_invite_template(?)",
      [creator_id]
    );

    if (
      result[0] &&
      result[0][0] &&
      result[0][0].error
    ) {
      return res.status(409).json({
        error: result[0][0].error,
      });
    }

    if (
      result[0] &&
      result[0][0] &&
      result[0][0].templates
    ) {
      return res.status(200).json({
        templates: result[0][0].templates
      });
    }

    return res.status(404).json({
      error: "No templates found"
    });

  } catch (error) {
    console.error("Failed to fetch templates:", error);
    return res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

const enrollmentController = listInviteTemplates;
export default enrollmentController;