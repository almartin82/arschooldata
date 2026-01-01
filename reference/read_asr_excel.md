# Read enrollment data from ASR Excel file

Parses the Annual Statistical Report Excel file to extract enrollment
data. ASR files have multiple sheets; we look for the enrollment-related
sheet.

## Usage

``` r
read_asr_excel(filepath, end_year)
```

## Arguments

- filepath:

  Path to the downloaded Excel file

- end_year:

  School year end (for format detection)

## Value

Data frame with enrollment data
