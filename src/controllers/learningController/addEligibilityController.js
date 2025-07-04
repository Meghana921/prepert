import { pool } from "../../config/db.js";

const addEligibilityTemplate = async (req, res) => {
  try {
    const {
      creator_id: in_creator_id,
      template_name: in_template_name,
      eligibility_questions: in_eligibility_questions,
    } = req.body;

    if (!in_creator_id || !in_template_name || !in_eligibility_questions) {
      return res.status(400).json({ status: false, error: "Missing required fields" });
    }
    console.log(1);
    // CALL SP
    const [rows] = await pool.query(
      "CALL add_eligibility_template(?, ?, ?)",
      [in_creator_id, in_template_name, JSON.stringify(in_eligibility_questions)]
    );
    console.log(2);
    // rows[0][0].status is a JSON string
    const raw = rows[0][0].status;
    console.log(rows[0][0]);
    let proc;
    try {
      proc = JSON.parse(raw);
    } catch {
      return res.status(500).json({
        status: false,
        error: "Malformed JSON response from stored procedure"
      });
    }
    console.log(3);
    if (!proc.status) {
      return res.status(409).json({ status: false, message: proc.message });
    }
    console.log(4);
    return res.status(201).json({
      status: true,
      data: proc.data,
      message: "Template saved successfully!"
    });

  } catch (err) {
    console.error("Error in addEligibilityTemplate:", err);
    return res.status(500).json({ status: false, error: "Internal server error", details: err.message });
  }
};

export default addEligibilityTemplate;
