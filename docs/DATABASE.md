# Database design

> 🚧 Work in progress — this document is updated as the schema evolves.

This document describes the data model for Ricota. All tables live in a single PostgreSQL database hosted on Supabase.

---

## Entity overview

```
users
  └── characters (one user can have multiple characters)
        └── character_stats
        └── character_skills
        └── character_equipment
        └── character_conditions

sessions (a game session)
  └── session_members (links users/characters to a session)
```

---

## Tables

### `users`

Managed by Supabase Auth. Extended with a public profile.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key (from Supabase Auth) |
| `username` | `text` | Unique display name |
| `created_at` | `timestamptz` | Auto |

---

### `sessions`

A game session created by a GM.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `name` | `text` | Session name |
| `invite_code` | `text` | Short unique code for players to join |
| `gm_id` | `uuid` | FK → `users.id` |
| `created_at` | `timestamptz` | Auto |

---

### `session_members`

Links a character to a session. One row per player per session.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `session_id` | `uuid` | FK → `sessions.id` |
| `user_id` | `uuid` | FK → `users.id` |
| `character_id` | `uuid` | FK → `characters.id` |
| `joined_at` | `timestamptz` | Auto |

---

### `characters`

Core character identity. Stats, skills and equipment are in separate tables.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `owner_id` | `uuid` | FK → `users.id` |
| `name` | `text` | Character name |
| `ancestry` | `text` | e.g. Human, Elf, Dwarf |
| `class` | `text` | e.g. Fighter, Wizard |
| `level` | `int` | 1–20 |
| `max_hp` | `int` | |
| `current_hp` | `int` | Updated frequently during play |
| `created_at` | `timestamptz` | Auto |
| `updated_at` | `timestamptz` | Auto |

---

> Further tables (`character_stats`, `character_skills`, `character_conditions`, `character_equipment`) will be designed and documented in a future iteration once the core character sheet is stable.

---

## Design decisions

**Why separate tables for stats and skills instead of a JSON column?**

A JSON column would be simpler to write, but it makes partial updates and queries harder. For example, "get all characters with Acrobatics +10 or higher" is a single SQL query with a normalised schema, but requires scanning and parsing JSON otherwise. The relational model also makes Supabase Realtime subscriptions more granular — a change to `current_hp` only triggers updates for that specific column.

**Why `invite_code` instead of a link?**

Short codes (e.g. `GX7K2`) are easier to share verbally at a physical table, which is the primary use case.
