# Copilot Workspace Instructions

## Overview
This workspace is a Node.js backend for Muud Health, using Express, Mongoose, and AWS/Firebase integrations. It includes a prototype app and a modular `src/` structure with controllers, models, routes, middleware, and services.

## Build & Test Commands
- **Start (dev/prod):** `npm run start` or `npm run dev`
- **Prototype:** `npm run prototype`
- **Lint:** `npm run lint` / `npm run lint:fix`
- **Test:** `npm test` or `npm run test:watch`

## Key Conventions
- **Entry point:** `src/index.js`
- **Prototype entry:** `src/prototype.js`
- **Controllers, models, routes, middleware, services** are organized by feature in `src/`
- **Unit tests:** in `tests/unit/`, named after the file under test
- **Config:** AWS, Firebase, and DB config in `src/config/`
- **Validation:** All input validation in `src/validators/`

## Project Structure
- `src/` — Main backend code
- `prototype/` — Standalone prototype app
- `tests/unit/` — Unit tests
- `scripts/` — Utility scripts

## Agent Guidance
- Use the provided npm scripts for all build, lint, and test operations
- Link to documentation in `docs/` if added in the future (none found yet)
- Follow the modular structure for new features (controller, model, route, validator)
- Prefer updating this file over duplicating instructions elsewhere

## Example Prompts
- "Add a new route for user settings with validation and tests."
- "Refactor notification service to use async/await."
- "Generate a test for the onboarding controller."

---
For advanced customizations, consider creating agent instructions for specific folders (e.g., `src/controllers/`, `src/services/`).