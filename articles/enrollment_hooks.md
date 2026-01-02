# Arkansas School Enrollment: An Overview

This vignette provides an overview of Arkansas school enrollment data
access through the `arschooldata` package.

## Getting Started

``` r
library(arschooldata)
library(dplyr)
```

## Available Data

The package provides access to Arkansas school enrollment data from the
Arkansas Department of Education. Use
[`get_available_years()`](https://almartin82.github.io/arschooldata/reference/get_available_years.md)
to see the available date range:

``` r
get_available_years()
#> $min_year
#> [1] 2006
#> 
#> $max_year
#> [1] 2024
#> 
#> $description
#> [1] "Arkansas enrollment data is available from 2005-06 (end_year 2006) through 2023-24 (end_year 2024). Data comes from the Annual Statistical Reports published by the Arkansas Division of Elementary and Secondary Education."
```

## Fetching Data

Use
[`fetch_enr()`](https://almartin82.github.io/arschooldata/reference/fetch_enr.md)
to download enrollment data for a single year:

``` r
# Fetch 2024 enrollment data
enr_2024 <- fetch_enr(2024)

# View the structure
head(enr_2024)
```

Use
[`fetch_enr_multi()`](https://almartin82.github.io/arschooldata/reference/fetch_enr_multi.md)
to download multiple years at once:

``` r
# Fetch 5 years of data
enr_multi <- fetch_enr_multi(2020:2024)

# View year counts
table(enr_multi$end_year)
```

## Data Structure

The returned data includes district-level information from the Arkansas
Annual Statistical Reports. Key columns include:

- District identifiers and names
- Average Daily Attendance (ADA)
- Financial and budget information

## Data Sources

Arkansas school data comes from the Arkansas Division of Elementary and
Secondary Education (DESE):

- **Annual Statistical Reports**: District-level fiscal and enrollment
  summary data
- **ADE Data Center**: Detailed enrollment demographics
  (<https://adedata.arkansas.gov/statewide/>)

## Caching

By default, downloaded data is cached locally to avoid repeated
downloads. Use
[`cache_status()`](https://almartin82.github.io/arschooldata/reference/cache_status.md)
to check cached data:

``` r
cache_status()
```

Clear the cache with
[`clear_cache()`](https://almartin82.github.io/arschooldata/reference/clear_cache.md)
if needed.

## More Information

For detailed enrollment demographics by race/ethnicity, grade level, and
school, visit the Arkansas Department of Education Data Center directly
at <https://adedata.arkansas.gov/statewide/>

------------------------------------------------------------------------

*For more information about Arkansas education data, visit the [Arkansas
Division of Elementary and Secondary
Education](https://dese.ade.arkansas.gov/).*
