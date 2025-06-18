#### DEMOGRAPHY ####
source("jh_charts_util.R")

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

update_dash_db(tfr)


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

update_dash_db(ags)

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

update_dash_db(bam)

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

update_dash_db(bmcob)



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

update_dash_db(acc )

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

update_dash_db(anm)

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

update_dash_db(tm)

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

update_dash_db(tfr)


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

update_dash_db(ab)

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

update_dash_db(tp)
