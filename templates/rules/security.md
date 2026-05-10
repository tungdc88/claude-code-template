---
paths: ["**/auth/**", "**/api/**", "**/routes/**", "**/*secret*", "**/*token*", "**/*password*"]
---
- NEVER log secrets, tokens, API keys, or passwords — even at DEBUG level
- Validate ALL user input at system boundaries — never trust input downstream
- Hash passwords with bcrypt or argon2 — never md5, sha1, sha256 raw
- Check OWASP Top 10 before marking auth/payment changes as complete:
  A01 Broken Access Control, A02 Cryptographic Failures, A03 Injection,
  A07 Identification/Auth Failures, A09 Logging/Monitoring Failures
- Rate limiting on all auth endpoints
- JWT: verify signature + expiry + audience — never decode-only without verify
- CORS: explicit allowlist, never `*` in production
- Secrets via environment variables or secret manager — never hardcoded
