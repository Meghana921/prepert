const express = require('express');
const eligibilityTemplateRouter = express.Router();
const addEligibilityTemplate = require('./add-ctrl');
const listEligibilityTemplates = require('./list-template-ctrl');
const deleteEligibilityTemplate = require('./delete-ctrl');
const updateEligibilityTemplate = require('./update-ctrl');
const viewEligibilityTemplate= require("./view-ctrl");
const submitEligibilityResponse= require("./response-ctrl");

eligibilityTemplateRouter.post('/add-eligibility-template',addEligibilityTemplate);
eligibilityTemplateRouter.get('/list-eligibility-template',listEligibilityTemplates);
eligibilityTemplateRouter.post('/delete-eligibility-template',deleteEligibilityTemplate);
eligibilityTemplateRouter.post('/update-eligibility-template',updateEligibilityTemplate);
eligibilityTemplateRouter.get('/view-eligibility-template',viewEligibilityTemplate);
eligibilityTemplateRouter.post('/submit-eligibility-response',submitEligibilityResponse);

module.exports = eligibilityTemplateRouter ;