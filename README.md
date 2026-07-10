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
| Synthetic-data generator and survey build | **Tested:** 420 rows; 9 Python tests passed |
| XLSForm local structural validation | **Passed:** pyxform 4.5.0 |
| KoboToolbox preview and logic test | Not yet tested |
| R pipeline and automated tests | **Passed:** R 4.6.1; 8 test blocks / 22 expectations |
| SQLite database and saved queries | **Tested:** four tables and common query patterns |
| Quarto HTML report | **Rendered:** Quarto 1.9.38; four embedded charts |
| Excel Power Query, pivots, and VBA | Not yet manually tested |

See [`docs/verification/automated_test_log.md`](docs/verification/automated_test_log.md)
and [`docs/verification/r_test_log.md`](docs/verification/r_test_log.md) for
commands and observed results. Passing local structural validation does not
prove that Kobo preview logic has been tested.

## Architecture

The generator writes immutable synthetic raw data and an injection-truth file.
The R pipeline parses and validates every raw record, writes a long issue log
and a deduplicated analysis copy, populates SQLite, creates four charts, and
feeds the Quarto report. Excel will independently import the raw extract through
Power Query and expose operational QC and monitoring views. See
[`docs/data_flow.md`](docs/data_flow.md).

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

## Run the R pipeline and report

Install R 4.6.1 and Quarto, then run from the repository root:

```powershell
Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', repos = 'https://cloud.r-project.org')"
Rscript -e "renv::restore(prompt = FALSE)"
Rscript scripts/run_pipeline.R
Rscript tests/testthat.R
Rscript scripts/check_database.R
quarto render reports/impact_survey_report.qmd
```

The exact R dependency versions are recorded in `renv.lock`. The final report
is [`reports/impact_survey_report.html`](reports/impact_survey_report.html).

## Synthetic findings

These figures demonstrate reporting logic; they do not describe a real
population or programme.

- 420 raw submissions and 413 consented submissions were generated.
- 403 unique consented response IDs remain after duplicate handling.
- 58 submissions have at least one QC flag, producing 60 record-level flags.
- Duplicate detection produces 20 flags across ten repeated response IDs.
- Synthetic training participation is 75.7%; mean valid satisfaction is 3.85
  out of 5; reported skill use among participants is 64.3%.
- All 72 non-empty synthetic comments were assigned to one of four transparent
  themes; positive-learning comments are the largest group at 43.1%.

The issue counts overlap by design: for example, an invalid region or site can
also trigger a region/site consistency rule.

## Current data-quality scenarios

The raw extract intentionally includes missing required values, duplicate
response identifiers, invalid codes, inconsistent dates, out-of-range values,
region/site inconsistencies, and skip-logic violations. These are test inputs,
not mistakes that should be silently repaired in the raw layer.

## Repository map

- `data/raw/`: immutable synthetic generator outputs and manifest
- `data/interim/`: disposable pipeline working files
- `data/processed/`: tested analysis, QC, summary, and SQLite outputs
- `R/`: small modules for import, validation, cleaning, summaries, and database output
- `reports/`: Quarto source, rendered HTML, and generated charts
- `sql/`: tested common monitoring queries
- `survey/source/`: diffable survey, choice, and settings sheets
- `survey/impact_survey_xlsform.xlsx`: generated Kobo-ready workbook
- `scripts/`: generators, builders, and validators
- `tests/`: Python and R automated tests
- `docs/`: procedures, design decisions, diagrams, and verification evidence

## Data-management documentation

- [Data-flow diagram](docs/data_flow.md)
- [Data-quality procedure](docs/data_quality_procedure.md)
- [Dataset update and versioning procedure](docs/update_and_versioning.md)
- [Common query guide](docs/query_guide.md)
- [Synthetic-data design](docs/synthetic_data_design.md)
- [Generated QC issue log](data/processed/qc_issues_synthetic.csv)

## Limitations and incomplete work

- KoboToolbox compatibility and user experience remain unverified until the
  workbook is uploaded, previewed, and exercised in a real Kobo session.
- Excel is installed but could not be opened through this automation session;
  Power Query, pivot, and VBA claims require interactive desktop testing.
- The qualitative comments come from a small synthetic phrase library. The
  keyword themes demonstrate a transparent workflow, not generalisable
  qualitative research.
- Duplicate handling retains the first submission ID in lexical order. A real
  project would require a documented confirmation from the data owner.
- Authentic screenshots will be added only after the corresponding manual test.
