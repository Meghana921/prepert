import { pool } from "../../config/db.js";

// Controller function to update modules and their nested topics for a learning program
const updateCourseContent = async (req, res) => {
  try {
    // Destructure input from request body
    const { program_id, modules } = req.body;

    // Validate required input
    if (!program_id || !Array.isArray(modules)) {
      return res.status(400).json({
        status: false,
        error: "Missing or invalid 'program_id' or 'modules' array.",
      });
    }

    // Call the stored procedure to update modules and topics
    await pool.query(
      "CALL update_learning_modules_and_topics(?, ?)",
      [program_id, JSON.stringify(modules)]
    );

    // Send success response
    return res.status(200).json({
      status: true,
      message: "Modules and topics updated successfully.",
    });

  } catch (error) {
    // Handle any unexpected errors
    console.error("Error updating modules and topics:", error);
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default updateCourseContent;
