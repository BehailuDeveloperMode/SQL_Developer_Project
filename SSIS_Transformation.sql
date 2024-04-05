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
--====================================
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
--      ,? -- 1
--	  ,? -- 2
--	  ,@Updated 
--	  ,GETDATE()
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
--======================================
