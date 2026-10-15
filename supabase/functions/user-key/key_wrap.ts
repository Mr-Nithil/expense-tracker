// Wrapping of per-user data keys with the master key (M11.4, ARCHITECTURE §13).
// AES-256-GCM (WebCrypto), random 12-byte nonce, authenticated data "user-key/v1|<user_id>",
// envelope "v1.<nonce>.<ciphertext+tag>" in base64url without padding (same as the app's
// RowCipher envelope). Never log keys.

export const VERSION = 'v1';
export const KEY_LENGTH = 32;
const NONCE_LENGTH = 12;

export function toBase64Url(bytes: Uint8Array): string {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

export function fromBase64Url(text: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]*$/.test(text)) throw new Error('not base64url');
  const padded = text.replaceAll('-', '+').replaceAll('_', '/') + '='.repeat((4 - (text.length % 4)) % 4);
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

/** The master key from its secret (standard base64 of 32 bytes, e.g. `openssl rand -base64 32`). */
export async function importMasterKey(secret: string | undefined): Promise<CryptoKey> {
  if (!secret) throw new Error('ENCRYPTION_MASTER_KEY is not set');
  const raw = Uint8Array.from(atob(secret.trim()), (c) => c.charCodeAt(0));
  if (raw.length !== KEY_LENGTH) throw new Error('ENCRYPTION_MASTER_KEY must be 32 bytes');
  return crypto.subtle.importKey('raw', raw, 'AES-GCM', false, ['encrypt', 'decrypt']);
}

const aad = (userId: string) => new TextEncoder().encode(`user-key/${VERSION}|${userId}`);

export async function wrapKey(dataKey: Uint8Array, userId: string, master: CryptoKey): Promise<string> {
  if (dataKey.length !== KEY_LENGTH) throw new Error('data key must be 32 bytes');
  const nonce = crypto.getRandomValues(new Uint8Array(NONCE_LENGTH));
  const sealed = new Uint8Array(
    await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce, additionalData: aad(userId) }, master, dataKey),
  );
  return [VERSION, toBase64Url(nonce), toBase64Url(sealed)].join('.');
}

/** Throws when the envelope is malformed, tampered with, or wrapped for another user or key. */
export async function unwrapKey(wrapped: string, userId: string, master: CryptoKey): Promise<Uint8Array> {
  const parts = wrapped.split('.');
  if (parts.length !== 3 || parts[0] !== VERSION) throw new Error('unknown wrapped key format');
  const nonce = fromBase64Url(parts[1]);
  if (nonce.length !== NONCE_LENGTH) throw new Error('malformed wrapped key');
  const dataKey = new Uint8Array(
    await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv: nonce, additionalData: aad(userId) },
      master,
      fromBase64Url(parts[2]),
    ),
  );
  if (dataKey.length !== KEY_LENGTH) throw new Error('malformed wrapped key');
  return dataKey;
}

export function newDataKey(): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(KEY_LENGTH));
}
