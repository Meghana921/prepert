const db = require('../db');

exports.addCourseContent = async (req, res) => {
  try {
    const { learning_program_tid, module_title, module_description, module_sequence, topics } = req.body;
    if (!learning_program_tid || !module_title || !module_description || !module_sequence || !topics) {
      return res.status(400).json({ error: 'learning_program_tid, module_title, module_description, module_sequence, and topics are required' });
    }
    const params = [learning_program_tid, module_title, module_description, module_sequence, JSON.stringify(topics)];
    const result = await db.callProcedure('sp_add_course_content', params);
    res.json(result[0][0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.editCourseContent = async (req, res) => {
  try {
    const { content_type, content_id, content_json, learning_program_tid } = req.body;
    if (!content_type || !content_id || !content_json || !learning_program_tid) {
      return res.status(400).json({ error: 'content_type, content_id, content_json, and learning_program_tid are required' });
    }
    const params = [content_type, content_id, JSON.stringify(content_json), learning_program_tid];
    const result = await db.callProcedure('sp_edit_course_content', params);
    res.json(result[0][0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.deleteCourseContent = async (req, res) => {
  try {
    const { content_type, content_id, learning_program_tid } = req.body;
    if (!content_type || !content_id || !learning_program_tid) {
      return res.status(400).json({ error: 'content_type, content_id, and learning_program_tid are required' });
    }
    const params = [content_type, content_id, learning_program_tid];
    const result = await db.callProcedure('sp_delete_course_content', params);
    res.json(result[0][0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 