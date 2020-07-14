
TRUNCATE TABLE #TempObjectInfo
BEGIN
DECLARE @vClientHostName VARCHAR(100)
DECLARE @vCMObject VARCHAR(MAX)
DECLARE @vPCSTObject VARCHAR(MAX)
DECLARE @vCMObject_Table TABLE(PCS_Obj_Name VARCHAR(500))
DECLARE @vPCSTObject_Table TABLE(PCST_Obj_Name VARCHAR(500))
DECLARE @vObjectId VARCHAR(100)

DECLARE @vxType VARCHAR(100)
DECLARE @vPCST_Code_Length INT
DECLARE @vMost_Common_Code_Length INT
DECLARE @vCM_Name VARCHAR(100)
DECLARE @vCM_Code_Length  INT
DECLARE @vCM_CrDate DATETIME
DECLARE @vPCST_CrDate DATETIME

DECLARE GetClient_Cursor CURSOR LOCAL FOR
	
	SELECT top 1 '['+ConsoleHostName+']' FROM tblPCMConsoles WHERE Active=1

OPEN GetClient_Cursor
	FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName

		WHILE @@FETCH_STATUS = 0

								
									BEGIN
									--USE PCST
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
									SELECT A.routine_name,
									A.ROUTINE_TYPE,
									LEN(A.ROUTINE_Definition),
									NULL,
									@vClientHostName,
									NULL,
									NULL,
									A.Created FROM PCST.information_schema.ROUTINES A WHERE NOT EXISTS(SELECT 1 FROM PCS.information_schema.ROUTINES B WHERE A.routine_name=B.routine_name)


									DECLARE PCSTObjInfo_Cursor CURSOR LOCAL FOR
										
										SELECT top 10000 A.routine_name FROM PCST.information_schema.ROUTINES A INNER JOIN PCS.information_schema.ROUTINES B On A.routine_name=B.routine_name 

									OPEN PCSTObjInfo_Cursor
										FETCH NEXT FROM PCSTObjInfo_Cursor INTO @vPCSTObject

											WHILE @@FETCH_STATUS = 0
	
											BEGIN										

												SELECT 
													@vxType=A.ROUTINE_TYPE,
													@vPCST_Code_Length=LEN(A.ROUTINE_Definition),
													@vPCST_CrDate=A.created
												FROM PCST.information_schema.ROUTINES A
												WHERE A.routine_name=@vPCSTObject
												--INNER JOIN sys.all_objects B On A.object_id = B.object_id
												--WHERE B.name=@vPCSTObject AND B.type='P'
								
												SELECT 
												@vCM_Code_Length=NULL,
												@vCM_CrDate=NULL
								
												BEGIN
												--USE PCS

												SELECT 
												@vCM_Code_Length=LEN(A.ROUTINE_Definition),
												@vCM_CrDate=A.created
												FROM PCS.information_schema.ROUTINES A
												--INNER JOIN PCS.sys.all_objects B On A.object_id = B.object_id
												--WHERE  B.name=@vPCSTObject AND B.type='P'
												--WHERE A.Object_Id=@vObjectId
												WHERE A.routine_name=@vPCSTObject

								
												END
								

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
																NULL,
																@vClientHostName,
																@vCM_Code_Length,
																@vCM_CrDate,
																@vPCST_CrDate
															)

												FETCH NEXT FROM PCSTObjInfo_Cursor INTO @vPCSTObject
											END
											CLOSE PCSTObjInfo_Cursor
											DEALLOCATE PCSTObjInfo_Cursor

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
									SELECT A.routine_name,
									A.ROUTINE_TYPE,
									NULL,
									NULL,
									@vClientHostName,
									LEN(A.ROUTINE_Definition),
									A.Created,
									NULL
									FROM PCS.information_schema.ROUTINES A WHERE NOT EXISTS(SELECT 1 FROM PCST.information_schema.ROUTINES B WHERE A.routine_name=B.routine_name)

									FETCH NEXT FROM GetClient_Cursor INTO @vClientHostName
									--PRINT @vClientHostName
					END
					CLOSE GetClient_Cursor
					DEALLOCATE GetClient_Cursor

SELECT * FROM #TempObjectInfo
END
