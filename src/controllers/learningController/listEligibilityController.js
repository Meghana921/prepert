import { pool } from "../../config/db.js";

// Controller to list all eligibility templates created by a specific user
const listEligibilityTemplates = async (req, res) => {
  try {

    const { creator_tid } = req.body;

    // Validate required fields
    if (!creator_tid) {
      res.status(400).json({
        status: false,
        error: "Missing required fields!"
      })
    }
    // Call the stored procedure with inputs
    const [result] = await pool.query("CALL list_eligibility_template(?)", [
      creator_tid,
    ]);

    // Extract the data object returned by the stored procedure
    const dataResult = result[0][0]?.data;

    // If the 'templates' array is empty, return a "not found" response
    if (dataResult.length == 0) {
      return res.status(200).json({
        status: false,
        error: "You have not added any template",
      });
    }
    else {
      // Return the templates if found, with a success message
      return res.status(200).json({
        data: dataResult,
        status: true,
        message: "Templates fetched successfully!",
      });
    };
  } catch (error) {
    // Catch and return internal server errors
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default listEligibilityTemplates;
