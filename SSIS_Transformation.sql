              ------ Transformation ---
-- Rename SSIS file Name With Date Time Stamp
DECLARE @FileName VARCHAR(MAX) = 'J:\16-Titanic Data.xlsx',
@TimeStamp DATETIME = GETDATE()
SELECT  CONCAT(
          REPLACE(@FileName,'.xlsx','_'),
          REPLACE(
		        REPLACE(
				     REPLACE(
					      SUBSTRING(CONVERT(VARCHAR(50),@TimeStamp,120),1,19),' ','_'),':',''),'-',''),
		                        '.xlsx') AS FileName_DateTimestamp;

--  'J:\16-Titanic Data_20240216_211411.xlsx'

--================== SQL Column To Rows UNPIVOT data.
DECLARE @Email_Address INT = 1
DECLARE @B INT = 5
DECLARE @UnpivotTable TABLE
(
Imp_Id INT IDENTITY (100,1),
Emp_Name VARCHAR(50),
Jan INT,
Feb INT,
Mar INT,
Apr INT,
May INT
)
WHILE(@Email_Address<=@B)
BEGIN
INSERT INTO @UnpivotTable
SELECT CONCAT('Test_',@Email_Address),5000,6000,4000,7000,8000 
SET @Email_Address = @Email_Address+1
END;
--===============
SELECT * FROM @UnpivotTable;
--===========
SELECT *
,SUM(Salary)over(PARTITION BY Month_Name ORDER BY Month_Name) AS totalsalary_bymonth  --Total Salry for each particular month.
,CASE 
WHEN Month_Name = 'Jan' THEN 1
    WHEN Month_Name = 'Feb' THEN 2
    WHEN Month_Name = 'Mar' THEN 3
    WHEN Month_Name = 'Apr' THEN 4
        WHEN Month_Name = 'May' THEN 5
        WHEN Month_Name = 'Jun' THEN 6
        WHEN Month_Name = 'Jul' THEN 7
        WHEN Month_Name = 'Aug' THEN 8
            WHEN Month_Name = 'Sep' THEN 9
            WHEN Month_Name = 'Oct' THEN 10
            WHEN Month_Name = 'Nov' THEN 11
            WHEN Month_Name = 'Dec' THEN 12
                ELSE NULL -- Handle invalid input if necessary
        END AS Month_Number
FROM --Final Output from SubQuery
(
SELECT * 
FROM @UnpivotTable) AS Row_Data  -- Origional declared Data.
  UNPIVOT
(
 Salary FOR Month_Name IN(Jan,Feb,Mar,Apr,May)  -- 
)Unpivot_Imput
ORDER BY 6;
--==================================
          -- To Get the first name and last name from the given email
          -- Demo as Last Name and  Test as First Name
DECLARE @Email_Add VARCHAR(50) = 'Test_Demo@domain.com' 
SELECT SUBSTRING(                                
        SUBSTRING(@Email_Add,1,(CHARINDEX('@',@Email_Add))-1),
		  1,CHARINDEX('_',SUBSTRING(@Email_Add,1,(CHARINDEX('@',@Email_Add))-1))-1) AS FName 
,SUBSTRING(      
           SUBSTRING(@Email_Add,1,(CHARINDEX('@',@Email_Add))-1),
		      CHARINDEX('_',SUBSTRING(@Email_Add,1,(CHARINDEX('@',@Email_Add))-1))+1,
			    LEN(SUBSTRING(@Email_Add,1,(CHARINDEX('@',@Email_Add))-1))) AS LName
				
--==================----------   Incremental data Load in SSIS using LookUP
-- Create a Audit_log Table
IF NOT EXISTS
	(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Audit_log]') AND type IN (N'U'))
BEGIN
	CREATE TABLE Audit_log
			(
			Id INT IDENTITY,
			PakageName VARCHAR(200),
			TableName VARCHAR(200),
			RecordsInserted INT,
			RecordsUpdated INT,
			Dated DATETIME
			) ON [PRIMARY]
		PRINT 'The table is Created'
END
ELSE
		PRINT 'The table is Exists'
GO
--====================  Create an Emails Table
IF NOT EXISTS
	(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Emails]') AND TYPE IN(N'U'))
BEGIN
	CREATE TABLE Emails
			(
			Id INT NULL,
			First_Name VARCHAR(50) NULL,
			Last_Name VARCHAR(50) NULL,
			Email VARCHAR(50) NULL,
			Gender VARCHAR(50) NULL			
			) ON [PRIMARY]
	PRINT 'The table is Created'
END
ELSE
	PRINT 'The table is Exists'
GO
--============================  Create  ZZ_Emaile_Updated  Table   
IF NOT EXISTS
	(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZZ_Emaile_Updated]') AND TYPE IN(N'U'))
BEGIN
	CREATE TABLE ZZ_Emaile_Updated
			(
			Id INT NULL,
			First_Name VARCHAR(50) NULL,
			Last_Name VARCHAR(50) NULL,
			Email VARCHAR(50) NULL,
			Gender VARCHAR(50) NULL			
			) ON [PRIMARY]
	PRINT 'The table is Created'
END
ELSE
	PRINT 'The table is Exists'
GO
--===================================
IF NOT EXISTS
	(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Archive]') AND TYPE IN(N'U'))
BEGIN
	CREATE TABLE Archive
			(
			Id INT IDENTITY (100,1),
			Email_Id INT NOT NULL,
			First_Name VARCHAR(50) NULL,
			Last_Name VARCHAR(50) NULL,
			Email VARCHAR(50) NULL,
			Gender VARCHAR(50) NULL,
			Dataed DATETIME DEFAULT GETDATE(),
			Activity VARCHAR(25) NOT NULL,
			) ON [PRIMARY]
	PRINT 'The table is Created'
END
ELSE
	PRINT 'The table is Exists'
GO
--========================================================
DECLARE @Updated INT
UPDATE a
SET a.First_Name = b.First_Name,
    a.Last_Name = b.Last_Name,
	a.Email = b.Email,
	a.Gender = b.Gender
FROM [dbo].[Emails]a
INNER JOIN [dbo].[ZZ_Emaile_Updated] AS b
ON a.Id = b.Id
SET @Updated = @@ROWCOUNT
INSERT INTO [dbo].[Audit_log]
SELECT 'Package.dtsx','dbo.Emails', 0 , @Updated ,GETDATE() -- or
--SELECT ? -- 0 
--,? -- 1
--,? -- 2
--,@Updated 
--,GETDATE()
--=======================================
GO
CREATE OR ALTER TRIGGER tr_Archaive ON [dbo].[Emails]
FOR INSERT,UPDATE,DELETE
AS
SET NOCOUNT ON
IF EXISTS (SELECT 0 FROM deleted)
BEGIN
  	IF EXISTS (SELECT 0 FROM inserted)
BEGIN
INSERT INTO [dbo].[Archive]
(
Email_Id,
First_Name,
Last_Name,
Email,
Gender,
[Activity]
)
SELECT d.Id AS Email_Id ,
		d.First_Name,
		d.Last_Name,
		d.Email,
		d.Gender,
		'Update' AS  Activity 
FROM deleted d
END
ELSE
BEGIN
INSERT INTO [dbo].[Archive]
(
Email_Id,
First_Name,
Last_Name,
Email,
Gender,
Activity 
)
SELECT d.Id AS Email_Id ,
		d.First_Name,
		d.Last_Name,
		d.Email ,
		d.Gender,
		'Delete'  AS Activity 
FROM deleted d
END
END
ELSE
BEGIN
INSERT INTO [dbo].[Archive]
	(
	Email_Id,
	First_Name,
	Last_Name,
	Email,
	Gender,
	Activity 
	)
SELECT Ins.Id AS Email_Id ,
		Ins.First_Name,
		Ins.Last_Name,
		Ins.Email ,
		Ins.Gender,
		'Insert'  AS Activity 
FROM inserted Ins
END
--=================================
-- To Extract a specific value from a string 
DECLARE @dateString NVARCHAR(50) = 'Feb 28, 2024, 6:26 PM';
SELECT SUBSTRING(@dateString, CHARINDEX(',', @dateString) + 2, 4) AS SecondCharacterAfterComma;
--SecondCharacterAfterComma
--2024
--================================
GO
-- To find a comma possition that occurrence on the thired possition. 

DECLARE @DateString NVARCHAR(50) = 'Feb 28, 2024, 6,:26 PM';
SELECT CHARINDEX(',', @dateString, CHARINDEX(',', @dateString) + 1) AS SecondCommaPosition;

--SecondCommaPosition
--13
Go
--================================
-- Date with three comma in diffrent possition
DECLARE @dateString NVARCHAR(50) = 'Feb 28, 2024, 6,:26 PM';
DECLARE @StringValue INT = CHARINDEX(',', @dateString, CHARINDEX(',', @dateString, CHARINDEX(',', @dateString) + 1) + 1)-4
DECLARE @DateValue DATE
DECLARE @DateExtract VARCHAR(50) = SUBSTRING(@dateString,1,@StringValue)
SET @DateValue = @DateExtract
SELECT @DateValue AS ExtractedDate
--ExtractedDate
--2024-02-28
GO
--=================================
--This query helps us find the number of transactions performed within a specific 
--date interval. In our case, the interval is the last 7 days from today's date
--Scenario
--Assume we have a table called @View_STGFamilyLiving that records daily transactions. 
--The table has the following data:

DECLARE @View_STGFamilyLiving TABLE 
(
    ID INT PRIMARY KEY,
    Date DATE,
    TransactionAmount DECIMAL(10,2)
);
INSERT INTO @View_STGFamilyLiving 
(ID, Date, TransactionAmount)
VALUES
(1, '2025-01-25', 100.00),
(2, '2025-01-26', 200.00),
(3, '2025-01-27', 150.00),
(4, '2025-01-28', 300.00),
(5, '2025-01-29', 250.00),
(6, '2025-01-30', 400.00),
(7, '2025-01-31', 500.00),
(8, '2025-02-01', 600.00);
  --=================
  --Now, you can execute either of these queries to count the number of distinct transaction dates in the last 7 days:

SELECT COUNT(DISTINCT DATE) AS Count_Of_Transaction 
FROM @View_STGFamilyLiving
WHERE DATE >=  
      (SELECT DISTINCT DATEADD(DAY, -7, GETDATE()) AS seven_days_ago FROM @View_STGFamilyLiving)

--GETDATE() returns today�s date (2025-02-01).
--DATEADD(DAY, -7, GETDATE()) subtracts 7 days, giving 2025-01-25.
--The WHERE clause ensures we count only transactions from 2025-01-25 to 2025-02-01.
--The COUNT(DISTINCT DATE) ensures we count unique transaction dates.
--The simplest form of the query can be solved using this streamlined version.
--This clearly indicates that the provided query is a simplified and more efficient alternative to the original.
  
SELECT COUNT(DISTINCT DATE) AS Count_Of_Transaction
FROM @View_STGFamilyLiving
WHERE DATE >= DATEADD(DAY, -7, GETDATE());

--The second query is more efficient and produces the same result.
--DATEADD(DAY, -7, GETDATE()) ensures we get the last 7 days, including today.
--COUNT(DISTINCT DATE) ensures only unique dates are counted.
--====================================================
--If you're getting 7 instead of 8, it's likely because of how GETDATE() works. Let's debug step by step.
--Potential Issue: GETDATE() Returns Date & Time
--GETDATE() returns both date and time, e.g., 2025-02-01 14:30:00.000.
--When using DATEADD(DAY, -7, GETDATE()), it calculates **2025-01-25 14:30:00.000`.
--If your Date column is of type DATE (without time), it only stores 2025-01-25.
--This causes the query to exclude the earliest date (2025-01-25) because of the >= condition.
--Solution: Use CAST(GETDATE() AS DATE)

SELECT COUNT(DISTINCT Date) AS Count_Of_Transaction
FROM @View_STGFamilyLiving
WHERE Date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE));

--Why This Works
--CAST(GETDATE() AS DATE) removes the time part, so it becomes 2025-02-01 00:00:00.000.
--Now, DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) gives 2025-01-25 00:00:00.000, correctly including 2025-01-25.
        
--Alternative Debugging Query
--Run this to check the calculated date:

SELECT DATEADD(DAY, -7, GETDATE()) AS WithTime,
DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) AS WithoutTime;

--If the WithTime result is causing an issue, the WithoutTime version will fix it.
          
--Expected Fix Output
--Now, when you run:

SELECT COUNT(DISTINCT Date) AS Count_Of_Transaction
FROM @View_STGFamilyLiving
WHERE Date >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE));

--=================================================================
