# Transparent qualitative theme coding ---------------------------------------
#
# The comments come from a small synthetic phrase library. A simple keyword
# method is intentionally used because it is inspectable and proportionate.

code_qualitative_comments <- function(data) {
  data |>
    dplyr::filter(!is.na(open_comment), trimws(open_comment) != "") |>
    dplyr::mutate(
      comment_lower = stringr::str_to_lower(open_comment),
      theme = dplyr::case_when(
        stringr::str_detect(
          comment_lower,
          "timing|shorter sessions|start earlier"
        ) ~ "Timing and scheduling",
        stringr::str_detect(
          comment_lower,
          "travel|closer to the community|printed materials"
        ) ~ "Access and materials",
        stringr::str_detect(
          comment_lower,
          "more examples|follow-up session|more time for questions"
        ) ~ "Request for more content",
        stringr::str_detect(
          comment_lower,
          "practical examples|explained.*clearly|already used|group activities"
        ) ~ "Positive learning experience",
        TRUE ~ "Other"
      )
    ) |>
    dplyr::select(-comment_lower)
}

summarise_qualitative_themes <- function(coded_comments) {
  coded_comments |>
    dplyr::count(theme, name = "comment_count", sort = TRUE) |>
    dplyr::mutate(
      percent_of_comments = round(100 * comment_count / sum(comment_count), 1)
    )
}

