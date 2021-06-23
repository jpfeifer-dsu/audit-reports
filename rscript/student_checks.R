library(tidyverse)
library(lubridate)
library(janitor)


load_data_from_rds('courses.RData')
load_data_from_rds('courses.RData')


#Function Definitions
fn_return_data <- function(data, category, message, table_name, column_name) {
  output_data <- {{data}} %>%
    mutate(category = {{category}},
           error_message = {{message}},
           banner_table = {{table_name}},
           banner_column = {{column_name}}) %>%
    ungroup()
  return (output_data)
}

#Variables
columns01 <- c('term', 'pidm', 'banner_id', 'first_name', 'last_name')
columns02 <- c('error_message')
columns03 <- c('banner_table', 'banner_column')
columns04 <- c('ssbsect_term_code', 'ssbsect_crn', 'ssbsect_subj_code', 'ssbsect_crse_numb', 'ssbsect_seq_numb', 'ssbsect_enrl')

#Demographics - Gender
filter_error_01 <- filter(student_sql,!gender %in% c('M', 'F') | is.na(gender))
error_check_01 <- fn_return_data(filter_error_01, 'Demographics', 'Gender is is blank', 'spbpers', 'spbpers_sex') %>%
  select(all_of(columns01), gender, all_of(columns02), all_of(columns03))

#Demographics - County
filter_error_02 <- filter(student_sql, admit_country == 'US' & is.na(admit_county))
error_check_02 <- fn_return_data(filter_error_02, 'Demographics', 'Missing County', 'sabsupl', 'sabsupl_cnty_code_admit') %>%
  select(all_of(columns01), admit_country, admit_county, all_of(columns02), all_of(columns03))

#Demographics - State
filter_error_03 <- filter(student_sql, admit_country == 'US' & is.na(admit_state))
error_check_03 <- fn_return_data(filter_error_03, 'Demographics', 'Missing State', 'sabsupl', 'sabsupl_stat_code_admit') %>%
  select(all_of(columns01), admit_state, all_of(columns02), all_of(columns03))

#Demographics - County
filter_error_04 <- filter(student_sql, admit_state == 'UT' & is.na(admit_county))
error_check_04 <- fn_return_data(filter_error_04, 'Demographics', 'Utah applicant missing county', 'sabsupl', 'sabsupl_cnty_code_admit') %>%
  select(all_of(columns01), admit_state, admit_county, all_of(columns02), all_of(columns03))

#Demographics - Country
filter_error_05 <- filter(student_sql, admit_state == 'UT' & is.na(admit_country))
error_check_05 <- fn_return_data(filter_error_05, 'Demographics', 'Missing Country', 'sabsupl', 'sabsupl_natn_code_admit') %>%
  select(all_of(columns01), admit_state, all_of(columns02), all_of(columns03))

#Demographics - Visa Errors
today <- lubridate::now()
filter_error_06 <-   filter(student_sql,(
  citz_code != '2' & !is.na(visa_type)
  | citz_code == '2' & is.na(visa_type)
  | !citz_code %in% c('2', '3') & !is.na(visa_type)
  | citz_code == '2' & is.na(visa_type))
  & (visa_expire_date > today | is.na(visa_expire_date))
)
error_check_06 <- fn_return_data(filter_error_06, 'Demographics', 'Invalid Visa Type or Citz Code', 'spbpers, gorvisa', 'spbpers_citz_code, gorvisa_vtyp_code') %>%
  select(all_of(columns01), citz_code, visa_type, all_of(columns02), all_of(columns03))

#Demographics - High School Code
filter_error_07 <- filter(student_sql, is.na(high_school_code) & age < 20)
error_check_07 <- fn_return_data(filter_error_07, 'Demographics', 'Missing HS Code', 'sorhsch', 'sorhsch_sbgi_code') %>%
  select(all_of(columns01), age, high_school_code, all_of(columns02), all_of(columns03))

#Demographics - High School Graduation Date
filter_error_08 <- filter(student_sql, birth_date >= high_school_grad_date)
error_check_08 <- fn_return_data(filter_error_08, 'Demographics', 'DOB must be before HS Graduation Date', 'sorhsch, spbpers', 'sorhsch_graduation_date, spbpers_birth_date') %>%
  select(all_of(columns01), age, high_school_grad_date, all_of(columns02), all_of(columns03))

#Demographics - Duplicate SSN's
filter_error_09 <- filter(student_sql, !is.na(student_sql$ssn)) %>%
  get_dupes(ssn)
error_check_09 <- fn_return_data(filter_error_09, 'Demographics', 'Duplicate SSN', 'spbpers', 'spbpers_ssn') %>%
  select(all_of(columns01), all_of(columns02), all_of(columns03))

#Demographics - Null citizenship
filter_error_10 <- filter(student_sql, is.na(citz_code))
error_check_10 <- fn_return_data(filter_error_10, 'Demographics', 'Null citizenship code found', 'spbpers', 'spbpers_citz_code') %>%
  select(all_of(columns01), citz_code, all_of(columns02), all_of(columns03))

#Demographics - High School Graduation Date is NULL
filter_error_11 <- filter(student_sql, is.na(high_school_grad_date) & student_type != 'P')
error_check_11 <- fn_return_data(filter_error_11, 'Demographics', 'Missing High School Graduation Date', 'sorhsch', 'sorhsch_graduation_date') %>%
  select(all_of(columns01), student_type, high_school_grad_date, all_of(columns02), all_of(columns03))

#PROGRAM CHECKS

#Programs - Lists Two active matriculations
#filter_programs_01 <- filter(student_sql, !major_code != 'RN' & !cur_prgm, 'BS-NURS-P', 'AA'))
#programs_check_01 <- fn_return_data(student_sql, 'Programs', 'Two active matriculations', 'swvstdn', 'swvstdn_program_1') %>%
  #select(all_of(columns01), cur_prgm, all_of(columns02), all_of(columns03))

#Programs - HS students with no ND-CONC
filter_programs_01 <- filter(student_sql, !cur_prgm %in% c('ND-CONC','ND-SA','ND-CE', 'ND-ACE') & entry_action == 'HS' & ! is.na(cur_prgm))
programs_check_01 <- fn_return_data(filter_programs_01, 'Programs', 'Entry Action is HS and not a Non-Degree Program', 'sorlcur', 'sorlcur_program') %>%
  select(all_of(columns01), entry_action, cur_prgm, high_school_grad_date, all_of(columns02), all_of(columns03))

#Programs - Blank Programs
filter_programs_02 <- filter(student_sql, is.na(cur_prgm))
programs_check_02 <- fn_return_data(filter_programs_02, 'Programs', 'Blank Program', 'sorlcur', 'sorlcur_program') %>%
  select(all_of(columns01), degree, major_code, cur_prgm, all_of(columns02), all_of(columns03))


#STUDENT TYPE CHECKS

#Student Type - Checks to make sure student is returning student
filter_students_01 <- filter(student_sql, ! is.na(first_term_enrolled_start_date) & first_term_enrolled_start_date > high_school_grad_date && student_type == 'R')
stype_check_01 <- fn_return_data(filter_students_01, 'Student Type', 'First term enrolled is greater than HS grad date') %>%
  select(all_of(columns01), entry_action, first_term_enrolled, high_school_grad_date, all_of(columns02))

#Student Type - HS Concurrent Enrollment
filter_students_02 <- filter(student_sql, term_start_date > high_school_grad_date & student_type == 'H')
stype_check_02 <- fn_return_data(filter_students_02, 'Student Type', 'Start Term Date is Greater Than HS Grad Date', 'shrtgpa, sfrstcr', 'shrtgpa_term_code, sfrstcr_term_code') %>%
  select(all_of(columns01), term_start_date, high_school_grad_date, student_type, all_of(columns02))

filter_students_03 <- filter(student_sql, student_type == 'H' & !cur_prgm %in% c('ND-ACE', 'ND-CONC', 'ND-SA'))
stype_check_03 <- fn_return_data(filter_students_03, 'Student Type', 'Concurrent Student not in a HS Program') %>%
  select(all_of(columns01), cur_prgm, student_type, entry_action, all_of(columns02))

#Student Type - Personal Interest Students - NM
filter_students_04 <- filter(student_sql, student_type == 'P' & !cur_prgm %in% c('ND-CE', 'ND-ESL') & ! is.na(cur_prgm))
stype_check_04 <- fn_return_data(filter_students_04, 'Student Type', 'Degree Seeking Program, but Personal Interest Student Type') %>%
  select(all_of(columns01), cur_prgm, student_type, entry_action, all_of(columns02))

#Student Type - New Graduates
filter_students_05 <- filter(student_sql, !student_level == 'GR' & student_type == '1')
stype_check_05 <- fn_return_data(filter_students_05, 'Student Type', 'Graduate Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_06 <- filter(student_sql, student_level == 'GR'  & student_type == '1' & ! is.na(first_term_enrolled))
stype_check_06 <- fn_return_data(filter_students_06, 'Student Type', 'Graduate student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, student_type, entry_action, all_of(columns02))

filter_students_07 <- filter(student_sql, student_level == 'GR' & student_type == '1' & ! is.na(last_transfer_term))
stype_check_07 <- fn_return_data(filter_students_07, 'Student Type', 'Graduate student has transfer record') %>%
  select(all_of(columns01), last_transfer_term, student_type, entry_action, all_of(columns02))

#Student Type - Continuing Graduates
filter_students_08 <- filter(student_sql, !student_level == 'GR' & student_type == '5')
stype_check_08 <- fn_return_data(filter_students_08, 'Student Type', 'Graduate Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_09 <- filter(student_sql, student_level == 'GR' & student_type == '5' & is.na(first_term_enrolled))
stype_check_09 <- fn_return_data(filter_students_09, 'Student Type', 'Graduate Student Level and type does not align') %>%
  select(all_of(columns01), first_term_enrolled, student_type, entry_action, all_of(columns02))

#Student Type - Transfer Graduates
filter_students_10 <- filter(student_sql, !student_level == 'GR' & student_type == '2')
stype_check_10 <- fn_return_data(filter_students_10, 'Student Type', 'Graduate Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_11 <- filter(student_sql, student_level == 'GR' & student_type == '2' & ! is.na(first_term_enrolled))
stype_check_11 <- fn_return_data(filter_students_11, 'Student Type', 'Graduate student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, student_type, entry_action, all_of(columns02))

filter_students_12 <- filter(student_sql, student_level == 'GR' & student_type == '1' &  !is.na(last_transfer_term))
stype_check_12 <- fn_return_data(filter_students_12, 'Student Type', 'Graduate student has transfer record') %>%
  select(all_of(columns01), last_transfer_term, student_type, entry_action, all_of(columns02))

#Student Type = Readmitted Gradutes
filter_students_13 <- filter(student_sql, !student_level == 'GR' & student_type == '4')
stype_check_13 <- fn_return_data(filter_students_13, 'Student Type', 'Graduate Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_14 <- filter(student_sql, student_level == 'GR' & student_type == '4' & ! is.na(first_term_enrolled))
stype_check_14 <- fn_return_data(filter_students_14, 'Student Type', 'Graduate student has not attended before') %>%
  select(all_of(columns01), first_term_enrolled, student_type, entry_action, all_of(columns02))

filter_students_15 <- select(student_sql, everything()) %>%
  mutate(days_since_last_enrolled = difftime(term_start_date,last_term_enrolled_end_date)) %>%
  filter(student_level == 'GR' & student_type == '4' & days_since_last_enrolled < 240)
stype_check_15 <- fn_return_data(filter_students_15, 'Student Type', 'Graduate student has not attended before') %>%
  select(all_of(columns01), student_level, student_type, entry_action, last_term_enrolled, all_of(columns02))

#Transfers - Undergraduates
filter_students_16 <- filter(student_sql, !student_level == 'UG' & student_type == 'T')
stype_check_16 <- fn_return_data(filter_students_16, 'Student Type', 'Undergraduate Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))  
  
filter_students_17 <- filter(student_sql, student_level == 'UG' & student_type == 'T' & ! is.na(first_term_enrolled))
stype_check_17 <- fn_return_data(filter_students_17, 'Student Type', 'Student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, student_type, entry_action, all_of(columns02))

filter_students_18 <- filter(student_sql, student_level == 'UG' & student_type %in% c('N', 'F') &  !is.na(last_transfer_term))
stype_check_18 <- fn_return_data(filter_students_18, 'Student Type', 'Student has transfer record') %>%
  select(all_of(columns01), last_transfer_term, student_type, entry_action, all_of(columns02))

filter_students_19 <- filter(student_sql, student_level == 'UG' & student_type == 'T' & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term)
stype_check_19 <- fn_return_data(filter_students_19, 'Student Type', 'Student has a cohort record') %>%
  select(all_of(columns01), sgrchrt_chrt_code, student_type, first_term_enrolled, last_term_enrolled, entry_action, sgrchrt_chrt_code, sgrchrt_term_code_eff, all_of(columns02))

#First-time Freshman (FF)
filter_students_20 <- filter(student_sql, !student_level == 'UG' & student_type == 'F')
stype_check_20 <- fn_return_data(filter_students_20, 'Student Type', 'Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_21 <- filter(student_sql, 
                             student_level == 'UG'  & 
                             student_type == 'F' & 
                             !is.na(first_term_enrolled) & 
                             first_term_enrolled < term &
                             first_term_enrolled_start_date > high_school_grad_date
                             )
stype_check_21 <- fn_return_data(filter_students_21, 'Student Type', 'Student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, last_term_enrolled, high_school_grad_date, student_type, entry_action, all_of(columns02))

filter_students_22 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           student_type == 'F' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation < 365
         ) 
stype_check_22 <- fn_return_data(filter_students_22, 'Student Type', 'Graduated from HS within a year') %>%
  select(all_of(columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(columns02))

filter_students_23 <- filter(student_sql, student_level == 'UG' & student_type == 'F' & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term)
stype_check_23 <- fn_return_data(filter_students_23, 'Student Type', 'Student has a cohort record') %>%
  select(all_of(columns01), sgrchrt_chrt_code, student_type, first_term_enrolled, last_term_enrolled, entry_action, sgrchrt_chrt_code, sgrchrt_term_code_eff, all_of(columns02))

#First-time Freshman Highschool (FH)
filter_students_24 <- filter(student_sql, !student_level == 'UG' & student_type == 'N')
stype_check_24 <- fn_return_data(filter_students_24, 'Student Type', 'Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_25 <- filter(student_sql, 
                             student_level == 'UG'  & 
                               student_type == 'N' & 
                               !is.na(first_term_enrolled) & 
                               first_term_enrolled < term &
                               first_term_enrolled_start_date > high_school_grad_date
)
stype_check_25 <- fn_return_data(filter_students_25, 'Student Type', 'Student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, last_term_enrolled, high_school_grad_date, student_type, entry_action, all_of(columns02))

filter_students_26 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           student_type == 'N' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation > 365
  ) 
stype_check_26 <- fn_return_data(filter_students_26, 'Student Type', 'Graduated from HS within a year') %>%
  select(all_of(columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(columns02))

filter_students_27 <- filter(student_sql, student_level == 'UG' & student_type == 'N' & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term)
stype_check_27 <- fn_return_data(filter_students_27, 'Student Type', 'Student has a cohort record') %>%
  select(all_of(columns01), sgrchrt_chrt_code, student_type, first_term_enrolled, last_term_enrolled, entry_action, sgrchrt_chrt_code, sgrchrt_term_code_eff, all_of(columns02))

#Entry Action (FF)
filter_students_28 <- filter(student_sql, !student_level == 'UG' & entry_action == 'FF')
stype_check_28 <- fn_return_data(filter_students_28, 'Student Type', 'Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_29 <- filter(student_sql, 
                             student_level == 'UG'  & 
                               entry_action == 'FF' & 
                               !is.na(first_term_enrolled) & 
                               first_term_enrolled < term &
                               first_term_enrolled_start_date > high_school_grad_date
)
stype_check_29 <- fn_return_data(filter_students_29, 'Student Type', 'Student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, last_term_enrolled, high_school_grad_date, student_type, entry_action, all_of(columns02))

filter_students_30 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           entry_action == 'FF' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation < 365
  ) 
stype_check_30 <- fn_return_data(filter_students_30, 'Student Type', 'Graduated from HS within a year') %>%
  select(all_of(columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(columns02))

filter_students_31 <- filter(student_sql, student_level == 'UG' & entry_action == 'FF' & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term)
stype_check_31 <- fn_return_data(filter_students_31, 'Student Type', 'Student has a cohort record') %>%
  select(all_of(columns01), sgrchrt_chrt_code, student_type, first_term_enrolled, last_term_enrolled, entry_action, sgrchrt_chrt_code, sgrchrt_term_code_eff, all_of(columns02))

#Entry Action (FH)
filter_students_32 <- filter(student_sql, !student_level == 'UG' & entry_action == 'FH')
stype_check_32 <- fn_return_data(filter_students_32, 'Student Type', 'Student Level and type does not align') %>%
  select(all_of(columns01), student_level, student_type, entry_action, all_of(columns02))

filter_students_33 <- filter(student_sql, 
                             entry_action == 'FH'  & 
                             !is.na(first_term_enrolled) & 
                             first_term_enrolled < term &
                             first_term_enrolled_start_date > high_school_grad_date
)
stype_check_33 <- fn_return_data(filter_students_33, 'Student Type', 'Student has already attended') %>%
  select(all_of(columns01), first_term_enrolled, last_term_enrolled, high_school_grad_date, student_type, entry_action, all_of(columns02))

filter_students_34 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           entry_action == 'FH' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation > 365
  ) 
stype_check_34 <- fn_return_data(filter_students_34, 'Student Type', 'Graduated from HS within a year') %>%
  select(all_of(columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(columns02))

filter_students_35 <- filter(student_sql, student_level == 'UG' & entry_action == 'FH' & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term)
stype_check_35 <- fn_return_data(filter_students_35, 'Student Type', 'Student has a cohort record') %>%
  select(all_of(columns01), sgrchrt_chrt_code, student_type, first_term_enrolled, last_term_enrolled, entry_action, sgrchrt_chrt_code, sgrchrt_term_code_eff, all_of(columns02))

#Courses
filter_courses_01 <- filter(courses_sql, ssbsect_ssts_code != 'A' & ssbsect_enrl > 0)
crse_check_01 <- fn_return_data(filter_courses_01, 'Courses', 'Cancelled course still has enrollments') %>%
  select(all_of(columns04))







