# Test coverage for all available years
# These tests verify that each year's data can be fetched and has expected structure

skip_if_offline <- function() {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
}

# Helper to get district name column for a given year's data
get_district_name_col <- function(data) {
  # Different years have different column naming
  if ("1" %in% names(data)) return("1")
  if ("district_name" %in% names(data)) return("district_name")
  if ("actual_amount" %in% names(data)) return("actual_amount")  # 2013 format
  # Fallback
  district_cols <- grep("district", names(data), ignore.case = TRUE, value = TRUE)
  if (length(district_cols) > 0) return(district_cols[1])
  names(data)[1]
}

# Helper to get district ID column
get_district_id_col <- function(data) {
  if ("2" %in% names(data)) return("2")
  if ("district_lea" %in% names(data)) return("district_lea")
  names(data)[2]
}

# Helper function to test a single year
test_year_data <- function(year) {
  data <- fetch_enr(year, use_cache = TRUE)

  # Basic structure tests
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 100, label = paste("Year", year, "has at least 100 rows"))
  expect_true(ncol(data) > 10, label = paste("Year", year, "has at least 10 columns"))
  expect_true("end_year" %in% names(data), label = paste("Year", year, "has end_year"))
  expect_equal(unique(data$end_year), year)

  # Check for presence of key data columns
  has_district_col <- "district_name" %in% names(data) ||
                      "1" %in% names(data) ||
                      "actual_amount" %in% names(data) ||
                      any(grepl("district", names(data), ignore.case = TRUE))
  expect_true(has_district_col, label = paste("Year", year, "has district column"))

  has_ada_col <- "ada" %in% names(data) ||
                 "2_ada" %in% names(data) ||
                 any(grepl("ada", names(data), ignore.case = TRUE))
  expect_true(has_ada_col, label = paste("Year", year, "has ADA column"))

  invisible(data)
}

# =============================================================================
# Individual year tests
# =============================================================================

test_that("2006 data is available and valid", {
  skip_if_offline()
  test_year_data(2006)
})

# Note: Years 2007-2012 do NOT have URL mappings and will fail
# They are skipped intentionally

test_that("2013 data is available and valid", {
  skip_if_offline()
  test_year_data(2013)
})

test_that("2014 data is available and valid", {
  skip_if_offline()
  test_year_data(2014)
})

test_that("2015 data is available and valid", {
  skip_if_offline()
  test_year_data(2015)
})

test_that("2016 data is available and valid", {
  skip_if_offline()
  test_year_data(2016)
})

test_that("2017 data is available and valid", {
  skip_if_offline()
  test_year_data(2017)
})

test_that("2018 data is available and valid", {
  skip_if_offline()
  test_year_data(2018)
})

test_that("2019 data is available and valid", {
  skip_if_offline()
  test_year_data(2019)
})

test_that("2020 data is available and valid", {
  skip_if_offline()
  test_year_data(2020)
})

test_that("2021 data is available and valid", {
  skip_if_offline()
  test_year_data(2021)
})

test_that("2022 data is available and valid", {
  skip_if_offline()
  test_year_data(2022)
})

test_that("2023 data is available and valid", {
  skip_if_offline()
  test_year_data(2023)
})

test_that("2024 data is available and valid", {
  skip_if_offline()
  test_year_data(2024)
})

# =============================================================================
# Cross-year consistency tests
# =============================================================================

test_that("district count is consistent across years", {
  skip_if_offline()

  count_districts <- function(year) {
    data <- fetch_enr(year, use_cache = TRUE)
    id_col <- get_district_id_col(data)
    if (is.null(id_col)) return(NA)
    valid_rows <- data[grepl("^[0-9]", data[[id_col]]), ]
    nrow(valid_rows)
  }

  # Arkansas has had consolidations, so district count may decrease
  # But should be roughly 230-270 districts
  count_2024 <- count_districts(2024)
  count_2013 <- count_districts(2013)
  count_2006 <- count_districts(2006)

  expect_true(count_2024 > 200 && count_2024 < 300)
  expect_true(count_2013 > 200 && count_2013 < 300)
  expect_true(count_2006 > 200 && count_2006 < 300)
})

test_that("Bentonville exists in all available years", {
  skip_if_offline()

  check_bentonville <- function(year) {
    data <- fetch_enr(year, use_cache = TRUE)
    name_col <- get_district_name_col(data)
    any(grepl("BENTONVILLE", data[[name_col]], ignore.case = TRUE))
  }

  # Check key years
  expect_true(check_bentonville(2024))
  expect_true(check_bentonville(2020))
  expect_true(check_bentonville(2013))
  expect_true(check_bentonville(2006))
})

test_that("Little Rock exists in all available years", {
  skip_if_offline()

  check_little_rock <- function(year) {
    data <- fetch_enr(year, use_cache = TRUE)
    name_col <- get_district_name_col(data)
    any(grepl("LITTLE ROCK", data[[name_col]], ignore.case = TRUE))
  }

  # Check key years
  expect_true(check_little_rock(2024))
  expect_true(check_little_rock(2020))
  expect_true(check_little_rock(2013))
  expect_true(check_little_rock(2006))
})

# =============================================================================
# URL availability tests
# =============================================================================

test_that("get_asr_url returns NULL for years without URLs", {
  expect_null(arschooldata:::get_asr_url(2007))
  expect_null(arschooldata:::get_asr_url(2008))
  expect_null(arschooldata:::get_asr_url(2009))
  expect_null(arschooldata:::get_asr_url(2010))
  expect_null(arschooldata:::get_asr_url(2011))
  expect_null(arschooldata:::get_asr_url(2012))
})

test_that("get_asr_url returns valid URLs for mapped years", {
  expect_true(grepl("^https://", arschooldata:::get_asr_url(2006)))
  expect_true(grepl("^https://", arschooldata:::get_asr_url(2013)))
  expect_true(grepl("^https://", arschooldata:::get_asr_url(2024)))
})
