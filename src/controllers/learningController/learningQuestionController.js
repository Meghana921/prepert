import { pool } from "../../config/db.js";

const addLearningQuestion = async (req, res) => {
  try {
    const { program_tid: p_program_tid, user_tid: p_user_tid, topic_tid: p_topic_tid, question: p_question } = req.body;
    if (!p_program_tid || !p_user_tid || !p_topic_tid || !p_question) {
      return res.status(400).json({ error: 'Required missing fields!', status: false });
    }


    const [result] = await pool.query('CALL sp_add_learning_question(?, ?, ?,?)', [p_program_tid, p_user_tid, p_topic_tid, JSON.stringify(p_question)]);
    if (result[0]?.[0?.message]){
      res.status(400).json({error:result[0][0].message,status:false})
    }
    res.status(200).json({ status: true, data: result[0][0].data, message: "Question added successfully" })
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message, status: false });
  }
};

const learningQuestionController = addLearningQuestion;

export default learningQuestionController;