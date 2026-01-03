# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from the
# Arkansas Department of Education (ADE).
#
# Data comes from two main sources:
# - Annual Statistical Reports (ASR): 2006-present, Excel files with detailed
#   district-level enrollment including demographics
# - ADE Data Center: 2005-present, web-based reports with Excel/CSV export
#
# Format Eras:
# - Era 1 (2006-2012): ASR Excel files with older column naming
# - Era 2 (2013-present): ASR Excel files with updated format
# - Era 3 (2005-present): ADE Data Center reports (CSV/Excel via web scraping)
#
# ==============================================================================


#' Download raw enrollment data from Arkansas ADE
#'
#' Downloads district and school enrollment data from the Arkansas Department
#' of Education. Uses Annual Statistical Reports for district-level data with
#' demographics, and can supplement with ADE Data Center for school-level data.
#'
#' @param end_year School year end (2023-24 = 2024)
#' @param include_schools If TRUE, also downloads school-level data from ADE
#'   Data Center (slower, requires additional requests)
#' @return List with district (and optionally school) data frames
#' @keywords internal
get_raw_enr <- function(end_year, include_schools = FALSE) {

  # Validate year
  if (end_year < 2006 || end_year > 2025) {
    stop("end_year must be between 2006 and 2025. ",
         "Annual Statistical Reports are available from 2006-2024.")
  }

  message(paste("Downloading Arkansas enrollment data for", end_year, "..."))

  # Download district data from Annual Statistical Reports (most reliable)
  district_data <- download_asr_enrollment(end_year)

  # Add end_year column
  district_data$end_year <- end_year

  result <- list(district = district_data)

  # Optionally download school-level data from ADE Data Center
  if (include_schools) {
    message("  Downloading school-level data from ADE Data Center...")
    school_data <- download_ade_enrollment(end_year, level = "school")
    if (!is.null(school_data) && nrow(school_data) > 0) {
      school_data$end_year <- end_year
      result$school <- school_data
    }
  }

  result
}


#' Download enrollment data from Annual Statistical Reports
#'
#' Downloads the Excel file from the Arkansas Division of Elementary and
#' Secondary Education's Annual Statistical Reports page.
#'
#' @param end_year School year end
#' @return Data frame with district enrollment data
#' @keywords internal
download_asr_enrollment <- function(end_year) {

  message("  Downloading from Annual Statistical Reports...")


  # Build URL based on year - URLs are not consistent, so we have a mapping
  url <- get_asr_url(end_year)

  if (is.null(url)) {
    stop("No Annual Statistical Report URL found for year ", end_year)
  }

  # Create temp file for download
  file_ext <- if (grepl("\\.xlsx$", url, ignore.case = TRUE)) ".xlsx" else ".xls"
  tname <- tempfile(
    pattern = paste0("ar_asr_", end_year, "_"),
    tmpdir = tempdir(),
    fileext = file_ext
  )

  # Download the file
  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(tname, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("Mozilla/5.0 (compatible; arschooldata R package)")
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

    # Check file was downloaded
    if (!file.exists(tname) || file.info(tname)$size < 1000) {
      stop("Downloaded file is too small or missing")
    }

  }, error = function(e) {
    stop(paste("Failed to download ASR for year", end_year,
               "\nError:", e$message,
               "\nURL:", url))
  })

  # Read the Excel file - find the enrollment sheet
  df <- read_asr_excel(tname, end_year)

  # Clean up
  unlink(tname)

  df
}


#' Get Annual Statistical Report URL for a given year
#'
#' Returns the direct download URL for the ASR Excel file.
#' URLs are not consistent across years, so this function maintains the mapping.
#'
#' @param end_year School year end
#' @return URL string or NULL if not available
#' @keywords internal
get_asr_url <- function(end_year) {

  # URL mapping for known ASR files
  # These URLs were collected from the DESE website
  asr_urls <- list(
    "2024" = "https://dese-admin.ade.arkansas.gov/Files/Annual_Statistics_Report_Excel_Grid_12202024_FAS.xlsx",
    "2023" = "https://dese.ade.arkansas.gov/Files/Annual_Statistics_Report_Excel_Grid_(actual_Budget)_1_2024_FAS.xlsx",
    "2022" = "https://dese.ade.arkansas.gov/Files/Annual_Statistics_Report_Excel_Grid_(actual_Budget)_FAS.xlsx",
    "2021" = "https://dese.ade.arkansas.gov/Files/2021_Annual_Statistics_Report_Excel_Grid_(actual_Budget)_10152021_20220210161155.xlsx",
    "2020" = "https://dese.ade.arkansas.gov/Files/20210212124435_2019-2020%20Annual%20Statistical%20Report.xlsx",
    "2019" = "https://dese.ade.arkansas.gov/Files/20201126125037_2019_Annual_Statistics_Report_Excel_Grid_actual_Budget.xlsx",
    "2018" = "https://dese.ade.arkansas.gov/Files/20201126124948_2018_Annual_Statistics_Report_Excel.xlsx",
    "2017" = "https://dese.ade.arkansas.gov/Files/20201126124905_2016-2017_Annual_Statistical_Report1.xlsx",
    "2016" = "https://dese.ade.arkansas.gov/Files/20201126123943_2015-2016_Annual_Statistical_Report.xlsx",
    "2015" = "https://dese.ade.arkansas.gov/Files/20201126124825_Final_2015_ASR_Excel_Grid_actual_Budget_01292016.xlsx",
    "2014" = "https://dese.ade.arkansas.gov/Files/20201126124842_2013_2014_Annual_Statistical_Report.xlsx",
    "2013" = "https://dese.ade.arkansas.gov/Files/20201126124802_2013_ASR_Actual_Grid_12042013.xlsx",
    "2006" = "https://dese.ade.arkansas.gov/Files/20201126123136_ASRSpreadsheet0506.xlsx"
  )

  # Return URL if we have it
  year_key <- as.character(end_year)
  if (year_key %in% names(asr_urls)) {
    return(asr_urls[[year_key]])
  }

  # For years we don't have direct URLs, return NULL
  # User would need to check the DESE website for updates
  NULL
}


#' Read enrollment data from ASR Excel file
#'
#' Parses the Annual Statistical Report Excel file to extract enrollment data.
#' ASR files have multiple sheets; we look for the enrollment-related sheet.
#'
#' @param filepath Path to the downloaded Excel file
#' @param end_year School year end (for format detection)
#' @return Data frame with enrollment data
#' @keywords internal
read_asr_excel <- function(filepath, end_year) {

  # Get sheet names to find enrollment data
  sheets <- readxl::excel_sheets(filepath)

  # Look for enrollment-related sheets
  # Common sheet names include "Enrollment", "Student", "Demographics", etc.
  enr_patterns <- c(
    "enrollment", "enroll", "student", "membership",
    "demographics", "ethnicity", "race"
  )

  enr_sheet <- NULL
  for (pattern in enr_patterns) {
    matched <- grep(pattern, sheets, ignore.case = TRUE, value = TRUE)
    if (length(matched) > 0) {
      enr_sheet <- matched[1]
      break
    }
  }

  # If no specific enrollment sheet, try the first sheet or one that looks like data
  if (is.null(enr_sheet)) {
    # Try sheets that might contain district data
    dist_patterns <- c("district", "lea", "data", "grid")
    for (pattern in dist_patterns) {
      matched <- grep(pattern, sheets, ignore.case = TRUE, value = TRUE)
      if (length(matched) > 0) {
        enr_sheet <- matched[1]
        break
      }
    }
  }

  # Still no match? Use the first sheet that's not a cover/intro
  if (is.null(enr_sheet)) {
    non_intro <- sheets[!grepl("cover|intro|contents|table of|index", sheets, ignore.case = TRUE)]
    if (length(non_intro) > 0) {
      enr_sheet <- non_intro[1]
    } else {
      enr_sheet <- sheets[1]
    }
  }

  message(paste("  Reading sheet:", enr_sheet))

  # Read the sheet - skip initial rows that might be headers/titles
  # Try to detect the header row
  # Use suppressMessages to silence "New names" messages from readxl
  # when columns have empty names (these are auto-renamed to ...1, ...2, etc.)
  df <- tryCatch({
    # First, read without column names to inspect structure
    raw <- suppressMessages(
      readxl::read_excel(filepath, sheet = enr_sheet, col_names = FALSE, n_max = 20)
    )

    # Find the row with column headers (look for "District" or "LEA" text)
    header_row <- 1
    for (i in 1:min(15, nrow(raw))) {
      row_text <- tolower(paste(as.character(raw[i, ]), collapse = " "))
      if (grepl("district|lea code|lea name|enrollment|white|black|hispanic", row_text)) {
        header_row <- i
        break
      }
    }

    # Now read with proper header
    # Suppress "New names" messages for empty column headers
    suppressMessages(
      readxl::read_excel(
        filepath,
        sheet = enr_sheet,
        skip = header_row - 1,
        col_types = "text"  # Read as text to avoid type issues
      )
    )
  }, error = function(e) {
    # Fallback: just read from the beginning
    suppressMessages(
      readxl::read_excel(
        filepath,
        sheet = enr_sheet,
        col_types = "text"
      )
    )
  })

  # Clean column names
  names(df) <- clean_column_names(names(df))

  # Remove completely empty rows
  df <- df[rowSums(!is.na(df) & df != "") > 0, ]

  df
}


#' Clean column names from Excel
#'
#' Standardizes column names by removing special characters, converting to
#' snake_case, and handling common variations.
#'
#' @param x Character vector of column names
#' @return Cleaned character vector
#' @keywords internal
clean_column_names <- function(x) {
  x <- tolower(x)
  # Remove line breaks and extra whitespace
  x <- gsub("[\r\n]+", " ", x)
  x <- gsub("\\s+", "_", trimws(x))
  # Remove special characters
  x <- gsub("[^a-z0-9_]", "", x)
  # Remove leading/trailing underscores
  x <- gsub("^_+|_+$", "", x)
  # Collapse multiple underscores
  x <- gsub("_+", "_", x)

  x
}


#' Download enrollment data from ADE Data Center
#'
#' Downloads enrollment data from the ADE Data Center's Statewide Information
#' System Reports. This uses web scraping since the ADE Data Center uses
#' ASP.NET postbacks rather than direct URLs.
#'
#' @param end_year School year end
#' @param level One of "state", "district", or "school"
#' @return Data frame with enrollment data or NULL if download fails
#' @keywords internal
download_ade_enrollment <- function(end_year, level = "district") {

  # Build the base URL for the enrollment by race report
  base_urls <- list(
    state = "https://adedata.arkansas.gov/statewide/ReportList/State/EnrollmentByRace.aspx",
    district = "https://adedata.arkansas.gov/statewide/ReportList/Districts/EnrollmentByRace.aspx",
    school = "https://adedata.arkansas.gov/statewide/ReportList/Schools/EnrollmentByRace.aspx"
  )

  url <- base_urls[[level]]
  if (is.null(url)) {
    stop("Invalid level. Must be 'state', 'district', or 'school'.")
  }

  # Note: The ADE Data Center uses ASP.NET postbacks which makes direct

  # programmatic download complex. For now, we rely on the ASR files which
  # provide comprehensive district-level data.

  # This is a placeholder for future implementation using rvest/httr
  # to handle the postback-based export functionality.

  message("  Note: ADE Data Center scraping not yet implemented.")
  message("  Using Annual Statistical Reports as primary data source.")

  NULL
}


#' Get the fiscal year ID for ADE Data Center
#'
#' The ADE Data Center uses fiscal year IDs in its postback system.
#' This function maps school year end to the fiscal year ID.
#'
#' @param end_year School year end
#' @return Fiscal year ID string
#' @keywords internal
get_ade_fiscal_year_id <- function(end_year) {
  # Based on observation: 2025-2026 = fy 36
  # Working backwards: each year decrements by 1
  # So 2024-2025 = 35, 2023-2024 = 34, etc.
  # Base: 2026 - end_year = offset from 36

  base_fy <- 36
  base_year <- 2026
  offset <- base_year - end_year

  as.character(base_fy - offset)
}
