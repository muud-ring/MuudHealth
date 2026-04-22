module.exports = {
  // E2E tests require a live server — excluded from CI unit/integration run
  testPathIgnorePatterns: ['/node_modules/', '/tests/e2e/'],
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: ['src/**/*.js', '!src/index.js', '!src/server.js', '!src/config/**'],
  coverageDirectory: 'coverage',
  verbose: true,
  setupFiles: ['./tests/setup.js'],
  // Run only unit tests by default — integration requires live DB, e2e requires live server
  // To run all: npx jest --selectProjects=unit,integration,e2e
  projects: [
    {
      displayName: 'unit',
      testMatch: ['**/tests/unit/**/*.test.js'],
      testEnvironment: 'node',
    },
  ],
};
