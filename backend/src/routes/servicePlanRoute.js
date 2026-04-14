// Muud Health — Service Plan Routes
// © Muud Health — Armin Hoes, MD
//
// CRUD + management for Muud Clinic (PMF/TMF/CMF), Academy, and Coaching plans.

const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const { fullAccountContext } = require('../middleware/platformAuth');
const { authorize } = require('../middleware/authorize');
const ServicePlan = require('../models/ServicePlan');
const Account = require('../models/Account');
const logger = require('../utils/logger');

// ── GET /service-plans — Get user's service plans ────────────────
router.get('/', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const { status, category } = req.query;
    const filter = { ownerSub: req.user.sub };
    if (status) filter.status = status;
    if (category) filter.category = category;

    const plans = await ServicePlan.find(filter).sort({ createdAt: -1 });
    res.json({ plans });
  } catch (err) {
    next(err);
  }
});

// ── GET /service-plans/active — Get highest-priority active plan ─
router.get('/active', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const plan = await ServicePlan.findOne({
      ownerSub: req.user.sub,
      status: 'active',
    }).sort({ impliedTier: 1 }); // Lowest tier = highest priority

    if (!plan) return res.json({ plan: null, message: 'No active service plan' });

    res.json({
      plan: plan.toObject(),
      summary: plan.getSummary(),
      impliedTier: plan.impliedTier,
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /service-plans — Create a service plan (admin/clinician) ─
router.post('/', requireAuth, fullAccountContext, authorize('clinician', 'admin'), async (req, res, next) => {
  try {
    const {
      ownerSub, category, planType, frequency, sessionDuration,
      academy, coaching, clinic, pricing, startDate, organizationId,
    } = req.body;

    if (!ownerSub || !category) {
      return res.status(400).json({ error: 'ownerSub and category are required' });
    }

    const plan = new ServicePlan({
      ownerSub,
      category,
      planType: planType || 'general',
      frequency: frequency || 'monthly',
      sessionDuration,
      academy,
      coaching,
      clinic,
      pricing,
      startDate: startDate || new Date(),
      status: 'active',
      organizationId,
    });

    await plan.save();

    // Auto-recalculate the user's account tier
    const account = await Account.findOne({ ownerSub });
    if (account && account.accountType === 'I') {
      const newTier = Account.computeIndividualTier(plan, account);
      account.tier = newTier;
      account.individual.activeServicePlanId = plan._id;
      account.lastTierRecalculation = new Date();
      await account.save();

      logger.info({ ownerSub, planId: plan._id, newTier }, 'Tier recalculated after plan creation');
    }

    res.status(201).json({
      plan: plan.toObject(),
      summary: plan.getSummary(),
    });
  } catch (err) {
    next(err);
  }
});

// ── PATCH /service-plans/:id — Update plan ───────────────────────
router.patch('/:id', requireAuth, fullAccountContext, authorize('clinician', 'admin'), async (req, res, next) => {
  try {
    const plan = await ServicePlan.findById(req.params.id);
    if (!plan) return res.status(404).json({ error: 'Service plan not found' });

    const allowedFields = [
      'frequency', 'status', 'endDate', 'coaching', 'clinic', 'academy', 'pricing',
    ];

    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        plan[field] = req.body[field];
      }
    }

    await plan.save();

    // Recalculate tier if status changed
    if (req.body.status) {
      const account = await Account.findOne({ ownerSub: plan.ownerSub });
      if (account && account.accountType === 'I') {
        const activePlan = await ServicePlan.findOne({
          ownerSub: plan.ownerSub,
          status: 'active',
        }).sort({ impliedTier: 1 });

        account.tier = Account.computeIndividualTier(activePlan, account);
        account.individual.activeServicePlanId = activePlan?._id || null;
        account.lastTierRecalculation = new Date();
        await account.save();
      }
    }

    res.json({ plan: plan.toObject(), summary: plan.getSummary() });
  } catch (err) {
    next(err);
  }
});

// ── GET /service-plans/catalog — Available plan catalog ──────────
router.get('/catalog', async (_req, res) => {
  const catalog = {
    clinic: {
      description: 'Muud Clinic Healthcare Services (3×3×3)',
      plans: [
        {
          planType: 'PMF',
          name: 'Psychiatry & Mental Fitness',
          duration: 45,
          frequencies: ['weekly', 'biweekly', 'monthly'],
          tierImpact: { weekly: 2, biweekly: 2, monthly: 3 },
        },
        {
          planType: 'TMF',
          name: 'Therapy & Mental Fitness',
          duration: 60,
          frequencies: ['weekly', 'biweekly', 'monthly'],
          tierImpact: { weekly: 2, biweekly: 2, monthly: 3 },
        },
        {
          planType: 'CMF',
          name: 'Combined Mental Fitness',
          duration: 75,
          frequencies: ['weekly', 'biweekly', 'monthly'],
          tierImpact: { weekly: 1, biweekly: 1, monthly: 3 },
        },
      ],
    },
    academy: {
      description: 'Muud Academy — Instructional training programs',
      programs: ['NBHWC Certification', 'Wellness Fundamentals', 'Mental Fitness Coaching'],
      tierImpact: 3,
    },
    coaching: {
      description: 'Muud Coaching — Interventional wellness coaching',
      frequencies: ['weekly', 'biweekly'],
      tierImpact: 3,
    },
    content: {
      description: 'Premium Content Subscription (SAAS)',
      tierImpact: 4,
      note: 'All Muud Ring users are automatically enrolled in Tier 4 (premium content)',
    },
    freemium: {
      description: 'Free account with limited features',
      tierImpact: 5,
      features: 'Basic app features, no premium content, no AI, no ring',
    },
  };

  res.json({ catalog });
});

module.exports = router;
