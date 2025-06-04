# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
)

#' @export
get_chapters <- function() {
  cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
  qr <- dbGetQuery(cn, "SELECT DISTINCT theme FROM meta")
  on.exit(dbDisconnect(cn))
  return(as.character(qr$theme))
}
