USE PCS
GO
IF OBJECT_ID('tempdb..#TempObjectInfo') IS NOT NULL
BEGIN
  TRUNCATE TABLE #TempObjectInfo
END
ELSE
BEGIN
	CREATE TABLE #TempObjectInfo
	(
	Object_Name VARCHAR(500),
	xType VARCHAR(100),
	PCST_Code_Length INT,
	Most_Common_Code_Length VARCHAR(5),
	CM_Name VARCHAR(100),
	CM_Code_Length  INT,
	CM_CrDate DATETIME,
	PCST_CrDate DATETIME
	)
END
GO
BEGIN

DECLARE @vClientHostName VARCHAR(100)
DECLARE @vPCSTObject VARCHAR(MAX)
DECLARE @vInnerSelect_Table TABLE(CM_Code_Length INT, CM_CrDate DATETIME)

DECLARE @vxType VARCHAR(100)
DECLARE @vPCST_Code_Length INT
DECLARE @vMost_Common_Code_Length INT
DECLARE @vPCST_CrDate DATETIME
DECLARE @vCursorDynQuery NVARCHAR(MAX)
DECLARE @vInnerSelectQuery NVARCHAR(MAX)

DECLARE GetClient_Cursor CURSOR LOCAL FOR
	
	SELECT '['+ConsoleHostName+']' FROM tblPCMConsoles WHERE Active=1 AND ConsoleHostName IN('SPH-PCCM','SYZ-PCCM','USTLSPCMAMS01','WYNPCMEMEA01')
	--IN('HSU-PCCM','KDH-PCCM','NLR-PCCM','SLR-PCCM')
	--IN('ACR-PCCM','ATC-PCCM','DXS-PCCM','EDC-PCCM')
	--NOT IN('AUBWS101','AUBWSPCM001','DERUSPCM001','USPLSGOSD002')  /* 2000 and 2005 Servers */

OPEN GetClient_Cursor
	FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName

		WHILE @@FETCH_STATUS = 0

									BEGIN
									
									/*   Missing Object   */
									INSERT INTO #TempObjectInfo
										(
											Object_Name,
											xType,
											PCST_Code_Length,
											Most_Common_Code_Length,
											CM_Name,
											CM_Code_Length,
											CM_CrDate,
											PCST_CrDate
										)
									EXEC ('SELECT A.routine_name,
									A.ROUTINE_TYPE,
									LEN(A.ROUTINE_Definition),
									NULL,'''
									+@vClientHostName+''',
									NULL,
									NULL,
									A.Created FROM PCST.information_schema.ROUTINES A WHERE NOT EXISTS(SELECT 1 FROM '+@vClientHostName+'.PCS.information_schema.ROUTINES B WHERE A.routine_name=B.routine_name AND A.ROUTINE_NAME NOT LIKE ''bk%'' AND B.ROUTINE_NAME NOT LIKE ''bk%'')')

									/*   Insync and Differing Objetcs   */
									DECLARE @PCSTObjInfo_Cursor CURSOR
										
										SET @vCursorDynQuery= ('SET @cursor =  CURSOR FORWARD_ONLY STATIC FOR  SELECT A.routine_name FROM PCST.information_schema.ROUTINES A INNER JOIN '+@vClientHostName+'.PCS.information_schema.ROUTINES B On A.routine_name=B.routine_name WHERE A.ROUTINE_DEFINITION IS NOT NULL AND A.ROUTINE_NAME NOT LIKE ''bk%'' AND B.ROUTINE_NAME NOT LIKE ''bk%'' OPEN @cursor')
										
										EXEC SYS.SP_EXECUTESQL
											@vCursorDynQuery
											,N'@cursor cursor output'
											,@PCSTObjInfo_Cursor OUTPUT

										FETCH NEXT FROM @PCSTObjInfo_Cursor INTO @vPCSTObject

											WHILE @@FETCH_STATUS = 0
	
											BEGIN										

												SELECT 
													@vxType=A.ROUTINE_TYPE,
													@vPCST_Code_Length=LEN(A.ROUTINE_Definition),
													@vPCST_CrDate=A.created
												FROM PCST.information_schema.ROUTINES A
												WHERE A.routine_name=@vPCSTObject AND A.ROUTINE_Definition IS NOT NULL
												
												SET @vInnerSelectQuery='SELECT 
												LEN(A.ROUTINE_Definition),
												A.created
												FROM '+@vClientHostName+'.PCS.information_schema.ROUTINES A
												WHERE A.routine_name='''+@vPCSTObject+''' AND A.ROUTINE_Definition IS NOT NULL'

												DELETE FROM @vInnerSelect_Table

												INSERT INTO @vInnerSelect_Table(CM_Code_Length,CM_CrDate)
												EXEC(@vInnerSelectQuery)					
								

												INSERT INTO #TempObjectInfo
															(
																Object_Name,
																xType,
																PCST_Code_Length,
																Most_Common_Code_Length,
																CM_Name,
																CM_Code_Length,
																CM_CrDate,
																PCST_CrDate
															)
														Values
															(
																@vPCSTObject,
																@vxType,
																@vPCST_Code_Length,
																CASE WHEN @vPCST_Code_Length=(SELECT CM_Code_Length FROM @vInnerSelect_Table) THEN 'YES' ELSE 'NO' END,
																@vClientHostName,
																(SELECT CM_Code_Length FROM @vInnerSelect_Table),
																(SELECT CM_CrDate FROM @vInnerSelect_Table),
																@vPCST_CrDate
															)

												FETCH NEXT FROM @PCSTObjInfo_Cursor INTO @vPCSTObject
											END
											CLOSE @PCSTObjInfo_Cursor
											IF CURSOR_STATUS('global','@PCSTObjInfo_Cursor')>=-1
											BEGIN
											 DEALLOCATE @PCSTObjInfo_Cursor
											END
									
									/* Extra Objects */
									INSERT INTO #TempObjectInfo
											(
												Object_Name,
												xType,
												PCST_Code_Length,
												Most_Common_Code_Length,
												CM_Name,
												CM_Code_Length,
												CM_CrDate,
												PCST_CrDate
											)
									EXEC('SELECT A.routine_name,
									A.ROUTINE_TYPE,
									NULL,
									NULL,'''+
									@vClientHostName+''',
									LEN(A.ROUTINE_Definition),
									A.Created,
									NULL
									FROM '+@vClientHostName+'.PCS.information_schema.ROUTINES A WHERE NOT EXISTS(SELECT 1 FROM PCST.information_schema.ROUTINES B WHERE A.routine_name=B.routine_name AND A.ROUTINE_NAME NOT LIKE ''bk%'' AND B.ROUTINE_NAME NOT LIKE ''bk%'')')

									SET @vCursorDynQuery = ''

									FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName
					END
					CLOSE GetClient_Cursor
					IF CURSOR_STATUS('global','GetClient_Cursor')>=-1
					BEGIN
						DEALLOCATE GetClient_Cursor
					END

DELETE FROM #TempObjectInfo WHERE Object_Name LIKE 'bk%'
SELECT * FROM #TempObjectInfo
END
