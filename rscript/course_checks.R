library(tidyverse)
library(lubridate)
library(janitor)

source(here::here('rscript', 'dsu_odbc_prod_connection_object.R'))

courses_sql <- load_data_from_rds('courses.RData')

courses_columns01 <- c('term', 'crn', 'subject_code')
courses_columns02 <- c('error_message')

#Function Definitions
fn_return_data <- function(data, category, message, table_name, column_name) {
  output_data <- {{data}} %>%
    mutate(category = {{category}},
           error_message = {{message}},
           banner_table = {{table_name}},
           banner_column = {{column_name}}) %>%
    ungroup() %>%
    ## Sorting Data
    arrange(term, crn) %>%
    return (output_data)
}

#Courses
crse_check_01 <- filter(courses_sql, active_ind != 'A' & enrollment > 0) %>%
  fn_return_data('Courses', 'Cancelled course still has enrollments') %>%
  select(all_of(courses_columns01))
