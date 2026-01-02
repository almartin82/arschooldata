# TODO - arschooldata

## Data Source Enhancement (Priority: High)

The current implementation fetches financial/budget data from the Annual
Statistical Reports (ASR), not detailed enrollment demographics. See
ERRATA.md for details.

### Needed

1.  Implement ADE Data Center scraping for enrollment by race/ethnicity
    data
2.  Add `process_enrollment.R` to standardize raw data
3.  Add `tidy_enrollment.R` to transform to long format
4.  Add `id_enr_aggs()` function for aggregation level flags

### Current Data

- Source: Arkansas DESE Annual Statistical Reports
- Content: ADA (Average Daily Attendance), financial data
- Coverage: 2006-2024

### Target Data

- Source: ADE Data Center (<https://adedata.arkansas.gov/statewide/>)
- Content: Enrollment by race/ethnicity, grade level, school
- Coverage: 2005-2026
