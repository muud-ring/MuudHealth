const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const validate = require('../middleware/validate');
const rules = require('../validators/biometricsValidators');
const ctrl = require('../controllers/biometricsController');

router.use(requireAuth);

router.post('/reading', rules.recordReading, validate, ctrl.recordReading);
router.post('/batch', rules.recordBatch, validate, ctrl.recordBatch);
router.get('/history', rules.getHistory, validate, ctrl.getHistory);
router.get('/latest', ctrl.getLatest);
router.get('/summary/:date', rules.getDailySummary, validate, ctrl.getDailySummary);
router.get('/summaries', rules.getSummaryRange, validate, ctrl.getSummaryRange);

module.exports = router;
