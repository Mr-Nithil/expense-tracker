-- Manual check for 0006 (M10.14). Paste into the Supabase SQL editor after running 0006.
-- Everything is rolled back. Success: the final notice says "change source check passed".

begin;

do $$
declare
  user_a uuid := gen_random_uuid();
  cat_a  uuid := gen_random_uuid();
  sealed text := 'v1.AAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
  marks  record;
begin
  insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
  values (user_a, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
          'src-a-' || user_a || '@example.test', '{"display_name":"A"}', now(), now());
  perform set_config('request.jwt.claims', json_build_object('sub', user_a, 'role', 'authenticated')::text, true);
  set local role authenticated;

  -- Defaults: a row written without the columns is the user's.
  insert into public.categories (id, user_id, icon, color, type, created_at, updated_at, payload_enc)
  values (cat_a, user_a, 'food', 0, 'expense', now(), now(), sealed);
  select created_by, updated_by, agent_proposal_id into marks from public.categories where id = cat_a;
  if marks.created_by <> 'user' or marks.updated_by <> 'user' or marks.agent_proposal_id is not null then
    raise exception 'defaults are wrong: %', marks;
  end if;

  -- An agent change with its proposal id: accepted.
  update public.categories
     set updated_by = 'agent', agent_proposal_id = gen_random_uuid(), updated_at = now()
   where id = cat_a;

  -- An agent change without a proposal id: rejected.
  begin
    update public.categories set agent_proposal_id = null where id = cat_a;
    raise exception 'an agent change without a proposal id was accepted';
  exception when check_violation then null;
  end;

  -- A user change that still carries a proposal id: rejected.
  begin
    update public.categories set updated_by = 'user' where id = cat_a;
    raise exception 'a user change with a proposal id was accepted';
  exception when check_violation then null;
  end;

  -- Unknown values: rejected.
  begin
    update public.categories set created_by = 'robot' where id = cat_a;
    raise exception 'an unknown created_by was accepted';
  exception when check_violation then null;
  end;

  raise notice 'change source check passed';
end;
$$;

rollback;
