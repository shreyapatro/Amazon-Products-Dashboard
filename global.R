# ── global.R ──────────────────────────────────────────────────────────────────
# Runs once when the app starts (shared across all user sessions).
# Loads required packages, helper functions, and the base product dataset.
#
# Expected data files (not included in this repo — see README for the
# dataset source): data/amazon_products.csv, data/amazon_categories.csv

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(webshot2)
library(png)
library(tiff)
library(shinycssloaders)

source("R/helpers.R")

# ── Load & clean data ────────────────────────────────────────────────────────
products   <- read.csv("data/amazon_products.csv",   stringsAsFactors = FALSE)
categories <- read.csv("data/amazon_categories.csv", stringsAsFactors = FALSE)

full_data <- merge(products, categories, by.x = "category_id", by.y = "id", all.x = TRUE)
full_data <- full_data[!duplicated(full_data$asin), ]

full_data$price            <- as.numeric(full_data$price)
full_data$listPrice        <- as.numeric(full_data$listPrice)
full_data$stars            <- as.numeric(full_data$stars)
full_data$reviews          <- as.numeric(full_data$reviews)
full_data$boughtInLastMonth <- as.numeric(full_data$boughtInLastMonth)
full_data$isBestSeller     <- tolower(full_data$isBestSeller) == "true"

full_data <- full_data[!is.na(full_data$price) & full_data$price > 0, ]
full_data <- full_data[!is.na(full_data$stars) & full_data$stars > 0, ]
full_data <- full_data[full_data$price < 1000, ]

# Clean brand: blank / NA → "Unknown"
if ("brand" %in% colnames(full_data)) {
  full_data$brand[is.na(full_data$brand) | trimws(full_data$brand) == ""] <- "Unknown"
} else {
  full_data$brand <- "Unknown"
}

