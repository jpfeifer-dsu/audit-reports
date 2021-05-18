# Libraries ####

library(tidyverse)
library(DBI)
library(here)
library(janitor)

# CONNECTION OBJECT ####
source(here::here('rscript', 'dsu_odbc_connection_object.R'))

faculty_load_sql <- dbGetQuery(con, read_file(here::here('sql', 'faculty_load.sql'))) %>% 
  mutate_if(is.factor, as.character) %>% 
  clean_names() %>% 
  as_tibble()

# csv file to explore the data
#write_csv(adjunct_faculty_sql, here::here('data', 'faculty_load.csv'))
# RData loads into the app easier
save(faculty_load_sql, file = here::here('data', 'faculty_load.RData'))
