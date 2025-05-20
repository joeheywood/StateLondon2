library(git2r)
library(glue)
library(RSQLite)

update_db_fl <- function() {
  repo <- repository("~/Projects/llo_state_london_data/")
  p <- git2r::pull(repo)
  if(p$fast_forward == TRUE) {
    fl <- "~/Projects/llo_state_london_data/data/sol_llo.db"

    inf <- file.info("app/data/sol_llo.db")

    if(test_all_meta(fl) == TRUE) {
      file.rename("app/data/sol_llo.db",
                  format(inf$mtime, "archived_data/sol_llo%Y%m%d.db"))


      file.copy("~/Projects/llo_state_london_data/data/sol_llo.db",
                "app/data/sol_llo.db")

    }


  }


}




test_all_meta <- function(fl) {
  cn <- dbConnect(SQLite(), fl)
  mt <- dbGetQuery(cn, "select dataset from meta")
  cd <- dbGetQuery(cn, "select distinct dataset from charts_data")
  print(glue("Checking meta and data match: {nrow(mt)} rows"))
  dbDisconnect(cn)
  all(c(mt$dataset %in% cd$dataset, cd$dataset %in% mt$dataset))
}
