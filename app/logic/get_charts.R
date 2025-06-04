# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue]
)

#' @export
get_charts <- function(chpt, llo) {
  if(nchar(chpt) < 2 | nchar(llo) < 2){
    return(c(".", "_"))
  }
  cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
  qry <- glue("SELECT DISTINCT dataset, indicator FROM meta WHERE theme = '{chpt}' AND llo = \"{llo}\"")
  dat <- dbGetQuery(cn, qry)
  out <- as.character(dat$dataset)
  names(out) <- as.character(dat$indicator)
  on.exit(dbDisconnect(cn))

  return(out)
}
