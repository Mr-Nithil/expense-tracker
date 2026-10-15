// Run with: deno test supabase/functions/user-key/key_wrap_test.ts
import { assert, assertEquals, assertNotEquals, assertRejects } from 'jsr:@std/assert@1';
import { fromBase64Url, importMasterKey, newDataKey, toBase64Url, unwrapKey, wrapKey } from './key_wrap.ts';

const secret = btoa(String.fromCharCode(...new Uint8Array(32).map((_, i) => i)));
const otherSecret = btoa(String.fromCharCode(...new Uint8Array(32).map((_, i) => 255 - i)));

Deno.test('wraps and unwraps a data key for its user', async () => {
  const master = await importMasterKey(secret);
  const key = newDataKey();
  const wrapped = await wrapKey(key, 'u1', master);

  assert(wrapped.startsWith('v1.'));
  assertEquals(await unwrapKey(wrapped, 'u1', master), key);
});

Deno.test('another user, master key or a changed byte fails', async () => {
  const master = await importMasterKey(secret);
  const wrapped = await wrapKey(newDataKey(), 'u1', master);

  await assertRejects(() => unwrapKey(wrapped, 'u2', master));
  await assertRejects(async () => unwrapKey(wrapped, 'u1', await importMasterKey(otherSecret)));
  const body = wrapped.split('.')[2];
  const tampered = wrapped.replace(body, (body[0] === 'A' ? 'B' : 'A') + body.slice(1));
  await assertRejects(() => unwrapKey(tampered, 'u1', master));
});

Deno.test('fresh nonces and fresh keys', async () => {
  const master = await importMasterKey(secret);
  const key = newDataKey();
  assertNotEquals(await wrapKey(key, 'u1', master), await wrapKey(key, 'u1', master));
  assertNotEquals(toBase64Url(newDataKey()), toBase64Url(newDataKey()));
});

Deno.test('the master key must be 32 bytes and present', async () => {
  await assertRejects(() => importMasterKey(undefined));
  await assertRejects(() => importMasterKey(btoa('short')));
});

Deno.test('base64url round trip without padding', () => {
  const bytes = new Uint8Array([251, 255, 0, 1, 2]);
  assertEquals(fromBase64Url(toBase64Url(bytes)), bytes);
  assert(!toBase64Url(bytes).includes('='));
});
