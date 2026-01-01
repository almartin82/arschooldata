# 10 Insights from Arkansas School Enrollment Data

``` r
library(arschooldata)
library(dplyr)
library(tidyr)
library(ggplot2)

theme_set(theme_minimal(base_size = 14))
```

This vignette explores Arkansas’s public school enrollment data,
surfacing key trends and demographic patterns across 21 years of data
(2005-2025).

------------------------------------------------------------------------

## 1. Arkansas enrollment peaked and is declining

Arkansas public school enrollment peaked around 2020 at nearly 480,000
students and has been declining since, following national trends.

``` r
enr <- fetch_enr_multi(2015:2025)

state_totals <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 2))

state_totals
```

``` r
ggplot(state_totals, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.2, color = "#CC0000") +
  geom_point(size = 3, color = "#CC0000") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(breaks = 2015:2025) +
  labs(
    title = "Arkansas Public School Enrollment (2015-2025)",
    subtitle = "Peak enrollment followed by pandemic-era decline",
    x = "School Year (ending)",
    y = "Total Enrollment"
  )
```

------------------------------------------------------------------------

## 2. Northwest Arkansas is booming

Bentonville, Rogers, Springdale, and Fayetteville are among the
fastest-growing school districts in the state, fueled by Walmart, Tyson,
and the tech corridor.

``` r
nwa_growth <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Bentonville|Rogers|Springdale|Fayetteville", district_name)) |>
  group_by(district_name) |>
  summarize(
    y2015 = n_students[end_year == 2015],
    y2025 = n_students[end_year == 2025],
    pct_change = round((y2025 / y2015 - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(desc(pct_change))

nwa_growth
```

``` r
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Bentonville|Rogers|Springdale|Fayetteville", district_name)) |>
  ggplot(aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Northwest Arkansas School District Growth",
    subtitle = "The state's economic engine is driving enrollment growth",
    x = "School Year",
    y = "Enrollment",
    color = "District"
  )
```

------------------------------------------------------------------------

## 3. COVID hit kindergarten hardest

Kindergarten enrollment dropped sharply during the pandemic as parents
delayed enrollment, creating a smaller cohort now moving through
elementary schools.

``` r
covid_grades <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09"),
         end_year %in% 2019:2023) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

covid_grades
```

------------------------------------------------------------------------

## 4. Little Rock is no longer the largest district

Springdale Public Schools has surpassed Little Rock School District to
become the state’s largest, reflecting the growth of Northwest Arkansas.

``` r
enr_2025 <- fetch_enr(2025)

top_10 <- enr_2025 |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  head(10) |>
  select(district_name, n_students)

top_10
```

``` r
top_10 |>
  mutate(district_name = forcats::fct_reorder(district_name, n_students)) |>
  ggplot(aes(x = n_students, y = district_name)) +
  geom_col(fill = "#CC0000") +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Arkansas's 10 Largest School Districts (2025)",
    x = "Total Enrollment",
    y = NULL
  )
```

------------------------------------------------------------------------

## 5. Hispanic enrollment has tripled

Hispanic students have gone from under 10% to over 15% of Arkansas
enrollment, concentrated in the poultry-processing regions of Northwest
Arkansas.

``` r
enr_full <- fetch_enr_multi(2005:2025)

hispanic_trend <- enr_full |>
  filter(is_state, subgroup == "hispanic", grade_level == "TOTAL") |>
  mutate(pct = round(pct * 100, 2)) |>
  select(end_year, n_students, pct)

hispanic_trend
```

``` r
ggplot(hispanic_trend, aes(x = end_year, y = pct)) +
  geom_line(linewidth = 1.2, color = "#2E8B57") +
  geom_point(size = 3, color = "#2E8B57") +
  labs(
    title = "Hispanic Student Enrollment Growth",
    subtitle = "From under 5% to over 15% in two decades",
    x = "School Year",
    y = "Percent of Total Enrollment"
  )
```

------------------------------------------------------------------------

## 6. The Delta is emptying out

Arkansas Delta counties have seen the sharpest enrollment declines as
agricultural mechanization reduces jobs and families move to cities.

``` r
delta <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Phillips|Lee County|Chicot|Blytheville", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  filter(n() > 5) |>
  summarize(
    earliest = n_students[end_year == min(end_year)],
    latest = n_students[end_year == max(end_year)],
    pct_change = round((latest / earliest - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(pct_change)

delta
```

------------------------------------------------------------------------

## 7. Arkansas is 63% white, 20% Black

The state’s demographics are shifting, but white students still comprise
nearly two-thirds of enrollment, with Black students concentrated in
Central and Delta regions.

``` r
demographics <- enr_2025 |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

demographics
```

``` r
demographics |>
  mutate(subgroup = forcats::fct_reorder(subgroup, n_students)) |>
  ggplot(aes(x = n_students, y = subgroup, fill = subgroup)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%")), hjust = -0.1) +
  scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Arkansas Student Demographics (2025)",
    x = "Number of Students",
    y = NULL
  )
```

------------------------------------------------------------------------

## 8. Charter school growth is accelerating

Arkansas charter schools have been growing, particularly in the Little
Rock area where district turmoil has pushed families to alternatives.

``` r
charters <- enr_2025 |>
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  head(10) |>
  select(district_name, n_students)

charters
```

------------------------------------------------------------------------

## 9. Economically disadvantaged rates exceed 60%

More than 60% of Arkansas students qualify as economically
disadvantaged, one of the highest rates in the nation.

``` r
econ <- enr_2025 |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("econ_disadv", "total_enrollment")) |>
  select(subgroup, n_students, pct)

econ
```

------------------------------------------------------------------------

## 10. Consolidation is reshaping rural Arkansas

Small rural districts are being consolidated or absorbed, with dozens of
districts having fewer than 500 students.

``` r
small <- enr_2025 |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  filter(n_students < 500) |>
  arrange(n_students) |>
  head(15) |>
  select(district_name, n_students)

small
```

------------------------------------------------------------------------

## Summary

Arkansas’s school enrollment data reveals:

- **Peak and decline**: Enrollment peaked around 2020 and is now
  declining
- **Regional divergence**: Northwest Arkansas booms while the Delta
  empties
- **Demographic shift**: Hispanic enrollment has tripled over two
  decades
- **Consolidation pressure**: Many small rural districts face uncertain
  futures
- **High poverty rates**: Over 60% economically disadvantaged

These trends have major implications for school funding formulas and
facility planning across the Natural State.

------------------------------------------------------------------------

*Data sourced from the Arkansas Department of Education [Data
Center](https://adedata.arkansas.gov/statewide/).*
