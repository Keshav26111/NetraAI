# Model Card

**Status: TBD. No real model exists yet.** Every field marked **TBD** must be filled from measured,
reproducible results. Do not fill any field with an estimate, a number from a paper, or a number
from another project.

## Current inference backend

`stub`: a deterministic placeholder that implements the inference contract
(see [architecture.md](architecture.md), section 5). Its output has **no clinical meaning** and must
be labeled as STUB wherever it is displayed.

## 1. Model details

| Field | Value |
|---|---|
| Model name | TBD |
| Version | TBD |
| Release / artifact hash | TBD |
| Architecture / backbone | TBD |
| Training framework | TBD |
| Training code commit | TBD |
| Preprocessing version | TBD |
| Tasks covered | image quality assessment (TBD), DR severity grading (TBD) |

## 2. Intended use

- **Intended:** screening support that helps trained staff prioritize and route cases, with
  mandatory clinician review.
- **Users:** health workers and clinicians. Patients see only a clinician-approved summary.
- **Out of scope:** autonomous diagnosis, treatment decisions, use without clinician review,
  assessment of diabetic macular edema, glaucoma, AMD or other conditions, and use on image types
  outside the training distribution.

## 3. Inputs and outputs

Defined by the inference contract (`quality`, `grade`, `uncertainty`, `explanation`, `model`).
Input image requirements (format, resolution, field of view): TBD.

## 4. Training data

Source, license, label scheme, split: **TBD**. See [data-card.md](data-card.md).

## 5. Evaluation data

| Field | Value |
|---|---|
| Internal held-out set | TBD |
| External-source test set | TBD |
| Split policy | by patient (design rule); manifests TBD |

## 6. Metrics (measured only)

| Metric | Value | Dataset | Notes |
|---|---|---|---|
| Sensitivity at operating point | TBD | TBD | TBD |
| Specificity at operating point | TBD | TBD | TBD |
| Quadratic weighted kappa | TBD | TBD | TBD |
| AUC | TBD | TBD | TBD |
| Ungradable rate | TBD | TBD | TBD |
| Per-camera / per-source breakdown | TBD | TBD | TBD |

## 7. Calibration

| Field | Value |
|---|---|
| Method | TBD |
| Calibration data | TBD |
| Calibration error | TBD |

## 8. Uncertainty and abstention

| Field | Value |
|---|---|
| Uncertainty method(s) | TBD |
| Abstention rule and thresholds | TBD (set only from validation data) |

## 9. Explainability

| Field | Value |
|---|---|
| Method | TBD (Grad-CAM planned, not implemented) |
| Sanity checks performed | TBD |
| Interpretation note | Overlays show regions that influenced the model. They are not verified lesion detections. |

## 10. Clinical validation

**Not clinically validated.**

| Field | Value |
|---|---|
| Clinician advisor | TBD |
| Referral rule review | TBD |
| Prospective / clinical study | TBD |
| Regulatory status | TBD |

## 11. Known limitations

Fill from evaluation results. Design-level limitations known in advance:

- Does not assess macular edema or non-DR eye disease.
- Performance on cameras or capture conditions not represented in training data is unknown.
- Overlays are not lesion detections.

Additional limitations: TBD.

## 12. Ethical and privacy considerations

TBD. See [threat-model.md](threat-model.md).

## 13. Version history

| Version | Date | Change |
|---|---|---|
| stub-0 | TBD | Deterministic placeholder, no clinical meaning |
