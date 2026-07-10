# R and Quarto verification log

## Environment

- Test date: 10 July 2026
- R: 4.6.1
- Quarto: 1.9.38
- Pandoc: 3.8.3 bundled with Quarto
- Dependency lock: `renv.lock`
- Data classification: synthetic only

## Final successful checks

Pipeline command:

```powershell
Rscript scripts/run_pipeline.R
```

Observed result:

- exit code 0;
- 420 raw and validated rows;
- 403 unique consented analysis rows;
- 58 submissions with at least one QC flag;
- 60 record-level QC flags;
- 72 coded synthetic comments;
- processed CSV, SQLite, JSON, and four PNG outputs created.

Test command:

```powershell
Rscript tests/testthat.R
```

Observed result: exit code 0. Eight test blocks completed with 22 passing
expectations across validation, duplicate handling, cleaning, qualitative
coding, output existence, and SQLite queries.

Database check command:

```powershell
Rscript scripts/check_database.R
```

Observed result: exit code 0; four expected tables, 403 analysis rows, four
non-missing region groups totalling 400 rows, 60 QC flags, and 72 coded comments
all reconciled. Two clean pipeline rebuilds produced the same SQLite SHA-256:
`42e3af6be438adaca9b2951d19a6eff7360fa073064a3b13e5dcd3fe0b88d7f1`.

Render command:

```powershell
quarto render reports/impact_survey_report.qmd
```

Observed result: exit code 0 and
`reports/impact_survey_report.html` created. The final HTML is self-contained,
approximately 2 MB, and contains four embedded PNG images.

## Problems found during verification

Verification found and corrected three implementation issues before the final
pass:

1. Full `renv` automatic activation was slow in the mixed Python/R workspace;
   a small documented bootstrap now activates the locked project library.
2. `testthat` changes the helper working directory; paths now use an explicit
   project root.
3. Initial report figure paths were relative to the wrong directory; the final
   render completed without missing-resource warnings.

These earlier failures are not counted as successful tests. The results above
refer to the corrected final runs.

## User-run acceptance check

On 10 July 2026, the repository owner reported manually running the supplied
Day 1 and Day 2 commands successfully. This included the synthetic-data and
XLSForm checks, R pipeline, R tests, SQLite database checker, Quarto render, and
visual inspection of the HTML report. The owner reported that the outputs and
four charts appeared as expected.

This entry records the user's report; no screenshot or browser evidence was
provided, so none is claimed.
