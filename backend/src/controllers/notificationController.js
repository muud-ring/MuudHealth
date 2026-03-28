// backend/src/controllers/notificationController.js
const UserProfile = require("../models/UserProfile");
const { getMessaging } = require("../config/firebase");
const logger = require("../utils/logger");

// POST /notifications/register-device
// body: { token, platform }
exports.registerDevice = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    if (!mySub) return res.status(401).json({ message: "Missing user sub" });

    const token = (req.body?.token || "").trim();
    const platform = (req.body?.platform || "unknown").trim();

    if (!token) {
      return res.status(400).json({ message: "token is required" });
    }

    // Add token to user's device list (avoid duplicates)
    await UserProfile.updateOne(
      { sub: mySub },
      {
        $addToSet: {
          fcmTokens: { token, platform, registeredAt: new Date() },
        },
      }
    );

    return res.status(200).json({ message: "Device registered" });
  } catch (err) {
    logger.error({ err }, "registerDevice failed");
    return res.status(500).json({ message: "Server error" });
  }
};

// DELETE /notifications/unregister-device
// body: { token }
exports.unregisterDevice = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    if (!mySub) return res.status(401).json({ message: "Missing user sub" });

    const token = (req.body?.token || "").trim();
    if (!token) {
      return res.status(400).json({ message: "token is required" });
    }

    await UserProfile.updateOne(
      { sub: mySub },
      { $pull: { fcmTokens: { token } } }
    );

    return res.status(200).json({ message: "Device unregistered" });
  } catch (err) {
    logger.error({ err }, "unregisterDevice failed");
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * Send a push notification to a specific user.
 * Called internally by other controllers (chat, people, etc.)
 *
 * @param {string} targetSub - The Cognito sub of the target user
 * @param {object} payload - { title, body, data? }
 */
async function sendPushToUser(targetSub, { title, body, data = {} }) {
  const messaging = getMessaging();
  if (!messaging) return; // FCM not configured

  try {
    const user = await UserProfile.findOne(
      { sub: targetSub },
      { fcmTokens: 1 }
    ).lean();

    if (!user?.fcmTokens?.length) return;

    const tokens = user.fcmTokens.map((t) => t.token);

    const message = {
      notification: { title, body },
      data: { ...data, type: data.type || "general" },
      tokens,
    };

    const result = await messaging.sendEachForMulticast(message);

    // Clean up invalid tokens
    if (result.failureCount > 0) {
      const invalidTokens = [];
      result.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const code = resp.error?.code;
          if (
            code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered"
          ) {
            invalidTokens.push(tokens[idx]);
          }
        }
      });

      if (invalidTokens.length > 0) {
        await UserProfile.updateOne(
          { sub: targetSub },
          { $pull: { fcmTokens: { token: { $in: invalidTokens } } } }
        );
      }
    }
  } catch (err) {
    logger.error({ err, targetSub }, "sendPushToUser failed");
  }
}

exports.sendPushToUser = sendPushToUser;
