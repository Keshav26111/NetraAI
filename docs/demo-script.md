# Demo Script

**Status: TBD.** This is a placeholder flow. Fill in details once the corresponding features exist.

## Ground rules

- Use only license-verified public images or synthetic data. No real patient data.
- While the STUB model is active, every result shown must be labeled **STUB (no clinical
  meaning)**.
- Do not quote accuracy or performance figures unless they come from a documented, reproducible
  evaluation. Until then, say the system is not clinically validated.
- Always state that NetraAI is a screening-support aid and not a diagnostic device.

## Setup (TBD)

- Hardware and network: TBD
- Start command: TBD
- Demo accounts (health worker, doctor): TBD
- Demo images and source/license: TBD
- Model artifact or STUB: TBD

## Flow (TBD)

| # | Step | Shows | Status |
|---|---|---|---|
| 1 | Health worker logs in | Role-based access | TBD |
| 2 | Register a synthetic patient and record consent | Pseudonymous IDs, consent | TBD |
| 3 | Upload images for both eyes | Capture and upload flow | TBD |
| 4 | Quality check result, including a retake case | IQA gate | TBD |
| 5 | Analysis result | Grade, confidence, uncertainty | TBD |
| 6 | Doctor opens the case | Overlay ("regions that influenced the model"), probabilities, flags | TBD |
| 7 | Doctor confirms or overrides | Review workflow | TBD |
| 8 | Referral recommendation and patient summary | Rule-based referral (placeholder thresholds), plain-language summary | TBD |
| 9 | Offline scenario: capture without server, then sync | Offline-friendly design | TBD |
| 10 | Limitations and next steps | Honest scope, no clinical claims | TBD |

## Fallback plan (TBD)

Pre-recorded video, pre-computed cases, local-only mode if the network fails.

## Talking points requiring verified evidence (TBD)

Any claim about performance, clinical value or deployment readiness needs a source in
[model-card.md](model-card.md) or [data-card.md](data-card.md) before it is used.
