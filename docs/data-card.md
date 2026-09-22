# Data Card

**Status: TBD. No dataset has been selected, downloaded or verified.** Fill each section from
verified information only. Raw data is never committed to this repository (see `.gitignore`).

## 1. Dataset source

No dataset selected. Candidates named during design, **none evaluated or verified**:

| Candidate | Evaluated | License / terms | Access | Decision |
|---|---|---|---|---|
| APTOS | No | TBD | TBD | TBD |
| EyePACS | No | TBD | TBD | TBD |
| Messidor-2 | No | TBD | TBD | TBD |
| IDRiD | No | TBD | TBD | TBD |
| DDR | No | TBD | TBD | TBD |
| FGADR | No | TBD | TBD | TBD |

Per selected dataset, record: name, version, URL, access date, citation, maintainer. **TBD.**

## 2. License and terms of use

For each selected dataset: license text, permitted uses (research, demo, redistribution),
attribution requirements, restrictions on derived models. **TBD.**

## 3. Provenance and consent

Collection site and population, de-identification status, consent and ethics basis. **TBD.**

## 4. Image characteristics

Camera models, resolution range, field of view, file formats, laterality labeling, quality
distribution. **TBD.**

## 5. Label scheme

Grading scale used, definition of each grade, definition of "referable", annotator count and
qualifications, adjudication process, quality labels, lesion annotations (not used in the MVP).
Mapping between datasets if more than one is used. **TBD.**

## 6. Patient-level split

- **Design rule:** splits are made by patient, never by image, so images from the same patient
  never appear in more than one of train, validation and test.
- Availability of patient identifiers per dataset: TBD.
- Split manifest location and hash: TBD.
- Class distribution per split: TBD.
- External-source test set: TBD.

## 7. Preprocessing

Border cropping, resizing, normalization, versioning. **TBD.** Must be identical in training and
inference.

## 8. Known limitations

To be filled from inspection. Risks to check for, not findings:

- Label noise and inter-grader disagreement.
- Label-scheme mismatch between datasets.
- Class imbalance.
- Camera and site differences (domain shift), including versus rural or handheld capture.
- Images that are ungradable but labeled.
- Missing patient identifiers, which prevents patient-level splitting.

Findings: **TBD.**

## 9. Handling rules

- Datasets and patient data are never committed. Local paths are git-ignored.
- Demos use license-verified public images or synthetic data only.
- No real patient data without consent and ethics approval.
