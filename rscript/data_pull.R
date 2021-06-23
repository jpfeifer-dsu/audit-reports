# Libraries ####

library(tidyverse)
library(DBI)
library(odbc)
library(here)
library(janitor)

# CONNECTION OBJECT ####
source(here::here('rscript', 'dsu_odbc_prod_connection_object.R'))

student_sql <- dbGetQuery(con, read_file(here::here('sql', 'student.sql'))) %>% 
  mutate_if(is.factor, as.character) %>% 
  clean_names() %>% 
  as_tibble()

cohorts_sql <- dbGetQuery(con, read_file(here::here('sql', 'cohorts.sql'))) %>% 
  mutate_if(is.factor, as.character) %>% 
  clean_names() %>% 
  as_tibble()

courses_sql <- dbGetQuery(con, read_file(here::here('sql', 'courses.sql'))) %>% 
  mutate_if(is.factor, as.character) %>% 
  clean_names() %>% 
  as_tibble()

# Save data as a RDate file
save(student_sql, file = here::here('data', 'students.RData'))
save(cohorts_sql, file = here::here('data', 'cohorts.RData'))
save(courses_sql, file = here::here('data', 'courses.RData'))

