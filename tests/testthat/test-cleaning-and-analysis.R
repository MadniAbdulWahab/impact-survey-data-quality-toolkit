test_that("analysis data has one consented row per response identifier", {
  validated <- validate_survey(read_survey_raw())$validated
  analysis <- clean_for_analysis(validated)

  expect_true(all(analysis$consent == "yes"))
  expect_equal(anyDuplicated(analysis$response_id), 0)
})

test_that("invalid analysis values are converted to missing", {
  validated <- validate_survey(read_survey_raw())$validated
  analysis <- clean_for_analysis(validated)

  expect_true(all(is.na(analysis$region_code) | analysis$region_code %in% VALID_VALUES$region_code))
  expect_true(all(is.na(analysis$household_size) | dplyr::between(analysis$household_size, 1, 20)))
  expect_true(all(is.na(analysis$satisfaction_score) | dplyr::between(analysis$satisfaction_score, 1, 5)))
  expect_true(all(is.na(analysis$completion_minutes) | dplyr::between(analysis$completion_minutes, 3, 60)))
})

test_that("all non-empty synthetic comments receive a theme", {
  validated <- validate_survey(read_survey_raw())$validated
  analysis <- clean_for_analysis(validated)
  comments <- code_qualitative_comments(analysis)

  expect_gt(nrow(comments), 0)
  expect_false(any(is.na(comments$theme)))
  expect_false(any(comments$theme == "Other"))
})

