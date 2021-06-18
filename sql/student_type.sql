SELECT x.*, ROW_NUMBER() OVER (PARTITION by pidm ORDER BY max_term) AS rn, CASE WHEN min_term = max_term -- This statement stops first-time attendance during the Summer from affecting Fall
                 AND substr(max_term, -2) = '30'
                 AND substr('202120', -2) = '40'
                 AND substr(max_term,1,4) = substr('202120',1,4)
           THEN 0 ELSE 1 END
             FROM   (
                      SELECT pidm          AS pidm,
                             ID            AS banner_id,
                             f_format_name(spriden_pidm,'LFMI')
                                           AS full_name,
                             styp          AS stu_type,
                             hsgraddt      AS hsgrad_dt,
                             cur_prgm      AS curr_prgm,
                             min(substr(dsc_term_code,1,5)||'0')
                                           AS min_term,
                             max(substr(dsc_term_code,1,5)||'0')
                                           AS max_term,
                          -- s_term_att_cr AS att_hrs,
                             'Marked STYP '||styp||', but has attended DSU since HS Grad'
                                           AS reason
                      FROM   dailystats,
                             spriden,
                             bailey.students03@dscir,
                             stvterm
                      WHERE  styp IN ('N','F','T')
                      AND    spriden_pidm = pidm
                      AND    spriden_pidm = dsc_pidm
                      AND    stvterm_code = substr(dsc_term_code,1,5)||'0'
                      AND    spriden_change_ind IS NULL
                      AND    s_entry_action <> 'HS'
                      AND    stvterm_start_date > hsgraddt
                      AND    stvterm_code > to_char(hsgraddt,'YYYY')||'30'
                      AND    stvterm_code != '202120'
                      GROUP  BY spriden_pidm, pidm, ID, styp, hsgraddt, cur_prgm, s_term_att_cr) x