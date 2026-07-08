# ── server.R ──────────────────────────────────────────────────────────────────
# Reactive logic for the dashboard: filtering, plots, tables, fake-product
# detection, and CSV downloads. Base dataset (full_data) and helper functions
# (make_histogram, save_plotly) come from global.R / R/helpers.R.

server <- function(input, output, session) {
  
  
  
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

