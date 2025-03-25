# app/logic/data_transformation.R
box::use(
  RSQLite[dbConnect, SQLite, dbGetQuery, dbDisconnect],
  glue[glue]
)

#' @export
get_LLOs <- function(chpt) {
  if(nchar(chpt) < 2){
    return(c(".", ".."))
  }
  cn <- dbConnect(SQLite(), "app/data/sol_llo.db")
  qry <- glue("SELECT DISTINCT llo FROM meta WHERE theme = '{chpt}'")
  dat <- dbGetQuery(cn, qry)
  on.exit(dbDisconnect(cn))
  return(as.character(dat$llo))
}
