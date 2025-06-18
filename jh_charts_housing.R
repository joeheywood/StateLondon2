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

update_dash_db(rp)

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

update_dash_db(cr)


d <- get_data2("roughsleeping_first_time") # needs to be a stacked bar
out <- d$d %>% select(xd, b, y) %>% pivot_wider(names_from = "b", values_from = "y") %>%
  select(xd, `No second night out`, `Second night out but not living on the streets`,
         `Joined living on the streets population`)





rgh_first <- robservable("@joe-heywood-gla/gla-dpa-chart", include = "chrt", # could force colours?
                         input = list(unempl = d$d,
                                      metaopts = list(
                                        includetitles = FALSE),
                                      chartopts = list(
                                        type = "quarter",
                                        ytickformat = ".0f"
                                      ) )
)

update_dash_db(rgh_first)


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

update_dash_db(hmd)


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

update_dash_db(mss_py)

d <- get_data2("hmls")
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

update_dash_db(hml, stack_id = "hmls")

