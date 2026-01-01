# Download raw enrollment data from Arkansas ADE

Downloads district and school enrollment data from the Arkansas
Department of Education. Uses Annual Statistical Reports for
district-level data with demographics, and can supplement with ADE Data
Center for school-level data.

## Usage

``` r
get_raw_enr(end_year, include_schools = FALSE)
```

## Arguments

- end_year:

  School year end (2023-24 = 2024)

- include_schools:

  If TRUE, also downloads school-level data from ADE Data Center
  (slower, requires additional requests)

## Value

List with district (and optionally school) data frames
