import { pool } from "../../config/db.js";

// Controller to fetch list of subscribers for a specific learning program
const viewCompanySubscribers = async (req, res) => {
  try {
    // Destructure and rename program_tid from request body
    const { program_tid: learning_program_tid } = req.body;

    // Validate required input
    if (!learning_program_tid) {
      return res
        .status(400)
        .json({ status: false, error: "Required fields missing!" });
    }

    // Prepare parameters for stored procedure
    const params = [learning_program_tid];

    // Call stored procedure to get course subscribers
    const [result] = await pool.query("CALL getCourseSubscribers(?)", params);

    // Send response with subscriber data
    res.status(201).json({
      data: result[0][0].data.data, // Unwrap nested JSON result
      status: true,
      message: "Subscribers fetched successfully",
    });
  } catch (err) {
    // Log and handle unexpected errors
    console.error(err);
    res.status(500).json({ error: err.message, status: false });
  }
};

export default viewCompanySubscribers;
