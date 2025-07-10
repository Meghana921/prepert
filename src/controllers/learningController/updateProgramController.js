import { pool } from "../../config/db.js";

const addProgram = async (req, res) => {
  try {
    // Destructure and extract all input parameters from request body
    const {
      title: in_title,
      description: in_description,
      creator_tid: in_creator_id,
      difficulty_level: in_difficulty_level,
      image_path: in_image_path = null,
      price: in_price = null,
      access_period_months: in_access_period_months = null,
      available_slots: in_available_slots = null,
      campus_hiring: in_campus_hiring = false,
      sponsored: in_sponsored = false,
      minimum_score: in_minimum_score = null,
      experience_from: in_experience_from = null,
      experience_to: in_experience_to = null,
      locations: in_locations = null,
      employer_name: in_employer_name = null,
      regret_message: in_regret_message = null,
      eligibility_template_tid: in_eligibility_template_id = null,
      invite_template_tid: in_invite_template_id = null,
    } = req.body;

    // Validate required fields
    if (
      !in_title ||
      !in_description ||
      !in_creator_id ||
      !in_difficulty_level
    ) {
      res.status(400).json({
        status: true, // should ideally be false in error, but kept as-is
        error: "Missing required fields!",
      });
    }

    // Execute stored procedure with 18 input parameters
    const [result] = await pool.query(
      `CALL add_learning_program(${Array(18).fill("?").join(",")})`,
      [
        in_title,
        in_description,
        in_creator_id,
        in_difficulty_level,
        in_image_path,
        in_price,
        in_access_period_months,
        in_available_slots,
        in_campus_hiring,
        in_sponsored,
        in_minimum_score,
        in_experience_from,
        in_experience_to,
        in_locations,
        in_employer_name,
        in_regret_message,
        in_eligibility_template_id,
        in_invite_template_id,
      ]
    );

    // Extract program data from stored procedure result
    const programData = result?.[0]?.[0]?.data;

    // Send success response with program data
    res.status(200).json({
      status: true,
      data: programData,
      message: "Program created successfully!",
    });
  } catch (error) {
    // Handle database errors and unexpected failures
    return res.status(500).json({ status: false, error: error.message });
  }
};

export default addProgram;
