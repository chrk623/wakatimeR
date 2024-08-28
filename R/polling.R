set_event_polling <- function() {
  poll_fn <- function() {
    current_file <- tryCatch(
      {
        rstudioapi::getSourceEditorContext()$path
      },
      error = function(e) {
        NULL
      }
    )

    if (!is.null(current_file) && nzchar(current_file)) {
      logger::log_debug("Current filepath: {current_file}")
      if (file_modified(current_file)) {
        logger::log_debug("{current_file} modified")
        send_heartbeat(current_file, is_write = FALSE)
      }
      if (file_saved(current_file)) {
        logger::log_debug("{current_file} saved")
        send_heartbeat(current_file, is_write = TRUE)
      }
    } else {
      logger::log_warn("No active file path detected in RStudio editor.")
    }

    # re-schedule the function to run again after the interval
    later::later(func = poll_fn, delay = wakatimer_env$polling_interval)
  }

  # start polling loop
  poll_fn()
  logger::log_info("Polling for editor events started.")
}


file_modified <- function(current_file) {
  # check if the file is being tracked
  if (exists(current_file, envir = last_known_content)) {
    # get file content
    current_content <- tryCatch(
      {
        rstudioapi::getSourceEditorContext()$contents
      },
      error = function(e) {
        logger::log_error("Error getting contents from RStudio editor: {e$message}")
        return(NULL)
      }
    )

    if (is.null(current_content)) {
      logger::log_warn("Failed to retrieve content for {current_file}. Considering it not modified.")
      return(FALSE)
    }

    # compare current content with the last known content
    if (!identical(last_known_content[[current_file]], current_content)) {
      # if not identical then the file has been modified
      # update last known content
      assign(current_file, current_content, envir = last_known_content)
      logger::log_debug("Content modified for {current_file}.")
      return(TRUE)
    } else {
      # if identical then the file has not been modified
      logger::log_debug("No modification detected for {current_file}.")
      return(FALSE)
    }
  } else {
    # if the file is not being tracked, initialize its content
    current_content <- tryCatch(
      {
        rstudioapi::getSourceEditorContext()$contents
      },
      error = function(e) {
        logger::log_error("Error getting contents from RStudio editor: {e$message}")
        return(NULL)
      }
    )

    # if its possible to retrieve the current content
    if (!is.null(current_content)) {
      # update the file content as last known content and start tracking
      assign(current_file, current_content, envir = last_known_content)
      logger::log_debug("Tracking new file: {current_file}")
    } else {
      logger::log_warn("Could not retrieve content for new file: {current_file}")
    }
    return(FALSE)
  }
}

file_saved <- function(current_file) {
  # check if file was saved since last heartbeat by last modify time
  file_info <- file.info(current_file)
  last_modify_time <- file_info$mtime
  last_heartbeat_time <- last_heartbeat$time
  logger::log_debug("Last hearbeat time {last_heartbeat_time}")
  logger::log_debug("{current_file} last modify time {last_modify_time}")
  if (last_modify_time > last_heartbeat_time) {
    logger::log_debug("{current_file} saved")
    return(TRUE)
  }
  return(FALSE)
}
