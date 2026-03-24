const Onboarding = require('../../src/models/Onboarding');
const controller = require('../../src/controllers/onboardingController');

jest.mock('../../src/models/Onboarding');

describe('onboardingController', () => {
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

  describe('getMe', () => {
    it('should return existing onboarding data', async () => {
      const mockDoc = {
        sub: 'user-123',
        favoriteColor: 'blue',
        focusGoal: 'wellness',
        activities: ['running', 'yoga'],
        notificationsEnabled: true,
        completed: true,
      };

      Onboarding.findOne.mockReturnValue({ lean: jest.fn().mockResolvedValue(mockDoc) });

      await controller.getMe(req, res);

      expect(Onboarding.findOne).toHaveBeenCalledWith({ sub: 'user-123' });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(mockDoc);
    });

    it('should return defaults when no onboarding doc exists', async () => {
      Onboarding.findOne.mockReturnValue({ lean: jest.fn().mockResolvedValue(null) });

      await controller.getMe(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        sub: 'user-123',
        favoriteColor: '',
        focusGoal: '',
        activities: [],
        notificationsEnabled: false,
        completed: false,
      });
    });

    it('should return 500 when DB query fails', async () => {
      Onboarding.findOne.mockReturnValue({
        lean: jest.fn().mockRejectedValue(new Error('DB error')),
      });

      await controller.getMe(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ message: 'Failed to fetch onboarding' });
    });
  });

  describe('upsert', () => {
    it('should save onboarding data and return it', async () => {
      req.body = {
        favoriteColor: ' blue ',
        focusGoal: 'wellness',
        activities: ['running', 'yoga'],
        notificationsEnabled: true,
        completed: true,
      };

      const mockUpdated = {
        sub: 'user-123',
        favoriteColor: 'blue',
        focusGoal: 'wellness',
        activities: ['running', 'yoga'],
        notificationsEnabled: true,
        completed: true,
      };

      Onboarding.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockUpdated),
      });

      await controller.upsert(req, res);

      expect(Onboarding.findOneAndUpdate).toHaveBeenCalledWith(
        { sub: 'user-123' },
        {
          $set: expect.objectContaining({
            sub: 'user-123',
            favoriteColor: 'blue',
            focusGoal: 'wellness',
            activities: ['running', 'yoga'],
            notificationsEnabled: true,
            completed: true,
          }),
        },
        { new: true, upsert: true }
      );
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        message: 'Onboarding saved',
        onboarding: mockUpdated,
      });
    });

    it('should handle missing optional fields with defaults', async () => {
      req.body = {};

      Onboarding.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockResolvedValue({ sub: 'user-123' }),
      });

      await controller.upsert(req, res);

      expect(Onboarding.findOneAndUpdate).toHaveBeenCalledWith(
        { sub: 'user-123' },
        {
          $set: expect.objectContaining({
            favoriteColor: '',
            focusGoal: '',
            activities: [],
            notificationsEnabled: false,
            completed: false,
          }),
        },
        expect.any(Object)
      );
    });

    it('should sanitize non-string activities', async () => {
      req.body = { activities: [123, null, 'yoga', '', 'running'] };

      Onboarding.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockResolvedValue({ sub: 'user-123' }),
      });

      await controller.upsert(req, res);

      expect(Onboarding.findOneAndUpdate).toHaveBeenCalledWith(
        expect.any(Object),
        {
          $set: expect.objectContaining({
            activities: ['yoga', 'running'],
          }),
        },
        expect.any(Object)
      );
    });

    it('should return 500 when save fails', async () => {
      req.body = { favoriteColor: 'red' };

      Onboarding.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockRejectedValue(new Error('DB error')),
      });

      await controller.upsert(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ message: 'Failed to save onboarding' });
    });
  });

  describe('getStatus', () => {
    it('should return completed: true when onboarding is complete', async () => {
      Onboarding.findOne.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue({ completed: true }),
        }),
      });

      await controller.getStatus(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ completed: true });
    });

    it('should return completed: false when no doc exists', async () => {
      Onboarding.findOne.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue(null),
        }),
      });

      await controller.getStatus(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ completed: false });
    });

    it('should return completed: false when completed field is missing', async () => {
      Onboarding.findOne.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue({}),
        }),
      });

      await controller.getStatus(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ completed: false });
    });

    it('should return 500 when query fails', async () => {
      Onboarding.findOne.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockRejectedValue(new Error('DB error')),
        }),
      });

      await controller.getStatus(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ message: 'Failed to fetch onboarding status' });
    });
  });
});
