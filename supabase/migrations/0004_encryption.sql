-- 0004 (M11.3): field encryption with server-held per-user keys (ARCHITECTURE §13).
--
-- 1. user_keys: each user's data key, wrapped by the ENCRYPTION_MASTER_KEY Edge Function secret.
--    RLS on with NO policies and no grants for app roles: only the `user-key` Edge Function
--    (service role) reads or writes it. The app never sees this table.
-- 2. payload_enc: the row's private fields sealed on the device ("v1.<nonce>.<ciphertext>").
-- 3. The encrypted columns become nullable: sealed rows send them as null. Their CHECKs stay
--    (NULL passes a CHECK) and still validate plain rows from app versions before M11.
-- 4. Every row keeps either its plain value or a payload.
--
-- Safe for installed app versions: they keep sending plain values and leave payload_enc null.
-- Run once in the Supabase SQL editor (or `supabase db push`). Runbook:
-- docs/Security/ENCRYPTION_RUNBOOK.md.

-- 1 -------------------------------------------------------------------------
create table public.user_keys (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  wrapped_key text not null check (wrapped_key ~ '^v1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'),
  created_at  timestamptz not null default now()
);

alter table public.user_keys enable row level security;
revoke all on table public.user_keys from anon, authenticated;

-- 2-4 -----------------------------------------------------------------------
do $$
declare
  spec record;
  required text;
begin
  for spec in
    select * from (values
      ('categories',         array['name'],                 'name'),
      ('transactions',       array['amount_minor', 'note'], 'amount_minor'),
      ('budgets',            array['limit_minor'],          'limit_minor'),
      ('goals',              array['name', 'target_minor'], 'name'),
      ('goal_contributions', array['amount_minor', 'note'], 'amount_minor'),
      ('reminders',          array['title'],                'title')
    ) as s(tbl, encrypted, required_column)
  loop
    execute format('alter table public.%I add column payload_enc text', spec.tbl);
    execute format(
      'alter table public.%1$I add constraint %2$I
         check (payload_enc is null or (char_length(payload_enc) <= 8000
           and payload_enc ~ ''^v1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$''))',
      spec.tbl, spec.tbl || '_payload_enc_format');

    foreach required in array spec.encrypted loop
      execute format('alter table public.%I alter column %I drop not null', spec.tbl, required);
    end loop;

    execute format(
      'alter table public.%1$I add constraint %2$I
         check (%3$I is not null or payload_enc is not null)',
      spec.tbl, spec.tbl || '_plain_or_sealed', spec.required_column);
  end loop;
end;
$$;
