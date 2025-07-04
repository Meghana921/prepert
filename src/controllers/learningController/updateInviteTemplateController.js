import { pool } from "../../config/db.js";

const updateInviteTemplate = async (req, res) => {
  try {
    const {
      creator_tid: in_creator_tid,
      template_id: in_template_id,
      template_name: in_new_name,
      subject: in_new_subject,
      body: in_new_body,
    } = req.body;

   
    if (
      !in_creator_tid ||
      !in_template_id ||
      !in_new_name ||
      !in_new_subject ||
      !in_new_body
    ) {
      return res.status(400).json({
        status: false,
        error:
          "Missing required fields (creator_tid, template_id,template_name, subject, body)",
      });
    }

    const [result] = await pool.query(
      "CALL update_invite_template(?, ?, ?, ?,?)",
      [in_creator_tid, in_template_id, in_new_name, in_new_subject, in_new_body]
    );

    if (result[0]?.[0]?.message) {
      return res.status(404).json({
        status: false,
        message: result[0][0].message,
      });
    }

    if (result[0]?.[0]?.data) {
      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Template updated successfully!",
      });
    }
  } catch (error) {
    console.error("Error in updateInviteTemplate:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

export default updateInviteTemplate;
