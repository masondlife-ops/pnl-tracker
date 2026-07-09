-- PNL Tracker — cloud sync database setup
-- Paste this whole file into the Supabase SQL Editor and click "Run".
-- It creates one table that stores each user's tracker data (one row per person),
-- and security rules so a logged-in user can only ever read/write their own row.

create table if not exists public.pnl_state (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.pnl_state enable row level security;

-- Each policy is scoped to auth.uid() = the currently logged-in user's id.
create policy "read own row"   on public.pnl_state
  for select using (auth.uid() = user_id);

create policy "insert own row" on public.pnl_state
  for insert with check (auth.uid() = user_id);

create policy "update own row" on public.pnl_state
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
