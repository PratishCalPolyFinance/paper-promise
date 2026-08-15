# Chapter 4 Replication Materials

**Paper Promise: Why Good Intentions Are Strangling Section 8 Housing**  
Pratish Patel — Professor of Finance, Cal Poly San Luis Obispo

---

## Overview

This folder contains the R script used to produce all Chapter 4 figures.
The chapter examines the mismatch between the Housing Choice Voucher program
and the chronically homeless population, the limits of Housing First as a
policy model, and the arithmetic of Permanent Supportive Housing versus
crisis stabilization. The figures document the growth of chronic homelessness
in Los Angeles County, the composition of that population by disability and
veteran status, and the stagnation of California housing production over the
past decade.

---

## Scripts

| Script | Purpose |
|--------|---------|
| `Chapter4Plots.R` | Loads data from `data/`, produces all three Chapter 4 figures |

---

## Data Sources

### HUD Continuum of Care — LA County Homeless Counts
`data/HomelessCount.xlsx`  
Annual Point-in-Time counts for Los Angeles City and County Continuum of
Care (CA-600). Counts cover total chronically homeless persons, severely
mentally ill individuals, those with chronic substance abuse disorders,
and veterans. Sheltered and unsheltered breakdowns included for each group.  
Years: 2018, 2019, 2020, 2022, 2023, 2024  
Source: U.S. Department of Housing and Urban Development, Continuum of Care
Homeless Assistance Programs, CA-600 Los Angeles City & County CoC.  
[https://www.hudexchange.info/programs/coc/coc-homeless-populations-and-subpopulations-reports/](https://www.hudexchange.info/programs/coc/coc-homeless-populations-and-subpopulations-reports/)

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

### ChronicallyHomeless figure

| Variable | Source | Definition |
|----------|--------|------------|
| `category` | HomelessCount.xlsx | Population group (Total Chronically Homeless Persons; Severely Mentally Ill) |
| `Year` | HomelessCount.xlsx | Year of Point-in-Time Count observation |
| `Value` | HomelessCount.xlsx | Count of individuals in the category for that year |
| `Attribute` | HomelessCount.xlsx | Whether the count is Total or Unsheltered |

### HomelessComposition figure

| Variable | Source | Definition |
|----------|--------|------------|
| `category` | HomelessCount.xlsx | Population group (Total Chronically Homeless Persons; Severely Mentally Ill; Chronic Substance Abuse; Veterans) |
| `unsheltered` | HomelessCount.xlsx | Count sleeping outside, not in shelters |
| `total` | HomelessCount.xlsx | Total count regardless of shelter status |
| `sheltered` | Computed | `total - unsheltered` |
| `pct_unsheltered` | Computed | `round(unsheltered / total * 100)` |

### HousingUnits figure

| Variable | Source | Definition |
|----------|--------|------------|
| `year` | HOusingUnitsExcel.xlsx (col X4) | Year of observation (2014–2024) |
| `annual_permits` | HOusingUnitsExcel.xlsx (col X5) | Annual total of new private housing units authorized by building permits in California |

---

## Key Notes

- `HomelessCount.xlsx` sheet `AllData` contains an embedded wide-format
  table in columns X5 onward. The script reads only columns 1–4 to avoid
  contaminating the pivot. Do not modify the column structure of that sheet.
- 2021 is absent from the homeless count data. The HUD Continuum of Care
  did not conduct a full Point-in-Time Count in 2021 due to the COVID-19
  pandemic. This gap is reflected in the figure x-axis.
- Bar labels in `HousingUnits.png` are displayed in thousands with a `k`
  suffix for readability (e.g., `128.4k`).
- All three figures use consistent style: Crimson Text font, grayscale
  palette, labels above or inside bars, no y-axis label, dashed horizontal
  gridlines.
- The 2014 baseline in `HousingUnits.png` is shown as a dashed horizontal
  line, consistent with the book's figure style.

---

## Figures Produced

| File | Description |
|------|-------------|
| `ChronicallyHomeless.png` | Total chronically homeless and severely mentally ill individuals in LA County, 2018–2024 |
| `HomelessComposition.png` | Composition of LA County's homeless population by group, 2024 Point-in-Time Count, with unsheltered share annotated |
| `HousingUnits.png` | California housing permits, 2014–2024, with 2014 as benchmark baseline |

---

## Reproducibility Notes

- No raw HUD data download is required. `HomelessCount.xlsx` is stored in
  `data/` and tracked by version control.
- The FRED housing permits file (`HOusingUnitsExcel.xlsx`) is also stored
  in `data/` and tracked by version control.
- All figures are produced in grayscale at 300 DPI for print reproduction
  in a 6×9 book interior (5×3.5 inches).