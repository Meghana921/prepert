import { pool } from "../../config/db.js";

// Controller to add a new sponsorship record for a learning program
const addSponsorship = async (req, res) => {
  try {
    // Extracting input data from the request body
    const {
      program_tid: in_program_id,     
      creator_tid: in_creator_id,    
      slots: in_slots                
    } = req.body;

    // Basic input validation
    if (!in_program_id || !in_creator_id || !in_slots) {
      return res.status(400).json({
        error: 'Missing required fields (program_tid, creator_tid, slots)'
      });
    }

    // Call the stored procedure to insert the sponsorship record
    const [result] = await pool.query(
      'CALL add_sponsorship(?, ?, ?)',
      [in_program_id, in_creator_id, in_slots]
    );

    // Send a success response
    res.status(201).json({
      status: true,
      message: 'Sponsorship added successfully'
    });

  } catch (error) {
    // handle internal server error
    res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

export default addSponsorship;
