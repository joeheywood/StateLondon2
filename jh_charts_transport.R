#### TFL ####
source("jh_charts_util.R")

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

update_dash_db(bus)


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

update_dash_db(dmd)


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


update_dash_db(tflj)



