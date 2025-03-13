box::use(
  shiny[fluidPage, sidebarPanel, mainPanel, moduleServer, NS],
)
box::use(
  app/view/chart_select,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  fluidPage(
    sidebarPanel(
      chart_select$ui(ns("chart_sel"))
    ),
    mainPanel(
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    chart_select$server("chart_sel")
  })
}
