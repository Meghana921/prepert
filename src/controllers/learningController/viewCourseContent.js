import { pool } from "../../config/db.js";

const viewCourseContentController = async (req, res) => {
  try {
    const { program_tid: program_id } = req.body;

    if (!program_id) {
      return res.status(400).json({
        status: false,
        error: "program_id is required"
      });
    }

    const [result] = await pool.query("CALL view_course_content(?)", [program_id]);

    res.status(200).json({
      data: result[0][0].data,
      status: true,
      message: "Course content fetched successfully!"
    });
  } catch (error) {
    console.error("Error fetching course content:", error);
    res.status(500).json({
      status: false,
      error:  error.message
    });
  }
};

export default viewCourseContentController;
