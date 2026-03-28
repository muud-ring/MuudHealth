const Conversation = require('../../src/models/Conversation');
const Message = require('../../src/models/Message');
const controller = require('../../src/controllers/chatController');

jest.mock('../../src/models/Conversation');
jest.mock('../../src/models/Message');
jest.mock('../../src/models/UserProfile');
jest.mock('../../src/utils/s3_avatar_url');
jest.mock('../../src/utils/logger', () => ({
  error: jest.fn(),
}));

describe('chatController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
      query: {},
      params: {},
      app: { get: jest.fn() },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  /* ------------------------------------------------------------------ */
  /*  getUnreadCount                                                     */
  /* ------------------------------------------------------------------ */
  describe('getUnreadCount', () => {
    it('should return unread count', async () => {
      Message.countDocuments.mockResolvedValue(5);

      await controller.getUnreadCount(req, res);

      expect(Message.countDocuments).toHaveBeenCalledWith({
        toSub: 'user-123',
        readAt: null,
      });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ unread: 5 });
    });

    it('should return 401 when user sub is missing', async () => {
      req.user = {};

      await controller.getUnreadCount(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should return 500 on error', async () => {
      Message.countDocuments.mockRejectedValue(new Error('DB error'));

      await controller.getUnreadCount(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getOrCreateConversation                                            */
  /* ------------------------------------------------------------------ */
  describe('getOrCreateConversation', () => {
    it('should create or return existing conversation', async () => {
      req.params.otherSub = 'user-456';
      const mockConvo = { _id: 'conv-1', members: ['user-123', 'user-456'] };

      Conversation.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockConvo),
      });

      await controller.getOrCreateConversation(req, res);

      expect(Conversation.findOneAndUpdate).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ conversation: mockConvo });
    });

    it('should return 400 when otherSub equals mySub', async () => {
      req.params.otherSub = 'user-123';

      await controller.getOrCreateConversation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 400 when params are missing', async () => {
      req.params.otherSub = undefined;
      req.user = {};

      await controller.getOrCreateConversation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 500 on error', async () => {
      req.params.otherSub = 'user-456';
      Conversation.findOneAndUpdate.mockReturnValue({
        lean: jest.fn().mockRejectedValue(new Error('DB error')),
      });

      await controller.getOrCreateConversation(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getMessages                                                        */
  /* ------------------------------------------------------------------ */
  describe('getMessages', () => {
    it('should return messages and mark as read', async () => {
      req.params.conversationId = 'conv-1';
      const mockConvo = { _id: 'conv-1', members: ['user-123', 'user-456'] };
      const mockMessages = [
        { _id: 'msg-1', text: 'hello', fromSub: 'user-456', toSub: 'user-123' },
      ];

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockConvo),
      });

      const sortMock = jest.fn().mockReturnValue({
        limit: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue(mockMessages),
        }),
      });
      Message.find.mockReturnValue({ sort: sortMock });
      Message.updateMany.mockResolvedValue({ modifiedCount: 1 });

      const ioMock = { to: jest.fn().mockReturnValue({ emit: jest.fn() }) };
      req.app.get.mockReturnValue(ioMock);

      await controller.getMessages(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ messages: mockMessages });
      expect(Message.updateMany).toHaveBeenCalledWith(
        { conversationId: 'conv-1', toSub: 'user-123', readAt: null },
        { $set: { readAt: expect.any(Date) } }
      );
    });

    it('should return 404 when conversation not found', async () => {
      req.params.conversationId = 'conv-999';

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(null),
      });

      await controller.getMessages(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 403 when user not a member', async () => {
      req.params.conversationId = 'conv-1';
      const mockConvo = { _id: 'conv-1', members: ['user-456', 'user-789'] };

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockConvo),
      });

      await controller.getMessages(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  sendMessage                                                        */
  /* ------------------------------------------------------------------ */
  describe('sendMessage', () => {
    it('should create and emit a message', async () => {
      req.params.conversationId = 'conv-1';
      req.body = { text: 'Hello world' };

      const mockConvo = { _id: 'conv-1', members: ['user-123', 'user-456'] };
      const mockMsg = {
        _id: 'msg-1',
        conversationId: 'conv-1',
        fromSub: 'user-123',
        toSub: 'user-456',
        text: 'Hello world',
        createdAt: new Date(),
      };

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(mockConvo),
      });
      Message.create.mockResolvedValue(mockMsg);
      Conversation.updateOne.mockResolvedValue({});

      const emitFn = jest.fn();
      const ioMock = { to: jest.fn().mockReturnValue({ emit: emitFn }) };
      req.app.get.mockReturnValue(ioMock);

      await controller.sendMessage(req, res);

      expect(Message.create).toHaveBeenCalledWith({
        conversationId: 'conv-1',
        fromSub: 'user-123',
        toSub: 'user-456',
        text: 'Hello world',
        readAt: null,
      });
      expect(res.status).toHaveBeenCalledWith(201);
      expect(ioMock.to).toHaveBeenCalledWith('conv:conv-1');
    });

    it('should return 400 for empty text', async () => {
      req.params.conversationId = 'conv-1';
      req.body = { text: '   ' };

      await controller.sendMessage(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 404 when conversation not found', async () => {
      req.params.conversationId = 'conv-1';
      req.body = { text: 'hello' };

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue(null),
      });

      await controller.sendMessage(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 403 when user not a member', async () => {
      req.params.conversationId = 'conv-1';
      req.body = { text: 'hello' };

      Conversation.findById.mockReturnValue({
        lean: jest.fn().mockResolvedValue({
          _id: 'conv-1',
          members: ['user-456', 'user-789'],
        }),
      });

      await controller.sendMessage(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  getInbox                                                           */
  /* ------------------------------------------------------------------ */
  describe('getInbox', () => {
    it('should return conversations sorted by last activity', async () => {
      const mockConvos = [
        { _id: 'conv-1', members: ['user-123', 'user-456'], lastMessage: 'hi' },
      ];

      Conversation.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          limit: jest.fn().mockReturnValue({
            lean: jest.fn().mockResolvedValue(mockConvos),
          }),
        }),
      });

      await controller.getInbox(req, res);

      expect(Conversation.find).toHaveBeenCalledWith({ members: 'user-123' });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ conversations: mockConvos });
    });

    it('should return 500 on error', async () => {
      Conversation.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          limit: jest.fn().mockReturnValue({
            lean: jest.fn().mockRejectedValue(new Error('DB error')),
          }),
        }),
      });

      await controller.getInbox(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });
});
