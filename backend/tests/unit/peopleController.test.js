const Connection = require('../../src/models/Connection');
const FriendRequest = require('../../src/models/FriendRequest');
const UserProfile = require('../../src/models/UserProfile');
const controller = require('../../src/controllers/peopleController');

jest.mock('../../src/models/Connection');
jest.mock('../../src/models/FriendRequest');
jest.mock('../../src/models/UserProfile');
jest.mock('../../src/utils/s3_avatar_url', () => ({
  attachAvatarUrls: jest.fn((profiles) => Promise.resolve(profiles)),
}));
jest.mock('../../src/utils/logger', () => ({
  error: jest.fn(),
}));

describe('peopleController', () => {
  let req, res;

  const mockProfile = {
    _id: 'id-123',
    sub: 'user-123',
    name: 'Test User',
    username: 'testuser',
    bio: '',
    location: '',
    avatarKey: '',
  };

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
      query: {},
      params: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();

    // Default: getMyProfile finds an existing user
    UserProfile.findOne.mockImplementation((filter, projection) => ({
      lean: jest.fn().mockResolvedValue(
        filter.sub ? mockProfile : null
      ),
    }));
    UserProfile.findById.mockReturnValue({
      lean: jest.fn().mockResolvedValue(mockProfile),
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getMe                                                              */
  /* ------------------------------------------------------------------ */
  describe('getMe', () => {
    it('should return the current user profile', async () => {
      // getMyProfile calls findOne({ sub }) then findById for username fix,
      // then getMe calls findOne({ _id }) for the full profile.
      UserProfile.findOne.mockImplementation((filter) => ({
        lean: jest.fn().mockResolvedValue(mockProfile),
      }));
      UserProfile.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockProfile),
      });

      await controller.getMe(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        me: expect.objectContaining({ sub: 'user-123' }),
      });
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};

      await controller.getMe(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should return 500 on error', async () => {
      UserProfile.findOne.mockImplementation(() => ({
        lean: jest.fn().mockRejectedValue(new Error('DB error')),
      }));

      await controller.getMe(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getConnections                                                     */
  /* ------------------------------------------------------------------ */
  describe('getConnections', () => {
    it('should return connections list', async () => {
      Connection.find.mockReturnValue({
        lean: jest.fn().mockResolvedValue([
          { userA: 'id-123', userB: 'id-456', tier: 'connection' },
        ]),
      });

      UserProfile.find.mockReturnValue({
        lean: jest.fn().mockResolvedValue([
          { _id: 'id-456', sub: 'user-456', name: 'Friend', username: 'friend1', avatarKey: '' },
        ]),
      });

      await controller.getConnections(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        connections: expect.any(Array),
      });
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};

      await controller.getConnections(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getInnerCircle                                                     */
  /* ------------------------------------------------------------------ */
  describe('getInnerCircle', () => {
    it('should return inner circle list', async () => {
      Connection.find.mockReturnValue({
        lean: jest.fn().mockResolvedValue([]),
      });

      UserProfile.find.mockReturnValue({
        lean: jest.fn().mockResolvedValue([]),
      });

      await controller.getInnerCircle(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ innerCircle: [] });
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getRequests                                                        */
  /* ------------------------------------------------------------------ */
  describe('getRequests', () => {
    it('should return pending friend requests', async () => {
      const mockRequests = [
        { _id: 'req-1', fromSub: 'user-456', toSub: 'user-123', status: 'pending' },
      ];

      FriendRequest.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue(mockRequests),
        }),
      });

      UserProfile.find.mockReturnValue({
        lean: jest.fn().mockResolvedValue([
          { sub: 'user-456', name: 'Requester', username: 'requester1', avatarKey: '' },
        ]),
      });

      await controller.getRequests(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        requests: expect.arrayContaining([
          expect.objectContaining({ fromSub: 'user-456' }),
        ]),
      });
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};

      await controller.getRequests(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  sendRequest                                                        */
  /* ------------------------------------------------------------------ */
  describe('sendRequest', () => {
    it('should create a friend request', async () => {
      req.params.sub = 'user-456';
      const mockResult = {
        _id: 'req-1',
        fromSub: 'user-123',
        toSub: 'user-456',
        status: 'pending',
      };

      FriendRequest.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(null),
      });
      FriendRequest.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockResult),
      });

      await controller.sendRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ request: mockResult });
    });

    it('should return 400 when requesting yourself', async () => {
      req.params.sub = 'user-123';

      await controller.sendRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        message: 'Cannot request yourself',
      });
    });

    it('should return 400 when reverse request exists', async () => {
      req.params.sub = 'user-456';

      FriendRequest.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue({
          fromSub: 'user-456',
          toSub: 'user-123',
          status: 'pending',
        }),
      });

      await controller.sendRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should handle duplicate key error', async () => {
      req.params.sub = 'user-456';

      FriendRequest.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(null),
      });

      const dupError = new Error('E11000 duplicate key');
      dupError.code = 11000;
      FriendRequest.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockRejectedValue(dupError),
      });

      await controller.sendRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        message: 'Request already exists',
      });
    });
  });

  /* ------------------------------------------------------------------ */
  /*  acceptRequest                                                      */
  /* ------------------------------------------------------------------ */
  describe('acceptRequest', () => {
    it('should accept a pending request and create connection', async () => {
      req.params.requestId = 'req-1';

      const mockRequest = {
        _id: 'req-1',
        fromSub: 'user-456',
        toSub: 'user-123',
        status: 'pending',
        save: jest.fn().mockResolvedValue(true),
      };

      FriendRequest.findById.mockResolvedValue(mockRequest);

      UserProfile.findOne.mockImplementation((filter) => ({
        lean: jest.fn().mockResolvedValue(
          filter.sub === 'user-456'
            ? { _id: 'id-456', sub: 'user-456' }
            : { _id: 'id-123', sub: 'user-123' }
        ),
      }));

      Connection.updateOne.mockResolvedValue({});

      await controller.acceptRequest(req, res);

      expect(mockRequest.status).toBe('accepted');
      expect(mockRequest.save).toHaveBeenCalled();
      expect(Connection.updateOne).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 404 when request not found', async () => {
      req.params.requestId = 'req-999';
      FriendRequest.findById.mockResolvedValue(null);

      await controller.acceptRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 400 when request already handled', async () => {
      req.params.requestId = 'req-1';
      FriendRequest.findById.mockResolvedValue({
        status: 'accepted',
        toSub: 'user-123',
      });

      await controller.acceptRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 403 when not the receiver', async () => {
      req.params.requestId = 'req-1';
      FriendRequest.findById.mockResolvedValue({
        status: 'pending',
        toSub: 'user-999',
        fromSub: 'user-456',
      });

      await controller.acceptRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  declineRequest                                                     */
  /* ------------------------------------------------------------------ */
  describe('declineRequest', () => {
    it('should decline a pending request', async () => {
      req.params.requestId = 'req-1';

      const mockRequest = {
        _id: 'req-1',
        fromSub: 'user-456',
        toSub: 'user-123',
        status: 'pending',
        save: jest.fn().mockResolvedValue(true),
      };

      FriendRequest.findById.mockResolvedValue(mockRequest);

      await controller.declineRequest(req, res);

      expect(mockRequest.status).toBe('declined');
      expect(mockRequest.save).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 403 when not the receiver', async () => {
      req.params.requestId = 'req-1';
      FriendRequest.findById.mockResolvedValue({
        status: 'pending',
        toSub: 'user-999',
      });

      await controller.declineRequest(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  removeConnection                                                   */
  /* ------------------------------------------------------------------ */
  describe('removeConnection', () => {
    it('should remove a connection', async () => {
      req.params.sub = 'user-456';

      UserProfile.findOne.mockImplementation((filter) => ({
        lean: jest.fn().mockResolvedValue(
          filter.sub === 'user-123'
            ? { _id: 'id-123' }
            : { _id: 'id-456' }
        ),
      }));

      Connection.deleteOne.mockResolvedValue({ deletedCount: 1 });

      await controller.removeConnection(req, res);

      expect(Connection.deleteOne).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        message: 'Connection removed',
        deletedCount: 1,
      });
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};
      req.params.sub = 'user-456';

      await controller.removeConnection(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should return 404 when target profile not found', async () => {
      req.params.sub = 'user-456';

      UserProfile.findOne.mockImplementation((filter) => ({
        lean: jest.fn().mockResolvedValue(
          filter.sub === 'user-123' ? { _id: 'id-123' } : null
        ),
      }));

      await controller.removeConnection(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });
  });
});
