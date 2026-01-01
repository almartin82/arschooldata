# ==============================================================================
# Utility Functions
# ==============================================================================

#' @importFrom rlang .data
NULL


#' Get available years for Arkansas enrollment data
#'
#' Returns the range of school years for which enrollment data is available
#' from the Arkansas Department of Education.
#'
#' @return A list with three elements:
#'   \item{min_year}{The earliest available school year end (e.g., 2006 for 2005-06)}
#'   \item{max_year}{The latest available school year end (e.g., 2025 for 2024-25)}
#'   \item{description}{Human-readable description of data availability}
#' @export
#' @examples
#' get_available_years()
#' # Returns list with min_year, max_year, and description
get_available_years <- function() {
  list(
    min_year = 2006,
    max_year = 2025,
    description = "Arkansas enrollment data is available from 2005-06 (end_year 2006) through 2024-25 (end_year 2025). Data comes from the Annual Statistical Reports published by the Arkansas Division of Elementary and Secondary Education."
  )
}


#' Convert to numeric, handling suppression markers
#'
#' Arkansas uses various markers for suppressed data (*, <, N/A, etc.)
#' and may use commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", ".", "-", "-1", "<5", "<10", "N/A", "NA", "", "RV", "**")] <- NA_character_

  suppressWarnings(as.numeric(x))
}


#' Convert school year string to end year
#'
#' Converts Arkansas school year format (e.g., "2023-2024") to end year (2024)
#'
#' @param sy School year string (e.g., "2023-2024" or "2023-24")
#' @return Integer end year
#' @keywords internal
parse_school_year <- function(sy) {
  # Handle formats like "2023-2024" or "2023-24"
  parts <- strsplit(sy, "-")[[1]]
  if (length(parts) == 2) {
    end_part <- parts[2]
    if (nchar(end_part) == 2) {
      # Two-digit year - determine century
      start_year <- as.integer(parts[1])
      century <- floor(start_year / 100) * 100
      return(century + as.integer(end_part))
    } else {
      return(as.integer(end_part))
    }
  }
  as.integer(sy)
}


#' Format end year as school year string
#'
#' Converts end year (e.g., 2024) to Arkansas school year format (2023-2024)
#'
#' @param end_year Integer end year
#' @return School year string
#' @keywords internal
format_school_year <- function(end_year) {

  paste0(end_year - 1, "-", end_year)
}


#' Clean district/school names
#'
#' Standardizes district and school names by trimming whitespace and
#' standardizing case.
#'
#' @param x Character vector of names
#' @return Cleaned character vector
#' @keywords internal
clean_names <- function(x) {
  x <- trimws(x)
  # Remove extra internal whitespace
  x <- gsub("\\s+", " ", x)
  x
}


#' Standardize Arkansas LEA/School IDs
#'
#' Arkansas uses 7-digit IDs for districts (LEAs) and schools.
#' This function ensures IDs are properly formatted as 7-digit strings.
#'
#' @param id Character or numeric ID
#' @return Character ID padded to 7 digits
#' @keywords internal
standardize_ar_id <- function(id) {
  id <- as.character(id)
  # Remove any non-numeric characters
  id <- gsub("[^0-9]", "", id)
  # Pad to 7 digits
  sprintf("%07s", id)
}


#' Extract district ID from school ID
#'
#' Arkansas school IDs embed the district ID in the first 4 digits.
#' District IDs end in "000" (e.g., 0401000 is Bentonville district,
#' 0401004 is a school in that district).
#'
#' @param school_id Character school ID (7 digits)
#' @return Character district ID (7 digits ending in 000)
#' @keywords internal
extract_district_id <- function(school_id) {
  school_id <- standardize_ar_id(school_id)
  # District ID is first 4 digits + "000"
  paste0(substr(school_id, 1, 4), "000")
}


#' Check if ID is a district (not a school)
#'
#' District IDs in Arkansas end in "000"
#'
#' @param id Character ID
#' @return Logical TRUE if this is a district ID
#' @keywords internal
is_district_id <- function(id) {
  id <- standardize_ar_id(id)
  grepl("000$", id)
}
