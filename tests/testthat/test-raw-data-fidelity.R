# Test raw data fidelity - verify processed data matches raw source files
#
# These tests ensure that fetch_enr() returns data that accurately reflects
# the original Excel files from the Arkansas Department of Education.
#
# CRITICAL: All values tested here were verified against the actual raw Excel files.

skip_if_offline <- function() {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
}

# =============================================================================
# Helper functions
# =============================================================================

#' Get the district name column for a given year's data
get_name_col <- function(data) {
  if ("1" %in% names(data)) return("1")
  if ("district_name" %in% names(data)) return("district_name")
  if ("actual_amount" %in% names(data)) return("actual_amount")
  names(data)[1]
}

#' Get the district ID column for a given year's data
get_id_col <- function(data) {
  if ("2" %in% names(data)) return("2")
  if ("district_lea" %in% names(data)) return("district_lea")
  names(data)[2]
}

#' Get the ADA column for a given year's data
get_ada_col <- function(data) {
  if ("2_ada" %in% names(data)) return("2_ada")
  if ("ada" %in% names(data)) return("ada")
  NULL
}

#' Filter to valid data rows (excluding headers)
get_valid_rows <- function(data) {
  id_col <- get_id_col(data)
  data[!is.na(data[[id_col]]) & grepl("^[0-9]+$", data[[id_col]]), ]
}

#' Get ADA value for a specific district by ID
get_district_ada <- function(data, district_id) {
  id_col <- get_id_col(data)
  ada_col <- get_ada_col(data)
  if (is.null(ada_col)) return(NA_real_)

  # Filter handling NAs properly
  row <- data[!is.na(data[[id_col]]) & data[[id_col]] == district_id, ]
  if (nrow(row) == 0) return(NA_real_)
  as.numeric(row[[ada_col]][1])
}

#' Get district name by ID
get_district_name <- function(data, district_id) {
  id_col <- get_id_col(data)
  name_col <- get_name_col(data)

  # Filter handling NAs properly
  row <- data[!is.na(data[[id_col]]) & data[[id_col]] == district_id, ]
  if (nrow(row) == 0) return(NA_character_)
  row[[name_col]][1]
}

# =============================================================================
# 2006 Raw Data Fidelity Tests
# =============================================================================

test_that("2006: Bentonville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)
  # Raw Excel value: Bentonville (ID 0401000) ADA = 9646.13
  ada <- get_district_ada(data, "0401000")
  expect_equal(ada, 9646.13, tolerance = 0.01)
})

test_that("2006: Little Rock ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)
  # Raw Excel value: Little Rock (ID 6001000) ADA = 24053
  ada <- get_district_ada(data, "6001000")
  expect_equal(ada, 24053, tolerance = 1.0)
})

test_that("2006: Total state ADA is plausible", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)
  ada_col <- get_ada_col(data)

  total_ada <- sum(as.numeric(valid_rows[[ada_col]]), na.rm = TRUE)
  # Arkansas had ~430,000 ADA in 2006
  expect_gt(total_ada, 400000)
  expect_lt(total_ada, 500000)
})

test_that("2006: District count is accurate", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)

  # Arkansas had ~250 districts in 2006
  expect_gt(nrow(valid_rows), 240)
  expect_lt(nrow(valid_rows), 270)
})

# =============================================================================
# 2013 Raw Data Fidelity Tests (different column format)
# =============================================================================

test_that("2013: Springdale ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2013, use_cache = TRUE)
  # Raw Excel value: Springdale (ID 7207000) ADA = 18853.88
  ada <- get_district_ada(data, "7207000")
  expect_equal(ada, 18853.88, tolerance = 1.0)
})

test_that("2013: Fort Smith ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2013, use_cache = TRUE)
  # Raw Excel value: Fort Smith (ID 6601000) ADA = 13267.48
  ada <- get_district_ada(data, "6601000")
  expect_equal(ada, 13267.48, tolerance = 1.0)
})

test_that("2013: Educational cooperatives have zero ADA (expected)", {
  skip_if_offline()

  data <- fetch_enr(2013, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)
  name_col <- get_name_col(data)
  ada_col <- get_ada_col(data)

  # Find cooperatives
  coops <- valid_rows[grepl("CO-OP|COOP|COOPERATIVE|SERVICE", valid_rows[[name_col]], ignore.case = TRUE), ]

  # All cooperatives should have 0 ADA
  coop_ada <- as.numeric(coops[[ada_col]])
  expect_true(all(coop_ada == 0, na.rm = TRUE),
              info = "Educational cooperatives should have 0 ADA")
})

# =============================================================================
# 2014-2018 Raw Data Fidelity Tests
# =============================================================================

test_that("2014: Bentonville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2014, use_cache = TRUE)
  # Raw Excel value: 12866.99
  ada <- get_district_ada(data, "0401000")
  expect_equal(ada, 12866.99, tolerance = 1.0)
})

test_that("2015: Rogers ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2015, use_cache = TRUE)
  # Raw Excel value: 14120.85
  ada <- get_district_ada(data, "0405000")
  expect_equal(ada, 14120.85, tolerance = 1.0)
})

test_that("2016: Conway ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2016, use_cache = TRUE)
  # Raw Excel value: Conway (ID 2301000) ADA = 9273.65
  ada <- get_district_ada(data, "2301000")
  expect_equal(ada, 9273.65, tolerance = 1.0)
})

test_that("2017: Jonesboro ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2017, use_cache = TRUE)
  # Raw Excel value: Jonesboro (ID 1608000) ADA = 5462.38
  ada <- get_district_ada(data, "1608000")
  expect_equal(ada, 5462.38, tolerance = 1.0)
})

test_that("2018: Fayetteville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2018, use_cache = TRUE)
  # Raw Excel value: Fayetteville (ID 7203000) ADA = 9411.26
  ada <- get_district_ada(data, "7203000")
  expect_equal(ada, 9411.26, tolerance = 1.0)
})

# =============================================================================
# 2019-2023 Raw Data Fidelity Tests
# =============================================================================

test_that("2019: Cabot ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2019, use_cache = TRUE)
  # Raw Excel value: Cabot (ID 4304000) ADA = 9677.93
  ada <- get_district_ada(data, "4304000")
  expect_equal(ada, 9677.93, tolerance = 1.0)
})

test_that("2020: Bryant ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2020, use_cache = TRUE)
  # Raw Excel value: Bryant (ID 6303000) ADA = 8962.82
  ada <- get_district_ada(data, "6303000")
  expect_equal(ada, 8962.82, tolerance = 1.0)
})

test_that("2021: Fayetteville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2021, use_cache = TRUE)
  # Raw Excel value: Fayetteville (ID 7203000) ADA = 9293.56
  ada <- get_district_ada(data, "7203000")
  expect_equal(ada, 9293.56, tolerance = 1.0)
})

test_that("2022: Russellville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2022, use_cache = TRUE)
  # Raw Excel value: Russellville (ID 5805000) ADA = 4897.30
  ada <- get_district_ada(data, "5805000")
  expect_equal(ada, 4897.30, tolerance = 1.0)
})

test_that("2023: Van Buren ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2023, use_cache = TRUE)
  # Raw Excel value: Van Buren (ID 1705000) ADA = 5339.62
  ada <- get_district_ada(data, "1705000")
  expect_equal(ada, 5339.62, tolerance = 1.0)
})

# =============================================================================
# 2024 Raw Data Fidelity Tests (most recent year - comprehensive)
# =============================================================================

test_that("2024: Bentonville ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  # Raw Excel value: 17929.14
  ada <- get_district_ada(data, "0401000")
  expect_equal(ada, 17929.14, tolerance = 0.01)
})

test_that("2024: Little Rock ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  # Raw Excel value: 17581.67
  ada <- get_district_ada(data, "6001000")
  expect_equal(ada, 17581.67, tolerance = 1.0)
})

test_that("2024: Springdale ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  # Raw Excel value: 20313.42
  ada <- get_district_ada(data, "7207000")
  expect_equal(ada, 20313.42, tolerance = 1.0)
})

test_that("2024: Rogers ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  # Raw Excel value: 14333.36
  ada <- get_district_ada(data, "0405000")
  expect_equal(ada, 14333.36, tolerance = 1.0)
})

test_that("2024: Fort Smith ADA matches raw Excel value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  # Raw Excel value: 12404.01
  ada <- get_district_ada(data, "6601000")
  expect_equal(ada, 12404.01, tolerance = 1.0)
})

test_that("2024: Total state ADA is plausible", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)
  ada_col <- get_ada_col(data)

  total_ada <- sum(as.numeric(valid_rows[[ada_col]]), na.rm = TRUE)
  # Arkansas has ~414,000 ADA in 2024
  expect_gt(total_ada, 400000)
  expect_lt(total_ada, 450000)
})

test_that("2024: District count is accurate", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)

  # Arkansas has ~234 districts in 2024
  expect_gt(nrow(valid_rows), 220)
  expect_lt(nrow(valid_rows), 250)
})

# =============================================================================
# Data Quality Tests - Cross-Year Consistency
# =============================================================================

test_that("State total ADA trend is plausible", {
  skip_if_offline()

  # Calculate state total for multiple years
  calculate_state_total <- function(year) {
    data <- fetch_enr(year, use_cache = TRUE)
    valid_rows <- get_valid_rows(data)
    ada_col <- get_ada_col(data)
    sum(as.numeric(valid_rows[[ada_col]]), na.rm = TRUE)
  }

  total_2006 <- calculate_state_total(2006)
  total_2020 <- calculate_state_total(2020)
  total_2024 <- calculate_state_total(2024)

  # State ADA should be in reasonable range across years
  expect_gt(total_2006, 400000)
  expect_gt(total_2020, 400000)
  expect_gt(total_2024, 400000)

  # Year-over-year change shouldn't be more than 10%
  expect_lt(abs(total_2024 / total_2020 - 1), 0.10)
})

test_that("Major districts exist in all years", {
  skip_if_offline()

  major_district_ids <- c(
    "0401000",  # Bentonville
    "6001000",  # Little Rock
    "7207000",  # Springdale
    "0405000",  # Rogers
    "6601000"   # Fort Smith
  )

  for (year in c(2006, 2013, 2020, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)
    id_col <- get_id_col(data)
    valid_rows <- get_valid_rows(data)

    for (district_id in major_district_ids) {
      expect_true(
        district_id %in% valid_rows[[id_col]],
        info = paste("District", district_id, "should exist in year", year)
      )
    }
  }
})

# =============================================================================
# Data Quality Tests - No Impossible Values
# =============================================================================

test_that("No negative ADA values in any year", {
  skip_if_offline()

  for (year in c(2006, 2013, 2017, 2020, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)
    valid_rows <- get_valid_rows(data)
    ada_col <- get_ada_col(data)

    ada_values <- as.numeric(valid_rows[[ada_col]])
    expect_true(
      all(ada_values >= 0, na.rm = TRUE),
      info = paste("Year", year, "should have no negative ADA")
    )
  }
})

test_that("No impossibly large ADA values", {
  skip_if_offline()

  for (year in c(2006, 2013, 2017, 2020, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)
    valid_rows <- get_valid_rows(data)
    ada_col <- get_ada_col(data)

    ada_values <- as.numeric(valid_rows[[ada_col]])
    # No district should have more than 30,000 ADA
    expect_true(
      all(ada_values < 30000, na.rm = TRUE),
      info = paste("Year", year, "should have no ADA > 30,000")
    )
  }
})

test_that("Major districts have non-zero ADA", {
  skip_if_offline()

  major_district_ids <- c(
    "0401000",  # Bentonville
    "6001000",  # Little Rock
    "7207000",  # Springdale
    "0405000",  # Rogers
    "6601000"   # Fort Smith
  )

  for (year in c(2006, 2013, 2017, 2020, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)

    for (district_id in major_district_ids) {
      ada <- get_district_ada(data, district_id)
      expect_true(
        !is.na(ada) && ada > 1000,
        info = paste("District", district_id, "in year", year, "should have ADA > 1000")
      )
    }
  }
})

# =============================================================================
# Data Structure Tests
# =============================================================================

test_that("All years have end_year column", {
  skip_if_offline()

  for (year in c(2006, 2013, 2017, 2020, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)
    expect_true("end_year" %in% names(data), info = paste("Year", year))
    expect_equal(unique(data$end_year), year)
  }
})

test_that("District IDs are 7-digit format", {
  skip_if_offline()

  for (year in c(2006, 2024)) {
    data <- fetch_enr(year, use_cache = TRUE)
    valid_rows <- get_valid_rows(data)
    id_col <- get_id_col(data)

    ids <- valid_rows[[id_col]]
    # All IDs should be 7 digits
    expect_true(all(nchar(ids) == 7), info = paste("Year", year, "IDs should be 7 digits"))
    # All IDs should be numeric
    expect_true(all(grepl("^[0-9]{7}$", ids)), info = paste("Year", year, "IDs should be numeric"))
    # District IDs end in 000
    expect_true(all(grepl("000$", ids)), info = paste("Year", year, "District IDs should end in 000"))
  }
})

# =============================================================================
# Known Data Issues Tests - Document Expected Behavior
# =============================================================================

test_that("2015 has some districts with zero ADA (consolidated/closed)", {
  skip_if_offline()

  data <- fetch_enr(2015, use_cache = TRUE)
  valid_rows <- get_valid_rows(data)
  ada_col <- get_ada_col(data)

  ada_values <- as.numeric(valid_rows[[ada_col]])
  zero_count <- sum(ada_values == 0, na.rm = TRUE)

  # Some districts in 2015 had zero ADA due to consolidation/closure
  # This is expected behavior, not a data error
  expect_gt(zero_count, 0, label = "2015 zero-ADA count")
  expect_lt(zero_count, 20, label = "2015 zero-ADA count")
})

test_that("2024 has /0 values in ADA percent change column (expected)",
{
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # The 3_ada_pct_change_over_5_years column contains "/0" for divide-by-zero
  # This is expected because these are new districts or have no 5-year history
  if ("3_ada_pct_change_over_5_years" %in% names(data)) {
    div_zero_count <- sum(data[["3_ada_pct_change_over_5_years"]] == "/0", na.rm = TRUE)
    # Many districts will have this
    expect_gt(div_zero_count, 0, label = "/0 values in ADA pct change")
  }
})

test_that("Header rows are present in raw data (document structure)", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # First two rows are headers ("Actual Amount", "2023/2024")
  # This is the current behavior - these should be filtered out in future processing
  expect_true(
    is.na(data[["2"]][1]) || !grepl("^[0-9]", data[["2"]][1]),
    info = "First row should be header, not data"
  )
})
