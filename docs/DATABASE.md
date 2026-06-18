# Database design

This document describes the full data model for Ricota. All tables live in a single PostgreSQL database hosted on Supabase.

> All enum values and internal identifiers are in English. User-facing labels are handled at the UI layer via i18n. See `ARCHITECTURE.md` for details.

---

## Entity overview

```
users
  └── characters
        ├── character_ability_scores  (1-to-1)
        ├── character_combat          (1-to-1)
        ├── character_saving_throws   (1-to-1)
        ├── character_profile         (1-to-1)
        ├── character_skills          (1-to-many)
        ├── character_weapons         (1-to-many)
        ├── character_conditions      (1-to-many)
        ├── character_inventory       (1-to-many)
        ├── character_feats           (1-to-many)
        ├── character_actions         (1-to-many)
        └── character_spellcasting    (1-to-many)
              ├── character_spell_slots  (1-to-many)
              └── character_spells       (1-to-many)

sessions
  └── session_members → links users + characters to a session
```

---

## Core tables

### `users`
Managed by Supabase Auth. Extended with a public profile.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK (from Supabase Auth) |
| `username` | `text` | Unique display name |
| `created_at` | `timestamptz` | Auto |

---

### `sessions`
A game session created by a GM.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `name` | `text` | Session name |
| `invite_code` | `text` | Short unique code to join |
| `gm_id` | `uuid` | FK → `users.id` |
| `created_at` | `timestamptz` | Auto |

---

### `session_members`
Links a character to a session.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `session_id` | `uuid` | FK → `sessions.id` |
| `user_id` | `uuid` | FK → `users.id` |
| `character_id` | `uuid` | FK → `characters.id` |
| `joined_at` | `timestamptz` | Auto |

---

## Character tables

### `characters`
Core character identity.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `owner_id` | `uuid` | FK → `users.id` |
| `name` | `text` | Character name |
| `player_name` | `text` | |
| `ancestry` | `text` | e.g. `"human"`, `"elf"` |
| `heritage` | `text` | e.g. `"versatile human"` |
| `background` | `text` | e.g. `"acolyte"` |
| `char_class` | `text` | e.g. `"fighter"`, `"wizard"` |
| `level` | `int` | 1–20 |
| `experience_points` | `int` | |
| `hero_points` | `int` | 0–3 |
| `size` | `text` | `"small"` \| `"medium"` \| `"large"` |
| `alignment` | `text` | e.g. `"neutral_good"` |
| `deity` | `text` | |
| `traits` | `text` | Comma-separated trait list |
| `speed_ft` | `int` | Base speed in feet |
| `languages` | `text` | Comma-separated |
| `notes` | `text` | Free text |
| `created_at` | `timestamptz` | Auto |
| `updated_at` | `timestamptz` | Auto |

---

### `character_ability_scores`
The six core ability scores. 1-to-1 with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `strength` | `int` | Raw score (e.g. 16) |
| `dexterity` | `int` | |
| `constitution` | `int` | |
| `intelligence` | `int` | |
| `wisdom` | `int` | |
| `charisma` | `int` | |

> Modifiers are derived on the client: `modifier = floor((score - 10) / 2)`

---

### `character_combat`
HP, AC, shield. 1-to-1 with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `max_hp` | `int` | |
| `current_hp` | `int` | Updated frequently during play |
| `temp_hp` | `int` | Temporary hit points |
| `dying` | `int` | 0 = not dying |
| `wounded` | `int` | Wounded condition value |
| `ac_base` | `int` | Base AC (without armor) |
| `armor_worn` | `text` | Name of equipped armor |
| `armor_proficiency` | `text` | `"untrained"` \| `"trained"` \| `"expert"` \| `"master"` \| `"legendary"` |
| `shield_name` | `text` | |
| `shield_hardness` | `int` | |
| `shield_max_hp` | `int` | |
| `shield_current_hp` | `int` | |
| `perception_proficiency` | `text` | Same enum as armor |
| `class_dc_key_ability` | `text` | e.g. `"strength"` |
| `class_dc_proficiency` | `text` | Same enum as armor |

---

### `character_saving_throws`
Fortitude, Reflex, Will. 1-to-1 with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `fortitude_proficiency` | `text` | |
| `reflex_proficiency` | `text` | |
| `will_proficiency` | `text` | |
| `fortitude_notes` | `text` | |
| `reflex_notes` | `text` | |
| `will_notes` | `text` | |

> Final modifier = ability modifier + proficiency bonus (0/2/4/6/8 + level) + item bonus. Calculated on client.

---

### `character_skills`
One row per skill. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `skill_name` | `text` | `"acrobatics"` \| `"arcana"` \| `"athletics"` \| `"crafting"` \| `"deception"` \| `"diplomacy"` \| `"intimidation"` \| `"lore"` \| `"medicine"` \| `"nature"` \| `"occultism"` \| `"performance"` \| `"religion"` \| `"society"` \| `"stealth"` \| `"survival"` \| `"thievery"` |
| `lore_topic` | `text` | Only used when `skill_name = "lore"` (e.g. `"history"`) |
| `proficiency` | `text` | `"untrained"` \| `"trained"` \| `"expert"` \| `"master"` \| `"legendary"` |
| `item_bonus` | `int` | Bonus from items |
| `armor_penalty` | `boolean` | Whether armor check penalty applies |
| `notes` | `text` | |

---

### `character_weapons`
Melee and ranged weapons. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `name` | `text` | |
| `type` | `text` | `"melee"` \| `"ranged"` |
| `proficiency` | `text` | `"untrained"` ... `"legendary"` |
| `ability_used` | `text` | `"strength"` \| `"dexterity"` |
| `damage_dice` | `text` | e.g. `"1d8"` |
| `damage_type` | `text` | `"piercing"` \| `"slashing"` \| `"bludgeoning"` |
| `damage_bonus_str` | `boolean` | Whether STR modifier adds to damage |
| `traits` | `text` | Comma-separated |
| `special` | `text` | Special properties |
| `notes` | `text` | |

---

### `character_conditions`
Active conditions. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `condition_name` | `text` | e.g. `"frightened"`, `"stunned"`, `"prone"` |
| `value` | `int` | For valued conditions (frightened 2, stunned 3...) |
| `notes` | `text` | |
| `applied_at` | `timestamptz` | Auto |

---

### `character_inventory`
Equipment and currency. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `name` | `text` | |
| `category` | `text` | `"worn"` \| `"readied"` \| `"other"` |
| `quantity` | `int` | |
| `bulk` | `numeric` | Supports L (0.1) and — (0) |
| `invested` | `boolean` | |
| `notes` | `text` | |
| `coins_cp` | `int` | Copper (stored on character, not per item) |
| `coins_sp` | `int` | Silver |
| `coins_gp` | `int` | Gold |
| `coins_pp` | `int` | Platinum |

---

### `character_feats`
All feats: ancestry, class, skill, general. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `name` | `text` | |
| `feat_type` | `text` | `"ancestry"` \| `"class"` \| `"skill"` \| `"general"` \| `"bonus"` |
| `level_gained` | `int` | Level at which this feat was taken |
| `traits` | `text` | |
| `description` | `text` | |

---

### `character_actions`
Custom actions, free actions and reactions. 1-to-many with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `name` | `text` | |
| `action_type` | `text` | `"action"` \| `"free_action"` \| `"reaction"` |
| `num_actions` | `text` | `"1"` \| `"2"` \| `"3"` \| `"free"` \| `"reaction"` |
| `trigger` | `text` | For reactions and free actions |
| `traits` | `text` | |
| `description` | `text` | |
| `page_ref` | `text` | Book + page reference |

---

## Magic tables

### `character_spellcasting`
One row per magical tradition. 1-to-many with `characters` (a character can have multiple).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `tradition` | `text` | `"arcane"` \| `"divine"` \| `"occult"` \| `"primal"` |
| `casting_type` | `text` | `"prepared"` \| `"spontaneous"` \| `"innate"` \| `"focus"` |
| `key_ability` | `text` | e.g. `"intelligence"` |
| `spell_attack_proficiency` | `text` | |
| `spell_dc_proficiency` | `text` | |
| `focus_points_current` | `int` | |
| `focus_points_max` | `int` | |

---

### `character_spell_slots`
Daily spell slots per level. 1-to-many with `character_spellcasting`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `spellcasting_id` | `uuid` | FK → `character_spellcasting.id` |
| `spell_level` | `int` | 1–10 |
| `slots_max` | `int` | |
| `slots_used` | `int` | Updated during play |

---

### `character_spells`
Known or prepared spells. 1-to-many with `character_spellcasting`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `spellcasting_id` | `uuid` | FK → `character_spellcasting.id` |
| `name` | `text` | |
| `spell_level` | `int` | 0 = cantrip |
| `spell_type` | `text` | `"spell"` \| `"cantrip"` \| `"focus"` \| `"innate"` |
| `casting_time` | `text` | e.g. `"2 actions"` |
| `components` | `text` | `"m"` (material), `"s"` (somatic), `"v"` (verbal) |
| `traits` | `text` | |
| `description` | `text` | |
| `prepared` | `boolean` | For prepared casters |

---

### `character_profile`
Physical description and personality. 1-to-1 with `characters`.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `character_id` | `uuid` | FK → `characters.id` |
| `ethnicity` | `text` | |
| `nationality` | `text` | |
| `birthplace` | `text` | |
| `age` | `int` | |
| `gender` | `text` | |
| `height` | `text` | |
| `weight` | `text` | |
| `appearance` | `text` | |
| `attitude` | `text` | |
| `beliefs` | `text` | |
| `likes` | `text` | |
| `dislikes` | `text` | |
| `catchphrases` | `text` | |
| `campaign_notes` | `text` | |
| `allies` | `text` | |
| `enemies` | `text` | |
| `organizations` | `text` | |

---

## Design decisions

**Why store proficiency as text and not as an integer?**

We could store `0/2/4/6/8` directly. But text enums (`"untrained"`, `"trained"`, etc.) are self-documenting and less error-prone — a value of `3` in an integer column is meaningless and hard to catch. The proficiency bonus formula is applied in the client: `untrained → 0`, `trained → 2 + level`, `expert → 4 + level`, `master → 6 + level`, `legendary → 8 + level`.

**Why are coins stored on `character_inventory` and not on `characters`?**

Coins in PF2e are part of the inventory and have bulk. Keeping them in the same table as equipment keeps the inventory section self-contained and makes future bulk calculations straightforward.

**Why can a character have multiple `character_spellcasting` rows?**

Some PF2e archetypes grant a second spellcasting tradition. For example, a Fighter who takes the Wizard archetype has their own spell slots and spells separate from any innate spellcasting they might also have. One row per tradition handles this cleanly.
