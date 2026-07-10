# Run from the repository root:
#   Rscript scripts/run_pipeline.R

options(stringsAsFactors = FALSE)
Sys.setenv(IMPACT_PROJECT_ROOT = normalizePath(getwd(), winslash = "/"))

source(file.path("R", "bootstrap.R"))
bootstrap_project_library()
source(file.path("R", "config.R"))
source(file.path("R", "import.R"))
source(file.path("R", "validate.R"))
source(file.path("R", "clean.R"))
source(file.path("R", "qualitative.R"))
source(file.path("R", "summarise.R"))
source(file.path("R", "database.R"))

dir.create(PROJECT_PATHS$processed_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(PROJECT_PATHS$figure_dir, recursive = TRUE, showWarnings = FALSE)

raw <- read_survey_raw()
validation <- validate_survey(raw)
validated <- validation$validated
issues <- validation$issues
analysis <- clean_for_analysis(validated)
cleaning_audit <- build_cleaning_audit(issues)

qualitative_comments <- code_qualitative_comments(analysis)
qualitative_summary <- summarise_qualitative_themes(qualitative_comments)
summaries <- build_summaries(
  validated,
  analysis,
  issues,
  qualitative_summary
)

readr::write_csv(
  validated,
  file.path(PROJECT_PATHS$processed_dir, "survey_validated_synthetic.csv"),
  na = ""
)
readr::write_csv(
  analysis,
  file.path(PROJECT_PATHS$processed_dir, "survey_analysis_synthetic.csv"),
  na = ""
)
readr::write_csv(
  issues,
  file.path(PROJECT_PATHS$processed_dir, "qc_issues_synthetic.csv"),
  na = ""
)
readr::write_csv(
  cleaning_audit,
  file.path(PROJECT_PATHS$processed_dir, "cleaning_audit_synthetic.csv"),
  na = ""
)
readr::write_csv(
  summaries$headline,
  file.path(PROJECT_PATHS$processed_dir, "headline_metrics_synthetic.csv"),
  na = ""
)
readr::write_csv(
  summaries$region_round,
  file.path(PROJECT_PATHS$processed_dir, "region_round_summary_synthetic.csv"),
  na = ""
)
readr::write_csv(
  summaries$gender_participation,
  file.path(PROJECT_PATHS$processed_dir, "gender_participation_synthetic.csv"),
  na = ""
)
readr::write_csv(
  summaries$issue_summary,
  file.path(PROJECT_PATHS$processed_dir, "qc_issue_summary_synthetic.csv"),
  na = ""
)
readr::write_csv(
  qualitative_comments,
  file.path(PROJECT_PATHS$processed_dir, "qualitative_comments_coded_synthetic.csv"),
  na = ""
)
readr::write_csv(
  qualitative_summary,
  file.path(PROJECT_PATHS$processed_dir, "qualitative_theme_summary_synthetic.csv"),
  na = ""
)

save_charts(analysis, summaries$issue_summary, qualitative_summary)
write_monitoring_database(
  analysis,
  issues,
  summaries$region_round,
  qualitative_comments
)

pipeline_manifest <- list(
  synthetic_data_notice = "SYNTHETIC DATA - NOT REAL PEOPLE OR PROGRAMME OPERATIONS",
  fixed_reference_date = as.character(REFERENCE_DATE),
  raw_rows = nrow(raw),
  validated_rows = nrow(validated),
  analysis_rows = nrow(analysis),
  responses_with_qc_flags = sum(validated$qc_any_issue),
  record_level_qc_flags = nrow(issues),
  coded_comments = nrow(qualitative_comments),
  output_database = file.path(
    "data", "processed", "impact_survey_synthetic.sqlite"
  )
)
jsonlite::write_json(
  pipeline_manifest,
  file.path(PROJECT_PATHS$processed_dir, "pipeline_manifest.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

message("R pipeline completed with synthetic data only.")
message("Raw rows: ", nrow(raw))
message("Analysis rows: ", nrow(analysis))
message("Record-level QC flags: ", nrow(issues))
message("Coded comments: ", nrow(qualitative_comments))
