
SELECT  
       n.RecordType [Record Type]
	 , n.OPEID [Institution Code (OPEID)]
	 , n.AwardYear [Award Year]
	 , n.StudentSSN [Student Social Security Number]
	 , n.FirstName [Student First Name]
	 , ISNULL(n.MiddleName,'') [Student Middle Name]
	 , n.LastName [Student Last Name]
	 , n.dob [Student Date of Birth]
	 , n.CIPCode [CIP Code]
	 , n.CredentialLevel [Credential Level]
	 , n.PubPrgLen [Published Length of Program]
	 , n.PubLengthProMsrm [Published Length of Program Measurement]
	 , n.WeeksinTIV [Weeks in Title IV Academic Year]
	 , ISNULL(n.CTP,'') [Comprehensive Transition and Postsecondary (CTP) Program Indicator]
	 , ISNULL(n.AppPrisEdu,'') [Approved Prison Education Program Indicator]
	 , n.DateCompWD [Date Student Completed or Withdrew from Program]
	 , ISNULL(f.TOTALPRIVATELOANS,0) [Total Amount Student Received in Private Education Loans During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALINSTDEBT, 0) [Total Amount of Institutional Debt During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALTUITIONANDFEESASSESSED, 0) [Total Amount of Tuition & Fees Assessed During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALBOOKSSUPPLIESEQUIPMENT, 0) [Total Amount of Allowance for books, supplies, and equipment included in the student's title IV]
	 , ISNULL(f.TOTALGRANTSANDSCHOLARSHIPS, 0) [Total Amount of Grants and Scholarships the student received During Student's Entire Enrollment in the Program]
	 , ISNULL(n.EnrlBegDate,'') [Program Enrollment Begin Date]
	 , ISNULL(n.StuEnrlStatus,'') [Student's Enrollment Status as of the 1st Day of Enrollment in the Program]
	 , ISNULL(n.ProgStatus,'') [Program Attendance Status During Award Year]
	 , ISNULL(n.ProgStatusDate,'') [Program Attendance Status Date During Award Year]
	 , ISNULL(f.ANNUALCOA, 0) [Annual Cost of Attendance (COA)]
	 , ISNULL(f.ANNUALTUITIONANDFEESASSESSED, 0) [Tuition and Fees Amount for Award Year being Reported]
	 , 'OS' [Residency Tuition Status by State or District]
	 , ISNULL(f.ANNUALBOOKSSUPPLIESEQUIPMENT, 0) [Allowance for Books, Supplies, and Equipment]
	 , ISNULL(f.ANNUALHOUSINGANDFOOD, 0) [Allowance for Housing and Food]
	 , ISNULL(f.ANNUALINSTGRANTSANDSCHOLARSHIPS, 0) [Institutional Grants and Scholarships]
	 , ISNULL(f.ANNUALOTHERSTATETRIBALPRIVATEGRANTSANDSCHOLARSHIPS, 0) [Other State, Tribal, or Private Grants]
	 , ISNULL(f.ANNUALPRIVATELOANAMOUNT,0) [Private Loans Amount]
	 , CASE WHEN f.INVALIDFLAG = 'T' THEN 'T'
	        WHEN f.INVALIDFLAG= 'N' AND n.ProgStatus = 'W' THEN 'R'
			ELSE 'N' END [Invalid Flag]
	 , 'N' [Gainful Employment Program Flag]
FROM nsc.nsc2223 n
	LEFT JOIN nsc.FVT f ON
	f.NSCSTUDENTID = n.StudentID
	AND f.NSCAIDYEAR = n.AwardYear
	AND f.NSCCIPCODE = n.CIPCode
    AND f.NSCRECORDTYPE = n.RecordType
    AND f.NSCCREDENTIALCODE = n.CredentialLevel
WHERE n.StudentID IS NOT NULL
UNION ALL 
SELECT  
       n.RecordType [Record Type]
	 , n.OPEID [Institution Code (OPEID)]
	 , n.AwardYear [Award Year]
	 , n.StudentSSN [Student Social Security Number]
	 , n.FirstName [Student First Name]
	 , ISNULL(n.MiddleName,'') [Student Middle Name]
	 , n.LastName [Student Last Name]
	 , n.dob [Student Date of Birth]
	 , n.CIPCode [CIP Code]
	 , n.CredentialLevel [Credential Level]
	 , n.PubPrgLen [Published Length of Program]
	 , n.PubLengthProMsrm [Published Length of Program Measurement]
	 , n.WeeksinTIV [Weeks in Title IV Academic Year]
	 , ISNULL(n.CTP,'') [Comprehensive Transition and Postsecondary (CTP) Program Indicator]
	 , ISNULL(n.AppPrisEdu,'') [Approved Prison Education Program Indicator]
	 , n.DateCompWD [Date Student Completed or Withdrew from Program]
     , ISNULL(f.TOTALPRIVATELOANS,0) [Total Amount Student Received in Private Education Loans During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALINSTDEBT, 0) [Total Amount of Institutional Debt During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALTUITIONANDFEESASSESSED, 0) [Total Amount of Tuition & Fees Assessed During Student's Entire Enrollment in the Program]
	 , ISNULL(f.TOTALBOOKSSUPPLIESEQUIPMENT, 0) [Total Amount of Allowance for books, supplies, and equipment included in the student's title IV]
	 , ISNULL(f.TOTALGRANTSANDSCHOLARSHIPS, 0) [Total Amount of Grants and Scholarships the student received During Student's Entire Enrollment in the Program]
	 , ISNULL(n.EnrlBegDate,'') [Program Enrollment Begin Date]
	 , ISNULL(n.StuEnrlStatus,'') [Student's Enrollment Status as of the 1st Day of Enrollment in the Program]
	 , ISNULL(n.ProgStatus,'') [Program Attendance Status During Award Year]
	 , ISNULL(n.ProgStatusDate,'') [Program Attendance Status Date During Award Year]
	 , ISNULL(f.ANNUALCOA, 0) [Annual Cost of Attendance (COA)]
	 , ISNULL(f.ANNUALTUITIONANDFEESASSESSED, 0) [Tuition and Fees Amount for Award Year being Reported]
	 , 'OS' [Residency Tuition Status by State or District]
	 , ISNULL(f.ANNUALBOOKSSUPPLIESEQUIPMENT, 0) [Allowance for Books, Supplies, and Equipment]
	 , ISNULL(f.ANNUALHOUSINGANDFOOD, 0) [Allowance for Housing and Food]
	 , ISNULL(f.ANNUALINSTGRANTSANDSCHOLARSHIPS, 0) [Institutional Grants and Scholarships]
	 , ISNULL(f.ANNUALOTHERSTATETRIBALPRIVATEGRANTSANDSCHOLARSHIPS, 0) [Other State, Tribal, or Private Grants]
	 , ISNULL(f.ANNUALPRIVATELOANAMOUNT,0) [Private Loans Amount]
	 , CASE WHEN f.INVALIDFLAG = 'T' THEN 'T'
	        WHEN f.INVALIDFLAG= 'N' AND n.ProgStatus = 'W' THEN 'R'
			ELSE 'N' END [Invalid Flag]
	 , 'N' [Gainful Employment Program Flag]
FROM nsc.nsc2223 n
    LEFT JOIN nsc.FVT f ON
	    f.NSCSSN = n.StudentSSN
	AND f.NSCAIDYEAR = n.AwardYear
	AND f.NSCCIPCODE = n.CIPCode
	AND f.NSCRECORDTYPE = n.RecordType
    AND f.NSCCREDENTIALCODE = n.CredentialLevel
WHERE n.StudentID IS NULL
