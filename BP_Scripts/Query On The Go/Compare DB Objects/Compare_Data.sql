USE [EHCR]
GO
/****** Object:  StoredProcedure [dbo].[simple_cursor]    Script Date: 1/28/2020 12:25:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[simple_cursor] 
@vFrom_DT DATETIME,
@vTO_DT DATETIME
AS
BEGIN
DECLARE @vEmpName VARCHAR(50), @vEmpId INT,@vWork_Alloc INT
DECLARE @vEmpTable AS TABLE(EMP_ID INT,EMP_NAME VARCHAR(50),WORK_ALLOC INT,FROM_DATE DATETIME, TO_DATE DATETIME)
DECLARE @vEmpHistTable AS TABLE(EMP_ID INT,EMP_NAME VARCHAR(50),WORK_ALLOC INT,DATA_ENTRY_DATE DATETIME)
DECLARE @vHCRAuditTable AS TABLE(EMP_ID INT,COLUMN_NAME VARCHAR(100),OLD_VALUE VARCHAR(8000),NEW_VALUE VARCHAR(8000),COMMENT VARCHAR(8000),ENTRY_DATE DATETIME,FROM_DATE DATETIME, TO_DATE DATETIME)
DECLARE @vST_DT DATE=CONVERT(DATE, @vFrom_DT)--CAST(CONVERT(VARCHAR(8), @vFrom_DT,112) AS INT)
DECLARE @vED_DT DATE=CONVERT(DATE, @vTO_DT)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vAuditComment VARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100)

DECLARE curr_audit_check CURSOR FOR
	SELECT TOP 100 Employee_Id,EmpName,Work_Alloc FROM HCR_Data WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
	OPEN curr_audit_check    
	
	FETCH NEXT FROM curr_audit_check INTO @vEmpId,@vEmpName,@vWork_Alloc
  
		WHILE @@FETCH_STATUS = 0    
		BEGIN 

			WHILE (@vST_DT<=@vED_DT)
			BEGIN

				INSERT INTO @vEmpHistTable
				SELECT  Employee_Id,EmpName,Work_Alloc,Date FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId

				IF EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId)
				BEGIN
					
					DECLARE curr_data_comp CURSOR FOR
						SELECT SC.name FROM sys.tables ST INNER JOIN sys.columns SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data'
					OPEN curr_data_comp    
					
					
					FETCH NEXT FROM curr_data_comp INTO @_vCol_Name
  
					WHILE @@FETCH_STATUS = 0    
					BEGIN 
						IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
						BEGIN
						  DROP TABLE #currentData
						END

						IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
						BEGIN
						  DROP TABLE #prevData
						END
						
						SELECT * INTO #currentData FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId
						SELECT * INTO #prevData FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = (SELECT MAX(DATE) FROM HCR_Data WHERE Employee_Id =@vEmpId AND CONVERT(DATE, Date) < @vST_DT)
						

						SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

						SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
						EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

						SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
						EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT

						IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
							INSERT INTO @vHCRAuditTable(EMP_ID,COLUMN_NAME,OLD_VALUE,NEW_VALUE,COMMENT,ENTRY_DATE,FROM_DATE,TO_DATE)
							VALUES(@vEmpId,@_vCol_Name,@_vOldValue,@_vNewValue, 'Value of column: '+@_vCol_Name+' has changed from old value: '+@_vOldValue+' to new value : '+@_vNewValue,@vST_DT,@vFrom_DT,@vTO_DT)
						
						FETCH NEXT FROM curr_data_comp INTO @_vCol_Name
					END
	
					CLOSE curr_data_comp;    
					DEALLOCATE curr_data_comp;
					
				END

				SELECT @vST_DT=DATEADD(DD, 1, @vST_DT)

			END

			SET @vST_DT =CONVERT(DATE, @vFrom_DT)
			SET @vED_DT =CONVERT(DATE, @vTO_DT)


			FETCH NEXT FROM curr_audit_check INTO @vEmpId,@vEmpName,@vWork_Alloc

		END
		CLOSE curr_audit_check
		DEALLOCATE curr_audit_check

		--SELECT * FROM @vEmpHistTable
		SELECT * FROM @vHCRAuditTable
END
