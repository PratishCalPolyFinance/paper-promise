# -------------------------------------------------------------------------
# Paper Promise: City-Level Tenure Figure
# Author: Pratish Patel
# Source: HUD Picture of Subsidized Households, 2024
# -------------------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(scales)
library(showtext)

# ---- Font ---------------------------------------------------------------
font_add_google("Crimson Text", "crimson")
showtext_auto()
showtext_opts(dpi = 300)

# ---- Load ---------------------------------------------------------------
city_raw <- openxlsx::read.xlsx("rawdata/PLACE_2024_2020census.xlsx")

# ---- National average from saved AllData --------------------------------
AllData <- read.csv("data/AllData.csv")
national_avg <- AllData %>%
  filter(year == 2025) %>%
  pull(months_from_movein)
national_avg <- national_avg[1]

# ---- Clean: top 20 by program size --------------------------------------
city_data <- city_raw %>%
  filter(
    program == 3,
    nchar(name) >= 3,
    months_from_movein >= 0,
    number_reported >= 1000
  ) %>%
  mutate(
    city_base          = str_remove(name, "\\s+[Cc]ity,.*$"),
    state_abbr         = str_sub(states, 1, 2),
    city               = paste0(city_base, ", ", state_abbr),
    months_from_movein = as.numeric(months_from_movein),
    number_reported    = as.numeric(number_reported)
  ) %>%
  filter(!is.na(city_base)) %>%
  mutate(city = str_remove(city, "^[A-Z]{2}\\s+")) %>%
  select(city, months_from_movein, number_reported) %>%
  slice_max(number_reported, n = 20) %>%
  arrange(months_from_movein) %>%
  mutate(
    city           = factor(city, levels = city),
    true_value     = months_from_movein,
    months_from_movein = pmin(months_from_movein, 500)
  )

# ---- DC true value for label and caption --------------------------------
dc_true <- city_data %>%
  filter(grepl("Washington", city)) %>%
  pull(true_value)
dc_label <- paste0("~", round(dc_true), " \u2192")

# ---- Plot ---------------------------------------------------------------
p_tenure_city <- ggplot(city_data,
                        aes(y = city, x = months_from_movein)) +
  geom_col(fill  = "gray50",
           alpha = 0.85,
           width = 0.75) +
  # True value label for capped bars (DC)
  geom_text(
    data   = filter(city_data, true_value > 500),
    aes(x = 498, y = city, label = dc_label),
    hjust  = 1,
    size   = 2.8,
    family = "crimson",
    color  = "gray20"
  ) +
  geom_vline(xintercept = national_avg,
             linetype  = "longdash",
             linewidth = 0.6,        # back to 0.6
             color     = "black") +
  annotate("text",
           x      = national_avg + 8,
           y      = 1.5,
           label = paste0("National avg\n", round(national_avg), 
                          " months (~", round(national_avg/12, 1), " yrs)"),
           hjust  = 0,
           size   = 2.8,
           family = "crimson",
           color  = "gray20") +
  scale_x_continuous(
    limits = c(0, 500),
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title   = paste0("Average months since move-in, 20 largest voucher programs",
                     "\n(benchmark dashed line = national average)"),
    x       = "Months since move-in",
    y       = NULL,
    caption = paste0("Source: HUD Picture of Subsidized Households, 2024. ",
                     "Washington, D.C. truncated at 500; true value ~",
                     round(dc_true), " months.")
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
    axis.title.x        = element_text(family = "crimson", size = 9,
                                       margin = margin(t = 6)),
    axis.title.y        = element_blank(),
    panel.grid.minor    = element_blank(),
    panel.grid.major.y  = element_blank(),
    panel.grid.major.x  = element_line(color     = "gray85",
                                       linewidth = 0.2,
                                       linetype  = "dotted"),
    plot.caption        = element_text(family = "crimson",
                                       size   = 7,
                                       color  = "gray50",
                                       margin = margin(t = 6))
  )

# ---- Save ---------------------------------------------------------------
dir.create("figures/chapter1", recursive = TRUE, showWarnings = FALSE)

ggsave("figures/chapter1/Tenure_Bar.png",
       p_tenure_city, width = 5, height = 4.5, dpi = 300, bg = "white")


message("Tenure_Bar.png saved.")