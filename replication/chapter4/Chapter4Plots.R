# -------------------------------------------------------------------------
# Paper Promise: Chapter 4 Figures
# Author: Pratish Patel
# Source: HUD Continuum of Care data, CA-600 Los Angeles City & County CoC
# -------------------------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(scales)
library(showtext)

# ---- Font ---------------------------------------------------------------
font_add_google("Crimson Text", "crimson")
showtext_auto()
showtext_opts(dpi = 300)

# ---- Load data ----------------------------------------------------------
df <- openxlsx::read.xlsx("./data/HomelessCount.xlsx", sheet = "AllData",
                          cols = 1:4) %>%
  rename(category = Column1) %>%
  filter(category %in% c("Total Chronically Homeless Persons",
                         "Severely Mentally Ill",
                         "Chronic Substance Abuse",
                         "Veterans")) %>%
  filter(!is.na(Year), !is.na(Value)) %>%
  mutate(Value = as.numeric(Value),
         Year  = as.numeric(Year))

# -------------------------------------------------------------------------
# FIGURE 4.1
# Short plot title — caption in LaTeX carries the full description
# Labels above bars to avoid clipping
# -------------------------------------------------------------------------

fig1_data <- df %>%
  filter(
    category %in% c("Total Chronically Homeless Persons", "Severely Mentally Ill"),
    Attribute == "Total"
  ) %>%
  mutate(
    category = factor(category,
                      levels = c("Total Chronically Homeless Persons",
                                 "Severely Mentally Ill"),
                      labels = c("Total Chronically Homeless",
                                 "Severely Mentally Ill")),
    Year = factor(Year)
  )

p_fig1 <- ggplot(fig1_data, aes(x = Year, y = Value, fill = category)) +
  geom_col(
    position = position_dodge(width = 0.72),
    width    = 0.65,
    alpha    = 0.88
  ) +
  # Labels above bars, in dark text, no clipping risk
  geom_text(
    aes(label = format(Value, big.mark = ",")),
    position = position_dodge(width = 0.72),
    vjust    = -0.4,
    size     = 2.4,
    family   = "crimson",
    color    = "gray10"
  ) +
  scale_fill_manual(
    values = c(
      "Total Chronically Homeless" = "gray30",
      "Severely Mentally Ill"      = "gray65"
    )
  ) +
  scale_y_continuous(
    labels = label_comma(),
    limits = c(0, 38000),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LA County: Chronically homeless individuals, 2018\u20132024",
    x     = NULL,
    y     = NULL,
    fill  = NULL
  ) +
  theme_minimal(base_size = 10, base_family = "crimson") +
  theme(
    plot.title          = element_text(
      family     = "crimson",
      face       = "bold",
      size       = 11,
      color      = "gray10",
      lineheight = 1.2,
      margin     = margin(b = 6)
    ),
    plot.title.position = "plot",
    axis.text           = element_text(family = "crimson", size = 9),
    axis.title.y        = element_text(family = "crimson", size = 9,
                                       margin = margin(r = 6)),
    axis.title.x        = element_blank(),
    legend.position     = "bottom",
    legend.text         = element_text(family = "crimson", size = 9),
    panel.grid.minor    = element_blank(),
    panel.grid.major.x  = element_blank(),
    panel.grid.major.y  = element_line(color     = "gray75",
                                       linewidth = 0.2,
                                       linetype  = "dashed"),
    plot.caption        = element_blank()
  )

# -------------------------------------------------------------------------
# FIGURE 4.2
# Stacked bar: Unsheltered (dark) + Sheltered (light)
# % unsheltered inside dark segment; total above bar
# X-axis labels shortened to avoid truncation
# -------------------------------------------------------------------------

fig2_data <- df %>%
  filter(Year == 2024) %>%
  pivot_wider(names_from = Attribute, values_from = Value) %>%
  rename(unsheltered = Unsheltered, total = Total) %>%
  mutate(
    sheltered       = total - unsheltered,
    pct_unsheltered = round(unsheltered / total * 100),
    category = factor(category,
                      levels = c("Total Chronically Homeless Persons",
                                 "Severely Mentally Ill",
                                 "Chronic Substance Abuse",
                                 "Veterans"),
                      # Shortened labels to prevent x-axis truncation
                      labels = c("Total\nChronically\nHomeless",
                                 "Severely\nMentally Ill",
                                 "Chronic\nSubstance\nAbuse",
                                 "Veterans"))
  )

fig2_long <- fig2_data %>%
  select(category, unsheltered, sheltered, total, pct_unsheltered) %>%
  pivot_longer(cols      = c(unsheltered, sheltered),
               names_to  = "segment",
               values_to = "count") %>%
  mutate(segment = factor(segment,
                          levels = c("sheltered", "unsheltered"),
                          labels = c("Sheltered", "Unsheltered")))

p_fig2 <- ggplot(fig2_long, aes(x = category, y = count, fill = segment)) +
  geom_col(width = 0.55, alpha = 0.88) +
  # % unsheltered inside the dark segment
  geom_text(
    data        = fig2_data,
    aes(x       = category,
        y       = unsheltered / 2,
        label   = paste0(pct_unsheltered, "%")),
    inherit.aes = FALSE,
    family      = "crimson",
    size        = 2.9,
    color       = "white",
    fontface    = "bold"
  ) +
  # Total count above each bar
  geom_text(
    data        = fig2_data,
    aes(x       = category,
        y       = total,
        label   = format(total, big.mark = ",")),
    inherit.aes = FALSE,
    vjust       = -0.4,
    family      = "crimson",
    size        = 2.9,
    color       = "gray10"
  ) +
  scale_fill_manual(
    values = c(
      "Unsheltered" = "gray30",
      "Sheltered"   = "gray70"
    )
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "LA County homeless population composition, 2024 Point-in-Time Count",
    x     = NULL,
    y     = NULL,
    fill  = NULL
  ) +
  theme_minimal(base_size = 10, base_family = "crimson") +
  theme(
    plot.title          = element_text(
      family     = "crimson",
      face       = "bold",
      size       = 11,
      color      = "gray10",
      lineheight = 1.2,
      margin     = margin(b = 6)
    ),
    plot.title.position = "plot",
    axis.text           = element_text(family = "crimson", size = 9),
    axis.text.x         = element_text(lineheight = 1.1),
    axis.title.y        = element_text(family = "crimson", size = 9,
                                       margin = margin(r = 6)),
    axis.title.x        = element_blank(),
    legend.position     = "bottom",
    legend.text         = element_text(family = "crimson", size = 9),
    panel.grid.minor    = element_blank(),
    panel.grid.major.x  = element_blank(),
    panel.grid.major.y  = element_line(color     = "gray75",
                                       linewidth = 0.2,
                                       linetype  = "dashed"),
    plot.caption        = element_blank()
  )

# -------------------------------------------------------------------------
# FIGURE 4.3: California Housing Permits 2014-2024
# -------------------------------------------------------------------------

permits <- openxlsx::read.xlsx("./data/HOusingUnitsExcel.xlsx",
                               sheet = "Monthly") %>%
  select(X4, X5) %>%
  rename(year = X4, annual_permits = X5) %>%
  filter(!is.na(year), !is.na(annual_permits)) %>%
  distinct(year, .keep_all = TRUE) %>%
  filter(year >= 2014, year <= 2024)

baseline_permits <- permits %>%
  filter(year == 2014) %>%
  pull(annual_permits)

p_fig3 <- ggplot(permits, aes(x = factor(year), y = annual_permits)) +
  geom_col(fill      = "gray50",
           alpha     = 0.85,
           width     = 0.65) +
  geom_text(
    aes(label = paste0(round(annual_permits / 1000, 1), "k")),
    vjust  = -0.4,
    size   = 2.9,
    family = "crimson",
    color  = "gray10"
  ) +
  geom_hline(
    yintercept = baseline_permits,
    linetype   = "longdash",
    linewidth  = 0.6,
    color      = "black"
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = paste0("California housing permits, 2014\u20132024",
                   "\n(benchmark dashed line = 2014 baseline)"),
    x     = NULL,
    y     = NULL
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
    axis.title.y        = element_blank(),
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

dir.create("./figures/chapter4", recursive = TRUE, showWarnings = FALSE)

ggsave("./figures/chapter4/ChronicallyHomeless.png",
       p_fig1, width = 5, height = 3.5, dpi = 300, bg = "white")

ggsave("./figures/chapter4/HomelessComposition.png",
       p_fig2, width = 5, height = 3.5, dpi = 300, bg = "white")

ggsave("./figures/chapter4/HousingUnits.png",
       p_fig3, width = 5, height = 3.5, dpi = 300, bg = "white")

message("Chapter 4 figures saved.")