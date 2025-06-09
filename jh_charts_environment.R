source("jh_charts_util.R")

d <- get_data2("aqno2")
d$d$xd <- as.Date(paste0(d$d$timeperiod_label, "-01-01"))
d$d$b <- d$d$area_code
d$d$b <- str_replace(d$d$b, "^r", "R")
d$d$b <- str_replace(d$d$b, "^u", "U")
d$d$text <- "solid"
d$d$text[which(d$d$b %in% c("UK limit", "WHO limit"))] <- "dotted"
d$d$xd <- d$d$timeperiod_label

no2 <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  mTop = 34,
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "character",
                                  ytickformat = ".0f",
                                  leglab = "labels",
                                  forcecols = list(
                                    `3-month moving average` = "#6da7de",
                                    `urban background` = "#9e0059",
                                    `UK limit` = "#AAAAAA",
                                    `WHO limit` = "#AAAAAA")
                                )
                   )
)

update_dash_db(no2)

d <- get_data2("aqpm25")
d$d$xd <- as.Date(paste0(d$d$timeperiod_label, "-01-01"))
d$d$b <- d$d$area_code
d$d$b <- str_replace(d$d$b, "^r", "R")
d$d$b <- str_replace(d$d$b, "^u", "U")
d$d$text <- "solid"
d$d$text[which(d$d$b %in% c("UK limit", "WHO limit"))] <- "dotted"
d$d$xd <- d$d$timeperiod_label

pm25 <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                    input = list(unempl = d$d,
                                 metaopts = list(
                                   mTop = 34,
                                   includetitles = FALSE),
                                 chartopts = list(
                                   type = "character",
                                   ytickformat = ".0f",
                                   leglab = "labels",
                                   forcecols = list(
                                     `3-month moving average` = "#6da7de",
                                     `urban background` = "#9e0059",
                                     `UK limit` = "#AAAAAA",
                                     `WHO limit` = "#AAAAAA")
                                 )
                    )
)

update_dash_db(pm25)

env_fl <- "Environment v6.xlsx"
d <- get_data2("green_gas")

gg <-  read_excel(env_fl, "Fig 1 GHG emissions") %>%
  select(Year:`Agriculture, forestry, and other land use`) %>%
  rename(xd = Year)

grg <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = gg,
                                metaopts = list(
                                  includetitles = FALSE,
                                  cheight = 600),
                                chartopts = list(
                                  cheight = 600,
                                  charttype = "bar",
                                  stackgroup = "stack",
                                  stack = TRUE,
                                  type = "character",
                                  lblFontsize = "12pt",
                                  xFontsize = "11pt",
                                  ytickformat = ".2s"
                                ) )
)

update_dash_db(grg, stack_id = "green_gas")


ren_eng <- read_excel(env_fl, "Fig 3 Renewable energy gen") |>
  select(xd = Year,  y = Value) %>%
  mutate(b = "London")

ren <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = ren_eng,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  type = "character",
                                  forceYDomain = c(0, 1600)
                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ren, glue("{theme_dir}/Renewable electricity generated in London (GWh).svg"), delay = 2)
remove_div(glue("{theme_dir}/Renewable electricity generated in London (GWh).svg"))


d <- get_data2("recycling_rates")
d$d$xd <- d$d$timeperiod_label

rr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                  input = list(unempl = d$d,
                               metaopts = list( includetitles = FALSE ),
                               chartopts = list(
                                 type = "character",
                                 ytickformat = ".0%",
                                 high = TRUE,
                                 forceYDomain = c(0, .58)
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(rr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("part_of_nature")
d$d$xd <- d$d$timeperiod_label

nat <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = d$d,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  type = "character",
                                  ytickformat = ".0%",
                                  high = TRUE,
                                  forceYDomain = c(0, 0.8)
                                ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(nat, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("heat_associated_deaths")
d$d$xd <- d$d$timeperiod_label

heat <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                    input = list(unempl = d$d,
                                 metaopts = list( includetitles = FALSE ),
                                 chartopts = list(
                                   type = "character",
                                   ytickformat = ".0f",
                                   high = TRUE
                                 ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(heat, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

