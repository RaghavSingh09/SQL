CREATE PROCEDURE SP_GetFile
@vFolderPath VARCHAR(1000),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @vDir VARCHAR(1000)--, @vFolderPath VARCHAR(1000)

IF OBJECT_ID('tempdb..#TempFileInfo') IS NOT NULL
BEGIN
	DROP TABLE #TempFileInfo
END

CREATE TABLE #TempFileInfo
(
ID INT IDENTITY,
File_Name VARCHAR(2000)
)

--SET @vFolderPath = 'C:\Users\rkumar699\Desktop\Test\Check'
SET @vDir = 'DIR '+ '"'+@vFolderPath+'"'
--PRINT @vDir

INSERT INTO #TempFileInfo EXECUTE master.dbo.xp_cmdshell @vDir

--Get all info about the directory
--SELECT * FROM #TempFileInfo

--To get only matching pattern files Nikhil*_Hello_*.txt 
DELETE FROM #TempFileInfo WHERE ID <6

IF NOT EXISTS(SELECT 1 FROM #TempFileInfo WHERE File_Name NOT LIKE '%<DIR>%' AND File_Name NOT LIKE '%bytes%' AND File_Name IS NOT NULL)
BEGIN
	SELECT @vMsg_Out = 'No Files Present In The Folder!'
END
ELSE IF EXISTS(SELECT 1 FROM #TempFileInfo WHERE File_Name NOT LIKE '%<DIR>%' AND File_Name NOT LIKE '%bytes%' AND File_Name IS NOT NULL AND File_Name LIKE '%Nikhil%_Hello_%.txt' )
BEGIN
	SELECT SUBSTRING(File_Name,40,LEN(File_Name)) AS FILE_NAMES FROM #TempFileInfo WHERE 
	File_Name NOT LIKE '%<DIR>%' AND File_Name NOT LIKE '%bytes%' AND File_Name IS NOT NULL AND
	File_Name LIKE '%Nikhil%_Hello_%.txt'

	SELECT @vMsg_Out = 'Matching File Names Extracted Successfully!'
END
ELSE
	SELECT @vMsg_Out = 'No File With Matching Pattern Exists In The Folder!'
END