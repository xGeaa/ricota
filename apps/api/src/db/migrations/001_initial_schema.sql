-- Users profile (extends Supabase Auth)
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  created_at timestamptz default now()
);

-- Game sessions
create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text unique not null,
  gm_id uuid not null references public.users(id) on delete cascade,
  created_at timestamptz default now()
);

-- Links players + characters to a session
create table public.session_members (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  character_id uuid not null,
  joined_at timestamptz default now()
);

-- Core character identity
create table public.characters (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  player_name text,
  ancestry text,
  heritage text,
  background text,
  char_class text,
  level int not null default 1,
  experience_points int not null default 0,
  hero_points int not null default 0,
  size text not null default 'medium',
  alignment text,
  deity text,
  traits text,
  speed_ft int not null default 25,
  languages text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Ability scores
create table public.character_ability_scores (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null unique references public.characters(id) on delete cascade,
  strength int not null default 10,
  dexterity int not null default 10,
  constitution int not null default 10,
  intelligence int not null default 10,
  wisdom int not null default 10,
  charisma int not null default 10
);

-- HP, AC, shield
create table public.character_combat (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null unique references public.characters(id) on delete cascade,
  max_hp int not null default 0,
  current_hp int not null default 0,
  temp_hp int not null default 0,
  dying int not null default 0,
  wounded int not null default 0,
  ac_base int not null default 10,
  armor_worn text,
  armor_proficiency text not null default 'untrained',
  shield_name text,
  shield_hardness int not null default 0,
  shield_max_hp int not null default 0,
  shield_current_hp int not null default 0,
  perception_proficiency text not null default 'untrained',
  class_dc_key_ability text,
  class_dc_proficiency text not null default 'untrained'
);

-- Saving throws
create table public.character_saving_throws (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null unique references public.characters(id) on delete cascade,
  fortitude_proficiency text not null default 'untrained',
  reflex_proficiency text not null default 'untrained',
  will_proficiency text not null default 'untrained',
  fortitude_notes text,
  reflex_notes text,
  will_notes text
);

-- Skills
create table public.character_skills (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  skill_name text not null,
  lore_topic text,
  proficiency text not null default 'untrained',
  item_bonus int not null default 0,
  armor_penalty boolean not null default false,
  notes text
);

-- Weapons
create table public.character_weapons (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  name text not null,
  type text not null default 'melee',
  proficiency text not null default 'untrained',
  ability_used text not null default 'strength',
  damage_dice text,
  damage_type text,
  damage_bonus_str boolean not null default true,
  traits text,
  special text,
  notes text
);

-- Active conditions
create table public.character_conditions (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  condition_name text not null,
  value int not null default 0,
  notes text,
  applied_at timestamptz default now()
);

-- Inventory
create table public.character_inventory (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  name text not null,
  category text not null default 'other',
  quantity int not null default 1,
  bulk numeric not null default 0,
  invested boolean not null default false,
  notes text,
  coins_cp int not null default 0,
  coins_sp int not null default 0,
  coins_gp int not null default 0,
  coins_pp int not null default 0
);

-- Feats
create table public.character_feats (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  name text not null,
  feat_type text not null default 'general',
  level_gained int not null default 1,
  traits text,
  description text
);

-- Actions, free actions and reactions
create table public.character_actions (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  name text not null,
  action_type text not null default 'action',
  num_actions text not null default '1',
  trigger text,
  traits text,
  description text,
  page_ref text
);

-- Character profile and personality
create table public.character_profile (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null unique references public.characters(id) on delete cascade,
  ethnicity text,
  nationality text,
  birthplace text,
  age int,
  gender text,
  height text,
  weight text,
  appearance text,
  attitude text,
  beliefs text,
  likes text,
  dislikes text,
  catchphrases text,
  campaign_notes text,
  allies text,
  enemies text,
  organizations text
);

-- Spellcasting traditions
create table public.character_spellcasting (
  id uuid primary key default gen_random_uuid(),
  character_id uuid not null references public.characters(id) on delete cascade,
  tradition text not null default 'arcane',
  casting_type text not null default 'prepared',
  key_ability text not null default 'intelligence',
  spell_attack_proficiency text not null default 'untrained',
  spell_dc_proficiency text not null default 'untrained',
  focus_points_current int not null default 0,
  focus_points_max int not null default 0
);

-- Spell slots per level
create table public.character_spell_slots (
  id uuid primary key default gen_random_uuid(),
  spellcasting_id uuid not null references public.character_spellcasting(id) on delete cascade,
  spell_level int not null,
  slots_max int not null default 0,
  slots_used int not null default 0
);

-- Known or prepared spells
create table public.character_spells (
  id uuid primary key default gen_random_uuid(),
  spellcasting_id uuid not null references public.character_spellcasting(id) on delete cascade,
  name text not null,
  spell_level int not null default 0,
  spell_type text not null default 'spell',
  casting_time text,
  components text,
  traits text,
  description text,
  prepared boolean not null default false
);
