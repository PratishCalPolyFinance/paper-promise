# -------------------------------------------------------------------------
# Paper Promise: Chapter 2 — Unused Vouchers Figure
# Author: Pratish Patel
# Source: HUD Picture of Subsidized Households
# -------------------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(scales)
library(showtext)

# ---- Font ---------------------------------------------------------------
font_add_google("Crimson Text", "crimson")
showtext_auto()
showtext_opts(dpi = 300)

# ---- Load from rawdata --------------------------------------------------
url_table <- data.frame(
  year = 2014:2024,
  file = c(
    paste0("rawdata/US_", 2014:2021, ".xlsx"),
    paste0("rawdata/US_", 2022:2024, "_2020census.xlsx")
  ),
  stringsAsFactors = FALSE
)

raw_list <- list()
for (i in seq_len(nrow(url_table))) {
  yr        <- url_table$year[i]
  file_path <- url_table$file[i]
  message("Loading: ", file_path)
  df <- openxlsx::read.xlsx(file_path) %>%
    mutate(year = yr) %>%
    filter(program == 3, total_units > 0) %>%
    mutate(across(c(total_units, pct_occupied,
                    number_reported, spending_per_month), as.numeric))
  raw_list[[as.character(yr)]] <- df
}

# ---- Aggregate ----------------------------------------------------------
unused_data <- bind_rows(raw_list) %>%
  group_by(year) %>%
  summarise(
    unused_vouchers = sum(total_units - number_reported, na.rm = TRUE),
    occupancy_rate  = weighted.mean(pct_occupied,
                                    w = total_units,
                                    na.rm = TRUE),
    .groups = "drop"
  )

# ---- Plot ---------------------------------------------------------------
p_unused <- ggplot(unused_data, aes(x = factor(year), y = unused_vouchers)) +
  geom_col(fill  = "gray50",
           alpha = 0.85,
           width = 0.75) +
  geom_text(
    aes(label = paste0(round(occupancy_rate, 1), "%")),
    vjust  = -0.5,
    size   = 2.8,
    family = "crimson",
    color  = "gray20"
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title   = paste0("Unused vouchers, 2014\u20132024",
                     "\n(occupancy rate shown above each bar)"),
    x       = NULL,
    y       = "Unused vouchers",
    caption = "Source: HUD Picture of Subsidized Households, 2014\u20132024."
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
    plot.caption        = element_text(family = "crimson",
                                       size   = 7,
                                       color  = "gray50",
                                       margin = margin(t = 6))
  )

# ---- Save ---------------------------------------------------------------
dir.create("figures/chapter2", recursive = TRUE, showWarnings = FALSE)

ggsave("figures/chapter2/UnUsedVouchers.png",
       p_unused, width = 5, height = 3.5, dpi = 300, bg = "white")

message("UnUsedVouchers.png saved.")