# Get available years for Arkansas enrollment data

Returns the range of school years for which enrollment data is available
from the Arkansas Department of Education.

## Usage

``` r
get_available_years()
```

## Value

A list with three elements:

- min_year:

  The earliest available school year end (e.g., 2006 for 2005-06)

- max_year:

  The latest available school year end (e.g., 2025 for 2024-25)

- description:

  Human-readable description of data availability

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2006
#> 
#> $max_year
#> [1] 2025
#> 
#> $description
#> [1] "Arkansas enrollment data is available from 2005-06 (end_year 2006) through 2024-25 (end_year 2025). Data comes from the Annual Statistical Reports published by the Arkansas Division of Elementary and Secondary Education."
#> 
# Returns list with min_year, max_year, and description
```
