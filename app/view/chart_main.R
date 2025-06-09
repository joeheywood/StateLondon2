
box::use(
  shiny[h3, p, textOutput, renderText, tagList, selectInput, updateSelectInput,
        moduleServer, NS, reactive, observeEvent, observe],
  glue[glue],
  r2d3[r2d3, renderD3, d3Output]
)

box::use(
  app/logic/get_chart_data[get_chart_data],
  app/logic/run_chart[run_chart]
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
      dt <- get_chart_data(cs())
      output$chart_ttl <- renderText({dt$m$indicator})
      # tryCatch({
        dd <- run_chart(dt)
        output$d3 <- renderD3({run_chart(dt)})
      # }, error = function(e) {
      #   print(glue("ERROR WITH {cs()}"))
      #   output$chart_ttl <- renderText({glue("{dt$m$indicator}) _ {cs()}")})
      # } )


    })
  })
}
