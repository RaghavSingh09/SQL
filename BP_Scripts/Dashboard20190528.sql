
/****** Object:  StoredProcedure [dbo].[Sp_GetDashBoardData]    Script Date: 5/28/2019 9:18:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_GetDashBoardData]
@vPortfolio_Id INT,
@vLayout_Id INT,
@vLogin_User_Id VARCHAR(10),
@vCountry_Code CHAR(3)=NULL,
@vMsg_OUT VARCHAR(100) OUT
AS
BEGIN

--DECLARE @vPortfolio_Id INT=1090
--DECLARE @vLayout_Id INT=1205
--DECLARE @vCountry_Code CHAR(3)='USA'
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



DECLARE @_vLayoutTag_Table AS TABLE(Row_ID INT IDENTITY(1,1),LayoutTag_Id Int, TG_Table_Name VARCHAR(500),TG_Table_Desc_ColName VARCHAR(500),Custom_ColName VARCHAR(500))
DECLARE @_vLayoutTag_Id Int 
DECLARE @_vLayout_TG_Table_Name VARCHAR(500)
DECLARE @_vLayout_vTG_Table_Desc_ColName VARCHAR(500)
DECLARE @_vLayout_vCustom_ColName VARCHAR(500)

DECLARE @_vLayoutMetric_Table AS TABLE(Row_ID INT IDENTITY(1,1),Layout_Id INT,Metric_Id INT,Metric_TDC_Type_Id INT,Metric_Field_Id INT,Period_Id INT,Start_Month_Id INT,
									   Start_Quarter_Id INT,Start_Year INT,End_Month_Id INT,End_Quarter_Id INT,End_Year INT,
										Custom_ColName varchar(500),Precision varchar(5),Program_Id INT)
--=DECLARE  @_vLayout_Id int
DECLARE @_vMetric_Id int
DECLARE @_vMetric_TDC_Type_Id int
DECLARE @_vMetric_Field_Id int
DECLARE @_vPeriod_Id int
--DECLARE @_vStart_Date datetime
DECLARE @_vEnd_Date datetime
DECLARE @_vStart_Month_Id INT
DECLARE @_vStart_Quarter_Id INT 
DECLARE @_vStart_Year INT
DECLARE @_vEnd_Month_Id INT
DECLARE @_vEnd_Quarter_Id INT
DECLARE @_vEnd_Year INT
DECLARE @_vCustom_ColName varchar(500)
DECLARE @_vPrecision varchar(5)
DECLARE @_vProgram_Id int
DECLARE @_vTDCType_ColPrefix VARCHAR(100)


DECLARE @_vTDCYearMonth VARCHAR(6)
DECLARE @_vMonthName VARCHAR(200)
DECLARE @_vMonthNumber CHAR(2)
DECLARE @_vQuarterStartDate DATE

DECLARE @_vLayoutMetricPeriod_Table AS TABLE(TDCStartDate DATE, TDCEndDate DATE)
DECLARE @_vTDCstartDate DATE
DECLARE @_vTDCendDate DATE
DECLARE @_vTDCMinDate DATE
DECLARE @_vTDCMaxDate DATE
DECLARE @_vTDCAttribColName VARCHAR(500)
DECLARE @_vDisplay_Order INT


DECLARE @_vLayOut_TG_Table_PK_ColName	VARCHAR(500)
DECLARE @_vLayOut_TG_Table_ColName_Desc VARCHAR(1000)
DECLARE @_vLayOut_TG_Table_ColName_Custom_Desc	VARCHAR(1000)
DECLARE @_vLayOut_WT_Table_Name	VARCHAR(500)
DECLARE @_vLayOut_WT_Table_FK_ColName	VARCHAR(500)
DECLARE @_vAttrib_Name VARCHAR(200)


DECLARE @_vGPM_WT_Layout_PL_Tag_Value_Table AS Table(Row_ID INT IDENTITY(1,1),Layout_Id Int,Layout_PL_Tag_Id Int, Custom_PL_ColName Varchar(500))
DECLARE @_vPL_Layout_Id Int
DECLARE @_vPL_Layout_PL_Tag_Id Int 
DECLARE @_vPL_Custom_PL_ColName Varchar(500)

DECLARE @_vDashboardColumnMap_Table AS Table (SelectField VARCHAR(500), DashBoardColumn Varchar(500), ColumnOrder INT, Display_Order INT)


DECLARE @_vGPM_WT_Layout_Custom_Fields_Table AS Table(Row_ID INT IDENTITY(1,1),Layout_Id Int,Custom_Field_Tag_Id VARCHAR(100), Custom_Field_Cust_ColName Varchar(500))
DECLARE @_vCustom_Field_Tag_Id INT
DECLARE @_vCustom_Field_Cust_ColName VARCHAR(500)
DECLARE @_vCustom_Field_WT_Name	VARCHAR(100)
DECLARE @_vCustom_Field_ColName	VARCHAR(500)
                  

DECLARE @_vWT_Table_Name_Cur varchar(100)
DECLARE @_vWT_Code_Cur  varchar(10)


DECLARE @_vHeaderList VARCHAR(MAX)
DECLARE @_vColumnList VARCHAR(MAX)
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

DECLARE @_vAdvance_Criteria_Id INT
DECLARE @_vFilter_Value VARCHAR(100)



IF NOT EXISTS(SELECT 1 FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id AND Is_Deleted_Ind = 'N')
	BEGIN
		SELECT @vMsg_OUT = 'Portfolio Not Found'
		RETURN 0
	END

IF NOT EXISTS(SELECT 1 FROM GPM_WT_Layout WHERE Layout_Id=@vLayout_Id AND Is_Deleted_Ind = 'N')
	BEGIN
		SELECT @vMsg_OUT = 'Layout Not Found'
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

SELECT @_vAdvance_Criteria_Id = Criteria_Id,
		@_vFilter_Value = Filter_Value
	FROM GPM_WT_Portfolio_Advance_Filter WHERE Portfolio_Id=@vPortfolio_Id


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
       
	   /*
DECLARE Outer_Cursor CURSOR FOR
       SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN
       (SELECT Value FROM Fn_SplitDelimetedData(',',@_vPF_WT_Codes))
	   */



DECLARE @_vColumnCommonList VARCHAR(MAX)='Login_User_Id,Portfolio_Id,Layout_Id,Row_Type'
DECLARE @_vdynSqlSelectCommonField VARCHAR(MAX)='SELECT '''+CAST(@vLogin_User_Id AS VARCHAR(10))+''' AS Login_User_Id,'+CAST(@vPortfolio_Id AS VARCHAR(10))+' AS Portfolio_Id,'+CAST(@vLayout_Id AS VARCHAR(10))+' AS Layout_Id,@@Row_Type AS Row_Type'


INSERT INTO @_vLayoutTag_Table(LayoutTag_Id,TG_Table_Name,TG_Table_Desc_ColName,Custom_ColName)
       SELECT GWLTV.Layout_Tag_Id, GLT.TG_Table_Name,GLT.TG_Table_Desc_ColName,GWLTV.Custom_ColName 
       FROM GPM_Layout_Tag GLT INNER JOIN GPM_WT_Layout_Tag_Value GWLTV On GLT.Layout_Tag_Id=GWLTV.Layout_Tag_Id
       WHERE GWLTV.Layout_Id=@vLayout_Id ---And GLT.Is_Default_Col = 'N'
	   
	
INSERT INTO @_vLayoutMetric_Table(Layout_Id,Metric_Id,Metric_TDC_Type_Id,Metric_Field_Id,Period_Id,Start_Month_Id,
	   Start_Quarter_Id,Start_Year,End_Month_Id,End_Quarter_Id,End_Year,
       Custom_ColName,Precision,Program_Id)
SELECT Layout_Id,Metric_Id,Metric_TDC_Type_Id,Metric_Field_Id,Period_Id,Start_Month_Id,
	   Start_Quarter_Id,Start_Year,End_Month_Id,End_Quarter_Id,End_Year,Custom_ColName,Precision,Program_Id FROM GPM_WT_Layout_Metrics_Value
       WHERE Layout_Id=@vLayout_Id Order By Metric_Id
      
INSERT INTO @_vGPM_WT_Layout_PL_Tag_Value_Table(Layout_Id,Layout_PL_Tag_Id, Custom_PL_ColName)
	SELECT Layout_Id,Layout_PL_Tag_Id, Custom_PL_ColName FROM GPM_WT_Layout_PL_Tag_Value WHERE Layout_Id=@vLayout_Id
	

INSERT INTO @_vGPM_WT_Layout_Custom_Fields_Table (Layout_Id,Custom_Field_Tag_Id, Custom_Field_Cust_ColName)
	 SELECT Layout_Id,Custom_Field_Tag_Id, Custom_Field_Cust_ColName FROM GPM_WT_Layout_Custom_Fields WHERE Layout_Id=@vLayout_Id
	 
	 
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

													   
                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_DMAIC.DMAIC_Number AS Project_Seq,GPM_WT_DMAIC.DMAIC_Name As Project_Name'

													   IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -1)
                                                END

                                                IF(@_vWT_Code_Cur='MDPO' AND @_vWT_Table_Name_Cur='GPM_WT_MDPO')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_MDPO ON GPM_WT_Project.WT_Id=GPM_WT_MDPO.MDPO_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_MDPO.MDPO_Number' 
													   

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_MDPO.MDPO_Number AS Project_Seq,GPM_WT_MDPO.MDPO_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -1)

												END

												IF(@_vWT_Code_Cur='GBP' AND @_vWT_Table_Name_Cur='GPM_WT_GBS')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GBS ON GPM_WT_Project.WT_Id=GPM_WT_GBS.GBS_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GBS.GBS_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_GBS.GBS_Number AS Project_Seq,GPM_WT_GBS.GBS_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -1)

												END

												IF(@_vWT_Code_Cur='GDI' AND @_vWT_Table_Name_Cur='GPM_WT_GDI')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_GDI ON GPM_WT_Project.WT_Id=GPM_WT_GDI.GDI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_GDI.GDI_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_GDI.GDI_Number AS Project_Seq,GPM_WT_GDI.GDI_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, -2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END

												IF(@_vWT_Code_Cur='IDEA' AND @_vWT_Table_Name_Cur='GPM_WT_Idea')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Idea ON GPM_WT_Project.WT_Id=GPM_WT_Idea.Idea_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Idea.Idea_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_Idea.Idea_Number AS Project_Seq,GPM_WT_Idea.Idea_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END

												IF(@_vWT_Code_Cur='IMA' AND @_vWT_Table_Name_Cur='GPM_WT_IMA')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_IMA ON GPM_WT_Project.WT_Id=GPM_WT_IMA.IMA_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_IMA.IMA_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_IMA.IMA_Number AS Project_Seq,GPM_WT_IMA.IMA_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END

												IF(@_vWT_Code_Cur='RD' AND @_vWT_Table_Name_Cur='GPM_WT_NMTP')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_NMTP ON GPM_WT_Project.WT_Id=GPM_WT_NMTP.QTI_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_NMTP.QTI_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_NMTP.QTI_Number AS Project_Seq,GPM_WT_NMTP.QTI_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END

												IF(@_vWT_Code_Cur='PSC' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement ON GPM_WT_Project.WT_Id=GPM_WT_Procurement.PSC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement.PSC_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_Procurement.PSC_Number AS Project_Seq,GPM_WT_Procurement.PSC_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END
                                                    
												IF(@_vWT_Code_Cur='PSIMP' AND @_vWT_Table_Name_Cur='GPM_WT_Procurement_Simple')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Procurement_Simple ON GPM_WT_Project.WT_Id=GPM_WT_Procurement_Simple.PSIMP_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Procurement_Simple.PSIMP_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_Procurement_Simple.PSIMP_Number AS Project_Seq,GPM_WT_Procurement_Simple.PSIMP_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END                                      

												IF(@_vWT_Code_Cur='REP' AND @_vWT_Table_Name_Cur='GPM_WT_Replication')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_Replication ON GPM_WT_Project.WT_Id=GPM_WT_Replication.Replication_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_Replication.Replication_Number' 

                                                       SELECT @_vdynSqlSelectField=REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','0') +', GPM_WT_Replication.Replication_Number AS Project_Seq,GPM_WT_Replication.Replication_Name As Project_Name'

													    IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Seq')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Seq', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table) +1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-2)

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='Project_Name')
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES('Project_Name', 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,-1)

												END                                      
       

												

												
												
											
                                                INSERT INTO @_vTab_Dyn_SQL_Table (Portfolio_Tag_Id,WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value)
                                                SELECT B.Portfolio_Tag_Id, B.WT_Table_Name, B.WT_Table_FK_ColName, B.TG_Table_Name, B.TG_Table_PK_ColName,REPLACE(A.Portfolio_Tag_Value,'^',',')
                                                FROM GPM_WT_Portfolio_Tag_Value A 
                                                INNER JOIN GPM_Portfolio_Tag B On A.Portfolio_Tag_Id=B.Portfolio_Tag_Id
                                                WHERE a.Portfolio_Id=@vPortfolio_Id AND B.WT_Table_Name=@_vWT_Table_Name_Cur

												

                                           
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

													--   PRINT @_vWT_Code_Cur+''+  @_vPortfolio_Tag_Value
													   
                                                       ---SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name
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
                                                       
                                                       --SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name      
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
                                                       
                                                       --SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

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

                                                
																/*
																IF((SELECT COUNT(*) FROM @_vRegion_Table)>0 )
																--AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL') )
																BEGIN
																			  SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table FOR XML PATH(''))
																			  SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
																			  SELECT @_vdynSqlWhere =' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'

																			  --PRINT 'Yes ALL'
																END

																*/
                                                

												
												
                                                
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

												
																/*
																IF((SELECT COUNT(*) FROM @_vCountry_Table)>0 
																AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL')
																AND  NOT EXISTS(SELECT 1 FROM @_vCountry_Table WHERE Country_Code='ALL')
																)*/
																/*
																IF((SELECT COUNT(*) FROM @_vCountry_Table)>0 )
																BEGIN
																			  SET @_vCountryList= (SELECT  ','+''''+ Country_Code+'''' FROM @_vCountry_Table FOR XML PATH(''))
																			  SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))
																			  IF (LEN(@_vdynSqlWhere)>0)
																					 SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+ ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
																			  ELSE
																					 SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
																END
																*/

												
																--IF((SELECT COUNT(*) FROM @_vLocation_Table)>0AND NOT EXISTS(SELECT 1 FROM @_vLocation_Table WHERE Location_Id='ALL'))
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
												
																/*
																IF((SELECT COUNT(*) FROM @_vLocation_Table)>0
																AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL')
																AND  NOT EXISTS(SELECT 1 FROM @_vCountry_Table WHERE Country_Code='ALL')
																AND  NOT EXISTS(SELECT 1 FROM @_vLocation_Table WHERE Location_Id='ALL')
																)
																*/
																/*
																IF((SELECT COUNT(*) FROM @_vLocation_Table)>0)
																BEGIN
																			  SET @_vLocationList= (SELECT  ','+ Location_Id FROM @_vLocation_Table FOR XML PATH(''))
																			  SET @_vLocationList= SUBSTRING(@_vLocationList,2, LEN(@_vLocationList))
															  
																			  IF (LEN(@_vdynSqlWhere)>0)
																					 SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'') + ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																			  ELSE
																					 SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
																END

																*/
												
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
														

														--IF (LEN(@_vdynSqlWhere)>0)

														--		SELECT @_vdynSqlWhere = ISNULL(@_vdynSqlWhere,'')+' AND EXISTS(SELECT 1 FROM ( SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'
														--ELSE
														--		SELECT @_vdynSqlWhere = ' WHERE EXISTS(SELECT 1 FROM ( SELECT Distinct Location_Id FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=' + CAST(@vPortfolio_Id AS VARCHAR(10))+' AND Location_Id IS NOT NULL) LOCATION_TAB WHERE LOCATION_TAB.Location_Id='+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name+')'

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
									IF(@_vAdvance_Criteria_Id IN(10,11) AND @_vWT_Code_Cur NOT IN('IDEA', 'GBP'))
									BEGIN
									--PRINT 'YES'
									
											SELECT  @_vTDC_Table_Name = 'GPM_WT_Project_TDC_Saving',
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

												--PRINT @_vdynSqlWhere
									
									END
									
									
									
                               /* Layout Portion Starts here */

									/* Layout Project Lead Tags*/
								  SELECT @_vCnt=0, @_vMaxCnt=0 
                                  IF((SELECT COUNT(*) FROM @_vGPM_WT_Layout_PL_Tag_Value_Table)>0)
								  BEGIN
								  								  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vGPM_WT_Layout_PL_Tag_Value_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

												SELECT  @_vPL_Layout_Id = Layout_Id,
                                                              @_vPL_Layout_PL_Tag_Id = Layout_PL_Tag_Id,
                                                              @_vPL_Custom_PL_ColName = Custom_PL_ColName
														FROM @_vGPM_WT_Layout_PL_Tag_Value_Table WHERE Row_ID=@_vCnt

														--PRINT 'Project Lead Tag'+ cast (@_vPL_Layout_PL_Tag_Id as varchar(100))
														--PRINT @_vLayout_vCustom_ColName

														SELECT @_vDisplay_Order=NULL
														
														SELECT @_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																WHERE Layout_Tag_Type_Desc='Project Lead Tag'
																AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vPL_Layout_PL_Tag_Id


													IF (@_vPL_Layout_PL_Tag_Id=10)
															BEGIN
															SELECT @_vdynSqlSelectField += ','+  '(SELECT GPM_Region.Region_Name FROM GPM_WT_Project_Team 
																									INNER JOIN GPM_User On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id 
																									INNER JOIN GPM_Region On GPM_User.Region_Code=GPM_Region.Region_Code
																									WHERE GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.WT_Role_ID=
																									(SELECT GPM_Project_Template_Role.WT_Role_Id FROM GPM_Project_Template_Role 
																									WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_Project_Template_Role.WT_Code='''+@_vWT_Code_Cur +''' AND GPM_Project_Template_Role.Is_Deleted_Ind=''N'')
																								AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS [PL_'+ @_vPL_Custom_PL_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='PL_'+ @_vPL_Custom_PL_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES('PL_'+ @_vPL_Custom_PL_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
															END
													IF (@_vPL_Layout_PL_Tag_Id=11)
															BEGIN
															SELECT @_vdynSqlSelectField += ','+  '(SELECT GPM_Country.Country_Name FROM GPM_WT_Project_Team 
																									INNER JOIN GPM_User  On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id 
																									INNER JOIN GPM_Country  On GPM_User.Country_Code=GPM_Country.Country_Code
																									WHERE GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.WT_Role_ID=
																									(SELECT GPM_Project_Template_Role.WT_Role_Id FROM GPM_Project_Template_Role 
																									WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_Project_Template_Role.WT_Code='''+@_vWT_Code_Cur +''' AND GPM_Project_Template_Role.Is_Deleted_Ind=''N'')
																								AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS [PL_'+ @_vPL_Custom_PL_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='PL_'+ @_vPL_Custom_PL_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES('PL_'+ @_vPL_Custom_PL_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
															END
													IF (@_vPL_Layout_PL_Tag_Id=12)
															BEGIN
															SELECT @_vdynSqlSelectField += ','+  '(SELECT GPM_Location.Location_Name FROM GPM_WT_Project_Team 
																									INNER JOIN GPM_User  On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id 
																									INNER JOIN GPM_Location  On GPM_User.Location_Id=GPM_Location.Location_Id
																									WHERE GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.WT_Role_ID=
																									(SELECT GPM_Project_Template_Role.WT_Role_Id FROM GPM_Project_Template_Role 
																									WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_Project_Template_Role.WT_Code='''+@_vWT_Code_Cur +''' AND GPM_Project_Template_Role.Is_Deleted_Ind=''N'')
																									AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS [PL_'+ @_vPL_Custom_PL_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='PL_'+ @_vPL_Custom_PL_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES('PL_'+ @_vPL_Custom_PL_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
															END

													IF (@_vPL_Layout_PL_Tag_Id=13)
															BEGIN
															SELECT @_vdynSqlSelectField += ','+  '(SELECT GPM_Department.Dept_Name FROM GPM_WT_Project_Team 
																									INNER JOIN GPM_User  On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id 
																									INNER JOIN GPM_Department  On GPM_User.Dept_ID=GPM_Department.Dept_ID
																									WHERE GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.WT_Role_ID=
																									(SELECT GPM_Project_Template_Role.WT_Role_Id FROM GPM_Project_Template_Role 
																									WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_Project_Template_Role.WT_Code='''+@_vWT_Code_Cur +''' AND GPM_Project_Template_Role.Is_Deleted_Ind=''N'')
																									AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS [PL_'+ @_vPL_Custom_PL_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='PL_'+ @_vPL_Custom_PL_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES('PL_'+ @_vPL_Custom_PL_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
															END

													IF (@_vPL_Layout_PL_Tag_Id=14)
														BEGIN
															SELECT @_vdynSqlSelectField += ','+  '(SELECT GPM_Business_Area.BA_Name FROM GPM_WT_Project_Team 
																									INNER JOIN GPM_User  On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id 
																									INNER JOIN GPM_Business_Area  On GPM_User.BA_Id=GPM_Business_Area.BA_ID
																									WHERE GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.WT_Role_ID=
																									(SELECT GPM_Project_Template_Role.WT_Role_Id FROM GPM_Project_Template_Role 
																									WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_Project_Template_Role.WT_Code='''+@_vWT_Code_Cur +''' AND GPM_Project_Template_Role.Is_Deleted_Ind=''N'')
																									AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS [PL_'+ @_vPL_Custom_PL_ColName +']'
															
															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField='PL_'+ @_vPL_Custom_PL_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES('PL_'+ @_vPL_Custom_PL_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)

														END				
													                  
													SELECT @_vCnt=MIN(Row_ID) FROM @_vGPM_WT_Layout_PL_Tag_Value_Table WHERE Row_ID>@_vCnt


												END
								  END


								  /* Layout Custom Field Tags*/
								  SELECT @_vCnt=0, @_vMaxCnt=0 
								  
								   IF((SELECT COUNT(*) FROM @_vGPM_WT_Layout_Custom_Fields_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vGPM_WT_Layout_Custom_Fields_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

												SELECT  @_vCustom_Field_Tag_Id = NULL,
                                                        @_vCustom_Field_Cust_ColName = NULL,
														@_vCustom_Field_ColName = NULL,
														@_vCustom_Field_WT_Name =NULL,
														@_vDisplay_Order=NULL
														

													
													SELECT  @_vCustom_Field_Tag_Id = Custom_Field_Tag_Id,
                                                            @_vCustom_Field_Cust_ColName = Custom_Field_Cust_ColName 
														FROM @_vGPM_WT_Layout_Custom_Fields_Table WHERE Row_ID=@_vCnt

													SELECT
														@_vCustom_Field_WT_Name = Custom_Field_WT_Name,
														@_vCustom_Field_ColName = Custom_Field_ColName 
													FROM GPM_Layout_Custom_Fields WHERE Custom_Field_Id=@_vCustom_Field_Tag_Id AND Custom_Field_WT_Code=@_vWT_Code_Cur
														AND Custom_Field_WT_Name=@_vWT_Table_Name_Cur 

														
														
														SELECT @_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																WHERE Layout_Tag_Type_Desc='Custom Tag'
																AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vCustom_Field_Tag_Id

														IF(LEN(@_vCustom_Field_WT_Name)>0)
														BEGIN
															SELECT @_vdynSqlSelectField += ','+ @_vCustom_Field_WT_Name +'.'+@_vCustom_Field_ColName +' AS ['+ @_vCustom_Field_Cust_ColName +']'

																IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vCustom_Field_Cust_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vCustom_Field_Cust_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
														END
														ELSE
														BEGIN
															SELECT @_vdynSqlSelectField += ','+ ' NULL AS ['+ @_vCustom_Field_Cust_ColName+']'

																IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vCustom_Field_Cust_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vCustom_Field_Cust_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
														END


													  

													SELECT @_vCnt=MIN(Row_ID) FROM @_vGPM_WT_Layout_Custom_Fields_Table WHERE Row_ID>@_vCnt

												END
										END


								  





								  /* Layout Tags */
								   SELECT @_vCnt=0, @_vMaxCnt=0 

                                  IF((SELECT COUNT(*) FROM @_vLayoutTag_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vLayoutTag_Table
												

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

												SELECT @_vDisplay_Order=NULL

                                                SELECT  @_vLayoutTag_Id = LayoutTag_Id,
                                                              @_vLayout_TG_Table_Name = TG_Table_Name,
                                                              @_vLayout_vTG_Table_Desc_ColName = TG_Table_Desc_ColName,
                                                              @_vLayout_vCustom_ColName = Custom_ColName
                                                FROM @_vLayoutTag_Table WHERE Row_ID=@_vCnt

												

													SELECT @_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																WHERE GPM_Layout_Tag_Type.Layout_Tag_Type_Desc='Project Tag'
																AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vLayoutTag_Id

																
														--PRINT 'Project Tag' + CAST( @_vLayoutTag_Id AS VARCHAR(10)) +' '+ ISNULL(CAST( @_vDisplay_Order AS VARCHAR(10)),0)

                                                  --PRINT @_vLayoutTag_Id
                                                IF(@_vLayoutTag_Id IN(45,46,47,48,49,50,51,52,53,54,55,56,57,21,13))
												BEGIN
													IF(@_vLayoutTag_Id=45) /* Add Status Column in select list*/
													BEGIN
														IF EXISTS(SELECT 1 FROM @_vProcessedWTndTag_Table PTG WHERE PTG.TG_Table_Name='GPM_Project_Tracking GPT')
															BEGIN
														
																		 SELECT @_vdynSqlSelectField += ', GPT.Proj_Track_Status AS ['+ @_vLayout_vCustom_ColName +']'

																		 IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																				INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																					VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
															END
														ELSE
															BEGIN
															--PRINT @_vLayout_vCustom_ColName
																		SET @_vdynSqlFrom += N' LEFT OUTER JOIN GPM_Project_Tracking GPT ON GPM_WT_Project.Status_Id=GPT.Proj_Track_Id'

																		SELECT @_vdynSqlSelectField += ', GPT.Proj_Track_Status AS ['+ @_vLayout_vCustom_ColName +']'

																		IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																				INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																					VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)

													
															END 
														END
													

													IF(@_vLayoutTag_Id=46) /* Add Template Type (WT_Code) Column in select list*/
													BEGIN
														SELECT @_vdynSqlSelectField += ', ''' +@_vWT_Code_Cur+''' AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=47) /* Add Active Gate in select list*/
													BEGIN
														SELECT @_vdynSqlSelectField += ', (SELECT GG.Alt_Gate_Desc FROM GPM_WT_Project_Gate GWPG INNER JOIN GPM_Gate GG On GWPG.Gate_Id=GG.Gate_Id
																						WHERE GWPG.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GWPG.Is_Currently_Active=''Y'') AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=48) /* Add Project Start Date Column in select list*/
													BEGIN
													IF(@vCountry_Code='USA' OR @vCountry_Code =NULL OR LEN(LTRIM(RTRIM(@vCountry_Code)))<=0)
														SELECT @_vdynSqlSelectField += ', CONVERT(VARCHAR(10),GPM_WT_Project.System_StartDate,101) AS ['+ @_vLayout_vCustom_ColName +']'
													ELSE
														SELECT @_vdynSqlSelectField += ', CONVERT(VARCHAR(10),GPM_WT_Project.System_StartDate,103) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=49) /* Add Project End Date Column in select list*/
													BEGIN
													IF(@vCountry_Code='USA' OR @vCountry_Code =NULL OR LEN(LTRIM(RTRIM(@vCountry_Code)))<=0)
														SELECT @_vdynSqlSelectField += ', CONVERT(VARCHAR(30),GPM_WT_Project.System_EndDate ,101) AS ['+ @_vLayout_vCustom_ColName +']'
													ELSE
														SELECT @_vdynSqlSelectField += ', CONVERT(VARCHAR(30),GPM_WT_Project.System_EndDate ,103) AS ['+ @_vLayout_vCustom_ColName +']'


														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=50) /* Add Project Lead  Column in select list*/
													BEGIN
														
														SELECT @_vdynSqlSelectField += ',(SELECT ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
														  INNER JOIN GPM_User On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id  WHERE GPM_Project_Template_Role.WT_Role_Name=''Project Lead'' AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END


													IF(@_vLayoutTag_Id=51) /* Add Team Member Column in select list*/
													BEGIN
														
														SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
																						INNER JOIN GPM_User On  GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id WHERE GPM_WT_Project_Team.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_Project_Template_Role.WT_Role_Name=''Team Members'' AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'' FOR XML PATH('''')), 2,50000)) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=52) /* Add Sponsor Column in select list*/
													BEGIN
														
														/*
														SELECT @_vdynSqlSelectField += ',(SELECT ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
														  INNER JOIN GPM_User On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id  WHERE GPM_Project_Template_Role.WT_Role_Name=''Sponsor'' AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS ['+ @_vLayout_vCustom_ColName +']'
														  */

														  SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
																						INNER JOIN GPM_User On  GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id WHERE GPM_WT_Project_Team.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_Project_Template_Role.WT_Role_Name=''Sponsor'' AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'' FOR XML PATH('''')), 2,50000)) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=53) /* Add Financial Rep Column in select list*/
													BEGIN
														
														/*
														SELECT @_vdynSqlSelectField += ',(SELECT ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
														  INNER JOIN GPM_User On GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id  WHERE GPM_Project_Template_Role.WT_Role_Name=''Financial Rep'' AND GPM_WT_Project_Team.WT_Project_ID=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'') AS ['+ @_vLayout_vCustom_ColName +']'
														  */

														  SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
																						INNER JOIN GPM_User On  GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id WHERE GPM_WT_Project_Team.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_Project_Template_Role.WT_Role_Name=''Financial Rep'' AND GPM_WT_Project_Team.Is_Deleted_Ind=''N'' FOR XML PATH('''')), 2,50000)) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													
													
													IF(@_vLayoutTag_Id=54) /* Add Indea Approver Column in select list*/
													BEGIN
														
														SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
																						INNER JOIN GPM_User On  GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id WHERE GPM_WT_Project_Team.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_Project_Template_Role.WT_Role_Name=''Idea Approver'' FOR XML PATH('''')), 2,50000)) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													
													IF(@_vLayoutTag_Id=55) /* Add MDPO Regional Approvers Column in select list*/
													BEGIN
														
														SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + ISNULL(GPM_User.User_First_Name,'''') +'' ''+ISNULL(GPM_User.User_Last_Name,'''') FROM GPM_WT_Project_Team INNER JOIN GPM_Project_Template_Role On GPM_WT_Project_Team.WT_Role_ID=GPM_Project_Template_Role.WT_Role_Id
																						INNER JOIN GPM_User On  GPM_WT_Project_Team.GD_User_Id=GPM_User.GD_User_Id WHERE GPM_WT_Project_Team.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_Project_Template_Role.WT_Role_Name=''MDPO Regional Approvers'' FOR XML PATH('''')), 2,50000)) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=56) /* Add Currency Column in select list*/
													BEGIN
														
														SELECT @_vdynSqlSelectField += ',(ISNULL(GPM_WT_Project.Currency_Code, (SELECT GPM_Country.Country_Code FROM GPM_Country WHERE '+ @_vWT_Table_Name_Cur+'.Country_Code=GPM_Country.Country_Code))) AS ['+ @_vLayout_vCustom_ColName +']'

														IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
															INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=57) /* Add Percentage Complete Column in select list*/
													BEGIN
													SELECT @_vdynSqlSelectField += ',CAST((SELECT CASE WHEN EXISTS(SELECT 1 FROM GPM_WT_Project_Gate INNER JOIN GPM_Gate_WT_Map ON GPM_WT_Project_Gate.Gate_Id=GPM_Gate_WT_Map.Gate_Id 
															WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND  GPM_Gate_WT_Map.WT_Code=GPM_WT_Project.WT_Code AND GPM_WT_Project_Gate.Is_Currently_Active=''Y'') THEN
																			ISNULL( (SELECT GPM_Gate.Weight_Perc FROM GPM_Gate WHERE GPM_Gate.Gate_Id =
																						(SELECT GPM_WT_Project_Gate.Gate_Id FROM GPM_WT_Project_Gate WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Gate.Gate_Order_Id=
																							(SELECT MAX(GPM_WT_Project_Gate.Gate_Order_Id) FROM GPM_WT_Project_Gate 
																								WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Gate.Is_Currently_Active=''N'' AND  GPM_WT_Project_Gate.Gate_Order_Id<
																									(
																										SELECT GPM_WT_Project_Gate.Gate_Order_Id FROM GPM_WT_Project_Gate  
																										WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id
																										AND GPM_WT_Project_Gate.Is_Currently_Active=''Y''
																									)
																							)
																					)),0)
																ELSE 

																				(SELECT GPM_Gate.Weight_Perc FROM GPM_Gate WHERE GPM_Gate.Gate_Id =
																					( SELECT GPM_WT_Project_Gate.Gate_Id FROM GPM_WT_Project_Gate WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id AND GPM_WT_Project_Gate.Gate_Order_Id=
																						(
																							SELECT MAX(GPM_WT_Project_Gate.Gate_Order_Id) FROM GPM_WT_Project_Gate 
																							WHERE GPM_WT_Project_Gate.WT_Project_Id=GPM_WT_Project.WT_Project_Id
																							AND GPM_WT_Project_Gate.Is_Currently_Active=''N''
																						)
																					))
															END) AS VARCHAR(20)) AS ['+ @_vLayout_vCustom_ColName +']'

																				 IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END
													

													IF(@_vLayoutTag_Id=21) /* Add Team Member Column in select list*/
													BEGIN
														
														IF(@_vWT_Code_Cur='FI')
															SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + CAST(GPM_Plant_Opt_Piller.Piller_Name AS VARCHAR(200)) FROM GPM_WT_DMAIC_MS_Attrib INNER JOIN GPM_Plant_Opt_Piller On GPM_WT_DMAIC_MS_Attrib.Piller_Id=GPM_Plant_Opt_Piller.Piller_Id
																						WHERE GPM_WT_DMAIC_MS_Attrib.DMAIC_Id=GPM_WT_DMAIC.DMAIC_Id FOR XML PATH('''')), 2,100000) ) AS ['+ @_vLayout_vCustom_ColName +']'

														ELSE IF(@_vWT_Code_Cur='IDEA')
															SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + CAST(GPM_Plant_Opt_Piller.Piller_Name AS VARCHAR(200)) FROM GPM_WT_IDEA_MS_Attrib INNER JOIN GPM_Plant_Opt_Piller On GPM_WT_IDEA_MS_Attrib.Piller_Id=GPM_Plant_Opt_Piller.Piller_Id
																						WHERE GPM_WT_IDEA_MS_Attrib.Idea_Id=GPM_WT_IDEA.Idea_Id FOR XML PATH('''')), 2,100000) ) AS ['+ @_vLayout_vCustom_ColName +']'

														ELSE IF(@_vWT_Code_Cur='GDI')
															SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + CAST(GPM_Plant_Opt_Piller.Piller_Name AS VARCHAR(200)) FROM GPM_WT_GDI_MS_Attrib INNER JOIN GPM_Plant_Opt_Piller On GPM_WT_GDI_MS_Attrib.Piller_Id=GPM_Plant_Opt_Piller.Piller_Id
																						WHERE GPM_WT_GDI_MS_Attrib.GDI_Id=GPM_WT_GDI.GDI_Id FOR XML PATH('''')), 2,100000) ) AS ['+ @_vLayout_vCustom_ColName +']'

														ELSE IF(@_vWT_Code_Cur='REP')
															SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + CAST(GPM_Plant_Opt_Piller.Piller_Name AS VARCHAR(200)) FROM GPM_WT_Replication_MS_Attrib INNER JOIN GPM_Plant_Opt_Piller On GPM_WT_Replication_MS_Attrib.Piller_Id=GPM_Plant_Opt_Piller.Piller_Id
																						WHERE GPM_WT_Replication_MS_Attrib.Replication_Id=GPM_WT_Replication.Replication_Id FOR XML PATH('''')), 2,100000) ) AS ['+ @_vLayout_vCustom_ColName +']'
														ELSE
															SELECT @_vdynSqlSelectField += ','''' AS ['+ @_vLayout_vCustom_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																	INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																		VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END

													IF(@_vLayoutTag_Id=13) /* GBS Served Geography*/
													BEGIN
														
														IF(@_vWT_Code_Cur='GBP')
															SELECT @_vdynSqlSelectField += ',(SELECT SUBSTRING((SELECT '','' + CAST(GPM_GBS_Geography.Gbs_Geography_Desc AS VARCHAR(200)) FROM GPM_WT_GBS_MS_Attrib INNER JOIN GPM_GBS_Geography On GPM_WT_GBS_MS_Attrib.Gbs_Geography_Id=GPM_GBS_Geography.Gbs_Geography_Id
																						WHERE GPM_WT_GBS_MS_Attrib.GBS_Id=GPM_WT_GBS.GBS_Id FOR XML PATH('''')), 2,100000) ) AS ['+ @_vLayout_vCustom_ColName +']'
														ELSE
															SELECT @_vdynSqlSelectField += ','''' AS ['+ @_vLayout_vCustom_ColName +']'

															IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																	INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																		VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1,@_vDisplay_Order)
													END	
			
												END
												ELSE


                                                IF EXISTS(SELECT 1 FROM @_vProcessedWTndTag_Table PTG WHERE PTG.TG_Table_Name=@_vLayout_TG_Table_Name)
													BEGIN
                                                                     SELECT @_vdynSqlSelectField += ','+ @_vLayout_TG_Table_Name +'.'+@_vLayout_vTG_Table_Desc_ColName +' AS ['+ @_vLayout_vCustom_ColName +']'

																	 IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
													END
                                                              
                                                ELSE
														BEGIN

																SELECT  @_vLayOut_TG_Table_PK_ColName = NULL,
																		@_vLayOut_TG_Table_ColName_Desc = NULL,
																		@_vLayOut_TG_Table_ColName_Custom_Desc = NULL,
																		@_vLayOut_WT_Table_Name = NULL,
																		@_vLayOut_WT_Table_FK_ColName = NULL

																SELECT  @_vLayOut_TG_Table_PK_ColName = TG_Table_PK_ColName,
																		@_vLayOut_TG_Table_ColName_Desc = TG_Table_ColName_Desc,
																		@_vLayOut_TG_Table_ColName_Custom_Desc = TG_Table_ColName_Custom_Desc,
																		@_vLayOut_WT_Table_Name=WT_Table_Name,
																		@_vLayOut_WT_Table_FK_ColName = WT_Table_FK_ColName
																FROM GPM_Layout_Tag_PK_ColMap WHERE Layout_Tag_Id=@_vLayoutTag_Id AND WT_Code=@_vWT_Code_Cur AND TG_Table_Name=@_vLayout_TG_Table_Name 


																IF(LEN(@_vLayOut_TG_Table_PK_ColName)>0)
																BEGIN
																	SET @_vdynSqlFrom += N' LEFT OUTER JOIN '+ @_vLayout_TG_Table_Name +N' ON '+@_vLayOut_WT_Table_Name+N'.'+@_vLayOut_WT_Table_FK_ColName+N' = '+@_vLayout_TG_Table_Name+N'.'+@_vLayOut_TG_Table_PK_ColName;

																	SELECT @_vdynSqlSelectField += ','+ @_vLayout_TG_Table_Name +'.'+@_vLayout_vTG_Table_Desc_ColName +' AS ['+ @_vLayout_vCustom_ColName +']'

																	IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
																END
																ELSE	
																	BEGIN 	
																		SELECT @_vdynSqlSelectField += ','+ ' '''' AS ['+ @_vLayout_vCustom_ColName+']'

																		IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vLayout_vCustom_ColName)
																			INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																				VALUES(@_vLayout_vCustom_ColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
																	END
                                                        END             
                                                              
                                                
                                                       SELECT @_vCnt=MIN(Row_ID) FROM @_vLayoutTag_Table WHERE Row_ID>@_vCnt
                                                
                                         END

                                  END      

								  
							
								  SELECT @_vTDCYearMonth = NULL,
										 @_vMonthName = NULL,
										 @_vMonthNumber = NULL,
										 @_vQuarterStartDate = NULL

										 
								
								  
                                  IF((SELECT COUNT(*) FROM @_vLayoutMetric_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vLayoutMetric_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

												SELECT  
                                                      -- @_vLayout_Id = NULL,
                                                       @_vMetric_Id = NULL,
                                                       @_vMetric_TDC_Type_Id = NULL,
                                                       @_vMetric_Field_Id = NULL,
                                                       @_vPeriod_Id = NULL,
                                                       @_vStart_Month_Id= NULL,
													   @_vStart_Quarter_Id= NULL, 
													   @_vStart_Year= NULL,
													   @_vEnd_Month_Id= NULL,
													   @_vEnd_Quarter_Id= NULL,
													   @_vEnd_Year= NULL,
                                                       @_vCustom_ColName = NULL,
                                                       @_vPrecision = NULL,
                                                       @_vProgram_Id = NULL

                                                SELECT  
                                                      -- @_vLayout_Id = Layout_Id,
                                                       @_vMetric_Id = Metric_Id,
                                                       @_vMetric_TDC_Type_Id = Metric_TDC_Type_Id,
                                                       @_vMetric_Field_Id = Metric_Field_Id,
                                                       @_vPeriod_Id = Period_Id,
                                                       @_vStart_Month_Id= Start_Month_Id,
													   @_vStart_Quarter_Id= Start_Quarter_Id, 
													   @_vStart_Year= Start_Year,
													   @_vEnd_Month_Id= End_Month_Id,
													   @_vEnd_Quarter_Id= End_Quarter_Id,
													   @_vEnd_Year= End_Year,
                                                       @_vCustom_ColName = Custom_ColName,
                                                       @_vPrecision = Precision,
                                                       @_vProgram_Id = Program_Id
                                                FROM @_vLayoutMetric_Table WHERE Row_ID=@_vCnt

												
												
													DELETE @_vLayoutMetricPeriod_Table
													SELECT @_vTDCstartDate =NULL,
															@_vTDCendDate =NULL
													

													
													IF(@_vPeriod_Id=10) /* Month Only*/
															BEGIN
															/*
																IF(@_vStart_Month_Id=10) 
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate)VALUES(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),101))
																ELSE
																IF(@_vStart_Month_Id=11) 
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate)VALUES(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(MONTH,-1, GETDATE()))-1),DATEADD(MONTH,-1,GETDATE())),101))
																ELSE
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate)
																		SELECT CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(@_vStart_Year AS VARCHAR(4)),113)

																		*/
																	/*	
																IF(@_vStart_Month_Id=10) 
																	SELECT @_vTDCstartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),101)
																ELSE
																IF(@_vStart_Month_Id=11) 
																	SELECT @_vTDCstartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(MONTH,-1, GETDATE()))-1),DATEADD(MONTH,-1,GETDATE())),101)
																ELSE
																BEGIN
																	IF(@_vStart_Year=-9999)
																		SELECT @_vTDCstartDate= CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)),113)
																	IF(@_vStart_Year=-9998)
																		SELECT @_vTDCstartDate= CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(DATEPART(YEAR, DATEADD(YEAR,-1,GETDATE())) AS VARCHAR(4)),113)
																	ELSE
																		SELECT @_vTDCstartDate= CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(@_vStart_Year AS VARCHAR(4)),113)
																END
																*/

																IF(@_vStart_Month_Id=10) 
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate) VALUES(DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()))
																ELSE
																IF(@_vStart_Month_Id=11) 
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate) VALUES(DATEADD(dd,-(DAY(DATEADD(MONTH,-1, GETDATE()))-1),DATEADD(MONTH,-1,GETDATE())))
																ELSE
																BEGIN
																	IF(@_vStart_Year=-9999)
																		INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate) VALUES(CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)),113))
																	IF(@_vStart_Year=-9998)
																		INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate) VALUES(CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(DATEPART(YEAR, DATEADD(YEAR,-1,GETDATE())) AS VARCHAR(4)),113))
																	ELSE
																		INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate) VALUES(CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(@_vStart_Year AS VARCHAR(4)),113))
																END
															END
													

														
														IF(@_vPeriod_Id=11) /* Quarter Only */
															BEGIN

																IF(@_vStart_Quarter_Id=10)
																	BEGIN

																	/*
																		SELECT TOP 1 @_vQuarterStartDate=CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113) 
																			FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB
														
									
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(@_vQuarterStartDate)
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,1,@_vQuarterStartDate))
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,2,@_vQuarterStartDate))

																			*/
																			/*
																			SELECT TOP 1 @_vTDCstartDate=CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113) 
																			FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB

																			SELECT @_vTDCendDate = DATEADD(MONTH,2,@_vTDCstartDate)
																			*/

																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																				SELECT CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113), DATEADD(MONTH,2, CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113) )
																					FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB

																					

																			
																	END
																ELSE
																IF(@_vStart_Quarter_Id=11)
																	BEGIN
																	/*
																			SELECT TOP 1 @_vQuarterStartDate=DATEADD(MONTH,-3,CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113)) 
																				FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB

															
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(@_vQuarterStartDate)
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,1,@_vQuarterStartDate))
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,2,@_vQuarterStartDate))

																			*/
																			/*
																			SELECT TOP 1 @_vTDCstartDate=DATEADD(MONTH,-3,CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113)) 
																				FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB

																			SELECT @_vTDCendDate = DATEADD(MONTH,2,@_vTDCstartDate)
																			*/

																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																				SELECT TOP 1 DATEADD(MONTH,-3,CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113)) , DATEADD(MONTH,2, DATEADD(MONTH,-3,CONVERT(DATE, '01'+' '+Value+' '+CONVERT(VARCHAR(4),GETDATE(),112), 113)) )
																					FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE CHARINDEX(DATENAME(month, Getdate()),Months,1)>0)) TAB

																	END
																ELSE 
																	BEGIN

																	/*
																		SELECT TOP 1 @_vQuarterStartDate=CONVERT(DATE, '01'+' '+Value+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) 
																				FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB

																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(@_vQuarterStartDate)
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,1,@_vQuarterStartDate))
																			INSERT INTO @_vLayoutMetricPeriod_Table(TDCDate) VALUES(DATEADD(MONTH,2,@_vQuarterStartDate))

																			*/
																			/*
																			IF(@_vStart_Year=-9999)
																				SELECT TOP 1 @_vTDCstartDate=CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)), 113) 
																					FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			IF(@_vStart_Year=-9998)
																				SELECT TOP 1 @_vTDCstartDate=CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, DATEADD(YEAR,-1,GETDATE())) AS VARCHAR(4)), 113) 
																					FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			ELSE
																				SELECT TOP 1 @_vTDCstartDate=CONVERT(DATE, '01'+' '+Value+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) 
																					FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			SELECT @_vTDCendDate = DATEADD(MONTH,2,@_vTDCstartDate)

																			*/

																			IF(@_vStart_Year=-9999)
																				INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																					SELECT TOP 1 CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)), 113), DATEADD(MONTH,2,CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)), 113) ) 
																						FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			IF(@_vStart_Year=-9998)
																				INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																					SELECT TOP 1 CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, DATEADD(YEAR,-1,GETDATE())) AS VARCHAR(4)), 113), DATEADD(MONTH,2, CONVERT(DATE, '01'+' '+Value+' '+CAST(DATEPART(YEAR, DATEADD(YEAR,-1,GETDATE())) AS VARCHAR(4)), 113))
																						FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			ELSE
																				INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																					SELECT TOP 1 CONVERT(DATE, '01'+' '+Value+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113), DATEADD(MONTH,2,CONVERT(DATE, '01'+' '+Value+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) ) 
																						FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB
																			


																	END
															END		



														IF(@_vPeriod_Id=12) /* Year Only*/
															BEGIN

															/*
																IF(@_vStart_Year='-9999')
																	SELECT @_vTDCstartDate=DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0),
																		@_vTDCendDate=DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) +1, 0))
																ELSE
																IF(@_vStart_Year='-9998')
																	SELECT @_vTDCstartDate=DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0),
																		 @_vTDCendDate=DATEADD(dd, -1, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
																ELSE
																	SELECT @_vTDCstartDate=CONVERT(DATE,CAST(@_vStart_Year AS VARCHAR(4))+'0101'),
																				@_vTDCendDate=CASE WHEN DATEPART(YEAR, GETDATE())=@_vStart_Year THEN 
																					CONVERT(DATE, '01'+' '+DATENAME(MONTH,GETDATE())+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) 
																							ELSE CONVERT(DATE,CAST(@_vStart_Year AS VARCHAR(4))+'1201' ,112) END

																							*/
																IF(@_vStart_Year='-9999')
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																		SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0),
																			DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) +1, 0))
																ELSE
																IF(@_vStart_Year='-9998')
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																		SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0),
																			DATEADD(dd, -1, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
																ELSE
																	INSERT INTO @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate) 
																	SELECT CONVERT(DATE,CAST(@_vStart_Year AS VARCHAR(4))+'0101'),
																				CASE WHEN DATEPART(YEAR, GETDATE())=@_vStart_Year THEN 
																					CONVERT(DATE, '01'+' '+DATENAME(MONTH,GETDATE())+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) 
																							ELSE CONVERT(DATE,CAST(@_vStart_Year AS VARCHAR(4))+'1201' ,112) END

																							/*
																;WITH CTE AS 
																(
																	SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
																	UNION ALL
																	SELECT DATEADD(MONTH, 1, Dates)
																	FROM CTE
																	WHERE CONVERT(DATE, Dates) < CONVERT(DATE, @_vTDCendDate)
																)                    
																INSERT @_vLayoutMetricPeriod_Table(TDCDate)
																		SELECT Dates FROM CTE
																				ORDER BY Dates

																				*/
															END


															IF(@_vPeriod_Id=13) /*Monthly Range */
															BEGIN

																	
																SELECT @_vTDCstartDate=CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vStart_Month_Id)+CAST(@_vStart_Year AS VARCHAR(4)),113),
																		@_vTDCendDate=CONVERT(DATE,'01'+(SELECT Month_Name_Desc FROM GPM_Month_Period_Type WHERE Month_Id=@_vEnd_Month_Id)+CAST(@_vEnd_Year AS VARCHAR(4)),113)

																			
																														
																			
																			
																;WITH CTE AS 
																(
																	SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
																	UNION ALL
																	SELECT DATEADD(MONTH, 1, Dates)
																	FROM CTE
																	WHERE CONVERT(DATE, Dates) < CONVERT(DATE, @_vTDCendDate)
																)                    
																INSERT @_vLayoutMetricPeriod_Table(TDCStartDate)
																		SELECT Dates FROM CTE
																				ORDER BY Dates
																				
															END

															IF(@_vPeriod_Id=14) /* Quarterly Range*/
															BEGIN

																	
																SELECT TOP 1 @_vTDCstartDate=CONVERT(DATE, '01'+' '+Value+' '+CAST(@_vStart_Year AS VARCHAR(4)), 113) 
																				FROM dbo.Fn_SplitDelimetedData(',',(SELECT Months FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vStart_Quarter_Id)) TAB		

																SELECT TOP 1 @_vTDCendDate=CONVERT(DATE, '01'+' '+REVERSE(Value)+' '+CAST(@_vEnd_Year AS VARCHAR(4)), 113) 
																				FROM dbo.Fn_SplitDelimetedData(',',(SELECT REVERSE(Months) FROM GPM_Quarter_Period_Type WHERE Quarter_Id=@_vEnd_Quarter_Id)) TAB		
																				
																				/*
																;WITH CTE AS 
																(
																	SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
																	UNION ALL
																	SELECT DATEADD(MONTH, 1, Dates)
																	FROM CTE
																	WHERE CONVERT(DATE, Dates) < CONVERT(DATE, @_vTDCendDate)
																)                    
																INSERT @_vLayoutMetricPeriod_Table(TDCDate)
																		SELECT Dates FROM CTE
																				ORDER BY Dates
																				*/

																;WITH CTE
																AS
																( SELECT @_vTDCstartDate AS date1
																		UNION All
																	SELECT DateAdd(Month,3,date1) FROM cte where date1 < @_vTDCendDate
																) 
																INSERT @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate)
																SELECT date1, DATEADD(MONTH,2,date1) FROM CTE
																WHERE Date1<@_vTDCendDate
																ORDER BY date1

																				
															END


															IF(@_vPeriod_Id=15) /* Yearly Range */
															BEGIN

																	
																	SELECT @_vTDCstartDate=CONVERT(DATE,CAST(@_vStart_Year AS VARCHAR(4))+'0101' ,112),
																			@_vTDCendDate=CASE WHEN (DATEPART(YEAR, GETDATE())=@_vEnd_Year) THEN
																							CONVERT(DATE, '01'+' '+DATENAME(MONTH,GETDATE())+' '+CAST(@_vEnd_Year AS VARCHAR(4)), 113) 
																							ELSE CONVERT(DATE,CAST(@_vEnd_Year AS VARCHAR(4))+'1201' ,112) END
																			

																;WITH CTE AS 
																(
																	SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
																	UNION ALL
																	SELECT DATEADD(YEAR, 1, Dates)
																	FROM CTE
																	WHERE CONVERT(DATE, Dates) < CONVERT(DATE, @_vTDCendDate)
																)                    
																INSERT @_vLayoutMetricPeriod_Table(TDCStartDate, TDCEndDate)
																		SELECT Dates, DATEADD(MONTH,11,Dates) FROM CTE
																			WHERE Dates< @_vTDCendDate
																				ORDER BY Dates
																				
															END

														
														
														
													
												SELECT  @_vTDC_Table_Name='',
														@_vTDCType_ColPrefix ='',
														@_vStart_Year=NULL,
														@_vTDCAttribColName=NULL,
														@_vDisplay_Order=NULL															
												IF(@_vMetric_Id=22 AND (SELECT COUNT(*) FROM @_vLayoutMetricPeriod_Table)>0) /* Start If TDC Metric Act_Fcst*/
												--IF(@_vMetric_Id=22 AND  ((@_vPeriod_Id=10  AND @_vTDCstartDate IS NOT NULL) OR (@_vPeriod_Id != 10 AND @_vTDCstartDate IS NOT NULL AND @_vTDCendDate IS NOT NULL)))

													BEGIN

													IF(@_vMetric_TDC_Type_Id=10)
														SELECT  @_vTDC_Table_Name = 'GPM_WT_Project_TDC_Saving',
																@_vTDCType_ColPrefix = 'Act_Fcst.',
																@_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																WHERE Layout_Tag_Type_Desc='TDC Metrics Act+FCst Tag'
																AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vMetric_Field_Id

													IF(@_vMetric_TDC_Type_Id=11)
														SELECT  @_vTDC_Table_Name = 'GPM_WT_Project_TDC_Saving_Baseline',
															@_vTDCType_ColPrefix = 'Baseline.',
															@_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																WHERE Layout_Tag_Type_Desc='TDC Metrics Baseline Tag'
																AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vMetric_Field_Id
																

																
																

														SELECT @_vTDCMinDate=MIN(TDCStartDate), @_vTDCMaxDate= MAX(TDCStartDate) FROM @_vLayoutMetricPeriod_Table

															  WHILE(@_vTDCMinDate<DATEADD(DAY,1,@_vTDCMaxDate))
																	BEGIN

																		SELECT @_vTDCstartDate=NULL,
																				@_vTDCendDate=NULL
																		
																		SELECT @_vTDCstartDate=TDCStartDate,
																				@_vTDCendDate=TDCEndDate
																		 FROM @_vLayoutMetricPeriod_Table WHERE CONVERT(VARCHAR(8), TDCStartDate,112)=CONVERT(VARCHAR(8),@_vTDCMinDate,112)
																		
																		SELECT @_vStart_Year= DATEPART(YEAR, @_vTDCstartDate)
																	
																		

																		SELECT @_vAttrib_Name=Attrib_Name FROM GPM_Metrics_TDC_Saving WHERE Attrib_Id=@_vMetric_Field_Id
																		SELECT @_vTDCAttribColName = CASE WHEN @_vPeriod_Id IN(10,13) THEN 
																											@_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')
																										--WHEN @_vPeriod_Id = 15 THEN 
																											--@_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM')
																										ELSE
																											@_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM') 
																										END
																										

                                                
																			--IF(@_vMetric_Field_Id IN (SELECT Attrib_Id FROM GPM_Metrics_TDC_Saving WHERE  Is_Computed_Attrib='N'))

																			 --SELECT @_vWT_Code_Cur, @_vdynSqlSelectField
																					--PRINT @_vdynSqlSelectField

																					

																					IF(@_vWT_Code_Cur  IN('GBP', 'IDEA'))
																						SELECT @_vdynSqlSelectField += ',''0'' AS ['+ @_vTDCAttribColName +']'
																					ELSE				 
																					  BEGIN
																					IF(@_vMetric_Field_Id IN (SELECT Attrib_Id FROM GPM_Metrics_TDC_Saving WHERE  Is_Computed_Attrib='N'))

																						SELECT @_vdynSqlSelectField += ','+ ' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0))  FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name +'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																							  @_vTDC_Table_Name +'.Attrib_Id='+CAST(@_vMetric_Field_Id AS VARCHAR(10)) +
																							  
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END
																							  
																					ELSE IF(@_vMetric_Field_Id = 18) 	/*GSS Conversion*/	
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND((ISNULL((SELECT ISNULL(SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)),0) FROM '+@_vTDC_Table_Name +'
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(37,38,39,40,41,42,43,44,45,46,47,48) ' + 
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 50)  /*TOTAL - WC IMPROVEMENT*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(15,16) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 51)  /*TOTAL - GROSS SAVINGS*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(17,18,19,20,21) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END
																						  
																					ELSE IF(@_vMetric_Field_Id = 52) /*TOTAL - (HW) / TW*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)),0) FROM '+ @_vTDC_Table_Name +'
																							  WHERE '+ @_vTDC_Table_Name +'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(22,23,24,25,26) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 53)  /*TOTAL - Cost Avoidance*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)),0)  FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(27,28,29,30) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 54) /*TOTAL - COST OF SAVINGS*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)),0)  FROM '+@_vTDC_Table_Name +'
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(32,33,34,35,36) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 55) /*CONVERSION SCORECARD*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)),0) FROM '+ @_vTDC_Table_Name +'
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							   '+@_vTDC_Table_Name +'.Attrib_Id IN(37,38,39,40,41,42,43,44,45,46,47,48) ' +
																							   CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 10) /*TT-Raw Material*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 32 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END ),0)  FROM '+@_vTDC_Table_Name +'
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																								'+@_vTDC_Table_Name+'.Attrib_Id IN(17,22,27,32) '+
																								CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 11) /*TT-Conversion*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 33 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END ),0) FROM '+@_vTDC_Table_Name +'
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																							  @_vTDC_Table_Name+'.Attrib_Id IN(23,28,33) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 12) /*TT-Other CGS*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 34 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END ),0) FROM '+ @_vTDC_Table_Name +'
																							  WHERE '+@_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+ 
																							  @_vTDC_Table_Name+'.Attrib_Id IN(19,24,29,34) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 13) /*TT-Transportation*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 35 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END ),0) FROM '+ @_vTDC_Table_Name +'
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+ 
																							  @_vTDC_Table_Name+'.Attrib_Id IN(20,25,30,35) ' +
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																							 

																					ELSE IF(@_vMetric_Field_Id = 14) /*TT-SAG*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT ISNULL(SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id = 36 THEN  ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END ),0) FROM '+@_vTDC_Table_Name +'
																							  WHERE '+@_vTDC_Table_Name +'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																							  @_vTDC_Table_Name +'.Attrib_Id IN(21,26,31,36) ' +
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																					ELSE IF(@_vMetric_Field_Id = 49) /*TOTAL - SAVINGS*/		
																						SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT (SUM(CASE WHEN Attrib_Id = 32 THEN  ISNULL('+ @_vTDC_Table_Name+'.Attrib_Value ,0)*-1 
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
																																) ' +
																								CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END
																							  
																				 END

																				
																
																--IF( @_vPeriod_Id=10)
																--BEGIN
																--PRINT @_vTDCAttribColName
																		IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vTDCAttribColName)
																				INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																					VALUES(@_vTDCAttribColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
																--END
																--ELSE
																--BEGIN
																--		IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=(@_vTDCType_ColPrefix +@_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM')))
																--				INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder)
																--					VALUES((@_vTDCType_ColPrefix +@_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM')), 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1)
																--END
																					
																
																		SELECT @_vTDCMinDate=MIN(TDCStartDate) FROM @_vLayoutMetricPeriod_Table WHERE TDCStartDate>@_vTDCMinDate
																	END		/* END INNER WHILE DATE ITERATIONS*/
																END /* END IF TDC Matrics*/

																--PRINT CAST(@_vMetric_Field_Id AS VARCHAR(10)) +'  '+ @_vdynSqlSelectField
																

																
															SELECT @_vTDC_Table_Name='',
																	@_vStart_Year=NULL,
																	@_vTDCAttribColName=NULL,
																	@_vDisplay_Order=NULL																													
																IF(@_vMetric_Id=15 AND (SELECT COUNT(*) FROM @_vLayoutMetricPeriod_Table)>0) /* Start If TDC Metric Act_Fcst*/
																--IF(@_vMetric_Id=15 AND   ((@_vPeriod_Id=10  AND @_vTDCstartDate IS NOT NULL) OR (@_vPeriod_Id != 10 AND @_vTDCstartDate IS NOT NULL AND @_vTDCendDate IS NOT NULL)))
																	BEGIN

																		IF(@_vMetric_TDC_Type_Id=10)
																		BEGIN
																			SELECT @_vTDC_Table_Name = 'GPM_WT_Project_GBS_Saving_ActFcst',
																					@_vTDCType_ColPrefix = 'Act_Fcst.',
																					 @_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																					WHERE Layout_Tag_Type_Desc='GBS Saving Metrics Act+Fcst Tag'
																					AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vMetric_Field_Id
																		END

																		IF(@_vMetric_TDC_Type_Id=11)
																			SELECT @_vTDC_Table_Name = 'GPM_WT_Project_GBS_Saving_Baseline',
																				@_vTDCType_ColPrefix = 'Baseline.',
																				@_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																					WHERE Layout_Tag_Type_Desc='GBS Saving Metrics Baseline Tag'
																					AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vMetric_Field_Id

																		IF(@_vMetric_TDC_Type_Id=12)
																			SELECT @_vTDC_Table_Name = 'GPM_WT_Project_GBS_Saving_OtherLoc',
																				@_vTDCType_ColPrefix = 'OtherLocation.',
																				@_vDisplay_Order=GPM_WT_Layout_Tag_Order.Layout_Tag_Order_Id  FROM GPM_WT_Layout_Tag_Order INNER JOIN GPM_Layout_Tag_Type On GPM_WT_Layout_Tag_Order.Layout_Tag_Type_Id=GPM_Layout_Tag_Type.Layout_Tag_Type_Id
																					WHERE Layout_Tag_Type_Desc='GBS Saving Metrics Other Location Tag'
																					AND GPM_WT_Layout_Tag_Order.Layout_Id=@vLayout_Id AND GPM_WT_Layout_Tag_Order.Layout_Tag_Id=@_vMetric_Field_Id
																			

																SELECT @_vTDCMinDate=MIN(TDCStartDate), @_vTDCMaxDate= MAX(TDCStartDate) FROM @_vLayoutMetricPeriod_Table

																	WHILE(@_vTDCMinDate<DATEADD(DAY,1,@_vTDCMaxDate))
																			BEGIN


																	--		SELECT @_vStart_Year=NULL

																		SELECT @_vTDCstartDate=NULL,
																				@_vTDCendDate=NULL

																		SELECT @_vTDCstartDate=TDCStartDate,
																				@_vTDCendDate=TDCEndDate
																		 FROM @_vLayoutMetricPeriod_Table WHERE CONVERT(VARCHAR(8), TDCStartDate,112)=CONVERT(VARCHAR(8),@_vTDCMinDate,112)	
																

																			SELECT @_vStart_Year= DATEPART(YEAR, @_vTDCstartDate)

																			SELECT @_vAttrib_Name=Attrib_Name FROM GPM_Metrics_GBS_Saving WHERE Attrib_Id=@_vMetric_Field_Id

																			SELECT @_vTDCAttribColName = CASE WHEN @_vPeriod_Id IN(10,13) THEN 
																											@_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')
																								--		WHEN @_vPeriod_Id = 15 THEN @_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM')
																										ELSE
																											@_vTDCType_ColPrefix+ @_vAttrib_Name +'_'+ Convert(VARCHAR(4),@_vTDCstartDate,112) +'-'+ FORMAT(@_vTDCstartDate,'MMMM')+'_'+ Convert(VARCHAR(4),@_vTDCendDate,112) +'-'+ FORMAT(@_vTDCendDate,'MMMM') 
																										END

																					IF(@_vWT_Code_Cur='GBP')
																					BEGIN
																						IF(@_vMetric_Field_Id IN (SELECT Attrib_Id FROM GPM_Metrics_GBS_Saving WHERE  Is_Computed_Attrib='N'))
																							SELECT @_vdynSqlSelectField += ','+ ' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0))  FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name +'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND '+
																							  @_vTDC_Table_Name +'.Attrib_Id='+CAST(@_vMetric_Field_Id AS VARCHAR(10)) +
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																						ELSE IF(@_vMetric_Field_Id = 10)  /*People Investment*/		
																							SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(11,12,13,14,15) ' +
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																						ELSE IF(@_vMetric_Field_Id = 16)  /*Operational Costs*/		
																							SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(17,18,19,20,21,22,23) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																						ELSE IF(@_vMetric_Field_Id = 25)  /*Gross Savings*/		
																							SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(11,12,13,14,15,/*People Investment*/
																																17,18,19,20,21,22,23, /*Operational Cost*/
																																24 /*Other SAG*/
																																) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END

																						ELSE IF(@_vMetric_Field_Id = 27)  /*Total Net Savings*/		
																							SELECT @_vdynSqlSelectField += ','+	' CAST(FLOOR(ROUND(ISNULL((SELECT SUM(CASE WHEN '+@_vTDC_Table_Name+'.Attrib_Id=26 THEN ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0)*-1 ELSE ISNULL('+@_vTDC_Table_Name+'.Attrib_Value,0) END) FROM '+@_vTDC_Table_Name+' 
																							  WHERE '+ @_vTDC_Table_Name+'.WT_Project_ID=GPM_WT_Project.WT_Project_ID AND 
																							  '+@_vTDC_Table_Name+'.Attrib_Id IN(11,12,13,14,15,/*People Investment*/
																																17,18,19,20,21,22,23, /*Operational Cost*/
																																24, /*Other SAG*/
																																26 /*Cost of Implementation*/
																																) '+
																							  CASE WHEN @_vPeriod_Id IN(10,13) THEN  ' AND ' + @_vTDC_Table_Name +'.YearMonth='+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+'),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																									--WHEN @_vPeriod_Id =15 THEN  ' AND (' +@_vTDC_Table_Name +'.Year BETWEEN '+CONVERT(VARCHAR(4),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(4),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  ELSE ' AND (' +@_vTDC_Table_Name +'.YearMonth BETWEEN '+CONVERT(VARCHAR(6),@_vTDCstartDate,112)+ ' AND '+ CONVERT(VARCHAR(6),@_vTDCendDate,112) + ')),0),-0)) AS VARCHAR(20))  AS '''+ @_vTDCAttribColName+''''
																							  END
																						
																							
																					END
																					ELSE		
																						SELECT @_vdynSqlSelectField += ',''0'' AS ['+ @_vTDCAttribColName +']'
																					
																					


																			IF NOT EXISTS(SELECT 1 FROM @_vDashboardColumnMap_Table WHERE SelectField=@_vTDCAttribColName)
																				INSERT INTO @_vDashboardColumnMap_Table (SelectField, DashBoardColumn,  ColumnOrder, Display_Order)
																					VALUES(@_vTDCAttribColName, 'Column_'+CAST((SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1 AS VARCHAR(10)), (SELECT ISNULL(MAX(ColumnOrder),-1) FROM @_vDashboardColumnMap_Table)+1, @_vDisplay_Order)
																

																				SELECT @_vTDCMinDate=MIN(TDCStartDate) FROM @_vLayoutMetricPeriod_Table WHERE TDCStartDate>@_vTDCMinDate

																			END

																			
																		END
																	
																SELECT @_vCnt=MIN(Row_ID) FROM @_vLayoutMetric_Table WHERE Row_ID>@_vCnt
														END	/*END Outer WHILE */

												END
												
												

						
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


						/* Format queries to retreive ALL the project which fits in Portfolio Criteria*/

								SELECT @_vCnt=0,
										@_vMaxCnt=0

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
							


--SELECT * FROM @_vWTQueriesTab

--SELECT * FROM @_vDashboardColumnMap_Table
SELECT @_vHeaderList = REPLACE(@_vdynSqlSelectCommonField,'@@Row_Type','1') +(SELECT ','+ ''''+ SelectField +''' AS ['+SelectField +']' FROM @_vDashboardColumnMap_Table FOR XML PATH(''))
--PRINT @_vHeaderList

SELECT @_vColumnList = @_vColumnCommonList +(SELECT','+ DashBoardColumn FROM @_vDashboardColumnMap_Table FOR XML PATH(''))
DECLARE @_vdynInsert VARCHAR(MAX)


DECLARE @_vSelectColumnListOrdered VARCHAR(MAX)

SELECT @_vSelectColumnListOrdered = @_vColumnCommonList +(SELECT ','+ '['+SelectField +']' FROM @_vDashboardColumnMap_Table ORDER BY Display_Order FOR XML PATH(''))

--PRINT @_vSelectColumnListOrdered

---IF EXISTS(SELECT TOP 1 Login_User_Id  FROM GPM_WT_DashBoard WHERE Login_User_Id= @vLogin_User_Id AND Portfolio_Id = @vPortfolio_Id AND Layout_Id = @vLayout_Id)
	DELETE FROM GPM_WT_DashBoard WHERE Login_User_Id = @vLogin_User_Id AND Portfolio_Id = @vPortfolio_Id AND Layout_Id = @vLayout_Id


--SET @_vdynInsert= (SELECT 'INSERT INTO GPM_WT_DashBoard ('+ @_vColumnList + ') ' + @_vHeaderList +' UNION ALL '+ @_vdynSqlFinalQuery)

SET @_vdynInsert= (SELECT 'INSERT INTO GPM_WT_DashBoard ('+ @_vColumnList + ') ' +'SELECT ' + @_vSelectColumnListOrdered + ' FROM ('+
							@_vHeaderList +' UNION ALL '+ @_vdynSqlFinalQuery +') TAB')

--SET @_vdynInsert=  'SELECT ' + @_vSelectColumnListOrdered + ' FROM ('+
--							@_vHeaderList +' UNION ALL '+ @_vdynSqlFinalQuery +') TAB'



--PRINT @_vdynInsert

--SELECT @_vdynInsert

EXEC(@_vdynInsert)

UPDATE GPM_WT_DashBoard SET Filled_Row=(SELECT COUNT(*) FROM GPM_WT_DashBoard WHERE Login_User_Id = @vLogin_User_Id AND Portfolio_Id = @vPortfolio_Id AND Layout_Id = @vLayout_Id AND Row_Type=0),
Filled_Column=(SELECT COUNT(*) FROM @_vDashboardColumnMap_Table) WHERE Login_User_Id = @vLogin_User_Id AND Portfolio_Id = @vPortfolio_Id AND Layout_Id = @vLayout_Id AND Row_Type=1

	
SELECT * FROM GPM_WT_DashBoard WHERE Login_User_Id= @vLogin_User_Id AND Portfolio_Id = @vPortfolio_Id AND Layout_Id = @vLayout_Id order by Row_Type desc

END


