               SELECT DISTINCT
                      (sfvregd_pidm) AS pidm,
                      spriden_id AS banner_id,
                      swvstdn_styp_code AS student_type,
                      swvstdn_blck_code AS block,
                      SYSDATE AS daterun,
                      sfvregd_term_code AS term,
                      sum(sfvregd_credit_hr) AS attempted_hours,
                      CASE
                         WHEN sum(sfvregd_credit_hr) >= '12' THEN 'F'
                         WHEN sum(sfvregd_credit_hr) >= '0.5' THEN 'P'
                         ELSE 'N'
                         END AS full_part_time,
                      swvstdn_degc_code_1 AS degree,
                      swvstdn_program_1 AS cur_prgm,
                      swvstdn_majr_code_conc_1 AS concentration_1,
                      swvstdn_majr_code_conc_1_2 AS concentration_2,
                      swvstdn_resd_code AS residency,
                      spbpers_sex as gender,
                      spbpers_ssn AS ssn,
                      hs_graduation_date,
                      f_calculate_age(SYSDATE, spbpers_birth_date, spbpers_dead_date) AS age,
                      f_calc_entry_action_4(sfvregd_pidm,sfvregd_term_code) AS reg_type
                 FROM baninst1.sfvregd a
           INNER JOIN dsc.dsc_swvstdn b
                   ON b.swvstdn_term_code = a.sfvregd_term_code AND b.swvstdn_pidm = a.sfvregd_pidm
           INNER JOIN saturn.stvrsts c
                   ON c.stvrsts_code = a.sfvregd_rsts_code
           INNER JOIN saturn.spbpers d
                   ON d.spbpers_pidm = a.sfvregd_pidm
           INNER JOIN saturn.spriden e
                   ON e.spriden_pidm = a.sfvregd_pidm
            LEFT JOIN (SELECT MAX(sorhsch_graduation_date) AS hs_graduation_date,
                              sorhsch_pidm
                         FROM sorhsch
                     GROUP BY sorhsch_pidm) f
                           ON f.sorhsch_pidm = a.sfvregd_pidm
                WHERE sfvregd_term_code = '202120'
                  AND stvrsts_incl_sect_enrl = 'Y'
                  AND sfvregd_camp_code != 'XXX'
                  AND spriden_change_ind IS NULL
                  AND (SELECT count(*)
                         FROM sfrstcr, stvrsts, as_catalog_schedule
                        WHERE sfrstcr_pidm = sfvregd_pidm
                          AND sfrstcr_crn = crn_key
                          AND sfvregd_term_code = term_code_key
                          AND sfrstcr_term_code = term_code_key
                          AND sfrstcr_rsts_code = stvrsts_code
                          AND stvrsts_incl_sect_enrl = 'Y'
                          AND upper(title) NOT LIKE '%LITERACY EXAM%') > 0
                GROUP BY sfvregd_pidm,
                         swvstdn_styp_code,
                         swvstdn_blck_code,
                         SYSDATE,
                         sfvregd_term_code,
                         swvstdn_program_1,
                         swvstdn_degc_code_1,
                         swvstdn_majr_code_conc_1,
                         swvstdn_majr_code_conc_1_2,
                         swvstdn_resd_code,
                         spbpers_sex,
                         spriden_id,
                         spbpers_ssn,
                         spbpers_birth_date,
                         spbpers_dead_date,
                         hs_graduation_date