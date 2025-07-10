import { pool } from "../../config/db.js";


const listInviteTemplates = async (req, res) => {
  try {
    const { creator_tid:creator_id } = req.body;
    if (!creator_id){
      return res.status().json({
        success:false,
        error:"Missing required fields!"
      })
    }
    const [result] = await pool.query("CALL list_invite_template(?)", [
      creator_id
    ]);

   // Extract the data object returned by the stored procedure
    const dataResult = result[0][0]?.data;

    // If the 'templates' array is empty, return a "not found" response
    if (dataResult.length==0) {
      return res.status(200).json({
        status: true,
        message: "No templates found!",
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

export default listInviteTemplates;