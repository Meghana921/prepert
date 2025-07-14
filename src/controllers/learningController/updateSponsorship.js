import { pool } from "../../config/db.js";

const updateSponsorship = async (req, res) => {
  

  try {
    const {
        program_tid: in_program_id,
        slots: in_slots,
        cancelled : in_cancelled = false
    } = req.body;

    if (!in_program_id ||  !in_slots) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const [result] = await pool.query(
        'CALL update_sponsored_program(?, ? , ?)',[in_program_id,  in_slots , in_cancelled]);
    res.status(200).json({ status:true, message: 'Sponsorship updated successfully' });
  } catch (error) {
    console.error('Error updating sponsorship:', error);
    res.status(500).json({ status:false,error: 'Failed to update sponsorship' });
  }
};

export default updateSponsorship;
