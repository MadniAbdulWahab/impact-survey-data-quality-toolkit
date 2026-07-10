test_that("all deliberately injected issues are detected", {
  raw <- read_survey_raw()
  detected <- validate_survey(raw)$issues
  truth <- readr::read_csv(PROJECT_PATHS$truth, show_col_types = FALSE) |>
    dplyr::mutate(
      issue_type = dplyr::recode(
        issue_type,
        inconsistent_date = "date_consistency",
        consistency_violation = "region_site_consistency",
        skip_logic_violation = "skip_logic"
      )
    ) |>
    dplyr::select(submission_id, issue_type)

  missing_detections <- dplyr::anti_join(
    truth,
    detected |>
      dplyr::select(submission_id, issue_type),
    by = c("submission_id", "issue_type")
  )
  expect_equal(nrow(missing_detections), 0)
})

test_that("duplicate rule flags both copies of each response identifier", {
  validated <- validate_survey(read_survey_raw())$validated
  duplicate_rows <- validated |>
    dplyr::filter(qc_duplicate_response_id)

  expect_equal(nrow(duplicate_rows), 20)
  expect_equal(dplyr::n_distinct(duplicate_rows$response_id), 10)
})

test_that("flag fields are logical and issue counts reconcile", {
  result <- validate_survey(read_survey_raw())
  expect_true(all(vapply(result$validated[FLAG_COLUMNS], is.logical, logical(1))))
  expect_equal(sum(result$validated$qc_issue_count), nrow(result$issues))
  expect_equal(
    sum(result$validated$qc_any_issue),
    dplyr::n_distinct(result$issues$submission_id)
  )
})

