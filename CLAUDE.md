# CLAUDE.md — AI Assistant Guide for muud_health_app

> **Last updated**: 2026-03-11
> **Assessed by**: Claude (Opus 4.6)
> **Build designation**: Muud App MVP V1.1 (App 1.1) — see [Build Assessment](#build-assessment) below

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Status](#repository-status)
3. [Repository Structure](#repository-structure)
4. [Development Setup](#development-setup)
5. [Commands](#commands)
6. [Architecture](#architecture)
7. [Muud Platform Vision](#muud-platform-vision)
8. [Code Conventions](#code-conventions)
9. [Testing](#testing)
10. [Git Workflow](#git-workflow)
11. [Key Guidelines for AI Assistants](#key-guidelines-for-ai-assistants)
12. [Build Assessment](#build-assessment)
13. [MVP Roadmap](#mvp-roadmap)

---

## Project Overview

**muud_health_app** is a health and wellness application by **MUUD Health** / **MUUD Tech**. It serves as the central operating platform for the broader Muud ecosystem — a decentralized, community-driven health technology network.

### Core Signal Pathway

The Muud technology platform is built around five sequential milestones:

```
Signal → Insight → Action → Learn → Grow
```

| Milestone | Delivered By | Description |
|-----------|-------------|-------------|
| **Signal** | Technology | Capture and generate data (smart ring, phone sensors, user input) |
| **Insight** | Technology | Dashboards, metrics, and reports on user activity and milestones |
| **Action** | Technology | Notifications, reminders, and alerts to facilitate behavior |
| **Learn** | Technology | Shared experiences, content, connections with experts/professionals |
| **Grow** | User commitment | Actual positive behavior change through routine daily usage |

### Platform Components

| Component | Role | Analogy |
|-----------|------|---------|
| **Muud App** | Central user OS / personal hub | User's personal computer |
| **Muud Smart Ring** | Biometric data capture device | Keyboard/mouse (input peripherals) |
| **Mobile Phone** | Display, interaction, connectivity | Screen/monitor |
| **Muud Network** | Community of connected users | Server network of interconnected PCs |

### Future AI Features

- Advanced analytics and predictive metrics
- Collaboration tools for communities
- Creator tools for content and shared experiences
- Expert/professional matching and connections

---

## Repository Status

- **Current state**: Initial commit — repository scaffolding only (README.md + CLAUDE.md)
- **Primary branch**: `main`
- **Remote**: `muud-health/muud_health_app` (GitHub)
- **Created**: 2025-06-27
- **Total commits**: 2 (initial commit + documentation)
- **Framework/language**: Not yet selected
- **Dependencies**: None
- **Source code**: None present
- **CI/CD**: Not configured
- **Tests**: None
- **.gitignore**: Not present

---

## Repository Structure

```
muud_health_app/
├── .git/              # Git version control
├── CLAUDE.md          # This file — AI assistant guide & build assessment
└── README.md          # Project title ("# muud_health_app")
```

**Notable absences** (files expected in a production health app):

- No `pubspec.yaml` / `package.json` / `build.gradle` (no dependency management)
- No `lib/` or `src/` directory (no source code)
- No `test/` directory (no tests)
- No `.gitignore` (no file exclusion rules)
- No `.env.example` (no environment configuration)
- No `Dockerfile` / `docker-compose.yml` (no containerization)
- No CI/CD config (`.github/workflows/`, `Jenkinsfile`, etc.)
- No linting/formatting config (`.eslintrc`, `analysis_options.yaml`, etc.)
- No API schema definitions
- No design assets or wireframes

---

## Development Setup

No build tools, dependencies, or environment configuration have been established yet.

**When the scaffold is created, update this section with:**

- Language and framework version requirements
- Package manager and install commands
- Environment variable setup (`.env` template)
- Database/backend configuration
- Emulator/simulator requirements (if mobile)
- IDE recommendations and extensions

---

## Commands

_None defined yet. Update this section as the project adds build scripts, test runners, and linters._

<!-- Template for when commands are established:
```bash
# Install dependencies
<package-manager> install

# Run the app (development)
<run-command>

# Run tests
<test-command>

# Lint / format
<lint-command>
<format-command>

# Build (production)
<build-command>

# Deploy
<deploy-command>
```
-->

---

## Architecture

_To be determined._ The architecture should be selected to support the Muud platform vision:

### Recommended Architectural Considerations

Given the platform requirements (real-time biometric data, community features, AI integration), the architecture should address:

- **Real-time data pipeline**: Smart ring → phone → app → cloud
- **Offline-first capability**: Health data capture must work without connectivity
- **Secure data storage**: HIPAA/health data compliance
- **Scalable backend**: Support growing user communities
- **Plugin/module system**: Enable future AI features and integrations
- **Cross-platform**: Reach maximum user base (iOS + Android minimum)

---

## Muud Platform Vision

The Muud App functions as a **personal health operating system** within a decentralized network:

```
┌─────────────────────────────────────────────────────┐
│                   MUUD ECOSYSTEM                     │
│                                                      │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│   │  User A  │◄──►│  User B  │◄──►│  User C  │     │
│   │ Muud App │    │ Muud App │    │ Muud App │     │
│   └────┬─────┘    └────┬─────┘    └────┬─────┘     │
│        │               │               │            │
│   ┌────┴─────┐    ┌────┴─────┐    ┌────┴─────┐     │
│   │Smart Ring│    │Smart Ring│    │Smart Ring│     │
│   └──────────┘    └──────────┘    └──────────┘     │
│        │               │               │            │
│        └───────────────┼───────────────┘            │
│                        ▼                             │
│              ┌──────────────────┐                    │
│              │   Muud Cloud     │                    │
│              │  ┌────────────┐  │                    │
│              │  │ AI Engine  │  │                    │
│              │  │ Analytics  │  │                    │
│              │  │ Community  │  │                    │
│              │  └────────────┘  │                    │
│              └──────────────────┘                    │
│                        │                             │
│              ┌─────────┴─────────┐                   │
│              │    Experts &      │                   │
│              │  Professionals    │                   │
│              └───────────────────┘                   │
└─────────────────────────────────────────────────────┘
```

---

## Code Conventions

_To be defined. When established, document:_

- Naming conventions (files, classes, variables, functions)
- File organization patterns
- State management approach
- Error handling patterns
- Logging standards
- API design conventions
- Documentation requirements

---

## Testing

_No testing framework configured yet. When established, document:_

- Unit test conventions and expectations
- Integration test approach
- Widget/UI test strategy (if mobile)
- End-to-end test framework
- Coverage thresholds
- Test data management
- CI test pipeline

---

## Git Workflow

- **Default branch**: `main`
- **Feature branches**: `claude/<description>-<id>` or `feature/<description>`
- Write clear, descriptive commit messages
- Keep commits focused on a single change
- Never commit secrets, credentials, or sensitive health data
- Use pull requests for code review

---

## Key Guidelines for AI Assistants

1. **Read before editing** — Always read files before modifying them
2. **Minimal changes** — Only make changes that are directly requested; avoid unnecessary refactoring
3. **No guessing** — If the project structure or conventions are unclear, ask rather than assume
4. **Security first** — Never commit secrets, credentials, or sensitive health data (HIPAA considerations)
5. **Update this file** — When significant project decisions are made (framework choice, architecture, dependencies), update this CLAUDE.md to reflect the current state
6. **Health data sensitivity** — This is a health app; treat all user data patterns, schemas, and examples with extra care
7. **Platform thinking** — Changes should consider the broader ecosystem (smart ring integration, community features, AI pipeline)
8. **Signal pathway alignment** — Features should map to the Signal → Insight → Action → Learn → Grow pathway

---

## Build Assessment

### Workspace Audit Results

**Repositories discovered**: 1
**Repository**: `muud-health/muud_health_app`

Only a single build exists in the muud-health workspace. The assessment below evaluates it as the sole candidate.

---

### Build #1: `muud_health_app` (main branch)

#### Inventory

| Category | Status | Details |
|----------|--------|---------|
| Source code | Missing | No application code exists |
| Frontend (UI/UX) | Missing | No screens, widgets, components, or layouts |
| Backend / API | Missing | No server code, endpoints, or data models |
| Integration layer | Missing | No smart ring SDK, no cloud connectors |
| State management | Missing | No state solution selected or implemented |
| Navigation / routing | Missing | No navigation framework |
| Authentication | Missing | No auth flow or identity management |
| Data persistence | Missing | No local database or caching |
| Networking | Missing | No HTTP client or API integration |
| Push notifications | Missing | No notification framework |
| Testing | Missing | No test files, no test framework |
| CI/CD | Missing | No pipeline configuration |
| Linting / formatting | Missing | No config files |
| Documentation | Partial | README.md (title only) + CLAUDE.md (this file) |
| .gitignore | Missing | No file exclusion rules |
| Environment config | Missing | No .env setup |
| Security | N/A | No code to evaluate |
| Accessibility | Missing | No a11y implementation |
| Internationalization | Missing | No i18n setup |
| Error handling | Missing | No error boundary or crash reporting |

---

#### SWOT Analysis

##### Strengths

1. **Clean slate** — No technical debt, no legacy code, no bad patterns to unwind. Every architectural decision can be made optimally from the start.
2. **Repository infrastructure exists** — Git is initialized, remote is configured on GitHub within the `muud-health` organization. Collaboration infrastructure is ready.
3. **Clear product vision** — The Muud platform concept (Signal → Insight → Action → Learn → Grow) is well-articulated, giving developers a strong guiding framework.
4. **Organizational presence** — The `muud-health` GitHub organization is established, suggesting organizational readiness.
5. **AI-assisted documentation** — CLAUDE.md provides a living guide for AI-assisted development, enabling faster iteration.

##### Weaknesses

1. **No application code** — The repository contains zero functional code. There is no frontend, backend, or integration layer of any kind.
2. **No technology stack selected** — Framework, language, and dependency choices have not been made, blocking all development.
3. **No project scaffold** — Not even a boilerplate or starter template has been generated.
4. **No .gitignore** — Risk of accidentally committing build artifacts, secrets, or IDE files.
5. **No CI/CD pipeline** — No automated testing, building, or deployment.
6. **No design artifacts** — No wireframes, mockups, or design system to guide UI development.
7. **No API specification** — No OpenAPI/Swagger docs or data model definitions.
8. **Single contributor history** — Only one commit in history, suggesting limited team engagement.
9. **No dependency management** — Cannot even install packages without a manifest file.
10. **No test infrastructure** — No framework chosen, no test directory, no coverage tooling.

##### Opportunities

1. **Modern framework selection** — Can adopt the latest stable frameworks (Flutter 3.x, React Native 0.76+, etc.) without migration burden.
2. **Best-practice architecture from day one** — Can implement clean architecture, proper dependency injection, and scalable patterns without refactoring.
3. **AI-accelerated development** — With CLAUDE.md and AI-assisted coding, the build-out can move significantly faster than traditional development.
4. **Health tech market growth** — The wearable health technology market is expanding rapidly, creating strong product-market fit potential.
5. **Smart ring differentiation** — The Muud Smart Ring integration offers a unique hardware+software value proposition.
6. **Community-first design** — Building the social/community layer into the core architecture (vs. bolting it on later) is a significant advantage.
7. **Compliance by design** — Starting fresh allows building HIPAA/health data compliance into the foundation rather than retrofitting.
8. **Cross-platform potential** — Modern frameworks enable iOS + Android + Web from a single codebase.

##### Threats

1. **Development velocity risk** — With no code, the gap between current state and a shippable MVP is enormous. Every component must be built from scratch.
2. **Technology decision paralysis** — The lack of any tech stack decision may indicate indecision or resource constraints.
3. **Resource constraints** — A health app with hardware integration, community features, and AI requires significant engineering investment.
4. **Regulatory complexity** — Health data apps face HIPAA, GDPR, and other regulatory requirements that add development overhead.
5. **Hardware dependency** — The smart ring integration adds complexity and a dependency on hardware availability/SDK maturity.
6. **Competitive landscape** — Established players (Oura, Whoop, Apple Health, Fitbit) have mature ecosystems.
7. **Security requirements** — Health data breaches carry severe legal and reputational consequences; security must be built in from the start.
8. **App store approval** — Health apps face additional scrutiny during iOS/Android app store review.
9. **Time to market** — Every day without code is a day competitors advance.
10. **Integration complexity** — The platform vision (app + ring + cloud + AI + community) has many moving parts that must work together reliably.

---

### Scoring: App Completion Rate

#### Methodology

The score measures **readiness to package and ship** on a 0–100 scale, evaluating both:

- **Quantity** (50 points): How much of the required functional code exists (frontend, backend, integration)
- **Quality** (50 points): How well the existing code performs (error rates, bugs, reliability, security)

#### Detailed Scoring: `muud_health_app`

##### Quantity Assessment (0–50 points)

| Component | Weight | Score | Rationale |
|-----------|--------|-------|-----------|
| Frontend UI/UX | 10 | 0 | No screens, components, or layouts exist |
| Backend / API | 8 | 0 | No server code or endpoints |
| Authentication | 5 | 0 | No auth implementation |
| Data persistence | 5 | 0 | No local storage or database |
| State management | 4 | 0 | No state solution |
| Navigation | 3 | 0 | No routing |
| Networking layer | 4 | 0 | No API client |
| Push notifications | 3 | 0 | No notification system |
| Hardware integration | 4 | 0 | No smart ring SDK |
| CI/CD pipeline | 2 | 0 | No pipeline |
| Documentation | 2 | 1 | README + CLAUDE.md exist (partial) |
| **Subtotal** | **50** | **1** | |

##### Quality Assessment (0–50 points)

| Criterion | Weight | Score | Rationale |
|-----------|--------|-------|-----------|
| Error rate / bugs | 10 | N/A (0) | No code to evaluate |
| Code architecture | 8 | N/A (0) | No architecture implemented |
| Test coverage | 8 | N/A (0) | No tests |
| Security posture | 8 | N/A (0) | No security measures (but also no vulnerabilities) |
| Performance | 5 | N/A (0) | No app to benchmark |
| Accessibility | 3 | N/A (0) | No UI to evaluate |
| Code style / consistency | 3 | N/A (0) | No code |
| Dependency health | 3 | N/A (0) | No dependencies |
| Build reliability | 2 | N/A (0) | No build system |
| **Subtotal** | **50** | **0** | |

#### Final Score

| Build | Quantity (0–50) | Quality (0–50) | **Total (0–100)** |
|-------|----------------|----------------|-------------------|
| `muud_health_app` | 1 | 0 | **1 / 100** |

> **App Completion Rate: 1%**
> The single point is awarded for the existence of repository infrastructure and documentation (CLAUDE.md + README.md). No functional code exists.

---

### Build Election

| Rank | Repository | Score | Status |
|------|-----------|-------|--------|
| 1 | `muud_health_app` | 1/100 | **Elected** (sole candidate) |

As the only build in the `muud-health` workspace, **`muud_health_app` is elected as the foundational codebase**.

---

## Muud App MVP V1.1 (App 1.1)

### Designation

```
╔══════════════════════════════════════════════════════╗
║                                                      ║
║          MUUD APP MVP V1.1  ("App 1.1")             ║
║                                                      ║
║   Repository:  muud-health/muud_health_app           ║
║   Branch:      main                                  ║
║   Elected:     2026-03-11                            ║
║   Score:       1 / 100                               ║
║   Status:      FOUNDATIONAL — Requires full build    ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

App 1.1 is now the **foundational code of the Muud App**. All future development builds upon this repository. The goal is to perfect App 1.1 into the strongest product core possible — the central operating system of the Muud ecosystem.

### App 1.1 — What Must Be Built

To bring App 1.1 from 1/100 to a shippable MVP, the following layers must be implemented:

#### Phase 1: Foundation (Score target: 20/100)
- [ ] Select technology stack (framework, language, backend)
- [ ] Generate project scaffold with proper directory structure
- [ ] Configure `.gitignore`, linting, formatting
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Create environment configuration (.env template)
- [ ] Define data models and API schema
- [ ] Set up authentication framework

#### Phase 2: Core Features — Signal & Insight (Score target: 45/100)
- [ ] User registration and authentication flows
- [ ] Home dashboard with health metrics display
- [ ] Smart ring data ingestion pipeline (Signal)
- [ ] Data visualization components — charts, graphs (Insight)
- [ ] Local data persistence (offline-first)
- [ ] User profile and settings

#### Phase 3: Engagement — Action & Learn (Score target: 70/100)
- [ ] Push notification system (Action)
- [ ] Reminders and alerts engine (Action)
- [ ] Community feed and shared experiences (Learn)
- [ ] Expert/professional directory and connections (Learn)
- [ ] Content sharing and discovery
- [ ] User-to-user connections (the Muud Network)

#### Phase 4: Intelligence & Polish (Score target: 85/100)
- [ ] AI-powered analytics and metrics
- [ ] Predictive insights engine
- [ ] Creator tools for content
- [ ] Collaboration features
- [ ] Comprehensive error handling and crash reporting
- [ ] Accessibility (a11y) compliance
- [ ] Internationalization (i18n) setup

#### Phase 5: Ship-Ready (Score target: 95–100/100)
- [ ] End-to-end test coverage (>80%)
- [ ] Security audit and HIPAA compliance review
- [ ] Performance optimization and benchmarking
- [ ] App store metadata and assets
- [ ] Beta testing program
- [ ] Production deployment pipeline
- [ ] Documentation for users, developers, and API consumers

---

## MVP Roadmap

```
Current State                                          Target
    │                                                     │
    ▼                                                     ▼
   1%  ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  100%
    │                                                     │
    ├── Phase 1: Foundation ──────────── 20%              │
    ├── Phase 2: Signal & Insight ────── 45%              │
    ├── Phase 3: Action & Learn ──────── 70%              │
    ├── Phase 4: Intelligence ────────── 85%              │
    └── Phase 5: Ship-Ready ──────────── 95-100%         │
```

Each phase builds on the previous. The Signal → Insight → Action → Learn → Grow pathway maps directly to the development phases, ensuring that the technical build mirrors the product vision.

---

*This document is a living guide. Update it as App 1.1 evolves.*
