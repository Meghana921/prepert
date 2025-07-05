import Router from 'express';
import addLearningEnrollment from '../../controllers/learningController/enrollmentController.js';

const router = Router();
router.post('/add-enrollment',addLearningEnrollment);

export default router;