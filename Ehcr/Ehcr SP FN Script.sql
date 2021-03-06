USE [EHCR]
GO
/****** Object:  StoredProcedure [dbo].[CountOfEmployees]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CountOfEmployees] 
@vDmVl_Id INT,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL
AS
BEGIN
	
	DECLARE @vDM_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vVL_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)

	IF((@vPosition IS NULL OR LEN(LTRIM(RTRIM(@vPosition)))<=0) AND (@vDelivery_Unit IS NULL OR LEN(LTRIM(RTRIM(@vDelivery_Unit)))<=0))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id
	END
	ELSE IF((@vPosition IS NULL OR LEN(LTRIM(RTRIM(@vPosition)))<=0) AND @vDelivery_Unit IS NOT NULL)
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
	END
	ELSE IF(@vPosition IS NOT NULL AND (@vDelivery_Unit IS NULL OR LEN(LTRIM(RTRIM(@vDelivery_Unit)))<=0))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition
	END
	ELSE
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
	END
	
	INSERT INTO @vEmpCntWithLeveltab
	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
	SELECT GRADE_DESC,EMP_ID FROM @vDM_EmpCntTab
	UNION
	SELECT GRADE_DESC,EMP_ID FROM @vVL_EmpCntTab
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
	
	--SELECT * FROM @vEmpCntWithLeveltab

	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB
END



GO
/****** Object:  StoredProcedure [dbo].[ProcessDBRange]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--INSERT INTO destTable
--SELECT * FROM srcTable
--WHERE MyKey IN (SELECT MyKey FROM destTable)

Create procedure [dbo].[ProcessDBRange] (@Start_dt as varchar(15) =null, @End_dt as varchar(15) =null)
As
Begin
DECLARE @date as varchar(15)

DECLARE Cursor_ProcessDB CURSOR FOR
    Select Distinct Convert(varchar(15), [date], 112) as [date]
    From [date]
    Where [date] >= @Start_dt and [date] <= @End_dt
    Order By [date]

OPEN Cursor_ProcessDB

FETCH next FROM Cursor_ProcessDB
INTO @date

WHILE @@FETCH_STATUS = 0

BEGIN

Exec ProcessDB @date

FETCH next FROM Cursor_ProcessDB
INTO @date

END
CLOSE Cursor_ProcessDB
DEALLOCATE Cursor_ProcessDB
End	

GO
/****** Object:  StoredProcedure [dbo].[Rpt_GetCountOfEmployees]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_GetCountOfEmployees] 
@vDmVl_Id INT,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL
AS
BEGIN
	
	DECLARE @vDM_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vVL_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)

	IF((@vPosition IS NULL OR LEN(LTRIM(RTRIM(@vPosition)))<=0) AND (@vDelivery_Unit IS NULL OR LEN(LTRIM(RTRIM(@vDelivery_Unit)))<=0)AND (@vAccount IS NULL OR LEN(LTRIM(RTRIM(@vAccount)))<=0))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id
	END
	ELSE IF((@vPosition IS NULL OR LEN(LTRIM(RTRIM(@vPosition)))<=0) AND @vDelivery_Unit IS NOT NULL AND (@vAccount IS NULL OR LEN(LTRIM(RTRIM(@vAccount)))<=0))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit
	END
	ELSE IF(@vPosition IS NOT NULL AND (@vDelivery_Unit IS NULL OR LEN(LTRIM(RTRIM(@vDelivery_Unit)))<=0)AND (@vAccount IS NULL OR LEN(LTRIM(RTRIM(@vAccount)))<=0))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition
	END
	ELSE IF(@vPosition IS NOT NULL AND (@vDelivery_Unit IS NULL OR LEN(LTRIM(RTRIM(@vDelivery_Unit)))<=0)AND (@vAccount IS NOT NULL))
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(EndClient_GroupId))=@vAccount
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(EndClient_GroupId))=@vAccount
	END
	ELSE
	BEGIN
		INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND DM_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit AND LTRIM(RTRIM(EndClient_GroupId))=@vAccount
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=(SELECT  MAX(Date) from HCR_Data) AND VL_Empno = @vDmVl_Id AND LTRIM(RTRIM(POS))=@vPosition AND LTRIM(RTRIM(Delivery_Unit))=@vDelivery_Unit AND LTRIM(RTRIM(EndClient_GroupId))=@vAccount
	END
	
	INSERT INTO @vEmpCntWithLeveltab
	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
	SELECT GRADE_DESC,EMP_ID FROM @vDM_EmpCntTab
	UNION
	SELECT GRADE_DESC,EMP_ID FROM @vVL_EmpCntTab
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
	
	--SELECT * FROM @vEmpCntWithLeveltab

	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB
END



GO
/****** Object:  StoredProcedure [dbo].[samplereport]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[samplereport]
      
AS   

    select * from HCR_Data where date='2020-01-06'
      

GO
/****** Object:  StoredProcedure [dbo].[SaveComment]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveComment]

AS
Begin 
Declare @vUnique_Id int
Declare @vSv_Comment varchar(Max)

Select Comment from HCR_Comp_Details
where @vSv_Comment=@vSv_Comment and @vUnique_Id=@vUnique_Id  
end  

GO
/****** Object:  StoredProcedure [dbo].[simple_cursor]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[simple_cursor] 
@vFrom_DT DATETIME,
@vTO_DT DATETIME
AS
BEGIN
DECLARE @vEmpName VARCHAR(50), @vEmpId INT,@vWork_Alloc INT
--DECLARE @vEmpTable AS TABLE(EMP_ID INT,EMP_NAME VARCHAR(50),WORK_ALLOC INT,FROM_DATE DATETIME, TO_DATE DATETIME)
--DECLARE @vEmpHistTable AS TABLE(EMP_ID INT,EMP_NAME VARCHAR(50),WORK_ALLOC INT,DATA_ENTRY_DATE DATETIME)
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

				--INSERT INTO @vEmpHistTable
				--SELECT  Employee_Id,EmpName,Work_Alloc,Date FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId

				IF EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId)
				BEGIN
					
					DECLARE curr_data_comp CURSOR FOR
						SELECT SC.name FROM sys.tables ST INNER JOIN sys.columns SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name <> 'Date'
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

GO
/****** Object:  StoredProcedure [dbo].[SP_AccListByEmpId]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_AccListByEmpId]
	@EmployeeId int =2023505
as

Begin
select Distinct(EndClient_GroupID),EndClient_GroupName
from HCR_Comp_Details 
where DM_Empno= @EmployeeId
end

GO
/****** Object:  StoredProcedure [dbo].[Sp_AddEmp]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_AddEmp]
@v_EmpName varchar(max),
@v_EmpId INT,
@v_Role INT,
@v_Email_Id Varchar(max),
@v_ParentId INT,
@vMsg_Out VARCHAR(100) OUT

AS
BEGIN
--SELECT @v_Emp_Id=EmpId from User_Details 
--INSERT INTO User_Details
--VALUES('EmpId=@v_EmpId','RoleId=@v_Role','EmailId=@v_Email_Id','EmpName=@v_EmpName','Parent_Id=@v_ParentId','','','','','','')
INSERT INTO User_Details(EmpId,EmpName,RoleId,EmailId,Parent_Id)
VALUES(@v_EmpId,@v_EmpName,@v_Role,@v_Email_Id,@v_ParentId )


SELECT @vMsg_Out = 'Employee Added Successfully'



END


GO
/****** Object:  StoredProcedure [dbo].[SP_DataPush_Test_To_Temp]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DataPush_Test_To_Temp]
AS
BEGIN
DECLARE @vEmpId INT,@vPrj_Num INT,@vDate DATETIME

DECLARE Test_Data_Load_Cursor CURSOR FOR
	SELECT Employee_Id,Prj_Num,Date FROM HCR_Test_Data
	OPEN Test_Data_Load_Cursor    
	
	FETCH NEXT FROM Test_Data_Load_Cursor INTO @vEmpId,@vPrj_Num,@vDate
  
		WHILE @@FETCH_STATUS = 0    
		BEGIN
		IF EXISTS(SELECT 1 FROM HCR_Temp_Data WHERE Employee_Id = @vEmpId AND Date = @vDate AND Prj_Num = @vPrj_Num)
		BEGIN
			--PRINT 'Update |'+ CAST(@vEmpId AS VARCHAR)+' | '+CAST(@vDate AS VARCHAR)
			UPDATE Temp  SET Temp.Date = Test.Date, Temp.HcrId = Test.HcrId, Temp.Employee_Id = Test.Employee_Id, Temp.EmpName = Test.EmpName, Temp.DOJ = Test.DOJ, Temp.POS = Test.POS, Temp.EmpType = Test.EmpType, Temp.Work_Alloc = Test.Work_Alloc, Temp.Bill_Alloc = Test.Bill_Alloc, Temp.Grade_Desc = Test.Grade_Desc, Temp.EndClient_Id = Test.EndClient_Id, Temp.EndClient_Name = Test.EndClient_Name, Temp.EndClient_GroupId = Test.EndClient_GroupId, Temp.EndClient_GroupName = Test.EndClient_GroupName, Temp.Buisness_Org = Test.Buisness_Org, Temp.Delivery_Unit = Test.Delivery_Unit, Temp.Prj_Num = Test.Prj_Num, Temp.Prj_Name = Test.Prj_Name, Temp.Assign_StartDate = Test.Assign_StartDate, Temp.Assign_RelDate = Test.Assign_RelDate, Temp.Prj_Type = Test.Prj_Type, Temp.Prj_BillFlag = Test.Prj_BillFlag, Temp.DM_Empno = Test.DM_Empno, Temp.DM_EmpName = Test.DM_EmpName, Temp.VL_Empno = Test.VL_Empno, Temp.VL_Empname = Test.VL_Empname, Temp.DH_EmpNo = Test.DH_EmpNo, Temp.DH_EmpName = Test.DH_EmpName, Temp.Practice = Test.Practice, Temp.Sub_Practice = Test.Sub_Practice, Temp.Emp_Category = Test.Emp_Category, Temp.OP_Comm_Model = Test.OP_Comm_Model, Temp.OP_Serve_Type = Test.OP_Serve_Type, Temp.Sum_BillAlloc = Test.Sum_BillAlloc, Temp.Prj_BillFlag_Name = Test.Prj_BillFlag_Name, Temp.Category = Test.Category, Temp.Channel_Sys = Test.Channel_Sys, Temp.DU_leader = Test.DU_leader, Temp.Category_1 = Test.Category_1, Temp.Opt_ClientGrp = Test.Opt_ClientGrp, Temp.Supr_EmpNo = Test.Supr_EmpNo, Temp.Supr_Name = Test.Supr_Name
			FROM HCR_Temp_Data Temp INNER JOIN HCR_Test_Data Test On Temp.Employee_Id = Test.Employee_Id AND Temp.Date = Test.Date AND Temp.Prj_Num = Test.Prj_Num WHERE Temp.Employee_Id = @vEmpId AND Temp.Date = @vDate  AND Temp.Prj_Num = @vPrj_Num
		END
		ELSE
		BEGIN
			--PRINT 'Insert |'+ CAST(@vEmpId AS VARCHAR)+' | '+CAST(@vDate AS VARCHAR)
			INSERT INTO HCR_Temp_Data
			SELECT * FROM HCR_Test_Data WHERE  Employee_Id = @vEmpId AND Date = @vDate AND Prj_Num = @vPrj_Num
		END
		FETCH NEXT FROM Test_Data_Load_Cursor INTO @vEmpId,@vPrj_Num,@vDate
		END
	CLOSE Test_Data_Load_Cursor
	DEALLOCATE Test_Data_Load_Cursor
	IF CURSOR_STATUS('global','Test_Data_Load_Cursor')>=-1
	BEGIN
			DEALLOCATE Test_Data_Load_Cursor
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteUser]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[SP_DeleteUser](@empId int, @Is_deleted bit)
as
begin
Update User_Details
set
Is_Deleted=@Is_deleted
where EmpId=@empId
End

GO
/****** Object:  StoredProcedure [dbo].[Sp_EditEmp]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_EditEmp]
@v_Email varchar(max),
@v_Role INT,
@v_Emp_Id INT,
@v_Parent_Id INT
AS
BEGIN
--SELECT @v_Emp_Id=EmpId from User_Details 
Update User_Details
SET RoleId=@v_Role,EmailId=@v_Email,Parent_Id=@v_Parent_Id
where @v_Emp_Id=EmpId
END

GO
/****** Object:  StoredProcedure [dbo].[SP_For_SP_Rpt_GetTopWMQCountOfEmployeesV2]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_For_SP_Rpt_GetTopWMQCountOfEmployeesV2]
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@dateForChart varchar(20)
AS
BEGIN
	
	DECLARE @DateLatest As Date
	--Declare @vLevel As varchar(50)
	--Set @vLevel = 'L1-L2'
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)
	DECLARE @minDate Date = NULL
	DECLARE @maxDate Date = NULL

	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##temp4TrendChart') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4TrendChart
	END

	CREATE Table ##temp4TrendChart
	(
		EMP_ID INT,GRADE_DESC VARCHAR(50)
	)

	--SET @sqlString = 'Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	--POS, Category Into ##temp4TrendChart From HCR_Data '

	 SET @sqlString = 'Insert Into ##temp4TrendChart '
	 SET @sqlString = @sqlString + ' Select Distinct Employee_Id, Grade_Desc From HCR_Data '

              Set @whereString = ' Where Date = ''' + @dateForChart +''''

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)
	INSERT INTO @vEmpCntWithLeveltab

	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
		SELECT GRADE_DESC,EMP_ID FROM ##temp4TrendChart	
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
		
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT,TAB.DateValue
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB order by TAB.Grade_Desc desc
	drop table ##temp4TrendChart
END








GO
/****** Object:  StoredProcedure [dbo].[SP_Get_UpComing_EmpResignDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Get_UpComing_EmpResignDate] 
@vDmVl_Id int
AS
Declare @vdate Date
DECLARE @vRelDateTab AS TABLE(Employee_Id INT,EmpName VARCHAR(500),Prj_Num INT,Prj_Name VARCHAR(500),Assign_RelDate DATE,POS VARCHAR(MAX),DM_EMP_Name VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX),EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX),Opt_ClientGrp Varchar(max))
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
		BEGIN
		SET @vdate=(SELECT  MAX(Date) from HCR_Data)
		INSERT INTO @vRelDateTab
		SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Assign_RelDate,POS,DM_EmpName,Work_Alloc,Bill_Alloc,Grade_Desc,Delivery_Unit,EndClient_GroupName,Category,Opt_ClientGrp from HCR_Data where Assign_RelDate between @vdate and DATEADD(DAY,45,@vdate) AND date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id)
		END
	ELSE
		BEGIN
		SET @vdate=(SELECT  MAX(Date) from HCR_Data)
		INSERT INTO @vRelDateTab
		SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Assign_RelDate,POS,DM_EmpName,Work_Alloc,Bill_Alloc,Grade_Desc,Delivery_Unit,EndClient_GroupName,Category,Opt_ClientGrp from HCR_Data where Assign_RelDate between @vdate and DATEADD(DAY,45,@vdate) AND date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id)
		END
END

SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Assign_RelDate,POS,DM_EMP_Name,Work_Alloc,Bill_Alloc,Grade_Desc,Delivery_Unit,EndClient_GroupName,Category,Opt_ClientGrp FROM @vRelDateTab --WHERE Employee_Id = 2343433
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Assign_RelDate,POS,DM_EmpName,Work_Alloc,Bill_Alloc,Grade_Desc,Delivery_Unit,EndClient_GroupName,Category,Opt_ClientGrp from HCR_Data where date = (SELECT  MAX(Date) from HCR_Data) AND Employee_Id IN(
			(
			SELECT TAB.Employee_Id FROM
			(
			SELECT DISTINCT HD.Employee_Id,HD.EmpName,HD.Prj_Num,HD.Prj_Name,HD.Assign_RelDate from HCR_Data HD INNER JOIN @vRelDateTab RDT On HD.Employee_Id = RDT.Employee_Id where date = @vdate AND 
			VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id)
			UNION
			SELECT DISTINCT HD.Employee_Id,HD.EmpName,HD.Prj_Num,HD.Prj_Name,HD.Assign_RelDate from HCR_Data HD INNER JOIN @vRelDateTab RDT On HD.Employee_Id = RDT.Employee_Id where date = @vdate AND 
			VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id)
			) TAB
			GROUP BY TAB.Employee_Id,TAB.EmpName
			HAVING COUNT(*) > 1
			)
			)
			--AND Employee_Id = 2343433

GO
/****** Object:  StoredProcedure [dbo].[SP_Get_WorkAllocLessThanHundred]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Get_WorkAllocLessThanHundred] 
@vDmVl_Id int
AS
Declare @vdate Date
BEGIN
	SET NOCOUNT ON;
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			SELECT HD.Employee_Id,HD.EmpName,HD.Work_Alloc,TAB.Total_Work_Alloc,HD.Prj_Num,HD.Prj_Name,VL_Empname,HD.VL_Empno,HD.Grade_Desc,HD.Category,HD.POS,HD.Bill_Alloc,HD.Delivery_Unit,HD.EndClient_GroupName,HD.Opt_ClientGrp FROM
					(
					SELECT Employee_Id,EmpName,SUM(Work_Alloc) AS Total_Work_Alloc FROM HCR_Data WHERE 
					Date = @vdate
					GROUP BY Employee_Id,EmpName
					HAVING SUM(Work_Alloc)<100
					)TAB INNER JOIN HCR_Data HD On TAB.Employee_Id = HD.Employee_Id
					WHERE HD.Date = @vdate AND HD.VL_Empno=@vDmVl_Id
					ORDER BY HD.Employee_Id

END

GO
/****** Object:  StoredProcedure [dbo].[SP_Get_WorkAllocLessThanHundredForParimal]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Get_WorkAllocLessThanHundredForParimal] 
--@vDmVl_Id int
AS
Declare @vdate Date
BEGIN
	SET NOCOUNT ON;
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			SELECT HD.Employee_Id,HD.EmpName,HD.Prj_Num,HD.Prj_Name,VL_Empname,HD.VL_Empno,TAB.Total_Work_Alloc FROM
					(
					SELECT Employee_Id,EmpName,SUM(Work_Alloc) AS Total_Work_Alloc FROM HCR_Data WHERE 
					Date = @vdate
					GROUP BY Employee_Id,EmpName
					HAVING SUM(Work_Alloc)<100
					)TAB INNER JOIN HCR_Data HD On TAB.Employee_Id = HD.Employee_Id
					WHERE HD.Date = @vdate AND HD.VL_Empno=2164575
					ORDER BY HD.Employee_Id

END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetAccounts_ByVLDMId]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetAccounts_ByVLDMId]
@vDmVl_Id INT
AS
BEGIN
IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
    SELECT DISTINCT Opt_ClientGrp FROM HCR_Comp_Details  WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id)
    UNION
    SELECT DISTINCT Opt_ClientGrp FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND Opt_ClientGrp<>'' order by Opt_ClientGrp
ELSE
    BEGIN
        SELECT DISTINCT Opt_ClientGrp FROM HCR_Comp_Details WHERE VL_Empno=@vDmVl_Id 
        UNION
        SELECT DISTINCT Opt_ClientGrp FROM HCR_Comp_Details WHERE DM_Empno=@vDmVl_Id AND Opt_ClientGrp<>'' order by Opt_ClientGrp 
    END

 

END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetAllUsers]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllUsers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.*, b.Role_Name
	from User_Details  a inner join Role b
	on a.RoleId = b.Role_Id
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetChangeCategory]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SP_GetChangeCategory]
AS
select * from HCR_Change_Category

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetColumnsToDisplay]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Sp_GetColumnsToDisplay] 
@vDisplay INT
as
begin
if(@vDisplay=1)
SELECT * from CustomColumns where DisplayFlag=1
else select * from CustomColumns
end

 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlID]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlID]
@vAccID varchar(100) = null,
@vPrjID INT=0,
@vDmVlID INT,
@vNew INT
AS

BEGIN
DECLARE @sqlString VARCHAR(MAX)
DECLARE @selectString VARCHAR(MAX)
DECLARE @whereDM VARCHAR(MAX)
DECLARE @whereVL VARCHAR(MAX)
DECLARE @whereCNDM VARCHAR(MAX)
DECLARE @whereCNVL VARCHAR(MAX)
DECLARE @whereCNNDM VARCHAR(MAX)
DECLARE @whereCNNVL VARCHAR(MAX)
DECLARE @whereElseDM VARCHAR(MAX)
DECLARE @whereElseVL VARCHAR(MAX)
DECLARE @whereElseCNDM VARCHAR(MAX)
DECLARE @whereElseCNVL VARCHAR(MAX)
DECLARE @whereElseCNNDM VARCHAR(MAX)
DECLARE @whereElseCNNVL VARCHAR(MAX)
DECLARE @SelectTempTable varchar(MAX)
DECLARE @InsertString varchar(MAX)
DECLARE @LatestCompareDate varchar(MAX)

--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##tempCompDetails') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempCompDetails
	END
	 create Table ##tempCompDetails
				([Comp_Detail_Id] [int] NULL,
					[EMP_ID] [int] NOT NULL,
					[EmpName] [varchar](max) NULL,
					[Grade_Desc] [varchar](max) NULL,
					[Prj_Num] [varchar](max) NULL,
					[Prj_Name] [varchar](max) NULL,
					[FROM_DATE] [date] NULL,
					[TO_DATE] [date] NULL,
					[POS] [varchar](max) NULL,
					[Work_Alloc] [varchar](max) NULL,
					[Bill_Alloc] [varchar](max) NULL,
					[Delivery_Unit] [varchar](max) NULL,
					[EndClient_GroupName] [varchar](max) NULL,
					[EndClient_GroupID] [varchar](max) NULL,
					[Category] [varchar](max) NULL,
					[DM_Empno] [varchar](max) NULL,
					[VL_Empno] [varchar](max) NULL,
					[COMMENT] [varchar](max) NULL,
					[Emp_Status_Ind] [int] NULL,
					[Change_Category] [int] NULL,
					[EndClient_Id] [varchar](100) NULL,
					[HR_Level] [varchar](max) NULL,
					[Del_Unit] [varchar](max) NULL,
					[Location] [varchar](max) NULL,
					[Qrtr_Inf] [varchar](max) NULL,
					[Bill_Allocations] [varchar](max) NULL,
					[Opt_ClientGrp] [varchar](max) NULL,
					[TO_DATE_SORT] [varchar](max) NULL,
					[RowColor] [varchar](max) NULL
					)


IF(@vAccID=NULL)set @vAccID=NULL
IF(@vPrjID=0) set @vPrjID=NULL
SET @LatestCompareDate =' AND TO_DATE=(SELECT MAX(TO_DATE) FROM HCR_Comp_Details) '
SET @SelectTempTable='select * from ##tempCompDetails'
SET @InsertString='Insert into ##tempCompDetails '
SET @sqlString = ''
SET @selectString = ' SELECT *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS TO_DATE_SORT,[dbo].[Fn_RowColor](Emp_Status_Ind) as RowColor FROM HCR_Comp_Details '
SET @whereDM = ' WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNDM = ' WHERE  DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNDM = ' WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseCNDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))

IF (@vNew = 0)/*Latest Date Comp Details*/
BEGIN
	print 'this is a test msg'
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
			print 'hi'
			SET @sqlString = @selectString +@whereCNDM+@LatestCompareDate+' UNION '+ @selectString +@whereCNVL+@LatestCompareDate
			SET @sqlString=@InsertString+@sqlString
			PRINT @sqlString
			EXEC(@sqlString)
			
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
			print '2nd'
			SET @sqlString = @selectString +@whereCNDM+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNVL+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			PRINT @sqlString
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
		print '3rd'
			SET @sqlString = @selectString +@whereCNDM+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNVL+ @LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			PRINT @sqlString
        END
		--EXEC(@SelectTempTable)
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+@LatestCompareDate+' UNION '+ @selectString +@whereElseCNVL+@LatestCompareDate
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
		SET @sqlString = @selectString +@whereElseCNDM+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNVL+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNVL+@LatestCompareDate+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
	EXEC(@SelectTempTable)
END

IF(@vNew=1)/*All Comp Details*/
    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' UNION '+ @selectString +@whereCNNVL
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
		--EXEC(@SelectTempTable)
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' UNION '+ @selectString +@whereElseCNNVL
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
	EXEC(@SelectTempTable)
END


IF (@vNew = 2)/*For all employees*/
BEGIN

    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
           SET @sqlString = @selectString +@whereDM+' UNION '+ @selectString +@whereVL
		   SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
             SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
		--EXEC(@SelectTempTable)

    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' UNION '+ @selectString +@whereElseVL
		SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			--PRINT(@sqlString)
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
    ELSE
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
	EXEC(@SelectTempTable)
END
--select *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS TO_DATE_SORT,[dbo].[Fn_RowColor](Emp_Status_Ind) as RowColor from HCR_Comp_Details

END 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlID_NEW]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlID_NEW]
@vAccID varchar(100) = null,
@vPrjID INT=0,
@vDmVlID INT,
@vNew INT
AS

BEGIN
DECLARE @sqlString VARCHAR(MAX)
DECLARE @selectString VARCHAR(MAX)
DECLARE @whereDM VARCHAR(MAX)
DECLARE @whereVL VARCHAR(MAX)
DECLARE @whereCNDM VARCHAR(MAX)
DECLARE @whereCNVL VARCHAR(MAX)
DECLARE @whereCNNDM VARCHAR(MAX)
DECLARE @whereCNNVL VARCHAR(MAX)
DECLARE @whereElseDM VARCHAR(MAX)
DECLARE @whereElseVL VARCHAR(MAX)
DECLARE @whereElseCNDM VARCHAR(MAX)
DECLARE @whereElseCNVL VARCHAR(MAX)
DECLARE @whereElseCNNDM VARCHAR(MAX)
DECLARE @whereElseCNNVL VARCHAR(MAX)


IF(@vAccID=NULL)set @vAccID=NULL
IF(@vPrjID=0) set @vPrjID=NULL
SET @sqlString = ''
SET @selectString = 'SELECT *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS TO_DATE_SORT FROM HCR_Comp_Details '
SET @whereDM = ' WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNDM = ' WHERE COMMENT = '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNVL = ' WHERE COMMENT = '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseCNDM = ' WHERE COMMENT = '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNVL = ' WHERE COMMENT = '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))

IF (@vNew = 0)
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' UNION '+ @selectString +@whereCNVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
			--PRINT (@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
			--PRINT(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' UNION '+ @selectString +@whereElseCNVL
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
		SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		EXEC(@sqlString)
    END
END

IF(@vNew=1)
    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' UNION '+ @selectString +@whereCNNVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' UNION '+ @selectString +@whereElseCNNVL
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		EXEC(@sqlString)
    END
END


IF (@vNew = 2)/*For all employees*/
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
           SET @sqlString = @selectString +@whereDM+' UNION '+ @selectString +@whereVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
			
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
             SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' UNION '+ @selectString +@whereElseVL
			EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			--PRINT(@sqlString)
			EXEC(@sqlString)
    END
    ELSE
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
    END
END

END 
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlID_Old]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlID_Old]
@vAccID varchar(100) = null,
@vPrjID INT=null,
@vDmVlID INT,
@vNew INT
AS
BEGIN
IF (@vNew = 0)/*For employees with comment*/
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND COMMENT = ''
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID AND COMMENT = ''
    END
    ELSE
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND DM_Empno=@vDmVlID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND VL_Empno=@vDmVlID AND COMMENT = ''
    END
END
IF (@vNew = 1)/*For employees without comment*/

 

 

 

    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND COMMENT NOT LIKE ''
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID AND COMMENT NOT LIKE ''
    END
    ELSE
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND DM_Empno=@vDmVlID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND VL_Empno=@vDmVlID AND COMMENT NOT LIKE ''
    END
END

 

 

 

IF (@vNew = 2)/*For all employees*/
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
            UNION
            SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND Opt_ClientGrp=@vAccID
    END
    ELSE
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND DM_Empno=@vDmVlID
        UNION
        SELECT * FROM HCR_Comp_Details WHERE Opt_ClientGrp=@vAccID AND Prj_Num=@vPrjID AND VL_Empno=@vDmVlID
    END
END

 


END
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlID_TEST]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlID_TEST]
@vAccID varchar(100) = null,
@vPrjID INT=0,
@vDmVlID INT,
@vNew INT
AS

BEGIN
DECLARE @sqlString VARCHAR(MAX)
DECLARE @selectString VARCHAR(MAX)
DECLARE @whereDM VARCHAR(MAX)
DECLARE @whereVL VARCHAR(MAX)
DECLARE @whereCNDM VARCHAR(MAX)
DECLARE @whereCNVL VARCHAR(MAX)
DECLARE @whereCNNDM VARCHAR(MAX)
DECLARE @whereCNNVL VARCHAR(MAX)
DECLARE @whereElseDM VARCHAR(MAX)
DECLARE @whereElseVL VARCHAR(MAX)
DECLARE @whereElseCNDM VARCHAR(MAX)
DECLARE @whereElseCNVL VARCHAR(MAX)
DECLARE @whereElseCNNDM VARCHAR(MAX)
DECLARE @whereElseCNNVL VARCHAR(MAX)


IF(@vAccID=NULL)set @vAccID=NULL
IF(@vPrjID=0) set @vPrjID=NULL
SET @sqlString = ''
SET @selectString = 'SELECT *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS DOJ_SORT FROM HCR_Comp_Details '
SET @whereDM = ' WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNDM = ' WHERE COMMENT = '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNVL = ' WHERE COMMENT = '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseCNDM = ' WHERE COMMENT = '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseCNVL = ' WHERE COMMENT = '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+') '

IF (@vNew = 0)
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' UNION '+ @selectString +@whereCNVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
			--PRINT (@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
			--PRINT(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' UNION '+ @selectString +@whereElseCNVL
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
		SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		EXEC(@sqlString)
    END
END

IF(@vNew=1)
    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' UNION '+ @selectString +@whereCNNVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' UNION '+ @selectString +@whereElseCNNVL
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		EXEC(@sqlString)
    END
END


IF (@vNew = 2)/*For all employees*/
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
           SET @sqlString = @selectString +@whereDM+' UNION '+ @selectString +@whereVL
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
             SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' UNION '+ @selectString +@whereElseVL
			EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			EXEC(@sqlString)
    END
    ELSE
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			EXEC(@sqlString)
    END
END

END 
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlIDOOLLDD]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlIDOOLLDD]
@vAccID INT = 0,
@vPrjID INT=0,
@vDmVlID INT,
@vNew bit
AS
BEGIN
IF(@vAccID=0)set @vAccID=NULL
IF(@vPrjID=0) set @vPrjID=NULL
IF (@vNew = 0)
BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND COMMENT = '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND COMMENT = '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND COMMENT = ''
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND EndClient_GroupID=@vAccID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND EndClient_GroupID=@vAccID AND COMMENT = ''
    END
    ELSE 
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND DM_Empno=@vDmVlID AND COMMENT = ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND VL_Empno=@vDmVlID AND COMMENT = ''
    END
END

 

ELSE
    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND COMMENT NOT LIKE '' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
            UNION
            SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND COMMENT NOT LIKE '' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
        END
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND COMMENT NOT LIKE ''
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND EndClient_GroupID=@vAccID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND EndClient_GroupID=@vAccID AND COMMENT NOT LIKE ''
    END
    ELSE 
    BEGIN
        SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND DM_Empno=@vDmVlID AND COMMENT NOT LIKE ''
        UNION
        SELECT * FROM HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND Prj_Num=@vPrjID AND VL_Empno=@vDmVlID AND COMMENT NOT LIKE ''
    END
END
END 
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetComparedData_ByAccPrjDmVlIDTest]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetComparedData_ByAccPrjDmVlIDTest]
@vAccID varchar(100) = null,
@vPrjID INT=0,
@vDmVlID INT,
@vNew INT
AS

BEGIN
DECLARE @sqlString VARCHAR(MAX)
DECLARE @selectString VARCHAR(MAX)
DECLARE @whereDM VARCHAR(MAX)
DECLARE @whereVL VARCHAR(MAX)
DECLARE @whereCNDM VARCHAR(MAX)
DECLARE @whereCNVL VARCHAR(MAX)
DECLARE @whereCNNDM VARCHAR(MAX)
DECLARE @whereCNNVL VARCHAR(MAX)
DECLARE @whereElseDM VARCHAR(MAX)
DECLARE @whereElseVL VARCHAR(MAX)
DECLARE @whereElseCNDM VARCHAR(MAX)
DECLARE @whereElseCNVL VARCHAR(MAX)
DECLARE @whereElseCNNDM VARCHAR(MAX)
DECLARE @whereElseCNNVL VARCHAR(MAX)
DECLARE @SelectTempTable varchar(MAX)
DECLARE @InsertString varchar(MAX)

--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##tempCompDetails') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempCompDetails
	END
	 create Table ##tempCompDetails
				([Comp_Detail_Id] [int] NULL,
					[EMP_ID] [int] NOT NULL,
					[EmpName] [varchar](max) NULL,
					[Grade_Desc] [varchar](max) NULL,
					[Prj_Num] [varchar](max) NULL,
					[Prj_Name] [varchar](max) NULL,
					[FROM_DATE] [date] NULL,
					[TO_DATE] [date] NULL,
					[POS] [varchar](max) NULL,
					[Work_Alloc] [varchar](max) NULL,
					[Bill_Alloc] [varchar](max) NULL,
					[Delivery_Unit] [varchar](max) NULL,
					[EndClient_GroupName] [varchar](max) NULL,
					[EndClient_GroupID] [varchar](max) NULL,
					[Category] [varchar](max) NULL,
					[DM_Empno] [varchar](max) NULL,
					[VL_Empno] [varchar](max) NULL,
					[COMMENT] [varchar](max) NULL,
					[Emp_Status_Ind] [int] NULL,
					[Change_Category] [int] NULL,
					[EndClient_Id] [varchar](100) NULL,
					[HR_Level] [varchar](max) NULL,
					[Del_Unit] [varchar](max) NULL,
					[Location] [varchar](max) NULL,
					[Qrtr_Inf] [varchar](max) NULL,
					[Bill_Allocations] [varchar](max) NULL,
					[Opt_ClientGrp] [varchar](max) NULL,
					[TO_DATE_SORT] [varchar](max) NULL,
					[RowColor] [varchar](max) NULL
					)


IF(@vAccID=NULL)set @vAccID=NULL
IF(@vPrjID=0) set @vPrjID=NULL
SET @SelectTempTable='select * from ##tempCompDetails'
SET @InsertString='Insert into ##tempCompDetails '
SET @sqlString = ''
SET @selectString = ' SELECT *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS TO_DATE_SORT,[dbo].[Fn_RowColor](Emp_Status_Ind) as RowColor FROM HCR_Comp_Details '
SET @whereDM = ' WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereVL = ' WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNDM = ' WHERE COMMENT = '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNVL = ' WHERE COMMENT = '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id='+CAST(@vDmVlID AS VARCHAR(50))+') '
SET @whereElseDM = ' WHERE DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseVL = ' WHERE VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))+''
SET @whereElseCNDM = ' WHERE COMMENT = '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNVL = ' WHERE COMMENT = '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNDM = ' WHERE COMMENT NOT LIKE '''' AND DM_Empno='+CAST(@vDmVlID AS VARCHAR(50))
SET @whereElseCNNVL = ' WHERE COMMENT NOT LIKE '''' AND VL_Empno='+CAST(@vDmVlID AS VARCHAR(50))

IF (@vNew = 0)
BEGIN
	print 'this is a test msg'
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
			print 'hi'
			SET @sqlString = @selectString +@whereCNDM+' UNION '+ @selectString +@whereCNVL
			SET @sqlString=@InsertString+@sqlString
			PRINT @sqlString
			EXEC(@sqlString)
			
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
			print '2nd'
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			PRINT @sqlString
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
		print '3rd'
			SET @sqlString = @selectString +@whereCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			PRINT @sqlString
        END
		EXEC(@SelectTempTable)
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' UNION '+ @selectString +@whereElseCNVL
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
		SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
		print @sqlString
    END
	EXEC(@SelectTempTable)
END

IF(@vNew=1)
    BEGIN
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' UNION '+ @selectString +@whereCNNVL
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
            SET @sqlString = @selectString +@whereCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
		EXEC(@SelectTempTable)
    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' UNION '+ @selectString +@whereElseCNNVL
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
    ELSE 
    BEGIN
        SET @sqlString = @selectString +@whereElseCNNDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		+' UNION '+ @selectString +@whereElseCNNVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
		SET @sqlString=@InsertString+@sqlString
		EXEC(@sqlString)
    END
	EXEC(@SelectTempTable)
END


IF (@vNew = 2)/*For all employees*/
BEGIN

    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID)
    BEGIN
        IF (@vAccID IS NULL AND @vPrjID IS NULL )
        BEGIN
           SET @sqlString = @selectString +@whereDM+' UNION '+ @selectString +@whereVL
		   SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NULL )
        BEGIN
            SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
			
        END
        IF (@vAccID IS NOT NULL AND @vPrjID IS NOT NULL )
        BEGIN
             SET @sqlString = @selectString +@whereDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
        END
	EXEC(@SelectTempTable)

    END
    ELSE IF (@vAccID IS NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' UNION '+ @selectString +@whereElseVL
		SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
    ELSE IF(@vAccID IS NOT NULL AND @vPrjID IS NULL )
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''
			--PRINT(@sqlString)
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
    ELSE
    BEGIN
        SET @sqlString = @selectString +@whereElseDM+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			+' UNION '+ @selectString +@whereElseVL+' AND LTRIM(RTRIM(Opt_ClientGrp))='+''''+(LTRIM(RTRIM(@vAccID)))+''''+'  AND Prj_Num='+CAST(@vPrjID AS VARCHAR(50))
			SET @sqlString=@InsertString+@sqlString
			EXEC(@sqlString)
    END
	EXEC(@SelectTempTable)
END
--select *,[dbo].[Fn_DateSortYYYYMMDD](TO_DATE) AS TO_DATE_SORT,[dbo].[Fn_RowColor](Emp_Status_Ind) as RowColor from HCR_Comp_Details

END 
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetCompDetails]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetCompDetails]

AS
BEGIN 
 SELECT * FROM HCR_Comp_Details
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetCompDetailsByLatestDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,mahendrakar.s@>
-- Create date: <Create Date,17-06-2020,>
-- Description:	<Description,To fetch the Compare Data for Latest Date at VL Level,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetCompDetailsByLatestDate]
@vDmVl_Id INT
AS
BEGIN 
	Declare @LatestToDate Date
	set @LatestToDate=(select Max(To_Date) from HCR_Comp_Details)
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
	BEGIN
	SELECT tblA.*,tblB.Change_Category as ChangeCategoryVal FROM HCR_Comp_Details tblA left join HCR_Change_Category tblB on tblA.Change_Category =tblB.Change_Id WHERE tblA.TO_DATE=@LatestToDate and tblA.VL_Empno in (SELECT EmpId FROM User_Details WHERE Parent_Id=@vDmVl_Id)
	END
	ELSE
	BEGIN
		IF((select RoleId from User_Details where EmpId=@vDmVl_Id)=2 )
		BEGIN
		SELECT tblA.*,tblB.Change_Category as ChangeCategoryVal FROM HCR_Comp_Details tblA left join HCR_Change_Category tblB on tblA.Change_Category=tblB.Change_Id WHERE tblA.TO_DATE=@LatestToDate and tblA.VL_Empno=@vDmVl_Id
		END
		IF((select RoleId from User_Details where EmpId=@vDmVl_Id)=3 )
		BEGIN
		SELECT tblA.*,tblB.Change_Category as ChangeCategoryVal FROM HCR_Comp_Details tblA left join HCR_Change_Category tblB on tblA.Change_Category=tblB.Change_Id WHERE tblA.TO_DATE=@LatestToDate and tblA.VL_Empno =(SELECT DISTINCT VL_Empno from HCR_Data WHERE DM_Empno=@vDmVl_Id)
		END
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDates_ByWeekMonthQuaterYear]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetDates_ByWeekMonthQuaterYear]
@vDateType INT 
--1 = Weekly, 2 = Monthly, 3 = Quarterly
AS
BEGIN

 

IF(@vDateType = 1)--Weekly
BEGIN
select Format(dts.From_date,N'dd-MMM-yyyy')as Dates, 'FROM_DATE' as 'FROM_TO' from (select distinct top 12 From_date from HCR_Comp_Details order by From_date desc) dts 
union all
select Format(dts.TO_DATE ,N'dd-MMM-yyyy')as Dates,'TO_DATE' as 'FROM_TO'from (select distinct top 12 TO_DATE from HCR_Comp_Details order by TO_DATE desc) dts

END

 

 
IF(@vDateType = 2)--Monthly
BEGIN
    --SELECT DISTINCT Format(TO_DATE, N'MMM-yyyy')AS TO_DATE,Format(FROM_DATE, N'MMM-yyyy')AS FROM_DATE from HCR_Comp_Details
    
    SELECT dts.Dates, FROM_TO
    From
    (SELECT DISTINCT TOP 12 Format(FROM_DATE, N'MMM-yyyy') AS Dates, 'FROM_DATE' as 'FROM_TO' 
    From HCR_Comp_Details Order By DATES Desc) dts 
    UNION 
    SELECT dts.TO_DATE, FROM_TO
    From
    (SELECT DISTINCT TOP 12   Format(TO_DATE, N'MMM-yyyy') AS TO_DATE, 'TO_DATE'  as 'FROM_TO'
     From HCR_Comp_Details Order By TO_DATE Desc) dts    

 

END
IF(@vDateType = 3)--Quarterly
BEGIN
    SELECT DISTINCT [dbo].[Fn_QuarterDate](FROM_DATE) AS Dates, 'FROM_DATE' as 'FROM_TO' From HCR_Comp_Details 
    UNION
    SELECT DISTINCT [dbo].[Fn_QuarterDate](TO_DATE)AS TO_DATE, 'TO_DATE' From HCR_Comp_Details    
END 
 
 end

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDates_ByWeekMonthQuaterYearComma]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Sp_GetDates_ByWeekMonthQuaterYearComma]
@vDateType INT/*1 = Weekly, 2 = Monthly, 3 = Quarterly*/
AS
BEGIN

--DECLARE @vDateTab AS TABLE(From_Date VARCHAR(50),To_Date VARCHAR(50))
DECLARE @vFrom_Date VARCHAR(MAX), @vTo_Date VARCHAR(MAX)

IF(@vDateType = 1)--Weekly
BEGIN
	SELECT @vFrom_Date = SUBSTRING((SELECT TOP 12 +','+CAST(FROM_DATE AS VARCHAR(50)) FROM HCR_Comp_Details GROUP BY FROM_DATE ORDER BY FROM_DATE DESC FOR XML PATH('')),2,1200000)
	SELECT @vTo_Date = SUBSTRING((SELECT TOP 12 +','+CAST(TO_DATE AS VARCHAR(50)) FROM HCR_Comp_Details GROUP BY TO_DATE ORDER BY TO_DATE DESC FOR XML PATH('')),2,1200000)
END

IF(@vDateType = 2)--Monthly
BEGIN
	SELECT @vFrom_Date =SUBSTRING((SELECT TOP 12  +','+FORMAT(FROM_DATE, N'MMM-yyyy') FROM HCR_Comp_Details GROUP BY FROM_DATE ORDER BY FROM_DATE DESC FOR XML PATH('')),2,1200000)
	SELECT @vTo_Date = SUBSTRING((SELECT TOP 12 +','+FORMAT(TO_DATE, N'MMM-yyyy') FROM HCR_Comp_Details GROUP BY TO_DATE ORDER BY TO_DATE DESC FOR XML PATH('')),2,1200000)
END
IF(@vDateType = 3)--Quarterly
BEGIN
	SELECT @vFrom_Date =SUBSTRING((SELECT TOP 12  +','+[dbo].[Fn_QuarterDateFY](FROM_DATE) FROM HCR_Comp_Details GROUP BY FROM_DATE ORDER BY FROM_DATE DESC FOR XML PATH('')),2,1200000)
	SELECT @vTo_Date = SUBSTRING((SELECT TOP 12 +','+[dbo].[Fn_QuarterDateFY](TO_DATE) FROM HCR_Comp_Details GROUP BY TO_DATE ORDER BY TO_DATE DESC FOR XML PATH('')),2,1200000)
END


--SELECT DISTINCT Value FROM DBO.Fn_SplitDelimetedData(',',@vFrom_Date) ORDER BY Value
--SELECT DISTINCT Value FROM DBO.Fn_SplitDelimetedData(',',@vTo_Date) ORDER BY Value

SELECT @vFrom_Date AS FROM_DATE,@vTo_Date AS TO_DATE


END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDates_FromHCR_DataByWeekMonthQuaterYear]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetDates_FromHCR_DataByWeekMonthQuaterYear]
@vDateType INT 
--1 = Weekly, 2 = Monthly, 3 = Quarterly
AS
BEGIN

 

IF(@vDateType = 1)--Weekly
BEGIN
select Format(dts.Date,N'dd-MMM-yyyy') As Dates from
(select distinct top 12 Date from HCR_Data order by Date desc) dts
END

 
IF(@vDateType = 2)--Monthly
BEGIN
    select dts.Dates from(
    Select distinct top 12 Format(Date,N'MMM-yyyy') as Dates from HCR_Data order by dates desc) dts
END

IF(@vDateType = 3)--Quarterly
BEGIN
    SELECT DISTINCT [dbo].[Fn_QuarterDate](Date) AS Dates From HCR_Data 
END 
 end

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDates_TOP20]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetDates_TOP20]
AS
BEGIN
select distinct top 20 date from HCR_Data order by date desc

END

 
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDates_TOP20_formated]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetDates_TOP20_formated]
AS
BEGIN
select Format(dts.date,N'dd-MMM-yyyy')as Dates from (select distinct top 20 date from HCR_Data order by date desc) dts 

END

 
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetHCR_DataCategory]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Sp_GetHCR_DataCategory]
@vDmVlPMO_Id INT,
@vAccount varchar(100)=NULL
AS
BEGIN
	DECLARE @DateLatest As Date
	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	If (@vAccount='' or @vAccount is null)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT Category FROM HCR_Data 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
			and Date = @DateLatest
		ELSE
			BEGIN
				SELECT DISTINCT Category FROM HCR_Data WHERE VL_Empno = @vDmVlPMO_Id and Date = @DateLatest
				UNION
				SELECT DISTINCT Category FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id and Date = @DateLatest 
			END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT Category FROM HCR_Data 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
			and Date = @DateLatest and EndClient_GroupId=@vAccount
		ELSE
			BEGIN
				SELECT DISTINCT Category FROM HCR_Data WHERE VL_Empno = @vDmVlPMO_Id and Date = @DateLatest and Opt_ClientGrp=@vAccount
				UNION
				SELECT DISTINCT Category FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id and Date = @DateLatest and Opt_ClientGrp=@vAccount
			END
	END
	
End	


GO
/****** Object:  StoredProcedure [dbo].[SP_GetLatestHCR_Date]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GetLatestHCR_Date]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT FORMAT(MAX(Date),N'dd-MMM-yyyy') AS FormattedDate,FORMAT(MAX(Date),'yyyy-MM-dd') AS Date FROM HCR_Data
END 
 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetPMO]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[SP_GetPMO]
AS
BEGIN
SELECT DISTINCT EmpId,EmpName FROM User_Details WHERE RoleId=1
END



GO
/****** Object:  StoredProcedure [dbo].[SP_GetPMOList]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_GetPMOList] 
				
AS
select UDt.*,Rt.Role_Name 
from User_Details UDt join Role Rt on UDt.RoleId =Rt.Role_Id
where UDt.RoleId=1 

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetProjects_ByAccount]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

CREATE PROCEDURE [dbo].[Sp_GetProjects_ByAccount]
@vDmVl_Id INT,
@vAccount_Id varchar(100)
AS
BEGIN
IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
    SELECT DISTINCT Prj_Num,Prj_Name FROM HCR_Comp_Details WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id)
    UNION
    SELECT DISTINCT Prj_Num,Prj_Name FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ORDER BY Prj_Name
ELSE
    BEGIN
    SELECT DISTINCT Prj_Num,Prj_Name FROM HCR_Comp_Details WHERE VL_Empno = @vDmVl_Id AND Opt_ClientGrp = @vAccount_Id
    UNION
    SELECT DISTINCT Prj_Num,Prj_Name FROM HCR_Comp_Details WHERE DM_Empno = @vDmVl_Id AND Opt_ClientGrp = @vAccount_Id  ORDER BY Prj_Name
    END
END
 

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetReport]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetReport]
@vDmVl_Id INT,
@vAccount INT=NULL,
@vFromDT varchar(max)=NULL,
@vToDT varchar(max)=NULL
AS
BEGIN

IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id)
	BEGIN
	IF(@vAccount IS NULL AND @vFromDT IS NULL AND @vToDT IS NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN 
		SELECT DISTINCT * FROM HCR_Comp_Details  WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id)
		UNION
		SELECT DISTINCT *FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND EndClient_GroupName<>'' order by EndClient_GroupName
		END
	IF(@vAccount IS NOT NULL AND @vFromDT IS NULL AND @vToDT IS NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN 
		SELECT DISTINCT * FROM HCR_Comp_Details  WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND @vAccount=EndClient_GroupID
		UNION
		SELECT DISTINCT *FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND @vAccount=EndClient_GroupID AND EndClient_GroupName<>'' order by EndClient_GroupName
		END
	IF(@vAccount IS NOT NULL AND @vFromDT IS NOT NULL AND @vToDT IS NOT NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN 
		SELECT DISTINCT * FROM HCR_Comp_Details  WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND @vAccount=EndClient_GroupID AND @vFromDT=FROM_DATE AND @vToDT=TO_DATE
		UNION
		SELECT DISTINCT *FROM HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) AND @vAccount=EndClient_GroupID AND @vFromDT=FROM_DATE AND @vToDT=TO_DATE AND EndClient_GroupName<>'' order by EndClient_GroupName
		END
	END
ELSE
	BEGIN
	IF(@vAccount IS NULL AND @vFromDT IS NULL AND @vToDT IS NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVl_Id 
		UNION
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVl_Id AND EndClient_GroupName<>'' order by EndClient_GroupName 
		END
	IF(@vAccount IS NOT NULL AND @vFromDT IS NULL AND @vToDT IS NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVl_Id AND @vAccount=EndClient_GroupID
		UNION
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVl_Id AND @vAccount=EndClient_GroupID AND EndClient_GroupName<>'' order by EndClient_GroupName 
		END
	IF(@vAccount IS NOT NULL AND @vFromDT IS NOT NULL AND @vToDT IS NOT NULL AND @vDmVl_Id IS NOT NULL)
		BEGIN
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE VL_Empno=@vDmVl_Id AND @vAccount=EndClient_GroupID AND @vFromDT=FROM_DATE AND @vToDT=TO_DATE
		UNION
		SELECT DISTINCT * FROM HCR_Comp_Details WHERE DM_Empno=@vDmVl_Id AND @vAccount=EndClient_GroupID AND @vFromDT=FROM_DATE AND @vToDT=TO_DATE AND EndClient_GroupName<>'' order by EndClient_GroupName 
		END
	END

END
GO
/****** Object:  StoredProcedure [dbo].[SP_GetTableByColumnName]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetTableByColumnName]
@vColumnName varchar(max)
AS
BEGIN
 Declare @sqlString Varchar(MAX)
 IF 1=0 BEGIN
		SET FMTONLY OFF
	END

IF OBJECT_ID('tempdb..##temp4ColumnName') IS NOT NULL
 BEGIN
      DROP TABLE ##temp4ColumnName
 END
 Set @sqlString = ' SELECT ' + @vColumnName +' INTO ##temp4ColumnName FROM HCR_Data'

--set @sqlString='SELECT ' + @vColumnName + ' Into ##tempCol FROM HCR_Data'

 

 Print @sqlString
 EXEC (@sqlString)
 return Select * From ##temp4ColumnName
END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetTableToDisplay]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

 

 


CREATE PROCEDURE [dbo].[Sp_GetTableToDisplay]
@whereString varchar(max)=NULL
AS
BEGIN
    IF ISNULL(@whereString, '') = ''
        BEGIN
            select top 10000 Date,EmpName,Prj_Name,Opt_ClientGrp,Delivery_Unit,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Category,VL_Empno,VL_Empname,Assign_RelDate,Prj_Num,EmpType,DOJ,DM_EmpName,[dbo].[Fn_DateSortYYYYMMDD](Date) as TO_DATE_SORT,[dbo].[Fn_DateSortYYYYMMDD](DOJ) as DOJ_SORT,[dbo].[Fn_DateSortYYYYMMDD](Assign_RelDate) as Assign_RelDate_SORT  from HCR_Data
        END
    ELSE
        BEGIN
            SET FMTONLY OFF

 

 

 

            IF OBJECT_ID('tempdb..##tempCustom') IS NOT NULL
            BEGIN
                DROP TABLE ##tempCustom
            END
            create Table ##tempCustom
                ([Date] [datetime] NOT NULL,
                [EmpName] [varchar](100) NULL,
                [Prj_Name] [varchar](100) NULL,
                [Opt_ClientGrp] [varchar](100) NULL,
                [Delivery_Unit] [varchar](100) NULL,
                [Grade_Desc] [varchar](15) NULL,
                [POS] [varchar](100) NULL,
                [Work_Alloc] [int] NULL,
                [Bill_Alloc] [int] NULL,
                [Category] [varchar](100) NULL,
                [VL_Empno] [int] NULL,
                [VL_Empname] [varchar](100) NULL,
                [Assign_RelDate] [datetime] NULL,
                [Prj_Num] [int] NULL,
                [EmpType] [varchar](100) NULL,
                [DOJ] [datetime] NULL,
                [DM_EmpName] [varchar](100) NULL,
                [TO_DATE_SORT] [varchar](10) not null,
                [DOJ_SORT] [varchar](10) not null,
                [Assign_RelDate_SORT] [varchar](10) not null
                )

 

 
            Declare @sqlString Varchar(MAX)
            set @sqlString='Insert into ##tempCustom select top 10000 Date,EmpName,Prj_Name,Opt_ClientGrp,Delivery_Unit,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Category,VL_Empno,VL_Empname,Assign_RelDate,Prj_Num,EmpType,DOJ,DM_EmpName,[dbo].[Fn_DateSortYYYYMMDD](Date) as TO_DATE_SORT,[dbo].[Fn_DateSortYYYYMMDD](DOJ) as DOJ_SORT,[dbo].[Fn_DateSortYYYYMMDD](Assign_RelDate) as Assign_RelDate_SORT from HCR_Data
             where ' + @whereString 
            Print @sqlString
            EXEC (@sqlString)

 

 

 


            Select * From ##tempCustom

 

 

 

            
        END
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetTop_Non_BillableFrshrAcc]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTop_Non_BillableFrshrAcc]
@vdate DATE=NULL,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)
BEGIN
	IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
			SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END

END



 

GO
/****** Object:  StoredProcedure [dbo].[SP_GetTop_Non_BillableFrshrAccPercentNew]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTop_Non_BillableFrshrAccPercentNew]
@vDmVl_Id int,
@vdate DATE=NULL
AS
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp1 AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
DECLARE @vTemp AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Grade_Desc IN('L1','L2') ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Grade_Desc IN('L1','L2')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Grade_Desc IN('L1','L2')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Grade_Desc IN('L1','L2')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category NOT IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

END





GO
/****** Object:  StoredProcedure [dbo].[SP_GetTop20WeekDates]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[SP_GetTop20WeekDates]
AS
BEGIN
select Distinct Top 20  date, Format(date,N'dd-MMM-yyyy') as formattedDate from HCR_Data order by Date desc
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopBillableFrshrAcc]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopBillableFrshrAcc]

@vdate DATE=NULL,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)
BEGIN
	IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			--INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END


END





GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopBillableFrshrAccPercentNew]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopBillableFrshrAccPercentNew]
@vDmVl_Id int,
@vdate DATE=NULL
AS
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp1 AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
DECLARE @vTemp AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Category IN ('Billable') ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Category IN ('Billable')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Category IN ('Billable')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate AND Category IN ('Billable')) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT TOP 10  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Category IN ('Billable') AND Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

END











GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopContractorsAcc]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopContractorsAcc]
@vdate DATE=Null,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END
--	SET NOCOUNT ON;
--	SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
--(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date BETWEEN @vFromdate and @vTodate) AS T 
--Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
	--SELECT TOP 10 EndClient_GroupName,EndClient_GroupId,COUNT(*) as COUNTS FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And  Date BETWEEN @vFrom_DT AND @vTO_DT Group BY EndClient_GroupId,EndClient_GroupName ORDER BY COUNTS DESC
	
END





GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopContractorsAccPercent]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopContractorsAccPercent]
@vdate DATE=Null,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)

BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
			ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
					SELECt End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
					SELECt End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END

END









GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopContractorsAccPercentNew]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetTopContractorsAccPercentNew]
@vdate DATE=Null,
@vDmVl_Id int
AS
DECLARE @vEmpId INT
DECLARE @vTemp1 AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
DECLARE @vTemp AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		ELSE
			BEGIN
				SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where EmpType IN('Agency Consultant Marked Emp For Projects','Direct Consultant Marked Emp For Projects') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10  T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

END




GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopFrshrAcc]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,09-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopFrshrAcc]
@vdate DATE=NULL,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)
BEGIN
	IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L1','L2') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END
END



GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopFrshrAccPercentageNew]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,09-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopFrshrAccPercentageNew]
@vdate DATE=NULL,
@vDmVl_Id int
AS
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp1 AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
DECLARE @vTemp AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		ELSE
			BEGIN
				SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On  T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On  T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		ELSE
			BEGIN
				--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L1','L2') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY  T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On  T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY Emp_Percentage DESC
			END
		END		

END






GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopL7plus]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopL7plus]
@vdate DATE=NULL,
@vDmVl_Id int
AS
--DECLARE @vFrom_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2020-02-24 00:00:00.000'
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp AS TABLE(End_Id INT,End_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		END
		
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
		ELSE
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp(End_Name,End_Id,Cnt)
			SELECT TOP 10  T.EndClient_GroupName,T.EndClient_GroupId,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,EndClient_GroupId,EndClient_GroupName FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.EndClient_GroupId,T.EndClient_GroupName ORDER BY COUNTS DESC
				SELECT End_Id,End_Name,Cnt,(CAST(((cnt)/(Select CAST(sum(cnt) AS FLOAT) from @vTemp))*100 AS NUMERIC(10,2)))as PERCENTAGE
			FROM @vTemp
			GROUP BY 
			End_Id,End_Name,Cnt
			ORDER BY Cnt DESC
			END
	END



END


GO
/****** Object:  StoredProcedure [dbo].[SP_GetTopL7plusPercentageNew]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Himanshu Sao>
-- Create date: <Create Date,05-06-2020,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetTopL7plusPercentageNew]
@vdate DATE=NULL,
@vDmVl_Id int
AS
DECLARE @vEmpId INT
DECLARE @EndClientGroupID INT
DECLARE @vTemp1 AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
DECLARE @vTemp AS TABLE(OpClient_Name VARCHAR(100),Cnt INT)
BEGIN
IF(@vdate IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		ELSE
			BEGIN
				SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		END		

ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVl_Id) 
			BEGIN
			--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
			INSERT INTO @vTemp1(OpClient_Name,Cnt)
			SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		ELSE
			BEGIN
				--SET @vdate=(SELECT  MAX(Date) from HCR_Data)
				INSERT INTO @vTemp1(OpClient_Name,Cnt)
				SELECT  T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where 
				Date = @vdate  ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC


				INSERT INTO @vTemp(OpClient_Name,Cnt)
				SELECT T.Opt_ClientGrp,COUNT(*) as COUNTS FROM 
				(SELECT DISTINCT Employee_Id,Opt_ClientGrp FROM HCR_Data where Grade_Desc IN('L7','L8','L9','L10','L11','L12') And 
				Date = @vdate AND VL_Empno IN(SELECT DISTINCT VL_Empno from HCR_Data where Employee_Id=@vDmVl_Id) ) AS T 
				Group BY T.Opt_ClientGrp ORDER BY COUNTS DESC

				SELECT  TOP 10 T.OpClient_Name,T.Cnt AS Specific_Emp_Cnt,T1.Cnt AS Total_Emp_Cnt,CAST(((T.Cnt)/(CAST(T1.Cnt AS FLOAT))*100) AS NUMERIC(10,2)) AS Emp_Percentage
				FROM @vTemp T INNER JOIN @vTemp1 T1 On T.OpClient_Name = T1.OpClient_Name
				GROUP BY 
				T.OpClient_Name,T.Cnt,T1.Cnt ORDER BY  Emp_Percentage DESC
			END
		END		

END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetUploadStatus]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUploadStatus] 
	@flag bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 -- Insert statements for procedure here
	Set @flag = (Select Upload_Flag From  HCR_Status)

END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data]
@HcrId int,
@Employee_Id int,
@EmpName varchar(50),
@DOJ datetime,
@POS varchar(50),
@EmpType varchar(50),
@Work_Alloc int,
@Bill_Alloc int,
@Grade_Desc varchar(15),
@EndClient_Id int,
@EndClient_Name varchar(50),
@EndClient_GroupId int,
@EndClient_GroupName varchar(50),
@Buisness_Org varchar(50),
@Delivery_Unit varchar(50),
@Prj_Num int,
@Prj_Name varchar(50),
@Assign_StartDate datetime,
@Assign_RelDate datetime,
@Prj_Type varchar(50),
@Prj_BillFlag bit,
@DM_Empno int,
@DM_EmpName varchar(50),
@VL_Empno int,
@VL_Empname varchar(50),
@DH_EmpNo int,
@DH_EmpName varchar(50),
@Practice varchar(100),
@Sub_Practice varchar(100),
@Emp_Category varchar(50),
@OP_Comm_Model varchar(50),
@OP_Serve_Type varchar(50),
@Sum_BillAlloc int,
@Prj_BillFlag_Name varchar(50),
@Category varchar(50),
@Channel_Sys varchar(50),
@DU_leader varchar(50),
@Opt_ClientGrp varchar(50),
@Supr_EmpNo int,
@Supr_Name varchar(50),
@Created_By int,
@Created_date datetime,
@Modified_By int,
@Modified_date datetime,
@Is_Deleted bit,
@Is_Archive bit
As
BEGIN
select * from [dbo].[HCR_Data]
where @HcrId=@HcrId and @Employee_Id=@Employee_Id and @EmpName=@EmpName and @DOJ=@DOJ
and @POS=@POS and @EmpType=@EmpType and @Bill_Alloc=@Bill_Alloc and @Grade_Desc=@Grade_Desc
and @EndClient_Id=@EndClient_Id and @EndClient_Name=@EndClient_Name and @EndClient_GroupId=@EndClient_GroupId
and @Buisness_Org=@Buisness_Org and @Delivery_Unit=@Delivery_Unit and @Prj_Num=@Prj_Num and @Prj_Name=@Prj_Name
and @Assign_StartDate=@Assign_StartDate and @Assign_RelDate=@Assign_RelDate and @Prj_Type=@Prj_Type
and @Prj_BillFlag=@Prj_BillFlag and @DM_Empno=@DM_Empno and @DM_EmpName=@DM_EmpName and @VL_Empno=@VL_Empno
and @VL_Empname=@VL_Empname and @DH_EmpNo=@DH_EmpNo and @DH_EmpName=@DH_EmpName and @Practice=@Practice and @Sub_Practice=@Sub_Practice
and @Emp_Category=@Emp_Category and @OP_Comm_Model=@OP_Comm_Model and @OP_Serve_Type=@OP_Serve_Type and @Sum_BillAlloc=@Sum_BillAlloc
and @Prj_BillFlag_Name=@Prj_BillFlag_Name and @Category=@Category and @Channel_Sys=@Channel_Sys and @DU_leader=@DU_leader and 
@Opt_ClientGrp=@Opt_ClientGrp and @Supr_EmpNo=@Supr_EmpNo and @Supr_Name=@Supr_Name and @Created_By=@Created_By 
and @Modified_By=@Modified_By and @Modified_date=@Modified_date and @Is_Deleted=@Is_Deleted and @Is_Archive=@Is_Archive;
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V10]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V10] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2020-02-10 00:00:00.000'
DECLARE @vTO_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id 
FROM HCR_Data WHERE Employee_Id IN(SELECT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date BETWEEN @vFrom_DT AND @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',' | '+CAST(EndClient_Id AS VARCHAR(MAX)) FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',' | '+CAST(EndClient_Id AS VARCHAR(MAX)) FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName'))
                                                       SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

					--SELECT @_vComment,@_vChange_Cat
                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
                        DEALLOCATE Outer_Cursor
              END
			  
              --EXEC(@_vUpdColQuery1)

              SELECT * FROM HCR_Comp_Details ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V15may]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V15may] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2019-12-16 00:00:00.000'
DECLARE @vTO_DT DATETIME='2019-12-23 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num=@vPrj_Num) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num=@vPrj_Num)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)), Qrtr_Inf FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId AND Prj_Num=@vPrj_Num

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vTO_DT
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num=@vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num=@vPrj_Num)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId AND Prj_Num=@vPrj_Num

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vFrom_DT
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'POS')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'Delivery_Unit')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										  IF(@_vCol_Name = 'Bill_Alloc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Bill_Allocations] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category,Qrtr_Inf) VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat,dbo.Fn_QuarterDate(@vTO_DT))
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 --PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
			  /* Deleting Duplicate Records*/
			 --  ;WITH DEL_CTE AS(
				--SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,
				--	RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num ORDER BY EMP_ID,Prj_Num)
				--FROM HCR_Comp_Details
				--)
				--DELETE FROM DEL_CTE WHERE RN > 1

				;WITH DEL_CTE AS(
				SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
					RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
				FROM HCR_Comp_Details
				)
				DELETE FROM DEL_CTE WHERE RN > 1

              SELECT * FROM HCR_Comp_Details 
			  --WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT
			  ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V25_MAY]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V25_MAY] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2019-11-04 00:00:00.000'
DECLARE @vTO_DT DATETIME='2019-11-12 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500),@vEndClientGroupId INT,@vEndClientId INT
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,EndClient_Id FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,EndClient_Id FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName,EndClient_Id FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName,@vEndClientId
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND EndClient_Id=@vEndClientId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId  AND EndClient_Id=@vEndClientId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)), Qrtr_Inf FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId  AND EndClient_Id=@vEndClientId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vTO_DT
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId  AND EndClient_Id=@vEndClientId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId  AND EndClient_Id=@vEndClientId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId  AND EndClient_Id=@vEndClientId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vFrom_DT
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'POS')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'Delivery_Unit')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										  IF(@_vCol_Name = 'Bill_Alloc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Bill_Allocations] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category,Qrtr_Inf) VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat,dbo.Fn_QuarterDate(@vTO_DT))
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 --PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName,@vEndClientId
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
			  /* Deleting Duplicate Records*/
			 --  ;WITH DEL_CTE AS(
				--SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,
				--	RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num ORDER BY EMP_ID,Prj_Num)
				--FROM HCR_Comp_Details
				--)
				--DELETE FROM DEL_CTE WHERE RN > 1

				;WITH DEL_CTE AS(
				SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
					RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
				FROM HCR_Comp_Details
				)
				DELETE FROM DEL_CTE WHERE RN > 1

              SELECT * FROM HCR_Comp_Details 
			  --WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT
			  ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V4]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V4] 
--@vFrom_DT DATETIME,
--@vTO_DT DATETIME
AS
BEGIN
DECLARE @vFrom_DT DATETIME
DECLARE @vTO_DT DATETIME

SELECT @vTO_DT = MAX(Date)
FROM HCR_Data

SELECT @vFrom_DT =(SELECT MAX(DATE)-1 from HCR_Data)
--SELECT @vFrom_DT =(SELECT MAX(DATE) FROM HCR_Data WHERE CONVERT(DATE, Date) < @vTO_DT)
--DECLARE @vFrom_DT DATETIME=N'2019-10-04 23:38:20.510'
--DECLARE @vTO_DT DATETIME=N'2020-01-13 23:38:20.510'
--CREATE TABLE HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), 
--Id VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT
DECLARE @vST_DT DATE=CONVERT(DATE, @vFrom_DT)
DECLARE @vED_DT DATE=CONVERT(DATE, @vTO_DT)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100)

DECLARE curr_audit_check CURSOR FOR
	SELECT Employee_Id,Prj_Num FROM HCR_Data WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
	OPEN curr_audit_check    
	
	FETCH NEXT FROM curr_audit_check INTO @vEmpId,@vPrj_Num
  
		WHILE @@FETCH_STATUS = 0    
		BEGIN 

			WHILE (@vST_DT<=@vED_DT)
			BEGIN
				
				
				IF EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vST_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
				BEGIN
					--print @vEmpId
					--print @vPrj_Num
					DECLARE curr_data_comp CURSOR FOR
						SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('Employee_Id','POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupName','Category','Category_1','DM_Empno','VL_Empno')
					OPEN curr_data_comp
					
					
					FETCH NEXT FROM curr_data_comp INTO @_vCol_Name
					--print @_vCol_Name
					--print @vST_DT
					--print @vEnd_DT
					WHILE @@FETCH_STATUS = 0    
					BEGIN 
						IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
						BEGIN						
						  Drop TABLE #currentData
						END
						 -- SET IDENTITY_INSERT #currentData ON
						 -- INSERT INTO #currentData 
						  SELECT * INTO #currentData FROM HCR_Data WHERE CONVERT(DATE, Date) = @vST_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
						 
					--	  Select * From #currentData
					--	END
					--	ELSE
					--		SELECT * INTO #currentData FROM HCR_Data WHERE CONVERT(DATE, Date) =@vST_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

						IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
						BEGIN
						  Drop TABLE #prevData
						--  SET IDENTITY_INSERT #prevData ON
						END
						 -- INSERT INTO #prevData 
						  SELECT * INTO #prevData FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = (SELECT MAX(DATE) FROM HCR_Data WHERE Employee_Id =@vEmpId AND CONVERT(DATE, Date) < @vST_DT  AND Prj_Num = @vPrj_Num)
						--END
						--ELSE					
						--	SELECT * INTO #prevData FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = (SELECT MAX(DATE) FROM HCR_Data WHERE Employee_Id =@vEmpId AND CONVERT(DATE, Date) < @vST_DT  AND Prj_Num = @vPrj_Num)
						-- Select * From #prevData
						 --print 
						SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

						SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
						EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

						SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
						EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
						
						-- Add Project num in Where condition
						IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name'))
								SET @_vUpdColQuery1 += 'UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX)))+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+CHAR(13)
						ELSE
						BEGIN
							IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
							BEGIN
									--IF NOT EXISTS(SELECT * FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId)
									--	INSERT INTO HCR_Comp_Details(EMP_ID,COMMENT,FROM_DATE,TO_DATE)VALUES(@vEmpId,'',@vFrom_DT,@vTO_DT)
									SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+CAST('Old: '+@_vOldValue AS VARCHAR(MAX))+', '+CAST('|New: '+@_vNewValue AS VARCHAR(MAX))+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+CHAR(13)
							END
						END
						--print @_vCol_Name
						FETCH NEXT FROM curr_data_comp INTO @_vCol_Name
					END
					
					CLOSE curr_data_comp;    
					DEALLOCATE curr_data_comp;
					IF CURSOR_STATUS('global','curr_data_comp')>=-1
					BEGIN
						   DEALLOCATE curr_data_comp
					END
					
				END

				SELECT @vST_DT=DATEADD(DD, 1, @vST_DT)

			END
			
			IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num))
				INSERT INTO HCR_Comp_Details(EMP_ID,COMMENT,FROM_DATE,TO_DATE,Prj_Num)VALUES(@vEmpId,'',@vFrom_DT,@vTO_DT,@vPrj_Num)
			/*Reset Temp Variables*/
			SET @vST_DT = CONVERT(DATE, @vFrom_DT)
			SET @vED_DT = CONVERT(DATE, @vTO_DT)

			FETCH NEXT FROM curr_audit_check INTO @vEmpId,@vPrj_Num
			
		END
		CLOSE curr_audit_check
		DEALLOCATE curr_audit_check
		IF CURSOR_STATUS('global','curr_audit_check')>=-1
		BEGIN
			   DEALLOCATE curr_audit_check
		END
		--print(@_vUpdColQuery)
		--print(@_vUpdColQuery1)
		EXEC(@_vUpdColQuery)
		EXEC(@_vUpdColQuery1)
		--DELETE FROM HCR_Comp_Details WHERE POS IS NULL AND Work_Alloc IS NULL AND Bill_Alloc IS NULL AND Grade_Desc IS NULL AND Delivery_Unit IS NULL AND Prj_Num IS NULL AND Prj_Name IS NULL AND EndClient_Id IS NULL AND Category IS NULL AND Category_1 IS NULL
		
		--INSERT INTO HCR_Comp_Details(EMP_ID,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_Id,Category,Category_1,DM_Empno,VL_Empno,FROM_DATE,TO_DATE)
		--SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupName,Category,Category_1,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT FROM HCR_Data
		--WHERE Date BETWEEN @vFrom_DT AND @vTO_DT AND Employee_Id IN(SELECT Employee_Id FROM HCR_Data GROUP BY Employee_Id HAVING COUNT(Employee_Id)=1) 

	--	SELECT * FROM HCR_Comp_Details
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V5]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V5] 
AS
BEGIN
--DECLARE @vFrom_DT DATETIME='2019-10-14 00:00:00.000'
--DECLARE @vTO_DT DATETIME='2019-10-21 00:00:00.000'
DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500),@vEndClientGroupId INT,@vEndClientId INT
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,EndClient_Id,Opt_ClientGrp FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,EndClient_Id,Opt_ClientGrp FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf,HCR_Data.Opt_ClientGrp
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf,HCR_Data.Opt_ClientGrp
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf,HCR_Data.Opt_ClientGrp
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName,EndClient_GroupId FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName,@vEndClientGroupId
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf,Opt_ClientGrp FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf,Opt_ClientGrp INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf,Opt_ClientGrp FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf,Opt_ClientGrp INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND EndClient_GroupId=@vEndClientGroupId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId And EndClient_GroupId=@vEndClientGroupId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf,Opt_ClientGrp)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','6',CAST(EndClient_Id AS VARCHAR(MAX)), Qrtr_Inf,Opt_ClientGrp FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId And EndClient_GroupId=@vEndClientGroupId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vTO_DT
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND EndClient_GroupId=@vEndClientGroupId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId And EndClient_GroupId=@vEndClientGroupId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf,Opt_ClientGrp)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','5',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf,Opt_ClientGrp FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId And EndClient_GroupId=@vEndClientGroupId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc, HCD.Del_Unit=HD.Delivery_Unit,HCD.Location=HD.POS,HCD.Bill_Allocations=HD.Bill_Alloc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vFrom_DT
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf','Opt_ClientGrp')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'POS')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'Delivery_Unit')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END 
										  IF(@_vCol_Name = 'Bill_Alloc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Bill_Allocations] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
										 END

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Qrtr_Inf','EndClient_Id','Opt_ClientGrp'))
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END
													IF(@_vCol_Name ='Bill_Alloc')
													BEGIN
														SET @_vComment+=',Bill Allocation Changed'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Allocation Changed') AS VARCHAR(10))
													END
													IF(@_vCol_Name ='Work_Alloc')
													BEGIN
														SET @_vComment+=',Work Allocation Changed'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Allocation Changed') AS VARCHAR(10))
													END
													IF(@_vCol_Name ='Category')
													BEGIN
														SET @_vComment+=', '
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Billability Changed') AS VARCHAR(10))
													END
													--IF(@_vCol_Name IN('Work_Alloc' , 'Bill_Alloc'))
													--BEGIN
													--	SET @_vComment+=',Allocations Changed'
													--	SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Allocation Changed') AS VARCHAR(10))
													--END
													

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND FROM_DATE ='''+CAST(@vFrom_DT AS VARCHAR)+''' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR)+''''+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))

					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''
					 IF((SELECT CHARINDEX('Bill',@_vComment))>0 AND (SELECT CHARINDEX('Work',@_vComment))>0 AND ((SELECT LEN(@_vComment)-LEN(REPLACE(@_vComment,',','')))=1))
					 BEGIN
						SET @_vComment='Allocations Changed'
						SET @_vChange_Cat=11
					 END
					 Else IF((SELECT CHARINDEX(',',@_vComment))>0)
					 BEGIN
						SET @_vComment=''
						SET @_vChange_Cat=10
					 END


                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category,Qrtr_Inf) VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat,dbo.Fn_QuarterDate(@vTO_DT))
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 --PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName,@vEndClientGroupId
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
			  /* Deleting Duplicate Records*/
			 --  ;WITH DEL_CTE AS(
				--SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,
				--	RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num ORDER BY EMP_ID,Prj_Num)
				--FROM HCR_Comp_Details
				--)
				--DELETE FROM DEL_CTE WHERE RN > 1

				;WITH DEL_CTE AS(
				SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
					RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
				FROM HCR_Comp_Details
				)
				DELETE FROM DEL_CTE WHERE RN > 1

     --         SELECT * FROM HCR_Comp_Details 
			  --WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT
			  --ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V5_BKP]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V5_BKP] 
@vFrom_DT DATE,
@vTO_DT DATE
AS
BEGIN

--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @vST_DT DATE=CONVERT(DATE, @vFrom_DT)
DECLARE @vED_DT DATE=CONVERT(DATE, @vTO_DT)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100)

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM HCR_Data WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno FROM HCR_Data WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno INTO #currentData FROM HCR_Data WHERE CONVERT(DATE, Date) =@vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno INTO #prevData FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                        --SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno INTO #prevData FROM HCR_Data WHERE Employee_Id = @vEmpId AND Date = (SELECT MAX(DATE) FROM HCR_Data WHERE Employee_Id =@vEmpId AND CONVERT(DATE, Date) < @vST_DT  AND Prj_Num = @vPrj_Num)
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vST_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT FROM HCR_Data
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vST_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT FROM HCR_Data
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM HCR_Data WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 

                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName'))
                                                       SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT * FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num))
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num)VALUES(@vEmpId,@vEmpName,'',@vFrom_DT,@vTO_DT,@vPrj_Num)
                     EXEC(@_vUpdColQuery)

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''


                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
                        DEALLOCATE Outer_Cursor
              END
			  
              EXEC(@_vUpdColQuery1)
              --DELETE FROM HCR_Comp_Details WHERE POS IS NULL AND Work_Alloc IS NULL AND Bill_Alloc IS NULL AND Grade_Desc IS NULL AND Delivery_Unit IS NULL AND Prj_Num IS NULL AND Prj_Name IS NULL AND EndClient_GroupName IS NULL AND Category IS NULL AND Category_1 IS NULL

              --INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE)
              --SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT FROM HCR_Data
              --WHERE Date BETWEEN @vFrom_DT AND @vTO_DT AND Employee_Id IN(SELECT Employee_Id FROM HCR_Data GROUP BY Employee_Id HAVING COUNT(Employee_Id)=1)

              SELECT * FROM HCR_Comp_Details
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V5_HR]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V5_HR] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2020-03-02 00:00:00.000'
DECLARE @vTO_DT DATETIME='2020-03-09 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno 
FROM HCR_Data WHERE Employee_Id IN(SELECT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date BETWEEN @vFrom_DT AND @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','' FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','' FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','HR_Level','Del_Unit','Location','Quarter_Info'))
                                                       SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

					--SELECT @_vComment,@_vChange_Cat
                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
                        DEALLOCATE Outer_Cursor
              END
			  
              --EXEC(@_vUpdColQuery1)

              SELECT * FROM HCR_Comp_Details ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V5_PRO]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V5_PRO]
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2020-01-20 00:00:00.000'
DECLARE @vTO_DT DATETIME='2020-02-03 00:00:00.000'

--DECLARE  @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE  @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)),' | ' + Qrtr_Inf FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
							
							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HCD.TO_DATE = @vTO_DT AND HCD.FROM_DATE = @vFrom_DT AND HD.Date = @vTO_DT
							--,HCD.Change_Category=CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'New Joinee') AS VARCHAR(10))

						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf+' | ' FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HCD.TO_DATE = @vTO_DT AND HCD.FROM_DATE = @vFrom_DT AND HD.Date = @vFrom_DT
							--,HCD.Change_Category=CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Resignation') AS VARCHAR(10))
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR(30))+''' AND FROM_DATE = '''+CAST(@vFrom_DT AS VARCHAR(30))+''''+CHAR(13)
										 END 

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Delivery_Unit','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR(30))+''' AND FROM_DATE = '''+CAST(@vFrom_DT AS VARCHAR(30))+''''+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END
													--IF(@_vCol_Name = 'Work_Alloc')
													--BEGIN
													--	SET @_vComment+=',Change in Work Allocation'
													--	SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Work Allocation') AS VARCHAR(10))
													--END
													--IF(@_vCol_Name = 'Bill_Alloc')
													--BEGIN
													--	SET @_vComment+=',Change in Bill Allocation'
													--	SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Bill Allocation') AS VARCHAR(10))
													--END
													--IF(@_vCol_Name = 'EndClient_Id')
													--BEGIN
													--	SET @_vComment+=',Allocated to New Project'
													--	SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Alloc_To_Nw_Prj') AS VARCHAR(10))
													--END
													
													--IF(@_vCol_Name = 'Category')
													--BEGIN
													--	SET @_vComment+=','
													--	SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Moved to Bench') AS VARCHAR(10))
													--END 
                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+' AND TO_DATE = '''+CAST(@vTO_DT AS VARCHAR(30))+''' AND FROM_DATE = '''+CAST(@vFrom_DT AS VARCHAR(30))+''''+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 --PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
			  /* Deleting Duplicate Records*/
			   ;WITH DEL_CTE AS(
				SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
					RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
				FROM HCR_Comp_Details
				)
				DELETE FROM DEL_CTE WHERE RN > 1
			
              SELECT * FROM HCR_Comp_Details 
			  --WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT
			  ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V5_Test]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V5_Test] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2020-02-10 00:00:00.000'
DECLARE @vTO_DT DATETIME='2020-02-17 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_Id FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_Id FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id 
FROM HCR_Data WHERE Employee_Id IN(SELECT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date BETWEEN @vFrom_DT AND @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',' | '+CAST(EndClient_Id AS VARCHAR(MAX)) FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',' | '+CAST(EndClient_GroupID AS VARCHAR(MAX)) FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName'))
                                                       SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

					--SELECT @_vComment,@_vChange_Cat
                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
                        DEALLOCATE Outer_Cursor
              END
			  
              --EXEC(@_vUpdColQuery1)

              SELECT * FROM HCR_Comp_Details ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V55]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V55] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME='2019-12-23 00:00:00.000'
DECLARE @vTO_DT DATETIME='2020-03-09 00:00:00.000'
--DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
--CREATE TABLE #HCR_Comp_Details(EMP_ID INT, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupID,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_Id FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_Id FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date BETWEEN @vFrom_DT AND @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',' | '+CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX))+' | ',Qrtr_Inf FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Delivery_Unit','Qrtr_Inf'))
                                                       SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
											
                                         ELSE
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END
										 IF(@_vCol_Name = 'Delivery_Unit')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END
										 IF(@_vCol_Name = 'POS')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END
                                         BEGIN
										 
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''


                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     
					 PRINT @_vComment

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
              SELECT * FROM HCR_Comp_Details

--WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

ORDER BY TO_DATE DESC
			  
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V6]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V6] 
AS
BEGIN
DECLARE @vFrom_DT DATETIME=(SELECT MAX(Date) FROM HCR_Data WHERE Date < (SELECT MAX(Date) FROM HCR_Data))
DECLARE @vTO_DT DATETIME=(SELECT MAX(Date) FROM HCR_Data)
CREATE TABLE #HCR_Comp_Details(EMP_ID INT, EMP_Name VARCHAR(500),COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), EndClient_GroupId VARCHAR(MAX), Category VARCHAR(MAX), Category_1 VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX))
DECLARE @vColNameTab AS TABLE (Col_Id INT IDENTITY, Col_Name SYSNAME)

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @vST_DT DATE=CONVERT(DATE, @vFrom_DT)
DECLARE @vED_DT DATE=CONVERT(DATE, @vTO_DT)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vCol_Id INT,@_vCnt INT,@_vMaxCnt INT

IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)


SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

INSERT INTO @vColNameTab
SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupId','Category','Category_1','DM_Empno','VL_Empno')

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
                                         
                                  IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                                         TRUNCATE TABLE #currentData
                                         INSERT INTO #currentData 
                                         SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,DM_Empno,VL_Empno FROM #TEMP WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,DM_Empno,VL_Empno INTO #currentData FROM #TEMP WHERE CONVERT(DATE, Date) =@vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                                         TRUNCATE TABLE #prevData
                                         INSERT INTO #prevData 
                                         SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,DM_Empno,VL_Empno FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                                         SELECT Employee_Id,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1,EndClient_GroupId,DM_Empno,VL_Empno INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num


                           IF EXISTS(SELECT 1 FROM #TEMP WHERE CONVERT(DATE, Date) = @vED_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  SELECT @_vCnt=0,@_vMaxCnt=0
                                  SELECT @_vCnt=MIN(Col_Id),@_vMaxCnt=MAX(Col_Id) FROM @vColNameTab

                                                              WHILE(@_vCnt<@_vMaxCnt+1)
                                                              BEGIN

                                                                     SELECT @_vCol_Name = Col_Name FROM @vColNameTab WHERE Col_Id = @_vCnt
                                                                     SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                        SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                        EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                        SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                        EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
                                        IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_Id'))
                                                                     BEGIN
                                                                           SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX)))+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                                     END
                                        ELSE
                                        BEGIN
                                            IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                            BEGIN
                                                                                  SET @_vUpdColQuery+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX))+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                            END
                                        END

                                                              
                                                              SET @_vCnt +=1
                                                              SET @_vCol_Name=''
                                                              END
                           END
                     
                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT * FROM #HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num))
                           INSERT INTO #HCR_Comp_Details(EMP_ID,EMP_Name,COMMENT,FROM_DATE,TO_DATE,Prj_Num)VALUES(@vEmpId,@vEmpName,'',@vFrom_DT,@vTO_DT,@vPrj_Num)
                     EXEC(@_vUpdColQuery)

                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
                        DEALLOCATE Outer_Cursor
              END

              EXEC(@_vUpdColQuery1)
              
              SELECT * FROM #HCR_Comp_Details
END

GO
/****** Object:  StoredProcedure [dbo].[SP_HCR_Data_Compare_New_V7]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HCR_Data_Compare_New_V7]
AS
BEGIN
DECLARE @vFrom_DT DATETIME=(SELECT MAX(Date) FROM HCR_Data WHERE Date < (SELECT MAX(Date) FROM HCR_Data))
DECLARE @vTO_DT DATETIME=(SELECT MAX(Date) FROM HCR_Data)

IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)


SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num


SELECT HCR_Data_Outer.Employee_Id, HCR_Data_Outer.EmpName, HCR_Data_Outer.Prj_Num, HCR_Data_Outer.Prj_Name,From_DT,TO_DT,
       (SELECT  Bill_Alloc_Old +' | '+ Bill_Alloc_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Bill_Alloc AS VARCHAR(MAX)) AS Bill_Alloc_Old, LEAD(CAST(Bill_Alloc AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Bill_Alloc_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Bill_Alloc_New <>'####' AND TAB.Bill_Alloc_New<>TAB.Bill_Alloc_Old
       ) As Bill_Aloc,

       (SELECT  Category_Old +' | '+ Category_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Category AS VARCHAR(MAX)) AS Category_Old, LEAD(CAST(Category AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Category_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Category_New <>'####' AND TAB.Category_New<>TAB.Category_Old
       ) As Category,

          (SELECT  Category_1_Old +' | '+ Category_1_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Category_1 AS VARCHAR(MAX)) AS Category_1_Old, LEAD(CAST(Category_1 AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Category_1_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Category_1_New <>'####' AND TAB.Category_1_New<>TAB.Category_1_Old
       ) As Category_1,

          (SELECT  POS_Old +' | '+ POS_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(POS AS VARCHAR(MAX)) AS POS_Old, LEAD(CAST(POS AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS POS_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.POS_New <>'####' AND TAB.POS_New<>TAB.POS_Old
       ) As POS,

          (SELECT  Work_Alloc_Old +' | '+ Work_Alloc_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Work_Alloc AS VARCHAR(MAX)) AS Work_Alloc_Old, LEAD(CAST(Work_Alloc AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Work_Alloc_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Work_Alloc_New <>'####' AND TAB.Work_Alloc_New<>TAB.Work_Alloc_Old
       ) As Work_Alloc,

          (SELECT  Grade_Desc_Old +' | '+ Grade_Desc_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Grade_Desc AS VARCHAR(MAX)) AS Grade_Desc_Old, LEAD(CAST(Grade_Desc AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Grade_Desc_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Grade_Desc_New <>'####' AND TAB.Grade_Desc_New<>TAB.Grade_Desc_Old
       ) As Grade_Desc,

          (SELECT  Delivery_Unit_Old +' | '+ Delivery_Unit_New  FROM
              (
                     SELECT TOP 2 DATE, CAST(Delivery_Unit AS VARCHAR(MAX)) AS Delivery_Unit_Old, LEAD(CAST(Delivery_Unit AS VARCHAR(MAX)), 1,'####') OVER(ORDER BY Date ASC) 
                     AS Delivery_Unit_New
                     FROM #TEMP WHERE #TEMP.Employee_Id=HCR_Data_Outer.Employee_Id AND #TEMP.Prj_Num=HCR_Data_Outer.Prj_Num
                     ORDER BY Date DESC
              ) TAB WHERE TAB.Delivery_Unit_New <>'####' AND TAB.Delivery_Unit_New<>TAB.Delivery_Unit_Old
       ) As Delivery_Unit,

          (SELECT TOP 1 EndClient_Id FROM HCR_Data WHERE Employee_Id= HCR_Data_Outer.Employee_Id AND Prj_Num=HCR_Data_Outer.Prj_Num  AND Date = TO_DT
              AND EndClient_Id IS NOT NULL
              ORDER BY Date DESC) AS EndClient_Id,

          (SELECT TOP 1 DM_Empno FROM HCR_Data WHERE Employee_Id= HCR_Data_Outer.Employee_Id AND Prj_Num=HCR_Data_Outer.Prj_Num  AND Date = TO_DT
              AND DM_Empno IS NOT NULL
              ORDER BY Date DESC) AS DM_Empno,

              (SELECT TOP 1 VL_Empno FROM HCR_Data WHERE Employee_Id= HCR_Data_Outer.Employee_Id AND Prj_Num=HCR_Data_Outer.Prj_Num  AND Date = TO_DT
              AND VL_Empno IS NOT NULL
              ORDER BY Date DESC) AS VL_Empno
FROM
(
SELECT DISTINCT Employee_Id, EmpName,Prj_Num, Prj_Name,From_DT,TO_DT FROM #TEMP
) HCR_Data_Outer


END

GO
/****** Object:  StoredProcedure [dbo].[sp_hcrdata]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_hcrdata]
as
select * from HCR_Data where Date='2019-12-16'

GO
/****** Object:  StoredProcedure [dbo].[SP_InsertData_TmpExcelToHCR]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertData_TmpExcelToHCR] 
		@insertDate Date,
		@rowCount int OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;   

	Insert into HCR_Data([Date], Employee_Id, EmpName, DOJ, POS, EmpType, Work_Alloc, Bill_Alloc, 
	Grade_Desc, EndClient_Id, EndClient_Name, EndClient_GroupId, EndClient_GroupName, Buisness_Org, Delivery_Unit, 
	Prj_Num, Prj_Name, Assign_StartDate, Assign_RelDate, Prj_Type, Prj_BillFlag, 
	DM_Empno, DM_EmpName, VL_Empno, VL_Empname, DH_EmpNo, DH_EmpName, Practice,Sub_Practice, 
	Emp_Category, OP_Comm_Model, OP_Serve_Type, Sum_BillAlloc, Prj_BillFlag_Name, Category, Channel_Sys,
	DU_leader, Category_1, Opt_ClientGrp, Supr_EmpNo, Supr_Name, Qrtr_Inf, Created_date)
	Select hcrExcel.[Date], [EMPLOYEE NUMBER], [EMPLOYEE NAME],[DATE OF JOINING],[POS ONSITE OFFSHORE],[EMPLOYEE TYPE],[WORK ALLOCATION],[BILL ALLOCATION],
	Replace([GRADE DESC],'Level ','L') as Grade_Desc, Case When [END CLIENT ID] = 'CH11' then '' Else [END CLIENT ID]  End as EndClient_Id,
	[END CLIENT NAME],[END CLIENT GROUP ID], [END CLIENT GROUP NAME],
	 [BUSINESS ORGANIZATION],
	 Replace([DELIVERY UNIT],'HP','') as Delivery_Unit,
	[PROJ NUM], [PROJ NAME],[ASSIGNMENT START DATE],[ASSIGNMENT RELEASE DATE],[PROJECT TYPE],convert(bit,(Case When [PROJECT BILL FLAG] = 'Y' then 1 else 0 End)),
	[DM EMP NO], [DM EMP NAME],[VL EMP NO],[VL EMP NAME],[DH EMP NO],[DH EMP NAME],[PARCTICE],[SUB_PARCTICE],
	[EMPLOYEE_CATEGORY],hcrExcel.[OP_COMM_MODEL],[OP_SERV_TYPE],[sum of BILL ALLOCATION],[PROJECT BILL FLAG1],hcrExcel.[CATEGORY],[CHANNEL-Sys],
	[DU Leader],[CATEGORY1],[OPERATIONAL CLIENT GROUP],[SUPERVISOR EMPNO],[SUPERVISOR NAME], [dbo].[Fn_QuarterDate](hcrExcel.[Date]), getDate()
	From HCR_Data_Excel hcrExcel left join HCR_Data hcrData on hcrExcel.[Date] = hcrData.[Date]
	Where hcrData.[Date] is null and hcrExcel.Date=@insertDate

	Set @rowCount = @@ROWCOUNT
	
	Update HCR_Data
	SET Grp_Grade_Desc=
		(CASE
        WHEN Grade_Desc IN ('L1','L2') THEN 'L1-L2'
		WHEN Grade_Desc IN ('L3','L4') THEN 'L3-L4'
		WHEN Grade_Desc IN ('L5','L6') THEN 'L5-L6'
		WHEN Grade_Desc IN ('L7','L8','L9','L10','L11','L12') THEN 'L7+'
		END) 	
END

GO
/****** Object:  StoredProcedure [dbo].[SP_InsertData_TmpExcelToHCRInLoop]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertData_TmpExcelToHCRInLoop] 
	@UploadRowCount int OUTPUT
	
AS
BEGIN
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	--SET NOCOUNT ON
	DECLARE @dateTable AS TABLE(ROW_Id INT IDENTITY,DateValue Date)	
	DECLARE @rowsCount Int=0
	Insert Into @dateTable Select Distinct Date from HCR_Data_Excel order By Date
	DECLARE @dateInLoop Date 
		select @dateInLoop = (select min(DateValue) from @dateTable)
		while @dateInLoop is not null
		BEGIN
		Print(convert(Varchar(20),@dateInLoop))
			Declare @tempRowCount INT=0
			exec [dbo].[SP_InsertData_TmpExcelToHCR] @dateInLoop, @rowCount=@tempRowCount Output
			SET @rowsCount=@rowsCount+@tempRowCount
			Print(convert(Varchar(20),@tempRowCount))
			Print(convert(Varchar(20),@rowsCount))
			select @dateInLoop = (select min(DateValue) from @dateTable where DateValue >@dateInLoop)
			exec [dbo].[SP_HCR_Data_Compare_New_V5]
		END
	Set @UploadRowCount = @rowsCount
END

GO
/****** Object:  StoredProcedure [dbo].[SP_PROACC]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PROACC]
as
select Distinct(EndClient_GroupName),EndClient_GroupId,Prj_Num, Prj_Name from HCR_Data where Employee_Id=2023505

GO
/****** Object:  StoredProcedure [dbo].[SP_ProjListByAcc]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ProjListByAcc]
	@EmployeeId int,
	@EndClientGroupId int
	
as
Begin

select Distinct(Prj_Num), Prj_Name
from HCR_Comp_Details
where EMP_ID =@EmployeeId AND EndClient_GroupId = @EndClientGroupId
end



GO
/****** Object:  StoredProcedure [dbo].[SP_ROLE_NAME]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ROLE_NAME]
@ROLE_NAME VARCHAR(50)
AS
Select * FROM [DBO].[Role] WHERE
@ROLE_NAME =@ROLE_NAME

GO
/****** Object:  StoredProcedure [dbo].[SP_RoleDetails]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SP_RoleDetails]
As
Begin
SET NOCOUNT ON;
Select Role_Id, Role_Name from Role
End

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_EmpCountGradeDescForCharts]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,mahendrakar.s@>
-- Create date: <Create Date,,>
-- Description:	<Description,,SP For Dashboard, Trend(Two DataSets and Top WMQ)>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_EmpCountGradeDescForCharts] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@vWMQId int =NULL,
@dateForChart varchar(20) =NULL
AS
BEGIN 
	DECLARE @DateChart As Date
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @maxDate Date = NULL
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	IF OBJECT_ID('tempdb..##tempForChart') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempForChart
	END

	CREATE Table ##tempForChart 
	(
		--EMP_COUNT INT,GRADE_DESC VARCHAR(5),ChartDate VARCHAR(20)
		EMP_COUNT INT,GRADE_DESC VARCHAR(5)
	)
	--For DashBoard Chart with latest Date if Null
	IF(@dateForChart IS NULL and @vWMQId IS NULL)
	BEGIN
		SET @DateChart =(SELECT MAX(Date) from HCR_Data)
		Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateChart) + ''''
	END
	--For Trend Two Data chart sets with input param date
	IF (@vWMQId = 1 and @dateForChart IS Not Null)
		BEGIN
			SET @DateChart=@dateForChart
              Set @whereString = ' Where Date = ''' + @dateForChart +''''
			  END

       Else IF( @vWMQId = 2 and @dateForChart IS Not Null)
			 Begin
			   Set @maxDate = (Select Max(Date) From HCR_Data where  Month(Date) = Month('01-'+@dateForChart) and year(Date)=Year('01-'+@dateForChart) )
			   SET @DateChart=@maxDate
              Set @whereString =' Where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
			  End

       Else IF( @vWMQId = 3 and @dateForChart IS Not Null)
	   Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where Qrtr_Inf = @dateForChart)
			    SET @DateChart=@maxDate
			set @whereString =' where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
       End
	 SET @sqlString = 'Insert Into ##tempForChart '
	 SET @sqlString = @sqlString+'Select count( DISTINCT Employee_Id) as EMP_COUNT,Grp_Grade_Desc from HCR_Data'
	 --SET @sqlString = @sqlString+'Select count( DISTINCT Employee_Id) as EMP_COUNT,Grp_Grade_Desc,''' + convert(varchar(20),@DateChart) + ''' as ChartDate  from HCR_Data'
	 
	
	
	  
	 --For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
		--EndClientGroup is replaced by Opt_ClientGrp
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Opt_ClientGrp)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString+' Group by Grp_Grade_Desc'
	
	Print @sqlString
	EXEC(@sqlString)
	----select GRADE_DESC, EMP_COUNT,ChartDate from ##tempForChart order by GRADE_DESC DESC
	SELECT TAB.GRADE_DESC,TAB.EMP_COUNT,TAB.ChartDate
	FROM
	(
	SELECT 'L1-L2' AS GRADE_DESC, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@DateChart as ChartDate FROM ##tempForChart WHERE GRADE_DESC IN('L1-L2')
	UNION
	SELECT 'L3-L4' AS GRADE_DESC,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@DateChart as ChartDate FROM ##tempForChart WHERE GRADE_DESC IN('L3-L4')
	UNION
	SELECT 'L5-L6' AS GRADE_DESC,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@DateChart as ChartDate FROM ##tempForChart WHERE GRADE_DESC IN('L5-L6')
	UNION
	SELECT 'L7+' AS GRADE_DESC,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@DateChart as ChartDate FROM ##tempForChart WHERE GRADE_DESC IN('L7+')
	) TAB order by TAB.GRADE_DESC desc
	drop table ##tempForChart


END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_ForSP_Rpt_GetTopWMQCountOfEmployeesV2]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_ForSP_Rpt_GetTopWMQCountOfEmployeesV2]
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@dateForChart varchar(20)
AS
BEGIN
	
	DECLARE @DateLatest As Date
	--Declare @vLevel As varchar(50)
	--Set @vLevel = 'L1-L2'
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)
	DECLARE @minDate Date = NULL
	DECLARE @maxDate Date = NULL

	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##temp4TrendChart') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4TrendChart
	END

	CREATE Table ##temp4TrendChart
	(
		EMP_ID INT,GRADE_DESC VARCHAR(50)
	)

	--SET @sqlString = 'Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	--POS, Category Into ##temp4TrendChart From HCR_Data '

	 SET @sqlString = 'Insert Into ##temp4TrendChart '
	 SET @sqlString = @sqlString + ' Select Distinct Employee_Id, Grade_Desc From HCR_Data '

              Set @whereString = ' Where Date = ''' + @dateForChart +''''

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)
	INSERT INTO @vEmpCntWithLeveltab

	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
		SELECT GRADE_DESC,EMP_ID FROM ##temp4TrendChart	
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
		
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT,TAB.DateValue
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT,@dateForChart as DateValue FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB Order by Tab.Grade_Desc desc
	drop table ##temp4TrendChart
END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetCntEmployeesComp]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_Rpt_GetCntEmployeesComp] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vAccount varchar(100)=NULL
AS
BEGIN
	
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)	
	Set @sqlString = ''
	Set @whereString = ''
		
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##tempT1') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempT1
	END
	 create Table ##tempT1
				([Date] [datetime] NOT NULL,
				[DM_EmpName] [varchar](100) NULL,
				[DM_Empno] [int] NULL,
				[EndClient_GroupName] [varchar](100) NULL,
				[EndClient_GroupId] [int] NULL,
				[Prj_Name] [varchar](100) NULL,
				[EmpName] [varchar](100) NULL,
				[Grade_Desc] [varchar](15) NULL,
				[Delivery_Unit] [varchar](100) NULL,
				[POS] [varchar](100) NULL,
				[Category] [varchar](100) NULL,
				[Work_Alloc][int] NULL,
				[Bill_Alloc][int]Null,
				[Prj_Num][int]Null,
				)

	SET @sqlString = @sqlString + ' Insert into ##tempT1 Select Date,  DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	POS, Category, Work_Alloc, Bill_Alloc, Prj_Num From HCR_Comp_Details '
	
	Set @whereString =  '' +'' + ''''

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = '+'' + @vAccount + ''+''
	

	


	SET @sqlString = @sqlString + @whereString + ' Order by DM_EmpName, EndClient_GroupName, Prj_Name, Grade_Desc  '
	
	Print @sqlString
	EXEC(@sqlString)
	
	Select * From ##tempT1
	order by DM_EmpName, EndClient_GroupName, Prj_Name, EmpName

END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetCntEmployeesDrillDown]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_Rpt_GetCntEmployeesDrillDown] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vGrade_Desc varchar(5)=NULL,
@vCategory varchar(50)=NULL

AS
BEGIN
	DECLARE @DateLatest As Date
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)	
	Set @sqlString = ''
	Set @whereString = ''
		
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##temp1') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp1
	END
	 create Table ##temp1
				([Date] [datetime] NOT NULL,
				[DM_EmpName] [varchar](100) NULL,
				[DM_Empno] [int] NULL,
				[EndClient_GroupName] [varchar](100) NULL,
				[EndClient_GroupId] [int] NULL,
				[Prj_Name] [varchar](100) NULL,
				[EmpName] [varchar](100) NULL,
				[Grade_Desc] [varchar](15) NULL,
				[Delivery_Unit] [varchar](100) NULL,
				[POS] [varchar](100) NULL,
				[Category] [varchar](100) NULL,
				[Work_Alloc][int] NULL,
				[Bill_Alloc][int]Null,
				[Prj_Num][int]Null,
				[Opt_ClientGrp][varchar](100) NULL
				)

	SET @sqlString = @sqlString + ' Insert into ##temp1 Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	POS, Category, Work_Alloc, Bill_Alloc, Prj_Num, Opt_ClientGrp From HCR_Data '
	
	Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateLatest) + ''''

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Opt_ClientGrp)) = ''' + @vAccount + ''''
	
	If ISNULL(@vGrade_Desc,'') <> ''
	Begin
	Set @whereString = @whereString + 'AND Grp_Grade_Desc=  ''' + @vGrade_Desc + ''''
	print(@whereString)
		--IF charindex( '+', @vGrade_Desc) > 0
		--Begin
		--	set @vGrade_Desc = Replace(@vGrade_Desc,'+','')
		--	--Set @whereString = @whereString + ' AND Grade_Desc >= ''' + @vGrade_Desc + ''''
		--	Set @whereString = @whereString + ' AND GRADE_DESC IN(''L7'',''L8'',''L9'',''L10'',''L11'',''L12'')'
		--End
		--Else
		--	Set @whereString = @whereString +  ' AND Grade_Desc in (SELECT Tab.Value FROM Fn_SplitDelimetedData(''-'',''' + Isnull(@vGrade_Desc,'') + ''' ) Tab)'
	END
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''


	SET @sqlString = @sqlString + @whereString + ' Order by DM_EmpName,Opt_ClientGrp, EndClient_GroupName, Prj_Name, Grade_Desc  '
	
	Print @sqlString
	EXEC(@sqlString)
	
	Select * From ##temp1
	order by DM_EmpName,Opt_ClientGrp, EndClient_GroupName, Prj_Name, EmpName

END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetCountOfEmployees]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_GetCountOfEmployees] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL
AS
BEGIN
	
	DECLARE @DateLatest As Date
	--Declare @vLevel As varchar(50)
	--Set @vLevel = 'L1-L2'
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)

	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##temp') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp
	END

	CREATE Table ##temp 
	(
		EMP_ID INT,GRADE_DESC VARCHAR(50)
	)

	--SET @sqlString = 'Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	--POS, Category Into ##temp From HCR_Data '

	 SET @sqlString = 'Insert Into ##temp '
	 SET @sqlString = @sqlString + ' Select Distinct Employee_Id, Grade_Desc From HCR_Data '
	
	Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateLatest) + ''''

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)

	--Select * From ##temp
	--Select Distinct WeekDate, EmpName, DMVL_EmpName From @vVLDM_EmpCntTab
	--Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	--POS, Category From ##temp
	--order by DM_EmpName, EndClient_GroupName, Prj_Name, EmpName
	INSERT INTO @vEmpCntWithLeveltab
	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
		SELECT GRADE_DESC,EMP_ID FROM ##temp	
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
		
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB order by TAB.Grade_Desc desc
	drop table ##temp
END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetCountOfEmployeesByFromToDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_Rpt_GetCountOfEmployeesByFromToDate] 
@vDmVlPMO_Id INT,
@weekMonthQuartLatest Int =null,
@dateForChart varchar(20) =Null
AS
BEGIN
DECLARE @DateLatest As Date
	--Declare @vLevel As varchar(50)
	--Set @vLevel = 'L1-L2'
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @minDate Date = NULL
	DECLARE @maxDate Date = NULL
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)

	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	IF OBJECT_ID('tempdb..##temp4CompDashboard') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4CompDashboard
	END

	CREATE Table ##temp4CompDashboard
	(
		EMP_ID INT,GRADE_DESC VARCHAR(50)
	)
	BEGIN
	SET @sqlString = 'Insert Into ##temp4CompDashboard '
	 SET @sqlString = @sqlString + ' Select Distinct Employee_Id, Grade_Desc From HCR_Data '
	 IF @weekMonthQuartLatest = 1

              Set @whereString = ' Where Date = ''' + @dateForChart +''''

       Else IF @weekMonthQuartLatest = 2
			 Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where   Format(Date, 'MMM-yyyy')= @dateForChart)
              Set @whereString =' Where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
			  End

       Else IF @weekMonthQuartLatest = 3
	   Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where Qrtr_Inf = @dateForChart)
			set @whereString =' where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
       End
	   Else If @weekMonthQuartLatest =4
	   Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateLatest) + ''''


	

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)

	INSERT INTO @vEmpCntWithLeveltab
	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
		SELECT GRADE_DESC,EMP_ID FROM ##temp4CompDashboard	
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
		
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB Order by TAB.Grade_Desc desc

	drop table ##temp4CompDashboard
	END

END

GO
/****** Object:  StoredProcedure [dbo].[Sp_Rpt_GetDeliveryUnits]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Rpt_GetDeliveryUnits]
@vDmVlPMO_Id INT
AS
BEGIN
	DECLARE @DateLatest As Date
	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--SELECT DISTINCT LTrim(Delivery_Unit) FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id 
	IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
		SELECT DISTINCT LTrim(Delivery_Unit) FROM HCR_Data 
		Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
		and Date = @DateLatest 
	ELSE
		BEGIN
			SELECT DISTINCT LTrim(Delivery_Unit) FROM HCR_Data WHERE VL_Empno = @vDmVlPMO_Id and Date = @DateLatest 
			UNION
			SELECT DISTINCT LTrim(Delivery_Unit) FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id and Date = @DateLatest 
		END
End	


GO
/****** Object:  StoredProcedure [dbo].[Sp_Rpt_GetDiffDataforTrendDrillDown]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_Rpt_GetDiffDataforTrendDrillDown]
@vDmVlPMO_Id INT,
@weekMonthQuartLatestFor Int =null,
@dateForDrillDownFor varchar(20) =Null,
@weekMonthQuartLatestTo Int =null,
@dateForDrillDownTo varchar(20) =Null,
@vGrade_DescSel varchar(5)=NULL
AS
BEGIN
IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	IF OBJECT_ID('tempdb..##temp9') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp9
	END
	IF OBJECT_ID('tempdb..##temp10') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp10
	END
 declare @table1 Table
				([Date] [datetime] NOT NULL,
				[DM_EmpName] [varchar](100) NULL,
				[DM_Empno] [int] NULL,
				[EndClient_GroupName] [varchar](100) NULL,
				[EndClient_GroupId] [int] NULL,
				[Prj_Num] [int] Null,
				[Prj_Name] [varchar](100) NULL,
				[Employee_Id] [int] Null,
				[EmpName] [varchar](100) NULL,
				[Grade_Desc] [varchar](15) NULL,
				[Delivery_Unit] [varchar](100) NULL,
				[POS] [varchar](100) NULL,
				[Category] [varchar](100) NULL
				)

		insert into @table1  exec SP_Rpt_GetTrendDrillDownbyDate @vDmVlPMO_Id = @vDmVlPMO_Id,
		@weekMonthQuartLatest = @weekMonthQuartLatestFor,
		@dateForDrillDown = @dateForDrillDownFor,
		@vGrade_Desc = @vGrade_DescSel

		select * into ##temp9 from  @table1
		delete from @table1

		insert into @table1 exec SP_Rpt_GetTrendDrillDownbyDate @vDmVlPMO_Id = @vDmVlPMO_Id,
		@weekMonthQuartLatest = @weekMonthQuartLatestTo,
		@dateForDrillDown = @dateForDrillDownTo,
		@vGrade_Desc =@vGrade_DescSel
		select * into ##temp10 from @table1

		(select @dateForDrillDownFor as 'Date', DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Num, Prj_Name, Employee_Id, EmpName, Grade_Desc, Delivery_Unit,POS, Category from ##temp9
		except
		select @dateForDrillDownFor as 'Date', DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Num, Prj_Name, Employee_Id, EmpName, Grade_Desc, Delivery_Unit,POS, Category from @table1) 
		union

		(select  @dateForDrillDownTo as 'Date', DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Num, Prj_Name, Employee_Id, EmpName, Grade_Desc, Delivery_Unit,POS, Category from @table1
		except
		select @dateForDrillDownTo as 'Date', DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Num, Prj_Name, Employee_Id, EmpName, Grade_Desc, Delivery_Unit,POS, Category  from ##temp9)

END

GO
/****** Object:  StoredProcedure [dbo].[Sp_Rpt_GetDMId]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Rpt_GetDMId]
@vDmVlPMO_Id INT,
@vId_IfHCR_Comp_Details int =0
AS
BEGIN
	IF (@vId_IfHCR_Comp_Details=0)
	BEGIN
		DECLARE @DateLatest As Date
		Set @DateLatest = (SELECT MAX(Date) from HCR_Data)

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT  DM_Empno, DM_EmpName FROM HCR_Data 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
			And Date = @DateLatest
		ELSE
			BEGIN
				SELECT DISTINCT DM_Empno, DM_EmpName FROM HCR_Data WHERE VL_Empno = @vDmVlPMO_Id And Date = @DateLatest
				UNION
				SELECT DISTINCT DM_Empno, DM_EmpName FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id And Date = @DateLatest order by DM_EmpName
		END
	END
	IF (@vId_IfHCR_Comp_Details=1)
	BEGIN

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT cast(DM_Empno as int)as DM_Empno, ud.EmpName as 'DM_EmpName' 
			FROM HCR_Comp_Details hcd left join User_Details ud on hcd.DM_Empno = ud.EMPID 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id) and Change_Category !=0
		ELSE
			BEGIN
				SELECT DISTINCT cast(DM_Empno as int) as DM_Empno,ud.EmpName as 'DM_EmpName' FROM HCR_Comp_Details hcd left join User_Details ud on hcd.DM_Empno = ud.EMPID WHERE VL_Empno = @vDmVlPMO_Id and Change_Category !=0
				UNION
				SELECT DISTINCT cast(DM_Empno as int)as DM_Empno, ud.EmpName as 'DM_EmpName' FROM HCR_Comp_Details hcd left join User_Details ud on hcd.DM_Empno = ud.EMPID WHERE DM_Empno = @vDmVlPMO_Id and Change_Category !=0 order by ud.EmpName
		END
	END
END


GO
/****** Object:  StoredProcedure [dbo].[Sp_Rpt_GetEndClientGrpsByDMId]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Rpt_GetEndClientGrpsByDMId]
@vDmVlPMO_Id INT,
@vId_IfHCR_Comp_Details int =0
AS
BEGIN
	IF (@vId_IfHCR_Comp_Details=0)
	BEGIN
		DECLARE @DateLatest As Date
		Set @DateLatest = (SELECT MAX(Date) from HCR_Data)

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT EndClient_GroupName, EndClient_GroupId FROM HCR_Data 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
			and Date = @DateLatest
		ELSE
			BEGIN
				SELECT DISTINCT EndClient_GroupName, EndClient_GroupId FROM HCR_Data WHERE VL_Empno = @vDmVlPMO_Id and Date = @DateLatest
				UNION
				SELECT DISTINCT EndClient_GroupName, EndClient_GroupId FROM HCR_Data WHERE DM_Empno = @vDmVlPMO_Id and Date = @DateLatest order by EndClient_GroupName
			END	
	END
	IF (@vId_IfHCR_Comp_Details=1)
	BEGIN

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT EndClient_GroupName, cast(EndClient_GroupId as int) as EndClient_GroupId FROM HCR_Comp_Details 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
		ELSE
			BEGIN
				SELECT DISTINCT EndClient_GroupName, cast(EndClient_GroupId as int) as EndClient_GroupId FROM HCR_Comp_Details WHERE VL_Empno = @vDmVlPMO_Id and Change_Category !=0
				UNION
				SELECT DISTINCT EndClient_GroupName, cast(EndClient_GroupId as int) as EndClient_GroupId FROM HCR_Comp_Details WHERE DM_Empno = @vDmVlPMO_Id and Change_Category !=0 order by EndClient_GroupName 
			END	
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Sp_Rpt_GetOptClientGrpsByDMId]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Rpt_GetOptClientGrpsByDMId]
@vDmVlPMO_Id INT,
@vId_IfHCR_Comp_Details int =0
AS
BEGIN
	IF (@vId_IfHCR_Comp_Details=0)
	BEGIN
		DECLARE @DateLatest As Date
		Set @DateLatest = (SELECT MAX(Date) from HCR_Data)

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp as OptClientGrpName  from HCR_Data
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id)
			and Date = @DateLatest order by OptClientGrpId
		ELSE
			BEGIN
				SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp as OptClientGrpName from HCR_Data WHERE VL_Empno = @vDmVlPMO_Id and Date = @DateLatest
				UNION
				SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp from HCR_Data  WHERE DM_Empno = @vDmVlPMO_Id and Date = @DateLatest order by OptClientGrpId
			END	
	END
	IF (@vId_IfHCR_Comp_Details=1)
	BEGIN

		IF EXISTS (SELECT 1 FROM User_Details WHERE RoleId = 1 AND EmpId = @vDmVlPMO_Id)
			SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp as OptClientGrpName from HCR_Comp_Details 
			Where VL_Empno In (Select EmpId From User_Details Where Parent_Id = @vDmVlPMO_Id) order by OptClientGrpId
		ELSE
			BEGIN
				SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp as OptClientGrpName FROM HCR_Comp_Details WHERE VL_Empno = @vDmVlPMO_Id and Change_Category !=0
				UNION
				SELECT DISTINCT Opt_ClientGrp as OptClientGrpId, Opt_ClientGrp as OptClientGrpName FROM HCR_Comp_Details WHERE DM_Empno = @vDmVlPMO_Id and Change_Category !=0 order by OptClientGrpId 
			END	
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetTopWMQCountOfEmployees]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,mahendrakar.s@>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_GetTopWMQCountOfEmployees] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@weekMonthQuart Int
AS
BEGIN
	
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	--DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT,dateToGroup Date)	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	
	--Delete Temp Tables
	IF OBJECT_ID('tempdb..##tempInSP_Rpt_GetTopWMQCountOfEmployees1') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempInSP_Rpt_GetTopWMQCountOfEmployees1
	END
	IF OBJECT_ID('tempdb..##tempInSP_Rpt_GetTopWMQCountOfEmployees2') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempInSP_Rpt_GetTopWMQCountOfEmployees2
	END
	IF OBJECT_ID('tempdb..##temp4EFrame') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4EFrame
	END
			CREATE Table ##tempInSP_Rpt_GetTopWMQCountOfEmployees1
			(
				EMP_ID INT,GRADE_DESC VARCHAR(50),DateOfRow Date
			)
			CREATE Table ##tempInSP_Rpt_GetTopWMQCountOfEmployees2
			(
				EmpCount INT,GRADE_DESC VARCHAR(50),DateOfRow Date
			)
			CREATE Table ##temp4EFrame
			(
				EmpCount INT,GRADE_DESC VARCHAR(50),DateOfRow date,FormattedDate VARCHAR(12)
			)

	 SET @sqlString = 'Insert Into ##tempInSP_Rpt_GetTopWMQCountOfEmployees1 '
	
	If @weekMonthQuart=1
		BEGIN
	
			SET @sqlString = @sqlString + 'select Distinct Employee_Id,Grade_Desc,Date from HCR_Data '
			Set @whereString =  'where Date IN (select Distinct Top 12 Date from HCR_Data order by Date desc)'
		END
	If @weekMonthQuart=2
		BEGIN
	
			SET @sqlString = @sqlString + 'select Distinct Employee_Id,Grade_Desc,Date from HCR_Data '
			Set @whereString =  'where Date IN (select top 6 Weekly from(Select  Max(Weekly) as weekly,Monthly from (select Distinct Date as weekly,Qrtr_Inf,FORMAT(Date,N''MMM-yyyy'') as Monthly from HCR_Data)tbl group by Monthly)tbla order by weekly desc)'
		END


	If @weekMonthQuart=3
		BEGIN			
			SET @sqlString = @sqlString + 'Select Distinct Employee_Id,Grade_Desc,Date from HCR_Data '
			--Set @whereString =  'where Qrtr_Inf IN (select Distinct Top 4 Qrtr_Inf from HCR_Data order by Qrtr_Inf desc)'
			Set @whereString =  'where Date IN (select top 4 Weekly from(Select  Max(Weekly) as weekly,Qrtr_Inf from (select Distinct Date as weekly,Qrtr_Inf,FORMAT(Date,N''MMM-yyyy'') as Monthly from HCR_Data)tbl group by Qrtr_Inf)tbla order by weekly desc)'
		END
	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)

	Insert into ##tempInSP_Rpt_GetTopWMQCountOfEmployees2
	select 	tbl.EmpCount,tbl.Grade_Desc ,tbl.DateOfRow
	from
	(select COUNT(EMP_ID) as EmpCount ,'L1-L2' AS Grade_Desc ,DateOfRow from ##tempInSP_Rpt_GetTopWMQCountOfEmployees1 where GRADE_DESC IN('L1','L2') Group By DateOfRow
	Union
	select COUNT(EMP_ID)as EmpCount,'L3-L4' AS Grade_Desc,DateOfRow from ##tempInSP_Rpt_GetTopWMQCountOfEmployees1 where GRADE_DESC IN('L3','L4') Group By DateOfRow
	Union
	select COUNT(EMP_ID)as EmpCount,'L5-L6' AS Grade_Desc, DateOfRow from ##tempInSP_Rpt_GetTopWMQCountOfEmployees1 where GRADE_DESC IN('L5','L6') Group By DateOfRow
	Union
	select COUNT(EMP_ID)as EmpCount,'L7+' AS Grade_Desc,DateOfRow from ##tempInSP_Rpt_GetTopWMQCountOfEmployees1 where GRADE_DESC IN('L7','L8','L9','L10','L11','L12') Group By DateOfRow)tbl


	If @weekMonthQuart=1
	BEGIN
		Insert into ##temp4EFrame  select tbl.EmpCount,tbl.GRADE_DESC,tbl.DateOfRow ,tbl.FormattedDate From(
		--select EmpCount,Grade_Desc, Format(DateOfRow,N'dd-MMM-yyyy') as DateOfRow from ##tempInSP_Rpt_GetTopWMQCountOfEmployees2)tbl
		select EmpCount,Grade_Desc,DateOfRow ,FORMAT(DateOfRow,N'dd-MMM-yyyy') as FormattedDate from ##tempInSP_Rpt_GetTopWMQCountOfEmployees2)tbl

	END
	If @weekMonthQuart=2
	BEGIN
		Insert into ##temp4EFrame  select tbl.EmpCount,tbl.GRADE_DESC,tbl.DateOfRow,tbl.FormattedDate From(
		select EmpCount,Grade_Desc, DateOfRow, FORMAT(DateOfRow,N'MMM-yyyy') as FormattedDate from ##tempInSP_Rpt_GetTopWMQCountOfEmployees2)tbl
	END
	If @weekMonthQuart=3
	BEGIN
		Insert into ##temp4EFrame  select tbl.EmpCount,tbl.GRADE_DESC,tbl.DateOfRow,tbl.FormattedDate From(
		select EmpCount,Grade_Desc ,DateOfRow,[dbo].[Fn_QuarterDate](DateOfRow) as FormattedDate from ##tempInSP_Rpt_GetTopWMQCountOfEmployees2)tbl
	END
	
	select * from  ##temp4EFrame order by DateOfRow desc,GRADE_DESC


	--drop table ##tempInSP_Rpt_GetTopWMQCountOfEmployees1
	--drop table ##tempInSP_Rpt_GetTopWMQCountOfEmployees2
	--drop table  ##temp4EFrame
END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetTopWMQCountOfEmployeesV2]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,mahendrakar.s@>
-- Create date: <Create Date,,>
-- Description:	<Description,[SP_Rpt_ForSP_Rpt_GetTopWMQCountOfEmployeesV2] is MANDATORY>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_GetTopWMQCountOfEmployeesV2] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@weekMonthQuart Int
AS
BEGIN
	

	DECLARE @dateTable AS TABLE(ROW_Id INT IDENTITY,DateValue Date)	
	DECLARE @temptable As TABLe(ROW_Id INT IDENTITY,EmpCount INT,GRADE_DESC VARCHAR(50),DateOfRow Date )
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	
	--Delete Temp Tables
	IF OBJECT_ID('tempdb..##tempinWhileLoop') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempinWhileLoop
	END
	IF OBJECT_ID('tempdb..##temp4EFrame') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4EFrame
	END
		CREATE Table ##tempinWhileLoop
			(
				Grade_Desc VARCHAR(50),EMP_COUNT INT,DateValue Date
			)
			CREATE Table ##temp4EFrame
			(
				Grade_Desc VARCHAR(50),EMP_COUNT INT,DateValue Date,FormattedDate VARCHAR(12)
			)
	
	If @weekMonthQuart=1
		BEGIN
		Insert Into @dateTable
		Select tbl.DateValue From
		(select Distinct Top 12 Date as DateValue from HCR_Data order by Date desc)tbl
		END
	If @weekMonthQuart=2
		BEGIN
		Insert Into @dateTable
		Select tblB.DateValue From
		(select top 6 Weekly as DateValue from
		(Select  Max(Weekly) as weekly,Monthly from
		(select Distinct Date as weekly,FORMAT(Date,N'MMM-yyyy') as Monthly from HCR_Data)tbl 
		group by Monthly)tbla order by weekly desc)tblB			
		END
	If @weekMonthQuart=3
		BEGIN			
		Insert Into @dateTable
		Select tblB.DateValue From
		(select top 4 Weekly as DateValue from
		(Select  Max(Weekly) as weekly,Qrtr_Inf from 
		(select Distinct Date as weekly,Qrtr_Inf from HCR_Data)tbl group by Qrtr_Inf)tbla order by weekly desc)tblB
		END


		declare @dateInLoop Date 
		select @dateInLoop = (select min(DateValue) from @dateTable)
		while @dateInLoop is not null
		Begin
		print @dateInLoop
		insert into ##tempinWhileLoop  exec SP_Rpt_ForSP_Rpt_GetTopWMQCountOfEmployeesV2 @vDmVlPMO_Id,@vDm_Id,@vPosition,@vDelivery_Unit,@vAccount,@vCategory,@dateInLoop
		select @dateInLoop = (select min(DateValue) from @dateTable where DateValue >@dateInLoop)
		END
		
	If @weekMonthQuart=1
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT, DateValue,FORMAT(DateValue,N'dd-MMM-yyyy') as FormattedDate from ##tempinWhileLoop)tbl

	END
	If @weekMonthQuart=2
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT, DateValue, FORMAT(DateValue,N'MMM-yyyy') as FormattedDate from ##tempinWhileLoop)tbl
	END
	If @weekMonthQuart=3
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT ,DateValue,[dbo].[Fn_QuarterDate](DateValue) as FormattedDate from ##tempinWhileLoop)tbl
	END
	
		select * from  ##temp4EFrame order by DateValue,GRADE_DESC desc
	
	--drop table ##temp4EFrame
	--drop table ##tempinWhileLoop
END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetTopWMQCountOfEmployeesV3]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,mahendrakar.s@>
-- Create date: <Create Date,,>
-- Description:	<Description,[SP_Rpt_EmpCountGradeDescForCharts] is MANDATORY>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_GetTopWMQCountOfEmployeesV3] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@weekMonthQuart Int
AS
BEGIN
	

	DECLARE @dateTable AS TABLE(ROW_Id INT IDENTITY,DateValue Date)	
	DECLARE @temptable As TABLe(ROW_Id INT IDENTITY,EmpCount INT,GRADE_DESC VARCHAR(50),DateOfRow Date )
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	
	--Delete Temp Tables
	IF OBJECT_ID('tempdb..##tempinWhileLoop') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempinWhileLoop
	END
	IF OBJECT_ID('tempdb..##temp4EFrame') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4EFrame
	END
		CREATE Table ##tempinWhileLoop
			(
				Grade_Desc VARCHAR(50),EMP_COUNT INT,DateValue Date
			)
			CREATE Table ##temp4EFrame
			(
				Grade_Desc VARCHAR(50),EMP_COUNT INT,DateValue Date,FormattedDate VARCHAR(12)
			)
	
	If @weekMonthQuart=1
		BEGIN
		Insert Into @dateTable
		Select tbl.DateValue From
		(select Distinct Top 12 Date as DateValue from HCR_Data order by Date desc)tbl
		END
	If @weekMonthQuart=2
		BEGIN
		Insert Into @dateTable
		Select top 6 Max(Date) as Dates From 
		(Select Distinct(CONCAT(Substring(DATENAME(MONTH , Date),1,3),'-',YEAR(Date))) as Monthly, Date
		From HCR_Data) tabMonths
		Group by Monthly
		order by Dates desc 
  --Select tblB.DateValue From
		--(select top 6 Weekly as DateValue from
		--(Select  Max(Weekly) as weekly,Monthly from
		--(select Distinct Date as weekly,CONCAT(Substring(DATENAME(MONTH , Date),1,3),'-',YEAR(Date)) as Monthly from HCR_Data)tbl 
		--group by Monthly)tbla order by weekly desc)tblB
		END
	If @weekMonthQuart=3
		BEGIN			
		Insert Into @dateTable
		Select tblB.DateValue From
		(select top 4 Weekly as DateValue from
		(Select  Max(Weekly) as weekly,Qrtr_Inf from 
		(select Distinct Date as weekly,Qrtr_Inf from HCR_Data)tbl group by Qrtr_Inf)tbla order by weekly desc)tblB
		END


		declare @dateInLoop Date 
		select @dateInLoop = (select min(DateValue) from @dateTable)
		while @dateInLoop is not null
		Begin
		print @dateInLoop
		--By Default SP will be excuted on Weekly with @vWMQId=1 
		insert into ##tempinWhileLoop  exec SP_Rpt_EmpCountGradeDescForCharts @vDmVlPMO_Id,@vDm_Id,@vPosition,@vDelivery_Unit,@vAccount,@vCategory,1,@dateInLoop
		select @dateInLoop = (select min(DateValue) from @dateTable where DateValue >@dateInLoop)
		END
		
	If @weekMonthQuart=1
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT, DateValue,FORMAT(DateValue,N'dd-MMM-yyyy') as FormattedDate from ##tempinWhileLoop)tbl

	END
	If @weekMonthQuart=2
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT, DateValue, FORMAT(DateValue,N'MMM-yyyy') as FormattedDate from ##tempinWhileLoop)tbl
	END
	If @weekMonthQuart=3
	BEGIN
		Insert into ##temp4EFrame  select tbl.Grade_Desc,tbl.EMP_COUNT,tbl.DateValue ,tbl.FormattedDate From(
		select Grade_Desc,EMP_COUNT ,DateValue,[dbo].[Fn_QuarterDate](DateValue) as FormattedDate from ##tempinWhileLoop)tbl
	END
	
		select * from  ##temp4EFrame order by DateValue,GRADE_DESC desc
	
	--drop table ##temp4EFrame
	--drop table ##tempinWhileLoop
END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetTrendCountOfEmployees]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_GetTrendCountOfEmployees] 
@vDmVlPMO_Id INT,
@vDm_Id INT = NULL,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL,
@vAccount varchar(100)=NULL,
@vCategory varchar(50)=NULL,
@weekMonthQuartLatest Int =NULL,
@dateForChart varchar(20) =NULL
AS
BEGIN
	
	DECLARE @DateLatest As Date
	--Declare @vLevel As varchar(50)
	--Set @vLevel = 'L1-L2'
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)
	DECLARE @minDate Date = NULL
	DECLARE @maxDate Date = NULL

	
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##temp4TrendChart') IS NOT NULL
	BEGIN
		   DROP TABLE ##temp4TrendChart
	END

	CREATE Table ##temp4TrendChart
	(
		EMP_ID INT,GRADE_DESC VARCHAR(50)
	)

	--SET @sqlString = 'Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit, 
	--POS, Category Into ##temp4TrendChart From HCR_Data '

	 SET @sqlString = 'Insert Into ##temp4TrendChart '
	 SET @sqlString = @sqlString + ' Select Distinct Employee_Id, Grade_Desc From HCR_Data '

	IF @weekMonthQuartLatest = 1

              Set @whereString = ' Where Date = ''' + @dateForChart +''''

       Else IF @weekMonthQuartLatest = 2
			 Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where   Format(Date, 'MMM-yyyy')= @dateForChart)
              Set @whereString =' Where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
			  End

       Else IF @weekMonthQuartLatest = 3
	   Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where Qrtr_Inf = @dateForChart)
			set @whereString =' where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
       End
	   Else If @weekMonthQuartLatest =4
	   Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateLatest) + ''''



	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	If ISNULL(@vDm_Id,'') <> '' 
		Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id) 
	If ISNULL(@vPosition,'') <> '' 
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(POS)) = ''' + @vPosition + ''''
	If ISNULL(@vDelivery_Unit,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(Delivery_Unit)) = ''' + @vDelivery_Unit	 + ''''
	If ISNULL(@vAccount,'') <> ''
		Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''
	If ISNULL(@vCategory,'') <> ''
		Set @whereString = @whereString + ' AND Category = ''' + @vCategory + ''''

	SET @sqlString = @sqlString + @whereString 
	
	Print @sqlString
	EXEC(@sqlString)
	INSERT INTO @vEmpCntWithLeveltab

	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
		SELECT GRADE_DESC,EMP_ID FROM ##temp4TrendChart	
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
		
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc, ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,ISNULL(SUM(EMP_COUNT),0) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB order by TAB.Grade_Desc desc
	drop table ##temp4TrendChart
END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_GetTrendDrillDownbyDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_Rpt_GetTrendDrillDownbyDate] 
@vDmVlPMO_Id INT,
@weekMonthQuartLatest Int =null,
@dateForDrillDown varchar(20) =Null,
@vGrade_Desc varchar(5)=NULL

AS
BEGIN
	Declare @sqlString Varchar(MAX)
	Declare @whereString Varchar(MAX)	
	DECLARE @maxDate Date = NULL
	DECLARE @DateLatest As Date
	Set @sqlString = ''
	Set @whereString = ''
		
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	Set @DateLatest = (SELECT MAX(Date) from HCR_Data)
	--Delete From HCR_DashboardDrillData
	IF OBJECT_ID('tempdb..##tempforTrendDrillDown') IS NOT NULL
	BEGIN
		   DROP TABLE ##tempforTrendDrillDown
	END
	 create Table ##tempforTrendDrillDown
				([Date] [datetime] NOT NULL,
				[DM_EmpName] [varchar](100) NULL,
				[DM_Empno] [int] NULL,
				[EndClient_GroupName] [varchar](100) NULL,
				[EndClient_GroupId] [int] NULL,
				[Prj_Num] [int] Null,
				[Prj_Name] [varchar](100) NULL,
				[Employee_Id] [int] Null,
				[EmpName] [varchar](100) NULL,
				[Grade_Desc] [varchar](15) NULL,
				[Delivery_Unit] [varchar](100) NULL,
				[POS] [varchar](100) NULL,
				[Category] [varchar](100) NULL
				)

	SET @sqlString = @sqlString + ' Insert into ##tempforTrendDrillDown Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId,Prj_Num,Prj_Name,Employee_Id, EmpName, Grade_Desc, Delivery_Unit, 
	POS, Category  From HCR_Data '
	
      IF @weekMonthQuartLatest = 1

              Set @whereString = ' Where Date = ''' + @dateForDrillDown +''''

       Else IF @weekMonthQuartLatest = 2
			 Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where   Format(Date, 'MMM-yyyy')= @dateForDrillDown)
              Set @whereString =' Where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
			  End

       Else IF @weekMonthQuartLatest = 3
	   Begin
			   Set @maxDate = (Select ISNULL(Max(Date),'') From HCR_Data where Qrtr_Inf = @dateForDrillDown)
			set @whereString =' where Date = ''' + CONVERT(Varchar(12),@maxDate) + ''''
       End
	   Else If @weekMonthQuartLatest =4
	   Set @whereString =  ' Where Date = ''' + convert(varchar(20),@DateLatest) + ''''
	

	--For PMO
	IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id) 
		Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
	--For VL and DM
	Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2) 
		Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)	 
	Else
		Set @whereString = @whereString + ' AND DM_Empno = ' +  convert(varchar(10),@vDmVlPMO_Id)
	
	
	If ISNULL(@vGrade_Desc,'') <> ''
	Begin
		IF charindex( '+', @vGrade_Desc) > 0
		Begin
			set @vGrade_Desc = Replace(@vGrade_Desc,'+','')
			Set @whereString = @whereString + ' AND Grade_Desc >= ''' + @vGrade_Desc + ''''
		End
		Else
			Set @whereString = @whereString +  ' AND Grade_Desc in (SELECT Tab.Value FROM Fn_SplitDelimetedData(''-'',''' + Isnull(@vGrade_Desc,'') + ''' ) Tab)'
	END

	SET @sqlString = @sqlString + @whereString + ' Order by DM_EmpName, EndClient_GroupName, Prj_Name, Grade_Desc  '
	
	Print @sqlString
	EXEC(@sqlString)
	
	Select * From ##tempforTrendDrillDown
	order by DM_EmpName, EndClient_GroupName, Prj_Name, EmpName

	DROP TABLE ##tempforTrendDrillDown

END








GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_ViewDataCategoryWise]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 


 

-- =============================================

 

-- Author:           <Author,,Name>

 

-- Create date: <Create Date,,>

 

-- Description:      <Description,,>

 

-- =============================================

 

CREATE PROCEDURE [dbo].[SP_Rpt_ViewDataCategoryWise]

 

@vDmVlPMO_Id INT,

 

@vFromdate Varchar(12),

 

@vTodate Varchar(12),

 

@vDm_Id INT = 0,

 

@vAccount varchar(100)=NULL,

 

@vPosition varchar(50)=NULL,

 

@vDelivery_Unit varchar(50)=NULL,

 

@options int=0

 

AS

 

BEGIN

 

       Declare @sqlString Varchar(MAX)

 

       Declare @whereString Varchar(MAX)

 

       DECLARE @minFromdate Date = NULL

 

       DECLARE @maxTodate Date = NULL

 

       DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,CHANGE_CATEGORY VARCHAR(50),EMP_COUNT INT)

 

       Set @sqlString = ''

 

       Set @whereString = ''

 

       --IF @vAccount=0 set @vAccount=NULL

 

       IF @vDm_Id=0 set @vDm_Id=NULL

         

 

       SET FMTONLY OFF

 

       IF OBJECT_ID('tempdb..##temp') IS NOT NULL

 

       BEGIN

 

              DROP TABLE ##temp

 

       END

 

       CREATE Table ##temp

 

       (EMP_ID INT, CHANGE_CATEGORY VARCHAR(50))

 

       SET @sqlString = 'Insert Into ##temp '

 

       SET @sqlString = @sqlString + ' Select Distinct Emp_Id, CHANGE_CATEGORY From HCR_Comp_Details '

 


       IF @options = 1

 

              Set @whereString = ' Where FROM_DATE >= ''' + @vFromdate + ''' AND TO_DATE <= ''' + @vTodate  + ''''

 

       Else IF @options = 2

          Begin

                     Set @minFromdate= (Select ISNULL(Min(From_Date),'') From HCR_Comp_Details where Format(FROM_DATE, 'MMM-yyyy') =  @vFromdate)

            Set @maxTodate = (Select ISNULL(Max(TO_DATE),'') From HCR_Comp_Details where Format(TO_DATE, 'MMM-yyyy') =  @vTodate)

            Set @whereString =' Where FROM_DATE >= ''' + CONVERT(Varchar(12),@minFromdate) + ''' and TO_DATE <= ''' + CONVERT(Varchar(12),@maxTodate) + ''''

          End

       Else IF @options = 3

       Begin

              Set @minFromdate= (Select ISNULL(Min(From_Date),'') From HCR_Comp_Details where Qrtr_Inf = @vFromdate)

              Set @maxTodate = (Select ISNULL(Max(TO_DATE),'') From HCR_Comp_Details where Qrtr_Inf = @vTodate)

 

              Set @whereString =' Where FROM_DATE >= ''' + CONVERT(Varchar(12),@minFromdate) + ''' and TO_DATE <= ''' + CONVERT(Varchar(12),@maxTodate) + ''''

 

       End            

 

       Set @whereString = @whereString + ' And ISNULL(Change_Category,0) <> 0 '

 

       --For PMO

 

       IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id)

 

              Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'

 

       --For VL and DM

 

       Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2)

 

                     Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)

 

       Else

 

              Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)

 

       If ISNULL(@vDm_Id,'') <> ''

 

              Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id)

 

       If ISNULL(@vPosition,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Location)) = ''' + @vPosition + ''''

 

       If ISNULL(@vDelivery_Unit,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Del_Unit)) = ''' + @vDelivery_Unit + ''''

 

       If ISNULL(@vAccount,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Opt_ClientGrp)) = ''' + @vAccount + ''''

 

            

 

       SET @sqlString = @sqlString + @whereString

 


 

       Print @sqlString

 

       EXEC (@sqlString)

 


 

       INSERT INTO @vEmpCntWithLeveltab

 

              SELECT TAB.CHANGE_CATEGORY,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM

              (

                     SELECT CHANGE_CATEGORY,EMP_ID FROM ##temp 

 

              ) TAB

 

              GROUP BY TAB.CHANGE_CATEGORY

 

              ORDER BY dbo.udf_GetNumeric(TAB.CHANGE_CATEGORY)

 


 

       SELECT hcc.Change_Category, ISNULL(h.EMP_COUNT,0) as EMP_COUNT

 

       FROM HCR_Change_Category hcc LEFT OUTER JOIN @vEmpCntWithLeveltab h On hcc.Change_Id = h.CHANGE_CATEGORY

 

       Order by hcc.Change_Category

 

                   

 

END


GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_ViewDataCategoryWise_quaterly]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_ViewDataCategoryWise_quaterly] 
@vDmVlPMO_Id INT,
@vFromdate DATE,
@vTodate DATE,
@vDm_Id INT = 0,
@vAccount varchar(100)=0,
@vPosition varchar(50)=NULL,
@vDelivery_Unit varchar(50)=NULL
AS
BEGIN
	 Declare @sqlString Varchar(MAX)
   Declare @whereString Varchar(MAX)
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,CHANGE_CATEGORY VARCHAR(50),EMP_COUNT INT)

    IF @vAccount=0 set @vAccount=NULL
    IF @vDm_Id=0 set @vDm_Id=NULL

    IF 1=0 BEGIN
        SET FMTONLY OFF
    END
  
    --Delete From HCR_DashboardDrillData
    IF OBJECT_ID('tempdb..##temp') IS NOT NULL
    BEGIN
           DROP TABLE ##temp
    END

    CREATE Table ##temp
    (
        EMP_ID INT, CHANGE_CATEGORY VARCHAR(50)
    )

    --SET @sqlString = 'Select Date, DM_EmpName, DM_Empno, EndClient_GroupName, EndClient_GroupId, Prj_Name, EmpName, Grade_Desc, Delivery_Unit,
    --POS, Category Into ##temp From HCR_Data '

     SET @sqlString = 'Insert Into ##temp '
     SET @sqlString = @sqlString + ' Select distinct Emp_Id, CHANGE_CATEGORY From HCR_Comp_Details '
		 
     
--	
	SET @whereString = 'WHERE SUBSTRING(CAST(FROM_DATE AS VARCHAR),1,7) BETWEEN LEFT('''+CAST(@vFromdate AS VARCHAR)+''',9) AND LEFT('''+CAST(@vTodate AS VARCHAR)+''',9)' 
 	Set @whereString =  @whereString + ' And ISNULL(Change_Category,0) <> 0 '

    --For PMO
    IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id)
        Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'
    --For VL and DM
    Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2)
        Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)
    Else
        Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)
  
    If ISNULL(@vDm_Id,'') <> ''
        Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id)
    If ISNULL(@vPosition,'') <> ''
        Set @whereString = @whereString + ' AND LTRIM(RTRIM(Location)) = ''' + @vPosition + ''''
    If ISNULL(@vDelivery_Unit,'') <> ''
        Set @whereString = @whereString + ' AND LTRIM(RTRIM(Del_Unit)) = ''' + @vDelivery_Unit + ''''
    If ISNULL(@vAccount,'') <> ''
        Set @whereString = @whereString + ' AND LTRIM(RTRIM(EndClient_GroupId)) = ''' + @vAccount + ''''

    SET @sqlString = @sqlString + @whereString 
  
    Print @sqlString
    EXEC(@sqlString)

    INSERT INTO @vEmpCntWithLeveltab
    SELECT TAB.CHANGE_CATEGORY,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
    (
        SELECT CHANGE_CATEGORY,EMP_ID FROM ##temp  
    ) TAB
    GROUP BY TAB.CHANGE_CATEGORY
    ORDER BY dbo.udf_GetNumeric(TAB.CHANGE_CATEGORY)

	SELECT ISNULL(B.Change_Category,'') AS Change_Category, A.EMP_COUNT FROM @vEmpCntWithLeveltab A
	LEFT OUTER JOIN HCR_Change_Category B On A.CHANGE_CATEGORY = B.Change_Id	

END

GO
/****** Object:  StoredProcedure [dbo].[SP_Rpt_ViewDataCategoryWiseDrilldown]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Rpt_ViewDataCategoryWiseDrilldown]

 

@vDmVlPMO_Id INT,

 

@vFromdate Varchar(12),

 

@vTodate Varchar(12),

 

@vDm_Id INT = 0,

 

@vAccount varchar(100)=NULL,

 

@vPosition varchar(50)=NULL,

 

@vDelivery_Unit varchar(50)=NULL,

 

@options int=0,

 

@change_Category varchar(50) = NULL

 

AS

 

BEGIN

 

       Declare @sqlString Varchar(MAX)

 

       Declare @whereString Varchar(MAX)

 

       DECLARE @minFromdate Date = NULL

 

       DECLARE @maxTodate Date = NULL

 

       Set @sqlString = ''

 

       Set @whereString = ''

         

 

      -- IF @vAccount=0 set @vAccount=NULL

 

       IF @vDm_Id=0 set @vDm_Id=NULL

         

 

       SET FMTONLY OFF

 

     

       IF OBJECT_ID('tempdb..##temp3') IS NOT NULL

 

       BEGIN

 

              DROP TABLE ##temp3

 

       END

 

       create Table ##temp3

              ([DM_Empno] [int]NULL,

              [DM_Name] [varchar](50) NULL,

              [EndClient_GroupName] [varchar](max) NULL,

              [EndClient_GroupId] [int] NULL,

              [Prj_Name] [varchar](max) NULL,

              [EmpName] [varchar](max) NULL,

              [HR_Level] [varchar](max) NULL,

              [Del_Unit] [varchar](max) NULL,
			  [Bill_Allocations] [varchar](max) NULL,

              [Location] [varchar](max) NULL,
			  [Opt_ClientGrp][varchar](100) NULL)

 

       SET @sqlString = @sqlString + 'Insert into ##temp3 Select Distinct DM_Empno, ud.EmpName, EndClient_GroupName, EndClient_GroupId, Prj_Name, hcd.EmpName, HR_Level ,

 

       Del_Unit,Bill_Allocations, Location,Opt_ClientGrp From HCR_Comp_Details hcd left join User_Details ud on hcd.DM_Empno = ud.EMPID '


 

       IF @options = 1

 

              Set @whereString = ' Where FROM_DATE >= ''' + @vFromdate + ''' AND TO_DATE <= ''' + @vTodate  + ''''

 

       Else IF @options = 2

		  Begin

                     Set @minFromdate= (Select ISNULL(Min(From_Date),'') From HCR_Comp_Details where Format(FROM_DATE, 'MMM-yyyy') =  @vFromdate)

            Set @maxTodate = (Select ISNULL(Max(TO_DATE),'') From HCR_Comp_Details where Format(TO_DATE, 'MMM-yyyy') =  @vTodate)

            Set @whereString =' Where FROM_DATE >= ''' + CONVERT(Varchar(12),@minFromdate) + ''' and TO_DATE <= ''' + CONVERT(Varchar(12),@maxTodate) + ''''

          End


              --Set @whereString =' Where Format(FROM_DATE, ''MM-yyyy'') >= dbo.Fn_GetMonthNo(''' + @vFromdate + ''') and Format(TO_DATE, ''MM-yyyy'') <= dbo.Fn_GetMonthNo(''' + @vTodate + ''')'

 

       Else IF @options = 3

 

       Begin

 

              Set @minFromdate= (Select ISNULL(Min(From_Date),'') From HCR_Comp_Details where Qrtr_Inf = @vFromdate)

 

              Set @maxTodate = (Select ISNULL(Max(TO_DATE),'') From HCR_Comp_Details where Qrtr_Inf = @vTodate)

 

              Set @whereString =' Where FROM_DATE >= ''' + CONVERT(Varchar(12),@minFromdate) + ''' and TO_DATE <= ''' + CONVERT(Varchar(12),@maxTodate) + ''''

 

       End

           

 

       Set @whereString = @whereString + ' And ISNULL(Change_Category,0) <> 0 '

 


       --For PMO

 

       IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlPMO_Id)

 

              Set @whereString = @whereString + ' AND VL_Empno In (Select EmpId From User_Details Where Parent_Id= ' + convert(varchar(10),@vDmVlPMO_Id) + ')'

 

       --For VL and DM

 

       Else IF EXISTS (SELECT 1 FROM User_Details WHERE EmpId=@vDmVlPMO_Id and RoleId = 2)

 

                     Set @whereString = @whereString + ' AND VL_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)

 

       Else

 

              Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDmVlPMO_Id)

 


 

       If ISNULL(@vDm_Id,'') <> ''

 

              Set @whereString = @whereString + ' AND DM_Empno = ' + convert(varchar(10),@vDm_Id)

 

       If ISNULL(@vPosition,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Location)) = ''' + @vPosition + ''''

 

       If ISNULL(@vDelivery_Unit,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Del_Unit)) = ''' + @vDelivery_Unit + ''''

 

       If ISNULL(@vAccount,'') <> ''

 

              Set @whereString = @whereString + ' AND LTRIM(RTRIM(Opt_ClientGrp)) = ''' + @vAccount + ''''

 

       If ISNULL(@change_Category, '') <>  ''

 

              Set @whereString = @whereString + ' AND Change_Category = (Select Change_ID From HCR_Change_Category Where Change_Category = ''' + @change_Category + ''')'

      

       SET @sqlString = @sqlString + @whereString + ' Order by HR_level'

 

       Print @sqlString

 

       EXEC (@sqlString)

 

      Select * From ##temp3
END

GO
/****** Object:  StoredProcedure [dbo].[SP_SaveComment]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SaveComment]
@vCommentStr NVARCHAR(MAX),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @vSaveCommentTab AS TABLE(Comment_Id INT,Comment NVARCHAR(MAX),Change_Cat VARCHAR(10))

INSERT INTO @vSaveCommentTab(Comment_Id,Comment,Change_Cat)
SELECT RTRIM(LTRIM(SUBSTRING(TAB.TagValue,1, (CHARINDEX('~',TAB.TagValue,1))-1))) AS Comment_Id,
		SUBSTRING(TAB.TagValue,(CHARINDEX('~',TAB.TagValue,1))+1, (CHARINDEX('#',TAB.TagValue,1))-1) AS Comment,
		SUBSTRING(TAB.TagValue,(CHARINDEX('#',TAB.TagValue,1))+1, LEN(TAB.TagValue)) AS Change_Cat
							FROM
								(
									SELECT 	Tab.Value AS TagValue
										FROM Fn_SplitDelimetedData('|',@vCommentStr) Tab
											WHERE Len(RTRIM(LTRIM(Value)))>0
										)	TAB 

UPDATE  A SET A.Comment = SUBSTRING(A.Comment,0,(CHARINDEX('#',A.Comment,1))) FROM @vSaveCommentTab A

--SELECT * FROM @vSaveCommentTab

UPDATE A SET A.COMMENT=B.Comment,A.Change_Category=B.Change_Cat FROM HCR_Comp_Details A INNER JOIN @vSaveCommentTab B On A.Comp_Detail_Id = B.Comment_Id

SELECT @vMsg_Out = 'Comments Saved Successfully'

END 


GO
/****** Object:  StoredProcedure [dbo].[SP_SetUploadStatus]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SetUploadStatus]
	-- Add the parameters for the stored procedure here
	@flag bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		Update HCR_Status
	Set Upload_Flag = @flag
END

GO
/****** Object:  StoredProcedure [dbo].[SP_TrenLineEmployeeCount]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,eHCR,Himanshu Sao>
-- Create date: <Create Date,09-06-2020,>
-- Description:	<Sp for Getting latest 6 months employee count and their level,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TrenLineEmployeeCount]  
	-- Add the parameters for the stored procedure here
@vDmVl_Id int
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @vTO_DT DATE=(SELECT MAX(Date) FROM HCR_Data)
	--DECLARE @vFrom_DT DATE=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
	DECLARE @cnt INT = 0
	DECLARE @vDM_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vVL_EmpCntTab AS TABLE(EMP_ID INT,GRADE_DESC VARCHAR(50))
	DECLARE @vEmpCntWithLeveltab AS TABLE(ROW_Id INT IDENTITY,GRADE_DESC VARCHAR(50),EMP_COUNT INT)
	While @cnt<6
	BEGIN
	INSERT INTO @vDM_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=@vTO_DT AND DM_Empno = @vDmVl_Id
		INSERT INTO @vVL_EmpCntTab
		SELECT DISTINCT Employee_Id,Grade_Desc FROM HCR_Data WHERE Date=@vTO_DT AND VL_Empno = @vDmVl_Id

		INSERT INTO @vEmpCntWithLeveltab
	SELECT TAB.GRADE_DESC,COUNT(TAB.EMP_ID) AS EMP_COUNT FROM
	(
	SELECT GRADE_DESC,EMP_ID FROM @vDM_EmpCntTab
	UNION
	SELECT GRADE_DESC,EMP_ID FROM @vVL_EmpCntTab
	) TAB 
	GROUP BY TAB.GRADE_DESC
	ORDER BY dbo.udf_GetNumeric(TAB.GRADE_DESC)
	

	
	SELECT TAB.Grade_Desc,TAB.EMP_COUNT
	FROM
	(
	SELECT 'L1-L2' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L1','L2')
	UNION
	SELECT 'L3-L4' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L3','L4')
	UNION
	SELECT 'L5-L6' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L5','L6')
	UNION
	SELECT 'L7+' AS Grade_Desc,SUM(EMP_COUNT) AS EMP_COUNT FROM @vEmpCntWithLeveltab WHERE GRADE_DESC IN('L7','L8','L9','L10','L11','L12')
	) TAB
	SET @cnt = @cnt + 1
	SET @vTO_DT=(SELECT MAX(Date) FROM HCR_Data WHERE Date < @vTO_DT)
	
	END

END

GO
/****** Object:  StoredProcedure [dbo].[SP_User_Info]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_User_Info]
@EmpName varchar(50),
@RoleId int
AS
Select * from 
[dbo].[User_Details] where EmpName=@EmpName AND RoleId=@RoleId;

GO
/****** Object:  StoredProcedure [dbo].[SP_UserDetails]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UserDetails] 
				@EmpId int
AS
SELECT EmpId,ud.Is_Deleted, EmpName, r.Role_Id, r.Role_Name, EmailId, ud.Created_date,ud.Parent_Id,ud.PasswordHash
FROM User_Details ud inner Join Role r on ud.RoleId = r.Role_Id
WHERE EmpId = @EmpId 

GO
/****** Object:  StoredProcedure [dbo].[SP_View_Monthly]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_View_Monthly]
AS
BEGIN
SELECT DISTINCT TOP 12 Format(FROM_DATE, N'MMM-yyyy')AS ST_DATE,Format(TO_DATE, N'MMM-yyyy') AS End_DATE from HCR_Comp_Details
END



GO
/****** Object:  StoredProcedure [dbo].[SP_View_Quarterly]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_View_Quarterly]
AS
BEGIN
SELECT DISTINCT TOP 12 [dbo].[Fn_QuarterDate](TO_DATE) AS To_DATE,[dbo].[Fn_QuarterDate](FROM_DATE) as From_Date from HCR_Comp_Details
END



GO
/****** Object:  StoredProcedure [dbo].[SP_View_Weekly]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_View_Weekly]
AS
BEGIN
SELECT DISTINCT TOP 12 TO_DATE,FROM_DATE from HCR_Comp_Details order by TO_DATE

END

GO
/****** Object:  StoredProcedure [dbo].[SP_ViewData_Compare]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ViewData_Compare] 
@vDmID INT=null,
@vDmVlID INT,
@vAccID INT=NULL,
@vFrom_DT varchar(max),
@vTO_DT varchar(max)
AS
BEGIN

CREATE TABLE #HCR_Comp_Details(EMP_ID INT,[EmpName] [varchar](max) NULL, COMMENT VARCHAR(MAX),FROM_DATE DATETIME, TO_DATE DATETIME,POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), [EndClient_GroupID] [varchar](max) NULL,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX),[HR_Level] [varchar](max) NULL,[Emp_Status_Ind] [int] NULL,[Del_Unit] [varchar](max) NULL,[EndClient_Id] [varchar](100) NULL,[Location] [varchar](max) NULL,[Qrtr_Inf] [varchar](max) NULL,[Change_Category] [varchar](100) NULL)

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END

;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records For Next Run Of SP*/
DELETE FROM #HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 
						
					IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                    END
                    ELSE
                        SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                    IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                    BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                    END
                    ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
						
						--New Joiner
						IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)),' | ' + Qrtr_Inf FROM #TEMP
							WHERE Date = @vTO_DT AND Employee_Id =@vEmpId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc,HCD.Del_Unit=HCD.Delivery_Unit,HCD.Location=HD.POS FROM #HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vTO_DT
						END
						--Resigned Employee
						ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
						BEGIN
							INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
							SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf+' | ' FROM #TEMP
							WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId

							UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc,HCD.Del_Unit=HCD.Delivery_Unit,HCD.Location=HD.POS FROM #HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vFrom_DT
						END
						
                        ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                           BEGIN
                                  
                                  DECLARE Inner_Cursor CURSOR LOCAL FOR
                                         SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
										 SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                                  OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										 /*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										 IF(@_vCol_Name = 'Grade_Desc')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'POS')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END 
										 IF(@_vCol_Name = 'Delivery_Unit')
										 BEGIN
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										 END 

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Delivery_Unit','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                                IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                                BEGIN
													IF(@_vCol_Name = 'Grade_Desc')
													BEGIN
														IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
														BEGIN
															SET @_vComment+=',Promotion'
															SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
														END
														ELSE
														BEGIN
															SET @_vComment+=''
															SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
														END

													END
													IF(@_vCol_Name = 'POS')
													BEGIN
														SET @_vComment+=',Shore Movement'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
													END

                                                       SET @_vUpdColQuery+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
					 SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))
					 
					 IF((SELECT CHARINDEX(',',@_vComment))>0)
						SET @_vComment=''
					 SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
					 IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
						SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM #HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
					 BEGIN
                           INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						   EXEC(@_vUpdColQuery)
						   EXEC(@_vUpdColQuery1)
					 END
                     


                     /*Reset Temp Variables*/
                     SET @_vUpdColQuery = ''
					 SET @_vUpdColQuery1 = ''
					 SET @_vComment = ''
					 SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
			  
			  /* Deleting Duplicate Records*/
				;WITH DEL_CTE AS(
				SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
					RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
				FROM #HCR_Comp_Details
				)
				DELETE FROM DEL_CTE WHERE RN > 1
				
				
IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
	BEGIN
		IF (@vAccID IS NULL AND @vDmID IS NULL)
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
		END
		IF (@vAccID IS NOT NULL AND @vDmID IS NULL)
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
		END
		IF (@vAccID IS NULL AND @vDmID IS NOT NULL)
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
		END
		IF (@vAccID IS NOT NULL AND @vDmID IS NOT NULL)
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND DM_Empno=@vDmID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND VL_Empno=@vDmID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
		END
	END
	
ELSE
	BEGIN 
		IF (@vAccID IS NULL AND @vDmID IS NULL)
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmVlID 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmVlID 
		END
		ELSE IF(@vAccID IS NOT NULL )
		BEGIN
			SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND EndClient_GroupID=@vAccID 
			UNION
			SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND EndClient_GroupID=@vAccID 
		END
				  
	END	  
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ViewData_Compare_New]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ViewData_Compare_New]
@vDmVlID INT,
@vDmID INT,
@vAccID INT=NULL,
@vFrom_DT VARCHAR(MAX)=NULL,
@vTO_DT VARCHAR(MAX)=NULL,
@vDateType INT/*1=Weekly, 2=Monthly, 3=Quarterly*/
AS
BEGIN

IF(@vFrom_DT IS NULL AND @vTO_DT IS NULL)
BEGIN
	SET @vTO_DT =SUBSTRING((SELECT FORMAT(MAX(Date),'yyyy-MM-dd') FROM HCR_Data),1,10)
	SET @vFrom_DT =SUBSTRING((SELECT FORMAT(MAX(Date),'yyyy-MM-dd') FROM HCR_Data WHERE Date < @vTO_DT),1,10)
END
ELSE
BEGIN
	SET @vFrom_DT = (SELECT dbo.Fn_GetDate(@vDateType,@vFrom_DT))
	SET @vTO_DT   = (SELECT dbo.Fn_GetDate(@vDateType,@vTO_DT))
END
CREATE TABLE #HCR_Comp_Details(EMP_ID INT,[EmpName] [varchar](max) NULL, COMMENT VARCHAR(MAX),FROM_DATE VARCHAR(10), TO_DATE VARCHAR(10),POS VARCHAR(MAX), Work_Alloc VARCHAR(MAX), Bill_Alloc VARCHAR(MAX), Grade_Desc VARCHAR(MAX), Delivery_Unit VARCHAR(MAX), Prj_Num VARCHAR(MAX),Prj_Name VARCHAR(MAX), [EndClient_GroupID] [varchar](max) NULL,EndClient_GroupName VARCHAR(MAX), Category VARCHAR(MAX),DM_Empno VARCHAR(MAX),VL_Empno VARCHAR(MAX),[HR_Level] [varchar](max) NULL,[Emp_Status_Ind] [int] NULL,[Del_Unit] [varchar](max) NULL,[EndClient_Id] [varchar](100) NULL,[Location] [varchar](max) NULL,[Qrtr_Inf] [varchar](max) NULL,[Change_Category] [varchar](100) NULL)

DECLARE @vEmpId INT,@vPrj_Num INT,@vEmpName VARCHAR(500)
DECLARE @_vOldValue VARCHAR(MAX)=''
DECLARE @_vNewValue VARCHAR(MAX)=''
DECLARE @_vDyn NVARCHAR(MAX)=NULL
DECLARE @_vUpdColQuery NVARCHAR(MAX)=''
DECLARE @_vUpdColQuery1 NVARCHAR(MAX)=''
DECLARE @_vCol_Name VARCHAR(100),@_vComment VARCHAR(100)='',@_vChange_Cat VARCHAR(100)=''

/*Capturing Data Which Has Some Change And Present On Both Dates*/
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
BEGIN
       DROP TABLE #TEMP
END
IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL
BEGIN
       DROP TABLE #TEMP1
END

IF(@vDateType = 1)
BEGIN
;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE DATE=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  DATE BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,
HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,
HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vFrom_DT

INSERT INTO #TEMP
SELECT HCR_Data.Date,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,
HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,
HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE Date BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND Date = @vTO_DT

/*Deleting Old Records Of Same Date Range For Next Run Of SP*/
DELETE FROM #HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP WHERE Date BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 

				IF OBJECT_ID('tempdb..#currentData') IS NOT NULL
                BEGIN
                    TRUNCATE TABLE #currentData
                    INSERT INTO #currentData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                END
                ELSE
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData FROM #TEMP WHERE  Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                IF OBJECT_ID('tempdb..#prevData') IS NOT NULL
                BEGIN
                    TRUNCATE TABLE #prevData
                    INSERT INTO #prevData 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num
                END
                ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData FROM #TEMP WHERE Employee_Id = @vEmpId AND Date = @vFrom_DT  AND Prj_Num = @vPrj_Num

				--New Joiner
				IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
				BEGIN
				INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
				SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)), Qrtr_Inf FROM #TEMP
				WHERE Date = @vTO_DT AND Employee_Id =@vEmpId

				UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM #HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vTO_DT
				END
				--Resigned Employee
				ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId)
				BEGIN
				INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
				SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf FROM #TEMP
				WHERE Date = @vFrom_DT AND Employee_Id =@vEmpId

				UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM #HCR_Comp_Details HCD INNER JOIN #TEMP HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE HD.Date = @vFrom_DT
				END

                ELSE IF EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP WHERE Date = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                    BEGIN
                                  
                            DECLARE Inner_Cursor CURSOR LOCAL FOR
                                    SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
									SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                            OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										/*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										IF(@_vCol_Name = 'Grade_Desc')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 
										IF(@_vCol_Name = 'POS')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 
										IF(@_vCol_Name = 'Delivery_Unit')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Delivery_Unit','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                            IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                            BEGIN
												IF(@_vCol_Name = 'Grade_Desc')
												BEGIN
													IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
													BEGIN
														SET @_vComment+=',Promotion'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
													END
													ELSE
													BEGIN
														SET @_vComment+=''
														SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
													END
												END
												IF(@_vCol_Name = 'POS')
												BEGIN
													SET @_vComment+=',Shore Movement'
													SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
												END

                                                    SET @_vUpdColQuery+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
							SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))

							IF((SELECT CHARINDEX(',',@_vComment))>0)
							SET @_vComment=''
							SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
							IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
							SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM #HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
						BEGIN
 					      INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						  EXEC(@_vUpdColQuery)
						  EXEC(@_vUpdColQuery1)
						END

						/*Reset Temp Variables*/
                        SET @_vUpdColQuery = ''
						SET @_vUpdColQuery1 = ''
						SET @_vComment = ''
						SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
END
ELSE IF(@vDateType IN(2,3))
BEGIN
;WITH CTE
AS
(
SELECT Employee_Id, Prj_Num FROM
(
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7)=@vFrom_DT
UNION
SELECT Employee_Id,EmpName,Prj_Num,Prj_Name,Grade_Desc,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,Category,Category_1 FROM HCR_Data WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7)=@vTO_DT
) TAB GROUP BY Employee_Id, Prj_Num HAVING COUNT(*)>1
)

SELECT HCR_Data.DATE,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,
HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,HCR_Data.DM_Empno,HCR_Data.VL_Empno,
HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
INTO #TEMP1
FROM HCR_Data INNER JOIN CTE ON HCR_Data.Employee_Id=CTE.Employee_Id AND HCR_Data.Prj_Num=CTE.Prj_Num
WHERE  LEFT(FORMAT(Date,'yyyy-MM-dd'),7) BETWEEN @vFrom_DT and @vTO_DT
ORDER BY Employee_Id,Prj_Num

/*Capturing Single Records In The Given Time Frame*/
INSERT INTO #TEMP1
SELECT HCR_Data.DATE,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,
HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,
HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT

INSERT INTO #TEMP1
SELECT HCR_Data.DATE,@vFrom_DT AS From_DT,@vTO_DT AS TO_DT,HCR_Data.Employee_Id,HCR_Data.EmpName,HCR_Data.Prj_Num,HCR_Data.Prj_Name,HCR_Data.Grade_Desc,
HCR_Data.POS,HCR_Data.Work_Alloc,HCR_Data.Bill_Alloc,HCR_Data.Delivery_Unit,HCR_Data.Category,HCR_Data.Category_1,HCR_Data.EndClient_GroupId,HCR_Data.EndClient_GroupName,
HCR_Data.DM_Empno,HCR_Data.VL_Empno,HCR_Data.EndClient_Id,HCR_Data.Qrtr_Inf
FROM HCR_Data WHERE Employee_Id IN(SELECT DISTINCT Employee_Id FROM HCR_Data
WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) BETWEEN @vFrom_DT AND @vTO_DT
GROUP BY Employee_Id,Prj_Num HAVING COUNT(*)=1)
AND LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT

/*Deleting Old Records Of Same LEFT(FORMAT(Date,'yyyy-MM-dd'),7) Range For Next Run Of SP*/
DELETE FROM #HCR_Comp_Details WHERE FROM_DATE = @vFrom_DT AND TO_DATE = @vTO_DT

DECLARE Outer_Cursor CURSOR LOCAL FOR
       SELECT DISTINCT Employee_Id,Prj_Num,EmpName FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) BETWEEN @vFrom_DT AND @vTO_DT 
       OPEN Outer_Cursor    
       
       FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
  
              WHILE @@FETCH_STATUS = 0    
              BEGIN 

				IF OBJECT_ID('tempdb..#currentData1') IS NOT NULL
                BEGIN
                    TRUNCATE TABLE #currentData1
                    INSERT INTO #currentData1 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num
                END
                ELSE
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #currentData1 FROM #TEMP1 WHERE  LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num

                IF OBJECT_ID('tempdb..#prevData1') IS NOT NULL
                BEGIN
                    TRUNCATE TABLE #prevData1
                    INSERT INTO #prevData1 
                    SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf FROM #TEMP1 WHERE Employee_Id = @vEmpId AND LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT  AND Prj_Num = @vPrj_Num
                END
                ELSE
					SELECT Employee_Id,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,EndClient_Id,Qrtr_Inf INTO #prevData1 FROM #TEMP1 WHERE Employee_Id = @vEmpId AND LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT  AND Prj_Num = @vPrj_Num

				--New Joiner
				IF EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id = @vEmpId) AND NOT EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT AND Employee_Id = @vEmpId)
				BEGIN
				INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
				SELECT Employee_Id,EmpName,' | '+Grade_Desc,Prj_Num,Prj_Name,' | '+POS,' | '+CAST(Work_Alloc AS VARCHAR(MAX)),' | '+CAST(Bill_Alloc AS VARCHAR(MAX)),' | '+Delivery_Unit,CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' | '+Category,DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,1,'','',CAST(EndClient_Id AS VARCHAR(MAX)),' | ' + Qrtr_Inf FROM #TEMP1
				WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id =@vEmpId

				UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM #HCR_Comp_Details HCD INNER JOIN #TEMP1 HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE LEFT(HD.DATE,7) = @vTO_DT
				END
				--Resigned Employee
				ELSE IF NOT EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id = @vEmpId) AND EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT AND Employee_Id = @vEmpId)
				BEGIN
				INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,Grade_Desc,Prj_Num,Prj_Name,POS,Work_Alloc,Bill_Alloc,Delivery_Unit,EndClient_GroupID,EndClient_GroupName,Category,DM_Empno,VL_Empno,FROM_DATE,TO_DATE,Emp_Status_Ind,COMMENT,Change_Category,EndClient_Id,Qrtr_Inf)
				SELECT Employee_Id,EmpName,Grade_Desc+' | ',Prj_Num,Prj_Name,' '+POS+' | ',' '+CAST(Work_Alloc AS VARCHAR(MAX))+' | ',' '+CAST(Bill_Alloc AS VARCHAR(MAX))+' | ',' '+Delivery_Unit+' | ',CAST(EndClient_GroupID AS VARCHAR(MAX)),EndClient_GroupName,' '+Category+' | ',DM_Empno,VL_Empno,@vFrom_DT,@vTO_DT,0,'','',CAST(EndClient_Id AS VARCHAR(MAX)),Qrtr_Inf+' | ' FROM #TEMP1
				WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT AND Employee_Id =@vEmpId

				UPDATE HCD SET HCD.HR_Level = HD.Grade_Desc FROM #HCR_Comp_Details HCD INNER JOIN #TEMP1 HD On HCD.EMP_ID = HD.Employee_Id AND HCD.Prj_Num = HD.Prj_Num WHERE LEFT(HD.DATE,7) = @vFrom_DT
				END

                ELSE IF EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vTO_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num) AND EXISTS(SELECT 1 FROM #TEMP1 WHERE LEFT(FORMAT(Date,'yyyy-MM-dd'),7) = @vFrom_DT AND Employee_Id = @vEmpId AND Prj_Num = @vPrj_Num)
                    BEGIN
                                  
                            DECLARE Inner_Cursor CURSOR LOCAL FOR
                                    SELECT SC.name FROM SYS.TABLES ST INNER JOIN SYS.COLUMNS SC On ST.object_id = SC.object_id WHERE ST.name = 'HCR_Data' AND 
									SC.name IN('POS','Work_Alloc','Bill_Alloc','Grade_Desc','Delivery_Unit','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Category','DM_Empno','VL_Empno','EndClient_Id','Qrtr_Inf')
                            OPEN Inner_Cursor    
                                  
                                  
                                  FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
  
                                  WHILE @@FETCH_STATUS = 0    
                                  BEGIN 
										/*Comparision Logic Starts Here*/
                                         SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

                                         SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #currentData1'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(MAX) OUTPUT',@_vNewValue OUTPUT

                                         SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #prevData1'
                                         EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(MAX) OUTPUT',@_vOldValue OUTPUT
                                         
										IF(@_vCol_Name = 'Grade_Desc')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [HR_Level] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 
										IF(@_vCol_Name = 'POS')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Location] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 
										IF(@_vCol_Name = 'Delivery_Unit')
										BEGIN
										SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET [Del_Unit] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
										END 

                                         IF(@_vCol_Name IN('DM_Empno','VL_Empno','Prj_Num','Prj_Name','EndClient_GroupID','EndClient_GroupName','Delivery_Unit','Qrtr_Inf','EndClient_Id'))
											SET @_vUpdColQuery1+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(ISNULL(CAST(@_vNewValue AS VARCHAR(MAX)),CAST(@_vOldValue AS VARCHAR(MAX))),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                         ELSE
                                         BEGIN
                                            IF(@_vNewValue != @_vOldValue AND LEN(@_vOldValue)>0 )
                                            BEGIN
												IF(@_vCol_Name = 'Grade_Desc')
												BEGIN
													IF((SELECT dbo.udf_GetNumeric(@_vNewValue))>(SELECT dbo.udf_GetNumeric(@_vOldValue)))
													BEGIN
														SET @_vComment+=',Promotion'
														SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Promotion') AS VARCHAR(10))
													END
													ELSE
													BEGIN
														SET @_vComment+=''
														SET @_vChange_Cat+=','+ CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Others') AS VARCHAR(10))
													END
												END
												IF(@_vCol_Name = 'POS')
												BEGIN
													SET @_vComment+=',Shore Movement'
													SET @_vChange_Cat+=',' + CAST((Select Change_Id from HCR_Change_Category Where Change_Category = 'Shore Movement') AS VARCHAR(10))
												END

                                                    SET @_vUpdColQuery+='UPDATE #HCR_Comp_Details SET ['+@_vCol_Name+'] = '''+REPLACE(CAST(@_vOldValue AS VARCHAR(MAX))+' | '+CAST(@_vNewValue AS VARCHAR(MAX)),CHAR(39),'''''')+''' WHERE EMP_ID = '+CAST(@vEmpId AS VARCHAR)+' AND Prj_Num = '+CAST(@vPrj_Num AS VARCHAR)+CHAR(13)
                                                END
                                         END

                                         FETCH NEXT FROM Inner_Cursor INTO @_vCol_Name
                                  END
       
                                  CLOSE Inner_Cursor;    
                                  DEALLOCATE Inner_Cursor;
                                  IF CURSOR_STATUS('global','Inner_Cursor')>=-1
                                  BEGIN
                                            DEALLOCATE Inner_Cursor
                                  END
                                  
                           END
                     
							SET @_vComment = SUBSTRING(@_vComment,2,LEN(@_vComment))

							IF((SELECT CHARINDEX(',',@_vComment))>0)
							SET @_vComment=''
							SET @_vChange_Cat = SUBSTRING(@_vChange_Cat,2,LEN(@_vChange_Cat))
							IF((SELECT CHARINDEX(',',@_vChange_Cat))>0)
							SET @_vChange_Cat=''

                     IF((SELECT CHARINDEX(CAST(@vEmpId AS VARCHAR(500)),@_vUpdColQuery))>0 AND NOT EXISTS(SELECT 1 FROM #HCR_Comp_Details WHERE EMP_ID = @vEmpId AND Prj_Num = @vPrj_Num AND TO_DATE = @vTO_DT))
						BEGIN
 					      INSERT INTO #HCR_Comp_Details(EMP_ID,EmpName,COMMENT,FROM_DATE,TO_DATE,Prj_Num,Emp_Status_Ind,Change_Category)VALUES(@vEmpId,@vEmpName,@_vComment,@vFrom_DT,@vTO_DT,@vPrj_Num,2,@_vChange_Cat)
						  EXEC(@_vUpdColQuery)
						  EXEC(@_vUpdColQuery1)
						END

						/*Reset Temp Variables*/
                        SET @_vUpdColQuery = ''
						SET @_vUpdColQuery1 = ''
						SET @_vComment = ''
						SET @_vChange_Cat=''

                     FETCH NEXT FROM Outer_Cursor INTO @vEmpId,@vPrj_Num,@vEmpName
                     
              END
              CLOSE Outer_Cursor
              DEALLOCATE Outer_Cursor
              IF CURSOR_STATUS('global','Outer_Cursor')>=-1
              BEGIN
				DEALLOCATE Outer_Cursor
              END
END


			/* Deleting Duplicate Records*/
			;WITH DEL_CTE AS(
			SELECT EMP_ID,EmpName,Prj_Num,Prj_Name,FROM_DATE,TO_DATE,
			RN = ROW_NUMBER()OVER(PARTITION BY EMP_ID,Prj_Num,FROM_DATE,TO_DATE ORDER BY EMP_ID,Prj_Num)
			FROM #HCR_Comp_Details
			)
			DELETE FROM DEL_CTE WHERE RN > 1

			--SELECT * FROM #HCR_Comp_Details
			--/*
			IF EXISTS (SELECT 1 FROM User_Details WHERE Parent_Id=@vDmVlID) 
			BEGIN
				IF (@vAccID IS NULL AND @vDmID IS NULL )
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				END
				IF (@vAccID IS NOT NULL AND @vDmID IS NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				END
				IF (@vAccID IS NOT NULL AND @vDmID IS NOT NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND @vDmID=DM_Empno AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE EndClient_GroupID=@vAccID AND @vDmID=VL_Empno AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				END
				IF (@vAccID IS NULL AND @vDmID IS NOT NULL )
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE @vDmID=DM_Empno AND DM_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE @vDmID=VL_Empno AND VL_Empno IN(SELECT DISTINCT EmpId from User_Details where Parent_Id=@vDmVlID) 
				END
			END
			ELSE
			BEGIN 
				IF (@vAccID IS NULL AND @vDmID IS NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmVlID 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmVlID 
				END
				IF (@vAccID IS NULL AND @vDmID IS NOT NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmID 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmID 
				END
				IF (@vAccID IS NOT NULL AND @vDmID IS NOT NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmID AND EndClient_GroupID=@vAccID 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmID AND EndClient_GroupID=@vAccID 
				END
				ELSE IF(@vAccID IS NOT NULL AND @vDmID IS NULL)
				BEGIN
				SELECT * FROM #HCR_Comp_Details WHERE DM_Empno=@vDmVlID AND EndClient_GroupID=@vAccID 
				UNION
				SELECT * FROM #HCR_Comp_Details WHERE VL_Empno=@vDmVlID AND EndClient_GroupID=@vAccID 
				END
 
			END  
			--*/
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_DateSortYYYYMMDD]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_DateSortYYYYMMDD](@vDate Date) --@vDate --> TO_DATE cell values(HCR_Comp_Details Table)
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @vDateSort VARCHAR(10)

    SET @vDateSort=(SELECT FORMAT(@vDate,'yyyyMMdd')) 
    
    RETURN @vDateSort
END

GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_GetDate](@vDateType INT,@vDate VARCHAR(10))
RETURNS VARCHAR(10) AS
BEGIN
	IF(@vDateType = 1) /*1 = Weekly Dates*/
		SET @vDate = (SELECT FORMAT(CAST(@vDate AS DATE),'yyyy-MM-dd'))
	IF(@vDateType = 2) /*2 = Monthly Dates*/
		SET @vDate = (SELECT RIGHT(@vDate,4)+'-'+
						CAST(CASE
							WHEN UPPER(LEFT(@vDate,3)) = 'JAN' THEN '01' 
							WHEN UPPER(LEFT(@vDate,3)) = 'FEB' THEN '02'
							WHEN UPPER(LEFT(@vDate,3)) = 'MAR' THEN '03'
							WHEN UPPER(LEFT(@vDate,3)) = 'APR' THEN '04'
							WHEN UPPER(LEFT(@vDate,3)) = 'MAY' THEN '05'
							WHEN UPPER(LEFT(@vDate,3)) = 'JUN' THEN '06'
							WHEN UPPER(LEFT(@vDate,3)) = 'JUL' THEN '07'
							WHEN UPPER(LEFT(@vDate,3)) = 'AUG' THEN '08'
							WHEN UPPER(LEFT(@vDate,3)) = 'SEP' THEN '09'
							WHEN UPPER(LEFT(@vDate,3)) = 'OCT' THEN '10'
							WHEN UPPER(LEFT(@vDate,3)) = 'NOV' THEN '11'
							WHEN UPPER(LEFT(@vDate,3)) = 'DEC' THEN '12'
							END AS VARCHAR(2)))
	IF(@vDateType = 3) /*3 = Quartly Dates*/
		SET @vDate = (SELECT SUBSTRING(@vDate,3,4)+'-'+
						CAST(CASE
							WHEN RIGHT(@vDate,2) = 'Q1' THEN '01' 
							WHEN RIGHT(@vDate,2) = 'Q2' THEN '04'
							WHEN RIGHT(@vDate,2) = 'Q3' THEN '07'
							WHEN RIGHT(@vDate,2) = 'Q4' THEN '10' END AS VARCHAR(2)))

RETURN @vDate

END;


GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetMonthNo]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

CREATE FUNCTION [dbo].[Fn_GetMonthNo](@vDate VARCHAR(10))

RETURNS VARCHAR(10)

AS

BEGIN

 

       DECLARE @MonthName varchar(15)

       DECLARE @MonthNo varchar(2)

      

       SET @MonthName = @vDate

       SET @MonthNo = MONTH(CAST('01-' + @MonthName  AS datetime))

       SET @MonthNo =  case when len(@MonthNo)= 1 then '0' + @MonthNo else @MonthNo End

       SET @MonthName = REPLACE(@MonthName, substring(@MonthName,1,3),@MonthNo)

      

       RETURN @MonthName

END

 


GO
/****** Object:  UserDefinedFunction [dbo].[Fn_QuarterDate]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_QuarterDate](@vDate Date)
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @QrtDate VARCHAR(100)

	SELECT
	@QrtDate=
    CASE
        WHEN MONTH(@vDate) BETWEEN 1  AND 3  THEN 'FY' + convert(char(4), YEAR(@vDate) + 0)+'-Q4'
        WHEN MONTH(@vDate) BETWEEN 4  AND 6  THEN 'FY' + convert(char(4), YEAR(@vDate) + 1)+'-Q1'
        WHEN MONTH(@vDate) BETWEEN 7  AND 9  THEN 'FY' + convert(char(4), YEAR(@vDate) + 1)+'-Q2'
        WHEN MONTH(@vDate) BETWEEN 10 AND 12 THEN 'FY' + convert(char(4), YEAR(@vDate) + 1)+'-Q3'
    END
	RETURN @QrtDate
END

GO
/****** Object:  UserDefinedFunction [dbo].[Fn_QuarterDateFY]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_QuarterDateFY](@vDate Date)
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @QrtDate VARCHAR(100)

	SELECT
	@QrtDate=
    CASE
        WHEN MONTH(@vDate) BETWEEN 1  AND 3  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q4'
        WHEN MONTH(@vDate) BETWEEN 4  AND 6  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q1'
        WHEN MONTH(@vDate) BETWEEN 7  AND 9  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q2'
        WHEN MONTH(@vDate) BETWEEN 10 AND 12 THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q3'
    END
	RETURN @QrtDate
END

GO
/****** Object:  UserDefinedFunction [dbo].[Fn_QuarterDateFY_New]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_QuarterDateFY_New](@vDate Date)
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @QrtDate VARCHAR(100)

	SELECT
	@QrtDate=
    CASE
        WHEN MONTH(@vDate) BETWEEN 1  AND 3  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q4-'+ convert(char(4),  MONTH(@vDate) - 0)
        WHEN MONTH(@vDate) BETWEEN 4  AND 6  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q1-'+ convert(char(4),  MONTH(@vDate) - 0)
        WHEN MONTH(@vDate) BETWEEN 7  AND 9  THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q2-'+ convert(char(4),  MONTH(@vDate) - 0)
        WHEN MONTH(@vDate) BETWEEN 10 AND 12 THEN 'FY' + convert(char(4), YEAR(@vDate) - 0)+'-Q3-'+ convert(char(4),  MONTH(@vDate) - 0)
    END
	RETURN @QrtDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_RowColor]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_RowColor](@vIndex int) --@vIndex --> Emp_Status_Ind cell values(HCR_Comp_Details Table)
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @vRowColor VARCHAR(10)

	if(@vIndex=1)
		SET @vRowColor='#FFEC8D' --orange
    else if(@vIndex=2)
		SET @vRowColor='#9cd49c' --green
	else SET @vRowColor='#FFFFFF' --white
    RETURN @vRowColor
END

GO
/****** Object:  UserDefinedFunction [dbo].[Fn_SplitDelimetedData]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fn_SplitDelimetedData](@vDelimeter Char(1), @vInputString AS Varchar(8000) )
RETURNS
      @Result TABLE(Value VARCHAR(8000))
AS

BEGIN

      DECLARE @str VARCHAR(8000)

      DECLARE @ind Int

      IF(@vInputString is not null)

      BEGIN

            SET @ind = CharIndex(@vDelimeter,@vInputString)

            WHILE @ind > 0

            BEGIN

                  SET @str = SUBSTRING(@vInputString,1,@ind-1)

                  SET @vInputString = SUBSTRING(@vInputString,@ind+1,LEN(@vInputString)-@ind)

                  INSERT INTO @Result values (@str)

                  SET @ind = CharIndex(@vDelimeter,@vInputString)

            END

            SET @str = @vInputString

            INSERT INTO @Result values (@str)

      END

      RETURN

END






GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetNumeric]    Script Date: 7/14/2020 3:58:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_GetNumeric]
(
  @strAlphaNumeric VARCHAR(256)
)
RETURNS INT
AS
BEGIN
  DECLARE @intAlpha INT
  SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
  BEGIN
    WHILE @intAlpha > 0
    BEGIN
      SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
      SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
    END
  END
  RETURN ISNULL(@strAlphaNumeric,0)
END

GO
