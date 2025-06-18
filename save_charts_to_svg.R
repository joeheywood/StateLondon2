library(RSQLite)
library(glue)
library(dplyr)
library(r2d3)
library(r2d3svg)
library(purrr)
library(stringr)

source("app/logic/get_chart_data.R")
source("jh_charts_util.R")

output_dir <- "~/Projects/sol_svgs/"

deps <- c(
  "js/labels.js",
  "js/lines_qtr.js",
  "js/lines_dt.js",
  # "js/lines_xaxis_chr.js",
  # "js/lines_chart_char.js",
  "js/lines.js",
  "js/yaxis.js" )

# deps <- dir("js", full.names = TRUE)

run_line_chart <- function(dtst) {
  tryCatch({
    dt <- get_chart_data(dtst)
    dt$d <- dt$d %>% arrange(xd)
    # yforce <- ifelse(dt$m$ystart0 == "N", c(),str_split(dt$m$ystart0, ",")[[1]] )
    yforce <- c(dt$o$forceYDomain_b, dt$o$forceYDomain_t)
    d3 <- r2d3(data = dt$d, script = scrpt, options = list(yfmt = dt$m$yformat, high = dt$o$high, yforce=yforce ),
         dependencies = deps, width = 1100, height = 530)
    theme_dir <- glue("{output_dir}/{dt$m$theme}")
    if(!dir.exists(theme_dir)) dir.create(theme_dir)
    save_d3_svg(d3, glue("{theme_dir}/{dt$m$title}.svg") )
    print(glue("{dtst} = {theme_dir} = {dt$m$title}"))

    return(glue("{theme_dir}/{dt$m$title}.svg"))

  }, error = function(e) {
    print(glue("######## ERROR in {dtst} ###########"))
    print(e)
    return("")
  })
}

run_line_chart_db <- function(dtst) {
  tryCatch({
    print(glue("RUNNING FOR {dtst}"))
    dt <- get_chart_data(dtst)
    dt$d <- dt$d %>% arrange(xd)
    # yforce <- ifelse(dt$m$ystart0 == "N", c(),str_split(dt$m$ystart0, ",")[[1]] )
    yforce <- c(dt$o$forceYDomain_b, dt$o$forceYDomain_t)
    d3 <- r2d3(data = dt$d, script = "js/lines_chart_dt.js", options = list(yfmt = dt$m$yformat, high = dt$o$high, yforce=yforce ),
         dependencies = deps, width = 1100, height = 530)
    update_dash_db_auto(d3)

  }, error = function(e) {
    print(glue("######## ERROR in {dtst} ###########"))
    print(e)
    return("")
  })
}



## function to correct for svg size. I couldn't find a simple way to control for this
## using the r2d3 function that worked (altering width and height didn't work for me)
change_svg_size <- function(fl) {
  x <- readLines(fl) %>%
    str_replace_all("<div (.*?)</div>$", "\n\n") %>%
    str_replace_all("<svg width=\"\\d+\" height=\"\\d+\"",
                    "<svg width=\"1020\" height=\"520\"")
  writeLines(x, fl)
  fl
}

correct_svg_size <- function() {
  svgs <- dir(output_dir, pattern = ".svg", full.names = TRUE, recursive = TRUE)

  map_chr(svgs, change_svg_size) # returns names of corrected filepaths
}

run_all_charts <- function() {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  m <- dbGetQuery(cn, glue("SELECT dataset FROM meta"))
  dbDisconnect(cn)
  charts <- map_chr(m$dataset, run_line_chart)
  correct_svg_size()
}

run_all_charts_db <- function() {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  m <- dbGetQuery(cn, glue("SELECT dataset FROM meta"))
  dbDisconnect(cn)
  charts <- map(m$dataset, run_line_chart_db)
}

# cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
# vls <- dbGetQuery(cn, "select dataset, value from charts_data")
# dbDisconnect(cn)
#
# vls %>%
#   summarise(.by = dataset, mn = round(min(value), 2), mx = round(max(value), 2))
