# Extract district ID from school ID

Arkansas school IDs embed the district ID in the first 4 digits.
District IDs end in "000" (e.g., 0401000 is Bentonville district,
0401004 is a school in that district).

## Usage

``` r
extract_district_id(school_id)
```

## Arguments

- school_id:

  Character school ID (7 digits)

## Value

Character district ID (7 digits ending in 000)
