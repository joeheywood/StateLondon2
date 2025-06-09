
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

update_dash_db(unf)


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

update_dash_db(unf)



d <- get_data2("bills_arrears")
d$d$xd <- d$d$timeperiod_label
d$d$xd <- str_replace(d$d$xd, "(\\d+)-(\\d+) - (\\d+)-(\\d+)", "\\1-\\4")

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

update_dash_db(arr)


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

update_dash_db(vr)


d <- get_data2("decision_influence")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(xd, b, y)
d$d <- bind_rows(d$d, data.frame(xd = "2022-23", b = c("London", "England"), NA))
d$d <- d$d %>% arrange(xd) %>% mutate(dataset = "decision_influence") %>% select(dataset, xd, b, y)

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

update_dash_db(decif)


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

update_dash_db(loc)



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

update_dash_db(dspg)


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

update_dash_db(ethpg)


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

update_dash_db(gnpg)


d <- get_data2("volunt_formal")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(dataset, xd, b, y)
d$d <- bind_rows(d$d, data.frame(dataset = "volunt_formal", xd = "2022-23", b = c("London", "England"), NA))
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

update_dash_db(fmlvol)

d <- get_data2("volunt_informal")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(dataset, xd, b, y)
d$d <- bind_rows(d$d, data.frame(dataset = "volunt_informal", xd = "2022-23", b = c("London", "England"), NA))
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

update_dash_db(infvol)

d <- get_data2("food_sec")
theme_dir <- glue("{output_dir}/{d$m$theme}")
file.remove(glue("{theme_dir}/{d$m$title}.svg"))


d <- get_data2("trust_neigh")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(dataset, xd, b, y)
d$d <- bind_rows(d$d, data.frame(dataset = "trust_neigh", xd = "2022-23", b = c("London", "England"), NA))
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

update_dash_db(tneigh)


d <- get_data2("talk_neigh")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(dataset, xd, b, y)
d$d <- bind_rows(d$d, data.frame(dataset = "talk_neigh", xd = "2022-23", b = c("London", "England")))
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

update_dash_db(tlkneigh)


d <- get_data2("social_action")
d$d$xd <- d$d$timeperiod_label
d$d <- d$d %>% select(dataset, xd, b, y)
d$d <- bind_rows(d$d, data.frame(dataset = "social_action", xd = "2022-23", b = c("London", "England"), NA))
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

update_dash_db(sa)



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

update_dash_db(hc)

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

update_dash_db(hlp)
