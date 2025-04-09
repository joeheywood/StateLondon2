
box::use(
  shiny[h3, p, textOutput, renderText, tagList, selectInput, updateSelectInput,
        moduleServer, NS, reactive, observeEvent, observe],
  glue[glue],
  r2d3[r2d3, renderD3, d3Output]
)

box::use(
  app/logic/get_chart_data[get_chart_data],
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3(textOutput(ns("chart_ttl"))),
    p(textOutput(ns("para"))),
    d3Output(ns("d3"))

  )
}

#' @export
server <- function(id, cs) {
  moduleServer(id, function(input, output, session) {
    observe({
      deps <- c(
          "js/labels.js",
          "js/lines_qtr.js",
          "js/lines_dt.js",
          "js/lines.js",
          "js/yaxis.js" )
      dt <- get_chart_data(cs())
      output$para <- renderText({glue("From server...{cs()} {nrow(dt$d)}")})
      output$chart_ttl <- renderText({dt$m$title})
      output$d3 <- renderD3({
        r2d3(data = dt$d, script = "js/lines_chart_dt.js", dependencies = deps)
      })


    })
  })
}
