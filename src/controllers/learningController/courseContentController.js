import { pool } from "../../config/db.js";



const editCourseContent = async (req, res) => {
  try {
    const { content_type, content_id, content_json, learning_program_tid } = req.body;
    if (!content_type || !content_id || !content_json || !learning_program_tid) {
      return res.status(400).json({ error: 'content_type, content_id, content_json, and learning_program_tid are required' });
    }
    const params = [content_type, content_id, JSON.stringify(content_json), learning_program_tid];
    const [result] = await pool.query('sp_edit_course_content(?,?,?,?)', params);
    res.json(result[0][0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const deleteCourseContent = async (req, res) => {
  try {
    const { content_type, content_id, learning_program_tid } = req.body;
    if (!content_type || !content_id || !learning_program_tid) {
      return res.status(400).json({ error: 'content_type, content_id, and learning_program_tid are required' });
    }
    const params = [content_type, content_id, learning_program_tid];
    const [result] = await pool.query('sp_delete_course_content(?,?,?)', params);
    res.json(result[0][0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const courseContentController = { addCourseContent, editCourseContent, deleteCourseContent };

export default courseContentController;