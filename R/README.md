# R pipeline modules

The R code is split by responsibility so each part can be reviewed and
explained without following a large framework.

- `bootstrap.R`: adds the `renv` project library to the R library path
- `config.R`: fixed dates, code lists, validation flags, and paths
- `import.R`: character-first CSV import and explicit type conversion
- `validate.R`: missing, duplicate, code, date, range, consistency, and skip rules
- `clean.R`: documented analysis-copy changes and cleaning audit
- `qualitative.R`: transparent keyword coding for synthetic comments
- `summarise.R`: indicators, cross-tabulations, and four charts
- `database.R`: SQLite tables and indexes

`scripts/run_pipeline.R` is the entry point. Raw data is never overwritten.

