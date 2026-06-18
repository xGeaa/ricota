# Architecture

This document explains every significant architectural decision made in Ricota, and the reasoning behind each one.

---

## Overview

Ricota is a mobile-first real-time app. The architecture is designed around three core requirements:

1. **Multiple users editing their own data simultaneously** — players update their character sheets in real time during a session.
2. **A shared, live view for the Game Master** — the GM sees all party members' sheets update instantly without any manual refresh.
3. **A professional, maintainable codebase** — clean separation of concerns, deployable, and extensible.

---

## Monorepo structure

The project uses **pnpm workspaces** to manage two apps and one shared package from a single repository.

```
ricota/
├── apps/api       # Express REST API
├── apps/mobile    # Expo React Native app
└── packages/shared  # Shared TypeScript types and constants
```

**Why a monorepo?** The API and the mobile app share data types (e.g. what a `Character` object looks like). A monorepo lets us define those types once in `packages/shared` and import them in both apps, preventing drift between what the API sends and what the client expects.

---

## Frontend: Expo (React Native)

**Decision:** Use Expo instead of plain React Native.

**Reasoning:**
- Expo handles all native build configuration, removing the need to manage Xcode and Android Studio setups during development.
- Expo Go allows instant testing on a real device with no build step.
- When ready to publish, EAS Build handles App Store and Play Store submissions.
- Since we already know React from the previous prototype, the learning curve is minimal.

**Alternative considered:** A React PWA (Next.js). Rejected because PWAs on iOS have significant limitations (no push notifications, no proper offline support, not installable from the App Store).

---

## Backend: Express + Node.js

**Decision:** Build a separate REST API instead of letting the mobile app talk directly to Supabase.

**Reasoning:**
- Business logic (e.g. "only the session owner can delete a character") lives on the server, not on the client. This is critical for a future public app — a malicious client cannot bypass rules by calling Supabase directly.
- The API acts as a stable interface. If we ever switch databases or add caching, the mobile app does not change.
- Keeps the mobile app thin: it only handles UI and user interaction.

**Alternative considered:** Direct Supabase access from the client using Row Level Security (RLS). Feasible, but RLS alone is harder to audit and test than plain server-side code, and it couples the client too tightly to the database schema.

---

## Database: PostgreSQL via Supabase

**Decision:** Use PostgreSQL (hosted on Supabase) instead of Firestore (used in the previous prototype).

**Reasoning:**
- Pathfinder 2e character data is highly relational: a character has stats, which reference ability scores, which affect skill modifiers, which interact with conditions. This is a textbook use case for a relational database.
- Firestore's document model required nesting everything into large JSON blobs, which made querying and partial updates awkward.
- Supabase provides PostgreSQL with a managed hosting layer, built-in Auth, and Realtime — everything we need from a single provider.

---

## Real-time sync: Supabase Realtime

**Decision:** Use Supabase Realtime for live updates instead of building a custom WebSocket server.

**Reasoning:**
- Supabase Realtime broadcasts PostgreSQL change events (INSERT, UPDATE, DELETE) to subscribed clients over WebSocket.
- This means we do not need to maintain a separate WebSocket server or event bus.
- The flow is simple: client writes via the REST API → API updates PostgreSQL → Supabase Realtime broadcasts the change → all subscribed clients (including the GM) receive the update.

**What real-time covers:**
- Character HP changes during combat
- Conditions applied or removed
- Resource expenditure (spell slots, focus points, etc.)

---

## Authentication: Supabase Auth

Supabase Auth handles user registration, login, and JWT session management. The Express API validates JWTs on every protected route using Supabase's public keys.

Session model:
- A **session** in Ricota terms is a game session (not an auth session). A session has one GM and multiple players.
- Players join a session via a short invite code.
- Each player can only read and write their own character. The GM can read all characters in their sessions.

---

## Internationalisation (i18n)

**Decision:** All internal values (database enums, API keys, code identifiers) are in English. User-facing text is handled via i18n at the UI layer using **i18next** + **react-i18next**.

**Reasoning:**
- Ricota is aimed at a public audience across multiple languages. Hardcoding Spanish text into the database or business logic would make adding new languages require database migrations and API changes — a significant cost.
- Separating data from display text means a new language is just a new JSON translation file, with zero changes to the backend.
- The initial release will ship with English (`en`) and Spanish (`es`). The architecture supports adding more without any structural changes.

**How it works in practice:**

Database and API always use English keys:
```
skill_name: "acrobatics" | "arcana" | "athletics" | ...
condition_name: "frightened" | "stunned" | "prone" | ...
```

The mobile app maps those keys to display strings via translation files:
```json
// en.json
{ "skills": { "acrobatics": "Acrobatics", "arcana": "Arcana" } }

// es.json
{ "skills": { "acrobatics": "Acrobacias", "arcana": "Arcanos" } }
```

Components never contain raw strings — always `t('skills.acrobatics')`.

---

## Derived values are calculated on the client

**Decision:** The database stores only base values. Derived stats are computed in the mobile app, never stored.

**Reasoning:**
- PF2e modifier formulas are deterministic: `skill modifier = ability modifier + proficiency bonus + item bonus`. Storing the result would create a second source of truth that can go out of sync with its inputs.
- Keeping calculations in the client means the database only needs to be updated when a base value changes (e.g. the player levels up), not every time a derived value would change as a consequence.
- This also makes the real-time sync simpler: when `current_hp` changes, only that one field is broadcast — not a cascade of derived values.

---

## Commit conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use for |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation only |
| `refactor:` | Code change with no behaviour change |
| `chore:` | Tooling, dependencies, config |
| `test:` | Adding or updating tests |

Example: `feat(api): add character HP update endpoint`
