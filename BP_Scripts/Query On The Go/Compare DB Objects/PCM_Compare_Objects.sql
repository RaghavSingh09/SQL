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
DECLARE @vPCSTObjectName VARCHAR(MAX)
--CREATE TABLE PCST_Objects_Rep_Table (Object_Name VARCHAR(500), xType VARCHAR(100), PCST_Code_Length INT, PCST_CrDate DATETIME)
--CREATE TABLE PCS_Objects_Rep_Table(Object_Name VARCHAR(500), xType VARCHAR(100), CM_Code_Length INT, CM_CrDate DATETIME)
DECLARE @vInnerSelect_Table TABLE(CM_Code_Length INT, CM_CrDate DATETIME)

DECLARE @vxType VARCHAR(100)
DECLARE @vPCST_Code_Length INT
DECLARE @vMost_Common_Code_Length INT
DECLARE @vPCST_CrDate DATETIME
DECLARE @vCursorDynQuery NVARCHAR(MAX)
DECLARE @vInnerSelectQuery NVARCHAR(MAX)

TRUNCATE TABLE PCST_Objects_Rep_Table

INSERT INTO PCST_Objects_Rep_Table (Object_Name,xType,PCST_Code_Length,PCST_CrDate)
SELECT A.name,A.type_desc,SUM(LEN(RTRIM(LTRIM(B.text)))),A.create_date
	FROM PCST.sys.objects A INNER JOIN PCST.sys.syscomments B On A.object_id=B.id 
	WHERE B.encrypted=0 AND A.type IN('P','V','FN') GROUP BY A.name,B.id,A.type_desc,A.create_date

DECLARE GetClient_Cursor CURSOR LOCAL FOR
	
	SELECT '['+ConsoleHostName+']' FROM tblPCMConsoles WHERE Active=1 AND ConsoleHostName NOT IN('AUBWS101','AUBWSPCM001','DERUSPCM001','USPLSGOSD002')  /* 2000 and 2005 Servers */
	--IN('SPH-PCCM','SYZ-PCCM','USTLSPCMAMS01','WYNPCMEMEA01')
	--IN('HSU-PCCM','KDH-PCCM','NLR-PCCM','SLR-PCCM')
	--IN('ACR-PCCM','ATC-PCCM','DXS-PCCM','EDC-PCCM')
	--NOT IN('AUBWS101','AUBWSPCM001','DERUSPCM001','USPLSGOSD002')  /* 2000 and 2005 Servers */

OPEN GetClient_Cursor
	FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName

		WHILE @@FETCH_STATUS = 0

									BEGIN
									PRINT @vClientHostName
									TRUNCATE TABLE PCS_Objects_Rep_Table

									INSERT INTO PCS_Objects_Rep_Table (Object_Name,xType,CM_Code_Length,CM_CrDate)
									EXECUTE('SELECT
												A.name, A.type_desc,
												SUM(LEN(RTRIM(LTRIM(B.text)))),
												A.create_date
												FROM '+@vClientHostName+'.PCS.sys.objects A INNER JOIN '+@vClientHostName+'.PCS.sys.syscomments B On A.object_id=B.id 
												WHERE B.encrypted=0 AND A.type IN(''P'',''V'',''FN'') GROUP BY A.name,B.id,A.type_desc,A.create_date')
										
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
									EXECUTE('SELECT A.Object_Name,
									A.xType,
									A.PCST_Code_Length,
									NULL,'''
									+@vClientHostName+''',
									NULL,
									NULL,
									A.PCST_CrDate
									FROM PCST_Objects_Rep_Table A WHERE NOT EXISTS(SELECT 1 FROM PCS_Objects_Rep_Table B WHERE A.Object_Name=B.Object_Name AND B.Object_Name NOT LIKE ''bk%'') AND A.Object_Name NOT LIKE ''bk%''')
									
									/*   Insync and Differing Objetcs   */
									
									DECLARE @PCSTObjInfo_Cursor CURSOR

										
										
										SET @vCursorDynQuery= ('SET @cursor =  CURSOR FORWARD_ONLY STATIC FOR  SELECT A.Object_Name FROM PCST_Objects_Rep_Table A  INNER JOIN PCS_Objects_Rep_Table B On A.Object_Name=B.Object_Name AND B.Object_Name NOT LIKE ''bk%'' AND A.Object_Name NOT LIKE ''bk%'' OPEN @cursor')
										
										EXEC SYS.SP_EXECUTESQL
											@vCursorDynQuery
											,N'@cursor cursor output'
											,@PCSTObjInfo_Cursor OUTPUT

										FETCH NEXT FROM @PCSTObjInfo_Cursor INTO @vPCSTObject

											WHILE @@FETCH_STATUS = 0
	
											BEGIN										
						
												SELECT 
													@vxType=A.xType,
													@vPCST_Code_Length=A.PCST_Code_Length,
													@vPCST_CrDate=A.PCST_CrDate
												FROM PCST_Objects_Rep_Table A
												WHERE A.Object_Name=@vPCSTObject
												
												SET @vInnerSelectQuery='SELECT 
																		A.CM_Code_Length,
																		A.CM_CrDate
																		FROM PCS_Objects_Rep_Table A
																		WHERE A.Object_Name='''+@vPCSTObject+''''

												--PRINT @vInnerSelectQuery
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
																CASE WHEN @vPCST_Code_Length=(SELECT CM_Code_Length FROM @vInnerSelect_Table) THEN 'Yes' ELSE 'No' END,
																@vClientHostName,
																(SELECT CM_Code_Length FROM @vInnerSelect_Table),
																(SELECT CM_CrDate FROM @vInnerSelect_Table),
																@vPCST_CrDate
															)

												FETCH NEXT FROM @PCSTObjInfo_Cursor INTO @vPCSTObject
											END
											CLOSE @PCSTObjInfo_Cursor
											DEALLOCATE @PCSTObjInfo_Cursor
											--IF CURSOR_STATUS('global','@PCSTObjInfo_Cursor')>=-1
											--BEGIN
											--	DEALLOCATE @PCSTObjInfo_Cursor
											--END
											

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
									EXECUTE('SELECT A.Object_Name,
									A.xType,
									NULL,
									NULL,'''+
									@vClientHostName+''',
									A.CM_Code_Length,
									A.CM_CrDate,
									NULL									
									FROM PCS_Objects_Rep_Table A WHERE NOT EXISTS(SELECT 1 FROM PCST_Objects_Rep_Table B WHERE A.Object_Name=B.Object_Name AND B.Object_Name NOT LIKE ''bk%'') AND A.Object_Name NOT LIKE ''bk%''')
									
									SET @vCursorDynQuery = ''

									FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName
					END
					CLOSE GetClient_Cursor
					IF CURSOR_STATUS('global','GetClient_Cursor')>=-1
					BEGIN
						DEALLOCATE GetClient_Cursor
					END


--Deffering Objects
SELECT * FROM #TempObjectInfo WHERE Most_Common_Code_Length = 'No'
--InSync Objects
SELECT * FROM #TempObjectInfo WHERE Most_Common_Code_Length = 'Yes'
--Missing Objects
SELECT CM_Name, Object_Name, xType,PCST_Code_Length,PCST_CrDate FROM #TempObjectInfo WHERE CM_Code_Length IS NULL
--Extra Objects
SELECT CM_Name, Object_Name, xType,CM_Code_Length,CM_CrDate FROM #TempObjectInfo WHERE PCST_Code_Length IS NULL
END
