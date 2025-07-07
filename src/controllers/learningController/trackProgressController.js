import { pool } from "../../config/db.js";

const trackProgress = async (req, res) => {
  try {
    const { user_tid:user_id, topic_tid:topic_id } = req.body;

    if (!user_id || !topic_id) {
      return res.status(400).json({
        status: false,
        error: "Both user_id and topic_id are required",
      });
    }

    // Call the stored procedure
    const[result]=await pool.query(`CALL track_learning_progess(?, ?)`, [user_id, topic_id]);

    return res.status(200).json({
      data : result[0][0],
      status: true,
      message: `Progress for user ${user_id} on topic ${topic_id} tracked successfully.`,
    });

  } catch (error) {
    console.error("Error tracking progress:", error.message);
    res.status(500).json({
      status: false,
      error: error.message 
    });
  }
};

export default trackProgress;
