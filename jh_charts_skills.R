source("jh_charts_util.R")
#### SKILLS ####
d <- get_data2("fe_skills")
d$d <- d$d %>% filter(area_name %in% "London", !area_code %in% "Overall positive destination")
d$d$xd <- d$d$timeperiod_label
d$d$b <- d$d$area_code

out <- d$d %>% select(dataset, xd, b, y) %>%
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

update_dash_db(fes, stack_id = "fe_skills")


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

update_dash_db(grad)


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

update_dash_db(jp)


d <- get_data2("top_skills")
d$d <- d$d %>% filter(area_code == "Common")
d$d$xd <- d$d$area_name
d$d$b <- d$d$timeperiod_label
d$d$order <- factor(d$d$xd,
                    levels = ordered$xd)
d$d <- d$d %>% arrange(desc(b), order)
out <- d$d %>% select(dataset, xd, b, y)


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

update_dash_db(ts_c)

d <- get_data2("top_skills")
d$d <- d$d %>% filter(area_code == "Specialised")
d$d$xd <- d$d$area_name
d$d$b <- d$d$timeperiod_label
ordered <- d$d %>% filter(b == "Jan-Mar 2025") %>% arrange(y)
d$d$order <- factor(d$d$xd,
                    levels = ordered$xd)
d$d <- d$d %>% arrange(desc(b), order)
out <- d$d %>% select(dataset, xd, b, y)


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
