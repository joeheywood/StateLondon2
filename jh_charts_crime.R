#### CRIME ####
source("jh_charts_util.R")

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


update_dash_db(vs)

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


update_dash_db(worr)

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


update_dash_db(reoff)


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


update_dash_db(tno)



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


update_dash_db(bbc)

