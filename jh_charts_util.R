library(RSQLite)
library(tidyr)
library(stringr)
library(robservable)
library(readxl)
library(readr)
library(glue)
library(jsonlite)
source("app/logic/get_chart_data.R")
source("~/StateLondon2/save_charts_to_svg.R")
output_dir <- "~/Projects/sol_svgs/"

jhupdates <- function() {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")

  dbSendQuery(cn, "update meta set yformat = '.1f' WHERE dataset = 'sch_happ'")
  dbSendQuery(cn, "update meta set yformat = '.0f' WHERE dataset = 'rent_affordability'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'emp_prof'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'skills_short'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'bus_train'")
  dbSendQuery(cn, "update meta set yformat = '.0f' WHERE dataset = 'lbw'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'recycling_rates'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'energy_performance'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'part_of_nature'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'tfl_active20_daily'")
  dbSendQuery(cn, "update meta set yformat = '.0%' WHERE dataset = 'tfl_sfdelay_reduction'")
  dbSendQuery(cn, "update meta set yformat = '.1f' WHERE theme = 'Demography'")
  dbSendQuery(cn, "update meta set title = '.1f' WHERE theme = 'Demography'")
  dbSendQuery(cn, "update meta set title = 'Travel demand on principal modes' WHERE dataset = 'tfl_demand_idx'")
  dbSendQuery(cn, "alter table meta add column  text default 'N'")
  dbSendQuery(cn, "alter table meta add column need_obs text default 'N'")
  View(dbGetQuery(cn, "select * from meta"))
  dbDisconnect(cn)

}

include_ranges <- function(){
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  m <- dbGetQuery(cn, "select * from meta")
  rngs <- read_csv("mta_ranges.csv") %>%
    select(dataset, ystart0)
  m$ystart0 <- NULL
  m <- left_join(m, rngs)
  m$ystart0[which(is.na(m$ystart0))] <- "N"
  dbSendQuery(cn, "drop table meta")
  dbWriteTable(cn, "meta", m)

  dbDisconnect(cn)

}

get_data2 <- function(dtst) {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  dat <- dbGetQuery(cn, glue("SELECT * FROM charts_data WHERE dataset = '{dtst}'")) %>%
    arrange(timeperiod_sortable)
  m <- dbGetQuery(cn, glue("SELECT * FROM meta WHERE dataset = '{dtst}'"))
  on.exit(dbDisconnect(cn))
  zeroes <- which(str_detect(dat$timeperiod_sortable, "0{4}$"))
  dat$timeperiod_sortable[zeroes] <- str_replace_all(dat$timeperiod_sortable[zeroes], "0000", "0101")
  dat$xd <- as.character(as.Date(dat$timeperiod_sortable, format = "%Y%m%d"))
  dat$b <- dat$area_name
  dat$y <- dat$value
  return(list(d = dat, m = m))

}

remove_div <- function(fl) {
  code <- readLines(fl) %>% paste(collapse = "")
  code <- str_replace(code, "^<div[a-z =\"]+>", "")
  code <- str_replace(code, "</div>$", "")
  writeLines(code, fl)
  TRUE
}

update_dash_db <- function(obj, stack_id = NULL) {
  if("stack" %in% names(obj$x$input$chartopts) && !"b" %in% names(obj$x$input$unempl)) {
    if(is.null(stack_id)) {
      stop("No. You need an id separately for this one. It's a stack bar")
    }
    df <- obj$x$input$unempl %>%
      mutate(dataset = stack_id) %>%
      pivot_longer(-c(dataset, xd), names_to = "b", values_to = "y") %>%
      select(dataset, xd, b, y)

  } else {
    df <- obj$x$input$unempl %>% select(dataset, xd, b, y)
  }

  opts <- obj$x$input$chartopts
  cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
  dtst <- df$dataset[1]
  dbSendQuery(cn, glue("DELETE FROM chart_data WHERE dataset = '{dtst}'"))
  a <- dbAppendTable(cn, "chart_data", df)
  print(glue("Added {a} rows to chart_data"))
  m <- dbGetQuery(cn, glue("select dataset, theme, title from meta where dataset = '{dtst}'"))
  dbDisconnect(cn)
  update_dash_opts(opts, dtst)
  tryCatch({
    theme_dir <- glue("{output_dir}/{m$theme}")
    save_d3_svg(obj, glue("{theme_dir}/{m$title}.svg"), delay = 2 )
    remove_div(glue("{theme_dir}/{m$title}.svg"))

  }, error = function(e){
    print(e)
    print(glue("Couldn't print file for {m$title}"))

  })

  return(a)

}

opts_db_blank <- data.frame(
  dataset = "",
  charttype = "line",
  type = "date",
  high = FALSE,
  leglab = "labels",
  lgg = "{}",
  ytickformat = ".1f",
  forceYDomain_b = 0,
  forceYDomain_t = 0,
  tick_base = 110,
  stack = FALSE,
  inc_mark = FALSE,
  suffix = ""
)

update_dash_opts <- function(opts, dtst) {
  optsdf <- opts_db_blank
  optsdf$dataset <- dtst
  for(n in names(opts)) {
    if(n %in% c("charttype", "type", "high", "leglab", "ytickformat", "tick_base")) {
      optsdf[[n]] <- opts[[n]]
    } else if(n == "forceYDomain") {
      optsdf$forceYDomain_b <- opts$forceYDomain[1]
      optsdf$forceYDomain_t <- opts$forceYDomain[2]
    } else if(n == "lgg") {
      optsdf$lgg <- as.character(toJSON(opts$lgg))
    } else {
      print(glue("** Ignoring {n} for {dtst}"))
    }
  }
  cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
  # dbWriteTable(cn, dbWriteTable(cn, "opts", optsdf))
  dbSendQuery(cn, glue("DELETE FROM opts WHERE dataset = '{dtst}'"))
  dbAppendTable(cn, "opts", optsdf)
  dbDisconnect(cn)


}


update_dash_db_auto <- function(obj, stack_id = NULL) {
  df <- obj$x$data

  opts <- obj$x$options
  opts$ytickformat = opts$yfmt
  opts$forceYDomain = opts$yforce
  cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
  dtst <- df$dataset[1]
  dbSendQuery(cn, glue("DELETE FROM chart_data WHERE dataset = '{dtst}'"))
  a <- dbAppendTable(cn, "chart_data", df)
  print(glue("Added {a} rows to chart_data"))
  m <- dbGetQuery(cn, glue("select dataset, theme, title from meta where dataset = '{dtst}'"))
  dbDisconnect(cn)
  update_dash_opts(opts, dtst)
  tryCatch({
    theme_dir <- glue("{output_dir}/{m$theme}")
    save_d3_svg(obj, glue("{theme_dir}/{m$title}.svg"), delay = 2 )
    remove_div(glue("{theme_dir}/{m$title}.svg"))

  }, error = function(e){
    print(e)
    print(glue("Couldn't print file for {m$title}"))

  })

  return(a)

}




