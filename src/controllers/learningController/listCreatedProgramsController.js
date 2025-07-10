import { pool } from "../../config/db.js";

const viewCreatedPrograms = async (req, res) => {
  try {
    // Extract creator_id from request body
    const { creator_tid: creator_id } = req.body;

    // Call stored procedure to fetch programs created by the given creator
    const [result] = await pool.query("CALL view_created_program(?)", [
      creator_id,
    ]);
   
    const resData=result[0][0].data
    // Send successful response with the fetched data
    res.status(201).json({
      data: resData,          // JSON data returned from the procedure
      status: true,
      message: "Programs fetched successfully!"
    });
  } catch (error) {
    // Log and send error response in case of failure
    console.error('Error creating program:', error);
    res.status(500).json({
      error: error.message,
      status: false
    });
  }
};

export default viewCreatedPrograms;
