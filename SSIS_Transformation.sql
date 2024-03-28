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
--=======================================
                      -- Write a SQL Query to Delete Parent Child Rows
					  -- Delete a row from a parent table
					  --aso will delete from child table