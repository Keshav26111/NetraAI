# Threat Model (STRIDE-lite starting point)

Status: initial draft, to be revised as components are built. All mitigations below are
**planned**; none are implemented yet (Phase 0).

## Assets

- Fundus images and patient identifiers (sensitive health data)
- Screening results, referral decisions, clinician overrides
- Model artifacts and referral rule configuration (integrity matters)
- Credentials and tokens
- Audit log

## Actors and trust boundaries

| Actor | Trust |
|---|---|
| Health worker | Authenticated, can capture and view assigned cases |
| Doctor | Authenticated, can review and confirm |
| Admin | Authenticated, manages users and audit |
| Patient | Receives a clinician-approved summary only; no login in the MVP |
| Anonymous network user | Untrusted |
| Clinic LAN device | Partially trusted (shared Wi-Fi) |

Boundaries: browser/PWA to API; API to database and image store; API to model artifact.

## STRIDE

| Category | Example threat | Planned mitigation |
|---|---|---|
| **Spoofing** | Stolen or guessed credentials; forged tokens | Strong password hashing, short-lived tokens, login rate limiting, TLS |
| **Tampering** | Modified model artifact or referral rules; altered results | Pinned model version and hash, config kept in version control, append-only audit, clinician override recorded not overwritten |
| **Repudiation** | User denies viewing or changing a case | Append-only audit log of views and changes |
| **Information disclosure** | Leaked images or identifiers; PII in filenames or logs; data left on shared devices | Pseudonymous IDs, UUID filenames, EXIF stripping, TLS, encrypted volume, RBAC and per-case access checks, no PII in logs, minimal offline queue cleared after sync |
| **Denial of service** | Oversized or many uploads exhaust the server | Size limits, rate limiting, in-process queue limits |
| **Elevation of privilege** | Health worker reaches doctor or admin functions | Server-side RBAC on every endpoint, tests for role boundaries |

## ML- and safety-specific threats

| Threat | Planned mitigation |
|---|---|
| Malicious or corrupt upload (crafted file) | Magic-byte checks, decode and re-encode with an image library, size caps |
| Non-fundus or out-of-distribution input yields a confident result | IQA/OOD gate, tests with blank and unrelated images |
| Output misread as a diagnosis | Persistent screening-aid notice, mandatory clinician review, no bare "normal" result, STUB clearly labeled |
| STUB output mistaken for real results | STUB flagged in the `model` group and in the UI |
| Placeholder referral thresholds mistaken for validated ones | Marked as placeholders in config, docs and UI until clinically validated |
| Training on unlicensed or real patient data | License verification, data-card records, no real patient data without consent and ethics approval |

## Out of scope for now

Multi-clinic sync, patient portal, ABDM integration, and on-device inference are deferred, so their
threats are not modeled yet.

## Open questions

- Applicable Indian data-protection obligations (DPDP Act, ABDM) need confirmation from a mentor
  or legal advisor.
- Retention and deletion policy for images and results.
- Whether encryption at rest is handled at disk level or application level for the demo.
