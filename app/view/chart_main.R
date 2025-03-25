
box::use(
  shiny[h3, p, textOutput, renderText, tagList, selectInput, updateSelectInput,
        moduleServer, NS, reactive, observeEvent, observe],
  glue[glue]
)

box::use(
  app/logic/get_chapters[get_chapters],
  app/logic/get_LLOs[get_LLOs],
  app/logic/get_charts[get_charts],
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3(textOutput(ns("chart_ttl"))),
    p(textOutput(ns("para")))
  )
}

#' @export
server <- function(id, cs) {
  moduleServer(id, function(input, output, session) {
    observe({
      print(cs())
      output$para <- renderText({glue("From server...{cs()}")})

    })
  })
}
