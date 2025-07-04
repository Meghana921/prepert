import express from "express";
import addEligibilityTemplate from '../../controllers/learningController/addEligibilityController.js';
import listEligibilityTemplates from '../../controllers/learningController/listEligibilityController.js';
import updateEligibilityTemplate from '../../controllers/learningController/updateEligibilityController.js';
import viewEligibilityTemplate from '../../controllers/learningController/viewEligibilityController.js';
import submitEligibilityResponse from '../../controllers/learningController/eligibilityResponseController.js';

const router = express.Router();

router.post('/add-eligibility-template', addEligibilityTemplate);
router.get('/list-eligibility-template', listEligibilityTemplates);
router.post('/update-eligibility-template', updateEligibilityTemplate);
router.get('/view-eligibility-template', viewEligibilityTemplate);
router.post('/submit-eligibility-response', submitEligibilityResponse);

export default router;