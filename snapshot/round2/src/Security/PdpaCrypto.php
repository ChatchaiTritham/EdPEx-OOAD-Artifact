<?php

declare(strict_types=1);

namespace Edpex\Security;

/**
 * PDPA encryption-at-rest + blind-index, extracted from app/governance.php's appEncryptPII()/
 * appDecryptPII() (unchanged logic — AES-256-GCM, random IV per call, format `enc:v1:<base64(iv|tag|ct)>`)
 * so the Slim4 admission layer and the legacy function-based app share one implementation. The
 * legacy names stay as thin wrappers calling this class (see app/governance.php) — zero call-site
 * changes there.
 *
 * blindIndex() is new: AES-GCM's random IV means the same plaintext never encrypts to the same
 * ciphertext twice, so encrypted columns can never be looked up or de-duplicated by equality. The
 * blind index is a deterministic HMAC-SHA256 of the normalized plaintext, keyed by a SEPARATE
 * secret (APP_PDPA_INDEX_KEY) — leaking the index key must not help decrypt the PII itself.
 */
final class PdpaCrypto
{
    public function key(): string
    {
        $hex = (string) (getenv('APP_PDPA_KEY') ?: '');
        return (strlen($hex) === 64 && ctype_xdigit($hex)) ? (string) hex2bin($hex) : '';
    }

    public function indexKey(): string
    {
        $hex = (string) (getenv('APP_PDPA_INDEX_KEY') ?: '');
        return (strlen($hex) === 64 && ctype_xdigit($hex)) ? (string) hex2bin($hex) : '';
    }

    public function encrypt(string $plain): string
    {
        $key = $this->key();
        if ($key === '' || $plain === '') {
            return $plain;
        }
        $iv = random_bytes(12);
        $tag = '';
        $ct = openssl_encrypt($plain, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);
        if ($ct === false) {
            return $plain;
        }
        return 'enc:v1:' . base64_encode($iv . $tag . $ct);
    }

    public function decrypt(string $stored): string
    {
        if (!str_starts_with($stored, 'enc:v1:')) {
            return $stored;
        }
        $key = $this->key();
        if ($key === '') {
            return $stored;
        }
        $raw = base64_decode(substr($stored, 7), true);
        if ($raw === false || strlen($raw) < 28) {
            return $stored;
        }
        $iv = substr($raw, 0, 12);
        $tag = substr($raw, 12, 16);
        $ct = substr($raw, 28);
        $plain = openssl_decrypt($ct, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);
        return $plain === false ? $stored : $plain;
    }

    /** Deterministic lookup/dedup index for an encrypted column. Empty key = no-op (dev), matching
     *  encrypt()/decrypt()'s own dev fallback — never throws on a missing key. */
    public function blindIndex(string $plain): string
    {
        $key = $this->indexKey();
        if ($key === '' || $plain === '') {
            return '';
        }
        return hash_hmac('sha256', $this->normalize($plain), $key);
    }

    private function normalize(string $value): string
    {
        return strtoupper(trim(preg_replace('/\s+/', '', $value) ?? $value));
    }
}
