// Muud Health — E2E Test Configuration
// © Muud Health — Armin Hoes, MD

module.exports = {
  baseUrl: process.env.E2E_BASE_URL || 'https://api.muudhealth.com',
  timeout: 30000,
  retries: 2,
  testUser: {
    sub: process.env.E2E_TEST_USER_SUB || 'e2e-test-user',
    token: process.env.E2E_TEST_TOKEN || null,
  },
  endpoints: {
    health: '/health',
    userMe: '/user/me',
    people: '/people/connections',
    chat: '/chat/conversations',
    feed: '/feed',
    journal: '/journal',
    vault: '/vault',
  },
};
