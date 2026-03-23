const { authLimiter, apiLimiter } = require('../../src/middleware/rateLimiter');

describe('rateLimiter middleware', () => {
  it('should export authLimiter as a function', () => {
    expect(authLimiter).toBeDefined();
    expect(typeof authLimiter).toBe('function');
  });

  it('should export apiLimiter as a function', () => {
    expect(apiLimiter).toBeDefined();
    expect(typeof apiLimiter).toBe('function');
  });
});
