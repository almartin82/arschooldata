# Get available years for Arkansas enrollment data

Returns the range of school years for which enrollment data is available
from the Arkansas Department of Education.

## Usage

``` r
get_available_years()
```

## Value

A list with the following elements:

- min_year:

  The earliest available school year end (e.g., 2006 for 2005-06)

- max_year:

  The latest available school year end (e.g., 2024 for 2023-24)

- available_years:

  Integer vector of all years with data URLs

- gap_years:

  Integer vector of years without data URLs (2007-2012)

- description:

  Human-readable description of data availability

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2006
#> 
#> $max_year
#> [1] 2024
#> 
#> $available_years
#>  [1] 2006 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024
#> 
#> $gap_years
#> [1] 2007 2008 2009 2010 2011 2012
#> 
#> $description
#> [1] "Arkansas enrollment data is available from 2005-06 (end_year 2006) and 2012-13 (end_year 2013) through 2023-24 (end_year 2024). NOTE: Years 2007-2012 are NOT currently available due to missing ASR URLs. Data comes from the Annual Statistical Reports published by the Arkansas Division of Elementary and Secondary Education (DESE). The data contains fiscal/budget information including Average Daily Attendance (ADA), but NOT enrollment demographics by race/ethnicity."
#> 
# Returns list with available years and description
```
