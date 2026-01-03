## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** — the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source — do not fall back to federal data.

---


# Arkansas School Data Package (arschooldata)

## Package Overview

The `arschooldata` package provides access to Arkansas school data from the Arkansas Division of Elementary and Secondary Education (DESE). The primary data source is the Annual Statistical Reports (ASR), which contain district-level fiscal and enrollment data.

**IMPORTANT:** This package provides Average Daily Attendance (ADA) data, NOT enrollment demographics by race/ethnicity. See the Data Limitations section below.

## Data Source URLs

- **Annual Statistical Reports (ASR)**: https://dese.ade.arkansas.gov/offices/data-management/annual-statistical-report
- **ADE Data Center** (demographics): https://adedata.arkansas.gov/statewide/

## Available Years

| Year Range | Status | Notes |
|------------|--------|-------|
| 2006 | Available | Earliest year with ASR URL |
| 2007-2012 | **NOT AVAILABLE** | Missing ASR URLs |
| 2013-2024 | Available | Current data range |

Use `get_available_years()` to check availability:
```r
get_available_years()
# Returns: min_year=2006, max_year=2024
#          available_years=c(2006, 2013:2024)
#          gap_years=2007:2012
```

## Key Data Columns

The ASR files provide fiscal/budget data with the following key columns:

| Column (varies by year) | Description |
|-------------------------|-------------|
| `1` or `district_name` or `actual_amount` | District name |
| `2` or `district_lea` | 7-digit district ID (e.g., "0401000" for Bentonville) |
| `2_ada` or `ada` | Average Daily Attendance |
| `4_4_qtr_adm` or `4_quarter_adm` | 4th Quarter Average Daily Membership |

**Note:** Column names vary across years due to different ASR file formats.

## Data Limitations

The tidy=TRUE version MUST maintain fidelity to the raw, unprocessed source file. Every test should verify actual values from the raw data appear correctly in the tidied output.

### What This Package DOES Provide
- District-level Average Daily Attendance (ADA)
- Fiscal/budget information (revenue, expenditure, mills, etc.)
- District identifiers and names

### What This Package Does NOT Provide (yet)
- Enrollment counts by race/ethnicity (demographics)
- School-level data
- Grade-level breakdowns

Demographics data is available through the ADE Data Center but requires ASP.NET session-based scraping which is not yet implemented.

## Usage Examples

```r
# Get single year
data_2024 <- fetch_enr(2024)

# Get multiple years
data_multi <- fetch_enr_multi(2020:2024)

# Check available years
get_available_years()

# Clear cache
clear_cache()
```

## Known Major Districts

For reference, here are some major Arkansas districts and their approximate ADA (2024):

| District | ID | ADA (approx) |
|----------|---------|--------------|
| Springdale | 7207000 | 20,300 |
| Bentonville | 0401000 | 17,900 |
| Little Rock | 6001000 | 17,600 |
| Rogers | 0405000 | 14,300 |
| Fort Smith | 6601000 | 12,400 |

## Git Commits and PRs

- NEVER reference Claude, Claude Code, or AI assistance in commit messages
- NEVER reference Claude, Claude Code, or AI assistance in PR descriptions
- NEVER add Co-Authored-By lines mentioning Claude or Anthropic
- Keep commit messages focused on what changed, not how it was written

## Testing

Run tests with:
```r
devtools::test()
```

Tests verify:
- Data fidelity: Raw values match tidied output
- Year coverage: All available years can be fetched
- Data quality: No impossible values (negative ADA, ADA > 50,000)
- District existence: Major districts present in all years

### Test Coverage Requirements

**CRITICAL**: All tests must verify that `tidy=TRUE` output maintains FIDELITY to the raw, unprocessed source data.

#### Required Test Coverage

1. **One test per year**: Every year the package supports (2006, 2013-2024) has at least one test verifying a specific ADA value against the raw Excel file.

2. **Raw data fidelity tests**: Tests compare specific numeric values from the raw Excel files to ensure the package doesn't corrupt or misparse data.

3. **Data quality checks**: Every test file includes checks for:
   - No negative ADA values
   - No impossibly large ADA values (>30,000)
   - Major districts have non-zero ADA
   - State total ADA is plausible (~400,000-450,000)

4. **Cross-year consistency**: District counts and major district presence verified across all years.

#### Known Data Characteristics (Not Bugs)

| Characteristic | Description | How to Handle |
|---------------|-------------|---------------|
| Header rows | First 1-3 rows contain headers | Filter rows where ID column is non-numeric |
| Zero ADA cooperatives | Educational cooperatives have 0 ADA | Expected - they don't serve students directly |
| Zero ADA districts | Consolidated/closed districts may show 0 | Check year-over-year if concerned |
| `/0` in pct change | Divide-by-zero for new districts | Expected - no 5-year history |
| "New names" warnings | Empty Excel column headers | Cosmetic - data is correct |

#### Test File Structure

See `tests/testthat/test-raw-data-fidelity.R` for the comprehensive fidelity testing pattern.


---

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE network tests.

### Test Categories:
1. URL Availability - HTTP 200 checks
2. File Download - Verify actual file (not HTML error)
3. File Parsing - readxl/readr succeeds
4. Column Structure - Expected columns exist
5. get_raw_enr() - Raw data function works
6. Data Quality - No Inf/NaN, non-negative counts
7. Aggregation - State total > 0
8. Output Fidelity - tidy=TRUE matches raw

### Running Tests:
```r
devtools::test(filter = "pipeline-live")
```

See `state-schooldata/CLAUDE.md` for complete testing framework documentation.

