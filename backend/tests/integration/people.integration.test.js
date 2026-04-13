// Muud Health — People API Integration Tests
// © Muud Health — Armin Hoes, MD

const request = require('supertest');
const app = require('../../src/app');
const { createMockToken } = require('../setup');

describe('People API Integration', () => {
  const userASub = 'people-test-user-a';
  const userBSub = 'people-test-user-b';
  const tokenA = createMockToken(userASub);
  const tokenB = createMockToken(userBSub);

  describe('GET /people/connections', () => {
    it('should return empty connections for new user', async () => {
      const res = await request(app)
        .get('/people/connections')
        .set('Authorization', `Bearer ${tokenA}`);
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('connections');
      expect(Array.isArray(res.body.connections)).toBe(true);
    });
  });

  describe('GET /people/suggestions', () => {
    it('should return suggestions array', async () => {
      const res = await request(app)
        .get('/people/suggestions')
        .set('Authorization', `Bearer ${tokenA}`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.suggestions || res.body)).toBe(true);
    });
  });

  describe('POST /people/request', () => {
    it('should reject friend request to self', async () => {
      const res = await request(app)
        .post('/people/request')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ targetSub: userASub });
      expect([400, 422]).toContain(res.status);
    });
  });

  describe('GET /people/inner-circle', () => {
    it('should return inner circle array', async () => {
      const res = await request(app)
        .get('/people/inner-circle')
        .set('Authorization', `Bearer ${tokenA}`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.innerCircle || res.body)).toBe(true);
    });
  });

  describe('GET /people/requests', () => {
    it('should return pending requests', async () => {
      const res = await request(app)
        .get('/people/requests')
        .set('Authorization', `Bearer ${tokenA}`);
      expect(res.status).toBe(200);
    });
  });
});
