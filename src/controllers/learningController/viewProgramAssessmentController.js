import { pool } from "../../config/db.js";

const viewProgramAssessment = async (req, res) => {
  try {
    const { program_tid:in_program_id } = req.body;

    if (!in_program_id) {
      return res.status(400).json({
        status: false,
        error: "Program ID is required",
      });
    }


    const [result] = await pool.query(
      "CALL view_program_assessment(?)",
      [in_program_id]
    );
    
    if (result[0]?.[0]?.message) {
      return res.status(409).json({
        status: false,
        message: result[0][0].message,
      });
    }
else{
    return res.status(200).json({
      data: result[0][0].data,
      status: true,
      message: "Assessment retrieved successfully"
    });
  }
  } catch (error) {
    console.error("Failed to retrive assessment:", error);
    return res.status(500).json({
      status: false,
      error:error.message
    });
  }
};

export default viewProgramAssessment;