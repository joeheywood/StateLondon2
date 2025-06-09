source("jh_charts_util.R")

#### SCHOOL READINESS ####
d <- get_data2("cyp_gld")
d$d$xd <- d$d$timeperiod_label
out <- d$d %>% select(dataset, xd, b, y)
mss <- data.frame(dataset = "cyp_gld",
                  xd = "2020/21",
                  b = c("London", "England"), y = NA)
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

update_dash_db(gld)

#### HAPPINESS AT SCHOOL ####
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

update_dash_db(happ)

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

update_dash_db(ment_dis)

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

update_dash_db(att8)


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

update_dash_db(att8)


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

update_dash_db(lvl3)

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

update_dash_db(abs)


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

update_dash_db(susp)

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

update_dash_db(susp)
