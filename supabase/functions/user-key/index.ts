// Edge Function `user-key` (M11.4): returns the signed-in user's data key, creating it on first
// use. The key is stored only wrapped by the ENCRYPTION_MASTER_KEY secret in public.user_keys
// (no app access; service role only). Deploy with "Verify JWT" on.
// Runbook: docs/Security/ENCRYPTION_RUNBOOK.md.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { importMasterKey, newDataKey, toBase64Url, unwrapKey, VERSION, wrapKey } from './key_wrap.ts';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: auth, error: authError } = await admin.auth.getUser(token);
  const user = auth?.user;
  if (authError || !user) return json({ error: 'unauthorized' }, 401);

  let master: CryptoKey;
  try {
    master = await importMasterKey(Deno.env.get('ENCRYPTION_MASTER_KEY'));
  } catch (error) {
    console.error('user-key: master key not configured', (error as Error).message);
    return json({ error: 'not_configured' }, 500);
  }

  const read = () => admin.from('user_keys').select('wrapped_key').eq('user_id', user.id).maybeSingle();

  try {
    let { data: row, error } = await read();
    if (error) throw error;

    if (!row) {
      // First use: create and store the key. Two devices asking at once both insert; the first
      // insert wins and both return the stored key.
      const wrapped = await wrapKey(newDataKey(), user.id, master);
      const insert = await admin
        .from('user_keys')
        .upsert({ user_id: user.id, wrapped_key: wrapped }, { onConflict: 'user_id', ignoreDuplicates: true });
      if (insert.error) throw insert.error;
      ({ data: row, error } = await read());
      if (error || !row) throw error ?? new Error('key not stored');
    }

    const dataKey = await unwrapKey(row.wrapped_key, user.id, master);
    return json({ version: VERSION, key: toBase64Url(dataKey) });
  } catch (error) {
    // Never log key material: only the message.
    console.error('user-key: failed for a user', (error as Error).message);
    return json({ error: 'key_unavailable' }, 500);
  }
});
