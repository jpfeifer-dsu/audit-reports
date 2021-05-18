   SELECT b.spriden_id banner_id,
          b.spriden_first_name first_name,
          b.spriden_last_name last_name,
          CASE WHEN i.ptrtenr_code IN ('T', 'O') THEN i.ptrtenr_desc
               ELSE g.ptrecls_long_desc
                END instructor_status,
          k.perfasg_percent_response repsonsibility_percentage,
          CASE WHEN e.nbrbjob_contract_type IS NULL THEN NULL
               WHEN e.nbrbjob_contract_type = 'O' THEN 1
               ELSE 0
                END overload_indicator,
          a.sirasgn_term_code term_code,
          a.sirasgn_crn crn,
          c.ssbsect_crse_numb course_number,
          c.ssbsect_seq_numb section_number,
          j.scbcrse_title course_title,
          l.stvcoll_desc college,
          m.stvdept_desc department,
          c.ssbsect_enrl student_count,
          c.ssbsect_tot_credit_hrs total_enrolled_credit_hours
     FROM saturn.sirasgn a
LEFT JOIN saturn.spriden b
       ON b.spriden_pidm = a.sirasgn_pidm
      AND b.spriden_change_ind IS NULL
LEFT JOIN saturn.ssbsect c
       ON a.sirasgn_term_code = c.ssbsect_term_code
      AND a.sirasgn_crn = c.ssbsect_crn
LEFT JOIN saturn.stvterm d
       ON d.stvterm_code = a.sirasgn_term_code
LEFT JOIN posnctl.nbrbjob e
       ON e.nbrbjob_pidm = a.sirasgn_pidm
      AND e.nbrbjob_posn = a.sirasgn_posn
      AND e.nbrbjob_suff = a.sirasgn_suff
      AND e.nbrbjob_begin_date = (SELECT MAX(e1.nbrbjob_begin_date)
                                    FROM posnctl.nbrbjob e1
                                   WHERE e.nbrbjob_pidm = e1.nbrbjob_pidm
                                     AND e.nbrbjob_posn = e1.nbrbjob_posn
                                     AND e.nbrbjob_suff = e1.nbrbjob_suff
                                     AND e1.nbrbjob_begin_date < d.stvterm_end_date)
LEFT JOIN posnctl.nbrjobs  f
       ON f.nbrjobs_pidm = e.nbrbjob_pidm
      AND f.nbrjobs_posn = e.nbrbjob_posn
      AND f.nbrjobs_suff = e.nbrbjob_suff
      AND f.nbrjobs_effective_date = (SELECT MAX(f1.nbrjobs_effective_date)
                                        FROM posnctl.nbrjobs f1
                                       WHERE f.nbrjobs_pidm = f1.nbrjobs_pidm
                                         AND f.nbrjobs_posn = f1.nbrjobs_posn
                                         AND f.nbrjobs_suff = f1.nbrjobs_suff)
LEFT JOIN payroll.ptrecls g
       ON f.nbrjobs_ecls_code = g.ptrecls_code
LEFT JOIN payroll.perappt h
       ON h.perappt_pidm = a.sirasgn_pidm
      AND h.perappt_begin_date = (SELECT MAX(h1.perappt_begin_date)
                                    FROM payroll.perappt h1
                                   WHERE h.perappt_pidm = h1.perappt_pidm
                                     AND h1.perappt_begin_date < d.stvterm_end_date)
      AND h.perappt_appt_eff_date = (SELECT MAX(h1.perappt_appt_eff_date)
                                       FROM payroll.perappt h1
                                      WHERE h.perappt_pidm = h1.perappt_pidm)
LEFT JOIN payroll.ptrtenr i
       ON i.ptrtenr_code = h.perappt_tenure_code
LEFT JOIN saturn.scbcrse j
       ON j.scbcrse_crse_numb = c.ssbsect_crse_numb
      AND j.scbcrse_subj_code = c.ssbsect_subj_code
      AND j.scbcrse_eff_term = (SELECT MAX(j1.scbcrse_eff_term)
                                  FROM saturn.scbcrse j1
                                 WHERE j.scbcrse_crse_numb = j1.scbcrse_crse_numb
                                   AND j.scbcrse_subj_code = j1.scbcrse_subj_code
                                   AND j1.scbcrse_eff_term <= d.stvterm_code)
LEFT JOIN payroll.perfasg k
       ON k.perfasg_pidm = a.sirasgn_pidm
      AND k.perfasg_posn = a.sirasgn_posn
      AND k.perfasg_suff = a.sirasgn_suff
      AND k.perfasg_crn = a.sirasgn_crn
      AND k.perfasg_term_code = a.sirasgn_term_code
LEFT JOIN saturn.stvcoll l
       ON l.stvcoll_code = j.scbcrse_coll_code
LEFT JOIN saturn.stvdept m
       ON m.stvdept_code = j.scbcrse_dept_code
    WHERE a.sirasgn_posn IS NOT NULL
      AND a.sirasgn_suff IS NOT NULL
      -- filter out non-compensated positions
      AND a.sirasgn_posn NOT LIKE 'GNC%'
 ORDER BY a.sirasgn_pidm,
             a.sirasgn_term_code,
             a.sirasgn_crn;