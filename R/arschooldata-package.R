#' arschooldata: Fetch and Process Arkansas School Data
#'
#' Downloads and processes school data from the Arkansas Department of Education
#' (ADE). Provides functions for fetching enrollment data from Annual Statistical
#' Reports (ASR), which contain Average Daily Attendance (ADA) and fiscal data.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{get_available_years}}}{Check which years have available data}
#' }
#'
#' @section Cache functions:
#' \describe{
#'   \item{\code{\link{cache_status}}}{View cached data files}
#'   \item{\code{\link{clear_cache}}}{Remove cached data files}
#' }
#'
#' @section ID System:
#' Arkansas uses a hierarchical ID system:
#' \itemize{
#'   \item District IDs (LEA): 7 digits (e.g., 0401000 = Bentonville)
#'   \item School IDs: 7 digits (e.g., 0401004)
#' }
#'
#' @section Data Sources:
#' Data is sourced from the Arkansas Department of Education systems:
#' \itemize{
#'   \item Annual Statistical Reports: \url{https://dese.ade.arkansas.gov/offices/data-management/annual-statistical-report}
#'   \item ADE Data Center (demographics, not yet implemented): \url{https://adedata.arkansas.gov/statewide/}
#' }
#'
#' @section Data Availability:
#' \itemize{
#'   \item Year 2006: Available
#'   \item Years 2007-2012: NOT available (missing ASR URLs)
#'   \item Years 2013-2024: Available
#' }
#' Use \code{\link{get_available_years}} to check current availability.
#'
#' @docType package
#' @name arschooldata-package
#' @aliases arschooldata
#' @keywords internal
"_PACKAGE"

