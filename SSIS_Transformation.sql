    ------ Transformation ---
--Rename SSIS file Name With Date Time Stamp
DECLARE @FileName VARCHAR(MAX) = 'J:\16-Titanic Data.xlsx',
@TimeStamp DATETIME = GETDATE()
SELECT  CONCAT(
          REPLACE(@FileName,'.xlsx','_'),
          REPLACE(
		        REPLACE(
				     REPLACE(
					      SUBSTRING(CONVERT(VARCHAR(50),@TimeStamp,120),1,19),' ','_'),':',''),'-',''),
		                        '.xlsx') AS FileName_Timestamp