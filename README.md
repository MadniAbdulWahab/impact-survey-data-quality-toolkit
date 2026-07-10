# Impact Survey Data Quality and Reporting Toolkit

> **Portfolio project using synthetic data only.** No record represents a real
> person, programme, organisation, or field operation.

This repository is under active construction. It demonstrates a reproducible
monitoring-data workflow spanning XLSForm survey design, deliberate data-quality
problems, R validation and reporting, SQLite queries, and an Excel monitoring
workbook. The fictional case is a community-services and training follow-up
survey; it is not connected to a real organisation.

## Current verified status

The status table is updated only after evidence-producing checks are run.

| Component | Status |
|---|---|
| Synthetic-data generator | **Tested:** 420 rows; 8 Python tests passed |
| XLSForm local structural validation | **Passed:** pyxform 4.5.0 |
| KoboToolbox preview and logic test | Not yet tested |
| R pipeline and automated tests | Not yet tested; R unavailable during initial inspection |
| Quarto HTML report | Not yet rendered |
| Excel Power Query, pivots, and VBA | Not yet manually tested |

See [`docs/verification/automated_test_log.md`](docs/verification/automated_test_log.md)
for commands and observed results. Passing local structural validation does not
prove that Kobo preview logic has been tested.

## Architecture

The generator writes immutable synthetic raw data and an injection-truth file.
The planned R pipeline will parse and validate raw records, write record-level
QC flags and processed data, populate SQLite, and render the Quarto report.
Excel will independently import the raw extract through Power Query and expose
operational QC and monitoring views. See [`docs/data_flow.md`](docs/data_flow.md).

## Reproduce the completed Day 1 components

From PowerShell in the repository root:

```powershell
python -m venv --system-site-packages .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe scripts\generate_synthetic_data.py
.\.venv\Scripts\python.exe scripts\build_xlsform.py
.\.venv\Scripts\python.exe -m pytest
.\.venv\Scripts\python.exe scripts\validate_xlsform.py
```

The generated manifest records fixed seed `20260710`, the expected row count,
issue counts, and the raw CSV SHA-256 hash.

## Current data-quality scenarios

The raw extract intentionally includes missing required values, duplicate
response identifiers, invalid codes, inconsistent dates, out-of-range values,
region/site inconsistencies, and skip-logic violations. These are test inputs,
not mistakes that should be silently repaired in the raw layer.

## Repository map

- `data/raw/`: immutable synthetic generator outputs and manifest
- `data/interim/`: disposable pipeline working files
- `data/processed/`: analysis-ready and QC outputs, to be produced by R
- `survey/source/`: diffable survey, choice, and settings sheets
- `survey/impact_survey_xlsform.xlsx`: generated Kobo-ready workbook
- `scripts/`: generators, builders, and validators
- `tests/`: automated validation tests
- `docs/`: procedures, design decisions, diagrams, and verification evidence

## Limitations and incomplete work

- KoboToolbox compatibility and user experience remain unverified until the
  workbook is uploaded, previewed, and exercised in a real Kobo session.
- R and Quarto were not installed during initial inspection, so no R analysis,
  test, chart, database, or rendered report is yet claimed.
- Excel is installed but could not be opened through this automation session;
  Power Query, pivot, and VBA claims require interactive desktop testing.
- The qualitative comments come from a small synthetic phrase library. Later
  theme analysis will demonstrate a transparent workflow, not generalisable
  qualitative research.
- Authentic screenshots will be added only after the corresponding manual test.
