const { pool } = require("../../config/db");

const view_created_programs = async (req, res) => {
  try {
    const { creator_id } = req.body;
    const [result] = await pool.query("CALL view_created_program(?)", [
      creator_id,
    ]);
    const program_list = result[0];
    res.status(200).json({data:program_list,status:true,message:"Programs fetched succesfully"});
  } catch (error) {
    return res.status(500).json({
      status:false,
      message: "Failed to fetch program due to a server error.",
      details: error.message,
    });
  }
};

module.exports = view_created_programs;
