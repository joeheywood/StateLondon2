# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue],
  dplyr[select,`%>%`, arrange],
  stringr[str_replace_all, str_detect]
)

#' @export
run_chart <- function(data_obj) {
  tryCatch({
    deps <- c(
      "js/labels.js",
      "js/lines_qtr.js",
      "js/lines_dt.js",
      "js/xaxis_char.js",
      "js/lines.js",
      "js/yaxis.js" )

    scrpt <- if(data_obj$o$charttype == "line") {
      if(data_obj$o$type == "date") {
        "js/lines_chart_dt.js"
      } else if(data_obj$o$type == "quarter") {
        "js/lines_chart_qtr.js"
      } else if(data_obj$o$type == "character") {
        if(data_obj$o$leglab == "legend") {
          "js/lines_chart_char_leg.js"
        } else {
          "js/lines_chart_char.js"
        }
      } else {
        "js/bars_xaxis_chr.js"
      }
    }
    opts <- list(
      yfmt = data_obj$o$ytickformat,
      high = data_obj$o$high
    )
    if(data_obj$o$forceYDomain_t - data_obj$o$forceYDomain_b == 0) {
      opts$yforce <- NULL
    } else {
      opts$yforce <- c(data_obj$o$forceYDomain_b, data_obj$o$forceYDomain_t)
    }
    print("RUNNING CHART")


    return(r2d3(data = data_obj$d,
         script = scrpt,
         options = opts,
         dependencies = deps))


  }, error = function(e) {
    "Error running chart"
    return(list())
  })

}
