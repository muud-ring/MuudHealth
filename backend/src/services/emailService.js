// backend/src/services/emailService.js
const FormData = require("form-data");
const Mailgun = require("mailgun.js");
const logger = require("../config/logger");

const mailgun = new Mailgun(FormData);

let mg = null;

function getClient() {
  if (mg) return mg;

  const apiKey = process.env.MAILGUN_API_KEY;
  const domain = process.env.MAILGUN_DOMAIN;

  if (!apiKey || !domain) {
    logger.warn("Mailgun not configured — MAILGUN_API_KEY or MAILGUN_DOMAIN missing");
    return null;
  }

  mg = mailgun.client({ username: "api", key: apiKey });
  return mg;
}

/**
 * Send an email via Mailgun.
 * @param {Object} opts
 * @param {string} opts.to - Recipient email address
 * @param {string} opts.subject - Email subject line
 * @param {string} opts.text - Plain text body
 * @param {string} [opts.html] - HTML body (optional)
 * @param {string} [opts.from] - Sender address (defaults to MAILGUN_FROM)
 * @returns {Promise<Object|null>} Mailgun response or null if not configured
 */
async function sendEmail({ to, subject, text, html, from }) {
  const client = getClient();
  if (!client) {
    logger.warn("Email not sent — Mailgun not configured", { to, subject });
    return null;
  }

  const domain = process.env.MAILGUN_DOMAIN;
  const sender = from || process.env.MAILGUN_FROM || `Muud Health <noreply@${domain}>`;

  const data = { from: sender, to: [to], subject, text };
  if (html) data.html = html;

  const result = await client.messages.create(domain, data);
  logger.info("Email sent", { to, subject, id: result.id });
  return result;
}

/**
 * Send an OTP verification email.
 */
async function sendOtpEmail(to, code) {
  return sendEmail({
    to,
    subject: "Your Muud Health verification code",
    text: `Your verification code is: ${code}\n\nThis code expires in 10 minutes.`,
    html: `
      <div style="font-family: sans-serif; max-width: 400px; margin: 0 auto; padding: 24px;">
        <h2 style="color: #5B288E;">Muud Health</h2>
        <p>Your verification code is:</p>
        <p style="font-size: 32px; font-weight: bold; color: #5B288E; letter-spacing: 4px;">${code}</p>
        <p style="color: #888;">This code expires in 10 minutes.</p>
      </div>
    `,
  });
}

/**
 * Send a welcome email after signup.
 */
async function sendWelcomeEmail(to, name) {
  return sendEmail({
    to,
    subject: "Welcome to Muud Health",
    text: `Hi ${name},\n\nWelcome to Muud Health! We're glad you're here.\n\nThe Muud Team`,
  });
}

module.exports = { sendEmail, sendOtpEmail, sendWelcomeEmail };
