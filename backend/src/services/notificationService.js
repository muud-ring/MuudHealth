// backend/src/services/notificationService.js
//
// Unified notification dispatcher — routes messages to the appropriate
// channel (email, SMS) based on available configuration.

const emailService = require("./emailService");
const smsService = require("./smsService");
const logger = require("../config/logger");

/**
 * Send an OTP code to a user via the appropriate channel.
 * @param {string} identifier - Email address or phone number
 * @param {string} code - OTP code
 */
async function sendOtp(identifier, code) {
  try {
    if (identifier.includes("@")) {
      return await emailService.sendOtpEmail(identifier, code);
    }
    return await smsService.sendOtpSms(identifier, code);
  } catch (err) {
    logger.error("Failed to send OTP", { identifier, error: err.message });
    throw err;
  }
}

/**
 * Send a welcome notification after successful signup.
 * @param {string} email - User's email address
 * @param {string} name - User's display name
 */
async function sendWelcome(email, name) {
  try {
    return await emailService.sendWelcomeEmail(email, name);
  } catch (err) {
    // Welcome emails are non-critical — log but don't throw
    logger.error("Failed to send welcome email", { email, error: err.message });
    return null;
  }
}

module.exports = { sendOtp, sendWelcome };
