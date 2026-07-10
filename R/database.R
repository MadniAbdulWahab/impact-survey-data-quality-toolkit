# SQLite output ---------------------------------------------------------------

write_monitoring_database <- function(
  analysis,
  issues,
  region_summary,
  qualitative_comments,
  path = PROJECT_PATHS$database
) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  connection <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(connection), add = TRUE)

  DBI::dbWriteTable(connection, "survey_responses", analysis, overwrite = TRUE)
  DBI::dbWriteTable(connection, "qc_issues", issues, overwrite = TRUE)
  DBI::dbWriteTable(connection, "region_round_summary", region_summary, overwrite = TRUE)
  DBI::dbWriteTable(connection, "qualitative_comments", qualitative_comments, overwrite = TRUE)

  DBI::dbExecute(
    connection,
    "CREATE INDEX IF NOT EXISTS idx_survey_response_id ON survey_responses(response_id)"
  )
  DBI::dbExecute(
    connection,
    "CREATE INDEX IF NOT EXISTS idx_qc_response_id ON qc_issues(response_id)"
  )

  invisible(path)
}

