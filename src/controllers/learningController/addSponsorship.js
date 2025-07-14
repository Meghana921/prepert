import { pool } from "../../config/db.js";

const addSponsorship = async (req, res) => {
  try {
    const {
        program_tid: in_program_id,
        creator_tid: in_creator_id,
        slots: in_slots,
    } = req.body;

    if (!in_program_id || !in_creator_id || !in_slots) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const [result] = await pool.query(
        'CALL add_sponsored_program(?, ?, ?)',[in_program_id, in_creator_id, in_slots]);
    res.status(201).json({ status:true,message: 'Sponsorship added successfully' });
  } catch (error) {
    console.error('Error adding sponsorship:', error);
    res.status(500).json({ status:false,error: 'Failed to add sponsorship' });
  }
};

export default addSponsorship;
