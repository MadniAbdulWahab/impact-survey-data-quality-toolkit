# Data-quality procedure

## Purpose

This procedure covers receipt, validation, review, correction, and publication
of a survey extract. The dataset is synthetic; the controls are structured so
they can be adapted to other small data workflows.

## Principles

1. Preserve the received raw file and its checksum.
2. Make corrections only in a reproducible analysis layer or in the source
   system after review; never type over raw values.
3. Keep automated detection separate from human resolution.
4. Record the rule, affected record, decision, and action.
5. Reconcile row counts and key indicators after every update.
6. Treat free text as potentially sensitive in a live project. This dataset
   contains synthetic phrases only.

## Workflow

### 1. Receive and register

- Save the export under `data/raw/` using an agreed naming convention.
- Confirm that expected columns exist.
- Record the source, survey version, extraction date, row count, and SHA-256.
- Mark the raw file read-only in an operational environment.

### 2. Run automated checks

Run:

```powershell
Rscript scripts/run_pipeline.R
Rscript tests/testthat.R
```

The validation module checks:

| Rule | Toolkit implementation | Typical response |
|---|---|---|
| Missing required | Core fields plus conditional training/follow-up fields | Request source confirmation or exclude from the relevant denominator |
| Duplicate identifier | Flags every copy of a repeated response ID | Compare submissions and retain only after documented review |
| Invalid code | Compares categorical values with controlled lists | Correct in source if confirmed; otherwise set missing in analysis copy |
| Date consistency | Survey-period and start/training/interview ordering | Verify against source documentation |
| Range | Household, duration, and 1–5 score limits | Confirm or set missing in analysis copy |
| Region/site consistency | Site must belong to its region | Confirm the intended site or region |
| Skip logic | Detects answers in inapplicable training/follow-up fields | Retain raw values, flag, and exclude from interpretation |

### 3. Triage the issue log

Use `data/processed/qc_issues_synthetic.csv` as the working issue list. In a
live workflow, assign an owner, priority, due date, and resolution note. Here,
`status` remains `Open` because the synthetic issues have no source owner who
can confirm a correction.

Suggested priorities:

- High: duplicate IDs, impossible dates, or problems affecting primary metrics
- Medium: missing or invalid values affecting secondary indicators
- Low: optional-field or presentation issues without analytical impact

### 4. Apply approved actions

- Update the source system when feasible and obtain a fresh export.
- Otherwise, encode the approved transformation in R and add a regression test.
- Do not replace a questionable value with an assumed value.
- Keep a cleaning audit showing what the analysis copy does with each issue.

### 5. Re-run and reconcile

Confirm:

- raw and validated row counts reconcile;
- analysis exclusions are explained by consent or duplicate handling;
- flag totals reconcile between wide flags and the long issue log;
- database table counts match the processed CSV files;
- report indicators come from the latest pipeline outputs.

### 6. Release

Only publish a processed dataset or report after automated tests pass and the
manual Excel/Kobo checks relevant to the release are recorded. Tag the Git
commit or record its hash in the release note.
