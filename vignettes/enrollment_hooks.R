## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 5
)

## ----load-packages------------------------------------------------------------
library(arschooldata)
library(dplyr)

## ----available-years----------------------------------------------------------
get_available_years()

## ----fetch-example, eval=FALSE------------------------------------------------
#  # Fetch 2024 enrollment data
#  enr_2024 <- fetch_enr(2024)
#
#  # View the structure
#  head(enr_2024)

## ----fetch-multi-example, eval=FALSE------------------------------------------
#  # Fetch 5 years of data
#  enr_multi <- fetch_enr_multi(2020:2024)
#
#  # View year counts
#  table(enr_multi$end_year)

## ----cache-status-------------------------------------------------------------
cache_status()
