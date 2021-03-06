CREATE PROCEDURE [dbo].[usp_SearchIfZipFilePatternExists]
(
@vFolderPath VARCHAR(4000),
@vFileName VARCHAR(4000),
@vMsg_Out VARCHAR(2000) OUT
)
AS
BEGIN

DECLARE @vTempFileInfo AS TABLE(ID INT IDENTITY,File_Info VARCHAR(MAX))
DECLARE @vTempDataInfo AS TABLE(ID INT IDENTITY,Data_Info VARCHAR(MAX))
DECLARE @vFileData AS TABLE(FileName VARCHAR(8000),FileLoc VARCHAR(MAX),Is_Folder VARCHAR(10),File_Size INT,Modified_Date VARCHAR(50))
DECLARE @_vFCnt INT=0, @_vFMaxCnt INT=0,@vFileInfoStr VARCHAR(MAX)

DECLARE @vPSDir VARCHAR(1000)= 'C:\Users\rkumar699\Desktop\BoQ\ReadCompleteZipFileInfo.ps1'
DECLARE @vPSCommand VARCHAR(1000) = 'powershell.exe '+'"'+@vPSDir+'" '+@vFolderPath
SET @vFileName = '%' + (SELECT REPLACE(REPLACE(@vFileName,'*','%'), '?','_'))


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

			DELETE FROM @vTempDataInfo

			INSERT INTO @vTempDataInfo 
			SELECT 
			CASE WHEN LEN(RTRIM(LTRIM(Value)))>0 THEN Value ELSE NULL END
			FROM Fn_SplitDelimetedData('~',@vFileInfoStr)
			
			INSERT INTO @vFileData(FileName,FileLoc,Is_Folder,File_Size,Modified_Date)
			SELECT
			(SELECT Data_Info FROM @vTempDataInfo WHERE ID=(SELECT MIN(ID) FROM @vTempDataInfo)+0)AS FileName,
			(SELECT Data_Info FROM @vTempDataInfo WHERE ID=(SELECT MIN(ID) FROM @vTempDataInfo)+1)AS FileLoc,
			(SELECT Data_Info FROM @vTempDataInfo WHERE ID=(SELECT MIN(ID) FROM @vTempDataInfo)+2)AS Is_Folder,
			(SELECT Data_Info FROM @vTempDataInfo WHERE ID=(SELECT MIN(ID) FROM @vTempDataInfo)+3)AS File_Size,						
			(SELECT Data_Info FROM @vTempDataInfo WHERE ID=(SELECT MIN(ID) FROM @vTempDataInfo)+4)AS Modified_Date

			SELECT @_vFCnt=MIN(ID) FROM @vTempFileInfo WHERE ID>@_vFCnt
		END
	END

--SELECT * FROM @vFileData


IF NOT EXISTS(SELECT 1 FROM @vFileData)
BEGIN
	SELECT @vMsg_Out = 'No Files Present In The Folder!'
END
ELSE IF EXISTS(SELECT 1 FROM @vFileData WHERE FileName LIKE @vFileName OR FileLoc LIKE @vFileName)
BEGIN
	SELECT  FileName,FileLoc,Is_Folder,
			CASE WHEN File_Size>(1024*1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024*1024),2) AS VARCHAR(100))+' GB'  
			WHEN File_Size>(1024*1024)
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024*1024),2) AS VARCHAR(100))+' MB' 
			WHEN File_Size>1024 
				THEN CAST(ROUND(CAST(File_Size AS FLOAT)/(1024),2) AS VARCHAR(100))+' KB'
			ELSE
				CAST(File_Size AS VARCHAR(100))+' Bytes' END AS Actual_File_Size,
			Modified_Date
	FROM @vFileData 
	WHERE FileName LIKE @vFileName OR FileLoc LIKE @vFileName
	
	SELECT @vMsg_Out = 'Files Found'
END
ELSE
BEGIN
	SELECT @vMsg_Out = 'No File With Matching Pattern ' + @vFileName + ' Exists In The Zip Folder!'
END

END

