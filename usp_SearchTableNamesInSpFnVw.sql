CREATE PROCEDURE [dbo].[usp_SearchTablesInSpFnVw]
AS
BEGIN
DECLARE @vTab AS TABLE (Obj_Type VARCHAR(50),Obj_Name VARCHAR(500),Table_Schema VARCHAR(50),Table_Name VARCHAR(500))
DECLARE @vTableInfo AS TABLE (Table_Info VARCHAR(MAX))
DECLARE @vObj_Type VARCHAR(50),@vObj_Schema VARCHAR(50),@vObj_Name VARCHAR(500),@vObj_Def VARCHAR(MAX), @vDefStr VARCHAR(MAX)=''

DECLARE TableSearchInSPFN CURSOR
    FOR SELECT ROUTINE_TYPE,SPECIFIC_SCHEMA,ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES --WHERE ROUTINE_NAME = 'Sp_GetWTCode_ByTagId'-- AND SPECIFIC_SCHEMA = 'Test'

	OPEN TableSearchInSPFN;
		FETCH NEXT FROM TableSearchInSPFN INTO @vObj_Type,@vObj_Schema,@vObj_Name;
	WHILE @@FETCH_STATUS = 0
    BEGIN
		
		DELETE FROM @vTableInfo
		SET @vDefStr=''
		SET @vObj_Name = @vObj_Schema+'.'+@vObj_Name
		
		INSERT INTO @vTableInfo
			EXEC SP_HELPTEXT @vObj_Name

		SET @vDefStr = (SELECT ' '+Table_Info FROM @vTableInfo FOR XML PATH(''))
		SET @vDefStr = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@vDefStr,'&#x0D;',''),'[',''),']',''),'&amp;',''),CHAR(10),' ')
		DELETE FROM @vTableInfo
		
		INSERT INTO @vTableInfo
			SELECT TAB.Value FROM DBO.Fn_SplitDelimetedData('.',@vDefStr) AS TAB WHERE LEN(LTRIM(RTRIM(TAB.Value)))>0

		SET @vDefStr = (SELECT ' '+Table_Info FROM @vTableInfo FOR XML PATH(''))
		SET @vDefStr = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@vDefStr,'&#x0D;',''),'[',''),']',''),'&amp;',''),CHAR(10),' ')
		DELETE FROM @vTableInfo

		INSERT INTO @vTableInfo
			SELECT TAB.Value FROM DBO.Fn_SplitDelimetedData(CHAR(32),@vDefStr) AS TAB WHERE LEN(LTRIM(RTRIM(TAB.Value)))>0

		INSERT INTO @vTab
			SELECT @vObj_Type,@vObj_Name,IST.TABLE_SCHEMA,IST.TABLE_NAME FROM INFORMATION_SCHEMA.TABLES IST 
			INNER JOIN @vTableInfo TAB On IST.TABLE_NAME = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Table_Info,'''',''),' ',''))) 
			--LIKE '%'+LTRIM(RTRIM(TAB.Table_Info))+'%'
			WHERE IST.TABLE_TYPE = 'BASE TABLE' AND CHARINDEX(IST.TABLE_NAME,TAB.Table_Info)>0

        FETCH NEXT FROM TableSearchInSPFN INTO @vObj_Type,@vObj_Schema,@vObj_Name;
    END;
	CLOSE TableSearchInSPFN;
	DEALLOCATE TableSearchInSPFN;
	
DECLARE TableSearchInViews CURSOR
    FOR SELECT TABLE_SCHEMA,TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS

	OPEN TableSearchInViews;
		FETCH NEXT FROM TableSearchInViews INTO @vObj_Schema,@vObj_Name;
	WHILE @@FETCH_STATUS = 0  
    BEGIN
		
		DELETE FROM @vTableInfo
		SET @vDefStr=''
		SET @vObj_Name = @vObj_Schema+'.'+@vObj_Name
		
		INSERT INTO @vTableInfo
			EXEC SP_HELPTEXT @vObj_Name

		SET @vDefStr = (SELECT ' '+Table_Info FROM @vTableInfo FOR XML PATH(''))
		SET @vDefStr = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@vDefStr,'&#x0D;',''),'[',''),']',''),'&amp;',''),CHAR(10),' ')
		DELETE FROM @vTableInfo

		INSERT INTO @vTableInfo
			SELECT TAB.Value FROM DBO.Fn_SplitDelimetedData('.',@vDefStr) AS TAB WHERE LEN(LTRIM(RTRIM(TAB.Value)))>0

		SET @vDefStr = (SELECT ' '+Table_Info FROM @vTableInfo FOR XML PATH(''))
		SET @vDefStr = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@vDefStr,'&#x0D;',''),'[',''),']',''),'&amp;',''),CHAR(10),' ')
		DELETE FROM @vTableInfo
		
		INSERT INTO @vTableInfo
			SELECT TAB.Value FROM DBO.Fn_SplitDelimetedData(CHAR(32),@vDefStr) AS TAB WHERE LEN(LTRIM(RTRIM(TAB.Value)))>0

		INSERT INTO @vTab
			SELECT 'VIEW',@vObj_Name,IST.TABLE_SCHEMA,IST.TABLE_NAME FROM INFORMATION_SCHEMA.TABLES IST 
			INNER JOIN @vTableInfo TAB On IST.TABLE_NAME = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Table_Info,'''',''),' ','')))
			WHERE IST.TABLE_TYPE = 'BASE TABLE' --AND CHARINDEX(IST.TABLE_NAME,TAB.Table_Info)>0

        FETCH NEXT FROM TableSearchInViews INTO @vObj_Schema,@vObj_Name;
    END;
	CLOSE TableSearchInViews;
	DEALLOCATE TableSearchInViews;


	SELECT DISTINCT * FROM @vTab 
	--WHERE Table_Name = 'GPM_Country'
	ORDER BY Obj_Name

END