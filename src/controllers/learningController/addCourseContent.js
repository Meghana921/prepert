import { pool } from "../../config/db.js";

// Controller to insert learning modules and topics
const addLearningModulesAndTopics = async (req, res) => {
  try {
    const {
      program_id: in_program_id,
      modules: in_modules_json
    } = req.body;

    // Validate required inputs
    if (!in_program_id || !Array.isArray(in_modules_json) || in_modules_json.length === 0) {
      return res.status(400).json({
        status: false,
        error: "Missing or invalid required fields: program_id or modules"
      });
    }

    // Call the stored procedure
    const [result] = await pool.query(
      "CALL insert_learning_modules_and_topics(?, ?)",
      [in_program_id, JSON.stringify(in_modules_json)]
    );

    // Success response
    return res.status(201).json({
      status: true,
      message: "Modules and topics inserted successfully"
    });

  } catch (error) {
    console.error("Error in insertLearningModulesAndTopics:", error);
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default addLearningModulesAndTopics;
