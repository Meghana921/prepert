import { pool } from "../../config/db.js";

// Controller to handle learning program enrollment
const addLearningEnrollment = async (req, res) => {
  try {
    // Extract and rename input parameters from request body
    const { user_tid: in_user_id, program_tid: in_program_id , status:in_status=null,type:in_type=null} = req.body;

    // Validate required inputs
    if (!in_user_id || !in_program_id) {
      return res.status(400).json({
        error: "Missing required field!",
      });
    }
   
    let result
    // Call the stored procedure to enroll the user in the program
    if(in_type === "1"){
       [result] = await pool.query(
      "CALL learning_enrollment(?, ?, ?)",
      [in_user_id, in_program_id,in_status]
    );
  }

  const resData = result[0][0];
    // Send response to client
    if (resData) {
      return res.status(200).json({
        data: resData,
        status: true,
        message: "Enrolled to program successfully!"
      });}
    

  } catch (error) {
    // Handle any server or SQL errors
    console.error("Failed to fetch templates:", error);
    return res.status(500).json({
      error: error.message,
      status: false
    });
  }
};

export default addLearningEnrollment;
