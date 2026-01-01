# Fetch Arkansas enrollment data

Downloads and returns enrollment data from the Arkansas Department of
Education.

## Usage

``` r
fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024). Valid range: 2006-2025.

- tidy:

  If TRUE (default), returns data in long (tidy) format. Currently
  returns district-level data from Annual Statistical Reports.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Data frame with enrollment data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data
enr_2024 <- fetch_enr(2024)

# Force fresh download
enr_fresh <- fetch_enr(2024, use_cache = FALSE)
} # }
```
