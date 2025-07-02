const { pool } = require("../../../db");

const view_program = async (req, res) => {
  try {
    const { creator_id, program_id } = req.body;

    
    if (!creator_id || !program_id) {
      return res.status(400).json({
        error: "Both creator_id and program_id are required in the request body"
      });
    }

  
    const [result] = await pool.query("CALL view_program(?, ?)", [
      creator_id,
      program_id
    ]);

   
    if (result[0] && result[0][0] && result[0][0].error) {
      return res.status(404).json({
        error: result[0][0].error
      });
    }

    
    if (!result[0] || result[0].length === 0) {
      return res.status(404).json({
        error: "Program not found"
      });
    }

    
    const programData = result[0][0].program_data;

    const responseData = typeof programData === 'string'
      ? JSON.parse(programData)
      : programData;

    return res.status(200).json(responseData);

  } catch (error) {
    console.error('Error viewing program:', error);

   
    if (error.code === '45000') {
      return res.status(403).json({
        error: error.message
      });
    }

    return res.status(500).json({
      error: "Internal server error",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = view_program;