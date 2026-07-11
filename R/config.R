# Fixed project configuration -------------------------------------------------
#
# Dates and code lists are deliberately fixed so validation results remain
# reproducible across environments.

SURVEY_START <- as.Date("2025-04-01")
SURVEY_END <- as.Date("2025-09-30")
REFERENCE_DATE <- as.Date("2025-10-01")

PROJECT_ROOT <- normalizePath(
  Sys.getenv("IMPACT_PROJECT_ROOT", unset = getwd()),
  winslash = "/",
  mustWork = TRUE
)

project_path <- function(...) file.path(PROJECT_ROOT, ...)

REGION_SITES <- list(
  NORTH = c("N01", "N02", "N03"),
  SOUTH = c("S01", "S02", "S03"),
  EAST = c("E01", "E02", "E03"),
  WEST = c("W01", "W02", "W03")
)

VALID_VALUES <- list(
  synthetic_data = "yes",
  survey_round = c("ROUND_1", "ROUND_2"),
  region_code = names(REGION_SITES),
  site_code = unname(unlist(REGION_SITES)),
  enumerator_code = sprintf("ENUM_%02d", 1:8),
  consent = c("yes", "no"),
  age_group = c("18_24", "25_34", "35_44", "45_54", "55_plus"),
  gender = c("woman", "man", "non_binary", "prefer_not"),
  yes_no = c("yes", "no"),
  training_topic = c(
    "planning", "financial_skills", "digital_skills", "leadership"
  ),
  preferred_channel = c("community_meeting", "printed_material", "radio")
)

PROJECT_PATHS <- list(
  raw_data = project_path("data", "raw", "survey_responses_synthetic.csv"),
  truth = project_path("data", "raw", "injected_issue_truth_synthetic.csv"),
  processed_dir = project_path("data", "processed"),
  report_dir = project_path("reports"),
  figure_dir = project_path("reports", "figures"),
  database = project_path(
    "data", "processed", "impact_survey_synthetic.sqlite"
  )
)

FLAG_COLUMNS <- c(
  "qc_missing_required",
  "qc_duplicate_response_id",
  "qc_invalid_code",
  "qc_date_consistency",
  "qc_out_of_range",
  "qc_region_site_consistency",
  "qc_skip_logic"
)

ISSUE_LABELS <- c(
  missing_required = "Missing required value",
  duplicate_response_id = "Duplicate response identifier",
  invalid_code = "Invalid code",
  date_consistency = "Date inconsistency",
  out_of_range = "Value outside allowed range",
  region_site_consistency = "Region/site inconsistency",
  skip_logic = "Skip-logic violation"
)
