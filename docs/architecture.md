# NetraAI Architecture

Status: approved working direction for the SIH 2026 MVP.
Tags: **[Optional]** = nice to have. **[Postpone]** = explicitly out of MVP scope.

## Approved constraints

- The MVP is a **modular monolith**.
- **Not to be implemented yet:** lesion segmentation, ONNX, Celery/Redis, Kubernetes, patient portal,
  multi-clinic sync, ABDM integration.
- **No invented clinical thresholds or accuracy numbers.** Referral thresholds are
  configuration/placeholders until clinically validated.
- **MySQL is the canonical primary database** for development and production, accessed through
  SQLAlchemy with Alembic migrations (section 3).
- The ML model is **replaceable behind the frozen inference contract** (section 5).
- A **deterministic STUB model** is used first, so the complete application can be built before a
  real model exists.

## 0. Framing and guardrails

- NetraAI is a **screening-support tool, not a diagnostic device**. Every output is a suggestion
  and a clinician confirms it in the MVP.
- No accuracy numbers appear anywhere until measured on our own held-out data. Documents use
  TBD placeholders until then.
- **Datasets are not assumed.** Candidate public DR datasets (for example APTOS, EyePACS,
  Messidor-2, IDRiD, DDR, FGADR) must each be verified for license, access terms and label scheme
  before use. See [data-card.md](data-card.md).
- **Out of scope for the MVP:** diabetic macular edema, glaucoma, AMD and other pathologies. This
  limitation must be shown in the UI and the model card.
- Anything touching Indian health-data regulation (DPDP Act, ABDM) needs mentor or legal
  confirmation. This document is not legal advice.

## 1. System architecture

```
 Health worker / Doctor / Patient summary
              |  (PWA, React)
              v
   +--------------------------+
   |  Reverse proxy (Caddy)   |  TLS
   +------------+-------------+
                v
   +--------------------------+        +-------------+
   |  FastAPI  (apps/api)     |------->| MySQL       |
   |  auth, cases, referral   |        +-------------+
   |  rules, audit, reports   |        +-------------+
   |        | predict()       |------->| Image store |  local volume
   |        v                 |        +-------------+  (S3/MinIO [Postpone])
   |  netra_ml (ml/ package)  |
   |  IQA -> preprocess ->    |<-- pinned model artifact (versioned folder)
   |  DR grade -> uncertainty |
   |  -> Grad-CAM overlay     |
   +--------------------------+
```

**Offline strategy (three tiers):**

- **MVP:** the whole stack runs on a clinic laptop or mini-PC. Tablets connect over local Wi-Fi
  and use the installed PWA.
- **MVP:** the PWA caches its app shell and queues uploads in IndexedDB while the server is
  unreachable.
- **[Postpone]** On-device inference and multi-clinic sync to a central server.

## 2. Responsibilities

| Layer | Owns | Does NOT own |
|---|---|---|
| **Frontend** | Capture/upload UX, role-based views, doctor review screen with overlay toggle, patient summary in local language, offline queue, i18n | Clinical logic or thresholds |
| **Backend** | Auth/RBAC, patient/visit/image CRUD, upload validation, calling `predict()`, referral rule engine, review workflow, audit log, report generation | Model training, image-model internals |
| **ML** | IQA, preprocessing, DR grading, calibration, uncertainty, overlay generation, evaluation, model artifacts | Storage, auth, HTTP |
| **Database (MySQL)** | Pseudonymous patients, visits, image metadata and paths, analyses, reviews, audit trail, model versions used | Image bytes (kept in the image store) |

The referral engine is **deterministic and rule-based, not ML**, so a clinician advisor can review
it. Its thresholds are configuration placeholders until clinically validated.

## 3. Technology stack

| Area | Choice | Why |
|---|---|---|
| Frontend | React + Vite + TypeScript + Tailwind, TanStack Query, `vite-plugin-pwa`, `react-i18next` | Fast to build; PWA gives installable, offline-capable UI without native code |
| Backend | FastAPI + Pydantic + SQLAlchemy + Alembic | Python matches the ML code; OpenAPI docs are automatic |
| Database | MySQL (SQLite only for isolated unit tests) | See "Why MySQL" below |
| ML training | PyTorch + `timm`, Albumentations, `pytorch-grad-cam` | Standard, well documented; transfer learning suits limited data |
| ML inference | PyTorch on CPU | Simple; ONNX is **[Postpone]** |
| Async work | FastAPI BackgroundTasks or an in-process queue | Single-image inference is short; Celery/Redis **[Postpone]** |
| Infra | Docker Compose, Caddy, GitHub Actions | One-command demo, simple TLS |
| Tracking | MLflow (local) or plain run folders with JSON logs | Reproducibility without a server |

Explicitly avoided: Kubernetes, Kafka, microservices, a custom model server.

### Why MySQL

- Mature, widely used relational database with extensive documentation and tooling.
- Works well with SQLAlchemy and Alembic.
- Suits the workload: relational CRUD, RBAC tables and an append-only audit trail, with image
  bytes kept outside the database.
- Keeps MVP deployment straightforward: a single official container image, easy to run on a clinic
  laptop or one VM.

This is an engineering choice for the MVP workload. It is not a claim that MySQL is better than any
other database, and it has no bearing on clinical performance.

### MySQL conventions and compatibility

MySQL is the canonical database for development, any test that touches the schema, and production.
SQLite is acceptable only for isolated unit tests that do not depend on migrations or
database-specific behavior. Image bytes stay in the image store; MySQL holds metadata and paths only.

- **Version:** use a currently supported release. MySQL 8.4 LTS is the assumed default; MySQL 8.0
  reached end of life in April 2026 and must not be used. Pin the exact version when the Compose
  file is written (Phase 2) and re-check its support status then.
- **Driver and URL:** `DATABASE_URL` uses SQLAlchemy's MySQL dialect (`mysql+pymysql://...`).
  PyMySQL is the assumed driver (pure Python, no native build step); the final choice is made at
  Phase 2. MySQL 8.4 disables `mysql_native_password` by default, so use the default
  `caching_sha2_password`, which PyMySQL supports with the `cryptography` package installed.
- **Character set:** `utf8mb4` everywhere (`?charset=utf8mb4` in the URL).
- **Storage engine:** InnoDB (transactions, foreign keys).
- **Timestamps:** store in UTC. MySQL `DATETIME` carries no timezone.
- **UUIDs:** MySQL has no native UUID type. Use SQLAlchemy's generic UUID type, stored in a
  fixed-length column.
- **Table names:** lowercase snake_case only, because table-name case sensitivity differs between
  Linux and Windows/macOS hosts.
- **Migrations:** MySQL DDL is not transactional, so a failed migration can leave a partial change.
  Keep Alembic migrations small, test them by upgrading a fresh MySQL database, and back up before
  applying them anywhere that holds data worth keeping.
- **SQL mode:** keep the server's default strict mode so invalid or truncated values raise errors.

## 4. Repository structure

```
NetraAI/
├─ docs/                  architecture, api, model-card, data-card, threat-model, demo-script
├─ apps/
│  ├─ web/                React PWA (src/features: capture, review, patient-summary, admin)
│  └─ api/                FastAPI (routers, services, models, schemas, referral, migrations)
├─ ml/
│  ├─ configs/            YAML per experiment
│  ├─ src/netra_ml/       data, preprocess, iqa, models, train, eval,
│  │                      calibrate, uncertainty, explain, inference, export
│  ├─ scripts/  notebooks/  tests/
├─ models/                artifacts (git-ignored; versioned folders + model_card.json)
├─ infra/                 docker-compose.yml, Caddyfile
├─ tests/e2e/
└─ .github/workflows/
```

**Boundary rule:** `apps/api` imports only `netra_ml.inference`. It never imports training code.
Requirements are split into inference and training sets so the API image stays small.

## 5. Inference contract

`netra_ml.inference.predict(...)` returns an `AnalysisResult`. The contract is frozen at the
field-group level; the machine-readable schema is **TBD**.

| Group | Contents |
|---|---|
| `quality` | gradable / ungradable, reasons, score |
| `grade` | label and calibrated probabilities |
| `uncertainty` | level and method |
| `explanation` | overlay type and reference |
| `referral` | category, rationale, rule version (produced by the backend rule engine from the fields above) |
| `model` | version and hash |

**STUB model:** a deterministic implementation of the same contract, used until a real model
exists. The same input must always produce the same output. It is clearly flagged as STUB through
the `model` group and in the UI, and its output has no clinical meaning.

## 6. ML pipeline and data flow

1. **Ingest:** validate type, size and decodability, strip EXIF, rename to a UUID, store.
2. **IQA gate:** gradable or ungradable plus reasons (blur, exposure, field of view, optic disc
   or macula not visible). Start with heuristics; a small CNN is **[Optional]** if quality-labeled
   data is verified. Ungradable means "retake image" and no DR grade is shown.
3. **Preprocess:** crop borders, resize, normalize. The same function is used in training and
   inference and is versioned in the artifact.
4. **DR grading:** severity classification (label scheme depends on the verified dataset) plus a
   derived "referable" flag. The definition of "referable" must be confirmed by the clinician
   advisor and is TBD.
5. **Uncertainty:** calibrated probabilities and an abstention rule (section 8).
6. **Explanation:** Grad-CAM overlay.
7. **Referral engine:** takes quality, grade, uncertainty and optional patient factors and outputs
   a category (re-screen, refer non-urgent, refer urgent, retake/cannot grade). Timelines and
   thresholds are **configuration placeholders until clinically validated**.
8. **Persist:** model version and hash, outputs, overlay reference, rule version.
9. **Doctor review:** accept or override with notes. Overrides are stored. Retraining from them is
   **[Postpone]**.

**Visit-level logic:** a visit has up to two eyes and multiple images. The visit result is driven
by the worse eye, and any ungradable eye is surfaced explicitly.

**Patient-facing output:** a plain-language summary in the local language, released only after
clinician confirmation. A patient login/portal is **[Postpone]**.

## 7. API (high level, `/api/v1`)

| Group | Endpoints |
|---|---|
| Auth | `POST /auth/login`, `POST /auth/refresh`, `GET /me` |
| Patients | `POST/GET /patients`, `GET /patients/{id}` |
| Visits | `POST /patients/{id}/visits`, `GET /visits/{id}` |
| Images | `POST /visits/{id}/images` (multipart, with eye side); returns quality result immediately |
| Analysis | `GET /images/{id}/analysis`, `GET /images/{id}/overlay` |
| Result | `GET /visits/{id}/result` (aggregate and referral) |
| Review | `POST /visits/{id}/review` |
| Report | `GET /visits/{id}/report` (patient summary, print/PDF) |
| Meta | `GET /health`, `GET /model/info` |
| **[Optional]** | `POST /sync/batch` (offline uploads), `GET /audit` (admin) |

Details live in [api.md](api.md).

## 8. Training vs inference separation

- **Training** is offline (Colab, Kaggle or a GPU workstation), config-driven and seeded. Dataset
  manifests are hashed. **Splits are by patient**, never by image. The test set is never used for
  tuning, and an external-source test set is preferred.
- **Artifact contract:** a versioned folder with weights, preprocessing config, label map,
  calibration parameters, thresholds, `model_card.json` and the git commit.
- **Inference:** the API loads one pinned artifact version via configuration and is read-only.
- **Metrics** are reported only once measured: sensitivity and specificity at the chosen
  operating point, quadratic weighted kappa, AUC, confusion matrix, calibration error, ungradable
  rate, and per-camera or per-source breakdown.

## 9. Explainability and uncertainty

**Explainability**

- Default: Grad-CAM/Grad-CAM++ overlay with an opacity toggle in the doctor view.
- Wording: "regions that influenced the model", **not** "detected lesions". Heatmaps show model
  attention, not verified pathology.
- **[Optional]** Sanity check that maps change when model weights are randomized.
- Lesion segmentation is **[Postpone]**.
- Doctor view: image, overlay, grade, probabilities, uncertainty, quality flags, model version.
- Patient view: no raw probabilities and no heatmap detail.

**Uncertainty**

- Calibration: temperature scaling on the validation set, with calibration error reported.
- Signals, cheap to costly: (1) entropy or max probability after calibration; (2) test-time
  augmentation variance; (3) deep ensemble **[Optional]**; (4) IQA/OOD gating for non-fundus or
  poor images.
- Abstention: high uncertainty means "low confidence, clinician review or referral". **The system
  never auto-reassures.** Thresholds for abstention are TBD and set only from validation data.
- Display: Low/Medium/High for everyone, numbers for doctors only.

## 10. Testing strategy

- **ML:** preprocessing determinism; no patient overlap across splits; label-map consistency;
  metric and calibration functions on synthetic data; golden-image regression on the pinned model;
  robustness perturbations (blur, brightness, JPEG, rotation); non-fundus images must be rejected.
- **Backend:** pytest + httpx; RBAC tests; upload abuse tests (oversized, wrong type, corrupt);
  table-driven referral-engine tests covering every state; migration tests run against MySQL;
  OpenAPI contract tests.
- **Frontend:** Vitest + Testing Library; offline-queue behavior; accessibility; low-bandwidth
  behavior.
- **E2E (Compose):** happy path, ungradable path, offline-queue path. Playwright is **[Optional]**.
- **Clinical review:** the team cannot validate clinically. A clinician advisor should review
  referral rules and sample outputs. Until then everything is labeled "not clinically validated".
- **CI:** lint, type-check, tests and image build on every PR.

## 11. Security and privacy

See [threat-model.md](threat-model.md). Summary:

- Data minimization: pseudonymous IDs, minimal demographics, no PII in filenames, EXIF stripped.
- Consent flag recorded before screening; patient-data deletion path.
- Auth: short-lived tokens, strong password hashing, RBAC (health worker, doctor, admin).
- TLS in transit; encrypted disk or volume at rest; secrets only via environment.
- Upload hardening: magic-byte checks, size caps, re-encoding, rate limiting.
- Append-only audit log.
- Demo and training data: license-verified public images and synthetic patients only. No real
  patient data without consent and ethics approval.
- Persistent "screening aid, not a diagnosis" notice; never show a bare "normal".

## 12. Local development and deployment

- **Dev:** `docker compose up` (MySQL, api, web), a Python venv for `ml/`, a Makefile, `.env.example`,
  pre-commit, and a seed script for synthetic patients. Compose and app targets arrive in Phase 2.
- **Models:** never in git. Pinned via `MODEL_VERSION`. Default backend is `stub`.
- **Deployment tiers:** (1) demo server on one VM or a team laptop with Compose and Caddy;
  (2) offline demo on a laptop with tablets on a hotspot; (3) **[Postpone]** managed cloud, GPU
  inference, multi-clinic sync, Kubernetes.
- **CI/CD:** GitHub Actions builds and pushes images; deployment is a manual `compose pull`.
- **Latency:** measure inference on the actual target hardware in Phase 4. Do not assume a number.

## 13. Phased roadmap

Durations are relative. From Phase 1, the ML and app tracks run in parallel, decoupled by the
frozen contract and the STUB.

| Phase | Scope | Exit criteria |
|---|---|---|
| **0. Foundations** | Repo skeleton, docs, CI skeleton, read the SIH problem statement, verify dataset licenses, machine-readable `AnalysisResult` schema, clinician advisor | Contract schema written; dataset license status documented |
| **1. Data + baseline ML** (ML track) | Ingestion, manifests, patient-level splits, preprocessing, baseline DR classifier, heuristic IQA, evaluation harness | Reproducible training run and an eval report with measured numbers |
| **2. App skeleton on STUB** (app track) | Auth, CRUD, upload, STUB inference, doctor view, patient summary, referral engine, i18n, PWA shell | End-to-end flow works on the STUB |
| **3. Real model integration** | Load artifact, calibration, uncertainty, Grad-CAM, IQA gate, replace STUB | End-to-end on the real artifact; golden tests green; model card filled |
| **4. Hardening** | Offline queue and local-node mode, RBAC/audit/upload pass, robustness tests, latency measurement, accessibility | Security checklist done; offline path demonstrated |
| **5. MVP demo** | One-command Compose demo, demo script, model card and limitations, presentation, fallback plan | Rehearsed demo; docs complete |

## 14. Key risks

- Dataset quality, licensing and class imbalance.
- **Domain shift** between public-dataset cameras and rural or handheld fundus capture.
- Training compute limits.
- Clinician advisor availability.
