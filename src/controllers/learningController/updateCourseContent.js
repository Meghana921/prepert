import { pool } from "../../config/db.js";

const updateProgramModulesAndTopics = async (req, res) => {
  try {
    const { program_id, modules } = req.body;

    if (!program_id || !Array.isArray(modules)) {
      return res.status(400).json({
        status: false,
        error: "Missing or invalid 'program_id' or 'modules' array.",
      });
    }

    // Call the procedure to delete and re-insert modules and topics
    await pool.query(
      "CALL update_learning_modules_and_topics(?, ?)",
      [program_id, JSON.stringify(modules)]
    );

    return res.status(200).json({
      status: true,
      message: "Modules and topics updated successfully.",
    });

  } catch (error) {
    console.error("Error updating modules and topics:", error);
    return res.status(500).json({
      status: false,
      error: error.message || "Internal Server Error",
    });
  }
};

export default updateProgramModulesAndTopics;
