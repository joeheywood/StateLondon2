# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue],
  dplyr[select,`%>%`, arrange],
  stringr[str_replace_all, str_detect]
)

#' @export
get_chart_data <- function(dtst) {
  tryCatch({

    cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
    dat <- dbGetQuery(cn, glue("SELECT * FROM charts_data WHERE dataset = '{dtst}'")) %>%
      arrange(timeperiod_sortable)
    m <- dbGetQuery(cn, glue("SELECT * FROM meta WHERE dataset = '{dtst}'"))
    on.exit(dbDisconnect(cn))
    zeroes <- which(str_detect(dat$timeperiod_sortable, "0{4}$"))
    dat$timeperiod_sortable[zeroes] <- str_replace_all(dat$timeperiod_sortable[zeroes], "0000", "0101")
    dat$xd <- as.character(as.Date(dat$timeperiod_sortable, format = "%Y%m%d"))
    dat$b <- dat$area_name
    dat$y <- dat$value

x
  }, error = function(e) {
    d = data.frame(dataset = dtst, xd = "2012", b = "b", y = 1)
    m = list()
    opts = list()

  })
  return(list (
    d = select(dat, dataset, xd, b, y),
    m = m)
  )
}
