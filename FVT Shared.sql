/*
TO DO:
Think about adding period to NSCList => Grab from something like rpratrm to match pidm to period, and then have the period come from rfrdefa as well.
Ensure Level Code is accurate => don't want a GR also getting UG terms added to their amounts
*/
/*
The em_tmp table is five columns from the NSC Cohort files. The columns are "Record Type", "Student SSN", "Student ID", "CIPCode", and "Aid Year"
*/
WITH NSCList AS
(
--293,849
--7:18
SELECT NSCRecordType NSCRecordType
       , NSCSSN NSCSSN
       , NSCStudentID NSCStudentID
       , NSCCIPCode NSCCIPCode
       , NSCAidYear NSCAidYear
       , spriden_pidm Pidm
       , spriden_id StudentID
       , spriden_first_name StudentFirstName
       , spriden_last_name StudentLastName
       , sfbetrm_term_code TermCode
       , TermAndAidYear.AidYear AidYear
       , MAX(sgbstdn_term_code_eff) SGBSTDNTermCode
FROM SPRIDEN
INNER JOIN sfbetrm
      ON sfbetrm_pidm = spriden_pidm
INNER JOIN spbpers
      ON spbpers.spbpers_pidm = spriden_pidm
INNER JOIN
  (
    SELECT DISTINCT rfrdefa_aidy_code AidYear
           , rfrdefa_term_code TermCode
    FROM rfrdefa
  ) TermAndAidYear ON TermAndAidYear.TermCode = sfbetrm_term_code
INNER JOIN 
  (
    SELECT em_tmp_1 NSCRecordType
           , LPAD(em_tmp_2, 9, '0') NSCSSN
           , em_tmp_3 NSCStudentID
           , em_tmp_4 NSCCIPCode
           , em_tmp_5 NSCAidYear
    FROM em_tmp
  ) NSCList ON (NSCList.NSCStudentID = spriden_id AND NSCList.NSCStudentID IS NOT NULL)
            OR (NSCList.NSCSSN = spbpers_ssn AND NSCList.Nscstudentid IS NULL)
INNER JOIN sgbstdn
      ON sgbstdn_pidm = spriden_pidm
      AND sgbstdn_term_code_eff <= sfbetrm_term_code
WHERE SPRIDEN_ENTITY_IND = 'P'
      AND SPRIDEN_CHANGE_IND IS NULL
      AND spriden_id = '892690138'
GROUP BY NSCRecordType
       , NSCSSN
       , NSCStudentID
       , NSCCIPCode
       , NSCAidYear
       , spriden_pidm
       , spriden_id
       , spriden_first_name
       , spriden_last_name
       , sfbetrm_term_code
       , TermAndAidYear.AidYear
ORDER BY spriden_last_name
      , spriden_first_name
      , spriden_id
      , sfbetrm_term_code
)
, getStuRec AS
(
SELECT NSCList.NSCRecordType NSCRecordType
       , NSCList.NSCSSN NSCSSN
       , NSCList.NSCStudentID NSCStudentID
       , NSCList.NSCCIPCode NSCCIPCode
       , NSCList.NSCAidYear NSCAidYear
       , NSCList.Pidm NSCPidm
       , NSCList.StudentFirstName NSCStudentFirstName
       , NSCList.StudentLastName NSCStudentLastName
       , NSCList.TermCode NSCTermCode
       , NSCList.AidYear AidYear
       , NSCList.SGBSTDNTermCode SGBSTDNTermCode
       , sgbstdn1.sgbstdn_levl_code LevelCode
       , sgbstdn1.sgbstdn_majr_code_1 MajorCode
       , sgbstdn1.sgbstdn_degc_code_1 DegreeCode
       , sgbstdn1.sgbstdn_program_1 ProgramCode
       , stvmajr.stvmajr_cipc_code
       , stvmajr.stvmajr_code
FROM NSCList
INNER JOIN sgbstdn sgbstdn1
     ON sgbstdn1.sgbstdn_pidm = NSCList.Pidm
     AND sgbstdn1.sgbstdn_term_code_eff = NSCList.SGBSTDNTermCode
INNER JOIN stvmajr
     ON stvmajr.stvmajr_cipc_code = NSCList.NSCCIPCode
     AND stvmajr.stvmajr_code = sgbstdn1.sgbstdn_majr_code_1
)
--Get the period budget
, PeriodBudget AS
(
SELECT getStuRec.NSCPidm
       , getStuRec.NSCStudentID
       , getStuRec.NSCTermCode
       , getStuRec.AidYear
       , getStuRec.NSCCIPCode
       , getStuRec.MajorCode
       , getStuRec.DegreeCode
       , getStuRec.ProgramCode
       , rbrapbc_pbcp_code Component
       , rbrapbc_amt Amount
FROM getStuRec
INNER JOIN rbrapbc
     ON rbrapbc_pidm = getStuRec.NSCPidm
     AND SUBSTR(rbrapbc_period, 0, 6) = getStuRec.NSCTermCode
     AND rbrapbc_pbtp_code = 'CAMP' --**Replace with your budget type code
)
--Get the Aid Year Budget
, AidYearBudget AS
(
SELECT DISTINCT getStuRec.NSCPidm NSCPidm
       , getStuRec.NSCStudentID NSCStudentID
       , getStuRec.AidYear AidYear
       , getStuRec.NSCCIPCode NSCCIPCode
       , getStuRec.MajorCode MajorCode
       , getStuRec.DegreeCode DegreeCode
       , getStuRec.ProgramCode ProgramCode
       , rbracmp.rbracmp_comp_code Component
       , rbracmp.rbracmp_amt Amount
FROM getStuRec
INNER JOIN rbracmp
     ON rbracmp.rbracmp_pidm = getStuRec.NSCPidm
     AND rbracmp.rbracmp_aidy_code = getStuRec.AidYear
     AND rbracmp.rbracmp_btyp_code = 'CAMP' --**Replace with your budget type code
     --Books and Supplies for Aid Year Budget
     AND rbracmp.rbracmp_comp_code IN ('Z5BK', 'Z6SP') --**Replace with your books and supplies component codes
)
, FinAid AS
(
SELECT getStuRec.NSCRecordType
       , getStuRec.NSCPidm
       , getStuRec.NSCSSN
       , getStuRec.NSCStudentID
       , getStuRec.NSCStudentFirstName
       , getStuRec.NSCStudentLastName
       , getStuRec.NSCCIPCode
       , getStuRec.NSCAidYear
       , getStuRec.AidYear
       , getStuRec.NSCTermCode
       , getStuRec.SGBSTDNTermCode
       , getStuRec.LevelCode
       , getStuRec.MajorCode
       , getStuRec.DegreeCode
       , getStuRec.ProgramCode
       , rpratrm_fund_code FundCode
       , rfrbase.rfrbase_fsrc_code FundSource
       , rfrbase.rfrbase_ftyp_code FundType
       , rpratrm_paid_amt PaidAmount
FROM getStuRec
LEFT JOIN rpratrm
     ON rpratrm.rpratrm_pidm = getStuRec.NSCPIDM
     AND SUBSTR(rpratrm.rpratrm_period, 0, 6) = getStuRec.NSCTermCode
     AND rpratrm.rpratrm_paid_amt > 0
LEFT JOIN rfrbase
     ON rfrbase.rfrbase_fund_code = rpratrm.rpratrm_fund_code
ORDER BY getStuRec.NSCStudentLastName
      , getStuRec.NSCStudentFirstName
      , getStuRec.NSCStudentID
      , getStuRec.NSCTermCode
)

SELECT *
FROM FinAid


