import { pool } from "../../config/db.js";


 // Controller to fetch all learning programs a user is enrolled in
const listUserSubscribedPrograms = async (req, res) => {
  try {
    const { user_tid } = req.body;

    // Validate required input
    if (!user_tid) {
      return res.status(400).json({
        status: false,
        error: "Missing required field: user_tid"
      });
    }

    // Call stored procedure 
    const [result] = await pool.query("CALL list_user_subscribed_programs(?)", [user_tid]);

    // Extract and return data
    res.status(200).json({
      status: true,
      message: "Subscribed programs fetched successfully",
      data: result[0][0]?.data || [] // Return empty array if no data
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default listUserSubscribedPrograms;
