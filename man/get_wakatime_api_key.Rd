% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wakatimeR.R
\name{get_wakatime_api_key}
\alias{get_wakatime_api_key}
\title{Get WakaTime API Key}
\usage{
get_wakatime_api_key(config_path)
}
\arguments{
\item{config_path}{Character. wakatimeR configuration file path.}
}
\value{
The WakaTime API key as a string, or NULL if not found.
}
\description{
Retrieves the WakaTime API key from the configuration file.
}
