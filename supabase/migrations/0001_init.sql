-- 0001_init: all synced tables, mirroring lib/core/db/tables (Drift schema v1).
--
-- Rules (docs/ARCHITECTURE.md §6.2):
--   * snake_case columns with the same names as Drift. `sync_status` is local only and is NOT here.
--   * Every table: RLS with `user_id = auth.uid()`, a server_updated_at trigger, and an
--     index on (user_id, server_updated_at) for the pull cursor.
--   * Never edit this file after it has been applied. Add a new numbered migration instead.

-- ---------------------------------------------------------------------------
-- Shared trigger function: server-side write timestamp used as the pull cursor.
-- clock_timestamp() (not now()) so rows written later in a long transaction get later values.
-- Rows can still commit after a cursor has passed their timestamp, so sync pulls with a small
-- overlap window and merges idempotently (ARCHITECTURE §7).
-- ---------------------------------------------------------------------------
create or replace function public.set_server_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles: one row per user. id = user_id = auth.users.id
-- ---------------------------------------------------------------------------
create table public.profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  user_id           uuid not null references auth.users (id) on delete cascade,
  display_name      text check (char_length(display_name) <= 100),
  currency_code     text check (char_length(currency_code) = 3),
  locale            text,
  theme_mode        text not null default 'system' check (theme_mode in ('system', 'light', 'dark')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  constraint profiles_id_is_user_id check (id = user_id)
);

-- ---------------------------------------------------------------------------
-- categories
-- ---------------------------------------------------------------------------
create table public.categories (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  name              text not null check (char_length(name) between 1 and 50),
  icon              text not null,
  color             bigint not null,
  type              text not null check (type in ('expense', 'income')),
  is_default        boolean not null default false,
  sort_order        integer not null default 0,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  -- Target of composite foreign keys, so children can only reference their owner's rows.
  constraint categories_id_user_unique unique (id, user_id)
);

-- ---------------------------------------------------------------------------
-- transactions
-- ---------------------------------------------------------------------------
create table public.transactions (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  type              text not null check (type in ('expense', 'income')),
  amount_minor      bigint not null check (amount_minor > 0),
  category_id       uuid not null,
  occurred_on       date not null,
  note              text check (char_length(note) <= 500),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  constraint transactions_category_fk
    foreign key (category_id, user_id) references public.categories (id, user_id)
);

-- ---------------------------------------------------------------------------
-- budgets: category_id null = overall monthly budget.
-- Uniqueness per (user, month, category) comes from a deterministic client id (UUID v5), not a
-- unique index, so offline creation on two devices converges instead of failing the push.
-- ---------------------------------------------------------------------------
create table public.budgets (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  month             date not null check (extract(day from month) = 1),
  category_id       uuid,
  limit_minor       bigint not null check (limit_minor > 0),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  constraint budgets_category_fk
    foreign key (category_id, user_id) references public.categories (id, user_id)
);

-- ---------------------------------------------------------------------------
-- goals
-- ---------------------------------------------------------------------------
create table public.goals (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  name              text not null check (char_length(name) between 1 and 100),
  target_minor      bigint not null check (target_minor > 0),
  deadline_on       date,
  icon              text not null,
  color             bigint not null,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  constraint goals_id_user_unique unique (id, user_id)
);

-- ---------------------------------------------------------------------------
-- goal_contributions
-- ---------------------------------------------------------------------------
create table public.goal_contributions (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  goal_id           uuid not null,
  amount_minor      bigint not null check (amount_minor > 0),
  contributed_on    date not null,
  note              text check (char_length(note) <= 500),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  constraint goal_contributions_goal_fk
    foreign key (goal_id, user_id) references public.goals (id, user_id)
);

-- ---------------------------------------------------------------------------
-- reminders
-- ---------------------------------------------------------------------------
create table public.reminders (
  id                uuid primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  title             text not null check (char_length(title) between 1 and 100),
  time_of_day       text not null check (time_of_day ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  repeat_rule       text not null check (repeat_rule in ('daily', 'weekly', 'monthly')),
  weekdays          smallint check (weekdays between 0 and 127),
  enabled           boolean not null default true,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
create index profiles_user_sync_idx           on public.profiles (user_id, server_updated_at);
create index categories_user_sync_idx         on public.categories (user_id, server_updated_at);
create index transactions_user_sync_idx       on public.transactions (user_id, server_updated_at);
create index transactions_user_occurred_idx   on public.transactions (user_id, occurred_on);
create index transactions_category_idx        on public.transactions (category_id);
create index budgets_user_sync_idx            on public.budgets (user_id, server_updated_at);
create index budgets_category_idx             on public.budgets (category_id);
create index goals_user_sync_idx              on public.goals (user_id, server_updated_at);
create index goal_contributions_user_sync_idx on public.goal_contributions (user_id, server_updated_at);
create index goal_contributions_goal_idx      on public.goal_contributions (goal_id);
create index reminders_user_sync_idx          on public.reminders (user_id, server_updated_at);

-- ---------------------------------------------------------------------------
-- server_updated_at triggers, RLS, policies and grants (identical for every table)
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'categories', 'transactions', 'budgets',
    'goals', 'goal_contributions', 'reminders'
  ]
  loop
    execute format(
      'create trigger %1$s_set_server_updated_at
         before insert or update on public.%1$I
         for each row execute function public.set_server_updated_at()', t);

    execute format('alter table public.%I enable row level security', t);

    execute format(
      'create policy %1$I on public.%2$I for select to authenticated
         using (user_id = (select auth.uid()))', t || '_select_own', t);
    execute format(
      'create policy %1$I on public.%2$I for insert to authenticated
         with check (user_id = (select auth.uid()))', t || '_insert_own', t);
    execute format(
      'create policy %1$I on public.%2$I for update to authenticated
         using (user_id = (select auth.uid()))
         with check (user_id = (select auth.uid()))', t || '_update_own', t);
    execute format(
      'create policy %1$I on public.%2$I for delete to authenticated
         using (user_id = (select auth.uid()))', t || '_delete_own', t);

    execute format('revoke all on table public.%I from anon', t);
    execute format('grant select, insert, update, delete on table public.%I to authenticated', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Create a profile when a user signs up.
-- security definer so it can write past RLS; search_path pinned to avoid hijacking.
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, user_id, display_name, created_at, updated_at)
  values (
    new.id,
    new.id,
    nullif(left(new.raw_user_meta_data ->> 'display_name', 100), ''),
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
