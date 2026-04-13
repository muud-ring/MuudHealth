// Muud Health — Health Endpoint E2E Test
// © Muud Health — Armin Hoes, MD

const config = require('./e2e.config');

describe('E2E: Health Check', () => {
  it('should return healthy status from production API', async () => {
    const response = await fetch(`${config.baseUrl}${config.endpoints.health}`, {
      method: 'GET',
      signal: AbortSignal.timeout(config.timeout),
    });

    expect(response.ok).toBe(true);
    const body = await response.json();
    expect(body).toHaveProperty('status');
    expect(body.status).toMatch(/ok|healthy/i);
  });

  it('should include required health headers', async () => {
    const response = await fetch(`${config.baseUrl}${config.endpoints.health}`);
    expect(response.headers.get('x-data-region')).toBeTruthy();
  });

  it('should respond within acceptable latency', async () => {
    const start = Date.now();
    await fetch(`${config.baseUrl}${config.endpoints.health}`);
    const latency = Date.now() - start;
    expect(latency).toBeLessThan(config.timeout);
  });
});
