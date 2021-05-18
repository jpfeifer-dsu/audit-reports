

load(here::here('data', 'faculty_load.RData'))
faculty_load <- faculty_load_sql
term_codes <- sort(unique(faculty_load$term_code))
instructor_statuses <- sort(unique(faculty_load$instructor_status))
colleges <- sort(unique(faculty_load$college))
departments <- sort(unique(faculty_load$department))
course_levels <- c("1000-2000", "3000-4000", "5000+")


disaggregated_UI <- function(id) {
  ns <- NS(id)
  
  tagList( 
    titlePanel("Faculty Load"),
    
    wellPanel(
      h4("Here is an important thing we want to say."),
      p("Here is some text that we can use to explain what this app does.")
    ),
    
    fluidRow( 
      column(2,
             textInput(ns("banner_id"), "Banner ID")
      ),
      column(2,
             pickerInput(ns("term_code"), "Term Code", 
                         term_codes, 
                         options=list(`actions-box`=TRUE), 
                         multiple=TRUE,
                         selected=term_codes)
      ),
      column(2,
             pickerInput(ns("instructor_status"), "Instructor Status", 
                         instructor_statuses, 
                         options=list(`actions-box`=TRUE), 
                         multiple=TRUE,
                         selected=instructor_statuses)
      ),
      column(2,
             pickerInput(ns("college"), "College", 
                         colleges, 
                         options=list(`actions-box`=TRUE), 
                         multiple=TRUE,
                         selected=colleges)
      ),
      column(2,
             pickerInput(ns("department"), "Department", 
                         departments, 
                         options=list(`actions-box`=TRUE), 
                         multiple=TRUE,
                         selected=departments)
      ),
      column(2,
             pickerInput(ns("course_level"), "Course Level", 
                         course_levels, 
                         options=list(`actions-box`=TRUE), 
                         multiple=TRUE,
                         selected=course_levels)
      )
    ),
    
    mainPanel(
      DT::dataTableOutput( ns("disagg_table" ) )
    )
  )
}

disaggregated_server <- function(input, output, session){
  filtered <- reactive({
    course_prefixes <- as.integer(substr(faculty_load$course_number, start=1, stop=1))
    rows <- (faculty_load$term_code %in% input$term_code) &
      (faculty_load$instructor_status %in% input$instructor_status) &
      (faculty_load$college %in% input$college) &
      (faculty_load$department %in% input$department) &
      (faculty_load$banner_id == input$banner_id | input$banner_id == '') &
      ( (course_prefixes %in% c(1,2) & "1000-2000" %in% input$course_level) |
          (course_prefixes %in% c(3,4) & "3000-4000" %in% input$course_level) |
          (course_prefixes >= 5 & "5000+" %in% input$course_level) )
    subset(faculty_load, rows) 
  })
  output$disagg_table <- DT::renderDataTable(filtered(), rownames=FALSE)
}

