# Manual SQLite verification -------------------------------------------------
# Run from the repository root:
#   Rscript scripts/check_database.R

source(file.path("R", "bootstrap.R"))
bootstrap_project_library()

database_path <- file.path(
  "data", "processed", "impact_survey_synthetic.sqlite"
)
if (!file.exists(database_path)) {
  stop(
    "Database not found. Run Rscript scripts/run_pipeline.R first.",
    call. = FALSE
  )
}

connection <- DBI::dbConnect(RSQLite::SQLite(), database_path)
on.exit(DBI::dbDisconnect(connection), add = TRUE)

expected_tables <- c(
  "qc_issues",
  "qualitative_comments",
  "region_round_summary",
  "survey_responses"
)
tables <- sort(DBI::dbListTables(connection))

region_results <- DBI::dbGetQuery(
  connection,
  paste(
    "SELECT region_code, COUNT(*) AS responses",
    "FROM survey_responses",
    "WHERE region_code IS NOT NULL",
    "GROUP BY region_code",
    "ORDER BY region_code"
  )
)

qc_results <- DBI::dbGetQuery(
  connection,
  paste(
    "SELECT issue_label, COUNT(*) AS flags",
    "FROM qc_issues",
    "GROUP BY issue_label",
    "ORDER BY flags DESC, issue_label"
  )
)

theme_results <- DBI::dbGetQuery(
  connection,
  paste(
    "SELECT theme, COUNT(*) AS comments",
    "FROM qualitative_comments",
    "GROUP BY theme",
    "ORDER BY comments DESC, theme"
  )
)

analysis_rows <- DBI::dbGetQuery(
  connection,
  "SELECT COUNT(*) AS rows FROM survey_responses"
)$rows[[1]]

stopifnot(
  identical(tables, expected_tables),
  analysis_rows == 403,
  nrow(region_results) == 4,
  sum(region_results$responses) == 400,
  nrow(qc_results) == 7,
  sum(qc_results$flags) == 60,
  nrow(theme_results) == 4,
  sum(theme_results$comments) == 72
)

cat("SQLite tables:\n")
print(tables)
cat("\nAnalysis rows:", analysis_rows, "\n")
cat("\nResponses by fictional region (three invalid region values are missing):\n")
print(region_results, row.names = FALSE)
cat("\nQC flags:\n")
print(qc_results, row.names = FALSE)
cat("\nSynthetic qualitative themes:\n")
print(theme_results, row.names = FALSE)
cat("\nDatabase checks passed.\n")

