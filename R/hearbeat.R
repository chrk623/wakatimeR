send_heartbeat <- function(file_path, is_write = FALSE) {
  # check if heartbeat should be sent
  if (!should_send_heartbeat(file_path, is_write)) {
    logger::log_info("Heartbeat not needed for {file_path}. Skipping...")
    return()
  }

  # get current project info
  project_name <- rstudioapi::getActiveProject()
  project_name_arg <- ifelse(is.null(project_name), "", paste("--project", shQuote(basename(project_name)), collapse = ""))

  # user agent headers for RSTUDIO
  ua1 <- paste0("Rstudio/", as.character(RStudio.Version()$version))
  ua2 <- paste0("rstudio-wakatimeR/", packageVersion("wakatimeR"))
  ua <- paste(ua1, ua2, collapse = "")

  # construct command to send to wakatime
  command <- sprintf(
    "%s --guess-language --entity %s %s --key %s --plugin %s %s",
    wakatimer_env$binary_path,
    shQuote(tools::file_path_as_absolute(file_path)),
    ifelse(is_write, "--write", ""),
    shQuote(wakatimer_env$api_key),
    shQuote(ua),
    project_name_arg
  )

  logger::log_info("Sending heartbeat with command: {command}")
  # execute command
  system(command, wait = FALSE)

  # update last heartbeat info
  last_heartbeat$file <- file_path
  last_heartbeat$time <- Sys.time()
  logger::log_info("Sent heartbeat for {file_path} (write: {is_write}).")
}


should_send_heartbeat <- function(file_path, is_write) {
  if (!is_write && !is.null(wakatimer_env$file) &&
    last_heartbeat$file == file_path &&
    (Sys.time() - last_heartbeat$time) < wanatimer_env$heartbeat_interval) {
    logger::log_debug("Skipping heartbeat for {file_path}, last heartbeat was within {heartbeat_interval} secs.")
    return(FALSE)
  }
  return(TRUE)
}
