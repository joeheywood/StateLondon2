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
    cn <- dbConnect(SQLite(), "app/data/sol_dash.db")
    dat <- dbGetQuery(cn, glue("SELECT * FROM chart_data WHERE dataset = '{dtst}'")) %>%
      arrange(xd)
    m <- dbGetQuery(cn, glue("SELECT * FROM meta WHERE dataset = '{dtst}'"))
    opts <- dbGetQuery(cn, glue("SELECT * FROM opts WHERE dataset = '{dtst}'"))
    on.exit(dbDisconnect(cn))
  }, error = function(e) {
    d = data.frame(dataset = dtst, xd = "2012", b = "b", y = 1)
    m = list()
    opts = list()

  })
  return(list (
    d = select(dat, dataset, xd, b, y),
    m = m, o = opts)
  )
}
