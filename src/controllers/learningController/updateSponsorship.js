import { pool } from "../../config/db.js";

// Controller to update the sponsorship details 
const updateSponsorship = async (req, res) => {
  try {
    // Extract inputs from request body 
    const {
      program_tid: in_program_id,
      slots: in_slots,
      cancelled: in_cancelled = false
    } = req.body;

    // Validate required fields
    if (!in_program_id || !in_slots) {
      return res.status(400).json({ status:false,error: 'Missing required fields' });
    }

    // Call the stored procedure to update sponsorship details
    const [result] = await pool.query(
      'CALL update_sponsored_program(?, ?, ?)',
      [in_program_id, in_slots, in_cancelled]
    );

    // Send success response
    res.status(200).json({
      status: true,
      message: 'Sponsorship updated successfully'
    });
  } catch (error) {
    // Handle and log any errors
    console.error('Error updating sponsorship:', error);
    res.status(500).json({
      status: false,
      error: 'Failed to update sponsorship'
    });
  }
};

export default updateSponsorship;
