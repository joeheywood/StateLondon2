
box::use(
  shiny[h3, p, textOutput, renderText, tagList, selectInput, updateSelectInput,
        moduleServer, NS, reactive, observeEvent],
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
    h3("Chart"),
    p(textOutput(ns("para"))),
    selectInput(ns("chapt"),
                "Chapter",
                choices = c("a", "b")),
    selectInput(ns("llos"),
                "London-level indicator",
                choices = c("a", "b")),
    selectInput(ns("chrts"),
                "Charts",
                choices = c("a", "b"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    chpt <- get_chapters()
    sel_chapt <- reactive({ input$chapt })
    sel_llo <- reactive({ input$llos })
    sel_chart <- reactive({ input$chrts })


    output$para <- renderText({"This is a paragraph to show the app working"})

    updateSelectInput(session, "chapt", choices = chpt)
    observeEvent(sel_chapt(), {
      llo <- get_LLOs(sel_chapt())
      updateSelectInput(session, "llos", choices = llo)
    })

    observeEvent(sel_llo(), {
      chrts <- get_charts(sel_chapt(), sel_llo())
      updateSelectInput(session, "chrts", choices = chrts)
    })

    reactive({
      sel_chart()
    })


  })
}
