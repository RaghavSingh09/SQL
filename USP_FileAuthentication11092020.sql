USE [demo]
GO
/****** Object:  StoredProcedure [dbo].[usp_FileAuthentication]    Script Date: 11/9/2020 4:50:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_FileAuthentication]
(
@vFolderPath VARCHAR(4000),
@vFileName VARCHAR(4000),
@username VARCHAR(4000),
@Password VARCHAR(4000),
@vMsg_Out nVARCHAR(500) OUT
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
   DATA VARCHAR(2000)
)

DECLARE @vPSDir VARCHAR(1000)= 'C:\Rupali\FileAuthe_1109.ps1'
DECLARE @vPSCommand VARCHAR(1000) = 'powershell.exe -ExecutionPolicy Unrestricted -file  '+@vPSDir+' '+@vFolderPath+' '+@vFileName+' '+@username+' '+@Password

----  PRINT @vPSCommand


   INSERT INTO #TempFileInfo  EXECUTE master.dbo.xp_cmdshell @vPSCommand
   DELETE FROM #TempFileInfo WHERE DATA like 'NotExist'  OR DATA IS NULL

IF not EXISTS(SELECT 1 FROM #TempFileInfo where SUBSTRING (DATA,0,CHARINDEX('&',DATA))= @username 
	and SUBSTRING(DATA,CHARINDEX('&',DATA)+1,LEN(DATA))=@Password and id=1  )
  BEGIN
	SELECT @vMsg_Out = 'Authentication failed - please verify your username and password'
   END
 
Else IF  EXISTS(SELECT 1 FROM #TempFileInfo where SUBSTRING (DATA,0,CHARINDEX('&',DATA))= @username 
	and SUBSTRING(DATA,CHARINDEX('&',DATA)+1,LEN(DATA))=@Password and id=1  )
   BEGIN
	
	 SELECT @vMsg_Out =  'Successfully authenticated with domain/'+ @username 

	  IF EXISTS(SELECT 1 FROM #TempFileInfo WHERE DATA LIKE @vFileName and id=2 )
         BEGIN
	        SELECT @username as UserName, @vFolderPath as File_Location, @vFileName as File_Names 
         END
	  Else 
	     BEGIN
	       SELECT @vMsg_Out = 'Files are absent In The Folder!'
          END
    END
 
  ---- SELECT * FROM #TempFileInfo

END



--declare @return int,
--@vMsg varchar(100)


--exec  @return= usp_FileAuthentication
--@vFolderPath='C:\Rupali',  
--@vFileName='test.txt',
--@username='rbirnale',
--@Password='Password',
--@vMsg_Out=@vMsg output
  


--select @vMsg as 'msg' 
--select 'retrun'= @return