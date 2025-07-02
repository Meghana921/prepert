const { pool } = require("../../config/db");

const view_program = async (req, res) => {
  try {
    const { creator_id, program_id } = req.body;

    if (!creator_id || !program_id) {
      return res.status(400).json({
        status: false,
        error: "Both creator_id and program_id are required"
      });
    }

    const [result] = await pool.query("CALL view_program(?, ?)", [
      creator_id,
      program_id
    ]);

    // Handle error message from stored procedure
    if (result[0]?.[0]?.message) {
      return res.status(404).json({
        status: false,
        error: result[0][0].message
      });
    }

    // Handle successful response
    if (result[0]?.[0]?.data) {
      const programData = typeof result[0][0].data === 'string' 
        ? JSON.parse(result[0][0].data) 
        : result[0][0].data;
      
      return res.status(200).json({
        status: true,
        data: programData,
        message: "Program retrieved successfully"
      });
    }


    return res.status(404).json({
      status: false,
      error: "Program not found"
    });

  } catch (error) {
    console.error('Error viewing program:', error);

 
    if (error.code === '45000') {
      return res.status(404).json({
        status: false,
        error: "Program not found"
      });
    }

    return res.status(500).json({
      status: false,
      error: "Internal server error",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = view_program;