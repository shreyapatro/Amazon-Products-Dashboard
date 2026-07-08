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
