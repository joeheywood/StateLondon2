# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue]
)

#' @export
get_chart_data <- function(dtst) {
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  dat <- dbGetQuery(cn, glue("SELECT * FROM charts_data WHERE dataset = '{dtst}'"))
  on.exit(dbDisconnect(cn))
  return(dat)
}
