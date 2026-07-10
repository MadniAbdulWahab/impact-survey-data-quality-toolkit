# Import and type parsing -----------------------------------------------------

read_survey_raw <- function(path = PROJECT_PATHS$raw_data) {
  if (!file.exists(path)) {
    stop("Raw survey file not found: ", path, call. = FALSE)
  }

  raw <- readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    na = c("", "NA"),
    trim_ws = TRUE,
    show_col_types = FALSE
  )

  raw |>
    dplyr::mutate(
      dplyr::across(where(is.character), ~ stringr::str_squish(.x)),
      dplyr::across(
        c(interview_date, program_start_date, training_date),
        ~ suppressWarnings(as.Date(.x))
      ),
      dplyr::across(
        c(
          household_size,
          satisfaction_score,
          knowledge_before,
          knowledge_after,
          service_access,
          completion_minutes
        ),
        ~ suppressWarnings(as.numeric(.x))
      )
    )
}

