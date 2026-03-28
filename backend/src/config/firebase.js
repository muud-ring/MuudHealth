// backend/src/config/firebase.js
const admin = require("firebase-admin");
const logger = require("../utils/logger");

let initialized = false;

function initFirebase() {
  if (initialized) return;

  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

  if (!serviceAccount) {
    logger.warn("FIREBASE_SERVICE_ACCOUNT_JSON not set — push notifications disabled");
    return;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccount)),
    });
    initialized = true;
    logger.info("Firebase Admin initialized");
  } catch (err) {
    logger.error({ err }, "Failed to initialize Firebase Admin");
  }
}

function getMessaging() {
  if (!initialized) return null;
  return admin.messaging();
}

module.exports = { initFirebase, getMessaging };
