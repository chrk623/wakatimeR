init_wakatime <- function(config_path = NULL, log_path = NULL) {
  if (!is.null(log_path)) {
    log_path <- normalizePath(log_path, mustWork = FALSE)
    log_dir <- dirname(log_path)
    dir.create(log_dir, showWarnings = FALSE)
    if (!file.exists(log_path)) {
      file.create(log_path, showWarnings = FALSE)
    }
  }

  if (!is.null(config_path)) {
    config_path <- normalizePath(config_path, mustWork = FALSE)
    config_dir <- dirname(config_path)
    dir.create(config_dir, showWarnings = FALSE)
    if (!file.exists(config_path)) {
      file.create(config_path, showWarnings = FALSE)
    }
  }
}

init_logger <- function(level, log_path = NULL) {
  logger::log_threshold(level = level, namespace = "wakatimeR")
  # write logs to file
  if (!is.null(log_path)) {
    logger::log_appender(logger::appender_file(file = log_path, append = TRUE),
      namespace = "wakatimeR"
    )
  }
}

binary_path_check <- function(binary_path = NULL) {
  if (!is.null(binary_path)) {
    binary_path <- Sys.which("wakatime-cli")
    if (nzchar(binary_path) <= 0) {
      stop("walatime-cli binary path not provided and is not in PATH.")
    }
    return(binary_path)
  }

  return(normalizePath("/usr/local/bin/wakatime-cli", mustWork = TRUE))
}
