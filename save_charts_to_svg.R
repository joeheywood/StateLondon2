library(RSQLite)
library(glue)
library(dplyr)
library(r2d3)
library(r2d3svg)
library(purrr)
library(stringr)

source("app/logic/get_chart_data.R")

output_dir <- "~/Projects/sol_svgs/"

deps <- c(
  "js/labels.js",
  "js/lines_qtr.js",
  "js/lines_dt.js",
  "js/lines.js",
  "js/yaxis.js" )


run_line_chart <- function(dtst) {
  print(dtst)
  dt <- get_chart_data(dtst)
  scrpt <- ifelse(dt$m$timeperiod_type == "Quarter", "js/lines_chart_qtr.js", "js/lines_chart_dt.js")
  d3 <-  r2d3(data = dt$d, script = scrpt, options = list(yfmt = dt$m$yformat),
              dependencies = deps, width = 1100, height = 530)
  theme_dir <- glue("{output_dir}/{dt$m$theme}")
  if(!dir.exists(theme_dir)) dir.create(theme_dir)
  save_d3_svg(d3, glue("{theme_dir}/{dt$m$title}.svg") )
  return(glue("{theme_dir}/{dt$m$title}.svg"))
}




change_svg_size <- function(fl) {
  print(fl)
  # x <- readLines("~/Projects/sol_svgs/Economy/Londoners have access to good work.svg")
  x <- readLines(fl) %>%
    str_replace_all("<div (.*?)</div>$", "\n\n") %>%
    str_replace_all("<svg width=\"\\d+\" height=\"\\d+\"",
                    "<svg width=\"1020\" height=\"520\"")
  writeLines(x, fl)
  fl
}

correct_svg_size <- function() {
  svgs <- dir(output_dir, pattern = ".svg", full.names = TRUE, recursive = TRUE)

  map_chr(svgs, change_svg_size)
}

run_all_charts <- function() {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  m <- dbGetQuery(cn, glue("SELECT dataset FROM meta"))
  dbDisconnect(cn)
  map_chr(m$dataset, run_line_chart)
  correct_svg_size()


}

cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
vls <- dbGetQuery(cn, "select dataset, value from charts_data")
dbDisconnect(cn)

vls %>%
  summarise(.by = dataset, mn = round(min(value), 2), mx = round(max(value), 2))
