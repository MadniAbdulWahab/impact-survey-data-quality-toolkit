# Dataset update and versioning procedure

## Version boundaries

- Survey instrument: semantic version such as `1.0.0`
- Raw extract: immutable file plus SHA-256 in its manifest
- Code and documentation: Git commit hash
- Processed outputs: regenerated from a named raw extract and code commit
- Published report: retained with the same release tag as its processed data

## Routine update

1. Create a short-lived branch such as `data-update-2025-10`.
2. Place the new export in `data/raw/`; do not overwrite the previous approved
   extract in an operational project.
3. Record filename, checksum, row count, survey version, extraction date, and
   source-system query or export settings.
4. Compare columns with `data/data_dictionary.csv`.
5. Run the generator only for this portfolio; a real update would use the new
   field export.
6. Run the R pipeline, R tests, and Quarto render.
7. Compare current and previous counts: submissions, consented records,
   duplicates, QC flags, and headline indicators.
8. Refresh Excel and verify pivot totals against the processed summary.
9. Review the issue log and document unresolved high-priority items.
10. Commit source and curated outputs with a message describing the actual
    update, then merge after review.

## Change log entry

Record:

- update date and responsible person;
- raw filename and checksum;
- survey and code versions;
- rows added, changed, or removed;
- new or resolved QC issues;
- material indicator changes;
- reviewer and approval decision.

## Excel workbook versioning

- `excel/impact_survey_monitoring_template.xlsx` is **generated**; treat it like
  code and rebuild it with `python scripts/build_excel_template.py` rather than
  editing it by hand. It is committed so reviewers can open it directly.
- Do all query, pivot, and macro work in the saved `excel/impact_survey_monitoring.xlsm`
  copy. The sanitized `.xlsm` is versioned only after the checkpoint in
  `docs/verification/excel_test_log.md` passes; never replace it with an
  unverified working copy.
- On a data update, set `RawDataPath`, **Data ▸ Refresh All**, confirm the row
  count still equals `ExpectedRowCount`, and reconcile the pivot totals against
  `data/processed/region_round_summary_synthetic.csv` before recording the run.
- Macro exports under `excel/exports/` are disposable working files. Promote
  only a reviewed example to `excel/examples/` as versioned evidence.

## Rollback

Because raw files are immutable and transformations are in Git, restore the
previous release by checking out its tag or commit and rerunning the pipeline.
Do not use a rollback to conceal a failed quality check; retain the failed run's
issue note in project history.
