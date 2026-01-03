# Test fetch_enr and fetch_enr_multi functions

# Skip tests if not on CI (network-dependent tests)
skip_if_offline <- function() {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
}

# =============================================================================
# Basic functionality tests
# =============================================================================

test_that("fetch_enr returns data frame for valid year", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  expect_s3_class(data, "data.frame")
  expect_gt(nrow(data), 0)
  expect_gt(ncol(data), 0)
})

test_that("fetch_enr adds end_year column", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  expect_true("end_year" %in% names(data))
  expect_equal(unique(data$end_year), 2024)
})

test_that("fetch_enr rejects invalid years", {
  expect_error(fetch_enr(1990), "end_year must be between")
  expect_error(fetch_enr(2050), "end_year must be between")
})

test_that("fetch_enr rejects years without URL mapping", {
  skip_if_offline()

  # Years 2007-2012 don't have URL mappings
  expect_error(fetch_enr(2010), "No Annual Statistical Report URL found")
})

# =============================================================================
# Data fidelity tests - verify raw data values are preserved
# =============================================================================

test_that("2024 data contains expected districts", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Get district name column (varies by year format)
  district_col <- if ("1" %in% names(data)) "1" else "district_name"

  districts <- data[[district_col]]
  expect_true(any(grepl("BENTONVILLE", districts, ignore.case = TRUE)))
  expect_true(any(grepl("LITTLE ROCK", districts, ignore.case = TRUE)))
  expect_true(any(grepl("SPRINGDALE", districts, ignore.case = TRUE)))
  expect_true(any(grepl("ROGERS", districts, ignore.case = TRUE)))
  expect_true(any(grepl("FORT SMITH", districts, ignore.case = TRUE)))
})

test_that("2024 Bentonville ADA matches raw data value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Bentonville ADA in raw data: 17929.14
  bentonville <- data[grepl("BENTONVILLE", data[["1"]], ignore.case = TRUE), ]

  expect_equal(nrow(bentonville), 1)
  ada_value <- as.numeric(bentonville[["2_ada"]])
  expect_equal(ada_value, 17929.14, tolerance = 0.01)
})

test_that("2024 Little Rock ADA matches raw data value", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Little Rock ADA in raw data: 17581.67 (approximately)
  little_rock <- data[grepl("^LITTLE ROCK SCHOOL", data[["1"]], ignore.case = TRUE), ]

  expect_equal(nrow(little_rock), 1)
  ada_value <- as.numeric(little_rock[["2_ada"]])
  expect_equal(ada_value, 17581.67, tolerance = 1.0)
})

test_that("2024 district IDs are properly formatted", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Get ID column
  id_col <- if ("2" %in% names(data)) "2" else "district_lea"

  # Filter to valid data rows (exclude headers)
  valid_rows <- data[grepl("^[0-9]", data[[id_col]]), ]

  ids <- valid_rows[[id_col]]
  expect_true(all(nchar(ids) == 7))
  expect_true(all(grepl("^[0-9]{7}$", ids)))

  # Districts should end in 000
  expect_true(all(grepl("000$", ids)))
})

# =============================================================================
# 2006 format tests (earliest year with different column names)
# =============================================================================

test_that("2006 data has proper column names", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)

  # 2006 format has named columns
  expect_true("district_name" %in% names(data) || "1" %in% names(data))
  expect_true("ada" %in% names(data) || "2_ada" %in% names(data))
})

test_that("2006 Bentonville ADA matches raw data value", {
  skip_if_offline()

  data <- fetch_enr(2006, use_cache = TRUE)

  # Determine which column has district names
  name_col <- if ("district_name" %in% names(data)) "district_name" else "1"
  ada_col <- if ("ada" %in% names(data)) "ada" else "2_ada"

  bentonville <- data[grepl("BENTONVILLE", data[[name_col]], ignore.case = TRUE), ]

  expect_equal(nrow(bentonville), 1)
  ada_value <- as.numeric(bentonville[[ada_col]])
  # Raw 2006 value: 9646.13
  expect_equal(ada_value, 9646.13, tolerance = 0.1)
})

# =============================================================================
# State-level aggregate tests
# =============================================================================

test_that("2024 state total ADA is plausible", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Filter to valid data rows
  valid_rows <- data[!is.na(data[["2"]]) & grepl("^[0-9]", data[["2"]]), ]

  # Calculate total ADA
  total_ada <- sum(as.numeric(valid_rows[["2_ada"]]), na.rm = TRUE)

  # Arkansas has about 480,000 public school students

  # ADA is typically 90-95% of enrollment, so expect 400,000-460,000
  expect_gt(total_ada, 350000)
  expect_lt(total_ada, 500000)
})

test_that("2024 has reasonable number of districts", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Filter to valid data rows
  valid_rows <- data[!is.na(data[["2"]]) & grepl("^[0-9]", data[["2"]]), ]

  # Arkansas has about 235 school districts
  expect_gt(nrow(valid_rows), 200)
  expect_lt(nrow(valid_rows), 300)
})

# =============================================================================
# Data quality tests - check for impossible values
# =============================================================================

test_that("2024 has no negative ADA values", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  valid_rows <- data[!is.na(data[["2"]]) & grepl("^[0-9]", data[["2"]]), ]
  ada_values <- as.numeric(valid_rows[["2_ada"]])

  expect_true(all(ada_values >= 0, na.rm = TRUE))
})

test_that("2024 has no impossibly large ADA values", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  valid_rows <- data[!is.na(data[["2"]]) & grepl("^[0-9]", data[["2"]]), ]
  ada_values <- as.numeric(valid_rows[["2_ada"]])

  # No district should have more than 50,000 students
  expect_true(all(ada_values < 50000, na.rm = TRUE))
})

test_that("2024 has no zero ADA for major districts", {
  skip_if_offline()

  data <- fetch_enr(2024, use_cache = TRUE)

  # Major districts should have non-zero ADA
  major_districts <- c("LITTLE ROCK", "BENTONVILLE", "SPRINGDALE", "ROGERS")

  for (district in major_districts) {
    row <- data[grepl(district, data[["1"]], ignore.case = TRUE), ]
    if (nrow(row) > 0) {
      ada_value <- as.numeric(row[["2_ada"]][1])
      expect_true(ada_value > 1000, label = paste("District", district, "ADA > 1000"))
    }
  }
})

# =============================================================================
# Multi-year fetch tests
# =============================================================================

test_that("fetch_enr_multi returns combined data", {
  skip_if_offline()

  data <- fetch_enr_multi(2023:2024, use_cache = TRUE)

  expect_s3_class(data, "data.frame")
  expect_true("end_year" %in% names(data))
  expect_equal(sort(unique(data$end_year)), c(2023, 2024))
})

test_that("fetch_enr_multi rejects invalid years", {
  expect_error(fetch_enr_multi(1990:2000), "Invalid years")
  expect_error(fetch_enr_multi(2050:2055), "Invalid years")
})

# =============================================================================
# Cache tests
# =============================================================================

test_that("cache_status returns data frame", {
  result <- cache_status()
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("clear_cache works without error", {
  expect_no_error(clear_cache())
})
