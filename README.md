# wakatimeR

`wakatimeR` is an R package built for [RStudio](https://posit.co/products/open-source/rstudio/) that automatically tracks your programming activity, providing time tracking, metrics, and insights to help you understand your coding habits.

**NOTE:** Only tested on Linux, should work on Mac, unsure about Windows.

## Setup
1. Head over to [WakaTime](https://wakatime.com/dashboard) and create an account.
2. Obtain your API key [here](https://wakatime.com/settings/account).
3. Download the `wakatime-cli` from [WakaTime's Github](https://github.com/wakatime/wakatime-cli/releases/). 
    - Optional: Add the binary to your system's PATH. You can verify this by running `wakatime-cli --version` in the terminal.
4. Install `wakatimeR`.
```R
remotes::install_github("chrk623/wakatimeR")
```
5. Run the following in your RStudio console. Since its your first time using the package, you can set `log_path` as `NULL` here to view the logs directly in the RStudio console.
```R
wakatimeR::start_wakatime(
  # seconds
  heartbeat_interval = 120,
  # seconds
  polling_interval = 120,
  # where you installed it, or you can use NULL if the cli is in PATH
  binary_path = "~/.wakatime/wakatime-cli",
  # where your api key will be stored
  config_path = "~/.wakatime/wakatimeR.cfg", 
  log_path = NULL,
  # or logger::INFO
  log_level = logger::DEBUG
)
```
I suggest you let it run for a few minutes and check your [WakaTime Dashboard](https://wakatime.com/dashboard) to see if the metrics are logged correctly. If you are unsure what the options mean, you can always check the documentation `?wakatimeR::start_wakatime`.

6. Now that you have everything working, put the following in `~/.Rprofile` or your project's local `.Rprofile`. **Remember to set `log_path` so the logs are written to the log file.**
```R
if (interactive()) {
  if (requireNamespace("wakatimeR", quietly = TRUE)) {
    tryCatch(
      {
        wakatimeR::start_wakatime(
          heartbeat_interval = 120,
          polling_interval = 120,
          binary_path = "~/.wakatime/wakatime-cli",
          config_path = "~/.wakatime/wakatimeR.cfg",
          log_path = "~/.wakatime/wakatimeR.log",
          log_level = logger::DEBUG
        )
      },
      error = function(e) {
        message("Failed to start wakatimeR: ", e$message)
      }
    )
  } else {
    message("You are trying to initalize wakatimeR but its not installed.")
  }
}
```

7. Now `wakatimeR` should start automatically when RStudio starts. You can check this by viewing the logs, i.e.,
```bash
tail ~/.wakatime/wakatimeR.log
```
