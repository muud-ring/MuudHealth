const errorHandler = require('../../src/middleware/errorHandler');

// Suppress pino output during tests
jest.mock('../../src/utils/logger', () => ({
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  debug: jest.fn(),
}));

describe('errorHandler middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      method: 'POST',
      originalUrl: '/test',
      body: { key: 'value' },
      user: { sub: 'user-123' },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
  });

  afterEach(() => {
    delete process.env.NODE_ENV;
  });

  it('should return 500 by default for errors without status', () => {
    const err = new Error('Something broke');

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: 'Something broke' })
    );
  });

  it('should use err.status when provided', () => {
    const err = new Error('Not found');
    err.status = 404;

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: 'Not found' })
    );
  });

  it('should use err.statusCode when provided', () => {
    const err = new Error('Bad request');
    err.statusCode = 400;

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('should hide error details in production for 500 errors', () => {
    process.env.NODE_ENV = 'production';
    const err = new Error('Secret internal details');

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({ error: 'Internal server error' });
  });

  it('should show error message in production for non-500 errors', () => {
    process.env.NODE_ENV = 'production';
    const err = new Error('Validation failed');
    err.status = 400;

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'Validation failed' });
  });

  it('should include stack trace in development', () => {
    process.env.NODE_ENV = 'development';
    const err = new Error('Dev error');

    errorHandler(err, req, res, next);

    const response = res.json.mock.calls[0][0];
    expect(response.stack).toBeDefined();
    expect(response.stack).toContain('Dev error');
  });

  it('should not include stack trace in production', () => {
    process.env.NODE_ENV = 'production';
    const err = new Error('Prod error');
    err.status = 400;

    errorHandler(err, req, res, next);

    const response = res.json.mock.calls[0][0];
    expect(response.stack).toBeUndefined();
  });

  it('should default to "Internal server error" when err.message is empty', () => {
    const err = new Error();

    errorHandler(err, req, res, next);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.any(String) })
    );
  });
});
