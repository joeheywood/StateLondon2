source("jh_charts_util.R")

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


update_dash_db(vst, stack_id = "gc_ldn_domint")




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

update_dash_db(vnght, stack_id = "gc_int_visitor_nights")



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

update_dash_db(vnght, stack_id = "gc_visitor_spend")



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

update_dash_db(vst)



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

update_dash_db(pea)



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


update_dash_db(dea)


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

update_dash_db(fdi)
