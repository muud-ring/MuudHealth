const Post = require('../../src/models/Post');
const controller = require('../../src/controllers/postController');

jest.mock('../../src/models/Post');
jest.mock('../../src/utils/logger', () => ({
  error: jest.fn(),
}));

describe('postController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
      params: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  /* ------------------------------------------------------------------ */
  /*  createPost                                                         */
  /* ------------------------------------------------------------------ */
  describe('createPost', () => {
    it('should create a public post', async () => {
      const mockPost = {
        _id: 'post-1',
        authorSub: 'user-123',
        caption: 'Test caption',
        mediaKeys: ['key1.jpg'],
        audioKey: '',
        visibility: 'public',
        recipientSubs: [],
      };

      req.body = {
        caption: 'Test caption',
        mediaKeys: ['key1.jpg'],
        visibility: 'public',
      };

      Post.create.mockResolvedValue(mockPost);

      await controller.createPost(req, res);

      expect(Post.create).toHaveBeenCalledWith({
        authorSub: 'user-123',
        caption: 'Test caption',
        mediaKeys: ['key1.jpg'],
        audioKey: '',
        visibility: 'public',
        recipientSubs: [],
      });
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ post: mockPost });
    });

    it('should return 400 when mediaKeys is empty', async () => {
      req.body = { caption: 'Test', mediaKeys: [] };

      await controller.createPost(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ message: 'mediaKeys required' });
    });

    it('should return 400 when non-public post has no recipientSubs', async () => {
      req.body = {
        mediaKeys: ['key1.jpg'],
        visibility: 'connections',
        recipientSubs: [],
      };

      await controller.createPost(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        message: 'recipientSubs required for non-public posts',
      });
    });

    it('should normalize visibility values', async () => {
      req.body = {
        caption: 'Test',
        mediaKeys: ['key1.jpg'],
        visibility: 'inner circle',
        recipientSubs: ['user-456'],
      };

      Post.create.mockResolvedValue({ _id: 'post-1' });

      await controller.createPost(req, res);

      expect(Post.create).toHaveBeenCalledWith(
        expect.objectContaining({ visibility: 'innerCircle' })
      );
    });

    it('should return 500 on error', async () => {
      req.body = { mediaKeys: ['key1.jpg'], visibility: 'public' };
      Post.create.mockRejectedValue(new Error('DB error'));

      await controller.createPost(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  updatePost                                                         */
  /* ------------------------------------------------------------------ */
  describe('updatePost', () => {
    it('should update a post owned by user', async () => {
      req.params.id = 'post-1';
      req.body = { caption: 'Updated caption', visibility: 'public' };

      const mockPost = {
        _id: 'post-1',
        authorSub: 'user-123',
        caption: 'Old caption',
        visibility: 'public',
        recipientSubs: [],
        save: jest.fn().mockResolvedValue(true),
      };

      Post.findById.mockResolvedValue(mockPost);

      await controller.updatePost(req, res);

      expect(mockPost.caption).toBe('Updated caption');
      expect(mockPost.save).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 404 when post not found', async () => {
      req.params.id = 'post-999';
      req.body = { caption: 'New' };
      Post.findById.mockResolvedValue(null);

      await controller.updatePost(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 403 when user is not the author', async () => {
      req.params.id = 'post-1';
      req.body = { caption: 'New' };

      Post.findById.mockResolvedValue({
        _id: 'post-1',
        authorSub: 'user-999',
      });

      await controller.updatePost(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });

    it('should return 400 when changing to non-public with no recipientSubs', async () => {
      req.params.id = 'post-1';
      req.body = { visibility: 'connections', recipientSubs: [] };

      const mockPost = {
        _id: 'post-1',
        authorSub: 'user-123',
        caption: 'Test',
        visibility: 'public',
        recipientSubs: [],
        save: jest.fn(),
      };

      Post.findById.mockResolvedValue(mockPost);

      await controller.updatePost(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });
  });

  /* ------------------------------------------------------------------ */
  /*  deletePost                                                         */
  /* ------------------------------------------------------------------ */
  describe('deletePost', () => {
    it('should delete a post owned by user', async () => {
      req.params.id = 'post-1';

      Post.findById.mockResolvedValue({
        _id: 'post-1',
        authorSub: 'user-123',
      });
      Post.deleteOne.mockResolvedValue({ deletedCount: 1 });

      await controller.deletePost(req, res);

      expect(Post.deleteOne).toHaveBeenCalledWith({ _id: 'post-1' });
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ ok: true });
    });

    it('should return 404 when post not found', async () => {
      req.params.id = 'post-999';
      Post.findById.mockResolvedValue(null);

      await controller.deletePost(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it('should return 403 when user is not the author', async () => {
      req.params.id = 'post-1';

      Post.findById.mockResolvedValue({
        _id: 'post-1',
        authorSub: 'user-999',
      });

      await controller.deletePost(req, res);

      expect(res.status).toHaveBeenCalledWith(403);
    });

    it('should return 500 on error', async () => {
      req.params.id = 'post-1';
      Post.findById.mockRejectedValue(new Error('DB error'));

      await controller.deletePost(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
    });
  });
});
