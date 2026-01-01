# arschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/arschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/arschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/arschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/arschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/arschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/arschooldata/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

Fetch and analyze Arkansas school enrollment data from the Arkansas Department of Education (ADE) in R or Python.

**[Documentation](https://almartin82.github.io/arschooldata/)** | **[10 Key Insights](https://almartin82.github.io/arschooldata/articles/enrollment_hooks.html)** | **[Getting Started](https://almartin82.github.io/arschooldata/articles/quickstart.html)**

## What can you find with arschooldata?

> **See the full analysis with charts and data output:** [10 Insights from Arkansas Enrollment Data](https://almartin82.github.io/arschooldata/articles/enrollment_hooks.html)

**21 years of enrollment data (2005-2025).** 470,000 students across 235+ districts in the Natural State. Here are ten stories hiding in the numbers:

---

### 1. Arkansas enrollment peaked and is declining

Arkansas public school enrollment peaked around 2020 at nearly 480,000 students and has been declining since, following national trends.

```r
library(arschooldata)
library(dplyr)

enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students) %>%
  mutate(change = n_students - lag(n_students))
```

![Arkansas enrollment trend](https://almartin82.github.io/arschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png)

---

### 2. Northwest Arkansas is booming

Bentonville, Rogers, Springdale, and Fayetteville are among the fastest-growing school districts in the state, fueled by Walmart, Tyson, and the tech corridor.

```r
enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Bentonville|Rogers|Springdale|Fayetteville", district_name)) %>%
  group_by(district_name) %>%
  summarize(
    y2015 = n_students[end_year == 2015],
    y2025 = n_students[end_year == 2025],
    pct_change = round((y2025 / y2015 - 1) * 100, 1)
  ) %>%
  arrange(desc(pct_change))
```

![Northwest Arkansas growth](https://almartin82.github.io/arschooldata/articles/enrollment_hooks_files/figure-html/nwa-chart-1.png)

---

### 3. COVID hit kindergarten hardest

Kindergarten enrollment dropped sharply during the pandemic as parents delayed enrollment, creating a smaller cohort now moving through elementary schools.

```r
enr <- fetch_enr_multi(2019:2023)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) %>%
  select(end_year, grade_level, n_students) %>%
  tidyr::pivot_wider(names_from = grade_level, values_from = n_students)
```

---

### 4. Little Rock is no longer the largest district

Springdale Public Schools has surpassed Little Rock School District to become the state's largest, reflecting the growth of Northwest Arkansas.

```r
enr_2025 <- fetch_enr(2025)

enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  select(district_name, n_students)
```

![Top 10 districts](https://almartin82.github.io/arschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png)

---

### 5. Hispanic enrollment has tripled

Hispanic students have gone from under 10% to over 15% of Arkansas enrollment, concentrated in the poultry-processing regions of Northwest Arkansas.

```r
enr <- fetch_enr_multi(2005:2025)

enr %>%
  filter(is_state, subgroup == "hispanic", grade_level == "TOTAL") %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, n_students, pct)
```

![Hispanic enrollment trend](https://almartin82.github.io/arschooldata/articles/enrollment_hooks_files/figure-html/hispanic-chart-1.png)

---

### 6. The Delta is emptying out

Arkansas Delta counties have seen the sharpest enrollment declines as agricultural mechanization reduces jobs and families move to cities.

```r
# Phillips, Lee, Chicot, Mississippi counties
enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Phillips|Lee County|Chicot|Blytheville", district_name, ignore.case = TRUE)) %>%
  group_by(district_name) %>%
  filter(n() > 5) %>%
  summarize(
    earliest = n_students[end_year == min(end_year)],
    latest = n_students[end_year == max(end_year)],
    pct_change = round((latest / earliest - 1) * 100, 1)
  ) %>%
  arrange(pct_change)
```

---

### 7. Arkansas is 63% white, 20% Black

The state's demographics are shifting, but white students still comprise nearly two-thirds of enrollment, with Black students concentrated in Central and Delta regions.

```r
enr_2025 %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian", "multiracial")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(subgroup, n_students, pct) %>%
  arrange(desc(n_students))
```

![Demographics breakdown](https://almartin82.github.io/arschooldata/articles/enrollment_hooks_files/figure-html/demographics-chart-1.png)

---

### 8. Charter school growth is accelerating

Arkansas charter schools have been growing, particularly in the Little Rock area where district turmoil has pushed families to alternatives.

```r
enr_2025 %>%
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  select(district_name, n_students)
```

---

### 9. Economically disadvantaged rates exceed 60%

More than 60% of Arkansas students qualify as economically disadvantaged, one of the highest rates in the nation.

```r
enr_2025 %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("econ_disadv", "total_enrollment")) %>%
  select(subgroup, n_students, pct)
```

---

### 10. Consolidation is reshaping rural Arkansas

Small rural districts are being consolidated or absorbed, with dozens of districts having fewer than 500 students.

```r
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  filter(n_students < 500) %>%
  arrange(n_students) %>%
  head(15) %>%
  select(district_name, n_students)
```

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/arschooldata")
```

## Quick start

### R

```r
library(arschooldata)
library(dplyr)

# Fetch one year
enr_2025 <- fetch_enr(2025)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2025)

# State totals
enr_2025 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# District breakdown
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students))

# Demographics
enr_2025 %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  select(subgroup, n_students, pct)
```

### Python

```python
import pyarschooldata as ar

# Check available years
years = ar.get_available_years()
print(f"Data available from {years['min_year']} to {years['max_year']}")

# Fetch one year
df = ar.fetch_enr(2025)

# Fetch multiple years
df_multi = ar.fetch_enr_multi([2020, 2021, 2022, 2023, 2024, 2025])

# State totals
state_total = df[(df['is_state'] == True) &
                 (df['subgroup'] == 'total_enrollment') &
                 (df['grade_level'] == 'TOTAL')]

# District breakdown
districts = df[(df['is_district'] == True) &
               (df['subgroup'] == 'total_enrollment') &
               (df['grade_level'] == 'TOTAL')].sort_values('n_students', ascending=False)
```

## Data availability

| Years | Source | Notes |
|-------|--------|-------|
| **2005-2025** | ADE Data Center | Enrollment by grade and demographics |
| **2006-2024** | Annual Statistical Reports | Additional detailed data |

Data is sourced from the Arkansas Department of Education Data Center.

### What's included

- **Levels:** State, district (~235), school (~1,100)
- **Demographics:** White, Black, Hispanic, Asian, American Indian, Pacific Islander, Two or More Races
- **Special populations:** Economically disadvantaged, English learners
- **Grade levels:** K-12

### Arkansas ID system

- **District IDs:** 7 digits (e.g., 0401000 = Bentonville)
- **School IDs:** 7 digits

## Data source

Arkansas Department of Education: [Data Center](https://adedata.arkansas.gov/statewide/)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
