const express = require('express');
const router = express.Router();
const courseContentController = require('../controllers/courseContentController');

router.post('/', courseContentController.addCourseContent);
router.put('/', courseContentController.editCourseContent);
router.delete('/', courseContentController.deleteCourseContent);

module.exports = router; 