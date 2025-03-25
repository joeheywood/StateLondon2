box::use(
  shiny[fluidPage, sidebarPanel, mainPanel, moduleServer, NS],
)
box::use(
  app/view/chart_select,
  app/view/chart_main,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  fluidPage(
    sidebarPanel(
      chart_select$ui(ns("chart_sel"))
    ),
    mainPanel(
      chart_main$ui(ns("chart_main"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    cs <- chart_select$server("chart_sel")
    cm <- chart_main$server("chart_main", cs)
  })
}
