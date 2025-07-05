import { pool } from "../../config/db.js";

const submitProgramAssessment = async (req, res) => {
  try {
    
    const { user_tid:p_user_id, assessment_tid : p_assessment_id , responses } = req.body;

   
    if (!p_user_id ||! p_assessment_id || !responses || !Array.isArray(responses)) {
      return res.status(400).json({
        status: false,
        error: "Missing required fields:user_id,program_id and responses array are required",
      });
    }

    
    const [result] = await pool.query(
      "CALL submit_program_assessment(?, ?, ?)",
      [p_user_id,  p_assessment_id , JSON.stringify(responses)]
    );

  
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }

   
    if (result[0]?.[0]?.data) {
      return res.status(201).json({
        data: result[0][0].data,
        status: true,
        message: "Assessment submitted successfully!"
      });
    }

   

  } catch (error) {
    console.error("Error in submitProgramAssessment:", error);
    return res.status(500).json({
      status: false,
      error: error.message,
    });
  }
};

export default submitProgramAssessment;