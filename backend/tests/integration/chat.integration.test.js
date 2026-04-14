// Muud Health — Chat API Integration Tests
// © Muud Health — Armin Hoes, MD

const request = require('supertest');
const app = require('../../src/app');
const { createMockToken } = require('../setup');

describe('Chat API Integration', () => {
  const userSub = 'chat-test-user';
  const token = createMockToken(userSub);

  describe('GET /chat/conversations', () => {
    it('should return conversations list for authenticated user', async () => {
      const res = await request(app)
        .get('/chat/conversations')
        .set('Authorization', `Bearer ${token}`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('should require authentication', async () => {
      const res = await request(app).get('/chat/conversations');
      expect(res.status).toBe(401);
    });
  });

  describe('GET /chat/messages/:otherSub', () => {
    it('should return messages array (may be empty)', async () => {
      const res = await request(app)
        .get('/chat/messages/other-user-sub')
        .set('Authorization', `Bearer ${token}`);
      expect([200, 404]).toContain(res.status);
      if (res.status === 200) {
        expect(Array.isArray(res.body.messages || res.body)).toBe(true);
      }
    });
  });

  describe('POST /chat/send', () => {
    it('should reject empty message', async () => {
      const res = await request(app)
        .post('/chat/send')
        .set('Authorization', `Bearer ${token}`)
        .send({ to: 'some-sub', text: '' });
      expect([400, 422]).toContain(res.status);
    });

    it('should reject message without recipient', async () => {
      const res = await request(app)
        .post('/chat/send')
        .set('Authorization', `Bearer ${token}`)
        .send({ text: 'Hello' });
      expect([400, 422]).toContain(res.status);
    });
  });
});
