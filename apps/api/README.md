# apps/api

FastAPI backend. **Not yet implemented** (Phase 2).

Planned responsibilities: auth and RBAC, patient/visit/image CRUD, upload validation, calling
`netra_ml.inference.predict()`, the deterministic referral rule engine (`referral/`, thresholds are
unvalidated placeholder configuration), review workflow, audit log, report generation.

Boundary rule: import only `netra_ml.inference` from the ML package, never training code.

Planned layout: `routers/`, `services/`, `models/`, `schemas/`, `referral/`, `migrations/`.
The internal Python package layout is finalized when the backend is scaffolded.
