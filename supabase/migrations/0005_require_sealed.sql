-- 0005 (M11.9): from now on the server only accepts sealed private columns.
--
-- RUN ONLY AFTER every device runs the app with M11 and has synced (each re-uploads its rows
-- sealed, M11.7). Old app versions can't sync after this (their plain values are rejected).
--
-- 1. Safety check: stops without changing anything while plain rows remain.
-- 2. Each row must carry payload_enc, and its plain private columns must be empty.
-- Runbook: docs/Security/ENCRYPTION_RUNBOOK.md, step 5.

do $$
declare
  spec record;
  plain bigint;
  column_name text;
  empty_columns text;
begin
  for spec in
    select * from (values
      ('categories',         array['name']),
      ('transactions',       array['amount_minor', 'note']),
      ('budgets',            array['limit_minor']),
      ('goals',              array['name', 'target_minor']),
      ('goal_contributions', array['amount_minor', 'note']),
      ('reminders',          array['title'])
    ) as s(tbl, encrypted)
  loop
    execute format('select count(*) from public.%I where payload_enc is null', spec.tbl) into plain;
    if plain > 0 then
      raise exception '% plain row(s) left in %: let every device sync with the updated app first',
        plain, spec.tbl;
    end if;
  end loop;

  for spec in
    select * from (values
      ('categories',         array['name']),
      ('transactions',       array['amount_minor', 'note']),
      ('budgets',            array['limit_minor']),
      ('goals',              array['name', 'target_minor']),
      ('goal_contributions', array['amount_minor', 'note']),
      ('reminders',          array['title'])
    ) as s(tbl, encrypted)
  loop
    -- Sealed rows already send them empty; clear any leftovers from old app edits.
    empty_columns := '';
    foreach column_name in array spec.encrypted loop
      execute format('update public.%I set %I = null where %I is not null', spec.tbl, column_name, column_name);
      empty_columns := empty_columns || format(' and %I is null', column_name);
    end loop;

    execute format('alter table public.%I drop constraint %I', spec.tbl, spec.tbl || '_plain_or_sealed');
    execute format(
      'alter table public.%1$I add constraint %2$I check (payload_enc is not null%3$s)',
      spec.tbl, spec.tbl || '_sealed', empty_columns);
  end loop;
end;
$$;
