import Router from "express";
import addInviteTemplate from '../../controllers/learningController/addInviteTemplateController.js';
import listInviteTemplates from '../../controllers/learningController/listInviteTemplateController.js';
import updateInviteTemplate from '../../controllers/learningController/updateInviteTemplateController.js';
import viewInviteTemplate from '../../controllers/learningController/viewInviteTemplateController.js';

const router = Router();

router.post('/add-invite-template', addInviteTemplate);
router.get('/list-invite-template', listInviteTemplates);
router.put('/update-invite-template', updateInviteTemplate);
router.get('/view-invite-template', viewInviteTemplate);

export default router;