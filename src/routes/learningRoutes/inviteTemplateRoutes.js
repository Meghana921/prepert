import Router from "express";
import addInviteTemplate from '../../controllers/learningController/addInviteTemplateController.js';
import listInviteTemplates from '../../controllers/learningController/listInviteTemplateController.js';
import updateInviteTemplate from '../../controllers/learningController/updateInviteTemplateController.js';
import viewInviteTemplate from '../../controllers/learningController/viewInviteTemplateController.js';
import addInvitee from '../../controllers/learningController/addInvitee.js';
import listAllInvitations from '../../controllers/learningController/listInvitations.js'
const router = Router();

router.post('/add-invite-template', addInviteTemplate);
router.get('/list-invite-template', listInviteTemplates);
router.put('/update-invite-template', updateInviteTemplate);
router.get('/view-invite-template', viewInviteTemplate);
router.post('/add-invitee',addInvitee);
router.get('/list-invitation',listAllInvitations)

export default router;