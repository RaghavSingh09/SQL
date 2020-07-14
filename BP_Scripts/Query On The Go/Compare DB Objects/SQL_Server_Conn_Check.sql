/*
Create a table ServerInfo and insert server names into Server_Name column as below then execute the script.
CREATE TABLE ServerInfo(Server_Name VARCHAR(500))
INSERT INTO ServerInfo VALUES('IN5CD7031HD8\SSMS_TEST'),('.\SSMS_TEST'),('IN5CD7031HD\SSMS_TEST'),('134.251.103.78\MSSQL2017'),('.\MSSQL2017')
*/

IF OBJECT_ID('tempdb..#TempObjectInfo') IS NOT NULL
BEGIN
  TRUNCATE TABLE #TempObjectInfo
END
ELSE
BEGIN
	CREATE TABLE #TempObjectInfo
	(
	Server_Name VARCHAR(500),
	Connection_Status CHAR(1)
	)
END
GO
BEGIN

DECLARE @vServerName VARCHAR(500)
DECLARE @_vIs_Data INT
DECLARE @_vDynConnQuery NVARCHAR(MAX)=NULL

DECLARE GetSQLConn_Cursor CURSOR LOCAL FOR
	SELECT '['+Server_Name+']' FROM ServerInfo
OPEN GetSQLConn_Cursor
	FETCH NEXT FROM GetSQLConn_Cursor INTO @vServerName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @_vDynConnQuery = ''
			SET @_vIs_Data=0
			SET @_vDynConnQuery = 'SELECT @_vIs_Data = COUNT(1) FROM '+ @vServerName+'.master.sys.objects'
	
			BEGIN TRY
				EXECUTE SP_EXECUTESQL @_vDynConnQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT
			END TRY
			BEGIN CATCH
				INSERT INTO #TempObjectInfo VALUES(@vServerName,'N')
			END CATCH

			IF(@_vIs_Data > 0)
				INSERT INTO #TempObjectInfo VALUES(@vServerName,'Y')
			
			FETCH NEXT FROM GetSQLConn_Cursor INTO @vServerName
		END
		CLOSE GetSQLConn_Cursor
		IF CURSOR_STATUS('global','GetSQLConn_Cursor')>=-1
		BEGIN
			DEALLOCATE GetSQLConn_Cursor
		END
SELECT * FROM #TempObjectInfo
END

