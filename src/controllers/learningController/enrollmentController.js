import  {pool} from "../../config/db.js";

const addLearningEnrollment = async (req, res) => {
  try {
    const { user_tid:in_user_id,program_tid:in_program_id} = req.body;

    if (!in_user_id|| !in_program_id) {
      return res.status(400).json({
        error: "Missing required field!",
      });
    }

    const [result] = await pool.query(
      "CALL learning_enrollment(?,?)",
      [in_user_id,in_program_id]
    );

    if (
      result[0]?.[0]?.message
    ) {
      return res.status(409).json({
        error: result[0][0].message,
        status:false
      });
    }

    else if(result[0]?.[0]?.data) {
      return res.status(200).json({
        data: result[0][0].data,
        status:true,
        message:"Enrolled to program successfully!"
      });
    }

     else {
      return res.status(500).json({
        status: false,
        error: "Unexpected response from stored procedure"
      })
    }

  } catch (error) {
    console.error("Failed to fetch templates:", error);
    return res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

export default addLearningEnrollment;