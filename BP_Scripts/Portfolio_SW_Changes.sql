/****** Object:  StoredProcedure [dbo].[Sp_AddWTPortfolioDetails]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_AddWTPortfolioDetails]
	@vPortfolio_Name varchar(500), 
	@vPortfolio_Desc varchar(8000) ,
	@vDescend_From varchar(max) ,
	@vWT_Codes varchar(1000),
	@vStatus_Ids varchar(1000),
	@vStatus_Change_Id int,
	@vStatus_Change_Period_Id int,
	@vStatus_Change_StartDate datetime,
	@vStatus_Change_EndDate datetime,
	@vProject_Leads varchar(8000),
	@vTeam_Members varchar(8000),
	@vSponsors varchar(8000),
	@vFinancialReps varchar(8000),
	@vApprovers varchar(8000),
	@vProject_StartDate_Period_Id int,
	@vProject_Start_StartDate datetime,
	@vProject_Start_EndDate datetime,
	@vProject_EndDate_Period_Id int,
	@vProject_End_StartDate datetime,
	@vProject_End_EndDate datetime,
	@vDescend_From_User_DefaultLoc char(1),
	@vArchived_Projects char(1),
	@vBP_Projects char(1),
	@vReplace_Program_By_Memebr char(1),
	@vEdit_By_Sharees char(1),
	@vInclude_Projects varchar(8000),
	@vExclude_Projects varchar(8000),
	@vInclude_Copied_Projects CHAR(1),
	@vInclude_Replicated_Projects CHAR(1),
	@vPortfolio_Tags varchar(max),
	@vPortfolio_Share_People varchar(max),
	@vPortfolio_Share_Facility varchar(max),
	@vPortfolio_Advance_Criteria varchar(max),
	@vIs_Deleted_Ind char(1),
	@vCreated_By varchar(10),
	@vLast_Modified_By varchar(10),
	@vPortfolio_Id int OUT,
	@vMsg_Out VARCHAR(100) OUT


AS
BEGIN

DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRMSepPos INT=0
DECLARE @_vRMSepPosSc INT=0

DECLARE @_vTabDescendFrom As TABLE(id INT Identity(1,1), DescendFrom VARCHAR(8000))
DECLARE @_vDescendFrom VARCHAR(8000)=NULL
DECLARE @_vRegion_Code VARCHAR(5)=NULL
DECLARE @_vCountry_Code CHAR(3)=NULL
DECLARE @_vLocation_Id INT=Null


DECLARE @_vTabPortfolioTags TABLE(id INT Identity(1,1), Tags VARCHAR(8000))
DECLARE @_vPortfolioTag_Id INT=0
DECLARE @_vTag_Values VARCHAR(8000)=NULL
DECLARE @_vPF_Tags VARCHAR(8000)=NULL


DECLARE @_vTabPortfolioShare TABLE(id INT Identity(1,1), ShareWithValue VARCHAR(8000))
DECLARE @_vShare_Type_Id INT=0
DECLARE @_vShare_With_Values VARCHAR(8000)=NULL
DECLARE @_vPF_ShareValues VARCHAR(8000)=NULL

DECLARE @_vTabPortfolioAFC TABLE(id INT Identity(1,1), AFC VARCHAR(8000))
DECLARE @_vCriteria_Id VARCHAR(8000)=NULL
DECLARE @_vFilterValue VARCHAR(8000)=NULL

BEGIN TRAN


			INSERT INTO GPM_WT_Portfolio
				(
					Portfolio_Name,
					Portfolio_Desc ,
					WT_Codes,
					Status_Ids,
					Status_Change_Id,
					Status_Change_Period_Id ,
					Status_Change_StartDate ,
					Status_Change_EndDate ,
					Project_Leads,
					Team_Members,
					Sponsors,
					FinancialReps,
					Approvers,
					Project_StartDate_Period_Id ,
					Project_Start_StartDate ,
					Project_Start_EndDate ,
					Project_EndDate_Period_Id ,
					Project_End_StartDate ,
					Project_End_EndDate,
					Descend_From_User_DefaultLoc,
					Archived_Projects ,
					BP_Projects,
					Replace_Program_By_Memebr,
					Edit_By_Sharees ,
					Include_Projects,
					Exclude_Projects,
					Include_Copied_Project,
					Include_Replicated_Project,
					Is_Deleted_Ind ,
					Created_By ,
					Created_Date ,
					Last_Modified_By,
					Last_Modified_Date
				)
			VALUES
				(
					@vPortfolio_Name,
					@vPortfolio_Desc ,
					@vWT_Codes,
					@vStatus_Ids,
					@vStatus_Change_Id,
					@vStatus_Change_Period_Id ,
					@vStatus_Change_StartDate ,
					@vStatus_Change_EndDate ,
					@vProject_Leads,
					@vTeam_Members,
					@vSponsors,
					@vFinancialReps,
					@vApprovers,
					@vProject_StartDate_Period_Id ,
					@vProject_Start_StartDate ,
					@vProject_Start_EndDate ,
					@vProject_EndDate_Period_Id ,
					@vProject_End_StartDate ,
					@vProject_End_EndDate,
					@vDescend_From_User_DefaultLoc,
					@vArchived_Projects ,
					@vBP_Projects,
					@vReplace_Program_By_Memebr,
					@vEdit_By_Sharees ,
					@vInclude_Projects,
					@vExclude_Projects,
					@vInclude_Copied_Projects,
					@vInclude_Replicated_Projects,
					'N',
					@vCreated_By ,
					Getdate(),
					@vLast_Modified_By,
					Getdate()
				)

			IF (@@ERROR <> 0) GOTO ERR_HANDLER

			SELECT @vPortfolio_Id=@@IDENTITY

			IF(LEN(LTRIM(RTRIM(@vDescend_From)))>0)
			INSERT INTO @_vTabDescendFrom(DescendFrom)
			SELECT 	Tab.Value
					FROM Fn_SplitDelimetedData('~',@vDescend_From) Tab
					WHERE Len(RTRIM(LTRIM(Value)))>0

				
				IF((SELECT COUNT(*) FROM @_vTabDescendFrom)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabDescendFrom

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vRegion_Code=NULL,
										@_vCountry_Code=NULL,
										@_vLocation_Id=NULL

								SELECT @_vDescendFrom=DescendFrom FROM @_vTabDescendFrom WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vDescendFrom,1)
								SELECT @_vRMSepPosSc=CHARINDEX('|',@_vDescendFrom,@_vRMSepPos+1)								


								SELECT @_vRegion_Code=RTRIM(LTRIM(SUBSTRING(@_vDescendFrom,1, @_vRMSepPos-1)))

								IF(LEN(LTRIM(RTRIM(@_vRegion_Code)))<=0)
								SELECT @_vRegion_Code=NULL

								SELECT @_vCountry_Code =SUBSTRING(@_vDescendFrom,@_vRMSepPos+1, @_vRMSepPosSc-(@_vRMSepPos+1))

								IF(LEN(LTRIM(RTRIM(@_vCountry_Code)))<=0)
								SELECT @_vCountry_Code=NULL
									
								SELECT @_vLocation_Id =CAST(SUBSTRING(@_vDescendFrom,@_vRMSepPosSc+1, len(@_vDescendFrom)) AS INT)

								SELECT @_vLocation_Id=CASE WHEN @_vLocation_Id=0 THEN NULL ELSE @_vLocation_Id END 

								IF NOT(@_vRegion_Code IS NULL AND @_vCountry_Code IS NULL AND @_vLocation_Id IS NULL)
								INSERT INTO GPM_WT_Portfolio_DescendFrom
									(
										Portfolio_Id,
										Region_Code,
										Country_Code,
										Location_ID 
									)
								Values
									(
										@vPortfolio_Id,
										@_vRegion_Code,
										@_vCountry_Code,
										@_vLocation_Id 
									)

										IF (@@ERROR <> 0) GOTO ERR_HANDLER

							SELECT @_vCnt=MIN(id) FROM @_vTabDescendFrom WHERE id>@_vCnt
						END
					END


					

					IF(LEN(@vPortfolio_Tags)>0)
					BEGIN
						INSERT INTO @_vTabPortfolioTags(Tags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vPortfolio_Tags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabPortfolioTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioTags

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPF_Tags=Tags FROM @_vTabPortfolioTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPF_Tags,1)
								SELECT @_vPortfolioTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPF_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vTag_Values=SUBSTRING(@_vPF_Tags,@_vRMSepPos+1, len(@_vPF_Tags))

								
								INSERT INTO GPM_WT_Portfolio_Tag_Value
								(
									Portfolio_Id,
									Portfolio_Tag_Id,
									Portfolio_Tag_Value,
									Created_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vPortfolio_Id,
									@_vPortfolioTag_Id,
									@_vTag_Values,
									@vCreated_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								)
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioTags WHERE id>@_vCnt
							END

						END
					END

					
					IF(LEN(RTRIM(LTRIM(@vPortfolio_Share_People)))>0)
					INSERT INTO @_vTabPortfolioShare(ShareWithValue) VALUES(@vPortfolio_Share_People)


					IF(LEN(@vPortfolio_Share_Facility)>0)
					BEGIN
						INSERT INTO @_vTabPortfolioShare(ShareWithValue)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vPortfolio_Share_Facility) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabPortfolioShare)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioShare

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPF_ShareValues=ShareWithValue FROM @_vTabPortfolioShare WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPF_ShareValues,1)
								SELECT @_vShare_Type_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPF_ShareValues,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vShare_With_Values=SUBSTRING(@_vPF_ShareValues,@_vRMSepPos+1, len(@_vPF_ShareValues))

								
								INSERT INTO GPM_WT_Portfolio_Sharing
								(
									Portfolio_Id,
									Share_Type_Id,
									Share_With_Values,
									Share_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT
									@vPortfolio_Id,
									@_vShare_Type_Id,
									Tab.Value,
									@vCreated_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								FROM Fn_SplitDelimetedData(',',@_vShare_With_Values) Tab
									WHERE Len(RTRIM(LTRIM(Value)))>0

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioShare WHERE id>@_vCnt
							END

						END
					END


					IF(LEN(LTRIM(RTRIM(@vPortfolio_Advance_Criteria)))>0)
						INSERT INTO @_vTabPortfolioAFC(AFC)
						SELECT 	Tab.Value
								FROM Fn_SplitDelimetedData('~',@vPortfolio_Advance_Criteria) Tab
								WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0
					IF((SELECT COUNT(*) FROM @_vTabPortfolioAFC)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioAFC

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN
									SELECT @vPortfolio_Advance_Criteria=AFC FROM @_vTabPortfolioAFC WHERE id=@_vCnt

									SELECT @_vRMSepPos=CHARINDEX('|',@vPortfolio_Advance_Criteria,1)
				
									SELECT @_vCriteria_Id=RTRIM(LTRIM(SUBSTRING(@vPortfolio_Advance_Criteria,1, @_vRMSepPos-1)))

									SELECT @_vFilterValue =SUBSTRING(@vPortfolio_Advance_Criteria,@_vRMSepPos+1, LEN(@vPortfolio_Advance_Criteria))
							
									--SELECT @_vFilterValue=CASE WHEN @_vCriteria_Id=10 THEN 0 ELSE 1 END 

									IF NOT(@vPortfolio_Id IS NULL AND @_vCriteria_Id IS NULL AND @_vFilterValue IS NULL)
									INSERT INTO GPM_WT_Portfolio_Advance_Filter
										(
											Portfolio_Id,
											Criteria_Id,
											Filter_Value
										)
									Values
										(
											@vPortfolio_Id,
											@_vCriteria_Id,
											@_vFilterValue 
										)	

									IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioAFC WHERE id>@_vCnt
								END
							END
				 
				 IF((LEN(RTRIM(LTRIM(@vPortfolio_Share_People)))>0 OR LEN(RTRIM(LTRIM(@vPortfolio_Share_Facility)))>0) AND @vPortfolio_Share_Facility!='~')
					BEGIN
						
						DECLARE @_vShareWithString VARCHAR(MAX)= @vPortfolio_Share_People +'~'+ @vPortfolio_Share_Facility
						
						DECLARE	@_vShared_UserList VARCHAR(MAX)
						EXEC	[Sp_GetUserList_ByShareWithString]
								@vSharewith =@_vShareWithString,
								@vUserList = @_vShared_UserList OUTPUT
						
						IF(LEN(RTRIM(LTRIM(@_vShared_UserList)))>0 OR ISNULL(@_vShared_UserList,'Y')!='Y')
							INSERT INTO GPM_WT_Portfolio_Visibility VALUES(@vPortfolio_Id,@_vShared_UserList)
						

						IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END
				
			SELECT @vMsg_Out =' Portfolio Added Successfully'
	COMMIT TRAN
	RETURN 1
			
	ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Add Portfolio Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
			
END










GO
/****** Object:  StoredProcedure [dbo].[Sp_DelPortfolio]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_DelPortfolio]
@vPortfolio_Id INT,
@vLast_Modified_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN

IF EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id AND Is_Deleted_Ind='Y' )
	SELECT @vMsg_Out='Portfolio Already Deleted'

IF NOT EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id)
	SELECT @vMsg_Out='Portfolio To Be Deleted Not Found'
ELSE
	BEGIN
	IF EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Created_By = @vLast_Modified_By AND Portfolio_Id = @vPortfolio_Id)
		BEGIN
			UPDATE GPM_WT_Portfolio 
			SET Is_Deleted_Ind='Y', Last_Modified_By = @vLast_Modified_By, Last_Modified_Date = GETDATE()
			WHERE Portfolio_Id=@vPortfolio_Id

			DELETE FROM GPM_WT_Portfolio_Visibility WHERE Portfolio_Id=@vPortfolio_Id
			DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id

			SELECT @vMsg_Out='Portfolio Deleted Successfully'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Portfolio_Visibility WHERE User_List  = @vLast_Modified_By AND Portfolio_Id=@vPortfolio_Id)
		BEGIN
			DELETE FROM GPM_WT_Portfolio_Visibility WHERE Portfolio_Id=@vPortfolio_Id
			DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Portfolio Deleted Successfully For Shared User'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Portfolio_Visibility WHERE User_List LIKE '%'+@vLast_Modified_By+',%' AND Portfolio_Id=@vPortfolio_Id)
		BEGIN
			UPDATE GPM_WT_Portfolio_Visibility SET User_List = REPLACE(User_List,@vLast_Modified_By+',','') WHERE Portfolio_Id=@vPortfolio_Id
			DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Portfolio Deleted Successfully For Shared User'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Portfolio_Visibility WHERE User_List LIKE '%'+@vLast_Modified_By AND Portfolio_Id=@vPortfolio_Id)
		BEGIN
			UPDATE GPM_WT_Portfolio_Visibility SET User_List = REPLACE(User_List,','+@vLast_Modified_By,'') WHERE Portfolio_Id=@vPortfolio_Id
			DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Portfolio Deleted Successfully For Shared User'
		END
	END
	
END



GO
/****** Object:  StoredProcedure [dbo].[Sp_GetDashBoardData_InvFinanceGrid]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/****** Object:  StoredProcedure [dbo].[Sp_GetDashBoardData]    Script Date: 8/12/2019 4:13:54 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE PROCEDURE [dbo].[Sp_GetDashBoardData_InvFinanceGrid]
@vPortfolio_Id INT,
@vYear CHAR(4),
@vTdcType VARCHAR(10),
@vLogin_User_Id VARCHAR(10),
@vCountry_Code CHAR(7)=NULL,
@vMsg_OUT VARCHAR(100) OUT
AS
BEGIN

--DECLARE @vPortfolio_Id INT=79
--DECLARE @vCountry_Code CHAR(7)='USA|USD'
---DECLARE @_vCurrencyCode CHAR(3)='AUD'
--DECLARE @vYearMonth CHAR(4)='2018'
--DECLARE @vTdcType VARCHAR(10)='Baseline'
--DECLARE @vLogin_User_Id VARCHAR(10) = 'A398351'
SET NOCOUNT ON
DECLARE @_vRow_ID INT
DECLARE @_vdynSql nvarchar(Max) = ''
DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vObjCnt INT=0, @_vObjMaxCnt INT=0
DECLARE @_vDummy INT=0
DECLARE @_vWT_Project_Table_Name VARCHAR(100)='GPM_WT_Project'
DECLARE @_vProjects_WT_Codes AS TABLE(WT_Code VARCHAR(10))
DECLARE @_vLocationClause VARCHAR(max)=NULL

DECLARE @_vPF_WT_Codes varchar(1000)
DECLARE @_vPF_Status_Ids VARCHAR(100)
DECLARE @_vStatus_Change_Id INT
DECLARE @_vStatus_Change_Period_Id INT
DECLARE @_vStatusChange_StartDt DATE = NULL
DECLARE @_vStatusChange_EndDt DATE = NULL
DECLARE @_vProject_StartDate_Period_Id INT
DECLARE @_vProject_Start_StartDate DATE = NULL
DECLARE @_vProject_Start_EndDate DATE = NULL
DECLARE @_vProject_EndDate_Period_Id  INT
DECLARE @_vProject_End_StartDate DATE = NULL
DECLARE @_vProject_End_EndDate DATE = NULL
DECLARE @_vProject_Leads VARCHAR(8000) = NULL
DECLARE @_vTeam_Members VARCHAR(8000) = NULL
DECLARE @_vSponsors VARCHAR(8000) = NULL
DECLARE @_vFinancialReps VARCHAR(8000) = NULL
DECLARE @_vApprovers VARCHAR(8000) = NULL
DECLARE @_vIncludeProjects VARCHAR(8000) = NULL
DECLARE @_vExcludeProjects VARCHAR(8000) = NULL
DECLARE @_vArchived_Projects CHAR(1)=NULL


DECLARE @_vRegion_Table AS TABLE (Region_Code Varchar(5), Is_Common_Region CHAR(1) DEFAULT 'N')
DECLARE @_vRegionList VARCHAR(8000)=NULL
DECLARE @_vRegion_Code varchar(5)

DECLARE @_vCountry_Table AS TABLE (Country_Code char(3), Is_Common_Country CHAR(1) DEFAULT 'N')
DECLARE @_vCountryList VARCHAR(8000)=NULL
DECLARE @_vCountry_Code char(3)

DECLARE @_vLocation_Table AS TABLE (Location_Id VARCHAR(5), Is_Common_Location CHAR(1) DEFAULT 'N')
DECLARE @_vLocationList VARCHAR(8000)=NULL
DECLARE @_vLocation_Id VARCHAR(10)

Declare @_vProcessedTag TABLE (Portfolio_Tag_Id INT)

DECLARE @_vWTQueriesTab AS TABLE(Row_ID INT IDENTITY(1,1), WT_Code VARCHAR(5), SelectField VARCHAR(MAX), SelectFrom VARCHAR(MAX), SelectWhere VARCHAR(MAX), IncludeProject CHAR(1) DEFAULT 'N')
DECLARE @_vdynSqlSelectField nvarchar(Max) = ''
DECLARE @_vdynSqlFrom nvarchar(Max) = ''
DECLARE @_vdynSqlWhere nvarchar(Max) = ''
DECLARE @_vdynSqlFinalQuery nvarchar(Max) = ''

Declare @_vTab_Dyn_SQL_Table TABLE (Row_ID INT IDENTITY(1,1), Portfolio_Tag_Id Int,WT_Table_Name varchar(100), WT_Table_FK_Col_Name varchar(100), TG_Table_Name varchar(100), TG_Table_PK_Col_Name varchar(100), Portfolio_Tag_Value varchar(8000))       
Declare @_vPortfolio_Tag_Id int
Declare @_vPortfolio_Tag_Value varchar(8000)
Declare @_vWT_Table_Name varchar(100) 
Declare @_vWT_Table_FK_Col_Name varchar(100) 
Declare @_vTG_Table_Name varchar(100)
Declare @_vTG_Table_PK_Col_Name varchar(100)



DECLARE @_vTDCType_ColPrefix VARCHAR(100)


DECLARE @_vTDCYearMonth VARCHAR(6)
DECLARE @_vMonthName VARCHAR(200)
DECLARE @_vMonthNumber CHAR(2)
DECLARE @_vQuarterStartDate DATE
DECLARE @_vWT_Table_Name_Cur varchar(100)
DECLARE @_vWT_Code_Cur  varchar(10)
DECLARE @_vBP_Portfolio_Tag_Value VARCHAR(8000)
DECLARE @_vTDC_Table_Name VARCHAR(200)


DECLARE @_vProject_Lead_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vTeam_Members_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vSponsors_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vFinancialReps_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vApprovers_Table As Table (GD_User_Id VARCHAR(10))


DECLARE @_vIncWT_Project_ID INT
DECLARE @_vIncWT_Code VARCHAR(10)
DECLARE @_vIncWT_Id INT
DECLARE @_vIncWT_Project_Number VARCHAR(15)
DECLARE @_vIncProjects_Table AS TABLE(IncWT_Project_ID INT,IncWT_Code VARCHAR(10),IncWT_Id INT,IncWT_Project_Number VARCHAR(15))


DECLARE @_vExcWT_Project_ID INT
DECLARE @_vExcWT_Code VARCHAR(10)
DECLARE @_vExcWT_Id INT
DECLARE @_vExcWT_Project_Number VARCHAR(15)
DECLARE @_vExcProjects_Table AS TABLE(ExcWT_Project_ID INT,ExcWT_Code VARCHAR(10),ExcWT_Id INT,ExcWT_Project_Number VARCHAR(15))

DECLARE @_vAdvance_Criteria_Id VARCHAR(100)--INT
DECLARE @_vFilter_Value VARCHAR(100)
DECLARE @_vAttrib_Seq INT
DECLARE @_vCurrencyCode CHAR(3)

DECLARE @_vDashBoardData_Table AS Dashboad_Data
DECLARE @_vYearMonth_Table  AS Table (YearMonth VARCHAR(7))
DECLARE @_vStartDate CHAR(6)
DECLARE @_vEndDate CHAR(6) 


IF NOT EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id AND Is_Deleted_Ind = 'N')
	BEGIN
		SELECT @vMsg_OUT = 'Portfolio Not Found'
		RETURN 0
	END

IF (@vYear IS NULL OR LEN(LTRIM(RTRIM(@vYear)))<0)
	BEGIN
		SELECT @vMsg_OUT = 'Invalid Year'
		RETURN 0
	END

	IF (@vTdcType IS NULL OR LEN(LTRIM(RTRIM(@vTdcType)))<0)
	BEGIN
		SELECT @vMsg_OUT = 'Invalid Metrics Type'
		RETURN 0
	END
	ELSE
	IF (RTRIM(LTRIM(UPPER(@vTdcType))) !='ACTFCST' AND  RTRIM(LTRIM(UPPER(@vTdcType)))!='BASELINE')
	BEGIN
		SELECT @vMsg_OUT = 'Invalid Metrics Type'
		RETURN 0
	END
	ELSE
	BEGIN
	SELECT @vTdcType=RTRIM(LTRIM(@vTdcType))
	END

	

--IF NOT EXISTS(SELECT 1 FROM GPM_WT_Layout WHERE Layout_Id=@vLayout_Id AND Is_Deleted_Ind = 'N')
--	BEGIN
--		SELECT @vMsg_OUT = 'Layout Not Found'
--		RETURN 0
--	END


IF (LEN(@vCountry_Code)<=0 OR @vCountry_Code IS NULL)
BEGIN
	SET @vCountry_Code = 'USA'
	SET @_vCurrencyCode='USD'
END
ELSE
	BEGIN
		IF(LEN(@vCountry_Code)=3)
			SET @_vCurrencyCode = 'USD'
		ELSE
			BEGIN
				SET @_vCurrencyCode=LTRIM(RTRIM(SUBSTRING(@vCountry_Code,CHARINDEX('|',@vCountry_Code)+1,LEN(@vCountry_Code))))
				SET @vCountry_Code=LTRIM(RTRIM(SUBSTRING(@vCountry_Code,0,CHARINDEX('|',@vCountry_Code))))
			END
	END
--/*
SELECT 
	@_vPF_WT_Codes=WT_Codes,
	@_vPF_Status_Ids=Status_Ids,
	@_vStatus_Change_Id = Status_Change_Id,
	@_vStatus_Change_Period_Id = Status_Change_Period_Id,
	@_vStatusChange_StartDt = Status_Change_StartDate,
	@_vStatusChange_EndDt = Status_Change_EndDate,

	@_vProject_StartDate_Period_Id = Project_StartDate_Period_Id,
	@_vProject_Start_StartDate = Project_Start_StartDate,
	@_vProject_Start_EndDate = Project_Start_EndDate,
	@_vProject_EndDate_Period_Id  = Project_EndDate_Period_Id,
	@_vProject_End_StartDate = Project_End_StartDate,
	@_vProject_End_EndDate = Project_End_EndDate,

	@_vProject_Leads = Project_Leads,
	@_vTeam_Members = Team_Members,
	@_vSponsors = Sponsors,
	@_vFinancialReps = FinancialReps,
	@_vApprovers = Approvers,
	@_vIncludeProjects=Include_Projects,
	@_vExcludeProjects=Exclude_Projects,
	@_vArchived_Projects=Archived_Projects

FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id

IF(LEN(LTRIM(RTRIM((SELECT CAST(Criteria_Id AS VARCHAR(10)) FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id=@vPortfolio_Id FOR XML PATH('')))))>2)
	SELECT @_vAdvance_Criteria_Id =12
ELSE
	BEGIN
		SELECT @_vAdvance_Criteria_Id = Criteria_Id,
			   @_vFilter_Value = Filter_Value
		FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id=@vPortfolio_Id
	END

IF(LEN(@_vIncludeProjects)>0)
		INSERT INTO @_vIncProjects_Table(IncWT_Project_ID,IncWT_Code,IncWT_Id,IncWT_Project_Number)
			SELECT WT_Project_ID,WT_Code,WT_Id,WT_Project_Number FROM GPM_WT_Project WHERE EXISTS(SELECT Value FROM DBO.Fn_SplitDelimetedData(',',@_vIncludeProjects) TAB WHERE TAB.Value=GPM_WT_Project.WT_Project_ID)

IF(LEN(@_vExcludeProjects)>0)
		INSERT INTO @_vExcProjects_Table(ExcWT_Project_ID,ExcWT_Code,ExcWT_Id,ExcWT_Project_Number)
			SELECT WT_Project_ID,WT_Code,WT_Id,WT_Project_Number FROM GPM_WT_Project WHERE EXISTS(SELECT Value FROM DBO.Fn_SplitDelimetedData(',',@_vExcludeProjects) TAB WHERE TAB.Value=GPM_WT_Project.WT_Project_ID)


IF(@_vPF_WT_Codes IS NULL OR LEN(LTRIM(RTRIM(@_vPF_WT_Codes)))<=0)	
	SELECT @_vPF_WT_Codes =(SELECT  STUFF((SELECT ',' + WT_Code [text()] FROM GPM_Project_Template WHERE  Is_Deleted_Ind='N' FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'')) 

	INSERT INTO @_vProjects_WT_Codes(WT_Code) 
			SELECT RTRIM(LTRIM(Value)) FROM Fn_SplitDelimetedData(',',@_vPF_WT_Codes)
       
	 
IF(LEN(RTRIM(LTRIM( @_vProject_Leads)))>0)
	INSERT INTO @_vProject_Lead_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vProject_Leads) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vTeam_Members)))>0)
	INSERT INTO @_vTeam_Members_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vTeam_Members) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vSponsors)))>0)
	INSERT INTO @_vSponsors_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vSponsors) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vFinancialReps)))>0)
	INSERT INTO @_vFinancialReps_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vFinancialReps) WHERE LEN(RTRIM(LTRIM(Value)))>0


IF(LEN(RTRIM(LTRIM( @_vApprovers)))>0)
	INSERT INTO @_vApprovers_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vApprovers) WHERE LEN(RTRIM(LTRIM(Value)))>0

DECLARE Outer_Cursor CURSOR FOR
SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN
       (SELECT WT_Code FROM @_vProjects_WT_Codes
	   UNION ALL
	   SELECT DISTINCT IncWT_Code FROM @_vIncProjects_Table)	


	INSERT INTO @_vRegion_Table (Region_Code, Is_Common_Region)
     SELECT DISTINCT Region_Code, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND LEN(RTRIM(LTRIM(Region_Code)))>0

    INSERT INTO @_vCountry_Table (Country_Code, Is_Common_Country)
     SELECT DISTINCT Country_Code, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND LEN(RTRIM(LTRIM(Country_Code)))>0

    INSERT INTO @_vLocation_Table (Location_Id, Is_Common_Location)
     SELECT DISTINCT Location_ID, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND Location_ID>0


	 

OPEN Outer_Cursor
FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

WHILE @@FETCH_STATUS = 0
       
BEGIN

--PRINT @_vWT_Code_Cur

                           SELECT 
                                                  @_vPortfolio_Tag_Id=NULL,
                                                  @_vWT_Table_Name=NULL,
                                                  @_vWT_Table_FK_Col_Name=NULL,
                                                  @_vTG_Table_Name=NULL,
                                                  @_vTG_Table_PK_Col_Name= NULL,
                                                  @_vPortfolio_Tag_Value=NULL,
                                                  @_vdynSql=NULL,
                                                  @_vdynSqlWhere='',
                                                  @_vdynSqlSelectField='',
                                                  @_vdynSqlFrom='',
												  @_vLocationList='',
												  @_vCountryList='',
												  @_vLocationList=''

                                                
												DELETE FROM @_vRegion_Table WHERE Is_Common_Region='N'
												DELETE FROM @_vCountry_Table WHERE Is_Common_Country='N'
												DELETE FROM @_vLocation_Table WHERE Is_Common_Location='N'
     

    
                                                IF(@_vWT_Code_Cur='FI' AND @_vWT_Table_Name_Cur='GPM_WT_DMAIC')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_DMAIC ON GPM_WT_Project.WT_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_DMAIC.DMAIC_Number'

													   
													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_DMAIC.DMAIC_Number AS Project_Seq,GPM_WT_DMAIC.DMAIC_Name As Project_Name'
													   
                                                END

                                                IF(@_vWT_Code_Cur='MDPO' AND @_vWT_Table_Name_Cur='GPM_WT_MDPO')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_MDPO ON GPM_WT_Project.WT_Id=GPM_WT_MDPO.MDPO_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_MDPO.MDPO_Number' 
													   
													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_MDPO.MDPO_Number AS Project_Seq,GPM_WT_MDPO.MDPO_Name As Project_Name'


												END

												IF(@_vWT_Code_Cur='GBP' AND @_vWT_Table_Name_Cur='GPM_WT_GBS')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GBS ON GPM_WT_Project.WT_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GBS.GBS_Number' 

													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GBS.GBS_Number AS Project_Seq,GPM_WT_GBS.GBS_Name As Project_Name'
												END

												IF(@_vWT_Code_Cur='GDI' AND @_vWT_Table_Name_Cur='GPM_WT_GDI')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GDI ON GPM_WT_Project.WT_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GDI.GDI_Number' 
													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GDI.GDI_Number AS Project_Seq,GPM_WT_GDI.GDI_Name As Project_Name'
												END

												IF(@_vWT_Code_Cur='IDEA' AND @_vWT_Table_Name_Cur='GPM_WT_Idea')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Idea ON GPM_WT_Project.WT_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Idea.Idea_Number' 
													   
													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Idea.Idea_Number AS Project_Seq,GPM_WT_Idea.Idea_Name As Project_Name'
												END

												IF(@_vWT_Code_Cur='SC' AND @_vWT_Table_Name_Cur='GPM_WT_Supply_Chain')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Supply_Chain ON GPM_WT_Project.WT_Id=GPM_WT_Supply_Chain.SC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Supply_Chain.SC_Number' 

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Supply_Chain.SC_Number AS Project_Seq,GPM_WT_Supply_Chain.SC_Name As Project_Name'
												END

												IF(@_vWT_Code_Cur='RD' AND @_vWT_Table_Name_Cur='GPM_WT_NMTP')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_NMTP ON GPM_WT_Project.WT_Id=GPM_WT_NMTP.QTI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_NMTP.QTI_Number' 

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_NMTP.QTI_Number AS Project_Seq,GPM_WT_NMTP.QTI_Name As Project_Name'
												END

												IF(@_vWT_Code_Cur='PSC' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement ON GPM_WT_Project.WT_Id=GPM_WT_Procurement.PSC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement.PSC_Number' 

                                                       SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Procurement.PSC_Number AS Project_Seq,GPM_WT_Procurement.PSC_Name As Project_Name'
												END
                                                    
												IF(@_vWT_Code_Cur='PSIMP' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement_Simple')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement_Simple ON GPM_WT_Project.WT_Id=GPM_WT_Procurement_Simple.PSIMP_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement_Simple.PSIMP_Number' 

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Procurement_Simple.PSIMP_Number AS Project_Seq,GPM_WT_Procurement_Simple.PSIMP_Name As Project_Name'
												END                                      

												IF(@_vWT_Code_Cur='REP' AND @_vWT_Table_Name_Cur='GPM_WT_Replication')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Replication ON GPM_WT_Project.WT_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Replication.Replication_Number' 

													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Replication.Replication_Number AS Project_Seq,GPM_WT_Replication.Replication_Name As Project_Name'
												END                                      
       

												
											
                                                INSERT INTO @_vTab_Dyn_SQL_Table (Portfolio_Tag_Id,WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value)
                                                SELECT B.Portfolio_Tag_Id, B.WT_Table_Name, B.WT_Table_FK_ColName, B.TG_Table_Name, B.TG_Table_PK_ColName,REPLACE(A.Portfolio_Tag_Value,'^',',')
                                                FROM GPM_WT_Portfolio_Tag_Value A 
                                                INNER JOIN GPM_Portfolio_Tag B On A.Portfolio_Tag_Id=B.Portfolio_Tag_Id
                                                WHERE a.Portfolio_Id=@vPortfolio_Id AND B.WT_Table_Name=@_vWT_Table_Name_Cur
												AND A.Portfolio_Tag_Id NOT IN(123,124)
												
												

                                           
                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region' 

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vRegion_Table (Region_Code, Is_Common_Region)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vRegion_Table RT WHERE RT.Region_Code=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
                                                       
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                END


												SELECT
                                                              @_vPortfolio_Tag_Id= NULL,
                                                              @_vPortfolio_Tag_Value=NULL,
                                                              @_vWT_Table_FK_Col_Name=NULL,
                                                              @_vTG_Table_Name=NULL,
                                                              @_vTG_Table_PK_Col_Name=NULL

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

												
                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vCountry_Table (Country_Code, Is_Common_Country)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vCountry_Table CT WHERE CT.Country_Code=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
                                                
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                       
                                                END


												SELECT
                                                              @_vPortfolio_Tag_Id= NULL,
                                                              @_vPortfolio_Tag_Value=NULL,
                                                              @_vWT_Table_FK_Col_Name=NULL,
                                                              @_vTG_Table_Name=NULL,
                                                              @_vTG_Table_PK_Col_Name=NULL

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vLocation_Table (Location_Id, Is_Common_Location)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vLocation_Table LT WHERE LT.Location_Id=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
													   
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                       
                                                END
                                                

												IF ((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='N') >0 OR
														(SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='N')>0 OR
														(SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='N')>0 )


												BEGIN
																IF((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='N')>0)
																BEGIN
																	SELECT
																				  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																				  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																				  @_vTG_Table_Name=GPT.TG_Table_Name,
																				  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region'

																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

																	SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table WHERE Is_Common_Region='N' FOR XML PATH(''))
																	SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
																	SELECT @_vdynSqlWhere =' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'
																END

                                                
																IF((SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='N')>0)
																BEGIN
																	SELECT
																				  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																				  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																				  @_vTG_Table_Name=GPT.TG_Table_Name,
																				  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

																	
																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name


																	 SET @_vCountryList= (SELECT  ','+''''+ Country_Code+'''' FROM @_vCountry_Table WHERE Is_Common_Country='N' FOR XML PATH(''))
																	 SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))
																	 IF (LEN(@_vdynSqlWhere)>0)
																			SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
																	 ELSE
																			SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'

																END

																IF((SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='N')>0)
																BEGIN

																	SELECT
																			@_vPortfolio_Tag_Id= NULL,
																			@_vWT_Table_FK_Col_Name=NULL,
																			@_vTG_Table_Name=NULL,
																			@_vTG_Table_PK_Col_Name=NULL

																	SELECT
																			@_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																			@_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																			@_vTG_Table_Name=GPT.TG_Table_Name,
																			@_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name


																	SET @_vLocationList= (SELECT  ','+ Location_Id FROM @_vLocation_Table WHERE Is_Common_Location='N' FOR XML PATH(''))
																	SET @_vLocationList= SUBSTRING(@_vLocationList,2, LEN(@_vLocationList))
												
																	IF (LEN(@_vdynSqlWhere)>0)
																		SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																	ELSE
																		SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																END
												
										END  /* END IF FOR TEMPLATE REGION, COUNTRY AND  LOCATION*/
										ELSE
										IF ((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='Y') >0 OR
												(SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='Y')>0 OR
													(SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='Y')>0 )

										
										BEGIN
											SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

														
											
											IF((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='Y')>0)
												BEGIN

											
													SELECT
														  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
														  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
														  @_vTG_Table_Name=GPT.TG_Table_Name,
														  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
													FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region'
													
													
													--INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
                                                
													SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

													SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table WHERE Is_Common_Region='Y' FOR XML PATH(''))
													SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))

													SELECT @_vdynSqlWhere +=' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'

													
												END

												SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

														

											IF((SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='Y')>0)
												BEGIN
													SELECT
														  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
														  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
														  @_vTG_Table_Name=GPT.TG_Table_Name,
														  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
													FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

													SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

													SET @_vRegionList= (SELECT  ','+''''+ PT.Region_Code+'''' FROM @_vRegion_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Region_Code=GWPD.Region_Code  
													WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Region='Y' AND GWPD.Country_Code IS NULL FOR XML PATH(''))
													
													
													SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
													SET @_vRegionList= ISNULL(@_vRegionList,'''''')

													 IF (LEN(@_vdynSqlWhere)>0)
															SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+' AND EXISTS(SELECT 1 FROM (SELECT Country_Code FROM GPM_Country WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Distinct Country_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Country_Code IS NOT NULL) COUNTRY_TAB WHERE COUNTRY_TAB.Country_Code='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'
													 ELSE
															SELECT @_vdynSqlWhere = ' WHERE EXISTS(SELECT 1 FROM (SELECT Country_Code FROM GPM_Country WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Distinct Country_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Country_Code IS NOT NULL) COUNTRY_TAB WHERE COUNTRY_TAB.Country_Code='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'

															
												END


												SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

												IF((SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='Y')>0)
													BEGIN
													
														SELECT
															@_vPortfolio_Tag_Id= NULL,
															@_vWT_Table_FK_Col_Name=NULL,
															@_vTG_Table_Name=NULL,
															@_vTG_Table_PK_Col_Name=NULL

														SELECT
															@_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
															@_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
															@_vTG_Table_Name=GPT.TG_Table_Name,
															@_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
														FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

														SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

														
														SET @_vRegionList= (SELECT  ','+''''+ PT.Region_Code+'''' FROM @_vRegion_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Region_Code=GWPD.Region_Code  
														WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Region='Y' AND GWPD.Country_Code IS NULL AND GWPD.Location_ID IS NULL FOR XML PATH(''))

														SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))

														SET @_vRegionList =ISNULL(@_vRegionList,'''''')

														

														SET @_vCountryList= (SELECT  ','+''''+ PT.Country_Code+'''' FROM @_vCountry_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Country_Code=GWPD.Country_Code
														WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Country='Y' AND GWPD.Location_ID IS NULL FOR XML PATH(''))

														SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))

														SET @_vCountryList =ISNULL(@_vCountryList,'''''')
														
															IF (LEN(@_vdynSqlWhere)>0)
																SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+' AND EXISTS(SELECT 1 FROM (SELECT Location_Id FROM GPM_Location WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Location_Id FROM GPM_Location WHERE Country_Code IN('+@_vCountryList+') UNION SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'
															ELSE
																SELECT @_vdynSqlWhere = ' WHERE EXISTS(SELECT 1 FROM (SELECT Location_Id FROM GPM_Location WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Location_Id FROM GPM_Location WHERE Country_Code IN('+@_vCountryList+') UNION SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'

													END

													
										END /* END IF FOR DEFAULT (DESCENDED) REGION, COUNTRY AND  LOCATION*/

										
										

                                  IF((SELECT COUNT(*) FROM @_vTab_Dyn_SQL_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vTab_Dyn_SQL_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=NULL,
                                                       @_vWT_Table_Name=NULL,
                                                       @_vWT_Table_FK_Col_Name=NULL,
                                                       @_vTG_Table_Name=NULL,
                                                       @_vTG_Table_PK_Col_Name= NULL,
                                                       @_vPortfolio_Tag_Value=NULL

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=Portfolio_Tag_Id,
                                                       @_vWT_Table_Name=WT_Table_Name,
                                                       @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                       @_vTG_Table_Name=TG_Table_Name,
                                                       @_vTG_Table_PK_Col_Name=TG_Table_PK_Col_Name,
                                                       @_vPortfolio_Tag_Value=Portfolio_Tag_Value
                                                FROM @_vTab_Dyn_SQL_Table WHERE Row_ID=@_vCnt


													IF NOT EXISTS(SELECT 1 FROM @_vProcessedTag PT WHERE PT.Portfolio_Tag_Id=@_vPortfolio_Tag_Id)
                                                       BEGIN
																IF(@_vPortfolio_Tag_Id IN(28,41,16,53,72))
																BEGIN
																	IF(@_vPortfolio_Tag_Id=28)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_GDI_MS_Attrib WHERE GPM_WT_GDI_MS_Attrib.GDI_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_GDI_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_GDI_MS_Attrib WHERE GPM_WT_GDI_MS_Attrib.GDI_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_GDI_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id =41)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_DMAIC_MS_Attrib WHERE GPM_WT_DMAIC_MS_Attrib.DMAIC_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_DMAIC_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_DMAIC_MS_Attrib WHERE GPM_WT_DMAIC_MS_Attrib.DMAIC_Id=GPM_WT_DMAIC.DMAIC_Id AND  GPM_WT_DMAIC_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=16)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_Idea_MS_Attrib WHERE GPM_WT_Idea_MS_Attrib.Idea_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Idea_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_Idea_MS_Attrib WHERE GPM_WT_Idea_MS_Attrib.Idea_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Idea_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=53)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_Replication_MS_Attrib WHERE GPM_WT_Replication_MS_Attrib.Replication_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Replication_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_Replication_MS_Attrib WHERE GPM_WT_Replication_MS_Attrib.Replication_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Replication_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=72)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_GBS_MS_Attrib WHERE GPM_WT_GBS_MS_Attrib.GBS_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_GBS_MS_Attrib.Gbs_Geography_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_GBS_MS_Attrib WHERE GPM_WT_GBS_MS_Attrib.GBS_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_GBS_MS_Attrib.Gbs_Geography_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																END
																ELSE
																BEGIN

                                                                     SET @_vdynSqlFrom += N' LEFT OUTER JOIN '+ @_vTG_Table_Name +N' ON '+@_vWT_Table_Name+N'.'+@_vWT_Table_FK_Col_Name+N' = '+@_vTG_Table_Name+N'.'+@_vTG_Table_PK_Col_Name;

                                                                     IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
                                                                     ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
																END

                                                                     
                                                       END
												

                                                SELECT @_vCnt=MIN(Row_ID) FROM @_vTab_Dyn_SQL_Table WHERE Row_ID>@_vCnt
                                                       
                                         END
                                  END

								  

								  

								  

								  IF(@_vPF_Status_Ids IS NOT NULL AND LEN(@_vPF_Status_Ids)>0)
								  IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                           SET @_vdynSqlWhere = ' WHERE '+ @_vWT_Project_Table_Name +'.Status_Id ' + ' IN ('+@_vPF_Status_Ids+')'
                                  ELSE
                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND '+ @_vWT_Project_Table_Name +'.Status_Id' + ' IN ('+@_vPF_Status_Ids+')'

					
								

								IF(@_vStatus_Change_Period_Id IS NOT NULL AND @_vStatus_Change_Period_Id>0)
									BEGIN
										IF(@_vStatus_Change_Period_Id!=17)
											SELECT 
												@_vStatusChange_EndDt = GETDATE(),
												@_vStatusChange_StartDt = dbo.Fn_Portfolio_Period(@_vStatus_Change_Period_Id,GETDATE())
									

										IF(@_vStatusChange_StartDt IS NOT NULL AND @_vStatusChange_EndDt IS NOT NULL)
										BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
													SET @_vdynSqlWhere = ' WHERE EXISTS ( SELECT 1 FROM GPM_WT_Project_Status_History WHERE  
													GPM_WT_Project_Status_History.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND 
													GPM_WT_Project_Status_History.Status_Id='+CAST(@_vStatus_Change_Id AS VARCHAR(2)) +' AND GPM_WT_Project_Status_History.StatusChange_Date BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_StartDt,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_EndDt,112)+''',112))'
												ELSE
													
													SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND EXISTS ( SELECT 1 FROM GPM_WT_Project_Status_History WHERE  
													GPM_WT_Project_Status_History.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND 
													GPM_WT_Project_Status_History.Status_Id='+CAST(@_vStatus_Change_Id AS VARCHAR(2)) +' AND GPM_WT_Project_Status_History.StatusChange_Date BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_StartDt,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_EndDt,112)+''',112))'
										END
									END

									IF(@_vProject_StartDate_Period_Id IS NOT NULL AND @_vProject_StartDate_Period_Id>0)
									BEGIN
										IF(@_vProject_StartDate_Period_Id!=17)
												SELECT 
													@_vProject_Start_EndDate = GETDATE(),
													@_vProject_Start_StartDate = dbo.Fn_Portfolio_Period(@_vProject_StartDate_Period_Id,GETDATE())
							

										IF(@_vProject_Start_StartDate IS NOT NULL AND @_vProject_Start_EndDate IS NOT NULL)
											BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
								
													SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_StartDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_StartDate,112)+''',112 ) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_EndDate,112)+''', DATE))'
												ELSE
													
													SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_StartDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_StartDate,112)+''',112 ) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_Start_EndDate,112)+''', 112))'
											END
									END


									IF(@_vProject_EndDate_Period_Id IS NOT NULL AND @_vProject_EndDate_Period_Id>0)
									BEGIN
										IF(@_vProject_EndDate_Period_Id!=17)
												SELECT 
													@_vProject_End_EndDate = GETDATE(),
													@_vProject_End_StartDate = dbo.Fn_Portfolio_Period(@_vProject_EndDate_Period_Id,GETDATE())
							

										IF(@_vProject_End_StartDate IS NOT NULL AND @_vProject_End_EndDate IS NOT NULL)
											BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
								
													SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_EndDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_StartDate,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_EndDate,112)+''',112))'
												ELSE
													
													SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_EndDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_StartDate,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_EndDate,112)+''',112))'
											END
									END

									
									/*Logic for Project Lead */
									
									IF(LEN(LTRIM(RTRIM(@_vProject_Leads)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='' OR LEN(RTRIM(LTRIM(@_vdynSqlWhere)))<=0)
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Project Lead'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vProject_Leads+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV
																WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Project Lead'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vProject_Leads+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END
	
	
								/* Logic For Sponsor */

									IF(LEN(RTRIM(LTRIM(@_vSponsors))) >0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Sponsor'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vSponsors+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Sponsor'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vSponsors+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									/* Logic For Approver Conditon*/
									IF(LEN(RTRIM(LTRIM(@_vApprovers)))>0)
									BEGIN
										IF(@_vWT_Code_Cur IN('PSIMP','PSC'))
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Managers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Managers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
						
										IF(@_vWT_Code_Cur ='IDEA')
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Idea Approver'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Idea Approver'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
									

										IF(@_vWT_Code_Cur ='MDPO')
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''MDPO Regional Approvers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''MDPO Regional Approvers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
									END




									/*Logic for Financial Rep*/
									IF(LEN(LTRIM(RTRIM(@_vFinancialReps)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Financial Rep'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vFinancialReps+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Financial Rep'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vFinancialReps+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									/*Logic for Team Member*/
									IF(LEN(RTRIM(LTRIM(@_vTeam_Members)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Team Members'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vTeam_Members+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND ( EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Team Members'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vTeam_Members+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									
									/*Apply Condition for Advance Criteria*/
									IF(@_vAdvance_Criteria_Id IN(10,11,12) AND @_vWT_Code_Cur NOT IN('IDEA', 'GBP','RD'))
									BEGIN
									--PRINT 'YES'
									
											--SELECT  @_vTDC_Table_Name = 'GPM_WT_Project_TDC_Saving',
											SELECT  @_vTDC_Table_Name = CASE WHEN @_vWT_Code_Cur='FI' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_DMAIC'
																						 WHEN @_vWT_Code_Cur='GDI' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_GDI'
																						 WHEN @_vWT_Code_Cur='MDPO' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_MDPO'
																						 WHEN @_vWT_Code_Cur='PSC' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_PSC'
																						 WHEN @_vWT_Code_Cur='PSIMP' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_PSIMP'
																						 WHEN @_vWT_Code_Cur='REP' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_REP'
																						 WHEN @_vWT_Code_Cur='SC' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_SC'
																						 ELSE '' END,
													@_vTDCType_ColPrefix = 'Act_Fcst.'

											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SELECT @_vdynSqlWhere = ' WHERE '
											ELSE
												SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '


												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' (FLOOR(ROUND(ISNULL((SELECT (SUM(CASE WHEN Attrib_Id = 32 THEN  ISNULL('+ @_vTDC_Table_Name+'.Attrib_Value ,0)*-1 
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 33 THEN  ISNULL(' + @_vTDC_Table_Name +'.Attrib_Value,0)*-1  
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 34 THEN  ISNULL('+ @_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 35 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 36 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END) + (SELECT SUM(ISNULL(Attrib_Value,0)) FROM '+@_vTDC_Table_Name +' 
																				WHERE '+ @_vTDC_Table_Name+'.Attrib_Id IN(37,38,39,40,41,42,43,44,45,46,47,48) /*GSS-Conversion*/
																				AND '+@_vTDC_Table_Name+'.WT_Project_Id=GPM_WT_Project.WT_Project_ID)) FROM '+@_vTDC_Table_Name +'
																				WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																					@_vTDC_Table_Name+'.Attrib_Id IN(
																													17,22,27,32, /*TT-Raw Material*/
																													23,28,33, /*TT-Conversion*/
																													19,24,29,34, /*TT-Other CGS*/
																													20,25,30,35, /*TT-Transportation*/
																													21,26,31,36 /*TT-SAG*/
																													)),0),-0))'
											IF(@_vAdvance_Criteria_Id=10)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' < 0 )'
											IF(@_vAdvance_Criteria_Id=11)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' > 0 )'
											IF(@_vAdvance_Criteria_Id=12)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' != 0 )'

												--PRINT @_vdynSqlWhere
									
									END
									
									/* Best Practice Condition*/
									--DECLARE @_vdynSqlWhereTemp VARCHAR(MAX)=''
									SELECT @_vBP_Portfolio_Tag_Value=NULL
									IF(@_vWT_Code_Cur='GDI')
									BEGIN
									
										SELECT @_vBP_Portfolio_Tag_Value=RTRIM(LTRIM(Portfolio_Tag_Value)) from GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id=@vPortfolio_Id AND Portfolio_Tag_Id=123
										IF(LEN(@_vBP_Portfolio_Tag_Value)>0)
										BEGIN
											IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
												IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ( ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N''  '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND ( ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '
												ELSE
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '


										IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
											BEGIN
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ' 
													ELSE
														IF (
															 EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
															AND
															(SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0
															)
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	OR  '
														ELSE
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  '

													SET  @_vdynSqlWhere =	ISNULL(@_vdynSqlWhere,'') + '(ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''Y'' AND EXISTS(SELECT  TOP  1 1 
																							FROM GPM_WT_Project_BP_Gate INNER JOIN(SELECT Value AS Portfolio_Tag_Value,
																									CASE	WHEN  GWPTV.Value=11 THEN 27
																											WHEN  GWPTV.Value=12 THEN 28
																											WHEN  GWPTV.Value=13 THEN 29
																											WHEN  GWPTV.Value=14 THEN 30
																											WHEN  GWPTV.Value=15 THEN 30
																											WHEN  GWPTV.Value=16 THEN 30
																											WHEN  GWPTV.Value=17 THEN 30 END AS BPC_Gate_Id
			
																			  FROM dbo.Fn_SplitDelimetedData('','','''+@_vBP_Portfolio_Tag_Value+''') GWPTV WHERE GWPTV.Value!=10
																			  ) BPC_Gate On GPM_WT_Project_BP_Gate.Gate_Id=BPC_Gate.BPC_Gate_Id
																			  WHERE GPM_WT_Project_BP_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_ID AND
																			  GPM_WT_Project_BP_Gate.Is_Currently_Active=(SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''Y'' ELSE ''N'' END)
																			  AND ''XXX''= (SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''XXX''  
																			  WHEN BPC_Gate.Portfolio_Tag_Value=15 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Could''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=16 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Should''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=17 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Must''),''YYY'')
																			  END)
																			  ))'

																			  IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
																			  SET @_vdynSqlWhere = @_vdynSqlWhere +')'
																				
											END
										END
												--PRINT @_vdynSqlWhereTemp
									END /* END GDI Best Practice If*/
									
									
									
									SELECT @_vBP_Portfolio_Tag_Value=NULL
									IF(@_vWT_Code_Cur='FI')
									BEGIN
									
										SELECT @_vBP_Portfolio_Tag_Value=RTRIM(LTRIM(Portfolio_Tag_Value)) from GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id=@vPortfolio_Id AND Portfolio_Tag_Id=124
										IF(LEN(@_vBP_Portfolio_Tag_Value)>0)
										BEGIN
											IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
												IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  (ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
												ELSE
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '


											IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
												BEGIN
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ' 
													ELSE
														IF (
															 EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
															AND
															(SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0
															)
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	OR  '
														ELSE
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  '


													SET  @_vdynSqlWhere =	ISNULL(@_vdynSqlWhere,'') + '(ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''Y'' AND EXISTS(SELECT  TOP  1 1 
																							FROM GPM_WT_Project_BP_Gate INNER JOIN(SELECT Value AS Portfolio_Tag_Value,
																									CASE	WHEN  GWPTV.Value=11 THEN 27
																											WHEN  GWPTV.Value=12 THEN 28
																											WHEN  GWPTV.Value=13 THEN 29
																											WHEN  GWPTV.Value=14 THEN 30
																											WHEN  GWPTV.Value=15 THEN 30
																											WHEN  GWPTV.Value=16 THEN 30
																											WHEN  GWPTV.Value=17 THEN 30 END AS BPC_Gate_Id
			
																			  FROM dbo.Fn_SplitDelimetedData('','','''+@_vBP_Portfolio_Tag_Value+''') GWPTV WHERE GWPTV.Value!=10
																			  ) BPC_Gate On GPM_WT_Project_BP_Gate.Gate_Id=BPC_Gate.BPC_Gate_Id
																			  WHERE GPM_WT_Project_BP_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_ID AND
																			  GPM_WT_Project_BP_Gate.Is_Currently_Active=(SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''Y'' ELSE ''N'' END)
																			  AND ''XXX''= (SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''XXX''  
																			  WHEN BPC_Gate.Portfolio_Tag_Value=15 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Could''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=16 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Should''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=17 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Must''),''YYY'')
																			  END)
																			  ))'

																			  IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
																			  SET @_vdynSqlWhere = @_vdynSqlWhere +')'
											END

										END
											
												--PRINT @_vdynSqlWhereTemp
									END /* END FI Best Practice If*/
									
									
						IF(@_vArchived_Projects='N' OR @_vArchived_Projects IS NULL)
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''N'') =''N'''
								ELSE
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''N'') =''N'''
							END
						ELSE
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''Y'') =''Y'''
								ELSE
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''Y'') =''Y'''
							END
						
						IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
							SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Deleted_Ind ,''N'') =''N'''
						ELSE
							SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE ISNULL('+@_vWT_Table_Name_Cur+'.Is_Deleted_Ind ,''N'')=''N'''


						IF EXISTS(SELECT * FROM @_vProjects_WT_Codes WHERE WT_Code=@_vWT_Code_Cur)
						BEGIN
						IF EXISTS(SELECT * FROM @_vExcProjects_Table WHERE ExcWT_Code=@_vWT_Code_Cur)
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								ELSE
									SELECT @_vdynSqlWhere = ' WHERE  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
							END

								INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere) 
									VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere)
						END

								
						IF EXISTS(SELECT * FROM @_vIncProjects_Table WHERE IncWT_Code=@_vWT_Code_Cur)
						BEGIN
							SELECT @_vdynSqlWhere= ' WHERE GPM_WT_Project.WT_Project_ID IN('+ (SELECT  STUFF((SELECT ',' + CAST(IncWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vIncProjects_Table WHERE  IncWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								
							--Select @_vdynSqlWhere

							IF EXISTS(SELECT * FROM @_vExcProjects_Table WHERE ExcWT_Code=@_vWT_Code_Cur)
								BEGIN
									IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
										SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
									ELSE
										SELECT @_vdynSqlWhere = ' WHERE  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								END


							INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere,IncludeProject) 
									VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere,'Y')
						END
						
						
						
                                  
                     FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

                     DELETE FROM @_vTab_Dyn_SQL_Table

                     
	END
CLOSE Outer_Cursor;
DEALLOCATE Outer_Cursor;
IF CURSOR_STATUS('global','Outer_Cursor')>=-1
BEGIN
       DEALLOCATE Outer_Cursor
END

BEGIN

	CREATE TABLE #Temp_Dashboard ( WT_Project_ID INT,WT_Code VARCHAR(10),Project_Seq VARCHAR(15),Project_Name NVARCHAR(500) PRIMARY KEY NONCLUSTERED (WT_Project_Id, WT_Code));

	
									SELECT @_vCnt=0,
										@_vMaxCnt=0

								IF((SELECT COUNT(*) FROM @_vWTQueriesTab WHERE  IncludeProject='N')>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vWTQueriesTab WHERE  IncludeProject='N'
												SELECT @_vdynSqlFinalQuery = ''

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN
														SELECT @_vdynSqlFinalQuery=''

														
														SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ ISNULL(SelectWhere,'') FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														
														INSERT INTO #Temp_Dashboard ( WT_Project_ID,WT_Code,Project_Seq,Project_Name)
														EXEC(@_vdynSqlFinalQuery)

														SELECT @_vCnt=MIN(Row_ID) FROM @_vWTQueriesTab WHERE Row_ID>@_vCnt AND  IncludeProject='N'
												END
										END
										

										

										/* Format queries to retreive ALL the project which fits in Portfolio Criteria*/

								SELECT @_vCnt=0,
										@_vMaxCnt=0

								IF((SELECT COUNT(*) FROM @_vWTQueriesTab WHERE  IncludeProject='Y')>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vWTQueriesTab WHERE  IncludeProject='Y'

												SELECT @_vdynSqlFinalQuery = ''

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN
														SELECT @_vdynSqlFinalQuery = ''
													
														
															SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ 
															
															CASE WHEN LEN(RTRIM(LTRIM(SelectWhere)))>0 THEN SelectWhere +' AND'
															ELSE ' WHERE ' END + ' NOT EXISTS( SELECT 1 FROM #Temp_Dashboard TD WHERE TD.WT_Project_ID=GPM_WT_Project.WT_Project_Id)'
															FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														
														INSERT INTO #Temp_Dashboard ( WT_Project_ID,WT_Code,Project_Seq,Project_Name)
														EXEC(@_vdynSqlFinalQuery)

												SELECT @_vCnt=MIN(Row_ID) FROM @_vWTQueriesTab WHERE Row_ID>@_vCnt AND  IncludeProject='Y'
												END
										END
							


END	
--*/	
--DECLARE @_vTDCMetric AS Table(Attrib_Id INT, Attrib_Name Varchar(200), YearMonth Varchar(8), Attrib_Value Numeric(38),  Display_Order Int)
DECLARE @_vTDCMetric TDC_InvFinancialMatrics

DECLARE @_vTDC_All_Template_BaseData AS Table(Attrib_Id INT,  YearMonth Int, Attrib_Value Numeric(38))

SELECT @_vStartDate  = CAST(@vYear+'01' AS INT),
		 @_vEndDate  = CAST(@vYear+'12' AS INT)
/*
INSERT INTO @_vTDC_All_Template_BaseData(Attrib_Id,  YearMonth, Attrib_Value)
SELECT Attrib_Id, YearMonth, SUM(Attrib_Value) AS Attrib_Value  FROM
(
SELECT TDC_Dmaic.Attrib_Id, TDC_Dmaic.YearMonth, CAST(SUM(TDC_Dmaic.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value FROM GPM_WT_Project_TDC_Saving_ActFcst_DMAIC TDC_Dmaic INNER JOIN  #Temp_Dashboard TD On TDC_Dmaic.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='FI' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_Dmaic.Attrib_Id, TDC_Dmaic.YearMonth
UNION ALL
SELECT TDC_GDI.Attrib_Id, TDC_GDI.YearMonth, CAST(SUM(TDC_GDI.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_GDI TDC_GDI INNER JOIN  #Temp_Dashboard TD On TDC_GDI.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='GDI' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_GDI.Attrib_Id, TDC_GDI.YearMonth
UNION ALL
SELECT TDC_MDPO.Attrib_Id, TDC_MDPO.YearMonth, CAST(SUM(TDC_MDPO.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_MDPO TDC_MDPO INNER JOIN  #Temp_Dashboard TD On TDC_MDPO.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='MDPO' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_MDPO.Attrib_Id, TDC_MDPO.YearMonth
UNION ALL
SELECT TDC_Psc.Attrib_Id, TDC_Psc.YearMonth, CAST(SUM(TDC_Psc.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_PSC TDC_Psc INNER JOIN  #Temp_Dashboard TD On TDC_Psc.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='PSC' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_Psc.Attrib_Id, TDC_Psc.YearMonth
UNION ALL
SELECT TDC_Psimp.Attrib_Id, TDC_Psimp.YearMonth, CAST(SUM(TDC_Psimp.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_PSIMP TDC_Psimp INNER JOIN  #Temp_Dashboard TD On TDC_Psimp.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='PSIMP' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_Psimp.Attrib_Id, TDC_Psimp.YearMonth
UNION ALL
SELECT TDC_Rep.Attrib_Id, TDC_Rep.YearMonth, CAST(SUM(TDC_Rep.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_REP TDC_Rep INNER JOIN  #Temp_Dashboard TD On TDC_Rep.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='REP' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_Rep.Attrib_Id, TDC_Rep.YearMonth
UNION ALL
SELECT TDC_Sc.Attrib_Id, TDC_Sc.YearMonth, CAST(SUM(TDC_Sc.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_ActFcst_SC TDC_Sc INNER JOIN  #Temp_Dashboard TD On TDC_Sc.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code='SC' AND YearMonth between @_vStartDate AND @_vEndDate GROUP BY TDC_Sc.Attrib_Id, TDC_Sc.YearMonth

) TDC_All_Template_Baseline GROUP BY Attrib_Id, YearMonth 
*/

INSERT INTO @_vTDC_All_Template_BaseData(Attrib_Id,  YearMonth, Attrib_Value)
EXEC('SELECT Attrib_Id, YearMonth, SUM(Attrib_Value) AS Attrib_Value  FROM
(
SELECT TDC_Dmaic.Attrib_Id, TDC_Dmaic.YearMonth, CAST(SUM(TDC_Dmaic.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_DMAIC TDC_Dmaic INNER JOIN  #Temp_Dashboard TD On TDC_Dmaic.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''FI'' AND YearMonth between '+@_vStartDate + ' AND '+ @_vEndDate +' GROUP BY TDC_Dmaic.Attrib_Id, TDC_Dmaic.YearMonth
UNION ALL
SELECT TDC_GDI.Attrib_Id, TDC_GDI.YearMonth, CAST(SUM(TDC_GDI.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_GDI TDC_GDI INNER JOIN  #Temp_Dashboard TD On TDC_GDI.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''GDI'' AND YearMonth between '+ @_vStartDate +' AND '+@_vEndDate +' GROUP BY TDC_GDI.Attrib_Id, TDC_GDI.YearMonth
UNION ALL
SELECT TDC_MDPO.Attrib_Id, TDC_MDPO.YearMonth, CAST(SUM(TDC_MDPO.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_MDPO TDC_MDPO INNER JOIN  #Temp_Dashboard TD On TDC_MDPO.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''MDPO'' AND YearMonth between '+ @_vStartDate +' AND '+ @_vEndDate +' GROUP BY TDC_MDPO.Attrib_Id, TDC_MDPO.YearMonth
UNION ALL
SELECT TDC_Psc.Attrib_Id, TDC_Psc.YearMonth, CAST(SUM(TDC_Psc.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_PSC TDC_Psc INNER JOIN  #Temp_Dashboard TD On TDC_Psc.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''PSC'' AND YearMonth between '+ @_vStartDate +' AND '+ @_vEndDate +' GROUP BY TDC_Psc.Attrib_Id, TDC_Psc.YearMonth
UNION ALL
SELECT TDC_Psimp.Attrib_Id, TDC_Psimp.YearMonth, CAST(SUM(TDC_Psimp.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_PSIMP TDC_Psimp INNER JOIN  #Temp_Dashboard TD On TDC_Psimp.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''PSIMP'' AND YearMonth between '+ @_vStartDate +' AND '+@_vEndDate +' GROUP BY TDC_Psimp.Attrib_Id, TDC_Psimp.YearMonth
UNION ALL
SELECT TDC_Rep.Attrib_Id, TDC_Rep.YearMonth, CAST(SUM(TDC_Rep.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_REP TDC_Rep INNER JOIN  #Temp_Dashboard TD On TDC_Rep.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''REP'' AND YearMonth between '+ @_vStartDate +' AND '+ @_vEndDate +' GROUP BY TDC_Rep.Attrib_Id, TDC_Rep.YearMonth
UNION ALL
SELECT TDC_Sc.Attrib_Id, TDC_Sc.YearMonth, CAST(SUM(TDC_Sc.Attrib_Value) AS NUMERIC(38)) AS Attrib_Value  FROM GPM_WT_Project_TDC_Saving_'+@vTdcType+'_SC TDC_Sc INNER JOIN  #Temp_Dashboard TD On TDC_Sc.WT_Project_ID=TD.WT_Project_ID
WHERE TD.WT_Code=''SC'' AND YearMonth between '+ @_vStartDate +' AND '+@_vEndDate +' GROUP BY TDC_Sc.Attrib_Id, TDC_Sc.YearMonth

) TDC_All_Template_Baseline GROUP BY Attrib_Id, YearMonth') 


 INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value,  Display_Order)
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
					 WHERE B.Attrib_Type='WC IMPROVEMENT' AND B.Is_Computed_Attrib='N'
					 UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='GROSS SAVINGS' AND B.Is_Computed_Attrib='N'
                      UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='(HW)/TW' AND B.Is_Computed_Attrib='N'
                      UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='COST AVOIDANCE' AND B.Is_Computed_Attrib='N'
                      UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='COST OF SAVINGS' AND B.Is_Computed_Attrib='N'
                      UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='LOSS AMOUNT' AND B.Is_Computed_Attrib='N'
                     UNION ALL
                     SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, ISNULL(A.Attrib_Value,0), B.Display_Order from @_vTDC_All_Template_BaseData A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
                     WHERE B.Attrib_Type='CONVERSION SCORECARD' AND B.Is_Computed_Attrib='N'


					 

					INSERT INTO @_vYearMonth_Table(YearMonth)
					SELECT DISTINCT YearMonth FROM @_vTDCMetric

					
					INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order) --Tab.Attrib_Value=0
                      SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, TAB.Attrib_Value, B.Display_Order FROM
                     (SELECT 50 As Attrib_Id, A.YearMonth As YearMonth ,
					 
					 (SELECT  SUM(ISNULL(TATB.Attrib_Value,0))	 AS Attrib_Value from @_vTDC_All_Template_BaseData TATB INNER JOIN GPM_Metrics_TDC_Saving GMTS ON TATB.Attrib_Id=GMTS.Attrib_Id
													WHERE GMTS.Attrib_Type='WC IMPROVEMENT' AND GMTS.Is_Computed_Attrib='N' AND TATB.YearMonth= CAST(REPLACE (A.YearMonth,'-','') AS INT)) AS Attrib_Value
					 
					 FROM @_vYearMonth_Table A 
                     ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
					 UNION ALL
					 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, TAB.Attrib_Value, B.Display_Order FROM
                     (SELECT 51 As Attrib_Id, A.YearMonth As YearMonth ,
					 
					 (SELECT  SUM(ISNULL(TATB.Attrib_Value,0))	 AS Attrib_Value from @_vTDC_All_Template_BaseData TATB INNER JOIN 
					 (SELECT Attrib_Id FROM GPM_Metrics_TDC_Saving GMTS WHERE Attrib_Type='GROSS SAVINGS' AND Is_Computed_Attrib='N'
					 UNION 
					 SELECT Attrib_Id FROM GPM_Metrics_TDC_Saving GMTS WHERE Attrib_Type='CONVERSION SCORECARD' AND Is_Computed_Attrib='N') GMTS ON TATB.Attrib_Id=GMTS.Attrib_Id													
													WHERE TATB.YearMonth= CAST(REPLACE (A.YearMonth,'-','') AS INT)) AS Attrib_Value
					 FROM @_vYearMonth_Table A 
                     )  TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
					 UNION ALL
					 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, TAB.Attrib_Value, B.Display_Order FROM
					 (SELECT 52 As Attrib_Id, A.YearMonth As YearMonth ,
					 
					 (SELECT  SUM(ISNULL(TATB.Attrib_Value,0))	 AS Attrib_Value from @_vTDC_All_Template_BaseData TATB INNER JOIN GPM_Metrics_TDC_Saving GMTS ON TATB.Attrib_Id=GMTS.Attrib_Id
													WHERE GMTS.Attrib_Type='(HW)/TW' AND GMTS.Is_Computed_Attrib='N' AND TATB.YearMonth= CAST(REPLACE (A.YearMonth,'-','') AS INT)) AS Attrib_Value
					 
					 FROM @_vYearMonth_Table A 
                     ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
					 UNION ALL
					 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, TAB.Attrib_Value, B.Display_Order FROM
					 (SELECT 53 As Attrib_Id, A.YearMonth As YearMonth ,
					 
					 (SELECT  SUM(ISNULL(TATB.Attrib_Value,0))	 AS Attrib_Value from @_vTDC_All_Template_BaseData TATB INNER JOIN GPM_Metrics_TDC_Saving GMTS ON TATB.Attrib_Id=GMTS.Attrib_Id
													WHERE GMTS.Attrib_Type='COST AVOIDANCE' AND GMTS.Is_Computed_Attrib='N' AND TATB.YearMonth= CAST(REPLACE (A.YearMonth,'-','') AS INT)) AS Attrib_Value
					 
					 FROM @_vYearMonth_Table A 
                     ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
					 UNION ALL
					 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, TAB.Attrib_Value, B.Display_Order FROM
					 (SELECT 54 As Attrib_Id, A.YearMonth As YearMonth ,
					 
					 (SELECT  SUM(ISNULL(TATB.Attrib_Value,0))	 AS Attrib_Value from @_vTDC_All_Template_BaseData TATB INNER JOIN GPM_Metrics_TDC_Saving GMTS ON TATB.Attrib_Id=GMTS.Attrib_Id
													WHERE GMTS.Attrib_Type='COST OF SAVINGS' AND GMTS.Is_Computed_Attrib='N' AND TATB.YearMonth= CAST(REPLACE (A.YearMonth,'-','') AS INT)) AS Attrib_Value
					 
					 FROM @_vYearMonth_Table A 
                     ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
					 UNION ALL
					 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, NULL, B.Display_Order FROM
                     (SELECT 55 As Attrib_Id, A.YearMonth As YearMonth from @_vYearMonth_Table A 
                     ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id

					 ;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
									SELECT TATB.YearMonth,TATB.Attrib_Id, CASE WHEN TATB.Attrib_Id = 32 THEN  ISNULL(TATB.Attrib_Value,0)*-1 
														ELSE ISNULL(TATB.Attrib_Value,0) END  AS Attrib_Value
														 FROM @_vTDC_All_Template_BaseData TATB

														 INNER JOIN GPM_Metrics_TDC_Saving On TATB.Attrib_Id=GPM_Metrics_TDC_Saving.Attrib_Id
												WHERE GPM_Metrics_TDC_Saving.Attrib_Type='CONVERSION SCORECARD' /*GSS-Conversion*/
												AND GPM_Metrics_TDC_Saving.Is_Computed_Attrib='N'												
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 18 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id

					 			

								;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
								AS  
								(  
											SELECT TATB.YearMonth,Attrib_Id,
					 											CASE WHEN TATB.Attrib_Id = 32 THEN  ISNULL(TATB.Attrib_Value ,0)*-1 
																 WHEN TATB.Attrib_Id = 33 THEN  ISNULL(TATB.Attrib_Value,0)*-1  
																 WHEN TATB.Attrib_Id = 34 THEN  ISNULL(TATB.Attrib_Value,0)*-1
																 WHEN TATB.Attrib_Id = 35 THEN  ISNULL(TATB.Attrib_Value,0)*-1
																 WHEN TATB.Attrib_Id = 36 THEN  ISNULL(TATB.Attrib_Value,0)*-1
																 ELSE ISNULL(TATB.Attrib_Value,0)  END 
																 AS Attrib_Value
																 FROM @_vTDC_All_Template_BaseData TATB 
																 WHERE TATB.Attrib_Id IN
																		(
																			17,22,27,32, /*TT-Raw Material*/
																			23,28,33, /*TT-Conversion*/
																			19,24,29,34, /*TT-Other CGS*/
																			20,25,30,35, /*TT-Transportation*/
																			21,26,31,36, /*TT-SAG*/
																			37,38,39,40,41,42,43,44,45,46,47,48 /*GSS-Conversion*/
																		)  
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 49 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id

									/*TT-Raw Material - 10 */								
									;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
									SELECT TATB.YearMonth,TATB.Attrib_Id, CASE WHEN TATB.Attrib_Id = 32 THEN  ISNULL(TATB.Attrib_Value,0)*-1 
														ELSE ISNULL(TATB.Attrib_Value,0) END  AS Attrib_Value
														 FROM @_vTDC_All_Template_BaseData TATB
												WHERE TATB.Attrib_Id IN(17,22,27,32) 
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 10 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id


									/*TT-Conversion - 11*/
									;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
									SELECT TATB.YearMonth,TATB.Attrib_Id,(CASE WHEN TATB.Attrib_Id = 33 THEN  ISNULL(TATB.Attrib_Value,0)*-1
												ELSE ISNULL(TATB.Attrib_Value,0) END) As Attrib_Value FROM @_vTDC_All_Template_BaseData TATB
												WHERE 
												TATB.Attrib_Id IN(
												SELECT 23 
													UNION 
												SELECT 28 
													UNION 
												SELECT 33
													UNION 
												SELECT GPM_Metrics_TDC_Saving.Attrib_Id FROM GPM_Metrics_TDC_Saving	WHERE GPM_Metrics_TDC_Saving.Attrib_Type='CONVERSION SCORECARD' 
												AND GPM_Metrics_TDC_Saving.Is_Computed_Attrib='N' /*GSS-Conversion*/)
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 11 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id


									/*TT-Other CGS - 12*/		
									;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
										SELECT TATB.YearMonth,TATB.Attrib_Id, CASE WHEN TATB.Attrib_Id = 34 THEN  ISNULL(TATB.Attrib_Value,0)*-1 
														ELSE ISNULL(TATB.Attrib_Value,0) END 

														AS Attrib_Value
														 FROM @_vTDC_All_Template_BaseData TATB
												WHERE TATB.Attrib_Id IN(19,24,29,34)
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 12 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id


									/* TT-Transportation -13 */

									;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
										SELECT TATB.YearMonth, TATB.Attrib_Id,  CASE WHEN TATB.Attrib_Id = 35 THEN  ISNULL(TATB.Attrib_Value,0)*-1 
														ELSE ISNULL(TATB.Attrib_Value,0) END  AS Attrib_Value
														 FROM @_vTDC_All_Template_BaseData TATB
												WHERE 
												TATB.Attrib_Id IN(20,25,30,35)
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 13 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id


									/* TT-SAG - 14 */
									;WITH TT_Tdc_Basline_Value (YearMonth,Attrib_Id, Attrib_Value)  
									AS  
									(  
										SELECT TATB.YearMonth, TATB.Attrib_Id,  CASE WHEN TATB.Attrib_Id = 36 THEN  ISNULL(TATB.Attrib_Value,0)*-1 
														ELSE ISNULL(TATB.Attrib_Value,0) END 

														AS Attrib_Value
														 FROM @_vTDC_All_Template_BaseData TATB
												WHERE TATB.Attrib_Id IN(21,26,31,36)
									)
									INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order)
									SELECT TDC_Agg_Data.Attrib_Id, B.Attrib_Name, TDC_Agg_Data.YearMonth, Attrib_Value, B.Display_Order FROM
									(
									SELECT 14 AS Attrib_Id, YearMonth.YearMonth,					
									(SELECT SUM(Attrib_Value) FROM TT_Tdc_Basline_Value WHERE TT_Tdc_Basline_Value.YearMonth=CAST(REPLACE(YearMonth.YearMonth,'-','') AS INT)) AS Attrib_Value
									FROM @_vYearMonth_Table YearMonth
									) TDC_Agg_Data INNER JOIN GPM_Metrics_TDC_Saving B On TDC_Agg_Data.Attrib_Id= B.Attrib_Id

				
					 SELECT Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Display_Order       FROM @_vTDCMetric
                     ORDER BY  YearMonth,Display_Order Asc
                     

					DROP TABLE #Temp_Dashboard
							
							
END


 

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetPortfolioDetails_ByPFId]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetPortfolioDetails_ByPFId]
@vPortfolio_Id INT
AS
BEGIN
	DECLARE @_vDescendFrom VARCHAR(MAX)
	DECLARE @_vPortfolioTag VARCHAR(MAX)
	DECLARE @_vStatus_Ids VARCHAR(MAX)
	DECLARE @_vTemp Table(Status_Id INT)



SELECT @_vDescendFrom=(SELECT '~' + ISNULL(GWPD.Region_Code,'')+'|'+ISNULL(GWPD.Country_Code,'')+ '|'+ISNULL(CAST(GWPD.Location_ID AS VARCHAR),'') 
FROM GPM_WT_Portfolio_DescendFrom GWPD WHERE GWPD.Portfolio_Id=@vPortfolio_Id
FOR XML PATH(''))

SELECT @_vPortfolioTag=(SELECT '~' + ISNULL(CAST(GWPD.Portfolio_Tag_Id AS VARCHAR),'')+'|'+ISNULL(GWPD.Portfolio_Tag_Value,'')
FROM GPM_WT_Portfolio_Tag_Value GWPD WHERE GWPD.Portfolio_Id=@vPortfolio_Id
FOR XML PATH(''))

Select @_vStatus_Ids = (SELECT Status_Ids FROM GPM_WT_Portfolio WHERE Portfolio_Id = @vPortfolio_Id)

INSERT INTO @_vTemp SELECT Value FROM Fn_SplitDelimetedData(',',@_vStatus_Ids)

DECLARE @_vStatus_Ids_With_Desc VARCHAR(MAX)
SELECT @_vStatus_Ids_With_Desc = (SELECT  ',' + ISNULL(CAST(GWT.Proj_Track_Id AS VARCHAR),'')
FROM GPM_Project_Tracking GWT INNER JOIN @_vTemp T On GWT.Proj_Track_Id=T.Status_Id
FOR XML PATH(''))

DECLARE @_vPAFC VARCHAR(MAX)
SELECT @_vPAFC = (SELECT  '~' + ISNULL(CAST(GWPAF.Criteria_Id AS VARCHAR),'') +'|'+ISNULL(CAST(GWPAF.Filter_Value AS VARCHAR),'')
FROM GPM_WT_Portfolio_Advance_Filter GWPAF WHERE Portfolio_Id = @vPortfolio_Id
FOR XML PATH(''))


SELECT GWP.Portfolio_Id,Portfolio_Name,Portfolio_Desc,@_vPortfolioTag AS Portfolio_Tag,WT_Codes,SUBSTRING(@_vDescendFrom,2,LEN(@_vDescendFrom)) AS DescendFrom,SUBSTRING(@_vStatus_Ids_With_Desc,2,LEN(@_vStatus_Ids_With_Desc)) AS Status_Ids,Status_Change_Id,Status_Change_Period_Id,GPP.Period_Desc,Status_Change_StartDate,Status_Change_EndDate,Project_Leads,
Team_Members,Sponsors,FinancialReps,Approvers,Project_StartDate_Period_Id,Project_Start_StartDate,Project_Start_EndDate,Project_EndDate_Period_Id,Project_End_StartDate,
Project_End_EndDate,Descend_From_User_DefaultLoc,Archived_Projects,BP_Projects,Replace_Program_By_Memebr,Edit_By_Sharees,Include_Projects,Exclude_Projects,Include_Copied_Project,Include_Replicated_Project,SUBSTRING(@_vPAFC,2,LEN(@_vPAFC)) AS Advance_Filter_Criteria,GWP.Is_Global,
Created_By,Created_Date,Last_Modified_By,Last_Modified_Date FROM GPM_WT_Portfolio GWP
LEFT OUTER JOIN GPM_Portfolio_Period GPP On GWP.Status_Change_Period_Id = GPP.Period_Id
LEFT OUTER JOIN GPM_WT_Portfolio_Advance_Filter GWPAF On GWP.Portfolio_Id = GWPAF.Portfolio_Id
WHERE GWP.Portfolio_Id=@vPortfolio_Id AND GWP.Is_Deleted_Ind = 'N'

END 






GO
/****** Object:  StoredProcedure [dbo].[Sp_GetPortofolioList_ByUser]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_GetPortofolioList_ByUser]
@vGD_User_Id VARCHAR(10)
AS
BEGIN
DECLARE @_vPeople INT=(SELECT PF_Share_Type_Id FROM GPM_Portfolio_Share_Type WHERE PF_Share_Type_Desc='People')
DECLARE @_vRegion INT=(SELECT PF_Share_Type_Id FROM GPM_Portfolio_Share_Type WHERE PF_Share_Type_Desc='Region')
DECLARE @_vCountry INT=(SELECT PF_Share_Type_Id FROM GPM_Portfolio_Share_Type WHERE PF_Share_Type_Desc='Country')
DECLARE @_vLocation INT=(SELECT PF_Share_Type_Id FROM GPM_Portfolio_Share_Type WHERE PF_Share_Type_Desc='Location')



SELECT GWP.Portfolio_Id,GWP.Portfolio_Name,GWP.Portfolio_Desc, GWP.Created_By As Portfolio_Onwer_Id, 
ISNULL(GU.User_First_Name,'')+' '+ISNULL(GU.User_Last_Name,'') AS Portfolio_Owner,NULL As Is_Active,

/*
SUBSTRING((SELECT '~' + CAST(GWPS.Share_Type_Id AS VARCHAR(10))+'|'+GWPS.Share_With_Values FROM GPM_WT_Portfolio_Sharing GWPS WHERE GWPS.Portfolio_Id=GWP.Portfolio_Id
FOR XML PATH('')),2,100000) AS ShareWith

*/

SUBSTRING((SELECT '~' + TAB.PFShareValues FROM 

(SELECT DISTINCT GWPS.Portfolio_Id,
CAST(Share_Type_Id AS VARCHAR(10))+'|'+(SUBSTRING((SELECT ',' + GWPS1.Share_With_Values FROM GPM_WT_Portfolio_Sharing GWPS1 
WHERE GWPS1.Portfolio_Id=GWP.Portfolio_Id and GWPS1.Share_Type_Id=GWPS.Share_Type_Id
FOR XML PATH('')),2,100000)) AS PFShareValues
FROM GPM_WT_Portfolio_Sharing GWPS WHERE GWPS.Portfolio_Id=GWP.Portfolio_Id) TAB

WHERE TAB.Portfolio_Id=GWP.Portfolio_Id
FOR XML PATH('')),2,100000) AS SharedWith,GWP.Is_Global,GWP.Edit_By_Sharees



FROM GPM_WT_Portfolio GWP LEFT OUTER JOIN GPM_User GU On GWP.Created_By=GU.GD_User_Id 
	LEFT OUTER JOIN GPM_WT_Portfolio_Visibility GWPV On GWP.Portfolio_Id=GWPV.Portfolio_Id

	WHERE GWP.Portfolio_Id IN(
	SELECT Portfolio_Id FROM  GPM_WT_Portfolio WHERE Created_By=@vGD_User_Id
	/*
	UNION
	SELECT Portfolio_Id FROM GPM_WT_Portfolio_Sharing WHERE Share_Type_Id=@_vPeople AND Share_With_Values=@vGD_User_Id
	UNION 
	SELECT Portfolio_Id FROM GPM_WT_Portfolio_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Region_Code
	WHERE Share_Type_Id=@_vRegion AND GU.GD_User_Id=@vGD_User_Id
	UNION
	SELECT Portfolio_Id FROM GPM_WT_Portfolio_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Country_Code
	WHERE Share_Type_Id=@_vCountry AND GU.GD_User_Id=@vGD_User_Id
	UNION
	SELECT Portfolio_Id FROM GPM_WT_Portfolio_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Location_Id
	WHERE Share_Type_Id=@_vLocation AND GU.GD_User_Id=@vGD_User_Id
	*/
)
 AND GWP.Is_Deleted_Ind='N' OR GWPV.User_List LIKE '%'+@vGD_User_Id+'%'
 
 --ORDER BY GWP.Portfolio_Name

END







GO
/****** Object:  StoredProcedure [dbo].[Sp_GetProjectList_ByPFID]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_GetProjectList_ByPFID]
@vPortfolio_Id INT,
@vMsg_OUT VARCHAR(100) OUT
AS
BEGIN

--DECLARE @vPortfolio_Id INT=79
--DECLARE @vLayout_Id INT=212
--DECLARE @vCountry_Code CHAR(7)='USA|USD'
----DECLARE @_vCurrencyCode CHAR(3)='AUD'
--DECLARE @vLogin_User_Id VARCHAR(10) = 'A398351'
SET NOCOUNT ON
Declare @_vRow_ID INT
DECLARE @_vdynSql nvarchar(Max) = ''
DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vObjCnt INT=0, @_vObjMaxCnt INT=0
DECLARE @_vDummy INT=0
DECLARE @_vWT_Project_Table_Name VARCHAR(100)='GPM_WT_Project'
DECLARE @_vProjects_WT_Codes AS TABLE(WT_Code VARCHAR(10))
DECLARE @_vLocationClause VARCHAR(max)=NULL

DECLARE @_vPF_WT_Codes varchar(1000)
DECLARE @_vPF_Status_Ids VARCHAR(100)
DECLARE @_vStatus_Change_Id INT
DECLARE @_vStatus_Change_Period_Id INT
DECLARE @_vStatusChange_StartDt DATE = NULL
DECLARE @_vStatusChange_EndDt DATE = NULL
DECLARE @_vProject_StartDate_Period_Id INT
DECLARE @_vProject_Start_StartDate DATE = NULL
DECLARE @_vProject_Start_EndDate DATE = NULL
DECLARE @_vProject_EndDate_Period_Id  INT
DECLARE @_vProject_End_StartDate DATE = NULL
DECLARE @_vProject_End_EndDate DATE = NULL
DECLARE @_vProject_Leads VARCHAR(8000) = NULL
DECLARE @_vTeam_Members VARCHAR(8000) = NULL
DECLARE @_vSponsors VARCHAR(8000) = NULL
DECLARE @_vFinancialReps VARCHAR(8000) = NULL
DECLARE @_vApprovers VARCHAR(8000) = NULL
DECLARE @_vIncludeProjects VARCHAR(8000) = NULL
DECLARE @_vExcludeProjects VARCHAR(8000) = NULL
DECLARE @_vArchived_Projects CHAR(1)=NULL

--DECLARE @_vPortfolioProjectListTable AS TABLE (WT_Project_Id INT, WT_Code VARCHAR(10), Project_Seq VARCHAR(100), Project_Name NVARCHAR(2000),XML_Data XML)
DECLARE @_vProcessedWTndTag_Table AS TABLE (WT_Code varchar(10), TG_Table_Name VARCHAR(100))

DECLARE @_vRegion_Table AS TABLE (Region_Code Varchar(5), Is_Common_Region CHAR(1) DEFAULT 'N')
DECLARE @_vRegionList VARCHAR(8000)=NULL
DECLARE @_vRegion_Code varchar(5)

DECLARE @_vCountry_Table AS TABLE (Country_Code char(3), Is_Common_Country CHAR(1) DEFAULT 'N')
DECLARE @_vCountryList VARCHAR(8000)=NULL
DECLARE @_vCountry_Code char(3)

DECLARE @_vLocation_Table AS TABLE (Location_Id VARCHAR(5), Is_Common_Location CHAR(1) DEFAULT 'N')
DECLARE @_vLocationList VARCHAR(8000)=NULL
DECLARE @_vLocation_Id VARCHAR(10)

Declare @_vProcessedTag TABLE (Portfolio_Tag_Id INT)

DECLARE @_vWTQueriesTab AS TABLE(Row_ID INT IDENTITY(1,1), WT_Code VARCHAR(5), SelectField VARCHAR(MAX), SelectFrom VARCHAR(MAX), SelectWhere VARCHAR(MAX), IncludeProject CHAR(1) DEFAULT 'N')
DECLARE @_vdynSqlSelectField nvarchar(Max) = ''
DECLARE @_vdynSqlFrom nvarchar(Max) = ''
DECLARE @_vdynSqlWhere nvarchar(Max) = ''
DECLARE @_vdynSqlFinalQuery nvarchar(Max) = ''

Declare @_vTab_Dyn_SQL_Table TABLE (Row_ID INT IDENTITY(1,1), Portfolio_Tag_Id Int,WT_Table_Name varchar(100), WT_Table_FK_Col_Name varchar(100), TG_Table_Name varchar(100), TG_Table_PK_Col_Name varchar(100), Portfolio_Tag_Value varchar(8000))       
Declare @_vPortfolio_Tag_Id int
Declare @_vPortfolio_Tag_Value varchar(8000)
Declare @_vWT_Table_Name varchar(100) 
Declare @_vWT_Table_FK_Col_Name varchar(100) 
Declare @_vTG_Table_Name varchar(100)
Declare @_vTG_Table_PK_Col_Name varchar(100)


DECLARE @_vTDCType_ColPrefix VARCHAR(100)
DECLARE @_vTDCAttribColName VARCHAR(500)
DECLARE @_vDisplay_Order NUMERIC(15,10)

DECLARE @_vDashboardColumnMap_Table AS Table (SelectField VARCHAR(500),  Display_Order NUMERIC(15,10), Is_Tdc_Attrib BIT DEFAULT 0)        

DECLARE @_vWT_Table_Name_Cur varchar(100)
DECLARE @_vWT_Code_Cur  varchar(10)
DECLARE @_vBP_Portfolio_Tag_Value VARCHAR(8000)

DECLARE @_vHeaderList VARCHAR(MAX)
DECLARE @_vColumnList VARCHAR(MAX)
DECLARE @_vdynInsert VARCHAR(MAX)
DECLARE @_vSummaryQuery VARCHAR(MAX)
DECLARE @_vExchangeRateQuery VARCHAR(MAX)
DECLARE @_vTDC_Table_Name VARCHAR(200)


DECLARE @_vProject_Lead_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vTeam_Members_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vSponsors_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vFinancialReps_Table As Table (GD_User_Id VARCHAR(10))
DECLARE @_vApprovers_Table As Table (GD_User_Id VARCHAR(10))


DECLARE @_vIncWT_Project_ID INT
DECLARE @_vIncWT_Code VARCHAR(10)
DECLARE @_vIncWT_Id INT
DECLARE @_vIncWT_Project_Number VARCHAR(15)
DECLARE @_vIncProjects_Table AS TABLE(IncWT_Project_ID INT,IncWT_Code VARCHAR(10),IncWT_Id INT,IncWT_Project_Number VARCHAR(15))


DECLARE @_vExcWT_Project_ID INT
DECLARE @_vExcWT_Code VARCHAR(10)
DECLARE @_vExcWT_Id INT
DECLARE @_vExcWT_Project_Number VARCHAR(15)
DECLARE @_vExcProjects_Table AS TABLE(ExcWT_Project_ID INT,ExcWT_Code VARCHAR(10),ExcWT_Id INT,ExcWT_Project_Number VARCHAR(15))

DECLARE @_vAdvance_Criteria_Id VARCHAR(100)--INT
DECLARE @_vFilter_Value VARCHAR(100)
DECLARE @_vAttrib_Seq INT
DECLARE @_vCurrencyCode CHAR(3)

DECLARE @_vDashBoardData_Table AS Dashboad_Data

IF NOT EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id AND Is_Deleted_Ind = 'N')
	BEGIN
		SELECT @vMsg_OUT = 'Portfolio Not Found'
		RETURN 0
	END

SELECT 
	@_vPF_WT_Codes=WT_Codes,
	@_vPF_Status_Ids=Status_Ids,
	@_vStatus_Change_Id = Status_Change_Id,
	@_vStatus_Change_Period_Id = Status_Change_Period_Id,
	@_vStatusChange_StartDt = Status_Change_StartDate,
	@_vStatusChange_EndDt = Status_Change_EndDate,

	@_vProject_StartDate_Period_Id = Project_StartDate_Period_Id,
	@_vProject_Start_StartDate = Project_Start_StartDate,
	@_vProject_Start_EndDate = Project_Start_EndDate,
	@_vProject_EndDate_Period_Id  = Project_EndDate_Period_Id,
	@_vProject_End_StartDate = Project_End_StartDate,
	@_vProject_End_EndDate = Project_End_EndDate,

	@_vProject_Leads = Project_Leads,
	@_vTeam_Members = Team_Members,
	@_vSponsors = Sponsors,
	@_vFinancialReps = FinancialReps,
	@_vApprovers = Approvers,
	@_vIncludeProjects=Include_Projects,
	@_vExcludeProjects=Exclude_Projects,
	@_vArchived_Projects=Archived_Projects

FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id

IF(LEN(LTRIM(RTRIM((SELECT CAST(Criteria_Id AS VARCHAR(10)) FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id=@vPortfolio_Id FOR XML PATH('')))))>2)
	SELECT @_vAdvance_Criteria_Id =12
ELSE
	BEGIN
		SELECT @_vAdvance_Criteria_Id = Criteria_Id,
			   @_vFilter_Value = Filter_Value
		FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id=@vPortfolio_Id
	END

IF(LEN(@_vIncludeProjects)>0)
		INSERT INTO @_vIncProjects_Table(IncWT_Project_ID,IncWT_Code,IncWT_Id,IncWT_Project_Number)
			SELECT WT_Project_ID,WT_Code,WT_Id,WT_Project_Number FROM GPM_WT_Project WHERE EXISTS(SELECT Value FROM DBO.Fn_SplitDelimetedData(',',@_vIncludeProjects) TAB WHERE TAB.Value=GPM_WT_Project.WT_Project_ID)

IF(LEN(@_vExcludeProjects)>0)
		INSERT INTO @_vExcProjects_Table(ExcWT_Project_ID,ExcWT_Code,ExcWT_Id,ExcWT_Project_Number)
			SELECT WT_Project_ID,WT_Code,WT_Id,WT_Project_Number FROM GPM_WT_Project WHERE EXISTS(SELECT Value FROM DBO.Fn_SplitDelimetedData(',',@_vExcludeProjects) TAB WHERE TAB.Value=GPM_WT_Project.WT_Project_ID)


IF(@_vPF_WT_Codes IS NULL OR LEN(LTRIM(RTRIM(@_vPF_WT_Codes)))<=0)	
	SELECT @_vPF_WT_Codes =(SELECT  STUFF((SELECT ',' + WT_Code [text()] FROM GPM_Project_Template WHERE  Is_Deleted_Ind='N' FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'')) 

	INSERT INTO @_vProjects_WT_Codes(WT_Code) 
			SELECT RTRIM(LTRIM(Value)) FROM Fn_SplitDelimetedData(',',@_vPF_WT_Codes)
       
	   
IF(LEN(RTRIM(LTRIM( @_vProject_Leads)))>0)
	INSERT INTO @_vProject_Lead_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vProject_Leads) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vTeam_Members)))>0)
	INSERT INTO @_vTeam_Members_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vTeam_Members) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vSponsors)))>0)
	INSERT INTO @_vSponsors_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vSponsors) WHERE LEN(RTRIM(LTRIM(Value)))>0

IF(LEN(RTRIM(LTRIM( @_vFinancialReps)))>0)
	INSERT INTO @_vFinancialReps_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vFinancialReps) WHERE LEN(RTRIM(LTRIM(Value)))>0


IF(LEN(RTRIM(LTRIM( @_vApprovers)))>0)
	INSERT INTO @_vApprovers_Table (GD_User_Id) SELECT Value FROM dbo.Fn_SplitDelimetedData(',',@_vApprovers) WHERE LEN(RTRIM(LTRIM(Value)))>0

DECLARE Outer_Cursor CURSOR FOR
SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN
       (SELECT WT_Code FROM @_vProjects_WT_Codes
	   UNION ALL
	   SELECT DISTINCT IncWT_Code FROM @_vIncProjects_Table)	


	INSERT INTO @_vRegion_Table (Region_Code, Is_Common_Region)
     SELECT DISTINCT Region_Code, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND LEN(RTRIM(LTRIM(Region_Code)))>0

    INSERT INTO @_vCountry_Table (Country_Code, Is_Common_Country)
     SELECT DISTINCT Country_Code, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND LEN(RTRIM(LTRIM(Country_Code)))>0

    INSERT INTO @_vLocation_Table (Location_Id, Is_Common_Location)
     SELECT DISTINCT Location_ID, 'Y' FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
	 AND Location_ID>0


	 

OPEN Outer_Cursor
FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

WHILE @@FETCH_STATUS = 0
       
BEGIN

--PRINT @_vWT_Code_Cur

                           SELECT 
                                                  @_vPortfolio_Tag_Id=NULL,
                                                  @_vWT_Table_Name=NULL,
                                                  @_vWT_Table_FK_Col_Name=NULL,
                                                  @_vTG_Table_Name=NULL,
                                                  @_vTG_Table_PK_Col_Name= NULL,
                                                  @_vPortfolio_Tag_Value=NULL,
                                                  @_vdynSql=NULL,
                                                  @_vdynSqlWhere='',
                                                  @_vdynSqlSelectField='',
                                                  @_vdynSqlFrom='',
												  @_vLocationList='',
												  @_vCountryList='',
												  @_vLocationList=''

                                                
												DELETE FROM @_vRegion_Table WHERE Is_Common_Region='N'
												DELETE FROM @_vCountry_Table WHERE Is_Common_Country='N'
												DELETE FROM @_vLocation_Table WHERE Is_Common_Location='N'
     

    
                                                IF(@_vWT_Code_Cur='FI' AND @_vWT_Table_Name_Cur='GPM_WT_DMAIC')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_DMAIC ON GPM_WT_Project.WT_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_DMAIC.DMAIC_Number'

													   
                                                       --SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_DMAIC.DMAIC_Number AS Project_Seq,GPM_WT_DMAIC.DMAIC_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_DMAIC.DMAIC_Number AS Project_Seq,GPM_WT_DMAIC.DMAIC_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField,  Display_Order)
																VALUES('WT_Project_ID',  -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',  -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name', -1)
                                                END

                                                IF(@_vWT_Code_Cur='MDPO' AND @_vWT_Table_Name_Cur='GPM_WT_MDPO')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_MDPO ON GPM_WT_Project.WT_Id=GPM_WT_MDPO.MDPO_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_MDPO.MDPO_Number' 
													   

                                                       --SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_MDPO.MDPO_Number AS Project_Seq,GPM_WT_MDPO.MDPO_Name As Project_Name'
													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_MDPO.MDPO_Number AS Project_Seq,GPM_WT_MDPO.MDPO_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',  -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END

												IF(@_vWT_Code_Cur='GBP' AND @_vWT_Table_Name_Cur='GPM_WT_GBS')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GBS ON GPM_WT_Project.WT_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GBS.GBS_Number' 

                                                       ---SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GBS.GBS_Number AS Project_Seq,GPM_WT_GBS.GBS_Name As Project_Name'
													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GBS.GBS_Number AS Project_Seq,GPM_WT_GBS.GBS_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',-4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END

												IF(@_vWT_Code_Cur='GDI' AND @_vWT_Table_Name_Cur='GPM_WT_GDI')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GDI ON GPM_WT_Project.WT_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GDI.GDI_Number' 

                                                       ---SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GDI.GDI_Number AS Project_Seq,GPM_WT_GDI.GDI_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_GDI.GDI_Number AS Project_Seq,GPM_WT_GDI.GDI_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',  -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END

												IF(@_vWT_Code_Cur='IDEA' AND @_vWT_Table_Name_Cur='GPM_WT_Idea')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Idea ON GPM_WT_Project.WT_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Idea.Idea_Number' 

                                                       ---SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Idea.Idea_Number AS Project_Seq,GPM_WT_Idea.Idea_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Idea.Idea_Number AS Project_Seq,GPM_WT_Idea.Idea_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID', -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END

												IF(@_vWT_Code_Cur='SC' AND @_vWT_Table_Name_Cur='GPM_WT_Supply_Chain')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Supply_Chain ON GPM_WT_Project.WT_Id=GPM_WT_Supply_Chain.SC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Supply_Chain.SC_Number' 

                                                       --SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Supply_Chain.SC_Number AS Project_Seq,GPM_WT_Supply_Chain.SC_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Supply_Chain.SC_Number AS Project_Seq,GPM_WT_Supply_Chain.SC_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID', -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code',-3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name', -1)

												END

												IF(@_vWT_Code_Cur='RD' AND @_vWT_Table_Name_Cur='GPM_WT_NMTP')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_NMTP ON GPM_WT_Project.WT_Id=GPM_WT_NMTP.QTI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_NMTP.QTI_Number' 

                                                       --SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_NMTP.QTI_Number AS Project_Seq,GPM_WT_NMTP.QTI_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_NMTP.QTI_Number AS Project_Seq,GPM_WT_NMTP.QTI_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',  -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code', -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq', -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name', -1)

												END

												IF(@_vWT_Code_Cur='PSC' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement ON GPM_WT_Project.WT_Id=GPM_WT_Procurement.PSC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement.PSC_Number' 

                                                       SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Procurement.PSC_Number AS Project_Seq,GPM_WT_Procurement.PSC_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',-4)
--

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code',  -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq',-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END
                                                    
												IF(@_vWT_Code_Cur='PSIMP' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement_Simple')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement_Simple ON GPM_WT_Project.WT_Id=GPM_WT_Procurement_Simple.PSIMP_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement_Simple.PSIMP_Number' 

                                                       --SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Procurement_Simple.PSIMP_Number AS Project_Seq,GPM_WT_Procurement_Simple.PSIMP_Name As Project_Name'

													   SELECT @_vdynSqlSelectField=' SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Procurement_Simple.PSIMP_Number AS Project_Seq,GPM_WT_Procurement_Simple.PSIMP_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',-4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code',  -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq', -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name',-1)

												END                                      

												IF(@_vWT_Code_Cur='REP' AND @_vWT_Table_Name_Cur='GPM_WT_Replication')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Replication ON GPM_WT_Project.WT_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Replication.Replication_Number' 

                                                       ---SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +',CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Replication.Replication_Number AS Project_Seq,GPM_WT_Replication.Replication_Name As Project_Name'

													   SELECT @_vdynSqlSelectField='SELECT CAST(GPM_WT_Project.WT_Project_ID AS VARCHAR(20)) AS WT_Project_ID, GPM_WT_Project.WT_Code, GPM_WT_Replication.Replication_Number AS Project_Seq,GPM_WT_Replication.Replication_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Project_ID')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Project_ID',  -4)


													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='WT_Code')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('WT_Code',  -3)


													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Seq', -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, Display_Order)
																VALUES('Project_Name', -1)

												END                                      
       
								
                                                INSERT INTO @_vTab_Dyn_SQL_Table (Portfolio_Tag_Id,WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value)
                                                SELECT B.Portfolio_Tag_Id, B.WT_Table_Name, B.WT_Table_FK_ColName, B.TG_Table_Name, B.TG_Table_PK_ColName,REPLACE(A.Portfolio_Tag_Value,'^',',')
                                                FROM GPM_WT_Portfolio_Tag_Value A 
                                                INNER JOIN GPM_Portfolio_Tag B On A.Portfolio_Tag_Id=B.Portfolio_Tag_Id
                                                WHERE a.Portfolio_Id=@vPortfolio_Id AND B.WT_Table_Name=@_vWT_Table_Name_Cur
												AND A.Portfolio_Tag_Id NOT IN(123,124)
												
												                                           
                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region' 

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vRegion_Table (Region_Code, Is_Common_Region)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vRegion_Table RT WHERE RT.Region_Code=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
                                                       
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)

                                                END


												SELECT
                                                              @_vPortfolio_Tag_Id= NULL,
                                                              @_vPortfolio_Tag_Value=NULL,
                                                              @_vWT_Table_FK_Col_Name=NULL,
                                                              @_vTG_Table_Name=NULL,
                                                              @_vTG_Table_PK_Col_Name=NULL

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

												
                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vCountry_Table (Country_Code, Is_Common_Country)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vCountry_Table CT WHERE CT.Country_Code=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
                                                
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                       
                                                END


												SELECT
                                                              @_vPortfolio_Tag_Id= NULL,
                                                              @_vPortfolio_Tag_Value=NULL,
                                                              @_vWT_Table_FK_Col_Name=NULL,
                                                              @_vTG_Table_Name=NULL,
                                                              @_vTG_Table_PK_Col_Name=NULL

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vLocation_Table (Location_Id, Is_Common_Location)
                                                       SELECT TAB.Value,'N' FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vLocation_Table LT WHERE LT.Location_Id=TAB.Value)
													   AND LEN(RTRIM(LTRIM(TAB.Value)))>0
													   
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)

                                                END
                                                

												IF ((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='N') >0 OR
														(SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='N')>0 OR
														(SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='N')>0 )


												BEGIN
																IF((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='N')>0)
																BEGIN
																	SELECT
																				  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																				  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																				  @_vTG_Table_Name=GPT.TG_Table_Name,
																				  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region'

																	INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
                                                
																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

																	SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table WHERE Is_Common_Region='N' FOR XML PATH(''))
																	SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
																	SELECT @_vdynSqlWhere =' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'
																END

                                                
							
                                                
																IF((SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='N')>0)
																BEGIN
																	SELECT
																				  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																				  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																				  @_vTG_Table_Name=GPT.TG_Table_Name,
																				  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

																	INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)

																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name


																	 SET @_vCountryList= (SELECT  ','+''''+ Country_Code+'''' FROM @_vCountry_Table WHERE Is_Common_Country='N' FOR XML PATH(''))
																	 SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))
																	 IF (LEN(@_vdynSqlWhere)>0)
																			SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
																	 ELSE
																			SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'

																END

												
																IF((SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='N')>0)
																BEGIN

																	SELECT
																			@_vPortfolio_Tag_Id= NULL,
																			@_vWT_Table_FK_Col_Name=NULL,
																			@_vTG_Table_Name=NULL,
																			@_vTG_Table_PK_Col_Name=NULL

																	SELECT
																			@_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
																			@_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
																			@_vTG_Table_Name=GPT.TG_Table_Name,
																			@_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
																	FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

																	INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
												
																	SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name


																	SET @_vLocationList= (SELECT  ','+ Location_Id FROM @_vLocation_Table WHERE Is_Common_Location='N' FOR XML PATH(''))
																	SET @_vLocationList= SUBSTRING(@_vLocationList,2, LEN(@_vLocationList))
												
																	IF (LEN(@_vdynSqlWhere)>0)
																		SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																	ELSE
																		SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																END
																				
										END  /* END IF FOR TEMPLATE REGION, COUNTRY AND  LOCATION*/
										ELSE
										IF ((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='Y') >0 OR
												(SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='Y')>0 OR
													(SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='Y')>0 )

										
										BEGIN
											SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

														
											
											IF((SELECT COUNT(*) FROM @_vRegion_Table WHERE Is_Common_Region='Y')>0)
												BEGIN

											
													SELECT
														  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
														  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
														  @_vTG_Table_Name=GPT.TG_Table_Name,
														  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
													FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region'
													
													
													INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
                                                
													SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

													SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table WHERE Is_Common_Region='Y' FOR XML PATH(''))
													SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))

													SELECT @_vdynSqlWhere +=' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'

													
												END

												SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

														

											IF((SELECT COUNT(*) FROM @_vCountry_Table WHERE Is_Common_Country='Y')>0)
												BEGIN
													SELECT
														  @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
														  @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
														  @_vTG_Table_Name=GPT.TG_Table_Name,
														  @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
													FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

													INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)

													SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

													SET @_vRegionList= (SELECT  ','+''''+ PT.Region_Code+'''' FROM @_vRegion_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Region_Code=GWPD.Region_Code  
													WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Region='Y' AND GWPD.Country_Code IS NULL FOR XML PATH(''))
													
													
													SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
													SET @_vRegionList= ISNULL(@_vRegionList,'''''')

													 IF (LEN(@_vdynSqlWhere)>0)
															--SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
															SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+' AND EXISTS(SELECT 1 FROM (SELECT Country_Code FROM GPM_Country WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Distinct Country_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Country_Code IS NOT NULL) COUNTRY_TAB WHERE COUNTRY_TAB.Country_Code='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'
													 ELSE
															--SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
															SELECT @_vdynSqlWhere = ' WHERE EXISTS(SELECT 1 FROM (SELECT Country_Code FROM GPM_Country WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Distinct Country_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Country_Code IS NOT NULL) COUNTRY_TAB WHERE COUNTRY_TAB.Country_Code='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'

															--   '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'

															
															
												END


												SELECT @_vCountryList=NULL,
														@_vRegionList=NULL,
														@_vLocationList=NULL

												IF((SELECT COUNT(*) FROM @_vLocation_Table WHERE Is_Common_Location='Y')>0)
													BEGIN
													
														SELECT
															@_vPortfolio_Tag_Id= NULL,
															@_vWT_Table_FK_Col_Name=NULL,
															@_vTG_Table_Name=NULL,
															@_vTG_Table_PK_Col_Name=NULL

														SELECT
															@_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
															@_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
															@_vTG_Table_Name=GPT.TG_Table_Name,
															@_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
														FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

														INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
												
														SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

														
														SET @_vRegionList= (SELECT  ','+''''+ PT.Region_Code+'''' FROM @_vRegion_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Region_Code=GWPD.Region_Code  
														WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Region='Y' AND GWPD.Country_Code IS NULL AND GWPD.Location_ID IS NULL FOR XML PATH(''))

														SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))

														SET @_vRegionList =ISNULL(@_vRegionList,'''''')

														

														SET @_vCountryList= (SELECT  ','+''''+ PT.Country_Code+'''' FROM @_vCountry_Table PT INNER JOIN GPM_WT_Portfolio_DescendFrom GWPD On PT.Country_Code=GWPD.Country_Code
														WHERE GWPD.Portfolio_Id=@vPortfolio_Id AND PT.Is_Common_Country='Y' AND GWPD.Location_ID IS NULL FOR XML PATH(''))

														SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))

														SET @_vCountryList =ISNULL(@_vCountryList,'''''')
														
														
														--IF(LEN(@_vRegionList)>0 AND LEN(@_vCountryList)>0)
															IF (LEN(@_vdynSqlWhere)>0)
																SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+' AND EXISTS(SELECT 1 FROM (SELECT Location_Id FROM GPM_Location WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Location_Id FROM GPM_Location WHERE Country_Code IN('+@_vCountryList+') UNION SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'
															ELSE
																SELECT @_vdynSqlWhere = ' WHERE EXISTS(SELECT 1 FROM (SELECT Location_Id FROM GPM_Location WHERE Region_Code IN('+@_vRegionList +') UNION SELECT Location_Id FROM GPM_Location WHERE Country_Code IN('+@_vCountryList+') UNION SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'

													END

													
										END /* END IF FOR DEFAULT (DESCENDED) REGION, COUNTRY AND  LOCATION*/

										
										

                                  IF((SELECT COUNT(*) FROM @_vTab_Dyn_SQL_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vTab_Dyn_SQL_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=NULL,
                                                       @_vWT_Table_Name=NULL,
                                                       @_vWT_Table_FK_Col_Name=NULL,
                                                       @_vTG_Table_Name=NULL,
                                                       @_vTG_Table_PK_Col_Name= NULL,
                                                       @_vPortfolio_Tag_Value=NULL

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=Portfolio_Tag_Id,
                                                       @_vWT_Table_Name=WT_Table_Name,
                                                       @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                       @_vTG_Table_Name=TG_Table_Name,
                                                       @_vTG_Table_PK_Col_Name=TG_Table_PK_Col_Name,
                                                       @_vPortfolio_Tag_Value=Portfolio_Tag_Value
                                                FROM @_vTab_Dyn_SQL_Table WHERE Row_ID=@_vCnt


													IF NOT EXISTS(SELECT 1 FROM @_vProcessedTag PT WHERE PT.Portfolio_Tag_Id=@_vPortfolio_Tag_Id)
                                                       BEGIN
																IF(@_vPortfolio_Tag_Id IN(28,41,16,53,72))
																BEGIN
																	IF(@_vPortfolio_Tag_Id=28)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_GDI_MS_Attrib WHERE GPM_WT_GDI_MS_Attrib.GDI_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_GDI_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_GDI_MS_Attrib WHERE GPM_WT_GDI_MS_Attrib.GDI_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_GDI_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id =41)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_DMAIC_MS_Attrib WHERE GPM_WT_DMAIC_MS_Attrib.DMAIC_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_DMAIC_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_DMAIC_MS_Attrib WHERE GPM_WT_DMAIC_MS_Attrib.DMAIC_Id=GPM_WT_DMAIC.DMAIC_Id AND  GPM_WT_DMAIC_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=16)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_Idea_MS_Attrib WHERE GPM_WT_Idea_MS_Attrib.Idea_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Idea_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_Idea_MS_Attrib WHERE GPM_WT_Idea_MS_Attrib.Idea_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Idea_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=53)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_Replication_MS_Attrib WHERE GPM_WT_Replication_MS_Attrib.Replication_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Replication_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_Replication_MS_Attrib WHERE GPM_WT_Replication_MS_Attrib.Replication_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Replication_MS_Attrib.Piller_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																	IF(@_vPortfolio_Tag_Id=72)
																		IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE EXISTS (SELECT 1 FROM GPM_WT_GBS_MS_Attrib WHERE GPM_WT_GBS_MS_Attrib.GBS_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_GBS_MS_Attrib.Gbs_Geography_Id  IN ('+@_vPortfolio_Tag_Value+'))'
																		ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND EXISTS (SELECT 1 FROM GPM_WT_GBS_MS_Attrib WHERE GPM_WT_GBS_MS_Attrib.GBS_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_GBS_MS_Attrib.Gbs_Geography_Id  IN ('+@_vPortfolio_Tag_Value+'))'

																END
																ELSE
																BEGIN

                                                                     INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)

                                                                     SET @_vdynSqlFrom += N' LEFT OUTER JOIN '+ @_vTG_Table_Name +N' ON '+@_vWT_Table_Name+N'.'+@_vWT_Table_FK_Col_Name+N' = '+@_vTG_Table_Name+N'.'+@_vTG_Table_PK_Col_Name;

                                                                     IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
                                                                     ELSE
                                                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
																END

                                                                     
                                                       END
												

                                                SELECT @_vCnt=MIN(Row_ID) FROM @_vTab_Dyn_SQL_Table WHERE Row_ID>@_vCnt
                                                       
                                         END
                                  END


								  IF(@_vPF_Status_Ids IS NOT NULL AND LEN(@_vPF_Status_Ids)>0)
								  IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                           SET @_vdynSqlWhere = ' WHERE '+ @_vWT_Project_Table_Name +'.Status_Id ' + ' IN ('+@_vPF_Status_Ids+')'
                                  ELSE
                                           SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') +' AND '+ @_vWT_Project_Table_Name +'.Status_Id' + ' IN ('+@_vPF_Status_Ids+')'

					
								

								IF(@_vStatus_Change_Period_Id IS NOT NULL AND @_vStatus_Change_Period_Id>0)
									BEGIN
										IF(@_vStatus_Change_Period_Id!=17)
											SELECT 
												@_vStatusChange_EndDt = GETDATE(),
												@_vStatusChange_StartDt = dbo.Fn_Portfolio_Period(@_vStatus_Change_Period_Id,GETDATE())
									

										IF(@_vStatusChange_StartDt IS NOT NULL AND @_vStatusChange_EndDt IS NOT NULL)
										BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
													SET @_vdynSqlWhere = ' WHERE EXISTS ( SELECT 1 FROM GPM_WT_Project_Status_History WHERE  
													GPM_WT_Project_Status_History.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND 
													GPM_WT_Project_Status_History.Status_Id='+CAST(@_vStatus_Change_Id AS VARCHAR(2)) +' AND GPM_WT_Project_Status_History.StatusChange_Date BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_StartDt,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_EndDt,112)+''',112))'
												ELSE
													
													SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND EXISTS ( SELECT 1 FROM GPM_WT_Project_Status_History WHERE  
													GPM_WT_Project_Status_History.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND 
													GPM_WT_Project_Status_History.Status_Id='+CAST(@_vStatus_Change_Id AS VARCHAR(2)) +' AND GPM_WT_Project_Status_History.StatusChange_Date BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_StartDt,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vStatusChange_EndDt,112)+''',112))'
										END
									END

									IF(@_vProject_StartDate_Period_Id IS NOT NULL AND @_vProject_StartDate_Period_Id>0)
									BEGIN
										IF(@_vProject_StartDate_Period_Id!=17)
												SELECT 
													@_vProject_Start_EndDate = GETDATE(),
													@_vProject_Start_StartDate = dbo.Fn_Portfolio_Period(@_vProject_StartDate_Period_Id,GETDATE())
							

										IF(@_vProject_Start_StartDate IS NOT NULL AND @_vProject_Start_EndDate IS NOT NULL)
											BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
								
													--SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_StartDate BETWEEN CAST('''+ CAST(@_vProject_Start_StartDate AS VARCHAR(30))+''' AS DATE) AND CAST('''+ CAST(@_vProject_Start_EndDate AS VARCHAR(100))+''' AS DATE))'
													SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_StartDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_StartDate,112)+''',112 ) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_EndDate,112)+''', DATE))'
												ELSE
													
													--SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_StartDate BETWEEN CAST('''+ CAST(@_vProject_Start_StartDate AS VARCHAR(100))+''' AS DATE) AND CAST('''+ CAST(@_vProject_Start_EndDate AS VARCHAR(100))+''' AS DATE))'
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_StartDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10), @_vProject_Start_StartDate,112)+''',112 ) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_Start_EndDate,112)+''', 112))'
											END
									END


									IF(@_vProject_EndDate_Period_Id IS NOT NULL AND @_vProject_EndDate_Period_Id>0)
									BEGIN
										IF(@_vProject_EndDate_Period_Id!=17)
												SELECT 
													@_vProject_End_EndDate = GETDATE(),
													@_vProject_End_StartDate = dbo.Fn_Portfolio_Period(@_vProject_EndDate_Period_Id,GETDATE())
							

										IF(@_vProject_End_StartDate IS NOT NULL AND @_vProject_End_EndDate IS NOT NULL)
											BEGIN
												IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
								
													--SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_EndDate BETWEEN CAST('''+ CAST(@_vProject_End_StartDate AS VARCHAR(100))+''' AS DATE) AND CAST('''+ CAST(@_vProject_End_EndDate AS VARCHAR(100))+''' AS DATE))'
													SET @_vdynSqlWhere = ' WHERE (GPM_WT_Project.System_EndDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_StartDate,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_EndDate,112)+''',112))'
												ELSE
													
													---SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_EndDate BETWEEN CAST('''+ CAST(@_vProject_End_StartDate AS VARCHAR(100))+''' AS DATE) AND CAST('''+ CAST(@_vProject_End_EndDate AS VARCHAR(100))+''' AS DATE))'
													SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND (GPM_WT_Project.System_EndDate BETWEEN CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_StartDate,112)+''',112) AND CONVERT(DATE,'''+ CONVERT(VARCHAR(10),@_vProject_End_EndDate,112)+''',112))'
											END
									END

									
									/*Logic for Project Lead */
									
									IF(LEN(LTRIM(RTRIM(@_vProject_Leads)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='' OR LEN(RTRIM(LTRIM(@_vdynSqlWhere)))<=0)
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Project Lead'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vProject_Leads+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV
																WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Project Lead'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vProject_Leads+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END
	
	
								/* Logic For Sponsor */

									IF(LEN(RTRIM(LTRIM(@_vSponsors))) >0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Sponsor'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vSponsors+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Sponsor'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vSponsors+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									/* Logic For Approver Conditon*/
									IF(LEN(RTRIM(LTRIM(@_vApprovers)))>0)
									BEGIN
										IF(@_vWT_Code_Cur IN('PSIMP','PSC'))
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Managers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Managers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
						
										IF(@_vWT_Code_Cur ='IDEA')
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Idea Approver'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Idea Approver'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
									

										IF(@_vWT_Code_Cur ='MDPO')
										BEGIN
											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''MDPO Regional Approvers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
											ELSE
												SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''MDPO Regional Approvers'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vApprovers+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
										END
									
									END




									/*Logic for Financial Rep*/
									IF(LEN(LTRIM(RTRIM(@_vFinancialReps)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Financial Rep'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vFinancialReps+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Financial Rep'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vFinancialReps+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									/*Logic for Team Member*/
									IF(LEN(RTRIM(LTRIM(@_vTeam_Members)))>0)
									BEGIN

									IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
										SET @_vdynSqlWhere = '	WHERE (EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Team Members'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vTeam_Members+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'
									ELSE
										SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND ( EXISTS(SELECT 1 FROM GPM_WT_Project_Team
																WHERE GPM_WT_Project_Team.WT_Role_ID=(SELECT WT_Role_ID FROM GPM_Project_Template_Role WHERE WT_Code='''+@_vWT_Code_Cur+''' AND WT_Role_Name=''Team Members'')
																AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND
																EXISTS(SELECT 1 FROM  (SELECT Value FROM dbo.Fn_SplitDelimetedData('','','''+@_vTeam_Members+''') WHERE LEN(RTRIM(LTRIM(Value)))>0) Project_Lead_Table_TV WHERE Project_Lead_Table_TV.Value=GPM_WT_Project_Team.GD_User_Id)
																AND GPM_WT_Project_Team.Is_Deleted_Ind=''N''))'

									END

									
									/*Apply Condition for Advance Criteria*/
									IF(@_vAdvance_Criteria_Id IN(10,11,12) AND @_vWT_Code_Cur NOT IN('IDEA', 'GBP','RD'))
									BEGIN
									--PRINT 'YES'
									
											--SELECT  @_vTDC_Table_Name = 'GPM_WT_Project_TDC_Saving',
											SELECT  @_vTDC_Table_Name = CASE WHEN @_vWT_Code_Cur='FI' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_DMAIC'
																						 WHEN @_vWT_Code_Cur='GDI' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_GDI'
																						 WHEN @_vWT_Code_Cur='MDPO' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_MDPO'
																						 WHEN @_vWT_Code_Cur='PSC' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_PSC'
																						 WHEN @_vWT_Code_Cur='PSIMP' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_PSIMP'
																						 WHEN @_vWT_Code_Cur='REP' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_REP'
																						 WHEN @_vWT_Code_Cur='SC' THEN 'GPM_WT_Project_TDC_Saving_ActFcst_SC'
																						 ELSE '' END,
													@_vTDCType_ColPrefix = 'Act_Fcst.'

											IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
												SELECT @_vdynSqlWhere = ' WHERE '
											ELSE
												SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '


												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' (FLOOR(ROUND(ISNULL((SELECT (SUM(CASE WHEN Attrib_Id = 32 THEN  ISNULL('+ @_vTDC_Table_Name+'.Attrib_Value ,0)*-1 
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 33 THEN  ISNULL(' + @_vTDC_Table_Name +'.Attrib_Value,0)*-1  
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 34 THEN  ISNULL('+ @_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 35 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 36 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1
																				ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END) + (SELECT SUM(ISNULL(Attrib_Value,0)) FROM '+@_vTDC_Table_Name +' 
																				WHERE '+ @_vTDC_Table_Name+'.Attrib_Id IN(37,38,39,40,41,42,43,44,45,46,47,48) /*GSS-Conversion*/
																				AND '+@_vTDC_Table_Name+'.WT_Project_Id=GPM_WT_Project.WT_Project_ID)) FROM '+@_vTDC_Table_Name +'
																				WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																					@_vTDC_Table_Name+'.Attrib_Id IN(
																													17,22,27,32, /*TT-Raw Material*/
																													23,28,33, /*TT-Conversion*/
																													19,24,29,34, /*TT-Other CGS*/
																													20,25,30,35, /*TT-Transportation*/
																													21,26,31,36 /*TT-SAG*/
																													)),0),-0))'
											IF(@_vAdvance_Criteria_Id=10)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' < 0 )'
											IF(@_vAdvance_Criteria_Id=11)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' > 0 )'
											IF(@_vAdvance_Criteria_Id=12)
												SELECT @_vdynSqlWhere =	@_vdynSqlWhere + ' != 0 )'

												--PRINT @_vdynSqlWhere
									
									END
									
									/* Best Practice Condition*/
									--DECLARE @_vdynSqlWhereTemp VARCHAR(MAX)=''
									SELECT @_vBP_Portfolio_Tag_Value=NULL
									IF(@_vWT_Code_Cur='GDI')
									BEGIN
									
										SELECT @_vBP_Portfolio_Tag_Value=RTRIM(LTRIM(Portfolio_Tag_Value)) from GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id=@vPortfolio_Id AND Portfolio_Tag_Id=123
										IF(LEN(@_vBP_Portfolio_Tag_Value)>0)
										BEGIN
											IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
												IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ( ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N''  '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND ( ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '
												ELSE
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''N'' '


										IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
											BEGIN
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ' 
													ELSE
														IF (
															 EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
															AND
															(SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0
															)
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	OR  '
														ELSE
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  '

													SET  @_vdynSqlWhere =	ISNULL(@_vdynSqlWhere,'') + '(ISNULL(GPM_WT_GDI.Is_Best_Proj_Nom,''N'')=''Y'' AND EXISTS(SELECT  TOP  1 1 
																							FROM GPM_WT_Project_BP_Gate INNER JOIN(SELECT Value AS Portfolio_Tag_Value,
																									CASE	WHEN  GWPTV.Value=11 THEN 27
																											WHEN  GWPTV.Value=12 THEN 28
																											WHEN  GWPTV.Value=13 THEN 29
																											WHEN  GWPTV.Value=14 THEN 30
																											WHEN  GWPTV.Value=15 THEN 30
																											WHEN  GWPTV.Value=16 THEN 30
																											WHEN  GWPTV.Value=17 THEN 30 END AS BPC_Gate_Id
			
																			  FROM dbo.Fn_SplitDelimetedData('','','''+@_vBP_Portfolio_Tag_Value+''') GWPTV WHERE GWPTV.Value!=10
																			  ) BPC_Gate On GPM_WT_Project_BP_Gate.Gate_Id=BPC_Gate.BPC_Gate_Id
																			  WHERE GPM_WT_Project_BP_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_ID AND
																			  GPM_WT_Project_BP_Gate.Is_Currently_Active=(SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''Y'' ELSE ''N'' END)
																			  AND ''XXX''= (SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''XXX''  
																			  WHEN BPC_Gate.Portfolio_Tag_Value=15 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Could''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=16 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Should''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=17 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Must''),''YYY'')
																			  END)
																			  ))'

																			  IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
																			  SET @_vdynSqlWhere = @_vdynSqlWhere +')'
																				
											END
										END
												--PRINT @_vdynSqlWhereTemp
									END /* END GDI Best Practice If*/
									
									
									
									SELECT @_vBP_Portfolio_Tag_Value=NULL
									IF(@_vWT_Code_Cur='FI')
									BEGIN
									
										SELECT @_vBP_Portfolio_Tag_Value=RTRIM(LTRIM(Portfolio_Tag_Value)) from GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id=@vPortfolio_Id AND Portfolio_Tag_Id=124
										IF(LEN(@_vBP_Portfolio_Tag_Value)>0)
										BEGIN
											IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
												IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  (ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  (ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
												ELSE
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE  ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '
													ELSE
														SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''N'' '


											IF ((SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0)
												BEGIN
													IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
														SET @_vdynSqlWhere = '	WHERE ' 
													ELSE
														IF (
															 EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
															AND
															(SELECT COUNT(*) FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value!=10)>0
															)
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	OR  '
														ELSE
															SET @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + '	AND  '


													SET  @_vdynSqlWhere =	ISNULL(@_vdynSqlWhere,'') + '(ISNULL(GPM_WT_DMAIC.Is_Best_Proj_Nom,''N'')=''Y'' AND EXISTS(SELECT  TOP  1 1 
																							FROM GPM_WT_Project_BP_Gate INNER JOIN(SELECT Value AS Portfolio_Tag_Value,
																									CASE	WHEN  GWPTV.Value=11 THEN 27
																											WHEN  GWPTV.Value=12 THEN 28
																											WHEN  GWPTV.Value=13 THEN 29
																											WHEN  GWPTV.Value=14 THEN 30
																											WHEN  GWPTV.Value=15 THEN 30
																											WHEN  GWPTV.Value=16 THEN 30
																											WHEN  GWPTV.Value=17 THEN 30 END AS BPC_Gate_Id
			
																			  FROM dbo.Fn_SplitDelimetedData('','','''+@_vBP_Portfolio_Tag_Value+''') GWPTV WHERE GWPTV.Value!=10
																			  ) BPC_Gate On GPM_WT_Project_BP_Gate.Gate_Id=BPC_Gate.BPC_Gate_Id
																			  WHERE GPM_WT_Project_BP_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_ID AND
																			  GPM_WT_Project_BP_Gate.Is_Currently_Active=(SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''Y'' ELSE ''N'' END)
																			  AND ''XXX''= (SELECT CASE WHEN BPC_Gate.Portfolio_Tag_Value IN('''+@_vBP_Portfolio_Tag_Value+''') THEN ''XXX''  
																			  WHEN BPC_Gate.Portfolio_Tag_Value=15 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Could''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=16 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Should''),''YYY'')
																			  WHEN BPC_Gate.Portfolio_Tag_Value=17 THEN ISNULL((SELECT ''XXX'' FROM GPM_WT_Project_BP_Criteria WHERE GPM_WT_Project_BP_Criteria.WT_Project_Id=GPM_WT_Project_BP_Gate.WT_Project_Id AND GPM_WT_Project_BP_Criteria.Gate_Id=30 AND 
																			  GPM_WT_Project_BP_Criteria.BP_Score_Type_Code=''Must''),''YYY'')
																			  END)
																			  ))'

																			  IF EXISTS(SELECT TOP 1 * FROM dbo.Fn_SplitDelimetedData(',',@_vBP_Portfolio_Tag_Value) WHERE Value=10)
																			  SET @_vdynSqlWhere = @_vdynSqlWhere +')'
											END

										END
											
												--PRINT @_vdynSqlWhereTemp
									END /* END FI Best Practice If*/
									
									
                               

						
						IF(@_vArchived_Projects='N' OR @_vArchived_Projects IS NULL)
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''N'') =''N'''
								ELSE
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''N'') =''N'''
							END
						ELSE
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''Y'') =''Y'''
								ELSE
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Archival_Ind ,''Y'') =''Y'''
							END
						
						IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
							SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  ISNULL('+@_vWT_Table_Name_Cur+'.Is_Deleted_Ind ,''N'') =''N'''
						ELSE
							SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' WHERE ISNULL('+@_vWT_Table_Name_Cur+'.Is_Deleted_Ind ,''N'')=''N'''


						IF EXISTS(SELECT * FROM @_vProjects_WT_Codes WHERE WT_Code=@_vWT_Code_Cur)
						BEGIN
						IF EXISTS(SELECT * FROM @_vExcProjects_Table WHERE ExcWT_Code=@_vWT_Code_Cur)
							BEGIN
								IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
									SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								ELSE
									SELECT @_vdynSqlWhere = ' WHERE  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
							END

								INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere) 
									VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere)
						END

								
						IF EXISTS(SELECT * FROM @_vIncProjects_Table WHERE IncWT_Code=@_vWT_Code_Cur)
						BEGIN
							SELECT @_vdynSqlWhere= ' WHERE GPM_WT_Project.WT_Project_ID IN('+ (SELECT  STUFF((SELECT ',' + CAST(IncWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vIncProjects_Table WHERE  IncWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								
							--Select @_vdynSqlWhere

							IF EXISTS(SELECT * FROM @_vExcProjects_Table WHERE ExcWT_Code=@_vWT_Code_Cur)
								BEGIN
									IF(LEN(LTRIM(RTRIM(@_vdynSqlWhere)))>0)
										SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
									ELSE
										SELECT @_vdynSqlWhere = ' WHERE  GPM_WT_Project.WT_Project_ID NOT IN('+ (SELECT  STUFF((SELECT ',' + CAST(ExcWT_Project_ID AS VARCHAR(10)) [text()] FROM @_vExcProjects_Table WHERE  ExcWT_Code=@_vWT_Code_Cur FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,''))+')'
								END


							INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere,IncludeProject) 
									VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere,'Y')
						END
						
						
						
                                  
                     FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

                     DELETE FROM @_vTab_Dyn_SQL_Table

                     DELETE FROM @_vProcessedWTndTag_Table

	END
CLOSE Outer_Cursor;
DEALLOCATE Outer_Cursor;
IF CURSOR_STATUS('global','Outer_Cursor')>=-1
BEGIN
       DEALLOCATE Outer_Cursor
END
	
									SELECT @_vCnt=0,@_vMaxCnt=0

								IF((SELECT COUNT(*) FROM @_vWTQueriesTab WHERE  IncludeProject='N')>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vWTQueriesTab WHERE  IncludeProject='N'

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN
													
														IF(@_vCnt=@_vMaxCnt)
															SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ ISNULL(SelectWhere,'') FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														ELSE
															SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ ISNULL(SelectWhere,'') +' UNION ALL 'FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														
												
												SELECT @_vCnt=MIN(Row_ID) FROM @_vWTQueriesTab WHERE Row_ID>@_vCnt AND  IncludeProject='N'
												END
										END

										/* Format queries to retreive ALL the project which fits in Portfolio Criteria*/

								SELECT @_vCnt=0,
										@_vMaxCnt=0

								IF((SELECT COUNT(*) FROM @_vWTQueriesTab WHERE  IncludeProject='Y')>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vWTQueriesTab WHERE  IncludeProject='Y'

												SELECT @_vdynSqlFinalQuery +=' UNION '

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN
													
														IF(@_vCnt=@_vMaxCnt)
															SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ ISNULL(SelectWhere,'') FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														ELSE
															SET @_vdynSqlFinalQuery += (SELECT SelectField+' '+SelectFrom +' '+ ISNULL(SelectWhere,'') +' UNION 'FROM @_vWTQueriesTab WHERE Row_ID=@_vCnt)
														
												
												SELECT @_vCnt=MIN(Row_ID) FROM @_vWTQueriesTab WHERE Row_ID>@_vCnt AND  IncludeProject='Y'
												END
										END
							

	SET @_vdynInsert= ' WITH Dashboard_CTE AS ('+ @_vdynSqlFinalQuery +') SELECT 1, WT_Project_ID,WT_Code,Project_Seq,Project_Name, '''' As XmlData
	FROM Dashboard_CTE Dashboard_CTE_Outer '

	INSERT INTO @_vDashBoardData_Table(Row_Type,WT_Project_Id, WT_Code, WT_Project_Number, Project_Name, XmlData)
	EXEC(@_vdynInsert)


	SELECT WT_Project_Id, WT_Code, WT_Project_Number, Project_Name FROM @_vDashBoardData_Table 
	WHERE WT_Project_ID !='WT_Project_ID' AND WT_Project_ID !='' 
	Order By Row_type
							
END


 

GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdPortfolioDetails]    Script Date: 11/18/2019 7:40:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_UpdPortfolioDetails]  
(  
	@vPortfolio_Id INT,
	@vPortfolio_Name varchar(500), 
	@vPortfolio_Desc varchar(8000),
	@vPortfolio_Tags varchar(max),
	@vDescend_From varchar(max) ,
	@vWT_Codes varchar(1000),
	@vStatus_Ids varchar(1000),
	@vStatus_Change_Id int,
	@vStatus_Change_Period_Id int,
	@vStatus_Change_StartDate datetime,
	@vStatus_Change_EndDate datetime,
	@vProject_Leads varchar(8000),
	@vTeam_Members varchar(8000),
	@vSponsors varchar(8000),
	@vFinancialReps varchar(8000),
	@vApprovers varchar(8000),
	@vProject_StartDate_Period_Id int,
	@vProject_Start_StartDate datetime,
	@vProject_Start_EndDate datetime,
	@vProject_EndDate_Period_Id int,
	@vProject_End_StartDate datetime,
	@vProject_End_EndDate datetime,
	@vDescend_From_User_DefaultLoc char(1),
	@vArchived_Projects char(1),
	@vBP_Projects char(1),
	@vReplace_Program_By_Memebr char(1),
	@vEdit_By_Sharees char(1),
	@vInclude_Projects varchar(8000),
	@vExclude_Projects varchar(8000),
	@vInclude_Copied_Projects CHAR(1),
	@vInclude_Replicated_Projects CHAR(1),
	@vPortfolio_Share_People varchar(max),
	@vPortfolio_Share_Facility varchar(max),
	@vPortfolio_Advance_Criteria varchar(max),
	@vLast_Modified_By VARCHAR(10),
	@vMsg_Out VARCHAR(100) OUT
 )  
 AS  
BEGIN 
 
DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRMSepPos INT=0
DECLARE @_vRMSepPosSc INT=0

DECLARE @_vTabDescendFrom As TABLE(id INT Identity(1,1), DescendFrom VARCHAR(8000))
DECLARE @_vDescendFrom VARCHAR(8000)=NULL
DECLARE @_vRegion_Code VARCHAR(5)=NULL
DECLARE @_vCountry_Code CHAR(3)=NULL
DECLARE @_vLocation_Id INT=Null


DECLARE @_vTabPortfolioTags TABLE(id INT Identity(1,1), Tags VARCHAR(8000))
DECLARE @_vPortfolioTag_Id INT=0
DECLARE @_vTag_Values VARCHAR(8000)=NULL
DECLARE @_vPF_Tags VARCHAR(8000)=NULL

DECLARE @_vTabPortfolioShare TABLE(id INT Identity(1,1), ShareWithValue VARCHAR(8000))
DECLARE @_vShare_Type_Id INT=0
DECLARE @_vShare_With_Values VARCHAR(8000)=NULL
DECLARE @_vPF_ShareValues VARCHAR(8000)=NULL

DECLARE @_vTabPortfolioAFC TABLE(id INT Identity(1,1), AFC VARCHAR(8000))
DECLARE @_vCriteria_Id VARCHAR(8000)=NULL
DECLARE @_vFilterValue VARCHAR(8000)=NULL

BEGIN
BEGIN TRAN 

	UPDATE GPM_WT_Portfolio
			SET Portfolio_Name = @vPortfolio_Name,
				Portfolio_Desc = @vPortfolio_Desc,
				WT_Codes = @vWT_Codes,
				Status_Ids = @vStatus_Ids,
				Status_Change_Id = @vStatus_Change_Id,
				Status_Change_Period_Id = @vStatus_Change_Period_Id,
				Status_Change_StartDate = @vStatus_Change_StartDate,
				Status_Change_EndDate = @vStatus_Change_EndDate,
				Project_Leads = @vProject_Leads,
				Team_Members = @vTeam_Members,
				Sponsors = @vSponsors,
				FinancialReps = @vFinancialReps,
				Approvers = @vApprovers,
				Project_StartDate_Period_Id = @vProject_StartDate_Period_Id,
				Project_Start_StartDate = @vProject_Start_StartDate,
				Project_Start_EndDate = @vProject_Start_EndDate,
				Project_EndDate_Period_Id = @vProject_EndDate_Period_Id,
				Project_End_StartDate = @vProject_End_StartDate,
				Project_End_EndDate = @vProject_End_EndDate,
				Descend_From_User_DefaultLoc = @vDescend_From_User_DefaultLoc,
				Archived_Projects = @vArchived_Projects,
				BP_Projects = @vBP_Projects,
				Replace_Program_By_Memebr = @vReplace_Program_By_Memebr,
				Edit_By_Sharees = @vEdit_By_Sharees,
				Include_Projects = @vInclude_Projects,
				Exclude_Projects = @vExclude_Projects,
				Include_Copied_Project = @vInclude_Copied_Projects,
				Include_Replicated_Project = @vInclude_Replicated_Projects,
				Last_Modified_By = @vLast_Modified_By,  
				Last_Modified_Date = Getdate()  
		WHERE Portfolio_Id=@vPortfolio_Id

		


	IF(LEN(LTRIM(RTRIM(@vDescend_From)))>0)
			INSERT INTO @_vTabDescendFrom(DescendFrom)
			SELECT 	Tab.Value
					FROM Fn_SplitDelimetedData('~',@vDescend_From) Tab
					WHERE Len(RTRIM(LTRIM(Value)))>0

				
				IF((SELECT COUNT(*) FROM @_vTabDescendFrom)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabDescendFrom

							DELETE FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id = @vPortfolio_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vRegion_Code=NULL,
										@_vCountry_Code=NULL,
										@_vLocation_Id=NULL

								SELECT @_vDescendFrom=DescendFrom FROM @_vTabDescendFrom WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vDescendFrom,1)
								SELECT @_vRMSepPosSc=CHARINDEX('|',@_vDescendFrom,@_vRMSepPos+1)								


								SELECT @_vRegion_Code=RTRIM(LTRIM(SUBSTRING(@_vDescendFrom,1, @_vRMSepPos-1)))

								IF(LEN(LTRIM(RTRIM(@_vRegion_Code)))<=0)
								SELECT @_vRegion_Code=NULL

								SELECT @_vCountry_Code =SUBSTRING(@_vDescendFrom,@_vRMSepPos+1, @_vRMSepPosSc-(@_vRMSepPos+1))

								IF(LEN(LTRIM(RTRIM(@_vCountry_Code)))<=0)
								SELECT @_vCountry_Code=NULL
									
								SELECT @_vLocation_Id =CAST(SUBSTRING(@_vDescendFrom,@_vRMSepPosSc+1, len(@_vDescendFrom)) AS INT)

								SELECT @_vLocation_Id=CASE WHEN @_vLocation_Id=0 THEN NULL ELSE @_vLocation_Id END 

								IF NOT(@_vRegion_Code IS NULL AND @_vCountry_Code IS NULL AND @_vLocation_Id IS NULL)
								INSERT INTO GPM_WT_Portfolio_DescendFrom
									(
										Portfolio_Id,
										Region_Code,
										Country_Code,
										Location_ID 
									)
								Values
									(
										@vPortfolio_Id,
										@_vRegion_Code,
										@_vCountry_Code,
										@_vLocation_Id 
									)

								

							SELECT @_vCnt=MIN(id) FROM @_vTabDescendFrom WHERE id>@_vCnt
						END
					END
					ELSE
						DELETE FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id = @vPortfolio_Id


					IF(LEN(@vPortfolio_Tags)>0)
					BEGIN
						INSERT INTO @_vTabPortfolioTags(Tags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vPortfolio_Tags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					
					IF((SELECT COUNT(*) FROM @_vTabPortfolioTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioTags

							DELETE FROM GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id = @vPortfolio_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPF_Tags=Tags FROM @_vTabPortfolioTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPF_Tags,1)
								SELECT @_vPortfolioTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPF_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vTag_Values=SUBSTRING(@_vPF_Tags,@_vRMSepPos+1, len(@_vPF_Tags))

								
								INSERT INTO GPM_WT_Portfolio_Tag_Value
								(
									Portfolio_Id,
									Portfolio_Tag_Id,
									Portfolio_Tag_Value,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vPortfolio_Id,
									@_vPortfolioTag_Id,
									@_vTag_Values,
									@vLast_Modified_By,
									GETDATE()
								)
								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioTags WHERE id>@_vCnt
							END

						END
					END
					ELSE
						DELETE FROM GPM_WT_Portfolio_Tag_Value WHERE Portfolio_Id = @vPortfolio_Id


					IF(LEN(RTRIM(LTRIM(@vPortfolio_Share_People)))>0)
						INSERT INTO @_vTabPortfolioShare(ShareWithValue) VALUES(@vPortfolio_Share_People)
					
					

					IF(LEN(@vPortfolio_Share_Facility)>0)
					BEGIN
						INSERT INTO @_vTabPortfolioShare(ShareWithValue)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vPortfolio_Share_Facility) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0
					END



					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabPortfolioShare)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioShare

								DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPF_ShareValues=ShareWithValue FROM @_vTabPortfolioShare WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPF_ShareValues,1)
								SELECT @_vShare_Type_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPF_ShareValues,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vShare_With_Values=SUBSTRING(@_vPF_ShareValues,@_vRMSepPos+1, len(@_vPF_ShareValues))

								
								INSERT INTO GPM_WT_Portfolio_Sharing
								(
									Portfolio_Id,
									Share_Type_Id,
									Share_With_Values,
									Share_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT
									@vPortfolio_Id,
									@_vShare_Type_Id,
									Tab.Value,
									@vLast_Modified_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								FROM Fn_SplitDelimetedData(',',@_vShare_With_Values) Tab
									WHERE Len(RTRIM(LTRIM(Value)))>0

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioShare WHERE id>@_vCnt
							END

					END
					ELSE
						DELETE FROM GPM_WT_Portfolio_Sharing WHERE Portfolio_Id=@vPortfolio_Id
					
					IF(LEN(LTRIM(RTRIM(@vPortfolio_Advance_Criteria)))>0)
						INSERT INTO @_vTabPortfolioAFC(AFC)
						SELECT 	Tab.Value
								FROM Fn_SplitDelimetedData('~',@vPortfolio_Advance_Criteria) Tab
								WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0
					IF((SELECT COUNT(*) FROM @_vTabPortfolioAFC)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabPortfolioAFC
							
							DELETE FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id = @vPortfolio_Id			
							
							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN
									SELECT @vPortfolio_Advance_Criteria=AFC FROM @_vTabPortfolioAFC WHERE id=@_vCnt

									SELECT @_vRMSepPos=CHARINDEX('|',@vPortfolio_Advance_Criteria,1)
				
									SELECT @_vCriteria_Id=RTRIM(LTRIM(SUBSTRING(@vPortfolio_Advance_Criteria,1, @_vRMSepPos-1)))

									SELECT @_vFilterValue =SUBSTRING(@vPortfolio_Advance_Criteria,@_vRMSepPos+1, LEN(@vPortfolio_Advance_Criteria))
							
									--SELECT @_vFilterValue=CASE WHEN @_vCriteria_Id=10 THEN 0 ELSE 1 END 

									IF NOT(@vPortfolio_Id IS NULL AND @_vCriteria_Id IS NULL AND @_vFilterValue IS NULL)
									INSERT INTO GPM_WT_Portfolio_Advance_Filter
										(
											Portfolio_Id,
											Criteria_Id,
											Filter_Value
										)
									Values
										(
											@vPortfolio_Id,
											@_vCriteria_Id,
											@_vFilterValue 
										)	

									IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabPortfolioAFC WHERE id>@_vCnt
								END
							END
					ELSE
					DELETE FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id = @vPortfolio_Id	
					
					IF((LEN(RTRIM(LTRIM(@vPortfolio_Share_People)))>0 OR LEN(RTRIM(LTRIM(@vPortfolio_Share_Facility)))>0) AND @vPortfolio_Share_Facility!='~')
					BEGIN
						DELETE FROM GPM_WT_Portfolio_Visibility WHERE Portfolio_Id = @vPortfolio_Id	
						DECLARE @_vShareWithString VARCHAR(MAX)= @vPortfolio_Share_People +'~'+ @vPortfolio_Share_Facility
						
						DECLARE	@_vShared_UserList VARCHAR(MAX)
						EXEC	[Sp_GetUserList_ByShareWithString]
								@vSharewith =@_vShareWithString,
								@vUserList = @_vShared_UserList OUTPUT
						
						IF(LEN(RTRIM(LTRIM(@_vShared_UserList)))>0 OR ISNULL(@_vShared_UserList,'Y')!='Y')
							INSERT INTO GPM_WT_Portfolio_Visibility VALUES(@vPortfolio_Id,@_vShared_UserList)
						
						IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END
					ELSE
					DELETE FROM GPM_WT_Portfolio_Visibility WHERE Portfolio_Id = @vPortfolio_Id		
   
				SELECT @vMsg_Out='Portfolio Details Updated Successfully'   

		COMMIT TRAN  
		RETURN 1  

 END     
  
 ERR_HANDLER:  
  BEGIN  
   SELECT @vMsg_Out='Failed To Update Portfolio Details-'+ ERROR_MESSAGE();  
   IF (@@TRANCOUNT>0)  
   ROLLBACK TRAN  
   RETURN 0  
  END  
 END






GO
