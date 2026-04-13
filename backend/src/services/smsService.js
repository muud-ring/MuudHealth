// backend/src/services/smsService.js
const logger = require("../utils/logger");

let twilioClient = null;

function getClient() {
  if (twilioClient) return twilioClient;

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;

  if (!accountSid || !authToken) {
    logger.warn("Twilio not configured — TWILIO_ACCOUNT_SID or TWILIO_AUTH_TOKEN missing");
    return null;
  }

  twilioClient = require("twilio")(accountSid, authToken);
  return twilioClient;
}

/**
 * Send an SMS via Twilio.
 * @param {Object} opts
 * @param {string} opts.to - Recipient phone number (E.164 format)
 * @param {string} opts.body - Message body
 * @param {string} [opts.from] - Sender phone number (defaults to TWILIO_PHONE_NUMBER)
 * @returns {Promise<Object|null>} Twilio message response or null if not configured
 */
async function sendSms({ to, body, from }) {
  const client = getClient();
  if (!client) {
    logger.warn("SMS not sent — Twilio not configured", { to });
    return null;
  }

  const sender = from || process.env.TWILIO_PHONE_NUMBER;
  if (!sender) {
    logger.warn("SMS not sent — TWILIO_PHONE_NUMBER not set", { to });
    return null;
  }

  const message = await client.messages.create({
    to,
    from: sender,
    body,
  });

  logger.info("SMS sent", { to, sid: message.sid });
  return message;
}

/**
 * Send an OTP verification code via SMS.
 */
async function sendOtpSms(to, code) {
  return sendSms({
    to,
    body: `Your Muud Health verification code is: ${code}. This code expires in 10 minutes.`,
  });
}

module.exports = { sendSms, sendOtpSms };
