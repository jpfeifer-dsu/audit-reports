               SELECT DISTINCT
                      (sfvregd_pidm) AS pidm,
                      spriden_id AS banner_id,
                      spriden_first_name AS first_name,
                      spriden_last_name AS last_name,
                      f_format_name(sfvregd_pidm, 'FML') AS full_name,
                      swvstdn_styp_code AS student_type,
                      sgbstdn_levl_code AS student_level,
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
                      spbpers_birth_date AS birth_date,
                      spbpers_citz_code AS citz_code,
                      gorvisa_vtyp_code AS visa_type,
                      gorvisa_visa_expire_date AS visa_expire_date,
                      high_school_grad_date,
                      high_school_code,
                      f_calculate_age(SYSDATE, spbpers_birth_date, spbpers_dead_date) AS age,
                      h.sabsupl_cnty_code_admit AS admit_county,
                      h.sabsupl_stat_code_admit AS admit_state,
                      h.sabsupl_natn_code_admit AS admit_country,
                      h.sabsupl_term_code_entry AS ea_term_code,
                      h.sabsupl_appl_no AS appl_num,
                      f_calc_entry_action_4(sfvregd_pidm,sfvregd_term_code) AS entry_action
                 FROM baninst1.sfvregd a
           INNER JOIN dsc.dsc_swvstdn b
                   ON b.swvstdn_term_code = a.sfvregd_term_code AND b.swvstdn_pidm = a.sfvregd_pidm
           INNER JOIN saturn.stvrsts c
                   ON c.stvrsts_code = a.sfvregd_rsts_code
           INNER JOIN saturn.spbpers d
                   ON d.spbpers_pidm = a.sfvregd_pidm
           INNER JOIN saturn.spriden e
                   ON e.spriden_pidm = a.sfvregd_pidm
            LEFT JOIN (SELECT MAX(sorhsch_graduation_date) AS high_school_grad_date,
                              sorhsch_pidm,
                              sorhsch_sbgi_code AS high_school_code
                         FROM sorhsch
                     GROUP BY sorhsch_pidm,
                              sorhsch_sbgi_code) f
                           ON f.sorhsch_pidm = a.sfvregd_pidm
            LEFT JOIN (SELECT MAX(sabsupl_appl_no||sabsupl_term_code_entry) sabsupl_key,
                              sabsupl_pidm
                         FROM sabsupl
                        WHERE sabsupl_term_code_entry >= '202120'
                          AND sabsupl_term_code_entry != '999999'
                      GROUP BY sabsupl_pidm) g ON g.sabsupl_pidm = a.sfvregd_pidm
            LEFT JOIN sabsupl h ON h.sabsupl_pidm = g.sabsupl_pidm
                  AND h.sabsupl_appl_no||h.sabsupl_term_code_entry = g.sabsupl_key
            LEFT JOIN gorvisa i
                   ON i.gorvisa_pidm = a.sfvregd_pidm
            LEFT JOIN sgbstdn j ON j.sgbstdn_pidm = a.sfvregd_pidm
                  AND j.sgbstdn_term_code_eff =
                    (
                      SELECT MAX(j1.sgbstdn_term_code_eff)
                      FROM   sgbstdn j1
                      WHERE  j1.sgbstdn_pidm = a.sfvregd_pidm
                      AND    j1.sgbstdn_term_code_eff <= '202120' -- <-- YYYYTT of this reporting term
                    )
            LEFT JOIN (SELECT sgvacur_pidm,
                              sgvacur_majr_code_1,
                              sgvacur_program
                         FROM sgvacur
                        WHERE sgvacur_cact_code = 'ACTIVE'
                         AND sgvacur_order = '2'
                         AND sgvacur_stdn_rowid  IN (SELECT j1.ROWID FROM sgbstdn j1)) ON sgvacur_pidm = a.sfvregd_pidm
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
                         spriden_first_name,
                         spriden_last_name,
                         sgbstdn_levl_code,
                         spbpers_ssn,
                         spbpers_birth_date,
                         spbpers_dead_date,
                         high_school_grad_date,
                         high_school_code,
                         h.sabsupl_cnty_code_admit,
                         h.sabsupl_stat_code_admit,
                         h.sabsupl_natn_code_admit,
                         h.sabsupl_term_code_entry,
                         h.sabsupl_appl_no,
                         sgvacur_majr_code_1,
                         spbpers_citz_code,
                         gorvisa_vtyp_code,
                         gorvisa_visa_expire_date