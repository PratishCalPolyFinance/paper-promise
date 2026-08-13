# Chapter 1 Replication Materials

**Paper Promise: Why Good Intentions Are Strangling Section 8 Housing**  
Pratish Patel — Professor of Finance, Cal Poly San Luis Obispo

---

## Overview

This folder contains the R scripts used to produce all Chapter 1 figures.
The analysis draws on HUD's Picture of Subsidized Households — an annual
administrative dataset covering federally assisted housing programs across
the United States.

All figures are saved to `figures/chapter1/`. The cleaned analysis dataset
is saved to `data/AllData.csv`.

---

## Scripts

| Script | Purpose |
|--------|---------|
| `RawDataDownload.R` | Downloads national-level HUD Picture files to `rawdata/` |
| `RawDataDownloadCity.R` | Downloads city-level HUD Picture file to `rawdata/` |
| `chapter1_figures.R` | Cleans data, builds `AllData.csv`, produces all national figures |
| `chapter1figures_city.R` | Produces city-level tenure figure (`Tenure_Bar.png`) |

---

## Data Source

**HUD Picture of Subsidized Households**  
U.S. Department of Housing and Urban Development  
[https://www.huduser.gov/portal/datasets/pictures.html](https://www.huduser.gov/portal/datasets/pictures.html)  
Data dictionary: [https://www.huduser.gov/portal/datasets/pictures/dictionary_2025.pdf](https://www.huduser.gov/portal/datasets/pictures/dictionary_2025.pdf)

Years used: 2005 (baseline), 2014–2025 (panel)  
Geographic levels: National (`US_`), City/Place (`PLACE_`)  
Program filter: `program == 3` (Housing Choice Vouchers only)

---

## Variables Used

| Variable | Label | Definition |
|----------|-------|------------|
| `number_reported` | Households Reported | Number of households for which HUD Form-50058 reports were received |
| `pct_occupied` | Percent Occupied | Occupied units as percent of units available under contract |
| `spending_per_month` | HUD Expenditure per Month | Average federal spending per unit-month (HAP payment plus admin cost) |
| `rent_per_month` | Family Expenditure per Month | Average gross household contribution toward rent and utilities per month |
| `hh_income` | Household Income per Year | Average total household income per year |
| `months_from_movein` | Months Since Move-In | Average months since households moved in (excludes zero values) |
| `pct_wage_major` | Wages as Major Income Source | Percent of households where majority of income is from wages or business |
| `pct_welfare_major` | Welfare as Major Income Source | Percent of households where majority of income is from TANF, General Assistance, or Public Assistance |
| `pct_2adults` | Two-Adult Families | Percent of households with two spouses and one or more children under 18 |
| `pct_female_head` | Female Head of Household | Percent of households headed by a female |
| `pct_female_head_child` | Female Head with Children | Percent of households headed by a female with children present |
| `pct_disabled_all` | Any Member with Disability | Percent of all persons in assisted households who have a disability |
| `pct_minority` | Minority Head of Household | Percent of households where head is Black, Native American, Asian/Pacific Islander, or Hispanic |
| `total_units` | Subsidized Units Available | Number of units under contract for federal subsidy and available for occupancy |

---

## Key Filters

| Filter | Reason |
|--------|--------|
| `program == 3` | Isolates Housing Choice Vouchers; excludes Public Housing, Project-Based Section 8, and other programs |
| `total_units > 0` | Removes inactive or placeholder records (applied to 2014–2024) |
| `sub_program == "N/A"` | Applied to 2025 only; isolates the aggregate voucher row, excluding MTW and PBV sub-program breakdowns added in 2025 data structure |
| `number_reported >= 1000` | Applied to city-level data; excludes very small programs where averages are unreliable |

---

## Missing Value Codes

Per HUD documentation, the following codes indicate missing or suppressed data:

| Code | Meaning |
|------|---------|
| `NA` | Not applicable |
| `-1` | Missing |
| `-4` | Suppressed (fewer than 11 reported families in cell) |
| `-5` | Non-reporting (reporting rate below 50%) |

All key variables are coerced to numeric via `as.numeric()`, which converts
these codes to `NA` and excludes them from calculations automatically.

---

## Figures Produced

| File | Description |
|------|-------------|
| `total.png` | Number of voucher holders, 2014–2025 vs. 2005 baseline |
| `SpendingPerYear.png` | Annualized federal spending per voucher holder, 2014–2025 vs. 2005 |
| `tenure.png` | Average months since move-in, 2014–2025 vs. 2005 baseline |
| `RentPerMonth.png` | Average tenant rent contribution per month, 2014–2025 vs. 2005 |
| `Percent2Adults.png` | Percent two-adult families, 2014–2025 vs. 2005 baseline |
| `WageMajor.png` | Percent with wages as major income source, 2014–2025 vs. 2005 |
| `Occupancy.png` | Percent occupied, 2014–2025 vs. 2005 baseline |
| `PercentFemaleHeads.png` | Percent female head of household, 2014–2025 vs. 2005 |
| `PercentDisabled.png` | Percent with any disability, 2014–2025 vs. 2005 baseline |
| `HHIncome.png` | Average household income, 2014–2025 vs. 2005 baseline |
| `PercentMinority.png` | Percent minority head of household, 2014–2025 vs. 2005 |
| `Tenure_Bar.png` | Average months since move-in, 20 largest voucher programs, 2024 |

---

## Reproducibility Notes

- Raw HUD files are stored locally in `rawdata/` and excluded from version
  control via `.gitignore`. They are not redistributed here due to file size.
- The cleaned analysis file `data/AllData.csv` is fully reproducible by
  running `RawDataDownload.R` followed by `chapter1_figures.R`.
- HUD periodically updates URLs and file naming conventions. The 2022–2025
  files use the `_2020census` suffix reflecting the updated census geography.
  The download scripts handle this automatically.
- All figures are produced in grayscale at 300 DPI for print reproduction
  in a 6×9 book interior (5×3.5 inches for national figures; 5×4.5 inches
  for the city tenure bar chart).