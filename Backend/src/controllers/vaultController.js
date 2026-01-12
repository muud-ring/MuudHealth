// backend/src/controllers/vaultController.js
const VaultItem = require("../models/VaultItem");
const Post = require("../models/Post");
const UserProfile = require("../models/UserProfile");

const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { s3 } = require("../config/s3");

const BUCKET = process.env.S3_BUCKET;

async function signKey(key, expiresIn = 600) {
  if (!BUCKET || !key) return null;
  const cmd = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return await getSignedUrl(s3, cmd, { expiresIn });
}

function normalizeCategory(v) {
  const s = (v || "").toString().toLowerCase().trim();
  const allowed = new Set([
    "family",
    "friends",
    "events",
    "holidays",
    "work",
    "school",
    "other",
  ]);
  return allowed.has(s) ? s : "other";
}

function toValidDate(v) {
  if (!v) return null;
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
}

function mapVaultCard({ post, authorProfile, imageUrl, audioUrl, authorAvatarUrl }) {
  return {
    id: post._id,
    caption: post.caption || "",
    createdAt: post.createdAt,
    visibility: post.visibility || "public",

    imageUrl,
    audioUrl,

    author: {
      sub: post.authorSub,
      username: authorProfile?.username || "",
      name: authorProfile?.name || "",
      location: authorProfile?.location || "",
      avatarUrl: authorAvatarUrl,
    },
  };
}

// POST /vault/save
// body: { sourceType:"post", sourceId:"...", category:"family", tags:[{type,value}], experienceType:"group" }
exports.save = async (req, res) => {
  try {
    const ownerSub = req.user.sub;

    const sourceType = (req.body?.sourceType || "post").toString();
    const sourceId = (req.body?.sourceId || "").toString().trim();
    const category = normalizeCategory(req.body?.category);
    const experienceType = (req.body?.experienceType || "").toString().trim();
    const tags = Array.isArray(req.body?.tags) ? req.body.tags : [];

    if (sourceType !== "post") {
      return res
        .status(400)
        .json({ message: "Only sourceType=post supported for now" });
    }
    if (!sourceId) return res.status(400).json({ message: "sourceId required" });

    // ensure post exists
    const post = await Post.findById(sourceId).select("_id authorSub").lean();
    if (!post) return res.status(404).json({ message: "Post not found" });

    // MVP: allow saving own post only
    if (post.authorSub !== ownerSub) {
      return res
        .status(403)
        .json({ message: "For MVP, you can only save your own posts" });
    }

    const cleanTags = tags
      .filter((t) => t && t.type && t.value)
      .map((t) => ({
        type: t.type,
        value: t.value,
      }));

    // ✅ Upsert: create if not exists, otherwise UPDATE category/tags
    const savedAt = new Date();

    const doc = await VaultItem.findOneAndUpdate(
      { ownerSub, sourceType: "post", sourceId: post._id },
      {
        $set: {
          category,
          tags: cleanTags,
          experienceType,
          savedAt,
        },
        $setOnInsert: {
          ownerSub,
          sourceType: "post",
          sourceId: post._id,
        },
      },
      { upsert: true, new: true }
    );

    return res.status(200).json({ ok: true, item: doc });
  } catch (err) {
    console.error("vault.save error:", err);
    return res.status(500).json({ message: "Failed to save to vault" });
  }
};

// DELETE /vault/save?sourceId=<postId>
exports.unsave = async (req, res) => {
  try {
    const ownerSub = req.user.sub;
    const sourceId = (req.query?.sourceId || "").toString().trim();
    if (!sourceId) return res.status(400).json({ message: "sourceId required" });

    await VaultItem.deleteOne({ ownerSub, sourceType: "post", sourceId });

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error("vault.unsave error:", err);
    return res.status(500).json({ message: "Failed to remove from vault" });
  }
};

// GET /vault/items?category=friends&limit=20&cursor=<savedAtISO>&from=<ISO>&to=<ISO>
// NOTE: cursor is still based on vault.savedAt (bookmark date) for paging,
// but filtering is applied to post.createdAt (journal/post date) to match your expectation.
exports.items = async (req, res) => {
  try {
    const ownerSub = req.user.sub;

    const category = req.query?.category
      ? normalizeCategory(req.query.category)
      : null;

    const limit = Math.min(parseInt(req.query?.limit || "20", 10) || 20, 50);
    const cursor = (req.query?.cursor || "").toString().trim(); // vault.savedAt ISO

    // ✅ date filters (we will apply to post.createdAt)
    const from = (req.query?.from || "").toString().trim(); // ISO
    const to = (req.query?.to || "").toString().trim(); // ISO
    const fromD = toValidDate(from);
    const toD = toValidDate(to);

    const q = { ownerSub, sourceType: "post" };
    if (category) q.category = category;

    // cursor pagination uses vault savedAt
    if (cursor) q.savedAt = { $lt: new Date(cursor) };

    // If date filtering is active, fetch a bigger batch first,
// then filter down to the requested limit.
// (Fixes “empty results” when first 20 don’t match date range)
const dateFilteringOn = !!(fromD || toD);
const fetchLimit = dateFilteringOn ? Math.min(limit * 10, 200) : limit;

const vaultItems = await VaultItem.find(q)
  .sort({ savedAt: -1 })
  .limit(fetchLimit)
  .lean();


    const postIds = vaultItems.map((v) => v.sourceId);
    const posts = postIds.length
      ? await Post.find({ _id: { $in: postIds } }).lean()
      : [];

    const postById = new Map(posts.map((p) => [String(p._id), p]));

    // author profiles
    const authorSubs = [...new Set(posts.map((p) => p.authorSub).filter(Boolean))];
    const profiles = authorSubs.length
      ? await UserProfile.find({ sub: { $in: authorSubs } })
          .select("sub username name location avatarKey")
          .lean()
      : [];

    const profileBySub = new Map(profiles.map((p) => [p.sub, p]));

    const out = await Promise.all(
      vaultItems.map(async (v) => {
        const post = postById.get(String(v.sourceId));
        if (!post) return null;

        const authorProfile = profileBySub.get(post.authorSub);

        const firstImageKey = (post.mediaKeys && post.mediaKeys[0]) || "";
        const imageUrl = firstImageKey ? await signKey(firstImageKey) : null;
        const audioUrl = post.audioKey ? await signKey(post.audioKey) : null;

        const authorAvatarUrl = authorProfile?.avatarKey
          ? await signKey(authorProfile.avatarKey)
          : null;

        return {
          vault: {
            id: v._id,
            category: v.category,
            tags: v.tags || [],
            experienceType: v.experienceType || "",
            savedAt: v.savedAt, // bookmark date
          },
          post: mapVaultCard({ post, authorProfile, imageUrl, audioUrl, authorAvatarUrl }),
        };
      })
    );

    // base clean
    let cleaned = out.filter(Boolean);

    // ✅ Apply date filter to POST createdAt (journal/post date)
    if (fromD || toD) {
      // include full "to" day (23:59:59.999)
      const toEnd = toD ? new Date(toD.getTime()) : null;
      if (toEnd) {
        toEnd.setHours(23, 59, 59, 999);
      }
    
      cleaned = cleaned.filter((x) => {
        const created = toValidDate(x.post.createdAt);
        if (!created) return false;
        if (fromD && created < fromD) return false;
        if (toEnd && created > toEnd) return false;
        return true;
      });
    }

    cleaned = cleaned.slice(0, limit);

    const nextCursor = cleaned.length
      ? cleaned[cleaned.length - 1].vault.savedAt.toISOString()
      : null;

    return res.status(200).json({ items: cleaned, nextCursor });
  } catch (err) {
    console.error("vault.items error:", err);
    return res.status(500).json({ message: "Failed to load vault items" });
  }
};

// GET /vault/landing
// Returns the 7 sections with small previews (like Figma)
exports.landing = async (req, res) => {
  try {
    const ownerSub = req.user.sub;

    const categories = [
      { key: "family", title: "Family" },
      { key: "friends", title: "Friends" },
      { key: "events", title: "Events" },
      { key: "holidays", title: "Holidays" },
      { key: "work", title: "Work" },
      { key: "school", title: "School" },
      { key: "other", title: "Other" },
    ];

    const sections = await Promise.all(
      categories.map(async (c) => {
        const vaultItems = await VaultItem.find({
          ownerSub,
          sourceType: "post",
          category: c.key,
        })
          .sort({ savedAt: -1 })
          .limit(3)
          .lean();

        const postIds = vaultItems.map((v) => v.sourceId);
        const posts = postIds.length ? await Post.find({ _id: { $in: postIds } }).lean() : [];
        const postById = new Map(posts.map((p) => [String(p._id), p]));

        // for MVP, all posts are yours; we’ll still keep structure ready
        const profile = await UserProfile.findOne({ sub: ownerSub })
          .select("sub username name location avatarKey")
          .lean();

        const avatarUrl = profile?.avatarKey ? await signKey(profile.avatarKey) : null;

        const preview = await Promise.all(
          vaultItems.map(async (v) => {
            const post = postById.get(String(v.sourceId));
            if (!post) return null;

            const firstImageKey = (post.mediaKeys && post.mediaKeys[0]) || "";
            const imageUrl = firstImageKey ? await signKey(firstImageKey) : null;

            return {
              vaultId: v._id,
              sourceId: v.sourceId,
              imageUrl,
              caption: post.caption || "",
              createdAt: post.createdAt,
              author: {
                username: profile?.username || "",
                name: profile?.name || "",
                location: profile?.location || "",
                avatarUrl,
              },
            };
          })
        );

        const count = await VaultItem.countDocuments({
          ownerSub,
          sourceType: "post",
          category: c.key,
        });

        return {
          key: c.key,
          title: c.title,
          count,
          preview: preview.filter(Boolean),
        };
      })
    );

    return res.status(200).json({ sections });
  } catch (err) {
    console.error("vault.landing error:", err);
    return res.status(500).json({ message: "Failed to load vault landing" });
  }
};
