// Muud Health — Auth Integration Tests
// © Muud Health — Armin Hoes, MD
// Requires: npm i -D supertest

const request = require('supertest');
const app = require('../../src/app');
const { createMockToken } = require('../setup');

describe('Auth Integration', () => {
  describe('GET /health', () => {
    it('should return 200 without auth', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('status');
    });
  });

  describe('Protected routes', () => {
    it('should reject requests without auth header', async () => {
      const res = await request(app).get('/user/me');
      expect(res.status).toBe(401);
      expect(res.body).toHaveProperty('message');
    });

    it('should reject requests with invalid token', async () => {
      const res = await request(app)
        .get('/user/me')
        .set('Authorization', 'Bearer invalid-token-xyz');
      expect(res.status).toBe(401);
    });

    it('should accept requests with valid dev token', async () => {
      const token = createMockToken('integration-test-user');
      const res = await request(app)
        .get('/user/me')
        .set('Authorization', `Bearer ${token}`);
      // 200 or 404 (user may not exist) — but NOT 401
      expect([200, 404]).toContain(res.status);
    });

    it('should reject requests with malformed Bearer header', async () => {
      const res = await request(app)
        .get('/user/me')
        .set('Authorization', 'NotBearer some-token');
      expect(res.status).toBe(401);
    });
  });
});
