# ── Plotting & export helpers ────────────────────────────────────────────────
# Shared helper functions used across the server logic. Kept separate from
# server.R so the reactive/server code isn't cluttered with plotting details.

#' Build a themed Plotly histogram
#'
#' @param data     data.frame containing the column to plot
#' @param xvar     name of the numeric column to histogram ("price" or "stars")
#' @param nbins    number of bins
#' @param color    bar color
#' @param xlimits  optional c(min, max) for the x-axis range
#' @param xbreaks  optional c(start, next) used to derive tick spacing
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

#' Save a Plotly widget to PNG, SVG, or TIFF
#'
#' @param plot a plotly htmlwidget
#' @param file destination file path
#' @param ext  one of "png", "svg", "tiff"
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
