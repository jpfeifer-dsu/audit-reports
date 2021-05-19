library(tidyverse)
library(Hmisc)

#stats
a <- select(demographics_sql, 
            pidm, 
            banner_id, 
            gender,
            hs_graduation_date,
            age,
            reg_type,
            attempted_hours, 
            full_part_time,
            student_type,
            degree,
            cur_prgm,
            residency
            )

#stats <- describe(a) %>%
  #html()




