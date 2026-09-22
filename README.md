# NetraAI

AI-assisted **diabetic retinopathy screening-support** system, built as an MVP for SIH 2026.

> **NetraAI is not a diagnostic device.** It is a prototype screening aid. Every output is a
> suggestion that must be reviewed by a qualified clinician. It has **not** been clinically
> validated, and this repository makes **no accuracy or performance claims**.

## Status

**Phase 0: foundation only.** The repository currently contains structure, documentation
templates and project configuration. There is no application code, no trained model, no dataset
and no clinical validation yet.

Until a real model exists, inference will use a **deterministic STUB** behind the same inference
contract. STUB output carries no clinical meaning and must be labeled as such wherever it is shown.

## Planned MVP capabilities

- Fundus image quality assessment (gradable / ungradable, with reasons)
- DR severity classification
- Calibrated confidence and uncertainty estimation
- Evidence overlay (Grad-CAM): regions that influenced the model, not verified lesions
- Rule-based referral recommendation (thresholds are placeholder configuration until clinically validated)
- Doctor-facing review workflow and plain-language patient summary
- Low-resource and offline-friendly operation (local-first node plus installable PWA)

## Architecture at a glance

Modular monolith: React PWA, FastAPI backend, MySQL, and an in-process ML package
(`netra_ml`) behind a fixed inference contract. Full design: [docs/architecture.md](docs/architecture.md).

## Repository layout

```
NetraAI/
├─ docs/         architecture, api, model-card, data-card, threat-model, demo-script
├─ apps/
│  ├─ web/       React PWA (not yet implemented)
│  └─ api/       FastAPI backend (not yet implemented)
├─ ml/           training, evaluation and inference package `netra_ml` (not yet implemented)
├─ models/       model artifacts (never committed; see models/README.md)
├─ infra/        Docker Compose and proxy config (not yet implemented)
├─ tests/e2e/    end-to-end tests (not yet implemented)
└─ .github/workflows/   CI (not yet implemented)
```

## Getting started

Phase 0 has no runtime dependencies. To verify the foundation (requires only `make` and `git`):

```
make check
```

Optional: `cp .env.example .env`. The values are non-secret placeholders and are not consumed
by anything until Phase 2.

## Roadmap

| Phase | Scope |
|---|---|
| 0 | Foundations: structure, docs, dataset and license verification, contract definition |
| 1 | Data and baseline ML (ML track) |
| 2 | Application skeleton running on the STUB model (app track) |
| 3 | Real model integration, calibration, uncertainty, overlay |
| 4 | Hardening: offline mode, security pass, robustness tests |
| 5 | MVP demo and documentation |

## Out of scope for the MVP

Lesion segmentation, ONNX/on-device inference, Celery/Redis, Kubernetes, patient portal,
multi-clinic sync, ABDM integration. Diabetic macular edema and other eye diseases are not assessed.

## Data handling

No real patient data, datasets or model weights are committed to this repository. Any data used
for development or demos must be license-verified public data or synthetic. See
[docs/data-card.md](docs/data-card.md) and [docs/threat-model.md](docs/threat-model.md).

## Documentation

- [Architecture](docs/architecture.md)
- [API](docs/api.md)
- [Model card](docs/model-card.md) (TBD fields)
- [Data card](docs/data-card.md) (TBD fields)
- [Threat model](docs/threat-model.md)
- [Demo script](docs/demo-script.md) (TBD)
