import { pool } from "../../config/db.js";

// Controller to view a specific eligibility template by ID
const viewEligibilityTemplate = async (req, res) => {
  try {
    const { template_tid } = req.body;

    // Validate input
    if (!template_tid) {
      return res.status(400).json({
        status: false,
        error: "Missing template_tid",
      });
    }

    // Call stored procedure
    const [result] = await pool.query("CALL view_eligibility_template(?)", [
      template_tid,
    ]);

    // Extract the returned JSON data
    const dataJson = result[0]?.[0]?.data;

    // If result is null or not found
    if (!dataJson) {
      return res.status(404).json({
        status: false,
        error: "Template not found",
      });
    }
    // If successful, return the response data
    else if (dataJson) {
      return res.status(200).json({
        status: true,
        data: dataJson,
        message: "Template retrieved successfully",
      });
    }

  } catch (error) {
    // Catch and return internal server errors
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default viewEligibilityTemplate;
