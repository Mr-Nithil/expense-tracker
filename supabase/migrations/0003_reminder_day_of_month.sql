-- 0003 (M8.2): monthly reminders store which day of the month they fire on.
--
-- Nullable, no default: existing reminders are unchanged (daily/weekly leave it null). RLS and
-- the server_updated_at trigger are per table, so they already cover the new column.
-- Run once in the Supabase SQL editor (or `supabase db push`).

alter table public.reminders
  add column day_of_month smallint check (day_of_month between 1 and 31);
