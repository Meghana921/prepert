const { pool } = require("../../db");

const addInviteTemplate = async (req, res) => {
  try {
    const { creator_tid:in_creator_tid, name:in_name, subject:in_subject, body:in_body } = req.body;

    if (!in_creator_tid || !in_name|| !in_subject || ! in_body) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields !",
      });
    }

    const [result] = await pool.query(
      "CALL add_invite_template(?, ?, ?, ?)",
      [in_creator_tid,in_name, in_subject,  in_body]
    );

 
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }

  
    if (result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Invite template created successfully!"
      });
    }

  } catch (error) {
    console.error("Error in addInviteTemplate:", error);
    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: error.message,
    });
  }
};

module.exports = addInviteTemplate;