# Analysis copy and cleaning audit -------------------------------------------

clean_for_analysis <- function(validated) {
  validated |>
    dplyr::filter(consent == "yes") |>
    dplyr::arrange(response_id, submission_id) |>
    dplyr::distinct(response_id, .keep_all = TRUE) |>
    dplyr::mutate(
      region_code = dplyr::if_else(
        region_code %in% VALID_VALUES$region_code, region_code, NA_character_
      ),
      site_code = dplyr::if_else(
        site_code %in% VALID_VALUES$site_code, site_code, NA_character_
      ),
      age_group = dplyr::if_else(
        age_group %in% VALID_VALUES$age_group, age_group, NA_character_
      ),
      gender = dplyr::if_else(
        gender %in% VALID_VALUES$gender, gender, NA_character_
      ),
      training_topic = dplyr::if_else(
        is.na(training_topic) | training_topic %in% VALID_VALUES$training_topic,
        training_topic,
        NA_character_
      ),
      household_size = dplyr::if_else(
        dplyr::between(household_size, 1, 20), household_size, NA_real_
      ),
      satisfaction_score = dplyr::if_else(
        dplyr::between(satisfaction_score, 1, 5),
        satisfaction_score,
        NA_real_
      ),
      knowledge_before = dplyr::if_else(
        dplyr::between(knowledge_before, 1, 5), knowledge_before, NA_real_
      ),
      knowledge_after = dplyr::if_else(
        dplyr::between(knowledge_after, 1, 5), knowledge_after, NA_real_
      ),
      service_access = dplyr::if_else(
        dplyr::between(service_access, 1, 5), service_access, NA_real_
      ),
      completion_minutes = dplyr::if_else(
        dplyr::between(completion_minutes, 3, 60),
        completion_minutes,
        NA_real_
      )
    )
}

build_cleaning_audit <- function(issues) {
  action_lookup <- c(
    missing_required = "Retain flag; exclude missing value from its denominator",
    duplicate_response_id = "Keep the first submission by identifier; exclude later copy from analysis",
    invalid_code = "Set invalid coded value to missing in the analysis copy",
    date_consistency = "Retain flag; exclude inconsistent date from date-specific interpretation",
    out_of_range = "Set out-of-range numeric value to missing in the analysis copy",
    region_site_consistency = "Retain both raw codes and flag for source review",
    skip_logic = "Retain raw values and exclude inapplicable answer from interpretation"
  )

  issues |>
    dplyr::mutate(action = unname(action_lookup[issue_type])) |>
    dplyr::select(submission_id, response_id, issue_type, issue_label, action)
}

