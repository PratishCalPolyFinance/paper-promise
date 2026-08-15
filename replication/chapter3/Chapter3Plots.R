# -------------------------------------------------------------------------
# Paper Promise: Chapter 3 Figures
# Author: Pratish Patel
# Sources: NYU Furman Center; Federal Reserve Bank of St. Louis (FRED)
# -------------------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(scales)
library(showtext)

# ---- Font ---------------------------------------------------------------
font_add_google("Crimson Text", "crimson")
showtext_auto()
showtext_opts(dpi = 300)

# -------------------------------------------------------------------------
# FIGURE 1: Voucher Success Rates 2018-2022
# -------------------------------------------------------------------------

sr <- openxlsx::read.xlsx("data/SuccessRate.xlsx") %>%
  select(year, success_rate) %>%
  filter(!is.na(year), !is.na(success_rate))

p_success <- ggplot(sr, aes(x = factor(year), y = success_rate)) +
  geom_col(fill      = "gray50",
           alpha     = 0.85,
           width     = 0.65) +
  geom_text(
    aes(label = paste0(round(success_rate * 100, 1), "%")),
    vjust  = 1.5,
    size   = 3.0,
    family = "crimson",
    color  = "white"
  ) +
  geom_hline(
    yintercept = sr$success_rate[sr$year == 2018],
    linetype   = "longdash",
    linewidth  = 0.6,
    color      = "black"
  ) +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    limits = c(0, 0.75),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title   = paste0("National voucher success rates, 2018\u20132022",
                     "\n(benchmark dashed line = 2018 baseline)"),
    x       = NULL,
    y       = "Success rate",
    caption = NULL
  ) +
  theme_minimal(base_size = 10, base_family = "crimson") +
  theme(
    plot.title          = element_text(
      family     = "crimson",
      face       = "bold",
      size       = 11,
      color      = "gray10",
      lineheight = 1.2,
      margin     = margin(b = 6)),
    plot.title.position = "plot",
    axis.text           = element_text(family = "crimson", size = 9),
    axis.title.y        = element_text(family = "crimson", size = 9,
                                       margin = margin(r = 6)),
    axis.title.x        = element_blank(),
    panel.grid.minor    = element_blank(),
    panel.grid.major.x  = element_blank(),
    panel.grid.major.y  = element_line(color     = "gray75",
                                       linewidth = 0.2,
                                       linetype  = "dashed"),
    plot.caption        = element_blank()
  )

# -------------------------------------------------------------------------
# FIGURE 2: California Housing Permits 2014-2024
# -------------------------------------------------------------------------

monthly <- openxlsx::read.xlsx("data/HOusingUnitsExcel.xlsx",
                               sheet = "Monthly") %>%
  select(Year, X4, X5) %>%
  rename(year = X4, annual_permits = X5) %>%
  filter(!is.na(year), !is.na(annual_permits)) %>%
  distinct(year, .keep_all = TRUE) %>%
  filter(year >= 2014, year <= 2024)

baseline_permits <- monthly %>%
  filter(year == 2014) %>%
  pull(annual_permits)

p_housing <- ggplot(monthly, aes(x = factor(year), y = annual_permits)) +
  geom_col(fill      = "gray50",
           alpha     = 0.85,
           width     = 0.75) +
  geom_text(
    aes(label = format(round(annual_permits / 1000), big.mark = ",")),
    vjust  = 1.5,
    size   = 2.6,
    family = "crimson",
    color  = "white"
  ) +
  geom_hline(
    yintercept = baseline_permits,
    linetype   = "longdash",
    linewidth  = 0.6,
    color      = "black"
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    title   = paste0("California housing permits, 2014\u20132024",
                     "\n(benchmark dashed line = 2014 baseline)"),
    x       = NULL,
    y       = "Annual permits (thousands)",
    caption = NULL
  ) +
  theme_minimal(base_size = 10, base_family = "crimson") +
  theme(
    plot.title          = element_text(
      family     = "crimson",
      face       = "bold",
      size       = 11,
      color      = "gray10",
      lineheight = 1.2,
      margin     = margin(b = 6)),
    plot.title.position = "plot",
    axis.text           = element_text(family = "crimson", size = 9),
    axis.title.y        = element_text(family = "crimson", size = 9,
                                       margin = margin(r = 6)),
    axis.title.x        = element_blank(),
    panel.grid.minor    = element_blank(),
    panel.grid.major.x  = element_blank(),
    panel.grid.major.y  = element_line(color     = "gray75",
                                       linewidth = 0.2,
                                       linetype  = "dashed"),
    plot.caption        = element_blank()
  )

# -------------------------------------------------------------------------
# SAVE
# -------------------------------------------------------------------------

dir.create("figures/chapter3", recursive = TRUE, showWarnings = FALSE)

ggsave("figures/chapter3/SuccessRate4.png",
       p_success, width = 5, height = 3.5, dpi = 300, bg = "white")

ggsave("figures/chapter3/HousingUnits.png",
       p_housing, width = 5, height = 3.5, dpi = 300, bg = "white")

message("Chapter 3 figures saved.")