import { pool } from "../../config/db.js";

const viewInviteTemplate = async (req, res) => {
  try {
    const { template_id } = req.body;

    if (!template_id) {
      return res.status(400).json({
        status: false,
        error: "Template ID is required"
      });
    }

    const [result] = await pool.query(
      "CALL view_invite_template(?)",
      [template_id]
    );


    if (result[0]?.[0]?.message) {
      return res.status(404).json({
        status: false,
        error: result[0][0].message
      });
    }


    if (result[0][0]) {
      return res.status(200).json({
        status: true,
        data: result[0][0],
        message: "Template retrieved successfully"
      });
    }


  } catch (error) {
    console.error("Error in viewInviteTemplate:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message
    });
  }
};

export default viewInviteTemplate;