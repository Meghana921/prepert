import express from 'express';
import listAllPrograms  from '../../controllers/learningController/listLearningPrograms.js';
import listUserSubscribedPrograms from '../../controllers/learningController/listSubscribedPrograms.js'
const router = express.Router();

router.get('/list-learning-programs',listAllPrograms );
router.get('/list-subscribed-courses',listUserSubscribedPrograms)

export default router;