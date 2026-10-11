-- 0002: last-write-wins on the server (TASKS M3.2).
--
-- Devices push their pending rows with a plain upsert. A device that was offline can hold an
-- OLDER version of a row that another device already changed and synced. Without this guard its
-- push would overwrite the newer data on the server, and nothing could bring it back.
--
-- keep_newer_row() runs BEFORE UPDATE: when the incoming updated_at is older than the stored one,
-- the stored row is kept. The trigger is named "<table>_0_keep_newer_row" so it fires before
-- "<table>_set_server_updated_at" (Postgres fires triggers in name order), which still stamps a
-- fresh server_updated_at on the kept row. The stale device's next pull therefore picks up the
-- newer version and replaces its own copy.
--
-- Equal timestamps are applied (a retried push of the same row must succeed).

create or replace function public.keep_newer_row()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.updated_at < old.updated_at then
    return old;
  end if;
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'categories', 'transactions', 'budgets', 'goals', 'goal_contributions', 'reminders'
  ]
  loop
    execute format(
      'create trigger %1$s_0_keep_newer_row
         before update on public.%1$I
         for each row execute function public.keep_newer_row()', t);
  end loop;
end;
$$;
