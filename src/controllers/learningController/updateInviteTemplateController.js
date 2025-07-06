import { pool } from "../../config/db.js";

const updateInviteTemplate = async (req, res) => {
  try {
    const {
      template_tid: in_template_id,
      template_name: in_new_name,
      subject: in_new_subject,
      body: in_new_body,
    } = req.body;


    if (
      !in_template_id ||
      !in_new_name ||
      !in_new_subject ||
      !in_new_body
    ) {
      return res.status(400).json({
        status: false,
        error:
          "Missing required fields !",
      });
    }

    const [result] = await pool.query(
      "CALL update_invite_template(?, ?, ?,?)",
      [ in_template_id, in_new_name, in_new_subject, in_new_body]
    );

     if (result[0]?.[0]?.data) {
      return res.status(200).json({
        data: result[0][0].data,
        status: true,
        message: "Template updated successfully!",
      });
    }
    else {
      return res.status(500).json({
        status: false,
        error: "Unexpected response from stored procedure"
      })
    }
  } catch (error) {
    console.error("Error in updateInviteTemplate:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default updateInviteTemplate;
