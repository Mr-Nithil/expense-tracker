-- Manual RLS check (TASKS M0.28). Paste into the Supabase SQL editor and run.
--
-- Creates two throwaway users inside a transaction, acts as each one, and checks that neither
-- can read or write the other's rows. Everything is rolled back at the end.
-- Success: the final notice says "RLS check passed". Any failure raises an exception.

begin;

do $$
declare
  user_a uuid := gen_random_uuid();
  user_b uuid := gen_random_uuid();
  cat_a  uuid := gen_random_uuid();
  n      int;
begin
  -- Two users (the handle_new_user trigger also creates their profiles).
  insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
  values
    (user_a, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'rls-a-' || user_a || '@example.test', '{"display_name":"A"}', now(), now()),
    (user_b, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'rls-b-' || user_b || '@example.test', '{"display_name":"B"}', now(), now());

  select count(*) into n from public.profiles where id in (user_a, user_b);
  if n <> 2 then raise exception 'handle_new_user did not create both profiles (got %)', n; end if;

  -- ---- Act as user A ------------------------------------------------------
  perform set_config('request.jwt.claims', json_build_object('sub', user_a, 'role', 'authenticated')::text, true);
  set local role authenticated;

  insert into public.categories (id, user_id, name, icon, color, type, created_at, updated_at)
  values (cat_a, user_a, 'Food', 'food', 4283215696, 'expense', now(), now());

  insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at)
  values (gen_random_uuid(), user_a, 'expense', 1200, cat_a, current_date, now(), now());

  select count(*) into n from public.profiles;
  if n <> 1 then raise exception 'A sees % profiles, expected 1', n; end if;

  -- A cannot insert rows owned by B.
  begin
    insert into public.categories (id, user_id, name, icon, color, type, created_at, updated_at)
    values (gen_random_uuid(), user_b, 'Hack', 'x', 0, 'expense', now(), now());
    raise exception 'A inserted a row for B';
  exception when insufficient_privilege then null;
  end;

  -- server_updated_at is set by the trigger, not the client.
  select count(*) into n from public.categories
   where id = cat_a and server_updated_at > now() - interval '1 minute';
  if n <> 1 then raise exception 'server_updated_at trigger did not run'; end if;

  reset role;

  -- ---- Act as user B ------------------------------------------------------
  perform set_config('request.jwt.claims', json_build_object('sub', user_b, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select count(*) into n from public.categories;
  if n <> 0 then raise exception 'B can read A''s categories (% rows)', n; end if;

  select count(*) into n from public.transactions;
  if n <> 0 then raise exception 'B can read A''s transactions (% rows)', n; end if;

  update public.categories set name = 'Hacked' where id = cat_a;
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'B updated A''s category'; end if;

  delete from public.categories where id = cat_a;
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'B deleted A''s category'; end if;

  -- B cannot attach a transaction to A's category (composite FK + RLS).
  begin
    insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at)
    values (gen_random_uuid(), user_b, 'expense', 100, cat_a, current_date, now(), now());
    raise exception 'B referenced A''s category';
  exception when foreign_key_violation then null;
  end;

  reset role;

  -- ---- Anonymous ----------------------------------------------------------
  set local role anon;
  begin
    perform 1 from public.categories limit 1;
    raise exception 'anon can read categories';
  exception when insufficient_privilege then null;
  end;
  reset role;

  raise notice 'RLS check passed';
end;
$$;

rollback;
