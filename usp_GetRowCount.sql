ALTER PROCEDURE [dbo].[usp_GetRowCount]
(
@vInFolderPath VARCHAR(4000),
@vOutFilePath VARCHAR(4000)=NULL,
@vDate VARCHAR(10)=NULL,
@vFile_Name VARCHAR(1000)=NULL,
@vMsg_Out VARCHAR(2000) OUT
)
AS
BEGIN

DECLARE @vTempFileInfo AS TABLE(ID INT IDENTITY,File_Info VARCHAR(MAX))
DECLARE @vFileData AS TABLE(File_Name VARCHAR(8000),Row_Count BIGINT,File_Size INT,File_Location VARCHAR(MAX))
DECLARE @_vFCnt INT=0, @_vFMaxCnt INT=0,@vFileInfoStr VARCHAR(MAX)
DECLARE @vPSCommand VARCHAR(1000)
DECLARE @vPSDir VARCHAR(1000)= 'C:\Users\rkumar699\Desktop\ReadRowCount.ps1'

SET @vInFolderPath = @vInFolderPath+' '+ISNULL(@vOutFilePath,'~')+' '+ISNULL(@vDate,'~')
SET @vPSCommand = 'powershell.exe '+'"'+@vPSDir+'" '+@vInFolderPath
SET @vFile_Name = '%' + (SELECT REPLACE(REPLACE(@vFile_Name,'*','%'), '?','_'))

INSERT INTO @vTempFileInfo EXECUTE master.dbo.xp_cmdshell @vPSCommand
DELETE FROM @vTempFileInfo WHERE File_Info IS NULL
--PRINT @vPSCommand
--SELECT * FROM @vTempFileInfo

SELECT @_vFCnt=0, @_vFMaxCnt=0
IF((SELECT COUNT(*) FROM @vTempFileInfo)>0)
	BEGIN
		SELECT @_vFCnt=MIN(ID), @_vFMaxCnt= MAX(ID) FROM @vTempFileInfo
							
		WHILE(@_vFCnt<@_vFMaxCnt+1)
		BEGIN

			SELECT @vFileInfoStr = File_Info FROM @vTempFileInfo WHERE ID=@_vFCnt
			
			INSERT INTO @vFileData(File_Name,File_Location,File_Size,Row_Count)
			SELECT
				RIGHT(LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 1, ','))),CHARINDEX('\',REVERSE(LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 1, ',')))))-1) AS File_Name,
				SUBSTRING(LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 1, ','))),0,LEN(LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 1, ','))))-CHARINDEX('\',REVERSE(LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 1, ',')))))+2) AS File_Location,
				LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 2, ','))) AS File_Size,
				LTRIM(RTRIM(dbo.UFN_SEPARATES_COLUMNS(@vFileInfoStr, 3, ','))) AS Row_Count

			SELECT @_vFCnt=MIN(ID) FROM @vTempFileInfo WHERE ID>@_vFCnt
		END
	END

--SELECT * FROM @vFileData

IF NOT EXISTS(SELECT 1 FROM @vFileData)
BEGIN
	SELECT @vMsg_Out = 'No Files Present In The Folder!'
END
ELSE IF EXISTS(SELECT 1 FROM @vFileData) AND @vFile_Name IS NULL
BEGIN
	SELECT  File_Name,Row_Count,
			CASE WHEN File_Size>(1024*1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024*1024),2) AS VARCHAR(100))+' GB'  
			WHEN File_Size>(1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024),2) AS VARCHAR(100))+' MB' 
			WHEN File_Size>1024 
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024),2) AS VARCHAR(100))+' KB'
			ELSE
				CAST(File_Size AS VARCHAR(100))+' Bytes' END AS Actual_File_Size,
				File_Location
	FROM @vFileData 
	
	SELECT @vMsg_Out = 'Files Row Count Fetched Successfully'
END
ELSE IF EXISTS(SELECT 1 FROM @vFileData WHERE File_Name LIKE @vFile_Name OR File_Location LIKE @vFile_Name)
BEGIN
	SELECT  File_Name,Row_Count,
			CASE WHEN File_Size>(1024*1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024*1024),2) AS VARCHAR(100))+' GB'  
			WHEN File_Size>(1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024),2) AS VARCHAR(100))+' MB' 
			WHEN File_Size>1024 
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024),2) AS VARCHAR(100))+' KB'
			ELSE
				CAST(File_Size AS VARCHAR(100))+' Bytes' END AS Actual_File_Size,
			File_Location
	FROM @vFileData 
	WHERE File_Name LIKE @vFile_Name OR File_Location LIKE @vFile_Name
	
	SELECT @vMsg_Out = 'Files Row Count Fetched Successfully'
END
ELSE
BEGIN
	SELECT @vMsg_Out = 'No File With Matching Pattern ' + @vFile_Name + ' Exists In The Folder!'
END

END

