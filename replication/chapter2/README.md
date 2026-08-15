# Chapter 2 Replication Materials

**Paper Promise: Why Good Intentions Are Strangling Section 8 Housing**  
Pratish Patel — Professor of Finance, Cal Poly San Luis Obispo

---

## Overview

This folder contains the R scripts used to produce all Chapter 2 figures.
The chapter examines landlord participation in the Housing Choice Voucher
program — why landlords exit, what the administrative friction costs them,
and how local rent markets determine whether vouchers are competitive.

Figures draw on two data sources: HUD's Picture of Subsidized Households
for national utilization trends, and scraped Zillow listings matched to
HUD Small Area Fair Market Rents for the Woodhaven and Chicago comparisons.

---

## Scripts

| Script | Purpose |
|--------|---------|
| `Chapter2_UnUsedVouchers.R` | Loads national HUD data from `rawdata/`, produces unused vouchers figure |
| `Chapter2_WoodHaven_Chicago.R` | Loads scraped listing JSON files and SAFMR data, produces Woodhaven and Chicago feasibility figures |

---

## Data Sources

### HUD Picture of Subsidized Households
U.S. Department of Housing and Urban Development  
[https://www.huduser.gov/portal/datasets/pictures.html](https://www.huduser.gov/portal/datasets/pictures.html)  
Years used: 2014–2024  
Geographic level: National (`US_`)  
Program filter: `program == 3` (Housing Choice Vouchers only)

### HUD Small Area Fair Market Rents (SAFMRs)
U.S. Department of Housing and Urban Development  
[https://www.huduser.gov/portal/datasets/fmr/fmr2025/fy2025_safmrs.xlsx](https://www.huduser.gov/portal/datasets/fmr/fmr2025/fy2025_safmrs.xlsx)  
Year used: FY2025  
Joined to scraped listings by ZIP code

### Scraped Zillow Listings
Rental listings scraped from Zillow in December 2025 for two markets:
- `data/WoodhavenScrape.json` — Woodhaven, Queens (ZIP 11421 and surrounding)
- `data/ChicagoScrape.json` — Chicago metro area

These files are included in the repository. They represent a snapshot
of the rental market as of December 2025 and are not updated automatically.

---

## Variables Used

### HUD Picture (UnUsedVouchers figure)

| Variable | Label | Definition |
|----------|-------|------------|
| `total_units` | Subsidized Units Available | Units under contract for federal subsidy and available for occupancy |
| `number_reported` | Households Reported | Households for which HUD Form-50058 reports were received |
| `pct_occupied` | Percent Occupied | Occupied units as percent of units available under contract |

Unused vouchers computed as: `total_units - number_reported`  
Occupancy rate computed as weighted mean of `pct_occupied`, weighted by `total_units`

### Scraped Listings (Woodhaven and Chicago figures)

| Variable | Source | Definition |
|----------|--------|------------|
| `price` | Zillow scrape | Listed monthly rent |
| `bedrooms` | Zillow scrape | Number of bedrooms |
| `SAFMR_Used` | HUD FY2025 SAFMRs | Small Area Fair Market Rent for the listing's ZIP code and bedroom count |
| `feasibility` | Computed | `SAFMR_Used - price`; positive = voucher covers rent, negative = rent exceeds voucher |

---

## Key Filters

| Filter | Applied To | Reason |
|--------|-----------|--------|
| `program == 3` | HUD national data | Isolates Housing Choice Vouchers only |
| `total_units > 0` | HUD national data | Removes inactive records |
| `feasibility >= -2000` | Chicago listings | Removes extreme luxury outliers that distort the scale |

---

## Missing Value Codes

Per HUD documentation:

| Code | Meaning |
|------|---------|
| `NA` | Not applicable |
| `-1` | Missing |
| `-4` | Suppressed (fewer than 11 reported families) |
| `-5` | Non-reporting (reporting rate below 50%) |

---

## Figures Produced

| File | Description |
|------|-------------|
| `UnUsedVouchers.png` | Unused vouchers by year, 2014–2024, with occupancy rate annotated above each bar |
| `Woodhaven.png` | Distribution of Woodhaven listings by feasibility relative to HUD SAFMR (n = 34, December 2025) |
| `Chicago.png` | Distribution of Chicago listings by feasibility relative to HUD SAFMR (n = 1,505, December 2025) |

---

## Reproducibility Notes

- Raw HUD files are stored locally in `rawdata/` and excluded from version
  control via `.gitignore`. They can be re-downloaded using the helper
  scripts in `rawdata/`.
- The SAFMR file (`fy2025_safmrs.xlsx`) is also stored in `rawdata/` and
  excluded from version control.
- Scraped listing files (`WoodhavenScrape.json`, `ChicagoScrape.json`) are
  included in `data/` and tracked by version control. They represent a
  December 2025 snapshot and cannot be automatically refreshed.
- All figures are produced in grayscale at 300 DPI for print reproduction
  in a 6×9 book interior (5×3.5 inches).
- Light bars indicate listings where rent exceeds the voucher ceiling;
  dark bars indicate listings where the voucher covers the rent.