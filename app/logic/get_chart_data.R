# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue],
  dplyr[select]
)

#' @export
get_chart_data <- function(dtst) {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  dat <- dbGetQuery(cn, glue("SELECT * FROM charts_data WHERE dataset = '{dtst}'"))
  m <- dbGetQuery(cn, glue("SELECT * FROM meta WHERE dataset = '{dtst}'"))
  on.exit(dbDisconnect(cn))
  dat$xd <- as.character(as.Date(dat$timeperiod_sortable, format = "%Y%m%d"))
  dat$b <- dat$area_name
  dat$y <- dat$value
  return(list (
    d = select(dat, dataset, xd, b, y),
    m = m)
  )
}
