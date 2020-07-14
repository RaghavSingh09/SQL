CREATE FUNCTION dbo.UFN_SEPARATES_COLUMNS(
 @TEXT      varchar(8000)
,@COLUMN    tinyint
,@SEPARATOR char(1)
)RETURNS varchar(8000)
AS
  BEGIN
       DECLARE @POS_START  int = 1
       DECLARE @POS_END    int = CHARINDEX(@SEPARATOR, @TEXT, @POS_START)
 
       WHILE (@COLUMN >1 AND @POS_END> 0)
         BEGIN
             SET @POS_START = @POS_END + 1
             SET @POS_END = CHARINDEX(@SEPARATOR, @TEXT, @POS_START)
             SET @COLUMN = @COLUMN - 1
         END
 
       IF @COLUMN > 1  SET @POS_START = LEN(@TEXT) + 1
       IF @POS_END = 0 SET @POS_END = LEN(@TEXT) + 1
 
       RETURN SUBSTRING (@TEXT, @POS_START, @POS_END - @POS_START)
  END
GO
CREATE TABLE Temp_Attach
(
Attach_Info NVARCHAR(MAX)
)
GO
DECLARE @vAttchmentValues NVARCHAR(MAX)

DECLARE add_attach_cur CURSOR FOR     
SELECT Attach_Info FROM TEMP_ATTACH  
OPEN add_attach_cur    
  
FETCH NEXT FROM add_attach_cur INTO @vAttchmentValues
  
	WHILE @@FETCH_STATUS = 0    
	BEGIN    
		
		SELECT
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 1, '^') AS Attach_Name,
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 2, '^') AS Attach_Size
      
		FETCH NEXT FROM add_attach_cur INTO @vAttchmentValues
   
	END     
CLOSE add_attach_cur;    
DEALLOCATE add_attach_cur;    