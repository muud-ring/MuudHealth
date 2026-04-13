// Muud Health — Load Test Configuration (Artillery / k6 Compatible)
// © Muud Health — Armin Hoes, MD

module.exports = {
  target: process.env.LOAD_TEST_TARGET || 'https://api.muudhealth.com',
  phases: [
    { duration: 60, arrivalRate: 10, name: 'Warm-up' },
    { duration: 120, arrivalRate: 10, rampTo: 50, name: 'Ramp-up' },
    { duration: 300, arrivalRate: 50, name: 'Sustained load' },
    { duration: 60, arrivalRate: 50, rampTo: 5, name: 'Cool-down' },
  ],
  scenarios: [
    {
      name: 'Health Check',
      weight: 10,
      flow: [
        { get: { url: '/health' } },
      ],
    },
    {
      name: 'Authenticated User Flow',
      weight: 40,
      flow: [
        { get: { url: '/user/me', headers: { Authorization: 'Bearer {{ token }}' } } },
        { get: { url: '/people/connections', headers: { Authorization: 'Bearer {{ token }}' } } },
        { get: { url: '/feed', headers: { Authorization: 'Bearer {{ token }}' } } },
      ],
    },
    {
      name: 'Chat Flow',
      weight: 25,
      flow: [
        { get: { url: '/chat/conversations', headers: { Authorization: 'Bearer {{ token }}' } } },
      ],
    },
    {
      name: 'Journal Flow',
      weight: 25,
      flow: [
        { get: { url: '/journal', headers: { Authorization: 'Bearer {{ token }}' } } },
      ],
    },
  ],
  thresholds: {
    p95_response_time: 2000, // ms
    p99_response_time: 5000, // ms
    error_rate: 0.01, // 1%
    min_rps: 10,
  },
};
