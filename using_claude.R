library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(webshot2)
library(png)
library(tiff)
library(shinycssloaders)

# ── Custom theme CSS ────────────────────────────────────────────────────────────
custom_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

  /* ── Global font ── */
  body, .skin-black .main-header .logo, .sidebar-menu,
  .box-title, .inner, .small-box { font-family: 'Inter', sans-serif !important; }

  /* ── Page background ── */
  .content-wrapper { background-color: #f5f6fa !important; padding-top: 64px; }

  /* ── Layout ── */
  .main-sidebar { position: fixed; height: 100%; overflow-y: auto; z-index: 1000; }
  .content-wrapper, .main-footer { margin-left: 240px; }
  .main-header { position: fixed; width: 100%; z-index: 1001; }

  /* ── Header — white, clean ── */
  .main-header .logo {
    background-color: #ffffff !important;
    color: #1a1a2e !important;
    font-weight: 700 !important;
    font-size: 15px !important;
    letter-spacing: -0.2px;
    border-bottom: 1px solid #eef0f4 !important;
    border-right: 1px solid #eef0f4 !important;
    width: 240px !important;
  }
  .main-header .navbar {
    background-color: #ffffff !important;
    border-bottom: 1px solid #eef0f4 !important;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  }
  .main-header .navbar .sidebar-toggle {
    color: #6b7280 !important;
  }
  .main-header .navbar .sidebar-toggle:hover {
    color: #6c63ff !important;
    background: transparent !important;
  }
  /* Navbar right icons */
  .navbar-custom-menu .navbar-nav > li > a { color: #6b7280 !important; }

  /* ── Sidebar — white, clean ── */
  .main-sidebar, .left-side {
    background-color: #ffffff !important;
    border-right: 1px solid #eef0f4 !important;
    width: 240px !important;
    box-shadow: 2px 0 8px rgba(0,0,0,0.04);
  }
  /* Sidebar user panel */
  .sidebar-menu { padding-top: 8px; }

  /* Nav items */
  .sidebar-menu > li > a {
    color: #6b7280 !important;
    font-size: 13.5px !important;
    font-weight: 500 !important;
    padding: 11px 20px !important;
    border-left: 3px solid transparent !important;
    transition: all 0.18s ease;
    border-radius: 0 8px 8px 0;
    margin: 1px 8px 1px 0;
  }
  .sidebar-menu > li > a:hover {
    color: #6c63ff !important;
    background-color: #f0efff !important;
    border-left-color: #6c63ff !important;
  }
  .sidebar-menu > li.active > a {
    color: #6c63ff !important;
    background-color: #f0efff !important;
    border-left-color: #6c63ff !important;
    font-weight: 600 !important;
  }
  .sidebar-menu > li > a > .fa {
    color: #9ca3af;
    width: 18px;
    margin-right: 10px;
    font-size: 13px;
  }
  .sidebar-menu > li.active > a > .fa,
  .sidebar-menu > li > a:hover > .fa { color: #6c63ff !important; }

  /* Sidebar section header */
  .sidebar-menu > li.header {
    color: #9ca3af !important;
    font-size: 10.5px !important;
    font-weight: 700 !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    padding: 16px 20px 4px !important;
  }

  /* ── Boxes — white cards, no coloured headers ── */
  .box {
    background: #ffffff !important;
    border-radius: 14px !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 4px 16px rgba(0,0,0,0.04) !important;
    border: 1px solid #eef0f4 !important;
    border-top: 1px solid #eef0f4 !important;
    margin-bottom: 18px !important;
  }
  .box-header {
    background: #ffffff !important;
    border-bottom: 1px solid #f3f4f6 !important;
    border-radius: 14px 14px 0 0 !important;
    padding: 14px 20px !important;
  }
  /* All coloured headers → override to white */
  .box.box-primary > .box-header,
  .box.box-info    > .box-header,
  .box.box-success > .box-header,
  .box.box-warning > .box-header,
  .box.box-danger  > .box-header {
    background: #ffffff !important;
    color: #111827 !important;
    border-bottom: 1px solid #f3f4f6 !important;
  }
  /* Coloured top-border accent per status (left stripe effect) */
  .box.box-primary { border-top: 3px solid #6c63ff !important; }
  .box.box-info    { border-top: 3px solid #22d3ee !important; }
  .box.box-success { border-top: 3px solid #10b981 !important; }
  .box.box-warning { border-top: 3px solid #f59e0b !important; }
  .box.box-danger  { border-top: 3px solid #ef4444 !important; }

  .box-title {
    font-size: 14px !important;
    font-weight: 600 !important;
    color: #111827 !important;
    letter-spacing: -0.1px;
  }
  .box-body { padding: 16px 20px !important; }

  /* ── Value / KPI boxes — gradient cards ── */
  .small-box {
    border-radius: 14px !important;
    box-shadow: 0 4px 20px rgba(0,0,0,0.10) !important;
    transition: transform 0.18s ease, box-shadow 0.18s ease;
    overflow: hidden;
    border: none !important;
  }
  .small-box:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 28px rgba(0,0,0,0.14) !important;
  }
  .small-box .inner { padding: 18px 20px 14px !important; }
  .small-box .inner h3 {
    font-size: 28px !important;
    font-weight: 700 !important;
    letter-spacing: -0.5px;
    margin: 0 0 2px 0 !important;
  }
  .small-box .inner p {
    font-size: 12.5px !important;
    font-weight: 500 !important;
    opacity: 0.85;
    margin: 0 !important;
  }
  .small-box .icon {
    font-size: 56px !important;
    top: 14px !important;
    right: 14px !important;
    opacity: 0.18;
  }
  .small-box .small-box-footer {
    background: rgba(0,0,0,0.12) !important;
    font-size: 12px !important;
    padding: 5px 0 !important;
  }

  /* Gradient colour overrides for each AdminLTE colour */
  .bg-navy, .small-box.bg-navy   { background: linear-gradient(135deg,#1e293b,#334155) !important; color:#fff !important; }
  .bg-blue, .small-box.bg-blue   { background: linear-gradient(135deg,#6c63ff,#8b85ff) !important; color:#fff !important; }
  .bg-purple,.small-box.bg-purple{ background: linear-gradient(135deg,#7c3aed,#a78bfa) !important; color:#fff !important; }
  .bg-teal,.small-box.bg-teal    { background: linear-gradient(135deg,#0d9488,#2dd4bf) !important; color:#fff !important; }
  .bg-green,.small-box.bg-green  { background: linear-gradient(135deg,#059669,#34d399) !important; color:#fff !important; }
  .bg-yellow,.small-box.bg-yellow{ background: linear-gradient(135deg,#d97706,#fbbf24) !important; color:#fff !important; }
  .bg-orange,.small-box.bg-orange{ background: linear-gradient(135deg,#ea580c,#fb923c) !important; color:#fff !important; }
  .bg-red,.small-box.bg-red      { background: linear-gradient(135deg,#dc2626,#f87171) !important; color:#fff !important; }
  .bg-maroon,.small-box.bg-maroon{ background: linear-gradient(135deg,#9f1239,#fb7185) !important; color:#fff !important; }

  /* ── Buttons ── */
  .btn-primary {
    background: linear-gradient(135deg,#6c63ff,#8b85ff) !important;
    border: none !important;
    border-radius: 8px !important;
    font-weight: 500 !important;
    font-size: 13px !important;
    box-shadow: 0 2px 8px rgba(108,99,255,0.30) !important;
    transition: all 0.18s;
  }
  .btn-primary:hover {
    background: linear-gradient(135deg,#5b52ee,#7a74ee) !important;
    box-shadow: 0 4px 14px rgba(108,99,255,0.40) !important;
    transform: translateY(-1px);
  }
  .btn-warning { border-radius: 8px !important; font-weight: 500 !important; }
  .btn-download {
    background: linear-gradient(135deg,#059669,#10b981);
    color: #fff; border: none;
    border-radius: 8px; padding: 6px 16px; font-size: 13px;
    font-weight: 500; cursor: pointer;
    box-shadow: 0 2px 8px rgba(5,150,105,0.25);
    transition: all 0.18s;
  }
  .btn-download:hover {
    background: linear-gradient(135deg,#047857,#059669);
    box-shadow: 0 4px 12px rgba(5,150,105,0.35);
    transform: translateY(-1px);
  }

  /* ── Form controls ── */
  .form-control, .selectize-input {
    border-radius: 8px !important;
    border: 1px solid #e5e7eb !important;
    font-size: 13px !important;
    box-shadow: none !important;
    transition: border-color 0.18s, box-shadow 0.18s;
  }
  .form-control:focus, .selectize-input.focus {
    border-color: #6c63ff !important;
    box-shadow: 0 0 0 3px rgba(108,99,255,0.12) !important;
  }
  label { font-size: 12.5px !important; font-weight: 600 !important; color: #374151 !important; }
  .irs-bar, .irs-bar-edge { background: #6c63ff !important; border-top-color: #6c63ff !important; border-bottom-color: #6c63ff !important; }
  .irs-slider { background: #6c63ff !important; border-color: #6c63ff !important; }

  /* ── Tables ── */
  .dataTables_wrapper .dataTables_filter input {
    border-radius: 8px; border: 1px solid #e5e7eb;
    padding: 5px 10px; font-size: 13px;
    box-shadow: none; outline: none;
    transition: border-color 0.18s;
  }
  .dataTables_wrapper .dataTables_filter input:focus { border-color: #6c63ff; }
  table.dataTable { border-collapse: separate !important; border-spacing: 0 !important; }
  table.dataTable thead th {
    background-color: #f9fafb !important;
    color: #374151 !important;
    font-weight: 600 !important;
    font-size: 12.5px !important;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    border-bottom: 2px solid #e5e7eb !important;
    padding: 10px 14px !important;
  }
  table.dataTable tbody td { font-size: 13px !important; padding: 9px 14px !important; color: #374151; }
  table.dataTable tbody tr { background: #fff !important; }
  table.dataTable tbody tr:hover td { background-color: #f5f3ff !important; color: #1a1a2e !important; }
  table.dataTable tbody tr:nth-child(even) { background-color: #fafafa !important; }
  .dataTables_info, .dataTables_paginate { font-size: 12.5px !important; color: #6b7280 !important; }
  .paginate_button { border-radius: 6px !important; color: #374151 !important; }
  /* Current page — every selector combo to beat AdminLTE */
  .paginate_button.current,
  .paginate_button.current:hover,
  a.paginate_button.current,
  a.paginate_button.current:hover,
  .dataTables_paginate .paginate_button.current,
  .dataTables_paginate .paginate_button.current:hover,
  .dataTables_paginate span .paginate_button.current,
  .dataTables_paginate span .paginate_button.current:hover,
  div.dataTables_wrapper div.dataTables_paginate span .paginate_button.current,
  div.dataTables_wrapper div.dataTables_paginate span .paginate_button.current:hover {
    background: #6c63ff !important;
    background-image: none !important;
    background-color: #6c63ff !important;
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
    border-color: #6c63ff !important;
    font-weight: 700 !important;
    text-shadow: none !important;
    box-shadow: 0 2px 6px rgba(108,99,255,0.35) !important;
  }
  .paginate_button:not(.current):hover {
    background: #f0efff !important; color: #6c63ff !important;
    border-color: #e0dfff !important;
  }
  .dataTables_paginate .paginate_button { color: #374151 !important; }
  .dataTables_paginate .paginate_button.disabled,
  .dataTables_paginate .paginate_button.disabled:hover { color: #9ca3af !important; background: none !important; }

  /* ── Responsive / mobile sidebar ── */
  @media (max-width: 991px) {
    .content-wrapper, .main-footer { margin-left: 0 !important; transition: margin-left 0.3s; }
    .main-sidebar {
      transform: translateX(-240px);
      transition: transform 0.3s ease;
      z-index: 1050 !important;
    }
    .main-sidebar.sidebar-visible {
      transform: translateX(0) !important;
      box-shadow: 4px 0 16px rgba(0,0,0,0.15) !important;
    }
    /* Hide AdminLTE's built-in hamburger on mobile — we use our own */
    .navbar-custom-menu,
    .sidebar-toggle { display: none !important; }
    /* Overlay behind open sidebar */
    #sidebar-overlay {
      display: none;
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: rgba(0,0,0,0.35);
      z-index: 1049;
    }
    #sidebar-overlay.active { display: block; }
    /* Hamburger button */
    #mobile-menu-btn {
      display: flex !important;
      align-items: center;
      justify-content: center;
      position: fixed;
      top: 12px; left: 12px;
      width: 38px; height: 38px;
      background: #6c63ff;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      z-index: 1100;
      box-shadow: 0 2px 8px rgba(108,99,255,0.4);
    }
    #mobile-menu-btn span {
      display: block;
      width: 18px; height: 2px;
      background: #fff;
      border-radius: 2px;
      transition: all 0.25s;
      position: relative;
    }
    #mobile-menu-btn span::before,
    #mobile-menu-btn span::after {
      content: '';
      display: block;
      width: 18px; height: 2px;
      background: #fff;
      border-radius: 2px;
      position: absolute;
      left: 0;
      transition: all 0.25s;
    }
    #mobile-menu-btn span::before { top: -6px; }
    #mobile-menu-btn span::after  { top:  6px; }
    /* Animate to X when open */
    #mobile-menu-btn.open span { background: transparent; }
    #mobile-menu-btn.open span::before { transform: rotate(45deg); top: 0; }
    #mobile-menu-btn.open span::after  { transform: rotate(-45deg); top: 0; }
    /* Header: show title centred with space for hamburger */
    .content-wrapper { padding-top: 64px !important; }
    .main-header .logo {
      width: 100% !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      padding-left: 50px !important;
      padding-right: 16px !important;
      font-size: 16px !important;
      min-height: 50px;
    }
    /* Keep navbar full width behind logo */
    .main-header .navbar { margin-left: 0 !important; }
    .col-sm-3, .col-sm-4, .col-sm-6, .col-sm-8, .col-sm-9, .col-sm-12 {
      width: 100% !important; float: none !important;
    }
    .small-box { margin-bottom: 12px !important; }
    .box { margin-bottom: 14px !important; }
  }
  @media (min-width: 992px) {
    #mobile-menu-btn { display: none !important; }
    #sidebar-overlay  { display: none !important; }
    /* Restore AdminLTE hamburger on desktop */
    .sidebar-toggle { display: block !important; }
  }
  @media (max-width: 767px) {
    .content { padding: 10px !important; }
    .inner h3 { font-size: 22px !important; }
    .box-body { padding: 12px !important; }
    .btn-download { font-size: 12px !important; padding: 5px 10px !important; }
    div[style*='display:flex'] { flex-wrap: wrap !important; }
  }

  /* ── Fake products — centered box title ── */
  #fake .box-title { text-align: center !important; width: 100%; display: block; }

  /* ── Slider ── */
  .irs--shiny .irs-handle { background: #6c63ff !important; border-color: #6c63ff !important; }
  .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single {
    background: #6c63ff !important; font-size: 11px !important;
  }

  /* ── Content padding ── */
  .content { padding: 20px 22px !important; }

  /* ── Tab content spacing ── */
  .tab-content > .tab-pane { padding-top: 4px; }

  /* ── Spinner ── */
  .sk-circle .sk-child:before { background-color: #6c63ff !important; }

  /* ── Scrollbar (webkit) ── */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: #f1f1f1; }
  ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 10px; }
  ::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

  /* ── Reason badge ── */
  .reason-badge {
    display: inline-block;
    background: #fee2e2;
    color: #dc2626;
    border-radius: 5px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 600;
    margin: 1px;
    white-space: nowrap;
  }

  /* ── verbatimTextOutput (summary box) ── */
  pre {
    background: #f9fafb !important;
    border: 1px solid #e5e7eb !important;
    border-radius: 8px !important;
    font-size: 12.5px !important;
    color: #374151 !important;
    padding: 12px 14px !important;
  }

  /* ── fluid rows – tighten gap ── */
  .row { margin-left: -9px !important; margin-right: -9px !important; }
  .col-sm-1,.col-sm-2,.col-sm-3,.col-sm-4,.col-sm-6,.col-sm-8,.col-sm-9,.col-sm-12 {
    padding-left: 9px !important; padding-right: 9px !important;
  }
"

# ── UI ──────────────────────────────────────────────────────────────────────────
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
    tags$head(tags$style(HTML(custom_css))),
    
    # ── Mobile hamburger button + overlay ──────────────────────────────────────
    tags$button(id = "mobile-menu-btn", `aria-label` = "Toggle menu",
                tags$span()),
    tags$div(id = "sidebar-overlay"),
    
    tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function() {

        /* ── 1. Mobile sidebar toggle ── */
        var btn     = document.getElementById('mobile-menu-btn');
        var overlay = document.getElementById('sidebar-overlay');
        var sidebar = document.querySelector('.main-sidebar');

        function openSidebar() {
          sidebar.classList.add('sidebar-visible');
          overlay.classList.add('active');
          btn.classList.add('open');
        }
        function closeSidebar() {
          sidebar.classList.remove('sidebar-visible');
          overlay.classList.remove('active');
          btn.classList.remove('open');
        }

        if (btn) {
          btn.addEventListener('click', function() {
            sidebar.classList.contains('sidebar-visible') ? closeSidebar() : openSidebar();
          });
        }
        if (overlay) overlay.addEventListener('click', closeSidebar);

        // Auto-close sidebar when a menu tab is clicked on mobile
        document.addEventListener('click', function(e) {
          var link = e.target.closest('.sidebar-menu a');
          if (link && window.innerWidth < 992) {
            setTimeout(closeSidebar, 180);
          }
        });

        /* ── 2. Fix pagination active-button text colour ── */
        function fixPagination() {
          document.querySelectorAll('.paginate_button.current').forEach(function(el) {
            el.style.setProperty('color',            '#ffffff', 'important');
            el.style.setProperty('-webkit-text-fill-color', '#ffffff', 'important');
            el.style.setProperty('background',       '#6c63ff', 'important');
            el.style.setProperty('background-image', 'none',    'important');
            el.style.setProperty('background-color', '#6c63ff', 'important');
            el.style.setProperty('border-color',     '#6c63ff', 'important');
            el.style.setProperty('font-weight',      '700',     'important');
            // Also force any inner <a> tag
            var a = el.querySelector('a');
            if (a) {
              a.style.setProperty('color',            '#ffffff', 'important');
              a.style.setProperty('-webkit-text-fill-color', '#ffffff', 'important');
            }
          });
        }

        // Run once after a short delay (for initial tables)
        setTimeout(fixPagination, 800);

        // Watch for future DOM changes (page clicks, tab switches)
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(m) {
            if (m.addedNodes.length || m.target.className) {
              fixPagination();
            }
          });
        });
        observer.observe(document.body, { subtree: true, childList: true, attributes: true, attributeFilter: ['class'] });

        // Also fire on every pagination click
        document.addEventListener('click', function(e) {
          if (e.target.closest('.dataTables_paginate')) {
            setTimeout(fixPagination, 80);
          }
        });
      });
    ")),
    
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


# ── SERVER ──────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  # ── Load & clean data ────────────────────────────────────────────────────────
  products   <- read.csv("amazon_products.csv",   stringsAsFactors = FALSE)
  categories <- read.csv("amazon_categories.csv", stringsAsFactors = FALSE)
  
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
  
  # ── Helpers ───────────────────────────────────────────────────────────────────
  make_histogram <- function(data, xvar, nbins = 30, color = "steelblue",
                             xlimits = NULL, xbreaks = NULL) {
    plt <- plot_ly(x = data[[xvar]], type = "histogram", nbinsx = nbins,
                   marker = list(color = color),
                   hovertemplate = paste0(xvar, ": %{x}<br>Count: %{y}<extra></extra>"))
    xaxis_list <- list(title = ifelse(xvar == "price", "Price ($)", "Stars"))
    if (!is.null(xlimits)) xaxis_list$range <- xlimits
    if (!is.null(xbreaks)) xaxis_list$dtick <- xbreaks[2] - xbreaks[1]
    plt %>% layout(
      xaxis = xaxis_list,
      yaxis = list(title = "Frequency"),
      margin = list(t = 40),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)"
    )
  }
  
  save_plotly <- function(plot, file, ext) {
    fhtml <- tempfile(fileext = ".html")
    htmlwidgets::saveWidget(plot, fhtml)
    if (ext == "png") {
      webshot2::webshot(fhtml, file = file, vwidth = 800, vheight = 600)
    } else if (ext == "svg") {
      webshot2::webshot(fhtml, file = file, vwidth = 800, vheight = 600, filetype = "svg")
    } else if (ext == "tiff") {
      tf_png <- tempfile(fileext = ".png")
      webshot2::webshot(fhtml, file = tf_png, vwidth = 800, vheight = 600)
      img <- png::readPNG(tf_png)
      tiff::writeTIFF(img, file)
    }
  }
  
  # ── Multi-file upload & merge ─────────────────────────────────────────────────
  merged_data <- reactive({
    user_files <- input$user_file
    merge_opt  <- input$merge_option
    required_cols <- c("title", "category_name", "price", "stars", "reviews", "isBestSeller")
    
    if (is.null(user_files)) return(full_data)
    
    all_user_data <- list()
    feedback <- data.frame(File = character(), Size = character(),
                           Rows = integer(), Columns = integer(),
                           Status = character(), stringsAsFactors = FALSE)
    
    for (i in seq_len(nrow(user_files))) {
      fname  <- user_files$name[i]
      fsize  <- user_files$size[i]
      rsz    <- ifelse(fsize >= 1e6, sprintf("%.2f MB", fsize/1e6),
                       ifelse(fsize >= 1e3, sprintf("%.2f KB", fsize/1e3), paste0(fsize, " B")))
      
      tryCatch({
        df <- read.csv(user_files$datapath[i], stringsAsFactors = FALSE)
        if (!all(required_cols %in% colnames(df))) stop("Missing required columns.")
        df$price      <- as.numeric(df$price)
        df$stars      <- as.numeric(df$stars)
        df$reviews    <- as.numeric(df$reviews)
        df$isBestSeller <- tolower(df$isBestSeller) == "true"
        feedback <<- rbind(feedback, data.frame(File = fname, Size = rsz,
                                                Rows = nrow(df), Columns = ncol(df),
                                                Status = "OK", stringsAsFactors = FALSE))
        all_user_data[[length(all_user_data) + 1]] <- df[, required_cols]
      }, error = function(e) {
        feedback <<- rbind(feedback, data.frame(File = fname, Size = rsz,
                                                Rows = NA, Columns = NA,
                                                Status = paste("Error:", e$message),
                                                stringsAsFactors = FALSE))
      })
    }
    
    attr(full_data, "upload_feedback") <- feedback
    if (length(all_user_data) == 0) return(full_data)
    
    user_merged <- do.call(rbind, all_user_data)
    if (merge_opt == "replace") {
      attr(user_merged, "upload_feedback") <- feedback
      return(user_merged)
    }
    merged <- rbind(full_data[, required_cols], user_merged)
    attr(merged, "upload_feedback") <- feedback
    merged
  })
  
  output$upload_feedback <- renderUI({
    user_files <- input$user_file
    data_obj   <- merged_data()
    feedback   <- attr(data_obj, "upload_feedback")
    if (!is.null(user_files) && !is.null(feedback)) {
      tagList(
        tags$h5("Upload Summary:"),
        DT::datatable(feedback, rownames = FALSE,
                      options = list(dom = "t", paging = FALSE, ordering = FALSE))
      )
    }
  })
  
  # ── Category choices ───────────────────────────────────────────────────────
  observe({
    cats <- sort(unique(full_data$category_name))
    updateSelectizeInput(session, "selected_category",   choices = cats, server = TRUE)
    updateSelectizeInput(session, "cat_OV",              choices = cats, server = TRUE)
    updateSelectizeInput(session, "scatter_cat",         choices = cats, server = TRUE)
  })
  
  # ── Column selector (filter tab) ──────────────────────────────────────────
  output$column_selector <- renderUI({
    data <- merged_data()
    if (!is.null(data) && nrow(data) > 0) {
      selectizeInput("selected_columns", "Columns to show/download:",
                     choices = colnames(data), selected = colnames(data), multiple = TRUE,
                     options = list(plugins = list("remove_button", "drag_drop")))
    }
  })
  
  # ── Filter logic ──────────────────────────────────────────────────────────
  filter_defaults <- reactiveValues(category = "", price = c(0, 500), sort_by = "alpha_asc")
  
  observeEvent(input$clear_filters, {
    updateSelectizeInput(session, "selected_category", selected = "")
    updateSliderInput(session, "price_range", value = filter_defaults$price)
    updateSelectInput(session, "sort_by", selected = filter_defaults$sort_by)
    updateSelectizeInput(session, "selected_columns", selected = colnames(merged_data()))
  })
  
  apply_filters <- function(data, cat_in, price_in, sort_in) {
    if (!is.null(cat_in) && cat_in != "")
      data <- data[data$category_name == cat_in, ]
    data <- data[data$price >= price_in[1] & data$price <= price_in[2], ]
    data <- switch(sort_in,
                   alpha_asc   = data[order(tolower(data$title)), ],
                   price_asc   = data[order(data$price), ],
                   price_desc  = data[order(-data$price), ],
                   ratings_desc = data[order(-data$stars), ],
                   data
    )
    data
  }
  
  filtered_data <- reactive({
    data <- merged_data()
    req(data)
    data <- apply_filters(data, input$selected_category, input$price_range, input$sort_by)
    if (!is.null(input$selected_columns))
      data <- data[, input$selected_columns, drop = FALSE]
    data
  })
  
  filtered_data_OV <- reactive({
    apply_filters(full_data, input$cat_OV, input$price_OV, input$sort_OV)
  })
  
  # ── Overview KPIs ─────────────────────────────────────────────────────────
  output$kpi_products <- renderValueBox({
    valueBox(format(nrow(full_data), big.mark = ","),
             "Total Products", icon = icon("box-open"),
             color = "navy")
  })
  output$kpi_avg_price <- renderValueBox({
    valueBox(sprintf("$%.2f", mean(full_data$price, na.rm = TRUE)),
             "Avg Price", icon = icon("dollar-sign"), color = "blue")
  })
  output$kpi_avg_rating <- renderValueBox({
    valueBox(sprintf("%.2f ★", mean(full_data$stars, na.rm = TRUE)),
             "Avg Rating", icon = icon("star"), color = "purple")
  })
  output$kpi_bestsellers <- renderValueBox({
    pct <- 100 * sum(full_data$isBestSeller, na.rm = TRUE) / nrow(full_data)
    valueBox(sprintf("%.1f%%", pct),
             "Bestseller Share", icon = icon("trophy"), color = "teal")
  })
  
  # ── Overview summary ─────────────────────────────────────────────────────
  output$summary <- renderPrint({
    cat("Products     :", format(nrow(full_data), big.mark = ","), "\n")
    cat("Categories   :", length(unique(full_data$category_name)), "\n")
    cat("Avg Price    : $", round(mean(full_data$price,   na.rm = TRUE), 2), "\n")
    cat("Avg Rating   :", round(mean(full_data$stars,    na.rm = TRUE), 2), "stars\n")
    cat("Bestsellers  :", sum(full_data$isBestSeller, na.rm = TRUE), "\n")
    cat("Avg Reviews  :", round(mean(full_data$reviews, na.rm = TRUE), 0), "\n")
    if ("brand" %in% colnames(full_data))
      cat("Unique Brands:", length(unique(full_data$brand[full_data$brand != "Unknown"])), "\n")
  })
  
  # ── Overview plots ────────────────────────────────────────────────────────
  output$pricePlotOverview  <- renderPlotly({ make_histogram(full_data, "price",  7, "#6c63ff", c(0,350)) })
  output$ratingPlotOverview <- renderPlotly({ make_histogram(full_data, "stars",  5, "#10b981") })
  
  output$dlPriceOV  <- downloadHandler("price_dist.png",
                                       content = function(f) save_plotly(make_histogram(full_data, "price", 7, "#6c63ff", c(0,350)), f, input$dlFmtPriceOV))
  output$dlRatingOV <- downloadHandler("rating_dist.png",
                                       content = function(f) save_plotly(make_histogram(full_data, "stars", 5, "#10b981"), f, input$dlFmtRatingOV))
  
  # ── Overview filtered table ───────────────────────────────────────────────
  output$filteredTable_OV <- renderDT({
    d <- filtered_data_OV()[, c("title","category_name","price","stars","reviews","isBestSeller")]
    d$title <- ifelse(nchar(d$title) > 60, paste0(substr(d$title,1,57),"..."), d$title)
    datatable(d, options = list(pageLength=10, autoWidth=TRUE, scrollX=TRUE,
                                searchHighlight=TRUE),
              filter = "top", rownames = FALSE)
  }, server = TRUE)
  
  output$dlFilteredOV <- downloadHandler("filtered_overview.csv",
                                         content = function(f) write.csv(filtered_data_OV(), f, row.names = FALSE))
  
  # ── SCATTER: Price vs Rating ───────────────────────────────────────────────
  scatter_data <- reactive({
    d <- full_data
    if (!is.null(input$scatter_cat) && input$scatter_cat != "")
      d <- d[d$category_name == input$scatter_cat, ]
    d <- d[d$price  >= input$scatter_price[1]  & d$price  <= input$scatter_price[2], ]
    d <- d[!is.na(d$reviews) & d$reviews >= input$scatter_min_reviews, ]
    if (input$scatter_bestseller_only) d <- d[d$isBestSeller == TRUE, ]
    if (nrow(d) > input$scatter_sample)
      d <- d[sample(nrow(d), input$scatter_sample), ]
    d
  })
  
  output$scatterPlot <- renderPlotly({
    d <- scatter_data()
    validate(need(nrow(d) > 0, "No products match the current filters."))
    
    # Limit to top 10 categories for a clean colour legend
    top_cats <- names(sort(table(d$category_name), decreasing = TRUE))[1:min(10, length(unique(d$category_name)))]
    d$cat_label <- ifelse(d$category_name %in% top_cats, d$category_name, "Other")
    
    plot_ly(d, x = ~price, y = ~stars, color = ~cat_label,
            type = "scatter", mode = "markers",
            marker = list(opacity = 0.55, size = 6),
            hovertemplate = paste0(
              "<b>%{text}</b><br>Price: $%{x:.2f}<br>Rating: %{y:.1f} ★<extra></extra>"
            ),
            text = ~substr(title, 1, 50)) %>%
      layout(
        xaxis = list(title = "Price ($)"),
        yaxis = list(title = "Rating (★)", range = c(0.5, 5.5)),
        legend = list(title = list(text = "Category"), orientation = "v"),
        margin = list(t = 20),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor  = "rgba(0,0,0,0)"
      )
  })
  
  # ── BESTSELLERS ───────────────────────────────────────────────────────────
  bs_data <- reactive({ full_data[full_data$isBestSeller == TRUE, ] })
  
  output$bs_kpi_count <- renderValueBox({
    valueBox(format(nrow(bs_data()), big.mark = ","),
             "Total Bestsellers", icon = icon("trophy"), color = "orange")
  })
  output$bs_kpi_pct <- renderValueBox({
    pct <- 100 * nrow(bs_data()) / nrow(full_data)
    valueBox(sprintf("%.1f%%", pct),
             "of All Products", icon = icon("percent"), color = "blue")
  })
  output$bs_kpi_avg_price <- renderValueBox({
    valueBox(sprintf("$%.2f", mean(bs_data()$price, na.rm = TRUE)),
             "Bestseller Avg Price", icon = icon("dollar-sign"), color = "green")
  })
  output$bs_kpi_avg_rating <- renderValueBox({
    valueBox(sprintf("%.2f ★", mean(bs_data()$stars, na.rm = TRUE)),
             "Bestseller Avg Rating", icon = icon("star"), color = "purple")
  })
  
  output$bsCatBar <- renderPlotly({
    cat_counts <- as.data.frame(table(full_data$category_name),    stringsAsFactors = FALSE)
    bs_counts  <- as.data.frame(table(bs_data()$category_name),   stringsAsFactors = FALSE)
    names(cat_counts) <- c("cat", "total")
    names(bs_counts)  <- c("cat", "bs")
    d <- merge(cat_counts, bs_counts, by = "cat", all.x = TRUE)
    d$bs[is.na(d$bs)] <- 0
    d$pct <- round(100 * d$bs / d$total, 1)
    d <- d[order(-d$pct), ]
    d <- head(d, 20)
    d$cat <- factor(d$cat, levels = rev(d$cat))
    
    plot_ly(d, x = ~pct, y = ~cat, type = "bar", orientation = "h",
            marker = list(color = "#6c63ff"),
            hovertemplate = "<b>%{y}</b><br>%{x:.1f}% bestsellers<extra></extra>") %>%
      layout(
        xaxis = list(
          title = "",
          ticksuffix = "%",
          automargin = TRUE
        ),
        yaxis = list(title = "", automargin = TRUE),
        margin = list(l = 10, r = 20, t = 20, b = 30),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor  = "rgba(0,0,0,0)"
      ) %>%
      config(responsive = TRUE)
  })
  
  output$bsPriceBox <- renderPlotly({
    d <- full_data
    d$group <- ifelse(d$isBestSeller, "Bestseller", "Non-bestseller")
    plot_ly(d, x = ~group, y = ~price, type = "box",
            color = ~group,
            colors = c("Bestseller" = "#6c63ff", "Non-bestseller" = "#e5e7eb"),
            boxpoints = FALSE,
            hovertemplate = "%{y:.2f}<extra></extra>") %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = "Price ($)", range = c(0, 300)),
        showlegend = FALSE,
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor  = "rgba(0,0,0,0)"
      )
  })
  
  output$bsTable <- renderDT({
    d <- bs_data()[, c("title","category_name","brand","price","stars","reviews","boughtInLastMonth")]
    d$title <- ifelse(nchar(d$title) > 60, paste0(substr(d$title,1,57),"..."), d$title)
    colnames(d) <- c("Title","Category","Brand","Price ($)","Rating","Reviews","Bought Last Month")
    datatable(d, options = list(pageLength=10, scrollX=TRUE, searchHighlight=TRUE),
              filter = "top", rownames = FALSE)
  }, server = TRUE)
  
  # ── TOP CATEGORIES ────────────────────────────────────────────────────────
  output$topCategoryPie <- renderPlotly({
    cat_counts <- sort(table(full_data$category_name), decreasing = TRUE)
    top8       <- head(cat_counts, 8)
    other_cnt  <- sum(cat_counts) - sum(top8)
    labels <- c(names(top8), "Others")
    values <- c(as.numeric(top8), other_cnt)
    
    plot_ly(labels = labels, values = values, type = "pie",
            textinfo = "none",
            hoverinfo = "label+percent+value",
            domain = list(x = c(0, 1), y = c(0.15, 1)),
            marker = list(
              colors = c("#6c63ff","#10b981","#f59e0b","#22d3ee",
                         "#7c3aed","#ef4444","#059669","#0891b2","#9ca3af"),
              line = list(color = "#fff", width = 1.5)
            )) %>%
      layout(
        showlegend = TRUE,
        legend = list(
          orientation = "h",
          x = 0.5, xanchor = "center",
          y = 0.02, yanchor = "bottom",
          font = list(size = 11)
        ),
        margin = list(t = 20, b = 10, l = 10, r = 10),
        paper_bgcolor = "rgba(0,0,0,0)"
      )
  })
  
  output$catCountTable <- renderDT({
    cat_counts <- sort(table(full_data$category_name), decreasing = TRUE)
    d <- data.frame(Category = names(cat_counts),
                    Count = as.integer(cat_counts), stringsAsFactors = FALSE)
    datatable(d, options = list(pageLength = 15), rownames = FALSE)
  })
  
  output$dlPie <- downloadHandler("top_categories.png",
                                  content = function(f) {
                                    plt <- plot_ly(labels = c(names(head(sort(table(full_data$category_name), decreasing=TRUE),8)),"Others"),
                                                   values = c(as.numeric(head(sort(table(full_data$category_name), decreasing=TRUE),8)),
                                                              nrow(full_data) - sum(head(sort(table(full_data$category_name), decreasing=TRUE),8))),
                                                   type = "pie")
                                    save_plotly(plt, f, input$dlFmtPie)
                                  })
  
  # ── OTHER CATEGORIES ──────────────────────────────────────────────────────
  output$othersTable <- renderDT({
    cat_counts <- sort(table(full_data$category_name), decreasing = TRUE)
    others     <- names(cat_counts)[-(1:8)]
    d <- full_data[full_data$category_name %in% others,
                   c("title","category_name","price","stars","reviews")]
    d$title <- ifelse(nchar(d$title) > 60, paste0(substr(d$title,1,57),"..."), d$title)
    datatable(d, options = list(
      pageLength = 10,
      scrollX    = TRUE,
      dom        = '<"top"flp>rt<"bottom"ip>',
      language   = list(search = "Search:")
    ), rownames = FALSE)
  }, server = TRUE)
  
  # ── FILTERED DATA TAB ────────────────────────────────────────────────────
  output$filteredTable <- renderDT({
    data <- filtered_data()
    validate(need(nrow(data) > 0, "No products match the current filters."))
    datatable(data,
              options = list(pageLength = 10, autoWidth = TRUE, scrollX = TRUE,
                             dom = "Bfrtip", buttons = list("colvis"),
                             searchHighlight = TRUE),
              filter = "top", rownames = FALSE, extensions = "Buttons")
  }, server = TRUE)
  
  output$stat_filtered_info <- renderUI({
    s <- nrow(filtered_data()); t <- nrow(merged_data())
    HTML(sprintf("<span style='font-size:13px;'>Showing <b>%s</b> of <b>%s</b> products (%.1f%%)</span>",
                 format(s, big.mark=","), format(t, big.mark=","), 100*s/t))
  })
  
  output$filteredPricePlot  <- renderPlotly({ make_histogram(filtered_data(), "price", 7, "#6c63ff", c(0,350)) })
  output$filteredRatingPlot <- renderPlotly({ make_histogram(filtered_data(), "stars", 5, "#10b981") })
  
  output$dlFP <- downloadHandler("filtered_price.png",
                                 content = function(f) save_plotly(make_histogram(filtered_data(),"price",7,"#6c63ff",c(0,350)), f, input$dlFmtFP))
  output$dlFR <- downloadHandler("filtered_rating.png",
                                 content = function(f) save_plotly(make_histogram(filtered_data(),"stars",5,"#10b981"), f, input$dlFmtFR))
  
  output$downloadFiltered <- downloadHandler("filtered_products.csv",
                                             content = function(f) write.csv(filtered_data(), f, row.names = FALSE))
  
  # ── FAKE PRODUCTS ─────────────────────────────────────────────────────────
  suspect_keywords <- c("100% original","authentic","genuine","guaranteed","real original")
  
  fake_flagged <- reactive({
    d <- full_data
    
    d$flag_keyword    <- grepl(paste(suspect_keywords, collapse = "|"), tolower(d$title))
    d$flag_hi_rat_few <- d$stars >= 4.5 & !is.na(d$reviews) & d$reviews <= 5
    d$flag_bs_low_sal <- d$isBestSeller & !is.na(d$boughtInLastMonth) & d$boughtInLastMonth <= 2
    d$flag_cheap_hi   <- d$price < 10 & d$stars >= 4.7
    d$flag_big_disc   <- !is.na(d$listPrice) & d$listPrice > 0 & (d$price / d$listPrice < 0.5)
    
    d <- d[d$flag_keyword | d$flag_hi_rat_few | d$flag_bs_low_sal |
             d$flag_cheap_hi | d$flag_big_disc, ]
    
    # Build a human-readable reason string per row
    d$Reasons <- apply(d[, c("flag_keyword","flag_hi_rat_few","flag_bs_low_sal",
                             "flag_cheap_hi","flag_big_disc")], 1, function(r) {
                               labels <- c("Suspicious keywords", "High rating / few reviews",
                                           "Bestseller with low sales", "Cheap + very high rating",
                                           "Big discount (>50%)")
                               paste(labels[as.logical(r)], collapse = " | ")
                             })
    d
  })
  
  output$fake_kpi_count <- renderValueBox({
    valueBox(format(nrow(fake_flagged()), big.mark = ","),
             "Flagged Products", icon = icon("exclamation-triangle"), color = "red")
  })
  output$fake_kpi_pct <- renderValueBox({
    pct <- 100 * nrow(fake_flagged()) / nrow(full_data)
    valueBox(sprintf("%.2f%%", pct),
             "of Dataset", icon = icon("percent"), color = "orange")
  })
  output$fake_kpi_top_cat <- renderValueBox({
    top <- names(sort(table(fake_flagged()$category_name), decreasing = TRUE))[1]
    valueBox(ifelse(is.na(top), "N/A", top),
             "Most Flagged Category", icon = icon("tag"), color = "purple")
  })
  
  output$fakeReasonBar <- renderPlotly({
    d <- fake_flagged()
    flag_cols  <- c("flag_keyword","flag_hi_rat_few","flag_bs_low_sal","flag_cheap_hi","flag_big_disc")
    flag_names <- c("Keywords","High rating\n/ few reviews","Bestseller\n+ low sales",
                    "Cheap +\nhigh rating","Big\ndiscount")
    counts <- sapply(flag_cols, function(col) sum(d[[col]], na.rm = TRUE))
    df <- data.frame(Reason = flag_names, Count = counts, stringsAsFactors = FALSE)
    df <- df[order(df$Count), ]
    df$Reason <- factor(df$Reason, levels = df$Reason)
    
    plot_ly(df, x = ~Count, y = ~Reason, type = "bar", orientation = "h",
            marker = list(color = "#ef4444", line = list(color = "#c53030", width = 0.5)),
            hovertemplate = "<b>%{y}</b><br>%{x:,} products<extra></extra>") %>%
      layout(
        xaxis = list(
          title = list(text = "Flagged products", standoff = 10),
          tickformat = "~s",
          automargin = TRUE
        ),
        yaxis = list(title = "", automargin = TRUE),
        margin = list(l = 10, r = 20, t = 20, b = 60),
        autosize = TRUE,
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor  = "rgba(0,0,0,0)"
      ) %>%
      config(responsive = TRUE)
  })
  
  output$fakeTable <- renderDT({
    d <- fake_flagged()
    d$title <- ifelse(nchar(d$title) > 60, paste0(substr(d$title,1,57),"..."), d$title)
    display_cols <- c("title","category_name","brand","price","stars","reviews","isBestSeller","Reasons")
    display_cols <- display_cols[display_cols %in% colnames(d)]
    out <- d[, display_cols]
    colnames(out)[colnames(out) == "title"]         <- "Title"
    colnames(out)[colnames(out) == "category_name"] <- "Category"
    colnames(out)[colnames(out) == "brand"]         <- "Brand"
    colnames(out)[colnames(out) == "price"]         <- "Price ($)"
    colnames(out)[colnames(out) == "stars"]         <- "Rating"
    colnames(out)[colnames(out) == "reviews"]       <- "Reviews"
    colnames(out)[colnames(out) == "isBestSeller"]  <- "Bestseller?"
    
    datatable(out,
              options = list(pageLength = 10, scrollX = TRUE,
                             searchHighlight = TRUE,
                             columnDefs = list(
                               list(targets = ncol(out) - 1, width = "300px")
                             )),
              filter = "top", rownames = FALSE, escape = FALSE)
  }, server = TRUE)
  
  # ── STATISTICS ────────────────────────────────────────────────────────────
  stat_all <- reactive({
    d <- merged_data()
    list(
      n_categories    = length(unique(d$category_name)),
      n_products      = nrow(d),
      avg_price       = mean(d$price,  na.rm = TRUE),
      min_price       = min(d$price,   na.rm = TRUE),
      max_price       = max(d$price,   na.rm = TRUE),
      median_price    = median(d$price, na.rm = TRUE),
      avg_rating      = mean(d$stars,  na.rm = TRUE),
      min_rating      = min(d$stars,   na.rm = TRUE),
      max_rating      = max(d$stars,   na.rm = TRUE),
      median_rating   = median(d$stars, na.rm = TRUE),
      n_best_seller   = sum(d$isBestSeller, na.rm = TRUE),
      pct_best_seller = 100 * sum(d$isBestSeller, na.rm = TRUE) / nrow(d)
    )
  })
  
  output$stat_unique_categories <- renderValueBox({
    valueBox(stat_all()$n_categories, "Categories", icon = icon("tags"), color = "navy")
  })
  output$stat_best_sellers <- renderValueBox({
    valueBox(format(stat_all()$n_best_seller, big.mark = ","),
             "Bestsellers", icon = icon("star"), color = "purple")
  })
  output$stat_avg_price <- renderValueBox({
    valueBox(sprintf("$%.2f", stat_all()$avg_price),
             "Avg Price", icon = icon("dollar-sign"), color = "green")
  })
  output$stat_avg_rating <- renderValueBox({
    valueBox(sprintf("%.2f ★", stat_all()$avg_rating),
             "Avg Rating", icon = icon("star-half-alt"), color = "teal")
  })
  
  output$stat_price_table <- renderTable({
    s <- stat_all()
    data.frame(
      Statistic = c("Average","Minimum","Maximum","Median"),
      Price     = sprintf("$%.2f", c(s$avg_price, s$min_price, s$max_price, s$median_price)),
      row.names = NULL
    )
  })
  
  output$stat_rating_table <- renderTable({
    s <- stat_all()
    data.frame(
      Statistic = c("Average","Minimum","Maximum","Median"),
      Rating    = round(c(s$avg_rating, s$min_rating, s$max_rating, s$median_rating), 2),
      row.names = NULL
    )
  })
  
  output$stat_category_breakdown <- renderDT({
    d <- merged_data()
    
    # One row per category, clean numeric columns
    cnt   <- as.data.frame(table(d$category_name), stringsAsFactors = FALSE)
    names(cnt) <- c("category_name", "Count")
    
    avg_p <- aggregate(price  ~ category_name, d, function(x) round(mean(x,  na.rm=TRUE), 2))
    avg_r <- aggregate(stars  ~ category_name, d, function(x) round(mean(x,  na.rm=TRUE), 2))
    avg_v <- aggregate(reviews~ category_name, d, function(x) round(mean(x,  na.rm=TRUE), 0))
    pct_b <- aggregate(isBestSeller ~ category_name, d,
                       function(x) paste0(round(100*mean(x, na.rm=TRUE),1), "%"))
    
    tab <- Reduce(function(a, b) merge(a, b, by = "category_name", all = TRUE),
                  list(cnt, avg_p, avg_r, avg_v, pct_b))
    tab <- tab[order(-tab$Count), ]
    colnames(tab) <- c("Category","Count","Avg Price ($)","Avg Rating","Avg Reviews","Bestseller %")
    
    datatable(tab, options = list(pageLength = 12, scrollX = TRUE, searchHighlight = TRUE),
              filter = "top", rownames = FALSE)
  })
  
  # ── DOWNLOAD TAB ─────────────────────────────────────────────────────────
  output$downloadRawData <- downloadHandler("raw_amazon_products.csv",
                                            content = function(f) write.csv(products,   f, row.names = FALSE))
  output$downloadData    <- downloadHandler("cleaned_amazon_products.csv",
                                            content = function(f) write.csv(full_data,  f, row.names = FALSE))
}

shinyApp(ui = ui, server = server)