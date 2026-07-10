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
