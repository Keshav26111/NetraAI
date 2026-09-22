# models

Model artifacts live here locally and are **never committed** (see `.gitignore`; only this README is
tracked).

Each artifact is a versioned folder containing:

- weights
- preprocessing config and version
- label map
- calibration parameters
- thresholds (TBD, from validation data only)
- `model_card.json`
- training code git commit

No real model exists yet. The default inference backend is the deterministic `stub`.
