

load(here::here('data', 'faculty_load.RData'))
faculty_load <- faculty_load_sql
agg_options <- c("term_code", "college", "department", "banner_id")

Aggregated_UI <- function(id) {
  ns <- NS(id)
  
  tagList( 
    titlePanel("Faculty Load"),
    
    wellPanel(
      h4("Here is an important thing we want to say."),
      p("Here is some text that we can use to explain what this app does.")
    ),
    
    sidebarPanel( selectInput(ns("agg_option"), 
                         "Aggregation Option",
                         choices=agg_options)
      
    ),
    
    mainPanel(
      DT::dataTableOutput( ns("agg_table" ) )
    )
  )
}

aggregated_server <- function(input, output, session){
  aggregated <- reactive({
    faculty_load %>% 
      group_by_at( input$agg_option ) %>% 
      summarise(total_enrolled_credit_hours=sum(total_enrolled_credit_hours)) %>%
      mutate(FTE=round(total_enrolled_credit_hours/12))
  })
  output$agg_table <- DT::renderDataTable(aggregated(), rownames=FALSE)
}

