Sys.setenv(IMPACT_PROJECT_ROOT = normalizePath(getwd(), winslash = "/"))
source(file.path("R", "bootstrap.R"))
bootstrap_project_library()
library(testthat)

test_dir("tests/testthat", reporter = "summary")
