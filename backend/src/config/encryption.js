// Muud Health — AES-256-GCM Encryption for PHI Fields
// © Muud Health — Armin Hoes, MD

const crypto = require('crypto');
const logger = require('../utils/logger');

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12; // 96 bits — NIST recommended for GCM
const TAG_LENGTH = 16;
const ENCODING = 'base64';

/**
 * Get encryption key from environment.
 * Key must be a 64-character hex string (32 bytes).
 */
function getKey() {
  const hex = process.env.ENCRYPTION_KEY;
  if (!hex || hex.length !== 64) {
    throw new Error(
      'ENCRYPTION_KEY must be a 64-character hex string. ' +
      'Generate with: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"'
    );
  }
  return Buffer.from(hex, 'hex');
}

/**
 * Encrypt a plaintext string using AES-256-GCM.
 *
 * @param {string} plaintext - Data to encrypt
 * @returns {string} Base64-encoded string containing IV + ciphertext + auth tag
 */
function encrypt(plaintext) {
  if (!plaintext || typeof plaintext !== 'string') return plaintext;

  const key = getKey();
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv, { authTagLength: TAG_LENGTH });

  const encrypted = Buffer.concat([
    cipher.update(plaintext, 'utf8'),
    cipher.final(),
  ]);
  const tag = cipher.getAuthTag();

  // Pack: IV (12) + tag (16) + ciphertext
  const packed = Buffer.concat([iv, tag, encrypted]);
  return packed.toString(ENCODING);
}

/**
 * Decrypt a Base64-encoded encrypted string.
 *
 * @param {string} encryptedString - Base64 string from encrypt()
 * @returns {string} Original plaintext
 */
function decrypt(encryptedString) {
  if (!encryptedString || typeof encryptedString !== 'string') return encryptedString;

  const key = getKey();
  const packed = Buffer.from(encryptedString, ENCODING);

  if (packed.length < IV_LENGTH + TAG_LENGTH + 1) {
    throw new Error('Invalid encrypted data: too short');
  }

  const iv = packed.subarray(0, IV_LENGTH);
  const tag = packed.subarray(IV_LENGTH, IV_LENGTH + TAG_LENGTH);
  const ciphertext = packed.subarray(IV_LENGTH + TAG_LENGTH);

  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv, { authTagLength: TAG_LENGTH });
  decipher.setAuthTag(tag);

  const decrypted = Buffer.concat([
    decipher.update(ciphertext),
    decipher.final(),
  ]);

  return decrypted.toString('utf8');
}

/**
 * Deterministic hash for PHI fields (enables encrypted search).
 * Uses HMAC-SHA256 with a separate key derived from the encryption key.
 *
 * @param {string} value - Plaintext PHI value to hash
 * @returns {string} Hex-encoded HMAC digest
 */
function hashPHI(value) {
  if (!value || typeof value !== 'string') return value;

  const key = getKey();
  // Derive a separate HMAC key using HKDF-like approach
  const hmacKey = crypto.createHmac('sha256', key)
    .update('muud-phi-search-key')
    .digest();

  return crypto.createHmac('sha256', hmacKey)
    .update(value.toLowerCase().trim())
    .digest('hex');
}

/**
 * Encrypt specific fields of an object (immutable — returns new object).
 *
 * @param {Object} obj - Source object
 * @param {string[]} fields - Field names to encrypt
 * @returns {Object} New object with specified fields encrypted
 */
function encryptFields(obj, fields) {
  if (!obj || typeof obj !== 'object') return obj;

  const result = { ...obj };
  for (const field of fields) {
    if (result[field] != null && typeof result[field] === 'string') {
      result[field] = encrypt(result[field]);
    }
  }
  return result;
}

/**
 * Decrypt specific fields of an object (immutable — returns new object).
 *
 * @param {Object} obj - Source object
 * @param {string[]} fields - Field names to decrypt
 * @returns {Object} New object with specified fields decrypted
 */
function decryptFields(obj, fields) {
  if (!obj || typeof obj !== 'object') return obj;

  const result = { ...obj };
  for (const field of fields) {
    if (result[field] != null && typeof result[field] === 'string') {
      try {
        result[field] = decrypt(result[field]);
      } catch (err) {
        logger.warn({ field, err: err.message }, 'Failed to decrypt field — may be unencrypted');
      }
    }
  }
  return result;
}

module.exports = {
  encrypt,
  decrypt,
  hashPHI,
  encryptFields,
  decryptFields,
};
