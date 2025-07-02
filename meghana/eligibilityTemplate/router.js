const express = require('express');
const eligibilityTemplateRouter = express.Router();
const addEligibilityTemplate = require('./controller/add-ctrl');
const listEligibilityTemplates = require('./controller/list-ctrl');
const updateEligibilityTemplate = require('./controller/update-ctrl');
const viewEligibilityTemplate = require("./controller/view-ctrl");
const submitEligibilityResponse = require("./controller/response-ctrl");

eligibilityTemplateRouter.post('/add-eligibility-template', addEligibilityTemplate);
eligibilityTemplateRouter.get('/list-eligibility-template', listEligibilityTemplates);
eligibilityTemplateRouter.post('/update-eligibility-template', updateEligibilityTemplate);
eligibilityTemplateRouter.get('/view-eligibility-template', viewEligibilityTemplate);
eligibilityTemplateRouter.post('/submit-eligibility-response', submitEligibilityResponse);

module.exports = eligibilityTemplateRouter;