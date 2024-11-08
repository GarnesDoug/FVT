
SELECT  
       n.RecordType [Record Type]
	 , n.OPEID [Institution Code (OPEID)]
	 , n.AwardYear [Award Year]
	 , n.StudentSSN [Student Social Security Number]
	 , n.FirstName [Student First Name]
	 , n.MiddleName [Student Middle Name]
	 , n.LastName [Student Last Name]
	 , n.dob [Student Date of Birth]
	 , n.CIPCode [CIP Code]
	 , n.CredentialLevel [Credential Level]
	 , n.PubPrgLen [Published Length of Program]
	 , n.PubLengthProMsrm [Published Length of Program Measurement]
	 , n.WeeksinTIV [Weeks in Title IV Academic Year]
	 , n.CTP [Comprehensive Transition and Postsecondary (CTP) Program Indicator]
	 , n.AppPrisEdu [Approved Prison Education Program Indicator]
	 , n.DateCompWD [Date Student Completed or Withdrew from Program]
	 , f.TOTALPRIVATELOANS [Total Amount Student Received in Private Education Loans During Student's Entire Enrollment in the Program]
	 , f.TOTALINSTDEBT [Total Amount of Institutional Debt During Student's Entire Enrollment in the Program]
	 , f.TOTALTUITIONANDFEESASSESSED [Total Amount of Tuition & Fees Assessed During Student's Entire Enrollment in the Program]
	 , f.TOTALBOOKSSUPPLIESEQUIPMENT [Total Amount of Allowance for books, supplies, and equipment included in the student's title IV]
	 , f.TOTALGRANTSANDSCHOLARSHIPS [Total Amount of Grants and Scholarships the student received During Student's Entire Enrollment in the Program]
	 , n.EnrlBegDate [Program Enrollment Begin Date]
	 , n.StuEnrlStatus [Student's Enrollment Status as of the 1st Day of Enrollment in the Program]
	 , n.ProgStatus [Program Attendance Status During Award Year]
	 , n.ProgStatusDate [Program Attendance Status Date During Award Year]
	 , f.ANNUALCOA [Annual Cost of Attendance (COA)]
	 , f.ANNUALTUITIONANDFEESASSESSED [Tuition and Fees Amount for Award Year being Reported]
	 , 'OS' [Residency Tuition Status by State or District]
	 , f.ANNUALBOOKSSUPPLIESEQUIPMENT [Allowance for Books, Supplies, and Equipment]
	 , f.ANNUALHOUSINGANDFOOD [Allowance for Housing and Food]
	 , f.ANNUALINSTGRANTSANDSCHOLARSHIPS [Institutional Grants and Scholarships]
	 , f.ANNUALOTHERSTATETRIBALPRIVATEGRANTSANDSCHOLARSHIPS [Other State, Tribal, or Private Grants]
	 , f.ANNUALPRIVATELOANAMOUNT [Private Loans Amount]
	 , f.INVALIDFLAG [Invalid Flag]
	 , 'N' [Gainful Employment Program Flag]
FROM nsc.nsc2324 n
	LEFT JOIN nsc.FVT f ON
	f.STUDENTID = n.StudentID
	AND f.NSCAIDYEAR = n.AwardYear
	AND f.CIPCODE = n.CIPCode
    AND f.RecordType = n.RecordType
WHERE n.StudentID IS NOT NULL
UNION ALL 
SELECT  
       n.RecordType [Record Type]
	 , n.OPEID [Institution Code (OPEID)]
	 , n.AwardYear [Award Year]
	 , n.StudentSSN [Student Social Security Number]
	 , n.FirstName [Student First Name]
	 , n.MiddleName [Student Middle Name]
	 , n.LastName [Student Last Name]
	 , n.dob [Student Date of Birth]
	 , n.CIPCode [CIP Code]
	 , n.CredentialLevel [Credential Level]
	 , n.PubPrgLen [Published Length of Program]
	 , n.PubLengthProMsrm [Published Length of Program Measurement]
	 , n.WeeksinTIV [Weeks in Title IV Academic Year]
	 , n.CTP [Comprehensive Transition and Postsecondary (CTP) Program Indicator]
	 , n.AppPrisEdu [Approved Prison Education Program Indicator]
	 , n.DateCompWD [Date Student Completed or Withdrew from Program]
	 , f.TOTALPRIVATELOANS [Total Amount Student Received in Private Education Loans During Student's Entire Enrollment in the Program]
	 , f.TOTALINSTDEBT [Total Amount of Institutional Debt During Student's Entire Enrollment in the Program]
	 , f.TOTALTUITIONANDFEESASSESSED [Total Amount of Tuition & Fees Assessed During Student's Entire Enrollment in the Program]
	 , f.TOTALBOOKSSUPPLIESEQUIPMENT [Total Amount of Allowance for books, supplies, and equipment included in the student's title IV]
	 , f.TOTALGRANTSANDSCHOLARSHIPS [Total Amount of Grants and Scholarships the student received During Student's Entire Enrollment in the Program]
	 , n.EnrlBegDate [Program Enrollment Begin Date]
	 , n.StuEnrlStatus [Student's Enrollment Status as of the 1st Day of Enrollment in the Program]
	 , n.ProgStatus [Program Attendance Status During Award Year]
	 , n.ProgStatusDate [Program Attendance Status Date During Award Year]
	 , f.ANNUALCOA [Annual Cost of Attendance (COA)]
	 , f.ANNUALTUITIONANDFEESASSESSED [Tuition and Fees Amount for Award Year being Reported]
	 , 'OS' [Residency Tuition Status by State or District]
	 , f.ANNUALBOOKSSUPPLIESEQUIPMENT [Allowance for Books, Supplies, and Equipment]
	 , f.ANNUALHOUSINGANDFOOD [Allowance for Housing and Food]
	 , f.ANNUALINSTGRANTSANDSCHOLARSHIPS [Institutional Grants and Scholarships]
	 , f.ANNUALOTHERSTATETRIBALPRIVATEGRANTSANDSCHOLARSHIPS [Other State, Tribal, or Private Grants]
	 , f.ANNUALPRIVATELOANAMOUNT [Private Loans Amount]
	 , f.INVALIDFLAG [Invalid Flag]
	 , 'N' [Gainful Employment Program Flag]
FROM nsc.nsc2324 n
	LEFT JOIN nsc.FVT f ON
	    f.SSN = n.StudentSSN
	AND f.NSCAIDYEAR = n.AwardYear
	AND f.CIPCODE = n.CIPCode
	AND f.RECORDTYPE = n.RecordType
WHERE n.StudentID IS NULL

