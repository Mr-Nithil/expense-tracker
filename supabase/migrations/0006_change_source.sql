-- 0006 (M10.14): who made each row and each change — the user or the agent (ARCHITECTURE §14).
--
-- created_by / updated_by: 'user' or 'agent'. agent_proposal_id: the approved agent proposal
-- behind the last change (set exactly when updated_by = 'agent'). Existing rows become 'user'.
-- The app writes 'user' (a local trigger resets the marks when the user edits an agent row); the
-- agent service writes 'agent' + the proposal id (docs/Agent/AGENT_INTEGRATION_GUIDE.md §6.7).
-- Labels for display and tracing, not a security control (both write with the user's token).
--
-- Run BEFORE installing the app build with M10.14: that build sends these columns on every push.
-- One statement per column so the app's schema test can read it.

alter table public.profiles add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.profiles add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.profiles add column agent_proposal_id uuid;
alter table public.profiles add constraint profiles_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.categories add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.categories add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.categories add column agent_proposal_id uuid;
alter table public.categories add constraint categories_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.transactions add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.transactions add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.transactions add column agent_proposal_id uuid;
alter table public.transactions add constraint transactions_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.budgets add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.budgets add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.budgets add column agent_proposal_id uuid;
alter table public.budgets add constraint budgets_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.goals add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.goals add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.goals add column agent_proposal_id uuid;
alter table public.goals add constraint goals_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.goal_contributions add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.goal_contributions add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.goal_contributions add column agent_proposal_id uuid;
alter table public.goal_contributions add constraint goal_contributions_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));

alter table public.reminders add column created_by text not null default 'user'
  check (created_by in ('user', 'agent'));
alter table public.reminders add column updated_by text not null default 'user'
  check (updated_by in ('user', 'agent'));
alter table public.reminders add column agent_proposal_id uuid;
alter table public.reminders add constraint reminders_change_source_consistent
  check ((updated_by = 'agent') = (agent_proposal_id is not null));
