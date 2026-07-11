test_that("pipeline writes the required processed outputs", {
  expected <- c(
    "survey_validated_synthetic.csv",
    "survey_analysis_synthetic.csv",
    "qc_issues_synthetic.csv",
    "cleaning_audit_synthetic.csv",
    "headline_metrics_synthetic.csv",
    "region_round_summary_synthetic.csv",
    "gender_participation_synthetic.csv",
    "qc_issue_summary_synthetic.csv",
    "qualitative_comments_coded_synthetic.csv",
    "qualitative_theme_summary_synthetic.csv",
    "pipeline_manifest.json"
  )
  expect_true(all(file.exists(file.path(PROJECT_PATHS$processed_dir, expected))))
})

test_that("SQLite output contains the expected queryable tables", {
  expect_true(file.exists(PROJECT_PATHS$database))
  connection <- DBI::dbConnect(RSQLite::SQLite(), PROJECT_PATHS$database)
  on.exit(DBI::dbDisconnect(connection), add = TRUE)

  tables <- DBI::dbListTables(connection)
  expect_true(all(c(
    "survey_responses",
    "qc_issues",
    "region_round_summary",
    "qualitative_comments"
  ) %in% tables))
  expect_gt(DBI::dbGetQuery(connection, "SELECT COUNT(*) AS n FROM survey_responses")$n, 0)

  region_query <- DBI::dbGetQuery(
    connection,
    paste(
      "SELECT region_code, survey_round, COUNT(*) AS responses",
      "FROM survey_responses",
      "WHERE region_code IS NOT NULL",
      "GROUP BY region_code, survey_round"
    )
  )
  issue_query <- DBI::dbGetQuery(
    connection,
    paste(
      "SELECT issue_label, COUNT(*) AS flags",
      "FROM qc_issues WHERE status = 'Open' GROUP BY issue_label"
    )
  )
  theme_query <- DBI::dbGetQuery(
    connection,
    "SELECT theme, COUNT(*) AS comments FROM qualitative_comments GROUP BY theme"
  )
  expect_equal(nrow(region_query), 8)
  expect_equal(nrow(issue_query), 7)
  expect_equal(nrow(theme_query), 4)
})
