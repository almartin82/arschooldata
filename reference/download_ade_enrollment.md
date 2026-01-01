# Download enrollment data from ADE Data Center

Downloads enrollment data from the ADE Data Center's Statewide
Information System Reports. This uses web scraping since the ADE Data
Center uses ASP.NET postbacks rather than direct URLs.

## Usage

``` r
download_ade_enrollment(end_year, level = "district")
```

## Arguments

- end_year:

  School year end

- level:

  One of "state", "district", or "school"

## Value

Data frame with enrollment data or NULL if download fails
