// Muud Health — Compliance Admin Routes
// © Muud Health — Armin Hoes, MD

const express = require('express');
const router = express.Router();

const requireAuth = require('../middleware/requireAuth');
const { authorize } = require('../middleware/authorize');
const { toBAAReport, validateAllBAAs } = require('../compliance/baaTracker');
const { generatePentestReport, runSecurityChecklist } = require('../compliance/pentestFramework');
const { getResidencyReport } = require('../config/dataResidency');
const auditService = require('../services/auditService');

// All compliance routes require admin role
router.use(requireAuth, authorize('admin'));

// BAA compliance report
router.get('/baa', (_req, res) => {
  res.json(toBAAReport());
});

// BAA validation status
router.get('/baa/validate', (_req, res) => {
  res.json(validateAllBAAs());
});

// Penetration test report
router.get('/pentest', (_req, res) => {
  res.json(generatePentestReport());
});

// Security checklist
router.get('/security-checklist', (_req, res) => {
  res.json(runSecurityChecklist());
});

// Data residency report
router.get('/data-residency', (_req, res) => {
  res.json(getResidencyReport());
});

// Audit log query
router.get('/audit-logs', async (req, res) => {
  const { actor, action, resource, startDate, endDate, page, limit } = req.query;
  const filters = {};
  if (actor) filters.actor = actor;
  if (action) filters.action = action;
  if (resource) filters.resource = resource;
  if (startDate || endDate) {
    filters.timestamp = {};
    if (startDate) filters.timestamp.$gte = new Date(startDate);
    if (endDate) filters.timestamp.$lte = new Date(endDate);
  }

  const result = await auditService.query(filters, {
    page: parseInt(page) || 1,
    limit: parseInt(limit) || 50,
  });
  res.json(result);
});

// Compliance report (combined)
router.get('/audit-report', async (req, res) => {
  const { startDate, endDate } = req.query;
  const start = startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  const end = endDate || new Date().toISOString();
  const report = await auditService.generateComplianceReport(start, end);
  res.json(report);
});

module.exports = router;
