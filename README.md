<div align="center">
  <h1>🧀 Ricota</h1>
  <p><strong>A real-time Pathfinder 2e companion app for players and game masters</strong></p>

  <p>
    <img src="https://img.shields.io/badge/status-in%20development-yellow" alt="Status" />
    <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue" alt="Platform" />
    <img src="https://img.shields.io/badge/stack-Expo%20%7C%20Express%20%7C%20Supabase-blueviolet" alt="Stack" />
  </p>
</div>

---

## What is Ricota?

Ricota is a mobile-first companion app for **Pathfinder 2e** tabletop sessions. It replaces paper character sheets with a live, interactive digital version — shared in real time between all players at the table.

Each player manages their own character sheet from their phone. The Game Master gets a read-only overview of the entire party. Everything syncs instantly.

> **This is a full rewrite** of an earlier prototype built with React + Vite + Firebase. The new version is designed from the ground up with a proper architecture, a clear separation between frontend and backend, and a mobile-first approach aimed at eventually publishing to the App Store and Google Play.

---

## Features (planned)

- 📋 **Digital character sheet** — stats, skills, HP, conditions, equipment
- ⚡ **Real-time sync** — changes propagate instantly to all connected clients
- 🎲 **Session management** — create a session, share a code, everyone joins
- 👁️ **GM view** — game master sees the full party at a glance
- 🔐 **Auth** — each player has their own account and characters

---

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│   Player (Expo)     │     │   GM (Expo)          │
└────────┬────────────┘     └──────────┬───────────┘
         │  REST (writes)              │
         └──────────┬──────────────────┘
                    ▼
         ┌──────────────────┐
         │  Express API     │
         │  Node.js         │
         └────────┬─────────┘
                  │
         ┌────────▼─────────┐
         │  Supabase        │
         │  PostgreSQL      │
         │  Auth + Realtime │
         └──────────────────┘
                  │
         WebSocket (realtime)
                  │
    ┌─────────────▼────────────┐
    │  All connected clients   │
    └──────────────────────────┘
```

See [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) for a full breakdown of every architectural decision and the reasoning behind it.

---

## Tech stack

| Layer | Technology | Why |
|---|---|---|
| Mobile | [Expo](https://expo.dev) (React Native) | Cross-platform iOS + Android from one codebase |
| Backend | [Express](https://expressjs.com) + Node.js | Simple REST API, business logic lives server-side |
| Database | [PostgreSQL](https://postgresql.org) via [Supabase](https://supabase.com) | Relational model fits PF2e data; managed hosting |
| Auth | Supabase Auth | JWT sessions, easy to integrate with Expo |
| Realtime | Supabase Realtime | WebSocket subscriptions over PostgreSQL changes |
| Monorepo | [pnpm workspaces](https://pnpm.io/workspaces) | Shared types between API and mobile |

---

## Project structure

```
ricota/
├── apps/
│   ├── api/          # Express REST API
│   │   └── src/
│   │       ├── routes/
│   │       ├── controllers/
│   │       ├── services/
│   │       ├── middleware/
│   │       └── db/
│   └── mobile/       # Expo React Native app
│       └── src/
│           ├── screens/
│           ├── components/
│           ├── hooks/
│           ├── services/
│           ├── store/
│           └── navigation/
├── packages/
│   └── shared/       # Shared types and constants
└── docs/
    ├── ARCHITECTURE.md
    ├── DATABASE.md
    └── CONTRIBUTING.md
```

---

## Getting started

> ⚠️ The project is in early development. Setup instructions will be updated as the project progresses.

### Prerequisites

- Node.js 20+
- pnpm 9+
- A [Supabase](https://supabase.com) project

### Installation

```bash
git clone https://github.com/xGeaa/ricota.git
cd ricota
pnpm install
# This also activates Husky git hooks (commitlint + commitizen)
```

### Environment variables

```bash
cp apps/api/.env.example apps/api/.env
# Fill in your Supabase credentials
```

### Run in development

```bash
# API
pnpm --filter api dev

# Mobile
pnpm --filter mobile start
```

---

## Documentation

- [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) — architectural decisions and patterns
- [`docs/DATABASE.md`](./docs/DATABASE.md) — data model and schema design
- [`docs/CONTRIBUTING.md`](./docs/CONTRIBUTING.md) — commit conventions and workflow

---

## Roadmap

- [ ] Data model design
- [ ] Supabase schema + migrations
- [ ] Express API scaffold
- [ ] Authentication (sign up, log in, sessions)
- [ ] Character sheet CRUD
- [ ] Real-time sync via Supabase Realtime
- [ ] GM view (read-only party overview)
- [ ] Polish + App Store submission

---

## About

Built by [@xGeaa](https://github.com/xGeaa) — computer science student at the University of Granada, learning by building things that are actually useful.

This project started as a messy prototype and is being rewritten from scratch with everything learned since. The old version lives at [xGeaa/Ricota-legacy](https://github.com/xGeaa/Ricota) (archived).
