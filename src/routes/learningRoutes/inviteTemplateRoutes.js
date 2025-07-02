const express = require('express');
const router = express.Router();
const addInviteTemplate = require('../../controllers/learningController/addInviteTemplateController');
const listInviteTemplates = require('../../controllers/learningController/listInviteTemplateController');
const updateInviteTemplate = require('../../controllers/learningController/updateInviteTemplateController');
const viewInviteTemplate = require('../../controllers/learningController/viewInviteTemplateController');

router.get('/list-invite-template', listInviteTemplates);
router.post('/add-invite-template', addInviteTemplate);
router.post('/update-invite-template', updateInviteTemplate);
router.get('/view-invite-template', viewInviteTemplate);

module.exports = router;