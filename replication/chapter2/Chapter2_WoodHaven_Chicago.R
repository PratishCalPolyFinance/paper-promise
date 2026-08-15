# -------------------------------------------------------------------------
# Paper Promise: Chapter 2 — Woodhaven and Chicago Feasibility Figures
# Author: Pratish Patel
# Source: Scraped listings matched to HUD SAFMRs
# -------------------------------------------------------------------------

library(tidyverse)
library(jsonlite)
library(openxlsx)
library(scales)
library(showtext)
library(here)

# ---- Font ---------------------------------------------------------------
font_add_google("Crimson Text", "crimson")
showtext_auto()
showtext_opts(dpi = 300)

# ---- Helper: null coalescing --------------------------------------------
`%||%` <- function(x, y) if (is.null(x)) y else x

# ---- Load SAFMR ---------------------------------------------------------
SAFMR <- openxlsx::read.xlsx("rawdata/fy2025_safmrs.xlsx") %>%
  rename(zip = ZIP.Code)

# ---- Helper: build feasibility dataset ----------------------------------
build_feasibility <- function(json_path, city_label) {
  
  raw <- jsonlite::fromJSON(json_path, simplifyVector = FALSE)
  
  extract_bed_range <- function(beds) {
    if (is.null(beds)) return(NA_integer_)
    if (is.list(beds) && !is.null(beds$min) && !is.null(beds$max)) {
      return(seq(beds$min, beds$max))
    }
    if (is.numeric(beds)) return(as.integer(beds))
    NA_integer_
  }
  
  extract_price_pair <- function(price) {
    if (is.null(price)) return(c(NA_real_, NA_real_))
    if (is.list(price)) {
      return(c(price$min %||% NA_real_,
               price$max %||% price$min %||% NA_real_))
    }
    if (is.numeric(price)) return(c(price, price))
    c(NA_real_, NA_real_)
  }
  
  process_listing <- function(x) {
    beds      <- extract_bed_range(x$bedrooms %||% x$bedRange)
    prices    <- extract_price_pair(x$price %||% x$priceRange)
    price_min <- prices[1]
    price_max <- prices[2]
    bed_max   <- ifelse(all(is.na(beds)), NA_integer_, max(beds, na.rm = TRUE))
    tibble(
      zip      = x$zip %||% x$location$zip %||% NA_character_,
      bedrooms = beds,
      price    = ifelse(beds == bed_max, price_max, price_min)
    )
  }
  
  purrr::map_dfr(raw, process_listing) %>%
    filter(!is.na(bedrooms), !is.na(price)) %>%
    left_join(SAFMR, by = "zip") %>%
    rowwise() %>%
    mutate(
      SAFMR_Used = case_when(
        bedrooms == 0 ~ SAFMR.0BR,
        bedrooms == 1 ~ SAFMR.1BR,
        bedrooms == 2 ~ SAFMR.2BR,
        bedrooms == 3 ~ SAFMR.3BR,
        bedrooms == 4 ~ SAFMR.4BR,
        TRUE          ~ NA_real_
      )
    ) %>%
    ungroup() %>%
    mutate(
      feasibility = SAFMR_Used - price,
      city        = city_label
    ) %>%
    filter(!is.na(feasibility))
}

# ---- Load data ----------------------------------------------------------
woodhaven_df <- build_feasibility(
  here::here("data", "WoodhavenScrape.json"),
  "Woodhaven, Queens"
)

chicago_df <- build_feasibility(
  here::here("data", "ChicagoScrape.json"),
  "Chicago"
) %>%
  filter(feasibility >= -2000)

# ---- Plot helper --------------------------------------------------------
plot_histogram <- function(df,
                           city_label,
                           annot_label,
                           x_limits  = NULL,
                           binwidth  = 100) {
  
  n_listings <- nrow(df)
  
  plot_df <- df %>%
    mutate(viable = feasibility >= 0)
  
  ggplot(plot_df, aes(x = feasibility)) +
    geom_histogram(
      aes(fill = viable),
      binwidth  = binwidth,
      color     = "white",
      linewidth = 0.2
    ) +
    scale_fill_manual(
      values = c("TRUE"  = "gray40",
                 "FALSE" = "gray80"),
      labels = c("TRUE"  = "Voucher covers rent",
                 "FALSE" = "Rent exceeds voucher"),
      name   = NULL
    ) +
    geom_vline(
      xintercept = 0,
      linetype   = "longdash",
      linewidth  = 0.6,
      color      = "black"
    ) +
    annotate(
      "text",
      x      = -20,
      y      = Inf,
      label  = annot_label,
      hjust  = 1,
      vjust  = 1.3,
      size   = 2.8,
      family = "crimson",
      color  = "gray20"
    ) +
    scale_x_continuous(
      labels = label_dollar(),
      limits = x_limits,
      expand = expansion(mult = c(0.02, 0.02))
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.1))
    ) +
    labs(
      title   = paste0(city_label, ": listed rents vs. voucher ceiling",
                       "\n(benchmark dashed line = voucher maximum)"),
      x       = "Voucher ceiling minus listed rent ($ per month)",
      y       = "Number of listings",
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
      axis.title          = element_text(family = "crimson", size = 9),
      axis.title.x        = element_text(margin = margin(t = 6)),
      axis.title.y        = element_text(margin = margin(r = 6)),
      legend.position     = "bottom",
      legend.text         = element_text(family = "crimson", size = 8),
      panel.grid.minor    = element_blank(),
      panel.grid.major.x  = element_blank(),
      panel.grid.major.y  = element_line(color     = "gray75",
                                         linewidth = 0.2,
                                         linetype  = "dashed"),
      plot.caption        = element_blank()
    )
}

# ---- Compute annotation labels dynamically ------------------------------
wh_pct_above  <- round(mean(woodhaven_df$feasibility < 0) * 10)
chi_pct_below <- round(mean(chicago_df$feasibility >= 0) * 10)

wh_annot  <- paste0(wh_pct_above,  " in 10 listings exceed\nthe voucher ceiling")
chi_annot <- paste0(chi_pct_below, " in 10 listings are\naffordable with a voucher")

# ---- Build plots --------------------------------------------------------
p_woodhaven <- plot_histogram(
  woodhaven_df,
  city_label  = "Woodhaven, Queens",
  annot_label = wh_annot,
  x_limits    = c(-1500, 1500),
  binwidth    = 150
)

p_chicago <- plot_histogram(
  chicago_df,
  city_label  = "Chicago",
  annot_label = chi_annot,
  x_limits    = c(-2000, 2000),
  binwidth    = 150
)

# ---- Save ---------------------------------------------------------------
dir.create("figures/chapter2", recursive = TRUE, showWarnings = FALSE)

ggsave("figures/chapter2/Woodhaven.png",
       p_woodhaven, width = 5, height = 3.5, dpi = 300, bg = "white")

ggsave("figures/chapter2/Chicago.png",
       p_chicago, width = 5, height = 3.5, dpi = 300, bg = "white")

message("Woodhaven.png and Chicago.png saved.")