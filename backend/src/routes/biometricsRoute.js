const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const ctrl = require('../controllers/biometricsController');

router.use(requireAuth);

router.post('/reading', ctrl.recordReading);
router.post('/batch', ctrl.recordBatch);
router.get('/history', ctrl.getHistory);
router.get('/latest', ctrl.getLatest);
router.get('/summary/:date', ctrl.getDailySummary);
router.get('/summaries', ctrl.getSummaryRange);

module.exports = router;
