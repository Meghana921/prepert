import { pool } from "../../config/db.js";

// Controller function to handle adding an eligibility template
const addEligibilityTemplate = async (req, res) => {
  try {
    // Destructure inputs from the request body
    const {
      creator_tid: in_creator_id,
      template_name: in_template_name,
      eligibility_questions: in_eligibility_questions,
    } = req.body;

    // Validate required fields
    if (!in_creator_id || !in_template_name || !in_eligibility_questions) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields",
      });
    }

    // Call the stored procedure with inputs
    const [result] = await pool.query(
      "CALL add_eligibility_template(?, ?, ?)",
      [
        in_creator_id,
        in_template_name,
        JSON.stringify(in_eligibility_questions), // Convert questions to JSON string for MySQL
      ]
    );

    // Handle known business logic error returned by stored procedure (e.g., duplicate name)
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        error: result[0][0].message
      });
    }

    // If successful, return the response data
    else if (result[0]?.[0]?.data) {
      return res.status(201).json({
        status: true,
        data: result[0][0].data,
        message: "Template saved successfully!"
      });
    }
    else {
      return res.status(500).json({
        status: false,
        error: "Unexpected response from stored procedure"
      })
    }
  } catch (error) {
    // Catch and return internal server errors
    console.error("Error in addEligibilityTemplate:", error);
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};


export default addEligibilityTemplate;
