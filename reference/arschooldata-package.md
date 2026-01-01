# arschooldata: Fetch and Process Arkansas School Data

Downloads and processes school data from the Arkansas Department of
Education (ADE). Provides functions for fetching enrollment data from
the ADE Data Center and Annual Statistical Reports (ASR), then
transforming it into tidy format for analysis.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/arschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/arschooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- `tidy_enr`:

  Transform wide data to tidy (long) format

- `id_enr_aggs`:

  Add aggregation level flags

- `enr_grade_aggs`:

  Create grade-level aggregations

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

- ADE Data Center: <https://adedata.arkansas.gov/statewide/>

- Annual Statistical Reports:
  <https://dese.ade.arkansas.gov/Offices/fiscal-and-administrative-services/publication-and-reports/annual-statistical-reports>

## Data Availability

- Enrollment by Grade/Race: 2005-2025 via ADE Data Center

- Annual Statistical Reports (detailed demographics): 2006-2024

- Pre-2005 data may have different formats

## See also

Useful links:

- <https://almartin82.github.io/arschooldata>

- <https://github.com/almartin82/arschooldata>

- Report bugs at <https://github.com/almartin82/arschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
