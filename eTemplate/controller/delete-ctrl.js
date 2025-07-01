const { pool } = require("../../db");

const deleteEligibilityTemplate = async (req, res) => {
  try {
    const { template_id } = req.body;
    const [result] = await pool.query("CALL deleteEligibilityTemplate(?)", [
      template_id
    ]);
    return res.status(200).json({ message: "Template deleted!" });
  } catch (error) {
    res
      .status(500)
      .json({ error: "Internal server error", details: error.message });
  }
};

module.exports = deleteEligibilityTemplate;
