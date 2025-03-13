
box::use(
  shiny[h3, p, textOutput, renderText, tagList, selectInput, updateSelectInput,
        moduleServer, NS],
)

box::use(
  app/logic/get_chapters[get_chapters],
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Chart"),
    p(textOutput(ns("para"))),
    selectInput(ns("chapt"),
                "Chapter",
                choices = c("a", "b"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    chpt <- get_chapters()
    output$para <- renderText({"This is a paragraph to show the app working"})

    updateSelectInput(session, "chapt", choices = chpt)

  })
}
