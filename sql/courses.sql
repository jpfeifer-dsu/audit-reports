         SELECT ssbsect_term_code,
                ssbsect_crn,
                ssbsect_subj_code,
                ssbsect_crse_numb,
                ssbsect_seq_numb,
                ssbsect_insm_code,
                ssbsect_camp_code,
                ssbsect_enrl,
                ssbsect_ssts_code,
                ssrsccd_sccd_code,
                bldg_code1,
                room_code1
           FROM as_catalog_schedule a --as_catalog_schedule, , ssrsccd
     INNER JOIN ssbsect b
             ON b.ssbsect_crn = a.crn_key
            AND b.ssbsect_term_code = a.term_code_key
     INNER JOIN ssrsccd c
             ON c.ssrsccd_crn = b.ssbsect_crn
            AND c.ssrsccd_term_code = a.term_code_key
          WHERE ssts_code = 'A'
           AND camp_code <> 'XXX'
           AND (ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') - 10 AS prior_term FROM dual)
            OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') AS current_term FROM dual)
            OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') + 10 AS future_term FROM dual));