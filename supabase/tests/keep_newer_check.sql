-- Manual check for 0002_keep_newer_rows.sql (TASKS M3.2). Paste into the Supabase SQL editor
-- and run AFTER applying the migration.
--
-- Creates a throwaway user and category inside a transaction, then checks that an older
-- update is ignored (but still bumps server_updated_at), and that newer and equal updates
-- apply. Everything is rolled back at the end.
-- Success: the final notice says "keep-newer check passed". Any failure raises an exception.

begin;

do $$
declare
  user_a   uuid := gen_random_uuid();
  cat      uuid := gen_random_uuid();
  base     timestamptz := '2026-10-11 12:00:00+00';
  stamp    timestamptz;
  new_name text;
begin
  insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
  values (user_a, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
          'keep-newer-' || user_a || '@example.test', '{"display_name":"A"}', now(), now());

  perform set_config('request.jwt.claims', json_build_object('sub', user_a, 'role', 'authenticated')::text, true);
  set local role authenticated;

  insert into public.categories (id, user_id, name, icon, color, type, created_at, updated_at)
  values (cat, user_a, 'Groceries', 'food', 4283215696, 'expense', base, base);
  select server_updated_at into stamp from public.categories where id = cat;

  -- 1. An OLDER write (e.g. an offline device's seed) is ignored, but server_updated_at moves on.
  update public.categories set name = 'Food', updated_at = base - interval '1 day' where id = cat;
  select name into new_name from public.categories where id = cat;
  if new_name <> 'Groceries' then raise exception 'older update overwrote the row (name = %)', new_name; end if;
  if (select server_updated_at from public.categories where id = cat) <= stamp then
    raise exception 'ignored update did not bump server_updated_at';
  end if;

  -- 2. A NEWER write applies.
  update public.categories set name = 'Food & drink', updated_at = base + interval '1 minute' where id = cat;
  select name into new_name from public.categories where id = cat;
  if new_name <> 'Food & drink' then raise exception 'newer update was not applied (name = %)', new_name; end if;

  -- 3. An EQUAL timestamp applies (a retried push of the same row).
  update public.categories set icon = 'cart', updated_at = base + interval '1 minute' where id = cat;
  if (select icon from public.categories where id = cat) <> 'cart' then
    raise exception 'equal-timestamp update was not applied';
  end if;

  raise notice 'keep-newer check passed';
end;
$$;

rollback;
