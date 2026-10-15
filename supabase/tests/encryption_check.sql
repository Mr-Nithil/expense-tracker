-- Manual check for 0004 (M11.3). Paste into the Supabase SQL editor after running 0004.
-- Everything is rolled back. Success: the final notice says "encryption check passed".

begin;

do $$
declare
  user_a uuid := gen_random_uuid();
  cat_a  uuid := gen_random_uuid();
  sealed text := 'v1.AAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
  n      int;
begin
  insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
  values (user_a, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
          'enc-a-' || user_a || '@example.test', '{"display_name":"A"}', now(), now());
  insert into public.user_keys (user_id, wrapped_key) values (user_a, sealed);

  perform set_config('request.jwt.claims', json_build_object('sub', user_a, 'role', 'authenticated')::text, true);
  set local role authenticated;

  -- The app can never read or write user_keys, not even its own row.
  begin
    select count(*) into n from public.user_keys;
    raise exception 'authenticated could read user_keys';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.user_keys (user_id, wrapped_key) values (user_a, sealed);
    raise exception 'authenticated could write user_keys';
  exception when insufficient_privilege then null;
  end;

  -- A sealed category (no plain name) is accepted.
  insert into public.categories (id, user_id, name, icon, color, type, created_at, updated_at, payload_enc)
  values (cat_a, user_a, null, 'food', 0, 'expense', now(), now(), sealed);

  -- A sealed transaction is accepted; a plain one too (app versions before M11).
  insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at, payload_enc)
  values (gen_random_uuid(), user_a, 'expense', null, cat_a, current_date, now(), now(), sealed);
  insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at)
  values (gen_random_uuid(), user_a, 'expense', 1250, cat_a, current_date, now(), now());

  -- Neither plain nor sealed: rejected.
  begin
    insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at)
    values (gen_random_uuid(), user_a, 'expense', null, cat_a, current_date, now(), now());
    raise exception 'a row with neither a plain amount nor a payload was accepted';
  exception when check_violation then null;
  end;

  -- A malformed payload: rejected.
  begin
    insert into public.transactions (id, user_id, type, amount_minor, category_id, occurred_on, created_at, updated_at, payload_enc)
    values (gen_random_uuid(), user_a, 'expense', null, cat_a, current_date, now(), now(), 'plain text');
    raise exception 'a malformed payload was accepted';
  exception when check_violation then null;
  end;

  raise notice 'encryption check passed';
end;
$$;

rollback;
