# Excel monitoring workbook

> **Synthetic data only.** Every value here is fictional. Nothing in this folder
> was claimed to be tested before the checkpoint in
> [`../docs/verification/excel_test_log.md`](../docs/verification/excel_test_log.md)
> passed. The tested `.xlsm` and its cached synthetic outputs are now included.

This folder holds the Git-friendly sources for an Excel monitoring layer over the
same synthetic extract the R pipeline uses. Two things live here:

- **A self-contained demo** — `impact_survey_monitoring_template.xlsx`. It opens
  and works with no wiring: the `Entry_Demo` sheet carries a small labelled
  sample plus live formulas that reproduce the seven R validation rules, data
  validation dropdowns, and conditional formatting. Rebuild it any time with
  `python scripts/build_excel_template.py`.
- **A production import path** — `power_query/SurveyRaw.m` loads the full
  420-row raw CSV and `vba/RefreshAndExportQC.bas` refreshes and exports a QC
  report. The verified result is `impact_survey_monitoring.xlsm`; the steps
  below show how it was assembled and how a reviewer can rebuild it.

## Files

| Path | Purpose |
|---|---|
| `impact_survey_monitoring_template.xlsx` | Generated template: Config, Lookups, QC_Rules, Entry_Demo, MonitoringSummary. |
| `impact_survey_monitoring.xlsm` | Sanitized, tested workbook with cached 420-row query data, two pivots, and embedded VBA. |
| `power_query/SurveyRaw.m` | Power Query M: imports the raw CSV, types it, joins code labels. Query name must stay `SurveyRaw`. |
| `vba/RefreshAndExportQC.bas` | VBA module: refresh all queries and pivots, export a timestamped QC CSV. |
| `examples/qc_report_verified.csv` | Curated example from the successful macro run. |
| `exports/` | Where the macro writes `qc_report_*.csv`. Exports are git-ignored. |

The template's code lists are generated from `scripts/project_config.py` and the
raw CSV, so they cannot silently drift from the survey definition or the R rules.

## Workbook sheets

- **Start_Here** — orientation and the step order.
- **Config** — named cells the query and formulas read: `RawDataPath`,
  `ExpectedRowCount` (420), `SurveyStart`/`SurveyEnd`/`ReferenceDate`, and the
  `HouseholdMin/Max`, `ScoreMin/Max`, `CompletionMin/Max` thresholds.
- **Lookups** — valid code lists and the site→region map, each a named range
  (`ValidRegions`, `ValidSites`, `SiteList`/`SiteRegionList`, …).
- **QC_Rules** — the seven rules and the R `qc_*` column each mirrors.
- **Entry_Demo** — the 36-column schema (27 raw + 9 QC). Rows 3–13 are known
  synthetic issues, one or two per category; the rows beneath are blank for you
  to exercise the dropdowns. Conditional formatting shades any flagged record.
- **MonitoringSummary** — region × round counts and mean satisfaction over the
  demo sample (the full dataset is summarised by the pivots you build below).

## Checkpoint — build and verify the full workbook

Perform these in the Excel desktop app, then record the outcome in
[`../docs/verification/excel_test_log.md`](../docs/verification/excel_test_log.md).

1. Open `impact_survey_monitoring_template.xlsx`. Confirm it opens with **no
   repair warning** and that `Entry_Demo` already shows shaded flagged rows.
2. On **Config**, set the `RawDataPath` cell (B3) to the full path of
   `data/raw/survey_responses_synthetic.csv` on your machine.
3. **Data ▸ Get Data ▸ From Other Sources ▸ Blank Query**.
4. **Home ▸ Advanced Editor**, delete the placeholder, and paste all of
   `power_query/SurveyRaw.m`. Click **Done**. Keep the query named `SurveyRaw`.
5. **Close & Load To… ▸ Table**. Confirm the table reports **420 rows**. The
   verified pivots use this worksheet table; no Data Model is claimed.
6. Build the monitoring pivots using the specifications below. Region and Round
   slicers are optional polish and are not present in the verified artifact.
7. **Alt+F11 ▸ File ▸ Import File…**, import `vba/RefreshAndExportQC.bas`.
8. **Save As** `impact_survey_monitoring.xlsm` (macro-enabled).
9. Point `RawDataPath` at a disposable 419-row copy and **Data ▸ Refresh All**.
   Confirm the table and pivot total become 419, then restore the immutable raw
   path and confirm both return to 420.
10. Run the macro (**Alt+F8 ▸ RefreshAndExportQC**). Confirm a
    `qc_report_*.csv` appears in `exports/` and the QC_Export sheet is written.

## Pivot specifications

Build both from the loaded `SurveyTbl` worksheet table.

**Pivot 1 — Participation by region and round**

- Rows: `region_label`
- Columns: `round_label`
- Values: Count of `submission_id`
- Optional slicers: `region_label`, `round_label`
- Reconciliation: the grand total equals `ExpectedRowCount` (420).

**Pivot 2 — Mean satisfaction by region**

- Rows: `region_label`
- Values: Average of `satisfaction_score` (number format 0.0)
- Filter: `participated_training` = `yes`
- Reconciliation: the pattern of regional means matches
  `data/processed/region_round_summary_synthetic.csv` from the R pipeline.

## Reconciliation targets

The Excel outputs should line up with the tested R pipeline:

- Row count after import: **420**.
- Pivot 1 grand total: **420**; consented-only views trace to the R headline
  metrics in `data/processed/headline_metrics_synthetic.csv`.
- The `Entry_Demo` sample intentionally triggers **all seven** QC rules; the
  known issue rows are documented in
  [`../data/raw/injected_issue_truth_synthetic.csv`](../data/raw/injected_issue_truth_synthetic.csv).

## Notes and limitations

- The `Entry_Demo` QC formulas mirror the R rules but operate on the small
  embedded sample; the authoritative, dataset-wide QC output is the R pipeline's
  `data/processed/survey_validated_synthetic.csv`.
- Power Query joins the same labels as `survey/source/choices.csv`; an unmapped
  code surfaces as `UNMAPPED` rather than failing silently.
- The committed `.xlsm` contains cached verified results but a sanitized
  `RawDataPath` placeholder. Set Config!B3 to a local full path before refresh.
- The verified pivots are table-backed, not Data-Model-backed.
- Regenerating the template with the build script overwrites unsaved manual
  edits to `impact_survey_monitoring_template.xlsx`. Do query/pivot/VBA work in
  the saved `.xlsm` copy.
