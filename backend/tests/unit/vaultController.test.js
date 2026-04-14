const VaultItem = require('../../src/models/VaultItem');
const Post = require('../../src/models/Post');
const controller = require('../../src/controllers/vaultController');

jest.mock('../../src/models/VaultItem');
jest.mock('../../src/models/Post');
jest.mock('../../src/models/UserProfile');
jest.mock('../../src/utils/logger', () => ({
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  debug: jest.fn(),
}));
jest.mock('../../src/utils/s3_sign', () => ({ signKey: jest.fn().mockResolvedValue('https://signed-url') }));

describe('vaultController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
      query: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('save', () => {
    it('should save a post to vault and return 200', async () => {
      req.body = {
        sourceType: 'post',
        sourceId: 'post-456',
        category: 'family',
        tags: [{ type: 'mood', value: 'happy' }],
      };

      Post.findById.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue({ _id: 'post-456', authorSub: 'user-123' }),
        }),
      });

      const mockDoc = { _id: 'vault-1', ownerSub: 'user-123', category: 'family' };
      VaultItem.findOneAndUpdate.mockResolvedValue(mockDoc);

      await controller.save(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ ok: true, item: mockDoc });
    });

    it('should reject non-post sourceType', async () => {
      req.body = { sourceType: 'video', sourceId: '123' };

      await controller.save(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        message: 'Only sourceType=post supported for now',
      });
    });

    it('should reject empty sourceId', async () => {
      req.body = { sourceType: 'post', sourceId: '' };

      await controller.save(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ message: 'sourceId required' });
    });

    it('should return 404 when post does not exist', async () => {
      req.body = { sourceType: 'post', sourceId: 'nonexistent' };

      Post.findById.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue(null),
        }),
      });

      await controller.save(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 403 when saving another users post', async () => {
      req.body = { sourceType: 'post', sourceId: 'post-789' };

      Post.findById.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue({ _id: 'post-789', authorSub: 'other-user' }),
        }),
      });

      await controller.save(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });

    it('should normalize unknown category to "other"', async () => {
      req.body = { sourceType: 'post', sourceId: 'post-456', category: 'UNKNOWN' };

      Post.findById.mockReturnValue({
        select: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue({ _id: 'post-456', authorSub: 'user-123' }),
        }),
      });
      VaultItem.findOneAndUpdate.mockResolvedValue({ category: 'other' });

      await controller.save(req, res);

      expect(VaultItem.findOneAndUpdate).toHaveBeenCalledWith(
        expect.any(Object),
        expect.objectContaining({
          $set: expect.objectContaining({ category: 'other' }),
        }),
        expect.any(Object)
      );
    });
  });

  describe('unsave', () => {
    it('should delete vault item and return 200', async () => {
      req.query = { sourceId: 'post-456' };

      VaultItem.deleteOne.mockResolvedValue({ deletedCount: 1 });

      await controller.unsave(req, res);

      expect(VaultItem.deleteOne).toHaveBeenCalledWith({
        ownerSub: 'user-123',
        sourceType: 'post',
        sourceId: 'post-456',
      });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ ok: true });
    });

    it('should reject empty sourceId', async () => {
      req.query = { sourceId: '' };

      await controller.unsave(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ message: 'sourceId required' });
    });

    it('should return 500 on DB error', async () => {
      req.query = { sourceId: 'post-456' };
      VaultItem.deleteOne.mockRejectedValue(new Error('DB error'));

      await controller.unsave(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });
});
