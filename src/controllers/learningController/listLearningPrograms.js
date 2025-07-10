import { pool } from "../../config/db.js";

const listAllPrograms = async (req, res) => {
  try {
    // Call stored procedure to fetch all programs
    const [result] = await pool.query("CALL view_all_learning_program()");

    // Extract JSON result from the procedure output
    const resData = result[0][0].data;

    // Send successful response with program list
    res.status(200).json({
      data: resData,
      status: true,
      message: "All learning programs fetched successfully!"
    });
  } catch (error) {
    // Log and return error response
    console.error("Error fetching all programs:", error);
    res.status(500).json({
      error: error.message,
      status: false
    });
  }
};

export default listAllPrograms;
