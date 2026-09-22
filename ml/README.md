# ml

Training, evaluation and inference package `netra_ml`. **Not yet implemented.**

- `src/netra_ml/`: `data`, `preprocess`, `iqa`, `models`, `train`, `eval`, `calibrate`,
  `uncertainty`, `explain`, `inference`, `export`
- `configs/`: YAML per experiment
- `scripts/`, `notebooks/`, `tests/`

`netra_ml.inference` is the only surface the API may import. A deterministic STUB implementation of
the inference contract comes first; the real model replaces it without contract changes.

Rules: preprocessing is shared between training and inference; splits are by patient; no metric is
reported until measured; datasets and run outputs stay out of git.
