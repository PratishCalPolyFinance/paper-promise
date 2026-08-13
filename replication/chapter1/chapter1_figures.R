# -------------------------------------------------------------------------
# Paper Promise: Replication Script — Chapter 1 Figures
# Author: Pratish Patel
# Source: HUD Picture of Subsidized Households
# -------------------------------------------------------------------------

rm(list = ls())

library(tidyverse)
library(openxlsx)
library(scales)
library(showtext)

# -------------------------------------------------------------------------
# 0. FONT SETUP
# -------------------------------------------------------------------------

font_add_google("Crimson Text", "crimson")  # serif, readable, print-friendly
showtext_auto()
showtext_opts(dpi = 300)

# -------------------------------------------------------------------------
# 1. HELPER FUNCTION
# -------------------------------------------------------------------------

read_hud <- function(url) {
  out <- try(openxlsx::read.xlsx(url), silent = TRUE)
  if (!inherits(out, "try-error")) return(out)
  download_dir <- tempfile()
  dir.create(download_dir)
  file_name <- basename(url)
  file_path <- file.path(download_dir, file_name)
  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)
  b$Browser$setDownloadBehavior(behavior = "allow", downloadPath = download_dir)
  b$Page$navigate(url)
  for (i in 1:40) {
    Sys.sleep(0.25)
    if (file.exists(file_path) && file.info(file_path)$size > 0) break
  }
  if (!file.exists(file_path) || file.info(file_path)$size == 0) {
    stop("Could not download HUD file: ", url)
  }
  openxlsx::read.xlsx(file_path)
}

# -------------------------------------------------------------------------
# 2. LOAD FROM RAWDATA
# -------------------------------------------------------------------------

key_cols <- c("total_units", "pct_occupied", "number_reported", "spending_per_month",
              "pct_wage_major", "pct_welfare_major", "pct_2adults",
              "pct_female_head", "pct_female_head_child", "pct_disabled_all",
              "pct_minority", "rent_per_month", "hh_income", "months_from_movein")

# ---- 2005 ---------------------------------------------------------------
df_2005 <- openxlsx::read.xlsx("rawdata/2005_us.xlsx") %>%
  mutate(year = 2005) %>%
  filter(program == 3) %>%
  mutate(
    pct_wage_major    = pct_wage_maj,
    pct_welfare_major = pct_welf_maj
  ) %>%
  mutate(across(all_of(key_cols), as.numeric)) %>%
  select(all_of(key_cols), year, name) %>%
  mutate(
    total_vouchers = number_reported,
    total_spend    = sum(spending_per_month * 12 * number_reported, na.rm = TRUE)
  )

# ---- 2014–2024 ----------------------------------------------------------
url_table_mid <- data.frame(
  year = 2014:2024,
  url  = c(
    paste0("https://www.huduser.gov/portal/datasets/pictures/files/US_", 2014:2021, ".xlsx"),
    paste0("https://www.huduser.gov/portal/datasets/pictures/files/US_", 2022:2024, "_2020census.xlsx")
  ),
  stringsAsFactors = FALSE
)

raw_list <- list()
for (i in seq_len(nrow(url_table_mid))) {
  yr        <- url_table_mid$year[i]
  file_name <- basename(url_table_mid$url[i])
  file_path <- file.path("rawdata", file_name)
  message(paste("Loading:", file_path))
  df <- openxlsx::read.xlsx(file_path) %>%
    mutate(year = yr) %>%
    filter(program == 3, total_units > 0) %>%
    mutate(across(all_of(key_cols), as.numeric)) %>%
    select(all_of(key_cols), year, name) %>%
    mutate(
      total_vouchers = number_reported,
      total_spend    = sum(spending_per_month * 12 * number_reported, na.rm = TRUE)
    )
  raw_list[[as.character(yr)]] <- df
}

vouch_data_2014_2024 <- bind_rows(raw_list)

# ---- 2025 ---------------------------------------------------------------
df_2025 <- openxlsx::read.xlsx("rawdata/US_2025_2020census.xlsx") %>%
  mutate(year = 2025) %>%
  filter(program == 3, sub_program == "N/A") %>%
  mutate(across(all_of(key_cols), as.numeric)) %>%
  select(all_of(key_cols), year, name) %>%
  mutate(
    total_vouchers = number_reported,
    total_spend    = sum(spending_per_month * 12 * number_reported, na.rm = TRUE)
  )

# ---- Combine ------------------------------------------------------------
AllData <- bind_rows(df_2005, vouch_data_2014_2024, df_2025) %>%
  mutate(spending_per_year = spending_per_month * 12)

# -------------------------------------------------------------------------
# 3. SAVE CLEANED DATA
# -------------------------------------------------------------------------

write.csv(AllData, "data/AllData.csv", row.names = FALSE)
message("Cleaned data saved to data/AllData.csv")

# -------------------------------------------------------------------------
# 4. PLOT HELPER
# -------------------------------------------------------------------------

plot_vs_2005 <- function(data,
                         var,
                         y_label,
                         year_var      = year,
                         baseline_year = 2005,
                         bar_year_min  = 2014,
                         bar_year_max  = 2025,
                         caption       = NULL,
                         y_formatter   = scales::label_number()) {
  
  if (missing(y_label)) stop("You must supply y_label.")
  
  var      <- rlang::enquo(var)
  year_var <- rlang::enquo(year_var)
  
  baseline_value <- data %>%
    dplyr::filter(!!year_var == baseline_year) %>%
    dplyr::pull(!!var)
  
  if (length(baseline_value) == 0 || is.na(baseline_value[1])) {
    stop("Baseline value missing. Check baseline_year and variable.")
  }
  baseline_value <- baseline_value[1]
  
  plot_df <- data %>%
    dplyr::filter(dplyr::between(!!year_var, bar_year_min, bar_year_max)) %>%
    dplyr::arrange(!!year_var)
  
  # Concise single-line title
  full_title <- paste0(y_label, ", ", bar_year_min, "\u2013", bar_year_max,
                       "\n(benchmark dashed line = ", baseline_year, ")")
  
  ggplot2::ggplot(plot_df, ggplot2::aes(x = factor(!!year_var))) +
    ggplot2::geom_col(ggplot2::aes(y = !!var),
                      fill  = "gray50",
                      width = 0.75,
                      alpha = 0.85) +
    ggplot2::geom_hline(yintercept = baseline_value,
                        color     = "black",
                        linewidth = 0.6,
                        linetype  = "longdash") +
    ggplot2::scale_y_continuous(labels = y_formatter,
                                expand = ggplot2::expansion(mult = c(0, 0.1))) +
    ggplot2::labs(title = full_title, x = NULL, caption = caption) +
    ggplot2::theme_minimal(base_size = 11, base_family = "crimson") +
    ggplot2::theme(
      plot.title          = ggplot2::element_text(
        family     = "crimson",
        face       = "bold",        # bold
        size       = 11,            # bigger
        color      = "gray10",      # darker
        lineheight = 1.2,
        margin     = ggplot2::margin(b = 6)),
      plot.title.position = "plot",
      axis.text           = ggplot2::element_text(family = "crimson", size = 10),  # bigger
      axis.title.x        = ggplot2::element_blank(),
      axis.title.y        = ggplot2::element_blank(),
      panel.grid.minor    = ggplot2::element_blank(),
      panel.grid.major.x  = ggplot2::element_blank(),
      panel.grid.major.y  = ggplot2::element_line(color     = "gray75",  # more prominent
                                                  linewidth = 0.2, 
                                                  linetype = "dashed"),      # thicker
      plot.caption        = ggplot2::element_text(family = "crimson",
                                                  size   = 8,
                                                  color  = "gray50",
                                                  margin = ggplot2::margin(t = 6))
    )
}

# -------------------------------------------------------------------------
# 5. SAVE FIGURES — Chapter 1 only
# -------------------------------------------------------------------------

save_fig <- function(plot, filename) {
  ggsave(
    file.path("figures/chapter1", filename),
    plot,
    width  = 5,
    height = 3.5,
    dpi    = 300,
    bg     = "white"
  )
  message(paste("Saved:", filename))
}

dir.create("figures/chapter1", recursive = TRUE, showWarnings = FALSE)

save_fig(plot_vs_2005(AllData, total_vouchers,
                      y_label     = "Number of Voucher Holders",
                      y_formatter = scales::label_comma()), "total.png")

save_fig(plot_vs_2005(AllData, spending_per_year,
                      y_label     = "Annualized Spending per Voucher Holder",
                      y_formatter = scales::label_dollar()), "SpendingPerYear.png")

save_fig(plot_vs_2005(AllData, months_from_movein,
                      y_label     = "Months from Move-In",
                      y_formatter = scales::label_comma()), "tenure.png")

save_fig(plot_vs_2005(AllData, rent_per_month,
                      y_label     = "Rent Per Month (Tenant Share)",
                      y_formatter = scales::label_dollar()), "RentPerMonth.png")

save_fig(plot_vs_2005(AllData, pct_2adults,
                      y_label     = "Percent Two-Adult Families",
                      y_formatter = scales::label_percent(scale = 1)), "Percent2Adults.png")

save_fig(plot_vs_2005(AllData, pct_wage_major,
                      y_label     = "Wages as Major Source of Income",
                      y_formatter = scales::label_percent(scale = 1)), "WageMajor.png")

save_fig(plot_vs_2005(AllData, pct_occupied,
                      y_label     = "Percent Occupied",
                      y_formatter = scales::label_percent(scale = 1)), "Occupancy.png")

save_fig(plot_vs_2005(AllData, pct_female_head,
                      y_label     = "Percent Female Head of Household",
                      y_formatter = scales::label_percent(scale = 1)), "PercentFemaleHeads.png")

save_fig(plot_vs_2005(AllData, pct_disabled_all,
                      y_label     = "Percent with a Disability",
                      y_formatter = scales::label_percent(scale = 1)), "PercentDisabled.png")

message("All Chapter 1 figures saved to figures/chapter1/")