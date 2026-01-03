# Test utility functions

test_that("get_available_years returns correct structure", {
  result <- get_available_years()

  expect_type(result, "list")
  expect_true("min_year" %in% names(result))
  expect_true("max_year" %in% names(result))
  expect_true("available_years" %in% names(result))
  expect_true("gap_years" %in% names(result))
  expect_true("description" %in% names(result))
  expect_lte(result$min_year, result$max_year)
})

test_that("get_available_years returns reasonable year range", {
  result <- get_available_years()

  # Arkansas data should start from 2006
  expect_equal(result$min_year, 2006)

  # Max year should be recent (at least 2024)
  expect_gte(result$max_year, 2024)
  expect_lte(result$max_year, 2030)
})

test_that("get_available_years documents gap years correctly", {
  result <- get_available_years()

  # Gap years are 2007-2012
  expect_equal(result$gap_years, 2007:2012)

  # Available years should include 2006 and 2013-2024
  expect_true(2006 %in% result$available_years)
  expect_true(2013 %in% result$available_years)
  expect_true(2024 %in% result$available_years)

  # Gap years should NOT be in available years
  expect_false(any(result$gap_years %in% result$available_years))
})

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(arschooldata:::safe_numeric("123"), 123)
  expect_equal(arschooldata:::safe_numeric("1,234"), 1234)
  expect_equal(arschooldata:::safe_numeric("1,234.56"), 1234.56)

  # Suppression markers should return NA
  expect_true(is.na(arschooldata:::safe_numeric("*")))
  expect_true(is.na(arschooldata:::safe_numeric(".")))
  expect_true(is.na(arschooldata:::safe_numeric("-")))
  expect_true(is.na(arschooldata:::safe_numeric("N/A")))
  expect_true(is.na(arschooldata:::safe_numeric("<5")))
  expect_true(is.na(arschooldata:::safe_numeric("RV")))
  expect_true(is.na(arschooldata:::safe_numeric("")))

  # Whitespace should be trimmed
  expect_equal(arschooldata:::safe_numeric("  123  "), 123)
})

test_that("parse_school_year handles different formats", {
  expect_equal(arschooldata:::parse_school_year("2023-2024"), 2024)
  expect_equal(arschooldata:::parse_school_year("2023-24"), 2024)
  expect_equal(arschooldata:::parse_school_year("2024"), 2024)
})

test_that("format_school_year produces correct format", {
  expect_equal(arschooldata:::format_school_year(2024), "2023-2024")
  expect_equal(arschooldata:::format_school_year(2006), "2005-2006")
})

test_that("standardize_ar_id pads IDs correctly", {
  expect_equal(arschooldata:::standardize_ar_id("101000"), "0101000")
  expect_equal(arschooldata:::standardize_ar_id("0401000"), "0401000")
  expect_equal(arschooldata:::standardize_ar_id(6001000), "6001000")
})

test_that("is_district_id correctly identifies districts", {
  # Districts end in 000
  expect_true(arschooldata:::is_district_id("0401000"))
  expect_true(arschooldata:::is_district_id("6001000"))

  # Schools don't end in 000
  expect_false(arschooldata:::is_district_id("0401004"))
  expect_false(arschooldata:::is_district_id("6001042"))
})

test_that("extract_district_id extracts correct district", {
  # School 0401004 is in Bentonville district (0401000)
  expect_equal(arschooldata:::extract_district_id("0401004"), "0401000")
  expect_equal(arschooldata:::extract_district_id("6001042"), "6001000")

  # District ID should return itself
  expect_equal(arschooldata:::extract_district_id("0401000"), "0401000")
})
