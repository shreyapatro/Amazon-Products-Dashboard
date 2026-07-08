# Amazon Products Dashboard

An interactive **R Shiny** dashboard for exploring an Amazon product listings
dataset — pricing, ratings, category trends, bestseller patterns, and a
rule-based fake/suspicious product detector.

## Overview

This project analyzes Amazon product data to surface insights on pricing,
customer ratings, brand performance, and category distribution, and packages
them into an interactive dashboard built with `shinydashboard`.

## Features

| Tab | What it shows |
|---|---|
| **Overview** | KPI cards, price/rating distributions, filterable product table |
| **Price vs Rating** | Scatter plot of price vs. rating, filterable by category/reviews/bestseller |
| **Bestsellers** | Bestseller rate by category, price comparison, bestseller table |
| **Top Categories** | Top 8 categories by product count (pie chart + table) |
| **Other Categories** | Breakdown of remaining categories |
| **Filtered Data** | Upload your own CSV(s), merge or replace, filter, and download |
| **Fake Products** | Heuristic-flagged products (low ratings, inconsistent data, etc.) with reason breakdown |
| **Statistics** | Summary tables for price, ratings, and category counts |
| **Download** | Export the raw or cleaned dataset as CSV |

Most charts support downloading as PNG, SVG, or TIFF directly from the UI.

## Project Structure
Amazon-Products-Dashboard/
├── global.R          # Packages, helper sourcing, one-time data load & cleaning
├── ui.R              # Dashboard layout (header, sidebar, tabs)
├── server.R          # Reactive logic: filters, plots, tables, downloads
├── R/
│   └── helpers.R      # Shared plotting/export helper functions
├── www/
│   ├── style.css       # All dashboard styling (previously inline in the R file)
│   └── script.js       # Sidebar toggle + table pagination fixes
├── data/
│   └── README.md       # Where to place the source CSVs (not tracked in git)
└── .gitignore

## Tech Stack

- **R / RStudio**
- **Shiny** & **shinydashboard** — app framework and layout
- **plotly** — interactive charts
- **DT** — interactive data tables
- **shinycssloaders** — loading spinners
- **webshot2**, **png**, **tiff** — chart export to image formats

## Getting Started

### Prerequisites

Install R (≥ 4.0) and the required packages:

```r
install.packages(c(
  "shiny", "shinydashboard", "DT", "plotly",
  "webshot2", "png", "tiff", "shinycssloaders"
))
```

`webshot2` also needs a headless Chromium install (one-time):

```r
webshot2::install_phantomjs()  # or: webshot2 uses Chromium automatically via chromote
```

### Dataset

Download the Amazon product listings dataset and place the two CSVs in
`data/` as described in [`data/README.md`](data/README.md):

- `data/amazon_products.csv`
- `data/amazon_categories.csv`

### Run the app

From the project root, in R or RStudio:

```r
shiny::runApp()
```

Or from the terminal:

```bash
Rscript -e "shiny::runApp(port = 3838)"
```

## Dataset Description

The dataset contains Amazon product listings with fields including:

- Product title, brand, category
- Price and list price
- Star rating and review count
- Bestseller flag and units bought last month

## Future Improvements

- Deploy the dashboard (e.g. shinyapps.io)
- Replace heuristic fake-product detection with a trained ML model
- Add proper NLP-based sentiment analysis on review text
- Add automated tests for the data-cleaning and filtering logic
