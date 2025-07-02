const express = require('express');
const router = express.Router();
const addEligibilityTemplate = require('../../controllers/learningController/addEligibilityController');
const listEligibilityTemplates = require('../../controllers/learningController/listEligibilityController');
const updateEligibilityTemplate = require('../../controllers/learningController/updateEligibilityController');
const viewEligibilityTemplate = require('../../controllers/learningController/viewEligibilityController');
const submitEligibilityResponse = require('../../controllers/learningController/eligibilityResponseController');

router.post('/add-eligibility-template', addEligibilityTemplate);
router.get('/list-eligibility-template', listEligibilityTemplates);
router.post('/update-eligibility-template', updateEligibilityTemplate);
router.get('/view-eligibility-template', viewEligibilityTemplate);
router.post('/submit-eligibility-response', submitEligibilityResponse);

module.exports = router;