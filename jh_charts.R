library(RSQLite)
library(tidyr)
library(stringr)
library(robservable)
library(readxl)
library(readr)
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

run_local_line_chart <- function(dt) {
  tryCatch({
    scrpt <- ifelse(dt$m$timeperiod_type == "Quarter", "js/lines_chart_qtr.js", "js/lines_chart_dt.js")
    if(dt$m$ystart0 %in% "N") {
      yforce = c()
    } else {
      yforce = str_split(dt$m$ystart0, ",")[[1]]
    }
    # yforce <- ifelse(dt$m$ystart0 == "N", c(),str_split(dt$m$ystart0, ",")[[1]] )
    d3 <-  r2d3(data = dt$d, script = scrpt,
                options = list(yfmt = dt$m$yformat, high = high, yforce=yforce ),
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

#### HEALTH ####


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







# Obesity
# May be able to do this locally?
d <- get_data2("yr6_obesity")

d$d$text <- "solid"
d$d$text[which(str_detect(d$d$b, "Reception"))] <- "dotted"
d$d$b <- str_replace_all(d$d$b, "( - Reception| - Year 6)", "")
d$d <- filter(d$d, timeperiod_sortable > 20070900)

obs <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "date",
                                  lgg = list(dots_England =  "England - Reception",
                                             dots_London = "London - Reception",
                                             solid_England = "England - Year 6",
                                             solid_London = "London - Year 6"),
                                  yformat = ".0f",
                                  high = TRUE,
                                  leglab = "legend"
                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(obs, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



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

d <- get_data2("childhood_vacc")
d$d$xd <- d$d$timeperiod_label
d$d$b <- d$d$area_code
d$d$b <- str_replace_all(d$d$b, "DTaP-IPV", "DTaP-IPV ")
d$d$chart <- d$d$area_name
d$d$text <- "solid"



d1 <- d$d %>% filter(chart %in% "London") %>% select(xd, b, y)
d1 <- bind_rows(d1, data.frame(xd = unique(d1$xd), b = "95% target", y = 95))

cvl <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d1,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           forcecols = list(`95% target` = "#AAAAAA"),
                           ytickformat = ".0f",
                           high = FALSE,
                           forceYDomain = c(60, 100),
                           leglab = "legend"

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(cvl, glue("{theme_dir}/{d$m$title}_London.svg"), delay = 3 )
remove_div(glue("{theme_dir}/{d$m$title}_London.svg"))


d2 <- d$d %>% filter(chart %in% "England") %>% select(xd, b, y)
d2 <- bind_rows(d2, data.frame(xd = unique(d2$xd), b = "95% target", y = 95))

cve <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d2,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "character",
                                  forcecols = list(`95% target` = "#AAAAAA"),
                                  ytickformat = ".0f",
                                  high = FALSE,
                                  forceYDomain = c(60, 100),
                                  leglab = "legend"

                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(cve, glue("{theme_dir}/{d$m$title}_England.svg"), delay = 3 )
remove_div(glue("{theme_dir}/{d$m$title}_England.svg"))

#### CYP ####

d <- get_data2("cyp_gld")
d$d$xd <- d$d$timeperiod_label
out <- d$d %>% select(xd, b, y)
mss <- data.frame(xd = "2020/21", b = c("London", "England"), y = NA)
out <- rbind(out, mss) %>% arrange(xd)

gld <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           ytickformat = ".0%",
                           high = TRUE,
                           forceYDomain = c(.5, .8)

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(gld, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("sch_happ")
d$d$b <- str_replace(d$d$b, " - 3_to_11", "")
d$d$xd <- d$d$timeperiod_label

happ <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                       input = list(unempl = d$d,
                                    metaopts = list(
                                      includetitles = FALSE),
                                    chartopts = list(
                                      type = "character",
                                      ytickformat = ".1f",
                                      high = TRUE,
                                      forceYDomain = c(6, 8)

                                    ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(happ, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cyp_mental_disorder")
d$d$xd <- d$d$timeperiod_label

ment_dis <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                    input = list(unempl = d$d,
                                 metaopts = list(
                                   includetitles = FALSE),
                                 chartopts = list(
                                   type = "character",
                                   ytickformat = ".0f",
                                   high = TRUE,
                                   forceYDomain = c(0, 25)

                                 ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ment_dis, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cyp_attainment8")
d$d$xd <- d$d$timeperiod_label

att8 <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           charttype = "bar",
                           ytickformat = ".0f",
                           high = TRUE,
                           leglab = "legend",
                           lgg = list(o = "top"),
                           forceYDomain = c(0, 60)

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(att8, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cyp_neet")
d$d$b <- str_replace(d$d$b, " - 16-24", "")

nt <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           high = TRUE,
                           forceYDomain = c(0, 25)

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(nt, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("cyp_level3")
d$d$xd <- d$d$timeperiod_label
d$d$upper_xd <- str_replace(d$d$xd, "(\\d+)/(\\d+)", "\\1")
d$d$lower_xd <- str_replace(d$d$xd, "(\\d+)(/\\d+)", "\\2")
lvl3 <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           ytickformat = ".0f",
                           high = TRUE,
                           forceYDomain = c(0, 100)

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(lvl3, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cyp_absence")
d$d$xd <- d$d$timeperiod_label
d$d$xd <- str_replace(d$d$xd, "//", "/")
d$d$upper_xd <- str_replace(d$d$xd, "(\\d+)/(\\d+)", "\\1")
d$d$lower_xd <- str_replace(d$d$xd, "(\\d+)(/\\d+)", "\\2")
abs <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                    input = list(unempl = d$d,
                                 metaopts = list(
                                   includetitles = FALSE),
                                 chartopts = list(
                                   type = "character",
                                   ytickformat = ".0f",
                                   high = TRUE,
                                   forceYDomain = c(0, 10)

                                 ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(abs, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("cyp_suspension")
d$d$xd <- d$d$timeperiod_label
d$d$upper_xd <- str_replace(d$d$xd, "(\\d+)/(\\d+)", "\\1")
d$d$lower_xd <- str_replace(d$d$xd, "(\\d+)(/\\d+)", "\\2")
susp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "character",
                                  ytickformat = ".0f",
                                  high = TRUE,
                                  forceYDomain = c(0, 10)

                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(susp, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cyp_exclusion")
d$d$xd <- d$d$timeperiod_label
d$d$upper_xd <- str_replace(d$d$xd, "(\\d+)/(\\d+)", "\\1")
d$d$lower_xd <- str_replace(d$d$xd, "(\\d+)(/\\d+)", "\\2")
excl <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                   input = list(unempl = d$d,
                                metaopts = list(
                                  includetitles = FALSE),
                                chartopts = list(
                                  type = "character",
                                  ytickformat = ".2f",
                                  high = TRUE,
                                  forceYDomain = c(0, .2 )

                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(excl, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

#### SOCIAL JUSTICE ####

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


d <- get_data2("strugg")

str <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           tick_base = 75,
                           ytickformat = ".0%",
                           high = FALSE,
                           forceYDomain = c(0,.29)
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(str, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("bills_arrears")
d$d$xd <- d$d$timeperiod_label
d$d$xd <- str_replace(d$d$xd, "(\\d+)-(\\d+) - (\\d+)-(\\d+)", "\\1-\\4")
# d$d$upper_xd <- str_replace(d$d$xd, "(\\d+-\\d+) - (\\d+-\\d+)", "\\1")
# d$d$lower_xd <- str_replace(d$d$xd, "(\\d+-\\d+) - (\\d+-\\d+)", "- \\2")

arr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           high = TRUE,
                           ytickformat = ".0%",
                           forceYDomain = c(0, 0.11)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(arr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("voter_reg")

vr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           high = TRUE,
                           ytickformat = ".0%",
                           forceYDomain = c(0.6, 1)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("decision_influence")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)

decif <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                  input = list(unempl = d$d,
                               metaopts = list(
                                 includetitles = FALSE),
                               chartopts = list(
                                 type = "character",
                                 inc_mark = "all_categories",
                                 high = TRUE,
                                 ytickformat = ".0f",
                                 forceYDomain = c(0, 47)
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(decif, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("locals")

loc <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                  input = list(unempl = d$d,
                               metaopts = list(
                                 includetitles = FALSE),
                               chartopts = list(
                                 type = "date",
                                 high = TRUE,
                                 ytickformat = ".0%",
                                 forceYDomain = c(0.8, 1)
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(loc, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("pay_gap_disability")
dspg <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           high = TRUE,
                           forceYDomain = c(0, .21)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(dspg, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("pay_gap_ethnicity")
ethpg <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           high = TRUE,
                           forceYDomain = c(0, .39)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ethpg, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("pay_gap_gender")
gnpg <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           high = TRUE,
                           forceYDomain = c(0, .32)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(gnpg, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("volunt_formal")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)


fmlvol <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           inc_mark = "all_categories",
                           ytickformat = ".0%",
                           tick_base = 80,
                           high = TRUE,
                           forceYDomain = c(0, .61)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(fmlvol, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("volunt_informal")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)

infvol <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                      input = list(unempl = d$d,
                                   metaopts = list(
                                     includetitles = FALSE),
                                   chartopts = list(
                                     type = "character",
                                     ytickformat = ".0%",
                                     inc_mark = "all_categories",
                                     high = TRUE,
                                     forceYDomain = c(0, .71)
                                   ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(infvol, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("food_sec")
theme_dir <- glue("{output_dir}/{d$m$theme}")
file.remove(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("trust_neigh")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)

tneigh <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           inc_mark = "all_categories",
                           ytickformat = ".0f",
                           suffix = "%",
                           high = TRUE,
                           forceYDomain = c(0, 54)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tneigh, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("talk_neigh")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)

tlkneigh <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           ytickformat = ".0f",
                           inc_mark = "all_categories",
                           suffix = "%",
                           high = TRUE,
                           forceYDomain = c(40, 90)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tlkneigh, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("social_action")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd)


sa <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                        input = list(unempl = d$d,
                                     metaopts = list(
                                       includetitles = FALSE),
                                     chartopts = list(
                                       type = "character",
                                       ytickformat = ".0f",
                                       inc_mark = "all_categories",
                                       suffix = "%",
                                       high = TRUE,
                                       forceYDomain = c(0, 28)
                                     ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(sa, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("hate_crimes")
hc <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                        input = list(unempl = d$d,
                                     metaopts = list(
                                       includetitles = FALSE),
                                     chartopts = list(
                                       type = "date",
                                       ytickformat = ".0f",
                                       high = TRUE,
                                       forceYDomain = c(0, 3100)
                                     ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(hc, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("help")
d$d$xd <- d$d$timeperiod_label
# d$d <- d$d %>% filter(!is.na(y))
hlp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
                  input = list(unempl = d$d,
                               metaopts = list(
                                 includetitles = FALSE),
                               chartopts = list(
                                 type = "character",
                                 inc_mark = list("England", "London"),
                                 ytickformat = ".0%",
                                 high = TRUE,
                                 forceYDomain = c(0.81, 1)
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(hlp, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



#### CRIME ####

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



#### SKILLS ####
d <- get_data2("fe_skills")
d$d <- d$d %>% filter(area_name %in% "London", !area_code %in% "Overall positive destination")
d$d$xd <- d$d$timeperiod_label
d$d$b <- d$d$area_code

out <- d$d %>% select(xd, b, y) %>%
  pivot_wider(names_from = b, values_from = y)

fes <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           stackgroup = "stack",
                           stack = TRUE,
                           # silent_x = TRUE,
                           type = "character",
                           ytickformat = ".0%"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(fes, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))




d <- get_data2("grad_outcomes")
d$d$xd <- d$d$timeperiod_label
grad <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "character",
                           high = TRUE,
                           ytickformat = ".0%",
                           forceYDomain = c(0, 1)
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(grad, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("job_posts")
d$d$b <- d$d$area_code

jp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".2s",
                           forcecols = list(
                             `3-month moving average` = "#6da7de",
                             `Raw count` = "#AAAAAA"


                           )
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(jp, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("top_skills")
d$d <- d$d %>% filter(area_code == "Common")
d$d$xd <- d$d$area_name
d$d$b <- d$d$timeperiod_label
ordered <- d$d %>% filter(b == "Jan-Mar 2025") %>% arrange(y)
d$d$order <- factor(d$d$xd,
                    levels = ordered$xd)
d$d <- d$d %>% arrange(desc(b), order)
out <- d$d %>% select(xd, b, y)


ts_c <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           horiz = TRUE,
                           type = "character",
                           ytickformat = ".0%",
                           forceYDomain = c(0, .42)
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ts_c, glue("{theme_dir}/{d$m$title} (common).svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title} (common).svg"))

d <- get_data2("top_skills")
d$d <- d$d %>% filter(area_code == "Specialised")
d$d$xd <- d$d$area_name
d$d$b <- d$d$timeperiod_label
ordered <- d$d %>% filter(b == "Jan-Mar 2025") %>% arrange(y)
d$d$order <- factor(d$d$xd,
                    levels = ordered$xd)
d$d <- d$d %>% arrange(desc(b), order)
out <- d$d %>% select(xd, b, y)


ts_s <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           horiz = TRUE,
                           type = "character",
                           ytickformat = ".0%"
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ts_s, glue("{theme_dir}/{d$m$title} (specialised).svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title} (specialised).svg"))
file.remove("~/Projects/sol_svgs/Skills/Top common and technical skills in demand as measured by frequency in job postings (%).svg")


# need to split these out into two charts. Needs observable!
#### HOUSING ####

d <- get_data2("rent_payment") # just needs separating out. join London/ROE with categories
d$d$area <- ifelse(d$d$area_code %in% "E12000007", "London", "RoE")
d$d$b <- paste0(d$d$area, " ", d$d$b)

rp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%"
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(rp, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("cladding_remediation") # needs to be a grouped bar
d$d$xd <- d$d$area_code
d$d$b <- str_replace(d$d$b, "Buildings with unsafe cladding ", "")
d$d$order <- factor(d$d$xd,
                    levels = c("London", "South East", "North West", "South West",
                               "East of England", "West Midlands", "Yorkshire and The Humber",
                               "East Midlands", "North East"))
d$d <- arrange(d$d, desc(order))
cr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           horiz = TRUE,
                           type = "character",
                           ytickformat = ".0f"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(cr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("roughsleeping_first_time") # needs to be a stacked bar
out <- d$d %>% select(xd, b, y) %>% pivot_wider(names_from = "b", values_from = "y") %>%
  select(xd, `No second night out`, `Second night out but not living on the streets`,
         `Joined living on the streets population`)




# rgh_first <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
#             input = list(unempl = out,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            charttype = "bar",
#                            stackgroup = "stack",
#                            stack = TRUE,
#                            silent_x = TRUE,
#                            type = "date",
#                            ytickformat = ".0f"
#                          ) )
# )

rgh_first <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "quarter",
                           ytickformat = ".0f"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(rgh_first, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("homeless_decisions")
d$d$b <- d$d$area_code
hmd <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "quarter",
                           ytickformat = ".0f"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(hmd, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("missed_payment")
dat <- read_csv("missed_payment.csv") %>%
  select(b = 1, `Jan-22`:`Jan-25`) %>%
  pivot_longer(-b, names_to = "xd", values_to = "y") %>%
  mutate(xd = as.Date(paste0("1-", xd), format = "%d-%b-%y"), dataset = "missed_payment") %>%
  select(dataset, xd, b, y)

dat$b[which(dat$b == "Net: Struggled")] <- "Net: struggled"


d$d <- d$d %>% select(xd, area_code, y)
d$d <- d$d[which(!d$d$area_code %in% c("Not applicable", "Prefer not to say",
                                       "Don’t know" )),]
out <- d$d %>% pivot_wider(names_from = area_code, values_from = y)
out$`Total: fallen behind or struggled` <- out$`I fell behind on one or more payments` +
  out$`I kept up with payments, but it was a struggle to do so at least once` +
  out$`I kept up with payments, but struggled every time` +
  out$`I’ve fallen behind on all payments`

out$`Net: struggled` <- out$`I kept up with payments, but it was a struggle to do so at least once` +
  out$`I kept up with payments, but struggled every time`

out$`Net: fallen behind` <- out$`I fell behind on one or more payments` +
  out$`I’ve fallen behind on all payments`

out <- out %>% select(xd,
  `Kept up with payments with no difficulties` = `I kept up with payments without any difficulties`,
  `Total: fallen behind or struggled`,
  `Net: struggled`,
  `Net: fallen behind`
)

out <- out %>% pivot_longer(-xd, names_to = "b", values_to = "y")


mss_py <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            #input = list(unempl = out,
            input = list(unempl = dat,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           tick_base = 60,
                           ytickformat = ".0%"
                         ) )
)
theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(mss_py, glue("{theme_dir}/{d$m$indicator}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$indicator}.svg"))

dfe <- get_data2("hmls")
# d$d$b <- "London"
# hml <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
#             input = list(unempl = d$d,
#                          metaopts = list(
#                            includetitles = FALSE),
#                          chartopts = list(
#                            charttype = "bar",
#                            stack
#                            type = "date",
#                            tick_base = 60,
#                            ytickformat = ".1s",
#                            forceYDomain = c(0, 100000)
#                          ) )
# )


out <- d$d %>%
  select(xd, b, y) %>%
  pivot_wider(names_from = b, values_from = y) %>%
  select(
    xd,
    `Leased from private sector by social housing landlord`,
    `Other private sector` = `Other private sector accommodation`,
    `Social housing`,
    `Bed and breakfast`,
    `Hostels and women's refuges`

  )

hml <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           tick_base = 60,
                           forceYDomain = c(0, 70100),
                           stackgroup = "stack",
                           stack = TRUE,
                           silent_x = TRUE,
                           type = "date",
                           ytickformat = ".2s"
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(hml, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



#### ECONOMY ####
d <- get_data2("annual_gva_growth") # needs more data to be added
d$d <- d$d %>% arrange(b)
d$d$text <- "solid"
d$d$text[25] <- "solid_join"
d$d$text[26] <- "dotted"
d$d$b[26] <- "London"

gva <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           leglab = "legend",
                           high = TRUE,
                           tick_base = 80,
                           lgg = list(dots_London = "London (Projected)")
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(gva, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("gva")
fl <- glue("{theme_dir}/{d$m$title}.svg")
if(file.exists(fl))file.remove(fl)


d <- get_data2("gva_ph")
d <- get_data2("extended_unemployment")

d <- get_data2("jq_score")
d$d$xd <- d$d$area_code
d$d$b <- d$d$area_name
d$d <- d$d %>% select(xd, b, y)
d$d <- rbind(d$d, data.frame(xd = "", b = "", y = 0))
d$d$xd[which(d$d$xd == "Positive employee involvment")] <- "Positive employee involvement"

d$d$order <- factor(d$d$xd,
                    levels = c(
                      "Positive career progression",
                      "Positive employee involvement",
                      "Not in low pay",
                      "No unpaid overtime",
                      "Satisfactory hours",
                      "Not on zero hours contract",
                      "Desired contract",
                      "",
                      "Average job quality indicator"
                    ))
d$d <- d$d %>% arrange(order)
out <- d$d %>% select(xd, b, y)

jqs <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           type = "character",
                           high = TRUE,
                           horiz = TRUE,
                           ytickformat = ".0%",
                           forceYDomain = c(0, 1)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(jqs, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gva_composition")
d$d$xd <- d$d$area_name
d$d$b <- "London"
out <- d$d %>% select(xd, y)

gva_comp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           type = "character",
                           horiz = TRUE,
                           ytickformat = ".0%",
                           forceYDomain = c(-.22, .22),
                           leglab = "none"

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(gva_comp, glue("{theme_dir}/{d$m$title}.svg"), delay = 1)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("gva_per_hour_worked_rhc")


prod <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt",
            input = list(unempl = d$d,
                         metaopts = list(
                           mTop = 34,
                           includetitles = FALSE),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           high = TRUE,
                         forceYDomain = c(76, 120),
                           leglab = "labels")
                           # lgg = list(o = "top")
            )

)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(prod, glue("{theme_dir}/London productivity relative to the UK average and since 2019.svg"), delay = 2)
remove_div(glue(glue("{theme_dir}/London productivity relative to the UK average and since 2019.svg")))


d <- get_data2("extended_unemployment")
d$d <- filter(d$d, area_code %in% c("inactivity", "unemployment"))
d$d$xds <- str_replace(d$d$timeperiod_label, "(\\w{3} \\d{4})-(\\w{3} \\d{4})", "1 \\2")
d$d$xd <- as.Date(d$d$xds, format = "%d %b %Y")
d$d$b <- d$d$area_code

out <- d$d %>%
  select(xd, b, y) %>%
  arrange(xd) %>%
  pivot_wider(names_from = "b", values_from = "y")

eu <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list(
                           includetitles = FALSE),
                         chartopts = list(
                           charttype = "bar",
                           stackgroup = "stack",
                           stack = TRUE,
                           type = "date",
                           silent_x = TRUE,
                           ytickformat = ".0%",
                           leglab = "legend"

                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(eu, glue("{theme_dir}/{d$m$title}.svg"), delay = 1)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


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
                                  tick_base = 50,
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
                                 tick_base = 50,
                                 leglab = "legend",
                                 lgg = list(o = "top"),
                                 forceYDomain = c(0, .5)

                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(spnd, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


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
                                 tick_base = 50,
                                 high = FALSE,
                                 leglab = "legend",
                                 lgg = list(o = "top"),
                                 forceYDomain = c(0, .8)

                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(inc_pur, glue("{theme_dir}/{d$m$title}.svg"), delay = 2 )
remove_div(glue("{theme_dir}/{d$m$title}.svg"))
#### ENVIRONMENT ####

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

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(no2, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

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

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(pm25, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

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

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(grg, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


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


#### DEMOGRAPHY ####

d <- get_data2("total_fertility_rate")

tfr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".1f",
                           high = TRUE,
                           forceYDomain = c(0, 2.3)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tfr, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("population_age_structure")
d$d$xd <- d$d$area_code
d$d$y <- d$d$y * 1000

ags <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "character",
                           omit_mod_n = 10,
                           ytickformat = ".0f",
                           high = TRUE
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ags, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("births_age_mother")
d$d$b <- d$d$area_code
bam <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".1s",
                           high = FALSE
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(bam, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("births_mothers_cob")
d$d$b <- d$d$area_code
bmcob <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".1s",
                           high = FALSE,
                           forceYDomain = c(0, 100000)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(bmcob, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("annual_change_component")
d$d$b <- d$d$area_code
acc <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                     input = list(unempl = d$d,
                                  metaopts = list( includetitles = FALSE ),
                                  chartopts = list(
                                    type = "date",
                                    ytickformat = ".1s",
                                    high = FALSE
                                  ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(acc , glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("net_migration")
d$d$b <- d$d$area_code
anm <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = d$d,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  type = "date",
                                  ytickformat = ".1s",
                                  high = FALSE
                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(anm, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

# d <- get_data2("population_age_structure")

d <- get_data2("total_migration")
d$d$b <- d$d$area_code

tm <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = d$d,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  type = "date",
                                  ytickformat = ".1s",
                                  high = FALSE
                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tm, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("total_fertility_rate")
d$d$b <- d$d$area_code

tfr <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                  input = list(unempl = d$d,
                               metaopts = list( includetitles = FALSE ),
                               chartopts = list(
                                 type = "date",
                                 ytickformat = ".1f",
                                 high = TRUE,
                                 forceYDomain = c(0, 2.3)
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tfr, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("annual_births")
d$d$o <- factor(d$d$b, levels = c("London", "Inner London", "Outer London"))
d$d <- d$d %>% arrange(xd, o)

ab <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = d$d,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  type = "date",
                                  ytickformat = ".1s",
                                  high = FALSE
                                ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(ab, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))

d <- get_data2("total_population_year")

tp <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".2s",
                           high = FALSE,
                           forceYDomain = c(6000000, 10000000)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tp, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))
#### GLOBAL CITY ####

d <- get_data2("gc_ldn_domint")
d$d$b <- d$d$area_code
d$d$xd <- d$d$timeperiod_label
out <- d$d %>% select(xd, b, y) %>%
  pivot_wider(names_from = "b", values_from = "y") %>%
  select(xd, Domestic = `Domestic visits(mil)`, International = `International Visits(mil)`)

vst <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                     input = list(unempl = out,
                                  metaopts = list( includetitles = FALSE ),
                                  chartopts = list(
                                    charttype = "bar",#
                                    stackgroup = "stack",
                                    stack = TRUE,
                                    tick_base = 50,
                                    forceYDomain = c(0, 41),
                                    # silent_x = TRUE,


                                    type = "character",
                                    ytickformat = ".0f",
                                    high = FALSE
                                  ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vst, glue("{theme_dir}/{d$m$title}.svg"), delay = 3)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gc_int_visitor_nights")
d$d$b <- d$d$area_code
d$d$xd <- d$d$timeperiod_label
out <- d$d %>% select(xd, b, y) %>%
  pivot_wider(names_from = "b", values_from = "y") %>%
  select(xd, Domestic = `Domestic Overnight Nights (Mil)`,
         International = `International Overnight Nights (Mil)`)

vnght <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           charttype = "bar",#
                           stackgroup = "stack",
                           stack = TRUE,
                           # silent_x = TRUE,
                           tick_base = 50,
                           forceYDomain = c(0, 161),


                           type = "character",
                           ytickformat = ".0f",
                           high = FALSE
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vnght, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("gc_visitor_spend")
d$d$b <- d$d$area_code
d$d$xd <- d$d$timeperiod_label
out <- d$d %>% select(xd, b, y) %>%
  pivot_wider(names_from = "b", values_from = "y") %>%
  select(xd,
         Domestic = `Domestic visitors Adjusted to 2019 Prices (£) million`,
         International = `International visitors Adjusted to 2019 Prices (£) million`)

vspnd <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = out,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           charttype = "bar",#
                           stackgroup = "stack",
                           stack = TRUE,
                           tick_base = 60,
                           # silent_x = TRUE,


                           type = "character",
                           ytickformat = ".2s",
                           high = FALSE
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vspnd, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))



d <- get_data2("gc_int_vist_ldn")

vst <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                  input = list(unempl = d$d,
                               metaopts = list( includetitles = FALSE ),
                               chartopts = list(
                                 type = "date",
                                 ytickformat = ".0f",
                                 high = TRUE
                               ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(vst, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gc_physical_engagement_arts")
d$d$xd <- d$d$timeperiod_label
d$d$xd <- str_replace_all(d$d$xd, " - ", "-")
d$d <- d$d %>% arrange(xd, desc(b))

pea <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                     input = list(unempl = d$d,
                                  metaopts = list( includetitles = FALSE ),
                                  chartopts = list(
                                    charttype = "bar",#
                                    high = TRUE,
                                    # silent_x = TRUE,
                                    tick_base = 60,


                                    type = "character",
                                    ytickformat = ".0f",
                                    high = FALSE
                                  ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(pea, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gc_digital_engagement_arts")
d$d$xd <- d$d$timeperiod_label
d$d$xd <- str_replace_all(d$d$xd, " - ", "-")
d$d <- d$d %>% arrange(xd, desc(b))

dea <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                   input = list(unempl = d$d,
                                metaopts = list( includetitles = FALSE ),
                                chartopts = list(
                                  charttype = "bar",#
                                  high = TRUE,
                                  # silent_x = TRUE,
                                    tick_base = 60,


                                  type = "character",
                                  ytickformat = ".0f",
                                  high = FALSE
                                ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(dea, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("gc_fdi_capex")
d$d$b <- d$d$area_code
d$d$text = "Chart_left"
d$d$text[which(d$d$b %in% "Capex")]<- "Chart_right"



fdi <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list(
                           includetitles = FALSE,
                           multichart = "lines_v_multi",
                           cheight = 700
                           ),
                         chartopts = list(
                           type = "quarter",
                           forcecols = list(Projects = "#6da7de", Capex = "#9e0059"),
                           ytickformat = ".0f",
                           high = FALSE
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(fdi, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


#### TFL ####

d <- get_data2("tfl_bus_speed")

bus <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0f",
                           high = FALSE,
                           forceYDomain = c(80, 123)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(bus, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("tfl_demand_idx")

dmd <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           ytickformat = ".0%",
                           high = FALSE,
                           forceYDomain = c(0.4, 0.8)
                         ) )
)

theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(dmd, glue("{theme_dir}/Travel demand on principal modes.svg"), delay = 2)
remove_div(glue("{theme_dir}/Travel demand on principal modes.svg"))


d <- get_data2("tfl_journeys")

tflj <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
            input = list(unempl = d$d,
                         metaopts = list( includetitles = FALSE ),
                         chartopts = list(
                           type = "date",
                           tick_base = 80,
                           ytickformat = ".0f",
                           high = FALSE,
                           forceYDomain = c(0, 141)
                         ) )
)


theme_dir <- glue("{output_dir}/{d$m$theme}")
save_d3_svg(tflj, glue("{theme_dir}/{d$m$title}.svg"), delay = 2)
remove_div(glue("{theme_dir}/{d$m$title}.svg"))
