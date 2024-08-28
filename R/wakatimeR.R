last_known_content <- new.env()

#' Start wakatimeR for RStudio
#'
#' Starts WakaTimeR for RStudio by setting up the necessary configurations,
#' checking for the `wakatime-cli` binary, and setting up event polling.
#' It also ensures that the WakaTime API key is properly configured.
#'
#' @param heartbeat_interval Numeric. The interval, in seconds, for sending heartbeats to WakaTime.
#' @param polling_interval Numeric. The interval, in seconds, for checking file changes.
#' @param binary_path Character. `wakatime-cli` binary file path. Default: `NULL` which will look for the binary in the system PATH.
#' @param config_path Character. wakatimeR configuration file path. Default: `"~/.wakatime/wakatimeR.cfg"`.
#' @param log_path Character. Log file path. Default: `"~/.wakatime/wakatimeR.log"`.
#' @param log_level Logger level. The logging level to use. Default is `logger::INFO`.
#'
#' @export
start_wakatime <- function(
    heartbeat_interval = 120,
    polling_interval = 120,
    binary_path = NULL,
    config_path = "~/.wakatime/wakatimeR.cfg",
    log_path = "~/.wakatime/wakatimeR.log",
    log_level = logger::INFO) {
  # get absolute path
  if (!is.null(log_path)) {
    log_path <- normalizePath(log_path, mustWork = FALSE)
  }
  if (!is.null(config_path)) {
    config_path <- normalizePath(config_path, mustWork = FALSE)
  }
  # ensure wakatimeR and loggers are set up
  init_wakatime(
    log_path = log_path,
    config_path = config_path
  )
  # browser()
  init_logger(
    level = log_level,
    log_path = log_path
  )

  # initalize
  logger::log_debug("Initializing wakatimeR")
  binary_path <<- binary_path_check(binary_path = binary_path)
  heartbeat_interval <<- heartbeat_interval
  polling_interval <<- polling_interval
  last_heartbeat <<- list(file = NULL, time = Sys.time() - heartbeat_interval)

  api_key <<- get_wakatime_api_key(config_path = config_path)
  if (is.null(api_key)) {
    logger::log_warn("WakaTime API key not found in {config_path}")
    api_key <<- readline(prompt = "Enter your WakaTime API Key: ")
    set_wakatime_api_key(api_key = api_key, config_path = config_path)
    logger::log_info("WakaTime API key has been set.")
  } else {
    logger::log_info("WakaTime API key found in {config_path}.")
  }

  # start polling
  set_event_polling()
  logger::log_info("WakaTime initialized for RStudio.")
}

#' Get WakaTime API Key
#'
#' Retrieves the WakaTime API key from the configuration file.
#'
#' @param config_path Character. wakatimeR configuration file path.
#'
#' @return The WakaTime API key as a string, or NULL if not found.
#' @export
get_wakatime_api_key <- function(config_path) {
  config_lines <- suppressWarnings(readLines(config_path))
  api_key_line <- grep("api_key", config_lines, value = TRUE)
  if (length(api_key_line) > 0) {
    api_key <- sub(".*api_key\\s*=\\s*", "", api_key_line)
  }
  if (api_key == "") {
    return(NULL)
  }
  return(api_key)
}

#' Set WakaTime API Key
#'
#' Set the WakaTime API key to the wakatimeR configuration file
#'
#' @param api_key Character. WakaTime API key.
#' @param config_path Character. wakatimeR configuration file path.
#'
#' @export
set_wakatime_api_key <- function(api_key, config_path) {
  init_wakatime(config_path = config_path)

  if (!file.exists(config_path)) {
    # create file if dont exist
    writeLines(paste0("[settings]\napi_key = ", api_key), config_path)
  } else {
    config_lines <- readLines(config_path)
    if (any(grepl("api_key", config_lines))) {
      # replace key if it exists
      config_lines <- sub("api_key\\s*=\\s*.*", paste0("api_key = ", api_key), config_lines)
    } else {
      # add key if it dont exist
      config_lines <- c(config_lines, paste0("api_key = ", api_key))
    }
    writeLines(config_lines, config_path)
  }
}
