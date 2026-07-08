# ── ui.R ──────────────────────────────────────────────────────────────────────
# Dashboard layout: header, sidebar navigation, and one tabItem per page.
# Custom styling lives in www/style.css, custom JS in www/script.js
# (both auto-served by Shiny from the www/ folder).

ui <- dashboardPage(
  skin = "black",
  dashboardHeader(
    title = tags$span(
      tags$span("Amazon", style = "color:#6c63ff; font-weight:700;"),
      tags$span(" Dashboard", style = "color:#1a1a2e; font-weight:600;")
    ),
    titleWidth = 240
  ),
  
  dashboardSidebar(
    width = 240,
    tags$div(
      style = "padding: 16px 20px 8px; border-bottom: 1px solid #f3f4f6;",
      tags$p(style = "font-size:10.5px; font-weight:700; color:#9ca3af; letter-spacing:0.8px; text-transform:uppercase; margin:0;",
             "MAIN MENU")
    ),
    sidebarMenu(
      menuItem("Overview",         tabName = "overview",     icon = icon("home")),
      menuItem("Price vs Rating",  tabName = "scatter",      icon = icon("chart-line")),
      menuItem("Bestsellers",      tabName = "bestsellers",  icon = icon("trophy")),
      menuItem("Top Categories",   tabName = "topcat",       icon = icon("chart-pie")),
      menuItem("Other Categories", tabName = "others",       icon = icon("list")),
      menuItem("Filtered Data",    tabName = "filter",       icon = icon("filter")),
      menuItem("Fake Products",    tabName = "fake",         icon = icon("exclamation-triangle")),
      menuItem("Statistics",       tabName = "statistics",   icon = icon("table")),
      menuItem("Download",         tabName = "download",     icon = icon("download"))
    )
  ),
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    
    # ── Mobile hamburger button + overlay ──────────────────────────────────────
    tags$button(id = "mobile-menu-btn", `aria-label` = "Toggle menu",
                tags$span()),
    tags$div(id = "sidebar-overlay"),
    
    tags$script(src = "script.js"),
    
    tabItems(
      
      # ── OVERVIEW ────────────────────────────────────────────────────────────
      tabItem(tabName = "overview",
              
              # KPI row
              fluidRow(
                valueBoxOutput("kpi_products",    width = 3),
                valueBoxOutput("kpi_avg_price",   width = 3),
                valueBoxOutput("kpi_avg_rating",  width = 3),
                valueBoxOutput("kpi_bestsellers", width = 3)
              ),
              
              fluidRow(
                box(title = "About the Dataset", width = 12, status = "primary", solidHeader = TRUE,
                    p("The Amazon product listings dataset contains ~1.2 million products across dozens of categories."),
                    p("Fields include: title, brand, price, list price, category, customer ratings, review counts, bestseller status, and units bought last month."),
                    p("Use the sidebar to explore brand comparisons, price vs rating relationships, bestseller patterns, and potentially fake product detection.")
                )
              ),
              
              fluidRow(
                box(title = "Data Summary", width = 4, status = "info", solidHeader = TRUE,
                    verbatimTextOutput("summary")),
                box(title = "Price Distribution", width = 4, status = "success", solidHeader = TRUE,
                    withSpinner(plotlyOutput("pricePlotOverview", height = "260px")),
                    div(style = "display:flex;gap:8px;margin-top:8px;",
                        selectInput("dlFmtPriceOV", NULL, choices = c("PNG"="png","SVG"="svg","TIFF"="tiff"), width = "90px"),
                        downloadButton("dlPriceOV", "Download", class = "btn-download"))),
                box(title = "Ratings Distribution", width = 4, status = "warning", solidHeader = TRUE,
                    withSpinner(plotlyOutput("ratingPlotOverview", height = "260px")),
                    div(style = "display:flex;gap:8px;margin-top:8px;",
                        selectInput("dlFmtRatingOV", NULL, choices = c("PNG"="png","SVG"="svg","TIFF"="tiff"), width = "90px"),
                        downloadButton("dlRatingOV", "Download", class = "btn-download")))
              ),
              
              fluidRow(
                box(title = "Filters", width = 3, status = "primary", solidHeader = TRUE,
                    selectizeInput("cat_OV", "Category:",
                                   choices = NULL, selected = NULL,
                                   options = list(placeholder = "All categories")),
                    sliderInput("price_OV", "Price Range ($):", min = 0, max = 1000, value = c(0, 500)),
                    selectInput("sort_OV", "Sort By:",
                                choices = c("A–Z" = "alpha_asc",
                                            "Price ↑" = "price_asc",
                                            "Price ↓" = "price_desc",
                                            "Rating ↓" = "ratings_desc")),
                    downloadButton("dlFilteredOV", "Download Filtered", class = "btn-download")),
                box(title = "Filtered Product Table", width = 9, status = "info", solidHeader = TRUE,
                    DTOutput("filteredTable_OV"))
              )
      ),
      
      # ── PRICE vs RATING SCATTER ─────────────────────────────────────────────
      tabItem(tabName = "scatter",
              fluidRow(
                box(title = "Filters", width = 3, status = "primary", solidHeader = TRUE,
                    selectizeInput("scatter_cat", "Category:",
                                   choices = NULL, selected = NULL,
                                   options = list(placeholder = "All categories")),
                    sliderInput("scatter_price", "Price Range ($):", min = 0, max = 1000, value = c(0, 300)),
                    sliderInput("scatter_min_reviews", "Min reviews:", min = 0, max = 5000, value = 10, step = 10),
                    numericInput("scatter_sample", "Max points to plot:", value = 3000, min = 500, max = 10000, step = 500),
                    checkboxInput("scatter_bestseller_only", "Bestsellers only", value = FALSE)
                ),
                box(title = "Price vs Rating Scatter Plot", width = 9, status = "success", solidHeader = TRUE,
                    p(style = "color:#555; font-size:13px; margin-bottom:4px;",
                      "Each dot is one product. Colour = category. Hover for details. Does higher price mean better rating?"),
                    withSpinner(plotlyOutput("scatterPlot", height = "480px")))
              )
      ),
      
      # ── BESTSELLERS ─────────────────────────────────────────────────────────
      tabItem(tabName = "bestsellers",
              fluidRow(
                valueBoxOutput("bs_kpi_count",       width = 3),
                valueBoxOutput("bs_kpi_pct",         width = 3),
                valueBoxOutput("bs_kpi_avg_price",   width = 3),
                valueBoxOutput("bs_kpi_avg_rating",  width = 3)
              ),
              fluidRow(
                box(title = "Bestseller % by Category", width = 6, status = "primary", solidHeader = TRUE,
                    withSpinner(plotlyOutput("bsCatBar", height = "380px"))),
                box(title = "Price: Bestsellers vs Non-bestsellers", width = 6, status = "success", solidHeader = TRUE,
                    withSpinner(plotlyOutput("bsPriceBox", height = "380px")))
              ),
              fluidRow(
                box(title = "Bestseller Products", width = 12, status = "info", solidHeader = TRUE,
                    DTOutput("bsTable"))
              )
      ),
      
      # ── TOP CATEGORIES ───────────────────────────────────────────────────────
      tabItem(tabName = "topcat",
              fluidRow(
                box(title = "Top 8 Product Categories", width = 8, status = "primary", solidHeader = TRUE,
                    withSpinner(plotlyOutput("topCategoryPie", height = "540px")),
                    div(style = "display:flex;gap:8px;margin-top:8px;",
                        selectInput("dlFmtPie", NULL, choices = c("PNG"="png","SVG"="svg","TIFF"="tiff"), width = "90px"),
                        downloadButton("dlPie", "Download Chart", class = "btn-download"))),
                box(title = "Category Counts", width = 4, status = "info", solidHeader = TRUE,
                    DTOutput("catCountTable"))
              )
      ),
      
      # ── OTHER CATEGORIES ─────────────────────────────────────────────────────
      tabItem(tabName = "others",
              fluidRow(
                box(title = "Other Product Categories", width = 12, status = "info", solidHeader = TRUE,
                    DTOutput("othersTable"))
              )
      ),
      
      # ── FILTERED DATA ────────────────────────────────────────────────────────
      tabItem(tabName = "filter",
              fluidRow(
                box(title = "Filters & Upload", width = 3, status = "primary", solidHeader = TRUE,
                    fileInput("user_file", "Upload CSV File(s)", accept = ".csv", multiple = TRUE),
                    radioButtons("merge_option", "Uploaded Data:",
                                 choices = c("Merge with existing" = "merge",
                                             "Replace existing"    = "replace"),
                                 selected = "merge"),
                    uiOutput("upload_feedback"),
                    selectizeInput("selected_category", "Category:",
                                   choices = NULL, selected = NULL,
                                   options = list(placeholder = "All categories")),
                    sliderInput("price_range", "Price Range ($):", min = 0, max = 1000, value = c(0, 500)),
                    selectInput("sort_by", "Sort By:",
                                choices = c("A–Z" = "alpha_asc",
                                            "Price ↑" = "price_asc",
                                            "Price ↓" = "price_desc",
                                            "Rating ↓" = "ratings_desc")),
                    uiOutput("column_selector"),
                    actionButton("clear_filters", "Clear Filters", icon = icon("undo"),
                                 class = "btn-warning", style = "margin-top:10px; width:100%;"),
                    br(),
                    downloadButton("downloadFiltered", "Download Filtered", class = "btn-download",
                                   style = "margin-top:8px; width:100%;")
                ),
                box(title = "Filtered Product Table", width = 9, status = "info", solidHeader = TRUE,
                    uiOutput("stat_filtered_info"),
                    br(),
                    DTOutput("filteredTable"))
              ),
              fluidRow(
                box(title = "Filtered Price Distribution", width = 6, status = "success", solidHeader = TRUE,
                    withSpinner(plotlyOutput("filteredPricePlot", height = "280px")),
                    div(style = "display:flex;gap:8px;margin-top:8px;",
                        selectInput("dlFmtFP", NULL, choices = c("PNG"="png","SVG"="svg","TIFF"="tiff"), width = "90px"),
                        downloadButton("dlFP", "Download", class = "btn-download"))),
                box(title = "Filtered Ratings Distribution", width = 6, status = "warning", solidHeader = TRUE,
                    withSpinner(plotlyOutput("filteredRatingPlot", height = "280px")),
                    div(style = "display:flex;gap:8px;margin-top:8px;",
                        selectInput("dlFmtFR", NULL, choices = c("PNG"="png","SVG"="svg","TIFF"="tiff"), width = "90px"),
                        downloadButton("dlFR", "Download", class = "btn-download")))
              )
      ),
      
      # ── FAKE PRODUCTS ────────────────────────────────────────────────────────
      tabItem(tabName = "fake",
              fluidRow(
                valueBoxOutput("fake_kpi_count",   width = 4),
                valueBoxOutput("fake_kpi_pct",     width = 4),
                valueBoxOutput("fake_kpi_top_cat", width = 4)
              ),
              fluidRow(
                box(title = tags$div(style="text-align:center; width:100%;", "Flag Breakdown"),
                    width = 4, status = "danger", solidHeader = TRUE,
                    withSpinner(plotlyOutput("fakeReasonBar", height = "360px")),
                    p(style = "font-size:12px; color:#888; margin-top:6px; text-align:center;",
                      "A product can trigger multiple flags. Chart shows count per flag type.")),
                box(title = "Potentially Fake Products", width = 8, status = "danger", solidHeader = TRUE,
                    p(style = "color:#7a2525; font-size:13px;",
                      "Flagged by heuristic rules. Hover the Reason(s) column for details."),
                    DTOutput("fakeTable"))
              )
      ),
      
      # ── STATISTICS ───────────────────────────────────────────────────────────
      tabItem(tabName = "statistics",
              fluidRow(
                valueBoxOutput("stat_unique_categories", width = 3),
                valueBoxOutput("stat_best_sellers",      width = 3),
                valueBoxOutput("stat_avg_price",         width = 3),
                valueBoxOutput("stat_avg_rating",        width = 3)
              ),
              fluidRow(
                box(title = "Price Statistics", width = 6, solidHeader = TRUE, status = "primary",
                    tableOutput("stat_price_table")),
                box(title = "Rating Statistics", width = 6, solidHeader = TRUE, status = "primary",
                    tableOutput("stat_rating_table"))
              ),
              fluidRow(
                box(title = "Category Breakdown", width = 12, solidHeader = TRUE, status = "info",
                    DTOutput("stat_category_breakdown"))
              )
      ),
      
      # ── DOWNLOAD ─────────────────────────────────────────────────────────────
      tabItem(tabName = "download",
              fluidRow(
                box(title = "Download Datasets", width = 6, status = "success", solidHeader = TRUE,
                    p("Download the raw or cleaned product dataset as CSV."),
                    br(),
                    downloadButton("downloadRawData", "Download Raw CSV",     class = "btn-download"),
                    br(), br(),
                    downloadButton("downloadData",    "Download Cleaned CSV", class = "btn-download"))
              )
      )
    ) # end tabItems
  )   # end dashboardBody
)     # end dashboardPage
