# Monitoring summaries and charts -------------------------------------------

safe_mean <- function(x) {
  if (all(is.na(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
}

safe_rate <- function(condition, eligible = rep(TRUE, length(condition))) {
  denominator <- sum(eligible & !is.na(condition))
  if (denominator == 0) return(NA_real_)
  sum(eligible & condition, na.rm = TRUE) / denominator
}

build_summaries <- function(validated, analysis, issues, qualitative_summary) {
  consented <- validated$consent == "yes"
  participated <- analysis$participated_training == "yes"

  headline <- dplyr::tibble(
    metric = c(
      "Raw submissions",
      "Consented submissions",
      "Unique consented responses used for analysis",
      "Responses with one or more QC flags",
      "Total record-level QC flags",
      "Training participation rate",
      "Mean satisfaction among valid training responses",
      "Skill-use rate among training participants",
      "Synthetic comments coded"
    ),
    value = c(
      nrow(validated),
      sum(consented, na.rm = TRUE),
      nrow(analysis),
      sum(validated$qc_any_issue),
      nrow(issues),
      safe_rate(analysis$participated_training == "yes"),
      safe_mean(analysis$satisfaction_score[participated]),
      safe_rate(analysis$used_skill == "yes", participated),
      sum(qualitative_summary$comment_count)
    ),
    display_type = c(
      "count", "count", "count", "count", "count",
      "proportion", "mean", "proportion", "count"
    )
  )

  region_round <- analysis |>
    dplyr::filter(!is.na(region_code), !is.na(survey_round)) |>
    dplyr::group_by(region_code, survey_round) |>
    dplyr::summarise(
      responses = dplyr::n(),
      training_participants = sum(participated_training == "yes", na.rm = TRUE),
      participation_rate = mean(participated_training == "yes", na.rm = TRUE),
      mean_satisfaction = safe_mean(satisfaction_score[participated_training == "yes"]),
      mean_service_access = safe_mean(service_access),
      follow_up_requests = sum(follow_up_requested == "yes", na.rm = TRUE),
      .groups = "drop"
    )

  gender_participation <- analysis |>
    dplyr::filter(!is.na(gender)) |>
    dplyr::count(gender, participated_training, name = "responses") |>
    dplyr::group_by(gender) |>
    dplyr::mutate(percent_within_gender = round(100 * responses / sum(responses), 1)) |>
    dplyr::ungroup()

  issue_summary <- issues |>
    dplyr::count(issue_type, issue_label, name = "flag_count", sort = TRUE) |>
    dplyr::mutate(
      affected_response_ids = vapply(
        issue_type,
        function(type) dplyr::n_distinct(issues$response_id[issues$issue_type == type]),
        integer(1)
      )
    )

  list(
    headline = headline,
    region_round = region_round,
    gender_participation = gender_participation,
    issue_summary = issue_summary
  )
}

save_charts <- function(analysis, issue_summary, qualitative_summary) {
  dir.create(PROJECT_PATHS$figure_dir, recursive = TRUE, showWarnings = FALSE)
  theme_portfolio <- ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.title.position = "plot",
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom"
    )

  qc_plot <- ggplot2::ggplot(
    issue_summary,
    ggplot2::aes(x = stats::reorder(issue_label, flag_count), y = flag_count)
  ) +
    ggplot2::geom_col(fill = "#B85450", width = 0.72) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Automated quality-control flags",
      x = NULL,
      y = "Record-level flags",
      caption = "Synthetic data; one response can trigger multiple rules."
    ) +
    theme_portfolio

  satisfaction_plot <- analysis |>
    dplyr::filter(
      participated_training == "yes",
      !is.na(region_code),
      !is.na(satisfaction_score)
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(x = region_code, y = satisfaction_score, fill = region_code)
    ) +
    ggplot2::geom_boxplot(width = 0.62, outlier.alpha = 0.45) +
    ggplot2::scale_y_continuous(breaks = 1:5, limits = c(1, 5)) +
    ggplot2::guides(fill = "none") +
    ggplot2::labs(
      title = "Satisfaction among training participants",
      x = "Fictional region",
      y = "Satisfaction score (1–5)",
      caption = "Out-of-range values are excluded from the analysis copy."
    ) +
    theme_portfolio

  participation_plot <- analysis |>
    dplyr::filter(!is.na(survey_round)) |>
    dplyr::count(survey_round, participated_training) |>
    dplyr::group_by(survey_round) |>
    dplyr::mutate(rate = n / sum(n)) |>
    dplyr::ungroup() |>
    ggplot2::ggplot(
      ggplot2::aes(x = survey_round, y = rate, fill = participated_training)
    ) +
    ggplot2::geom_col(position = "fill", width = 0.62) +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    ggplot2::scale_fill_manual(values = c(no = "#A7B6C2", yes = "#2F6B4F")) +
    ggplot2::labs(
      title = "Training participation by survey round",
      x = NULL,
      y = "Share of responses",
      fill = "Participated",
      caption = "Synthetic monitoring responses."
    ) +
    theme_portfolio

  qualitative_plot <- ggplot2::ggplot(
    qualitative_summary,
    ggplot2::aes(x = stats::reorder(theme, comment_count), y = comment_count)
  ) +
    ggplot2::geom_col(fill = "#356A8A", width = 0.72) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Themes in synthetic comments",
      x = NULL,
      y = "Comments",
      caption = "Transparent keyword coding of a small synthetic phrase library."
    ) +
    theme_portfolio

  ggplot2::ggsave(
    file.path(PROJECT_PATHS$figure_dir, "qc_issue_counts.png"),
    qc_plot,
    width = 8,
    height = 4.8,
    dpi = 160
  )
  ggplot2::ggsave(
    file.path(PROJECT_PATHS$figure_dir, "satisfaction_by_region.png"),
    satisfaction_plot,
    width = 8,
    height = 4.8,
    dpi = 160
  )
  ggplot2::ggsave(
    file.path(PROJECT_PATHS$figure_dir, "participation_by_round.png"),
    participation_plot,
    width = 7,
    height = 4.6,
    dpi = 160
  )
  ggplot2::ggsave(
    file.path(PROJECT_PATHS$figure_dir, "qualitative_themes.png"),
    qualitative_plot,
    width = 8,
    height = 4.8,
    dpi = 160
  )
}

