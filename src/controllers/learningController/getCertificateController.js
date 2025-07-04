import { pool} from '../../config/db.js';

export const getCertificate = async (req, res) => {
    try {
      const { enrollment_tid } = req.body;
      if (!enrollment_tid) {
        return res.status(400).json({ status: false, message: 'enrollment_tid is required' });
      }
      // Call the new get_certificate_url procedure with enrollment_tid
      const params = [enrollment_tid];
      const [result] = await pool.query('get_certificate_url(?)', params);
      res.json(result[0][0] || { status: false, message: 'No response from procedure' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, message: 'Internal server error' });
    }
};
export default getCertificate;