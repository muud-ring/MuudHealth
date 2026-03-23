# Muud Health App

Health and wellness platform built around: **Signal → Insight → Action → Learn → Grow**

## Quick Start — Prototype

The prototype runs fully in-memory (no database required). Includes seeded demo data with 6 users, biometric trends, chat conversations, and social features.

### Run Locally

```bash
cd backend
npm install
node src/prototype.js
# Open http://localhost:4000
```

### Deploy to Render (Recommended — Free)

1. Push this repo to GitHub
2. Go to [render.com/new](https://render.com/new)
3. Click **"New Blueprint"** and connect this repo
4. Render reads `render.yaml` and deploys automatically
5. Your app will be live at `https://muud-prototype.onrender.com`

Or manually: **New > Web Service** → connect repo → set root directory to `backend`, build command `npm install`, start command `node src/prototype.js`.

### Deploy to Fly.io (Free Tier)

```bash
# Install flyctl: https://fly.io/docs/flyctl/install/
fly auth login
fly launch          # Uses fly.toml config
fly deploy
# App live at https://muud-prototype.fly.dev
```

### Deploy with Docker

```bash
docker build -t muud-prototype .
docker run -p 4000:4000 muud-prototype
# Open http://localhost:4000
```

## Demo Accounts

| Name | Username | Role |
|------|----------|------|
| Alex Johnson | alex | Main demo user (has biometric data) |
| Sam Rivera | sam | Yoga instructor, Alex's inner circle |
| Jordan Lee | jordan | Runner, connected to Alex |
| Taylor Chen | taylor | Nutrition enthusiast, connected to Alex |
| Morgan Davis | morgan | Pending friend request to Alex |
| Casey Park | casey | Suggested connection for Alex |

## Features in Prototype

- **Home** — Wellness score dashboard, biometric metrics (HR, sleep, steps, HRV, SpO2, stress), social feed
- **Trends** — 7-day biometric charts and daily summaries
- **Journal** — Create and view entries with visibility controls
- **People** — Inner circle, connections, friend requests, suggestions
- **Chat** — Real-time messaging with unread badges
- **Explore** — Public content feed
- **Settings** — Profile view
- **Notifications** — Friend request alerts

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML/CSS/JS single-page app (prototype) |
| Backend | Node.js + Express 5.2 |
| Real-time | Socket.IO |
| Data | In-memory (prototype) / MongoDB (production) |
| Auth | Dev tokens (prototype) / AWS Cognito (production) |
