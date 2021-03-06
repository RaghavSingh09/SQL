USE [TEST]
GO
/****** Object:  StoredProcedure [dbo].[usp_SearchIfFilePatternExists]    Script Date: 7/1/2020 9:00:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_SearchIfZipFilePatternExists]
(
@vFolderPath VARCHAR(4000),
@vFileName VARCHAR(4000),
@vMsg_Out VARCHAR(2000) OUT
)
AS
BEGIN

IF OBJECT_ID('tempdb..#TempFileInfo') IS NOT NULL
BEGIN
	DROP TABLE #TempFileInfo
END

CREATE TABLE #TempFileInfo
(
ID INT IDENTITY,
File_Name VARCHAR(2000)
)

DECLARE @vPSDir VARCHAR(1000)= 'C:\Users\rkumar699\Desktop\ReadZipFileNames.ps1'
DECLARE @vPSCommand VARCHAR(1000) = 'powershell.exe '+'"'+@vPSDir+'" '+@vFolderPath
SET @vFileName = '%' + (SELECT REPLACE(REPLACE(@vFileName,'*','%'), '?','_'))

INSERT INTO #TempFileInfo EXECUTE master.dbo.xp_cmdshell @vPSCommand

DELETE FROM #TempFileInfo WHERE ID<5 OR File_Name IS NULL
--SELECT * FROM #TempFileInfo

IF NOT EXISTS(SELECT 1 FROM #TempFileInfo)
BEGIN
	SELECT @vMsg_Out = 'No Files Present In The Folder!'
END
ELSE IF EXISTS(SELECT 1 FROM #TempFileInfo WHERE File_Name LIKE @vFileName )
BEGIN
	SELECT 
	@vFolderPath+'\'+REPLACE(REPLACE(REPLACE(File_Name,'''',''),'::','\'),'/','\') AS File_Locations,
	SUBSTRING(File_Name,CHARINDEX('::',File_Name)+2,LEN(File_Name)) AS FILE_NAMES FROM #TempFileInfo WHERE
	File_Name LIKE @vFileName
	SELECT @vMsg_Out = 'Files Found'
END
ELSE
BEGIN
	SELECT @vMsg_Out = 'No File With Matching Pattern ' + @vFileName + ' Exists In The Zip Folder!'
END
END

