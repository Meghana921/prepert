import express from 'express';
import listAllPrograms  from '../../controllers/learningController/listLearningPrograms.js';

const router = express.Router();

router.get('/list-learning-programs',listAllPrograms );

export default router;