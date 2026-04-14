module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: ['src/**/*.js', '!src/index.js', '!src/server.js', '!src/config/**'],
  coverageDirectory: 'coverage',
  verbose: true,
  setupFiles: ['./tests/setup.js'],
  projects: [
    {
      displayName: 'unit',
      testMatch: ['**/tests/unit/**/*.test.js'],
      testEnvironment: 'node',
    },
    {
      displayName: 'integration',
      testMatch: ['**/tests/integration/**/*.test.js'],
      testEnvironment: 'node',
      setupFiles: ['./tests/setup.js'],
    },
    {
      displayName: 'e2e',
      testMatch: ['**/tests/e2e/**/*.test.js'],
      testEnvironment: 'node',
    },
  ],
};
