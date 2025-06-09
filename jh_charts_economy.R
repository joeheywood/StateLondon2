#### ECONOMY ####

source("jh_charts_util.R")
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


update_dash_db(gva)

d <- get_data2("gva")
fl <- glue("{theme_dir}/{d$m$title}.svg")
if(file.exists(fl))file.remove(fl)



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
out <- d$d %>% select(xd, b, y) %>% mutate(dataset = "jq_score")

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

update_dash_db(jqs)


d <- get_data2("gva_composition")
d$d$xd <- d$d$area_name
d$d$b <- "London"
out <- d$d %>% select(dataset, xd, b, y)

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

update_dash_db(gva_comp)


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

update_dash_db(prod)


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

# update_dash_db(eu, stack_id = "extended_unemployment")
# not working. stacked bar


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

update_dash_db(ff)

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

update_dash_db(spnd)


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

update_dash_db(inc_pur)


