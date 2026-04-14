// Muud Health — Test Setup & Utilities
// © Muud Health — Armin Hoes, MD

process.env.NODE_ENV = 'test';
process.env.DEV_AUTH = 'true';
process.env.PORT = '0'; // Random port for tests
process.env.MONGO_URI = 'mongodb://localhost:27017/muud-test';
process.env.AWS_REGION = 'us-west-2';
process.env.COGNITO_USER_POOL_ID = 'dev-pool';
process.env.COGNITO_CLIENT_ID = 'dev-client';
process.env.ENCRYPTION_KEY = 'a'.repeat(64); // Test-only key

/**
 * Create a mock user object matching requireAuth output.
 */
function createMockUser(overrides = {}) {
  return {
    sub: 'test-user-001',
    username: 'testuser',
    role: 'user',
    scope: 'openid profile',
    client_id: 'dev-client',
    token_use: 'access',
    claims: { sub: 'test-user-001', preferred_username: 'testuser' },
    ...overrides,
  };
}

/**
 * Create a dev auth token for test requests.
 */
function createMockToken(sub = 'test-user-001') {
  return `dev-${sub}`;
}

/**
 * Create a mock Express request object.
 */
function createMockReq(overrides = {}) {
  return {
    user: createMockUser(),
    ip: '127.0.0.1',
    headers: {
      'user-agent': 'MuudHealthTest/1.0',
      authorization: `Bearer ${createMockToken()}`,
    },
    method: 'GET',
    originalUrl: '/test',
    params: {},
    query: {},
    body: {},
    ...overrides,
  };
}

/**
 * Create a mock Express response object.
 */
function createMockRes() {
  const res = {
    statusCode: 200,
    _headers: {},
    _json: null,
    status(code) {
      res.statusCode = code;
      return res;
    },
    json(data) {
      res._json = data;
      return res;
    },
    set(key, value) {
      res._headers[key] = value;
      return res;
    },
    setHeader(key, value) {
      res._headers[key] = value;
      return res;
    },
    getHeader(key) {
      return res._headers[key];
    },
    on() { return res; },
  };
  return res;
}

module.exports = {
  createMockUser,
  createMockToken,
  createMockReq,
  createMockRes,
};
