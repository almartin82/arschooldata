#' arschooldata: Fetch and Process Arkansas School Data
#'
#' Downloads and processes school data from the Arkansas Department of Education
#' (ADE). Provides functions for fetching enrollment data from the ADE Data Center
#' and Annual Statistical Reports (ASR), then transforming it into tidy format
#' for analysis.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{tidy_enr}}}{Transform wide data to tidy (long) format}
#'   \item{\code{\link{id_enr_aggs}}}{Add aggregation level flags}
#'   \item{\code{\link{enr_grade_aggs}}}{Create grade-level aggregations}
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
#'   \item ADE Data Center: \url{https://adedata.arkansas.gov/statewide/}
#'   \item Annual Statistical Reports: \url{https://dese.ade.arkansas.gov/Offices/fiscal-and-administrative-services/publication-and-reports/annual-statistical-reports}
#' }
#'
#' @section Data Availability:
#' \itemize{
#'   \item Enrollment by Grade/Race: 2005-2025 via ADE Data Center
#'   \item Annual Statistical Reports (detailed demographics): 2006-2024
#'   \item Pre-2005 data may have different formats
#' }
#'
#' @docType package
#' @name arschooldata-package
#' @aliases arschooldata
#' @keywords internal
"_PACKAGE"

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
