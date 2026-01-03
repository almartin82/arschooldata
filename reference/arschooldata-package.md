# arschooldata: Fetch and Process Arkansas School Data

Downloads and processes school data from the Arkansas Department of
Education (ADE). Provides functions for fetching enrollment data from
Annual Statistical Reports (ASR), which contain Average Daily Attendance
(ADA) and fiscal data.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/arschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/arschooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- [`get_available_years`](https://almartin82.github.io/arschooldata/reference/get_available_years.md):

  Check which years have available data

## Cache functions

- [`cache_status`](https://almartin82.github.io/arschooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/arschooldata/reference/clear_cache.md):

  Remove cached data files

## ID System

Arkansas uses a hierarchical ID system:

- District IDs (LEA): 7 digits (e.g., 0401000 = Bentonville)

- School IDs: 7 digits (e.g., 0401004)

## Data Sources

Data is sourced from the Arkansas Department of Education systems:

- Annual Statistical Reports:
  <https://dese.ade.arkansas.gov/offices/data-management/annual-statistical-report>

- ADE Data Center (demographics, not yet implemented):
  <https://adedata.arkansas.gov/statewide/>

## Data Availability

- Year 2006: Available

- Years 2007-2012: NOT available (missing ASR URLs)

- Years 2013-2024: Available

Use
[`get_available_years`](https://almartin82.github.io/arschooldata/reference/get_available_years.md)
to check current availability.

## See also

Useful links:

- <https://almartin82.github.io/arschooldata>

- <https://github.com/almartin82/arschooldata>

- Report bugs at <https://github.com/almartin82/arschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
