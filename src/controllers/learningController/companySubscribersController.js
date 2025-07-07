import { pool } from "../../config/db.js";

const viewCompanySubscribers = async (req, res) => {
  try {
    const { program_tid:learning_program_tid } = req.body;
    if (!learning_program_tid) {
      return res
        .status(400)
        .json({ status: false, error: "Required fields missing!" });
    }
    const params = [learning_program_tid];
    const [result] = await pool.query("call getCourseSubscribers(?)", params);

    res
      .status(201)
      .json({
        data: result[0][0].data.data,
        status: true,
        message: "Subscribers fetched successfully",
      });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message, status: false });
  }
};

export default viewCompanySubscribers;
