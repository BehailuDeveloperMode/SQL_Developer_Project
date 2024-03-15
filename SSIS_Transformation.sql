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
DECLARE @A INT = 1
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
WHILE(@A<=@B)
BEGIN
INSERT INTO @UnpivotTable
SELECT CONCAT('Test_',@A),5000,6000,4000,7000,8000 
SET @A = @A+1
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
Salary FOR Month_Name IN(Jan,Feb,Mar,Apr,May)
)Unpivot_Imput
ORDER BY 6;
--==================================

