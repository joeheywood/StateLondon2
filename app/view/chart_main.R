
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
      dt <- get_chart_data(cs())
      output$chart_ttl <- renderText({dt$m$indicator})



      deps <- c(
        "js/labels.js",
        "js/lines_qtr.js",
        "js/lines_dt.js",
        "js/lines_xaxis_chr.js",
        "js/xaxis_char.js",
        "js/bars.js",
        "js/legend.js",
        "js/lines.js",
        "js/yaxis.js" )

      tryCatch({
        if(dt$o$charttype == "line") {
          if(dt$o$type == "date") {
            scrpt <- "js/lines_chart_dt.js"
          } else if(dt$o$type == "character") {
            scrpt <- ifelse(dt$o$leglab == "legend",
                            "js/lines_chart_char_leg.js",
                            "js/lines_chart_char.js")
          }
        }

        if(dt$o$forceYDomain_t - dt$o$forceYDomain_b == 0) {
          yfc <- NULL
        } else {
          yfc <- c(dt$o$forceYDomain_b, dt$o$forceYDomain_t)
        }
        output$d3 <- renderD3({
        r2d3(data = dt$d,
             script = scrpt,
             dependencies = deps,
             options = list(
               high=TRUE,
               yfmt = dt$o$ytickformat,
               yforce = yfc
             ))
        })

      }, error = function(e) {
        print(e)
        output$chart_ttl <- renderText({glue("{dt$m$indicator} _none_")})
      })

    })
  })
}
