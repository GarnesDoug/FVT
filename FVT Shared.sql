WITH NSCList AS
(
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
INNER JOIN sfbetrm --Grabs the terms the student is enrolled in 
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
    FROM em_tmp --The em_tmp table is five columns from the NSC Cohort files. The columns are "Record Type", "Student SSN", "Student ID", "CIPCode", and "Aid Year"
  ) NSCList ON (NSCList.NSCStudentID = spriden_id AND NSCList.NSCStudentID IS NOT NULL)
            OR (NSCList.NSCSSN = spbpers_ssn AND NSCList.Nscstudentid IS NULL)
INNER JOIN sgbstdn
      ON sgbstdn_pidm = spriden_pidm
      AND sgbstdn_term_code_eff <= sfbetrm_term_code
WHERE SPRIDEN_ENTITY_IND = 'P'
      AND SPRIDEN_CHANGE_IND IS NULL
--       AND spriden_id = '892537451'
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
SELECT getStuRec.NSCRecordType
       , getStuRec.NSCAidYear
       , getStuRec.NSCPidm
       , getStuRec.NSCStudentID
       , getStuRec.NSCTermCode
       , getStuRec.AidYear
       , getStuRec.NSCCIPCode
       , getStuRec.LevelCode
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
SELECT DISTINCT getStuRec.NSCRecordType NSCRecordType
       , getStuRec.NSCAidYear NSCAidYear
       , getStuRec.NSCPidm NSCPidm
       , getStuRec.NSCStudentID NSCStudentID
       , getStuRec.AidYear AidYear
       , getStuRec.NSCCIPCode NSCCIPCode
       , getStuRec.LevelCode LevelCode
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
     --Books and Supplies for Aid Year Budget. These are the only components that matter for older years. We switched to Period Based Budgets in AIDY 2021.
     AND rbracmp.rbracmp_comp_code IN ('Z5BK', 'Z6SP') --**Replace with your books and supplies component codes
)
, FinAid AS
(
SELECT getStuRec.NSCRecordType NSCRecordType
       , getStuRec.NSCPidm NSCPidm
       , getStuRec.NSCSSN NSCSSN
       , getStuRec.NSCStudentID NSCStudentID
       , getStuRec.NSCStudentFirstName NSCStudentFirstName
       , getStuRec.NSCStudentLastName NSCStudentLastName
       , getStuRec.NSCCIPCode NSCCIPCode
       , getStuRec.NSCAidYear NSCAidYear
       , getStuRec.AidYear AidYear
       , getStuRec.NSCTermCode NSCTermCode
       , getStuRec.SGBSTDNTermCode SGBSTDNTermCode
       , getStuRec.LevelCode LevelCode
       , getStuRec.MajorCode MajorCode
       , getStuRec.DegreeCode DegreeCode
       , getStuRec.ProgramCode ProgramCode
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
, ChargesAssessed AS
(
SELECT getStuRec.NSCRecordType NSCRecordType
       , getStuRec.NSCPidm NSCPidm
       , getStuRec.NSCSSN NSCSSN
       , getStuRec.NSCStudentID NSCStudentID
       , getStuRec.NSCStudentFirstName NSCStudentFirstName
       , getStuRec.NSCStudentLastName NSCStudentLastName
       , getStuRec.NSCCIPCode NSCCIPCode
       , getStuRec.NSCAidYear NSCAidYear
       , getStuRec.AidYear AidYear
       , getStuRec.NSCTermCode NSCTermCode
       , getStuRec.SGBSTDNTermCode SGBSTDNTermCode
       , getStuRec.LevelCode LevelCode
       , getStuRec.MajorCode MajorCode
       , getStuRec.DegreeCode DegreeCode
       , getStuRec.ProgramCode ProgramCode
       , tbbdetc_type_ind TypeInd
       , tbbdetc_dcat_code CatCode
       , tbraccd_detail_code DetailCode
       , tbraccd_amount Amount
FROM getStuRec
LEFT JOIN tbraccd
     ON tbraccd.tbraccd_pidm = getStuRec.NSCPidm
     AND tbraccd.tbraccd_term_code = getStuRec.NSCTermCode
LEFT JOIN tbbdetc
     ON tbbdetc.tbbdetc_detail_code = tbraccd.tbraccd_detail_code
)

SELECT DISTINCT getStuRec.NSCRecordType
       , '00354500'
       , getStuRec.NSCAidYear
       , getStuRec.NSCSSN
       , getStuRec.NSCPidm
       , getStuRec.NSCStudentID
       , getStuRec.NSCStudentFirstName
       , getStuRec.NSCStudentLastName
       , getStuRec.NSCCIPCode
       , getStuRec.ProgramCode
       , CASE
           WHEN getStuRec.NSCRecordType = 'TA'
             THEN NVL(FinAid1.Amount,0)
         END TotalPrivateLoans
       , CASE
           WHEN getStuRec.NSCRecordType = 'TA' AND ChargesAssessed1.Amount > 0
             THEN NVL(ChargesAssessed1.Amount, 0)
           WHEN getStuRec.NSCRecordType = 'TA' AND ChargesAssessed1.Amount <= 0
             THEN 0
           ELSE 0
         END TotalInstDebt
       , CASE
           WHEN getStuRec.NSCRecordType = 'TA'
             THEN NVL(ChargesAssessed2.Amount, 0)
           ELSE 0
         END TotalTuitionAndFeesAssessed
       , CASE
           WHEN getStuRec.NSCRecordType = 'TA'
             THEN NVL(Budget1.Amount, 0)
         END TotalBooksSuppliesEquipment
       , CASE
           WHEN getStuRec.NSCRecordType = 'TA'
             THEN NVL(FinAid2.Amount, 0) + NVL(ChargesAssessed3.Amount, 0) + NVL(ChargesAssessed4.Amount, 0)
           ELSE 0
         END TotalGrantsAndScholarships
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(PeriodBudget1.Amount, 0)
           ELSE 0
         END AnnualCOA
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(ChargesAssessed5.Amount, 0)
         END AnnualTuitionAndFeesAssessed
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(PeriodBudget2.Amount, 0)
           ELSE 0
         END AnnualBooksSuppliesEquipment
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(PeriodBudget3.Amount, 0)
           ELSE 0
         END AnnualHousingAndFood
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(FinAid3.Amount, 0) + NVL(ChargesAssessed6.Amount, 0)
           ELSE 0
         END AnnualINSTGrantsAndScholarships
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(FinAid4.Amount, 0)
           ELSE 0
         END AnnualOtherStateTribalPrivateGrantsAndScholarships
       , CASE
           WHEN getStuRec.NSCRecordType = 'AA'
             THEN NVL(FinAid5.Amount, 0)
           ELSE 0
         END AnnualPrivateLoanAmount
FROM getStuRec
------------------------------------------------------------------------
--Total Private Loans
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT FinAid.NSCRecordType NSCRecordType
           , FinAid.NSCAidYear NSCAidYear
           , FinAid.NSCPidm NSCPidm
           , FinAid.NSCCIPCode NSCCIPCode
           , FinAid.LevelCode LevelCode
           , FinAid.MajorCode MajorCode
           , FinAid.DegreeCode DegreeCode
           , FinAid.ProgramCode ProgramCode
           , SUM(FinAid.PaidAmount) Amount
    FROM FinAid
    WHERE FinAid.FundSource IN ('STAT', 'EXTN', 'INST') --**Replace with your FundSource Codes (RFRBASE_FSRC_CODE) that you use to indicate Private Loans.
          AND FinAid.FundType IN ('ALTL', 'LOAN') --**Replace with your FundType Codes (RFRBASE_FTYP_CODE) that you use to indicate Private Loans.
    GROUP BY FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
  ) FinAid1 ON FinAid1.NSCRecordType = getStuRec.NSCRecordType
            AND FinAid1.NSCAidYear = getStuRec.NSCAidYear
            AND FinAid1.NSCPidm = getStuRec.NSCPidm
            AND FinAid1.NSCCIPCode = getStuRec.NSCCIPCode
            AND FinAid1.LevelCode = getStuRec.LevelCode
            AND FinAid1.MajorCode = getStuRec.MajorCode
            AND FinAid1.DegreeCode = getStuRec.DegreeCode
            AND FinAid1.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Institutional Debt
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , NVL
               (
                 SUM
                   (
                     CASE
                       WHEN ChargesAssessed.TypeInd = 'C'
                         THEN ChargesAssessed.Amount
                       ELSE ChargesAssessed.Amount * -1
                     END
                   )
               , 0) Amount
    FROM ChargesAssessed
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed1 ON ChargesAssessed1.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed1.NSCAidYear = getStuRec.NSCAidYear
                     AND ChargesAssessed1.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed1.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed1.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed1.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed1.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed1.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Tuition And Fees Assessed
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , SUM(ChargesAssessed.Amount) Amount
    FROM ChargesAssessed
    WHERE ChargesAssessed.CatCode IN ('TUI', 'FEE') --**Replace with your tuition and fees detail cat codes (TBBDETC_DCAT_CODE) for Tuition and Fees.
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed2 ON ChargesAssessed2.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed2.NSCAidYear = getStuRec.NSCAidYear
                     AND ChargesAssessed2.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed2.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed2.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed2.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed2.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed2.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Books Supplies And Equipment Allowance
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
           , NVL(SUM(PeriodBudget.Amount), 0) + NVL(SUM(AidYearBudget.Amount), 0) Amount
    FROM PeriodBudget
    LEFT JOIN AidYearBudget
         ON AidYearBudget.NSCRecordType = PeriodBudget.NSCRecordType
         AND AidYearBudget.NSCAidYear = PeriodBudget.NSCAidYear
         AND AidYearBudget.NSCPidm = PeriodBudget.NSCPidm
         AND AidYearBudget.NSCCIPCode = PeriodBudget.NSCCIPCode
         AND AidYearBudget.LevelCode = PeriodBudget.LevelCode
         AND AidYearBudget.MajorCode = PeriodBudget.MajorCode
         AND AidYearBudget.DegreeCode = PeriodBudget.DegreeCode
         AND AidYearBudget.ProgramCode = PeriodBudget.ProgramCode
         AND AidYearBudget.Component IN ('Z5BK', 'Z6SP') --**Replace with your Component Codes (RBRACMP_COMP_CODE) for books and supplies.
    WHERE PeriodBudget.Component IN ('Z5BK', 'Z6SP')--**Replace with your Component Codes (RBRAPBC_PBCP_CODE) for books and supplies.
    GROUP BY PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
  ) Budget1 ON Budget1.NSCRecordType = getStuRec.NSCRecordType
            AND Budget1.NSCAidYear = getStuRec.NSCAidYear
            AND Budget1.NSCPidm = getStuRec.NSCPidm
            AND Budget1.NSCCIPCode = getStuRec.NSCCIPCode
            AND Budget1.LevelCode = getStuRec.LevelCode
            AND Budget1.MajorCode = getStuRec.MajorCode
            AND Budget1.DegreeCode = getStuRec.DegreeCode
            AND Budget1.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Grants and Scholarship - From RPAAWRD
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
           , NVL(SUM(FinAid.PaidAmount), 0) Amount
    FROM FinAid
    WHERE FinAid.FundSource IN ('INST', 'UFUN', 'UNDE', 'UNDO', 'FUND', 'FUCM', 'FUDN', 'FUDE', 'STAT', 'EXTN') --**Replace with your FundSource Codes (RFRBASE_FSRC_CODE) that you use to indicate Grants or Scholarships.
           AND FinAid.FundType IN ('DEPT', 'ERMS', 'ERMT', 'GRNT', 'OTHR', 'SCHL', 'SCHP', 'SCHT', 'SCHO') --**Replace with your FundType Codes (RFRBASE_FTYP_CODE) that you use to indicate Grants or Scholarships.
    GROUP BY FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
  ) FinAid2 ON FinAid2.NSCRecordType = getStuRec.NSCRecordType
            AND FinAid2.NSCAidYear = getStuRec.NSCAidYear
            AND FinAid2.NSCPidm = getStuRec.NSCPidm
            AND FinAid2.NSCCIPCode = getStuRec.NSCCIPCode
            AND FinAid2.LevelCode = getStuRec.LevelCode
            AND FinAid2.MajorCode = getStuRec.MajorCode
            AND FinAid2.DegreeCode = getStuRec.DegreeCode
            AND FinAid2.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Grants and Scholarships - Paid to Student Accounts Only
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , SUM(ChargesAssessed.Amount) Amount
    FROM ChargesAssessed
    WHERE ChargesAssessed.DetailCode IN ('EF03', 'EF22', 'EF57', 'EFAC', 'EFTA', 'EFTB', 'EFTC', 'EFTD', 'EFTE', 'EFTF', 'EFTG', 'EFTH', 'EFTI', 'EFTJ', 'EFTK', 'EFTR', 'EFTT', 'EFTV', 'EFTY','CHKR', 'CHKS', 'REM') --**Replace for any detail codes (TBRACCD_DETAIL_CODE) you may have that do not have their corresponding amounts on RPAAWRD. 
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed3 ON ChargesAssessed3.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed3.NSCAidYear = getStuRec.NSCAidYear
                     AND ChargesAssessed3.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed3.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed3.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed3.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed3.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed3.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Total Meal Plan Scholarship - Only Paid to Student Account
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , SUM(ChargesAssessed.Amount) Amount
    FROM ChargesAssessed
    WHERE ChargesAssessed.DetailCode IN ('221V', '5DAY', 'MSCH') --**Replace for any detail codes (TBRACCD_DETAIL_CODE) you may have that do not have their corresponding amounts on RPAAWRD. We separted meal plan detail codes, but you could get rid of this CTE and just put all yours in the CTE above. Don't forget to take it out of the SELECT as well!
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed4 ON ChargesAssessed4.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed4.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed4.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed4.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed4.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed4.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed4.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual COA
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
           , SUM(PeriodBudget.Amount) Amount
    FROM PeriodBudget
    WHERE PeriodBudget.AidYear = SUBSTR(PeriodBudget.NSCAidYear, 3, 2) || SUBSTR(PeriodBudget.NSCAidYear, 7, 2)
    GROUP BY PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
  ) PeriodBudget1 ON PeriodBudget1.NSCRecordType = getStuRec.NSCRecordType
                  AND PeriodBudget1.NSCPidm = getStuRec.NSCPidm
                  AND PeriodBudget1.NSCCIPCode = getStuRec.NSCCIPCode
                  AND PeriodBudget1.LevelCode = getStuRec.LevelCode
                  AND PeriodBudget1.MajorCode = getStuRec.MajorCode
                  AND PeriodBudget1.DegreeCode = getStuRec.DegreeCode
                  AND PeriodBudget1.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Tuition and Fees Assessed
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.AidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , SUM(ChargesAssessed.Amount) Amount
    FROM ChargesAssessed
    WHERE ChargesAssessed.CatCode IN ('TUI', 'FEE') --**Replace with your tuition and fees detail cat codes (TBBDETC_DCAT_CODE) for Tuition and Fees.
          AND ChargesAssessed.AidYear = SUBSTR(ChargesAssessed.NSCAidYear, 3, 2) || SUBSTR(ChargesAssessed.NSCAidYear, 7, 2)
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.AidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed5 ON ChargesAssessed5.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed5.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed5.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed5.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed5.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed5.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed5.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Books, Supplies, and Equipment Allowance
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
           , SUM(PeriodBudget.Amount) Amount
    FROM PeriodBudget
    WHERE PeriodBudget.Component IN ('Z5BK', 'Z6SP') --**Replace with your Component Codes (RBRAPBC_PBCP_CODE) for books and supplies.
          AND PeriodBudget.AidYear = SUBSTR(PeriodBudget.NSCAidYear, 3, 2) || SUBSTR(PeriodBudget.NSCAidYear, 7, 2)
    GROUP BY PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
  ) PeriodBudget2 ON PeriodBudget2.NSCRecordType = getStuRec.NSCRecordType
                  AND PeriodBudget2.NSCPidm = getStuRec.NSCPidm
                  AND PeriodBudget2.NSCCIPCode = getStuRec.NSCCIPCode
                  AND PeriodBudget2.LevelCode = getStuRec.LevelCode
                  AND PeriodBudget2.MajorCode = getStuRec.MajorCode
                  AND PeriodBudget2.DegreeCode = getStuRec.DegreeCode
                  AND PeriodBudget2.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Housing and Food
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
           , SUM(PeriodBudget.Amount) Amount
    FROM PeriodBudget
    WHERE PeriodBudget.Component IN ('Z3HO', 'Z4FO') --**Replace with your Component Codes (RBRAPBC_PBCP_CODE) for housing and food.
          AND PeriodBudget.AidYear = SUBSTR(PeriodBudget.NSCAidYear, 3, 2) || SUBSTR(PeriodBudget.NSCAidYear, 7, 2)
    GROUP BY PeriodBudget.NSCRecordType
           , PeriodBudget.NSCAidYear
           , PeriodBudget.AidYear
           , PeriodBudget.NSCPidm
           , PeriodBudget.NSCCIPCode
           , PeriodBudget.LevelCode
           , PeriodBudget.MajorCode
           , PeriodBudget.DegreeCode
           , PeriodBudget.ProgramCode
  ) PeriodBudget3 ON PeriodBudget3.NSCRecordType = getStuRec.NSCRecordType
                  AND PeriodBudget3.NSCPidm = getStuRec.NSCPidm
                  AND PeriodBudget3.NSCCIPCode = getStuRec.NSCCIPCode
                  AND PeriodBudget3.LevelCode = getStuRec.LevelCode
                  AND PeriodBudget3.MajorCode = getStuRec.MajorCode
                  AND PeriodBudget3.DegreeCode = getStuRec.DegreeCode
                  AND PeriodBudget3.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Institutional Grants and Scholarships
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
           , SUM(FinAid.PaidAmount) Amount
    FROM FinAid
    WHERE FinAid.FundSource IN ('INST', 'FUCM', 'FUDE', 'FUDN', 'FUND', 'UFUN', 'UNDE', 'UNDO') --**Replace with your FundSource Codes (RFRBASE_FSRC_CODE) that you use to indicate Grants and Scholarships
          AND FinAid.FundType IN ('DEPT', 'ERMS', 'ERMT', 'GRNT', 'OTHR', 'SCHL', 'SCHP', 'SCHT', 'SCHO') --**Replace with your FundType Codes (RFRBASE_FTYP_CODE) that you use to indicate Grants and Scholarships
          AND FinAid.AidYear = SUBSTR(FinAid.NSCAidYear, 3, 2) || SUBSTR(FinAid.NSCAidYear, 7, 2)
    GROUP BY FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
  ) FinAid3 ON FinAid3.NSCRecordType = getStuRec.NSCRecordType
            AND FinAid3.NSCAidYear = getStuRec.NSCAidYear
            AND FinAid3.NSCPidm = getStuRec.NSCPidm
            AND FinAid3.NSCCIPCode = getStuRec.NSCCIPCode
            AND FinAid3.LevelCode = getStuRec.LevelCode
            AND FinAid3.MajorCode = getStuRec.MajorCode
            AND FinAid3.DegreeCode = getStuRec.DegreeCode
            AND FinAid3.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Institutional Grants and Scholarships - Only on Student Accounts
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.AidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
           , SUM(ChargesAssessed.Amount) Amount
    FROM ChargesAssessed
    WHERE ChargesAssessed.DetailCode IN ('221V', 'BP99','MSCH') --**Replace with your tuition and fees detail cat codes (TBBDETC_DCAT_CODE) for grants or scholarships that are not paid on RPAAWRD.
          AND ChargesAssessed.AidYear = SUBSTR(ChargesAssessed.NSCAidYear, 3, 2) || SUBSTR(ChargesAssessed.NSCAidYear, 7, 2)
    GROUP BY ChargesAssessed.NSCRecordType
           , ChargesAssessed.NSCAidYear
           , ChargesAssessed.AidYear
           , ChargesAssessed.NSCPidm
           , ChargesAssessed.NSCCIPCode
           , ChargesAssessed.LevelCode
           , ChargesAssessed.MajorCode
           , ChargesAssessed.DegreeCode
           , ChargesAssessed.ProgramCode
  ) ChargesAssessed6 ON ChargesAssessed6.NSCRecordType = getStuRec.NSCRecordType
                     AND ChargesAssessed6.NSCPidm = getStuRec.NSCPidm
                     AND ChargesAssessed6.NSCCIPCode = getStuRec.NSCCIPCode
                     AND ChargesAssessed6.LevelCode = getStuRec.LevelCode
                     AND ChargesAssessed6.MajorCode = getStuRec.MajorCode
                     AND ChargesAssessed6.DegreeCode = getStuRec.DegreeCode
                     AND ChargesAssessed6.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Other State, Tribal, or Private Grants and Scholarships
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
           , SUM(FinAid.PaidAmount) Amount
    FROM FinAid
    WHERE FinAid.FundSource IN ('STAT', 'EXTN') --**Replace with your FundSource Codes (RFRBASE_FSRC_CODE) that you use to indicate Other State, Tirbal, or Private Grants/Scholarships
          AND FinAid.FundType IN ('SCHP', 'GRNT', 'SCHO', 'ERMS') --**Replace with your FundType Codes (RFRBASE_FTYP_CODE) that you use to indicate Other State, Tirbal, or Private Grants/Scholarships
          AND FinAid.AidYear = SUBSTR(FinAid.NSCAidYear, 3, 2) || SUBSTR(FinAid.NSCAidYear, 7, 2)
    GROUP BY FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
  ) FinAid4 ON FinAid4.NSCRecordType = getStuRec.NSCRecordType
            AND FinAid4.NSCAidYear = getStuRec.NSCAidYear
            AND FinAid4.NSCPidm = getStuRec.NSCPidm
            AND FinAid4.NSCCIPCode = getStuRec.NSCCIPCode
            AND FinAid4.LevelCode = getStuRec.LevelCode
            AND FinAid4.MajorCode = getStuRec.MajorCode
            AND FinAid4.DegreeCode = getStuRec.DegreeCode
            AND FinAid4.ProgramCode = getStuRec.ProgramCode
------------------------------------------------------------------------
--Annual Private Loans
------------------------------------------------------------------------
LEFT JOIN
  (
    SELECT FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
           , SUM(FinAid.PaidAmount) Amount
    FROM FinAid
    WHERE FinAid.FundSource IN ('STAT', 'EXTN', 'INST') --**Replace with your FundSource Codes (RFRBASE_FSRC_CODE) that you use to indicate Private Loans.
          AND FinAid.FundType IN ('ALTL', 'LOAN') --**Replace with your FundType Codes (RFRBASE_FTYP_CODE) that you use to indicate Private Loans.
          AND FinAid.AidYear = SUBSTR(FinAid.NSCAidYear, 3, 2) || SUBSTR(FinAid.NSCAidYear, 7, 2)
    GROUP BY FinAid.NSCRecordType
           , FinAid.NSCAidYear
           , FinAid.AidYear
           , FinAid.NSCPidm
           , FinAid.NSCCIPCode
           , FinAid.LevelCode
           , FinAid.MajorCode
           , FinAid.DegreeCode
           , FinAid.ProgramCode
  ) FinAid5 ON FinAid5.NSCRecordType = getStuRec.NSCRecordType
            AND FinAid5.NSCAidYear = getStuRec.NSCAidYear
            AND FinAid5.NSCPidm = getStuRec.NSCPidm
            AND FinAid5.NSCCIPCode = getStuRec.NSCCIPCode
            AND FinAid5.LevelCode = getStuRec.LevelCode
            AND FinAid5.MajorCode = getStuRec.MajorCode
            AND FinAid5.DegreeCode = getStuRec.DegreeCode
            AND FinAid5.ProgramCode = getStuRec.ProgramCode
ORDER BY getStuRec.NSCStudentLastName
      , getStuRec.NSCStudentFirstName
      , getStuRec.NSCStudentID
      , getStuRec.NSCRecordType
