const UserProfile = require('../../src/models/UserProfile');
const controller = require('../../src/controllers/notificationController');

jest.mock('../../src/models/UserProfile');
jest.mock('../../src/config/firebase', () => ({
  getMessaging: jest.fn(),
}));
jest.mock('../../src/utils/logger', () => ({
  error: jest.fn(),
  info: jest.fn(),
}));

describe('notificationController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('registerDevice', () => {
    it('should register a device token', async () => {
      req.body = { token: 'fcm-token-abc', platform: 'ios' };
      UserProfile.updateOne.mockResolvedValue({ modifiedCount: 1 });

      await controller.registerDevice(req, res);

      expect(UserProfile.updateOne).toHaveBeenCalledWith(
        { sub: 'user-123' },
        {
          $addToSet: {
            fcmTokens: {
              token: 'fcm-token-abc',
              platform: 'ios',
              registeredAt: expect.any(Date),
            },
          },
        }
      );
      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 400 when token is empty', async () => {
      req.body = { token: '' };

      await controller.registerDevice(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};
      req.body = { token: 'fcm-token-abc' };

      await controller.registerDevice(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should return 500 on error', async () => {
      req.body = { token: 'fcm-token-abc' };
      UserProfile.updateOne.mockRejectedValue(new Error('DB error'));

      await controller.registerDevice(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  describe('unregisterDevice', () => {
    it('should remove a device token', async () => {
      req.body = { token: 'fcm-token-abc' };
      UserProfile.updateOne.mockResolvedValue({ modifiedCount: 1 });

      await controller.unregisterDevice(req, res);

      expect(UserProfile.updateOne).toHaveBeenCalledWith(
        { sub: 'user-123' },
        { $pull: { fcmTokens: { token: 'fcm-token-abc' } } }
      );
      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 400 when token is empty', async () => {
      req.body = { token: '' };

      await controller.unregisterDevice(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};
      req.body = { token: 'fcm-token-abc' };

      await controller.unregisterDevice(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });
  });

  describe('sendPushToUser', () => {
    const { getMessaging } = require('../../src/config/firebase');

    it('should do nothing when messaging is not configured', async () => {
      getMessaging.mockReturnValue(null);

      await controller.sendPushToUser('user-456', {
        title: 'Test',
        body: 'Hello',
      });

      expect(UserProfile.findOne).not.toHaveBeenCalled();
    });

    it('should do nothing when user has no tokens', async () => {
      const mockMessaging = { sendEachForMulticast: jest.fn() };
      getMessaging.mockReturnValue(mockMessaging);

      UserProfile.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue({ fcmTokens: [] }),
      });

      await controller.sendPushToUser('user-456', {
        title: 'Test',
        body: 'Hello',
      });

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it('should send push and clean invalid tokens', async () => {
      const mockMessaging = {
        sendEachForMulticast: jest.fn().mockResolvedValue({
          failureCount: 1,
          responses: [
            { success: true },
            {
              success: false,
              error: { code: 'messaging/registration-token-not-registered' },
            },
          ],
        }),
      };
      getMessaging.mockReturnValue(mockMessaging);

      UserProfile.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue({
          fcmTokens: [
            { token: 'valid-token' },
            { token: 'invalid-token' },
          ],
        }),
      });
      UserProfile.updateOne.mockResolvedValue({});

      await controller.sendPushToUser('user-456', {
        title: 'New Message',
        body: 'You have a new chat message',
        data: { type: 'chat' },
      });

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledWith({
        notification: { title: 'New Message', body: 'You have a new chat message' },
        data: { type: 'chat' },
        tokens: ['valid-token', 'invalid-token'],
      });

      // Should clean up the invalid token
      expect(UserProfile.updateOne).toHaveBeenCalledWith(
        { sub: 'user-456' },
        { $pull: { fcmTokens: { token: { $in: ['invalid-token'] } } } }
      );
    });
  });
});
