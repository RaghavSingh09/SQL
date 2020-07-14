USE PCS
GO

DECLARE @vConsoleHostName VARCHAR(100)
DECLARE @vClientNameWithVer AS TABLE (CM_Name VARCHAR(100),CM_Ver VARCHAR(500))

DECLARE CurServerVersion CURSOR FOR
	SELECT  '['+ConsoleHostName+']' FROM tblPCMConsoles WHERE Active=1
OPEN CurServerVersion

FETCH NEXT FROM CurServerVersion INTO @vConsoleHostName
			
	WHILE @@FETCH_STATUS = 0

			BEGIN

			INSERT INTO @vClientNameWithVer
			EXEC(
			'SELECT '''+@vConsoleHostName+''', * FROM OPENQUERY('+@vConsoleHostName+',''SELECT @@VERSION'')')

			FETCH NEXT FROM CurServerVersion INTO @vConsoleHostName
			END

	CLOSE CurServerVersion
	DEALLOCATE CurServerVersion
	
SELECT * FROM @vClientNameWithVer