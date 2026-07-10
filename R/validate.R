# Record-level validation -----------------------------------------------------

is_blank <- function(x) {
  is.na(x) | (is.character(x) & trimws(x) == "")
}

outside <- function(x, lower, upper) {
  !is.na(x) & (x < lower | x > upper)
}

site_matches_region <- function(region, site) {
  mapply(
    function(one_region, one_site) {
      if (is.na(one_region) || is.na(one_site)) return(FALSE)
      allowed <- REGION_SITES[[one_region]]
      !is.null(allowed) && one_site %in% allowed
    },
    region,
    site,
    USE.NAMES = FALSE
  )
}

validate_survey <- function(data) {
  required_columns <- c(
    "submission_id", "response_id", "synthetic_data", "survey_round",
    "interview_date", "program_start_date", "region_code", "site_code",
    "enumerator_code", "consent", "age_group", "gender",
    "household_size", "disability_access", "participated_training",
    "training_date", "training_topic", "satisfaction_score",
    "knowledge_before", "knowledge_after", "used_skill", "service_access",
    "follow_up_requested", "preferred_channel", "completion_minutes"
  )
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    stop(
      "Required columns are missing: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  training_populated <- !is.na(data$training_date) |
    !is_blank(data$training_topic) |
    !is.na(data$satisfaction_score) |
    !is.na(data$knowledge_before) |
    !is.na(data$knowledge_after) |
    !is_blank(data$used_skill)

  core_missing <- is_blank(data$survey_round) |
    is.na(data$interview_date) |
    is.na(data$program_start_date) |
    is_blank(data$region_code) |
    is_blank(data$site_code) |
    is_blank(data$enumerator_code) |
    is_blank(data$age_group) |
    is_blank(data$gender) |
    is.na(data$household_size) |
    is_blank(data$disability_access) |
    is_blank(data$participated_training) |
    is.na(data$service_access) |
    is_blank(data$follow_up_requested) |
    is.na(data$completion_minutes)

  training_missing <- data$participated_training == "yes" & (
    is.na(data$training_date) |
      is_blank(data$training_topic) |
      is.na(data$satisfaction_score) |
      is.na(data$knowledge_before) |
      is.na(data$knowledge_after) |
      is_blank(data$used_skill)
  )

  follow_up_missing <- data$follow_up_requested == "yes" &
    is_blank(data$preferred_channel)

  duplicated_id <- duplicated(data$response_id) |
    duplicated(data$response_id, fromLast = TRUE)

  invalid_code <- !(data$synthetic_data %in% VALID_VALUES$synthetic_data) |
    (!is_blank(data$survey_round) & !(data$survey_round %in% VALID_VALUES$survey_round)) |
    (!is_blank(data$region_code) & !(data$region_code %in% VALID_VALUES$region_code)) |
    (!is_blank(data$site_code) & !(data$site_code %in% VALID_VALUES$site_code)) |
    (!is_blank(data$enumerator_code) & !(data$enumerator_code %in% VALID_VALUES$enumerator_code)) |
    (!is_blank(data$consent) & !(data$consent %in% VALID_VALUES$consent)) |
    (!is_blank(data$age_group) & !(data$age_group %in% VALID_VALUES$age_group)) |
    (!is_blank(data$gender) & !(data$gender %in% VALID_VALUES$gender)) |
    (!is_blank(data$disability_access) & !(data$disability_access %in% VALID_VALUES$yes_no)) |
    (!is_blank(data$participated_training) & !(data$participated_training %in% VALID_VALUES$yes_no)) |
    (!is_blank(data$training_topic) & !(data$training_topic %in% VALID_VALUES$training_topic)) |
    (!is_blank(data$used_skill) & !(data$used_skill %in% VALID_VALUES$yes_no)) |
    (!is_blank(data$follow_up_requested) & !(data$follow_up_requested %in% VALID_VALUES$yes_no)) |
    (!is_blank(data$preferred_channel) & !(data$preferred_channel %in% VALID_VALUES$preferred_channel))

  date_consistency <- outside(data$interview_date, SURVEY_START, SURVEY_END) |
    (!is.na(data$program_start_date) & !is.na(data$interview_date) &
      data$program_start_date > data$interview_date) |
    (data$participated_training == "yes" & !is.na(data$training_date) &
      !is.na(data$program_start_date) &
      data$training_date < data$program_start_date) |
    (data$participated_training == "yes" & !is.na(data$training_date) &
      !is.na(data$interview_date) & data$training_date > data$interview_date)

  out_of_range <- outside(data$household_size, 1, 20) |
    outside(data$satisfaction_score, 1, 5) |
    outside(data$knowledge_before, 1, 5) |
    outside(data$knowledge_after, 1, 5) |
    outside(data$service_access, 1, 5) |
    outside(data$completion_minutes, 3, 60)

  region_site_consistency <- !is_blank(data$region_code) &
    !is_blank(data$site_code) &
    !site_matches_region(data$region_code, data$site_code)

  skip_logic <- (data$participated_training == "no" & training_populated) |
    (data$follow_up_requested == "no" & !is_blank(data$preferred_channel))

  validated <- data |>
    dplyr::mutate(
      qc_missing_required = consent == "yes" &
        (core_missing | training_missing | follow_up_missing),
      qc_duplicate_response_id = duplicated_id,
      qc_invalid_code = invalid_code,
      qc_date_consistency = consent == "yes" & date_consistency,
      qc_out_of_range = consent == "yes" & out_of_range,
      qc_region_site_consistency = consent == "yes" & region_site_consistency,
      qc_skip_logic = consent == "yes" & skip_logic
    ) |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(FLAG_COLUMNS), ~ dplyr::coalesce(.x, FALSE)),
      qc_issue_count = rowSums(dplyr::across(dplyr::all_of(FLAG_COLUMNS))),
      qc_any_issue = qc_issue_count > 0
    )

  issues <- validated |>
    dplyr::select(
      submission_id,
      response_id,
      region_code,
      survey_round,
      dplyr::all_of(FLAG_COLUMNS)
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(FLAG_COLUMNS),
      names_to = "issue_type",
      values_to = "flagged"
    ) |>
    dplyr::filter(flagged) |>
    dplyr::mutate(
      issue_type = sub("^qc_", "", issue_type),
      issue_label = unname(ISSUE_LABELS[issue_type]),
      status = "Open",
      review_note = "Synthetic issue detected by an automated rule"
    ) |>
    dplyr::select(-flagged)

  list(validated = validated, issues = issues)
}

