source("jh_charts_util.R")

#### INFANT MORTALITY ####

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
                                  ytickformat = ".0f",
                                  high = TRUE,
                                  leglab = "legend",
                                  lgg = list(o = "top"),
                                  forceYDomain = c(0, 6)
                                ) )
)

update_dash_db(i_m)


#### SAFETY ####
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


update_dash_db(safe)
rms <- c("~/Projects/sol_svgs/CYP/Percentage feel safe in the area where they live.svg",
         "~/Projects/sol_svgs/CYP/Percentage feel safe when they are at school.svg",
         "~/Projects/sol_svgs/CYP/Percentage feel safe online.svg")

for(r in rms) {
  if(file.exists(r)) {
    file.remove(r)
  }
}


#### OBESITY ####
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
                                  ytickformat = ".0f",
                                  high = TRUE,
                                  leglab = "legend"
                                ) )
)

update_dash_db(obs)


#### INFORMAL VOLUNTEERING ####
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

update_dash_db(iv)


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

update_dash_db(hle)


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

update_dash_db(le)

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

update_dash_db(lsanx)



#### NOT SAVED CHILDHOOD VACC ####
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

