# Lightweight project-library activation -------------------------------------
#
# renv's full automatic loader was slow in the mixed Python/R workspace during
# development. We still use renv.lock and renv::restore(), but only add the
# existing project library to .libPaths() at startup. This keeps entry points
# fast and makes the workaround visible rather than hiding it in shell setup.

bootstrap_project_library <- function(project = getwd()) {
  if (!requireNamespace("renv", quietly = TRUE)) {
    message(
      "renv is not installed. Run install.packages('renv') before restore."
    )
    return(invisible(NULL))
  }

  library_path <- renv::paths$library(project = project)
  if (dir.exists(library_path)) {
    .libPaths(unique(c(library_path, .libPaths())))
  }
  invisible(library_path)
}

