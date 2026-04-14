// Muud Health — Shared Vault Routes
// © Muud Health — Armin Hoes, MD
//
// Cross-platform vault API: items saved in app appear in portal and vice versa.
// Supports individual sharing and organization-level vault access.

const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const { fullAccountContext } = require('../middleware/platformAuth');
const { requireEntitlement, FEATURES } = require('../config/entitlements');
const {
  syncVaultItem,
  shareVaultItem,
  getSharedVaultItems,
  SharedVaultEntry,
} = require('../services/crossPlatformSyncService');
const logger = require('../utils/logger');

// ── POST /shared-vault/sync — Sync a vault item across platforms ─
router.post(
  '/sync',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_VAULT),
  async (req, res, next) => {
    try {
      const { vaultItemId } = req.body;
      if (!vaultItemId) return res.status(400).json({ error: 'vaultItemId required' });

      const entry = await syncVaultItem(req.user.sub, vaultItemId, req.platform);
      if (!entry) return res.status(500).json({ error: 'Sync failed' });

      res.json({ message: 'Vault item synced', entry: entry.toObject() });
    } catch (err) {
      next(err);
    }
  }
);

// ── POST /shared-vault/share — Share a vault item with a user ────
router.post(
  '/share',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_VAULT_SHARED),
  async (req, res, next) => {
    try {
      const { vaultItemId, targetSub, accessLevel = 'view' } = req.body;
      if (!vaultItemId || !targetSub) {
        return res.status(400).json({ error: 'vaultItemId and targetSub required' });
      }

      if (targetSub === req.user.sub) {
        return res.status(400).json({ error: 'Cannot share with yourself' });
      }

      const entry = await shareVaultItem(req.user.sub, vaultItemId, targetSub, accessLevel);
      if (!entry) return res.status(500).json({ error: 'Share failed' });

      logger.info({ ownerSub: req.user.sub, targetSub, vaultItemId }, 'Vault item shared');
      res.json({ message: 'Item shared', entry: entry.toObject() });
    } catch (err) {
      next(err);
    }
  }
);

// ── GET /shared-vault/shared-with-me — Items shared with user ────
router.get(
  '/shared-with-me',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_VAULT),
  async (req, res, next) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = Math.min(parseInt(req.query.limit) || 20, 50);

      const items = await getSharedVaultItems(req.user.sub, { page, limit });
      res.json({ items, page, limit });
    } catch (err) {
      next(err);
    }
  }
);

// ── GET /shared-vault/my-shared — Items I've shared ──────────────
router.get(
  '/my-shared',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_VAULT_SHARED),
  async (req, res, next) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = Math.min(parseInt(req.query.limit) || 20, 50);
      const skip = (page - 1) * limit;

      const items = await SharedVaultEntry.find({
        ownerSub: req.user.sub,
        'sharedWith.0': { $exists: true },
      })
        .sort({ updatedAt: -1 })
        .skip(skip)
        .limit(limit);

      res.json({ items, page, limit });
    } catch (err) {
      next(err);
    }
  }
);

// ── DELETE /shared-vault/share/:entryId/:targetSub — Revoke share
router.delete(
  '/share/:entryId/:targetSub',
  requireAuth,
  fullAccountContext,
  async (req, res, next) => {
    try {
      const entry = await SharedVaultEntry.findOne({
        _id: req.params.entryId,
        ownerSub: req.user.sub,
      });

      if (!entry) return res.status(404).json({ error: 'Shared entry not found' });

      entry.sharedWith = entry.sharedWith.filter((s) => s.sub !== req.params.targetSub);
      await entry.save();

      res.json({ message: 'Share revoked' });
    } catch (err) {
      next(err);
    }
  }
);

// ── GET /shared-vault/sync-status — Sync status for user ─────────
router.get(
  '/sync-status',
  requireAuth,
  fullAccountContext,
  async (req, res, next) => {
    try {
      const entries = await SharedVaultEntry.find({ ownerSub: req.user.sub })
        .select('vaultItemId syncedPlatforms updatedAt')
        .sort({ updatedAt: -1 })
        .limit(100);

      const stats = {
        totalEntries: entries.length,
        syncedToApp: entries.filter((e) => e.syncedPlatforms?.app?.synced).length,
        syncedToPortal: entries.filter((e) => e.syncedPlatforms?.portal?.synced).length,
        fullySynced: entries.filter(
          (e) => e.syncedPlatforms?.app?.synced && e.syncedPlatforms?.portal?.synced
        ).length,
      };

      res.json({ syncStatus: stats, entries });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
