// Import the database connection pool
import { pool } from "../../config/db.js";

// Controller function to fetch course content based on program ID
const viewCourseContentController = async (req, res) => {
  try {
    // Extract 'program_tid' from request body and alias it as 'program_id'
    const { program_tid: program_id } = req.body;

    // 
    if (!program_id) {
      return res.status(400).json({
        status: false,
        error: "program_id is required"
      });
    }

    // Call the stored procedure 
    const [result] = await pool.query("CALL view_course_content(?)", [program_id]);

    // Response to client
    res.status(200).json({
      data: result[0][0].data, 
      status: true,
      message: "Course content fetched successfully!"
    });
  } catch (error) {
    // Handle any server or database errors
    res.status(500).json({
      status: false,
      error: error.message // Return error message from the exception
    });
  }
};

// Export the controller function for use in routing
export default viewCourseContentController;
