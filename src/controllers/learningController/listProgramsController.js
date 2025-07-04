import { pool } from "../../config/db.js";

const viewCreatedPrograms = async (req, res) => {
  try {
    const { creator_tid:creator_id } = req.body;
    const [result] = await pool.query("CALL view_created_program(?)", [
      creator_id,
    ]);
    

    res.status(201).json({ data: result[0][0].data, 
      status: true, 
      message: "Programs fetched successfully!" });
  } catch (error) {
    console.error('Error creating program:', error);
    res.status(500).json({
      error: error.message,
      status:false
    });
  }
};

export default viewCreatedPrograms;
