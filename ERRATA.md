# Data Source Errata

## Enrollment Demographics (2024-01-02)

### Issue

The Arkansas package currently fetches data from the Annual Statistical
Reports (ASR) which contains primarily financial and budget data, not
the enrollment demographics (race/ethnicity breakdowns) that the package
API was designed to provide.

### Expected Data Structure

The
[`fetch_enr()`](https://almartin82.github.io/arschooldata/reference/fetch_enr.md)
function should return a data frame with: - `is_state`, `is_district`,
`is_school`, `is_charter` - aggregation level flags - `subgroup` -
demographic categories (total_enrollment, white, black, hispanic,
etc.) - `grade_level` - grade breakdowns (K, 01, 02, … 12, TOTAL) -
`n_students` - enrollment counts - `pct` - percentage of total

### Actual Data Structure

The ASR files contain: - ADA (Average Daily Attendance) - a single
count, not broken down by demographics - Financial data (revenue,
expenditure, mills, etc.) - District identifiers

### Root Cause

The ASR Excel files from the Arkansas Division of Elementary and
Secondary Education contain fiscal/budget data, not enrollment
demographics. The enrollment demographics are available through the ADE
Data Center (adedata.arkansas.gov), which uses ASP.NET postback forms
that require session-based scraping.

### Workaround

Until proper ADE Data Center integration is implemented, the package
provides limited functionality: - ADA counts are available as a rough
proxy for enrollment - Full demographic breakdowns require manual
download from the ADE Data Center

### Planned Resolution

1.  Implement session-based scraping of the ADE Data Center enrollment
    reports
2.  Add proper process_enrollment.R to standardize raw data
3.  Add proper tidy_enrollment.R to transform to long format with
    demographics

### Year Coverage

| Years     | Data Source | Demographics Available |
|-----------|-------------|------------------------|
| 2006-2024 | ASR         | No (ADA only)          |

### Contact

For manually downloading enrollment demographics, visit:
<https://adedata.arkansas.gov/statewide/ReportList/State/EnrollmentByRace.aspx>
