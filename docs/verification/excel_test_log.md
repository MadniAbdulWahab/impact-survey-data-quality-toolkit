# Excel verification log

Status: **PASSED** on 10 July 2026 and publication-audited on 11 July 2026. The workbook was assembled and exercised in
real Excel through COM automation on this Windows session. Values below are
observed, not planned. Authentic evidence images captured from the saved
workbook are under `docs/screenshots/`.

## Environment

- Test date: 10 July 2026
- Excel version: 16.0, build 20131 (desktop, COM automation)
- Windows: 11 Pro, 10.0.26200
- Data classification: synthetic only
- Template built by `scripts/build_excel_template.py`
- Method: driven via Excel COM (open, Power Query load, pivots, VBA import,
  macro run). `AccessVBOM` and `VBAWarnings` were temporarily enabled for the
  automated VBA import/run and then restored to their original (unset) state.

## Automated build checks

```powershell
.\.venv\Scripts\python.exe scripts\build_excel_template.py
.\.venv\Scripts\python.exe -m pytest
```

- Build exit code: 0; template written to
  `excel/impact_survey_monitoring_template.xlsx`.
- Python suite: 18 passed (includes byte-identical template rebuild, final
  `.xlsm` feature checks, and local-metadata scanning).

## Manual checkpoint results

| # | Step | Result |
|---|---|---|
| 1 | Template opens, no repair warning; Entry_Demo QC formulas recalculate | **Pass** — flags match the known-issue rows (see below) |
| 2 | `RawDataPath` set on Config | **Pass** |
| 3 | Blank Query created | **Pass** |
| 4 | `SurveyRaw.m` loaded; query named `SurveyRaw` | **Pass** — 31 output columns (27 raw + 4 labels) |
| 5 | Close & Load to worksheet table; row count 420 | **Pass** — 420 rows; no Data Model is claimed |
| 6 | Pivots built | **Pass** — Region×Round and Satisfaction pivots created; slicers are not included |
| 7 | VBA module imported via Alt+F11 | **Pass** — module `modQCExport`, `Sub RefreshAndExportQC` |
| 8 | Saved as `impact_survey_monitoring.xlsm` | **Pass** — sanitized verified artifact committed with cached outputs |
| 9 | Controlled source-copy change + Refresh All | **Pass** on 11 July — disposable copy changed query and pivot totals to 419; restoring the immutable source returned both to 420 |
| 10 | Macro runs; `exports/qc_report_*.csv` written; QC_Export sheet present | **Pass** — `qc_report_20260710_200503.csv` written |

## Reconciliation

- Imported row count vs `ExpectedRowCount`: **420 = 420**.
- Pivot 1 grand total (count of `submission_id`): **420**.
- Pivot 2 mean satisfaction by region (participants only, raw extract):
  NORTH 3.81, SOUTH 3.92, EAST 3.99, WEST 3.74. Same EAST-high / WEST-low
  pattern as `data/processed/region_round_summary_synthetic.csv`; the small gap
  is expected because the raw pivot still contains the duplicate rows and the
  injected out-of-range satisfaction value that the R analysis copy removes.
- Entry_Demo flags cover all seven QC rules.

## Entry_Demo flag verification (recalculated in Excel)

| Row | Submission | Flag raised |
|---|---|---|
| 3–5 | SUB-0064 / SUB-0002 / SUB-0003 | none (clean) |
| 6, 7 | SUB-0239 / SUB-DUP-001 | qc_duplicate_response_id |
| 8 | SUB-0116 | qc_missing_required |
| 9 | SUB-0192 | qc_invalid_code **and** qc_region_site_consistency |
| 10 | SUB-0009 | qc_date_consistency |
| 11 | SUB-0001 | qc_out_of_range |
| 12 | SUB-0197 | qc_region_site_consistency |
| 13 | SUB-0033 | qc_skip_logic |

Row 9 tripping two rules reproduces the R pipeline's documented overlap: an
invalid region cannot own its site, so the consistency rule also fires.

## Macro export contents

The successful export is retained as
`excel/examples/qc_report_verified.csv`:

```
qc_rule,flagged_rows
qc_missing_required,1
qc_duplicate_response_id,2
qc_invalid_code,1
qc_date_consistency,1
qc_out_of_range,1
qc_region_site_consistency,2
qc_skip_logic,1
records_with_any_flag,8
```

## Data-validation and formatting

- Dropdown, whole-number, decimal, and date validations are present on the
  `Entry_Demo` input columns (built by the template script).
- Conditional formatting is keyed on `qc_any_issue`; because the flag values
  recalculated correctly, the shading renders on the eight flagged sample rows.
- Formula results, validation definitions, and conditional-formatting rules
  were independently inspected from the saved workbook package.

## Publication audit

- `xl/vbaProject.bin` contains `modQCExport.RefreshAndExportQC`.
- The saved package contains the `SurveyRaw` Power Query connection, one loaded
  query table with 420 rows, and two pivot caches with 420 records each.
- Cached formula results reproduce the documented clean and flagged demo rows.
- Temporary Excel VBA trust registry values are absent after testing.
- The public workbook contains no local `C:\Users` path or personal author
  metadata. Config!B3 is a setup placeholder that reviewers replace locally.
- Authentic workbook and report screenshots are documented in
  `docs/screenshots/README.md`.
- Slicers and an Excel Data Model are intentionally not claimed.

## Sign-off

- Result: **Pass** — Excel workbook functional and reconciled to the pipeline.
- Evidence: scripted COM run on 10 July, controlled refresh and package audit on
  11 July 2026; curated export committed under `excel/examples/`.
