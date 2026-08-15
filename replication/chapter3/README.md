# Chapter 3 Replication Materials

**Paper Promise: Why Good Intentions Are Strangling Section 8 Housing**  
Pratish Patel — Professor of Finance, Cal Poly San Luis Obispo

---

## Overview

This folder contains the R script used to produce all Chapter 3 figures.
The chapter examines three failed strategies for fixing the voucher program:
building around landlords, compelling them through source-of-income laws,
and regulating them into compliance. The figures document the decline in
voucher success rates and the stagnation of California housing production
despite a decade of legislation.

---

## Scripts

| Script | Purpose |
|--------|---------|
| `Chapter3Plots.R` | Loads data from `data/`, produces success rate and housing permit figures |

---

## Data Sources

### NYU Furman Center — Voucher Success Rates
`data/SuccessRate.xlsx`  
Success rate is the percentage of families who received a voucher, attended
briefing, and successfully leased a unit within 12 months, weighted by
number of voucher searches at each Public Housing Agency.  
Years: 2018–2022  
Source: NYU Furman Center analysis of HUD administrative data.  
[https://www.furmancenter.org/news/calculating-success-rates-for-the-housing-choice-voucher-program-using-hud-administrative-data/](https://www.furmancenter.org/news/calculating-success-rates-for-the-housing-choice-voucher-program-using-hud-administrative-data/)

### Federal Reserve Bank of St. Louis (FRED) — California Housing Permits
`data/HOusingUnitsExcel.xlsx`  
New Private Housing Units Authorized by Building Permits for California,
monthly, not seasonally adjusted. Annual totals computed from monthly data.  
Series: `CABPPRIV`  
Years: 2014–2024  
Source: Federal Reserve Economic Data (FRED), Federal Reserve Bank of St. Louis.  
[https://fred.stlouisfed.org](https://fred.stlouisfed.org)

---

## Variables Used

### Success Rate figure

| Variable | Source | Definition |
|----------|--------|------------|
| `year` | SuccessRate.xlsx | Year of observation (2018–2022) |
| `success_rate` | SuccessRate.xlsx | Share of voucher recipients who successfully leased a unit within 12 months |

### Housing Permits figure

| Variable | Source | Definition |
|----------|--------|------------|
| `year` | HOusingUnitsExcel.xlsx (col X4) | Year of observation (2014–2024) |
| `annual_permits` | HOusingUnitsExcel.xlsx (col X5) | Annual total of new private housing units authorized by building permits in California |

---

## Key Notes

- The Housing Units Excel file contains both monthly (`CABPPRIV`) and
  pre-aggregated annual totals (columns X4 and X5). The script uses the
  annual totals directly.
- Bar labels in `HousingUnits.png` are displayed in thousands for readability.
  The y-axis label reads "Annual permits (thousands)" accordingly.
- Both figures use 2018 and 2014 as benchmark baselines respectively,
  shown as dashed horizontal lines consistent with the book's figure style.
- Both data files are included in `data/` and tracked by version control.
  They do not require re-downloading.

---

## Figures Produced

| File | Description |
|------|-------------|
| `SuccessRate4.png` | National voucher success rates, 2018–2022, with 2018 as benchmark baseline |
| `HousingUnits.png` | California housing permits, 2014–2024, with 2014 as benchmark baseline |

---

## Reproducibility Notes

- No raw HUD data is required for Chapter 3 figures.
- Both source files (`SuccessRate.xlsx`, `HOusingUnitsExcel.xlsx`) are
  stored in `data/` and committed to the repository.
- All figures are produced in grayscale at 300 DPI for print reproduction
  in a 6×9 book interior (5×3.5 inches).
- The LaTeX manuscript references these figures as `.png` files in
  `Chapter 3/Figures/`.