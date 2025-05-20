library(RSQLite)
library(stringr)
library(robservable)
library(readr)
source("app/logic/get_chart_data.R")
source("~/StateLondon2/save_charts_to_svg.R")
output_dir <- "~/Projects/sol_svgs/"

jhupdates <- function() {
cn <- dbConnect(SQLite(), "app/data/sol_llo.db")

dbSendQuery(cn, "update meta set yformat = '.1f' WHERE dataset = 'sch_happ'")
dbSendQuery(cn, "update meta set yformat = '.0f' WHERE dataset = 'rent_affordability'")
dbSendQuery(cn, "update meta set title = indicator")
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

# infant mortality
# legend at top
# split x axis to two parts
d <- get_data2("inf_mort")
d$d$timeperiod_label <- stringr::str_replace_all(d$d$timeperiod_label, " - ", "-")

d$d$xd <- d$d$timeperiod_label
d$d$upper_xd <- str_replace(d$d$xd, "(\\d+)-(\\d+)", "\\1")
d$d$lower_xd <- str_replace(d$d$xd, "(\\d+)(-\\d+)", "\\2")

i_m <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           yformat = ".0f",
                           high = TRUE,
                           leglab = "legend",
                           lgg = list(o = "top"),
                           forceYDomain = c(0, 6)
                           ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(i_m, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# safety one. combnines datasets
# bar chart, grouped

d1 <- get_data2("safe_school")
d2 <- get_data2("safe_home")
d3 <- get_data2("safe_online")

d <- list(
  d = bind_rows(
    d1$d %>% mutate(xd = "Feel safe at school"),
    d2$d %>% mutate(xd = "Feel safe in the area where they live"),
    d3$d %>% mutate(xd = "Feel safe online")),
  m = d1$m
)
d$d$b <- format(as.Date(d$d$timeperiod_sortable, "%Y%m%d"), "%Y")

safe <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           charttype = "bar",
                           yformat = ".0f",
                           high = FALSE,
                           leglab = "legend",
                           lgg = list(o = "top")
                           ) )
)



theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(safe, glue("{theme_dir}/Feelings of safety.svg"), delay = 2)
remove_div(glue("{theme_dir}/Feelings of safety.svg"))

rms <- c("~/Projects/sol_svgs/CYP/Percentage feel safe in the area where they live.svg",
         "~/Projects/sol_svgs/CYP/Percentage feel safe when they are at school.svg",
         "~/Projects/sol_svgs/CYP/Percentage feel safe online.svg")

for(r in rms) {
  if(file.exists(r)) {
    file.remove(r)
  }
}


#school happiness
# force y domain
# d <- get_data2("sch_happ")
# d$d$xd <- glue("20{d$d$timeperiod_label}")
#
# happ <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#             input = list(unempl = d$d,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            type = "character",
#                            ytickformat = ".1f",
#                            high = TRUE,
#                            forceYDomain = c(6, 8)
#                          ) )
# )

# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(happ, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# medium household income
# just the y domqin
# d <- get_data2("med_hhi")
# d$d$upper_xd <- str_replace(d$d$timeperiod_label, "(\\d+)/(\\d+)", "\\1")
# d$d$lower_xd <- str_replace(d$d$timeperiod_label, "(\\d+)/(\\d+)", "-\\2")
#
# med <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#             input = list(unempl = d$d,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            type = "character",
#                            ytickformat = ".0%",
#                            high = TRUE,
#                            forceYDomain = c(0, .25)
#                          ) )
# )
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(med, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# unfair treatment
# bar
d <- get_data2("unfair")
d$d$xd <- d$d$timeperiod_label

unf <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           charttype = "bar",
                           yformat = ".0f",
                           high = FALSE,
                           leglab = "none"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(unf, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


# Obesity
# May be able to do this locally?
d <- get_data2("yr6_obesity")
d$d$text <- "solid"
d$d$text[which(str_detect(d$d$b, "Reception"))] <- "dotted"

d$d <- filter(d$d, timeperiod_sortable > 20070900)

obs <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           yformat = ".0f",
                           high = TRUE,
                           leglab = "legend"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(obs, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# # disability pay gap.
# # just the y axis
# d <- get_data2("dis_pg")
# dis <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#             input = list(unempl = d$d,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            type = "date",
#                            ytickformat = ".0%",
#                            high = TRUE,
#                            forceYDomain = c(0, .2)
#                          ) )
# )

# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(dis, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))
#
# # formal volunteering
# # just y axis
# d <- get_data2("fml_vol")
# d$d <- d$d[which(!is.na(d$d$y)),]
#
# fv <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#             input = list(unempl = d$d,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            type = "date",
#                            ytickformat = ".0%",
#                            high = TRUE,
#                            forceYDomain = c(0, .4)
#                          ) )
# )
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(fv, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))


# informal volunteering. Just remove missing value?
d <- get_data2("inf_vol")
d$d <- d$d[which(!is.na(d$d$y)),]

iv <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           high = TRUE
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(iv, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

## life expectancy. Bit more complicated.
d <- get_data2("health_hle_m")
d$d$b <- d$d$area_code

d2 <- get_data2("health_hle_f")
d2$d$b <- d$d$area_code

d2$d$text <- "Chart_left"
d$d$text <- "Chart_right"


both <- bind_rows(d$d, d2$d)
both$xd <- str_replace_all(both$timeperiod_label,
                          "(\\d{2})(\\d{2}) - (\\d{2})",
                          "\\1\\3")

hle <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = both,
                         metaopts = list(
                           mTop = 34,
                           includetitles = FALSE,
                           multichart = "lines_horiz",
                           subheads = c("Female", "Male")),
                         chartopts = list(
                           type = "character",
                           ytickformat = ".0f",
                           high = TRUE,
                           leglab = "legend",
                           lgg = list(o = "top"),
                           forceYDomain = c(50,70)
                         )
            )

)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(hle, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("health_le_m")
d$d$b <- d$d$area_code

d2 <- get_data2("health_le_f")
d2$d$b <- d$d$area_code

d2$d$text <- "Chart_left"
d$d$text <- "Chart_right"


both <- bind_rows(d$d, d2$d)
# both$xd <- str_replace_all(both$timeperiod_label,
#                            "(\\d{2})(\\d{2}) - (\\d{2})",
#                            "\\1\\3")

le <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = both,
                         metaopts = list(
                           mTop = 34,
                           includetitles = FALSE,
                           multichart = "lines_horiz",
                           subheads = c("Female", "Male")),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           high = TRUE,
                           leglab = "legend",
                           lgg = list(o = "top"),
                           forceYDomain = c(75,90)
                         )
            )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(le, glue("{theme_dir}/{d$m$title}.svg"), delay = 3 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("anxiety_lifesat")
d$d$text <- ifelse(d$d$area_code == "Life satisfaction", "Chart_left", "Chart_right")

lsanx <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           mTop = 34,
                           includetitles = FALSE,
                           multichart = "lines_horiz",
                           subheads = c("Life Satisfaction", "Anxiety")),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           high = TRUE,
                           leglab = "legend",
                           lgg = list(o = "top"),
                           forceYDomain = c(0, 10)
                         )
            )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(lsanx, glue("{theme_dir}/{d$m$title}.svg"), delay = 3 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# Low Birth Rate
# Forces y axis.
# d <- get_data2("lbw")
#
# lbw <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#                    input = list(unempl = d$d,
#                                 metaopts = list(
#                                   includetitles = FALSE),
#                                 chartopts = list(
#                                   type = "date",
#                                   yformat = ".0f",
#                                   high = TRUE,
#                                   forceYDomain = c(0, 4)
#                                 ) )
# )
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(lbw, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# Smoking
# forces y axis
# d <- get_data2("smoking")
#
# smk <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#                    input = list(unempl = d$d,
#                                 metaopts = list(
#                                   includetitles = FALSE),
#                                 chartopts = list(
#                                   type = "date",
#                                   yformat = ".0f",
#                                   high = TRUE,
#                                   forceYDomain = c(0, 25)
#                                 ) )
# )
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(smk, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# increased footfall
# bar
# forces y axis
d <- get_data2("increased_footfall")
d$d$xd <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\1")
d$d$b <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\2")

ff <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "character",
                                  charttype = "bar",
                                  ytickformat = ".0%",
                                  high = FALSE,
                                  leglab = "legend",
                                  lgg = list(o = "top"),
                                  forceYDomain = c(0, 1)

                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ff, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("hs_spend")
d$d$xd <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\1")
d$d$b <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\2")

spnd <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                  input = list(unempl = d$d,
                               metaopts = list(
                                 includetitles = FALSE),
                               chartopts = list(
                                 type = "character",
                                 charttype = "bar",
                                 ytickformat = ".0%",
                                 high = FALSE,
                                 leglab = "legend",
                                 lgg = list(o = "top"),
                                 forceYDomain = c(0, .5)

                               ) )
)

d <- get_data2("hs_increased_purchases")
d$d$xd <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\1")
d$d$b <- str_replace_all(d$d$area_code, "(\\w+) - (\\w+)", "\\2")

inc_pur <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                  input = list(unempl = d$d,
                               metaopts = list(
                                 includetitles = FALSE),
                               chartopts = list(
                                 type = "character",
                                 charttype = "bar",
                                 ytickformat = ".0%",
                                 high = FALSE,
                                 leglab = "legend",
                                 lgg = list(o = "top"),
                                 forceYDomain = c(0, .8)

                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(inc_pur, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# victim satisfaction
# just change to y axis
d <- get_data2("victim_satisfaction")
d$d$b <- d$d$area_code

vs <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%"
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vs, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# Worried about crime chart
# y domain and legend
# not labels
d <- get_data2("worried_crime_asb")
d$d$b <- d$d$area_code

worr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           forceYDomain = c(0, 0.7),
                           leglab = "legend",
                           lgg = list(o = "top")
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(worr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# #trust in mps
# # forces y domain
# d <- get_data2("trust_in_mps")
#
# trst <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#                     input = list(unempl = d$d,
#                                  metaopts = list(
#                                    includetitles = FALSE),
#                                  chartopts = list(
#                                    type = "date",
#                                    ytickformat = ".0%",
#                                    forceYDomain = c(.0, 1)
#                                  ) )
# )
#
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(trst, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# # victimisation
# # just y axis
# d <- get_data2("victimisation_rate")
#
#
# vct <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
#                     input = list(unempl = d$d,
#                                  metaopts = list(
#                                    includetitles = FALSE),
#                                  chartopts = list(
#                                    type = "date",
#                                    ytickformat = ".0%",
#                                    forceYDomain = c(.0, .1)
#                                  ) )
# )
#
#
# theme_dir <- glue("{output_dir}/{d$m$theme}")
# save_d3_svg(vct, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
# remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("proven_reoffending")

reoff <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "date",
                                  ytickformat = ".0%",
                                  forceYDomain = c(.0, .5)
                                ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(reoff, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("tno")
d$d$xd <- d$d$timeperiod_label

tno <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                     input = list(unempl = d$d,
                                  metaopts = list(
                                    includetitles = FALSE),
                                  chartopts = list(
                                    type = "character",
                                    ytickformat = ".1s",
                                    forceYDomain = c(500000, 1000000)
                                  ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tno, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gva_composition") ## needs to be a bar chart

d <- get_data2("gva") # missing data

d <- get_data2("gva_ph") # missing data

d <- get_data2("bbc")
d$d$b <- d$d$area_code

bbc <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "date",
                                  ytickformat = ".2s",
                                  forceYDomain = c(0, 25000)
                                ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(bbc, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))
