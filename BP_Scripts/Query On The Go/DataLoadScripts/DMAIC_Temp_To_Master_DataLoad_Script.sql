--USE [PMT_Migration]
--GO
--/****** Object:  StoredProcedure [dbo].[Temp_DMAIC_DATA_LOAD]    Script Date: 4/3/2019 7:00:35 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER PROCEDURE [dbo].[Temp_DMAIC_DATA_LOAD]
--AS




BEGIN
DECLARE @_vName	VARCHAR(2000)
DECLARE @_vPowerSteering_ID	VARCHAR(500)
DECLARE @_vSequence_number VARCHAR(500)
DECLARE @_vProject_Lead	VARCHAR(500)
DECLARE @_vSystem_start_date VARCHAR(500)
DECLARE @_vActive_phase	VARCHAR(500)
DECLARE @_vSystem_end_date VARCHAR(500)
DECLARE @_vStatus VARCHAR(500)
DECLARE @_vWork_Template VARCHAR(500)
DECLARE @_vWork_type VARCHAR(500)
DECLARE @_vComments	VARCHAR(2000)
DECLARE @_vConsequential_Metric	VARCHAR(2000)
DECLARE @_vExpected_Benefits VARCHAR(2000)
DECLARE @_vExpected_Total_Savings_in_$	VARCHAR(2000)
DECLARE @_vExpected_Total_Savings_in_$_raw	VARCHAR(2000)
DECLARE @_vGoal_Statement VARCHAR(2000)
DECLARE @_vPrimary_Metric_and_Current_Performance VARCHAR(2000)
DECLARE @_vProblem_Statement VARCHAR(2000)
DECLARE @_vProject_Scope_and_Scale	VARCHAR(2000)
DECLARE @_vSecondary_Metric	VARCHAR(2000)
DECLARE @_vBaseline	VARCHAR(2000)
DECLARE @_vLoss_Opportunity	VARCHAR(2000)
DECLARE @_vLoss_Opportunity_raw	VARCHAR(2000)
DECLARE @_vMeasures_of_Success	VARCHAR(2000)
DECLARE @_vTarget	VARCHAR(2000)
DECLARE @_vAnalyze	VARCHAR(2000)
DECLARE @_vCapEx	VARCHAR(2000)
DECLARE @_vCapEx_ID	VARCHAR(2000)
DECLARE @_vControl	VARCHAR(2000)
DECLARE @_vDefine	VARCHAR(2000)
DECLARE @_vImprove	VARCHAR(2000)
DECLARE @_vMeasure	VARCHAR(2000)
DECLARE @_vDMAIC_Id INT
DECLARE @_vWT_Project_Id INT

DECLARE @_vBusiness_Area	VARCHAR(2000)
DECLARE @_vCost_Category	VARCHAR(2000)
DECLARE @_vCountry VARCHAR(2000)
DECLARE @_vDepartments VARCHAR(2000)
DECLARE @_vFinance_BPO VARCHAR(2000)
DECLARE @_vFinancial_Impact_Area VARCHAR(2000)
DECLARE @_vLocation VARCHAR(2000)
DECLARE @_vPlant_Optimization_pillar VARCHAR(2000)
DECLARE @_vPrimary_Loss_Categories VARCHAR(2000)
DECLARE @_vProduct_Category VARCHAR(2000)
DECLARE @_vProject_Allocation VARCHAR(2000)
DECLARE @_vProject_Category VARCHAR(2000)
DECLARE @_vProject_Codification VARCHAR(2000)
DECLARE @_vProject_Main_Category VARCHAR(2000)
DECLARE @_vRegions VARCHAR(2000)
DECLARE @_vSub_Cost_Categories VARCHAR(2000)
DECLARE @_vFinancial_Rep VARCHAR(2000)
DECLARE @_vSponsor VARCHAR(2000)


DECLARE @_vRegion_Code VARCHAR(5)
DECLARE @_vCountry_Code VARCHAR(3)
DECLARE @_vLocation_ID INT
DECLARE @_vBA_Id INT
DECLARE @_vDept_ID INT
DECLARE @_vFN_BPO_ID INT
DECLARE @_vProduct_Cat_Id INT
DECLARE @_vProj_Main_Cat_Id INT
DECLARE @_vProj_Cat_Id INT
DECLARE @_vFin_Impact_Ar_Id INT
DECLARE @_vCost_Cat_Id INT
DECLARE @_vPrim_Loss_Cat_Id INT
DECLARE @_vStatus_Id INT
DECLARE @_vCreated_By VARCHAR(10)

DECLARE @_vTabGate AS TABLE (WT_Project_Id INT, Gate_Id INT, Gate_Order_Id INT)
DECLARE @_vMaxTabOrder INT 
DECLARE @_vTabCnt INT
DECLARE @_vGate_Id INT

DECLARE @_vDeliverable_Id INT=0
DECLARE @_vDeliverable_Order INT=0

DECLARE @_vGPM_WT_Project_Team_Deliverable_Table AS Table(Deliverable_Id INT, Project_Lead VARCHAR(500))
													
DECLARE @_vActive_Gate VARCHAR(500)

DECLARE @_vProjectMember_Table  As Table (Row_Id INT IDENTITY(1,1), WT_Role_Name VARCHAR(200), Project_Member_Name VARCHAR(500))
DECLARE @_vWT_Role_Name VARCHAR(200)
DECLARE @_vProject_Member_Name VARCHAR(500)
DECLARE @_vProject_Member_Id VARCHAR(10)=NULL	

DECLARE @_vValidData VARCHAR(5)='TRUE'											
DECLARE @_vError_Desc VARCHAR(MAX)=''
DECLARE @_vTempGateCnt Int =0
DECLARE @_vDBGateCnt Int =0

DECLARE @_vPiller_Name_Table AS Table(Piller_Name VARCHAR(500))
DECLARE @_vPiller_Name VARCHAR(8000)


TRUNCATE TABLE Temp_Dmaic_Error

TRUNCATE TABLE Temp_Dmaic_MissingRoleMember_Error

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving_Baseline

--TRUNCATE TABLE GPM_WT_Project_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Team

--TRUNCATE TABLE GPM_WT_Project_Team_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Gate

--DELETE FROM GPM_WT_Project

--DELETE FROM GPM_WT_DMAIC


SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='FI'  AND Is_Deleted_Ind='N'
 
DECLARE DMAIC_Cursor CURSOR FOR
		SELECT  
			A.Name,
			PowerSteering_ID,
			A.Sequence_number,
			Project_Lead,
			System_start_date,
			Active_phase,
			System_end_date,
			Status,
			Work_Template,
			Work_type,
			Comments,
			Consequential_Metric,
			Expected_Benefits,
			Expected_Total_Savings_in_$,
			Expected_Total_Savings_in_$_raw,
			Goal_Statement,
			Primary_Metric_and_Current_Performance,
			Problem_Statement,
			Project_Scope_and_Scale,
			Secondary_Metric,
			Baseline,
			Loss_Opportunity,
			Loss_Opportunity_raw,
			Measures_of_Success,
			Target,
			Analyze,
			CapEx,
			CapEx_ID,
			Control,
			Define,
			Improve,
			Measure
	FROM
		Temp_DMAIC_Custom_fields A --INNER JOIN Temp_Dmaic_Error_20190611 B On A.Sequence_number = B.Sequence_number
		

	OPEN DMAIC_Cursor
	FETCH NEXT FROM DMAIC_Cursor INTO 
				@_vName,
				@_vPowerSteering_ID,
				@_vSequence_number,
				@_vProject_Lead,
				@_vSystem_start_date,
				@_vActive_phase,
				@_vSystem_end_date,
				@_vStatus,
				@_vWork_Template,
				@_vWork_type,
				@_vComments,
				@_vConsequential_Metric,
				@_vExpected_Benefits,
				@_vExpected_Total_Savings_in_$,
				@_vExpected_Total_Savings_in_$_raw,
				@_vGoal_Statement,
				@_vPrimary_Metric_and_Current_Performance,
				@_vProblem_Statement,
				@_vProject_Scope_and_Scale,
				@_vSecondary_Metric,
				@_vBaseline,
				@_vLoss_Opportunity,
				@_vLoss_Opportunity_raw,
				@_vMeasures_of_Success,
				@_vTarget,
				@_vAnalyze,
				@_vCapEx,
				@_vCapEx_ID,
				@_vControl,
				@_vDefine,
				@_vImprove,
				@_vMeasure

		WHILE @@FETCH_STATUS = 0
       
			BEGIN

				SELECT 
				@_vValidData = 'TRUE',
				@_vBusiness_Area	= NULL,
				@_vCost_Category	= NULL,
				@_vCountry = NULL,
				@_vDepartments = NULL,
				@_vFinance_BPO = NULL,
				@_vFinancial_Impact_Area = NULL,
				@_vLocation = NULL,
				@_vPlant_Optimization_pillar = NULL,
				@_vPrimary_Loss_Categories = NULL,
				@_vProduct_Category = NULL,
				@_vProject_Allocation = NULL,
				@_vProject_Category = NULL,
				@_vProject_Codification = NULL,
				@_vProject_Main_Category = NULL,
				@_vRegions = NULL,
				@_vSub_Cost_Categories = NULL,

				@_vRegion_Code=NULL,
				@_vCountry_Code=NULL,
				@_vLocation_ID=NULL,
				@_vBA_Id=NULL,
				@_vDept_ID = NULL,
				@_vFN_BPO_ID=NULL,
				@_vProduct_Cat_Id=NULL,
				@_vProj_Main_Cat_Id=NULL,
				@_vProj_Cat_Id=NULL,
				@_vFin_Impact_Ar_Id=NULL,
				@_vCost_Cat_Id=NULL,
				@_vPrim_Loss_Cat_Id=NULL

			SELECT 
				@_vBusiness_Area	= Business_Area,
				@_vCost_Category	= Cost_Category,
				@_vCountry = Country,
				@_vDepartments = Departments,
				@_vFinance_BPO = Finance_BPO,
				@_vFinancial_Impact_Area = Financial_Impact_Area,
				@_vLocation = Location,
				@_vPlant_Optimization_pillar = Plant_Optimization_pillar,
				@_vPrimary_Loss_Categories = Primary_Loss_Categories,
				@_vProduct_Category = Product_Category,
				@_vProject_Allocation = Project_Allocation,
				@_vProject_Category = Project_Category,
				@_vProject_Codification = Project_Codification,
				@_vProject_Main_Category = Project_Main_Category,
				@_vRegions = Regions,
				@_vSub_Cost_Categories = Sub_Cost_Categories
				FROM Temp_Dmaic_RoleAndTags
				WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))




				SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
				SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry))
				SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
				SELECT @_vBA_Id=BA_Id FROM GPM_Business_Area WHERE RTRIM(LTRIM(BA_Name))=RTRIM(LTRIM(@_vBusiness_Area))
				SELECT @_vDept_ID = Dept_ID FROM GPM_Department WHERE RTRIM(LTRIM(Dept_Name))=RTRIM(LTRIM(@_vDepartments)) AND BA_Id=@_vBA_Id
				SELECT @_vFN_BPO_ID=FN_BPO_ID FROM GPM_Finance_BPO WHERE RTRIM(LTRIM(FN_BPO_Name))=RTRIM(LTRIM(@_vFinance_BPO)) AND BA_Id=@_vBA_Id AND Dept_ID=@_vDept_ID
				SELECT @_vProduct_Cat_Id=Product_Cat_Id FROM GPM_Product_Category WHERE RTRIM(LTRIM(Product_Cat_Desc))=RTRIM(LTRIM(@_vProduct_Category))
				SELECT @_vProj_Main_Cat_Id=Proj_Main_Cat_Id FROM GPM_Proj_Main_Category WHERE RTRIM(LTRIM(Proj_Main_Cat_Desc))=RTRIM(LTRIM(@_vProject_Main_Category))
				SELECT @_vProj_Cat_Id=Proj_Cat_Id FROM GPM_Proj_Category WHERE RTRIM(LTRIM(Proj_Cat_Desc))=RTRIM(LTRIM(@_vProject_Category)) AND Proj_Main_Cat_Id=@_vProj_Main_Cat_Id
				SELECT @_vFin_Impact_Ar_Id=Fin_Impact_Ar_Id FROM GPM_Finance_Impact_Area WHERE RTRIM(LTRIM(Fin_Impact_Ar_Desc))=RTRIM(LTRIM(@_vFinancial_Impact_Area)) 
				SELECT @_vCost_Cat_Id=Cost_Cat_Id FROM GPM_Cost_Category WHERE RTRIM(LTRIM(Cost_Cat_Desc))=RTRIM(LTRIM(@_vCost_Category)) 
				SELECT @_vPrim_Loss_Cat_Id=Prim_Loss_Cat_Id FROM GPM_Primary_Loss_Category WHERE RTRIM(LTRIM(Prim_Loss_Cat_Desc))=RTRIM(LTRIM(@_vPrimary_Loss_Categories)) 
				SELECT @_vStatus_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
				SELECT @_vCreated_By=GD_User_Id FROM GPM_USer WHERE User_First_Name +' '+User_Last_Name = RTRIM(LTRIM(@_vProject_Lead))

				DELETE FROM @_vPiller_Name_Table
				SELECT @_vPiller_Name=NULL
				SELECT @_vTempGateCnt=0
				SELECT @_vError_Desc=''

				IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : DMAIC Name Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vSystem_start_date IS NULL)
				BEGIN
					SELECT @_vError_Desc += '| MA : Planned Start Date Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vDefine IS NULL OR LEN(LTRIM(RTRIM(@_vDefine)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Definition Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vPrimary_Metric_and_Current_Performance IS NULL OR LEN(LTRIM(RTRIM(@_vPrimary_Metric_and_Current_Performance)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Primary Metric and Current Performance Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vRegions IS NULL OR LEN(LTRIM(RTRIM(@_vRegions)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Region Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vRegion_Code IS NULL OR  LEN(LTRIM(RTRIM(@_vRegion_Code)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+@_vRegions +' Region Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vCountry IS NULL OR LEN(LTRIM(RTRIM(@_vCountry)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Country Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vCountry_Code IS NULL OR  LEN(LTRIM(RTRIM(@_vCountry_Code)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vCountry +'  Country Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vLocation IS NULL OR LEN(LTRIM(RTRIM(@_vLocation)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Location Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vLocation_ID IS NULL OR  @_vLocation_ID<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vLocation +' Location Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END


				IF(@_vBusiness_Area IS NULL OR LEN(LTRIM(RTRIM(@_vBusiness_Area)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Business Area Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vBA_Id IS NULL OR @_vBA_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vBusiness_Area +' Business Area Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vDepartments IS NULL OR LEN(LTRIM(RTRIM(@_vDepartments)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Departments Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vDept_Id IS NULL OR @_vDept_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vDepartments + ' Departments Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProject_Main_Category IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Main_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Main Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProj_Main_Cat_Id IS NULL OR @_vProj_Main_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vProject_Main_Category + ' Project Main Category Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END


				IF(@_vProject_Category IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProj_Cat_Id IS NULL OR @_vProj_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vProject_Category + ' Project Category Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END



				IF(@_vFinancial_Impact_Area IS NULL OR LEN(LTRIM(RTRIM(@_vFinancial_Impact_Area)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Financial Impact Area Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vFin_Impact_Ar_Id IS NULL OR @_vFin_Impact_Ar_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vFinancial_Impact_Area + ' Financial Impact Area Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vCost_Category IS NULL OR LEN(LTRIM(RTRIM(@_vCost_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Cost Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vCost_Cat_Id IS NULL OR @_vCost_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vCost_Category + ' Cost Category Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END


				IF(@_vPrimary_Loss_Categories IS NULL OR LEN(LTRIM(RTRIM(@_vPrimary_Loss_Categories)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Primary Loss Categories Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vPrim_Loss_Cat_Id IS NULL OR @_vPrim_Loss_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vCost_Category + ' Primary Loss Categories Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vStatus IS NULL OR LEN(LTRIM(RTRIM(@_vStatus)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Status Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vStatus_Id IS NULL OR  @_vStatus_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vStatus +' Status Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


				IF(@_vProject_Lead IS NOT NULL AND LEN(LTRIM(RTRIM(@_vProject_Lead)))>0)
				BEGIN
					SELECT TOP 1 @_vProject_Lead = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vProject_Lead, CHAR(10),'|'))))) TAB 


					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vProject_Lead

					IF(@_vProject_Member_Id IS NULL)
					BEGIN
						SELECT TOP 1 @_vProject_Lead = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vProject_Lead, CHAR(13),'|'))))) TAB 


					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vProject_Lead
					END

				END


				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: Project Lead Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vProject_Lead +' Project Lead Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vFinancial_Rep =NULL

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				IF(@_vFinancial_Rep IS NOT NULL AND LEN(LTRIM(RTRIM(@_vFinancial_Rep)))>0)
				BEGIN

						SELECT TOP 1 @_vFinancial_Rep = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vFinancial_Rep, CHAR(10),'|'))))) TAB 

					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vFinancial_Rep

					IF(@_vProject_Member_Id IS NULL)
					BEGIN
						SELECT TOP 1 @_vFinancial_Rep = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(13),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vFinancial_Rep, CHAR(10),'|'))))) TAB 

					END
				END

				IF(@_vFinancial_Rep IS NULL OR LEN(LTRIM(RTRIM(@_vFinancial_Rep)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: Financial Rep Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vFinancial_Rep +' Financial_Rep Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vSponsor=NULL

				SELECT @_vSponsor=LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
				IF(@_vSponsor IS NOT NULL AND LEN(LTRIM(RTRIM(@_vSponsor)))>0)
				BEGIN
					SELECT TOP 1 @_vSponsor = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vSponsor, CHAR(10),'|'))))) TAB 
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vSponsor

					IF(@_vProject_Member_Id IS NULL)
					BEGIN
					SELECT TOP 1 @_vSponsor = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vSponsor, CHAR(13),'|'))))) TAB 
					END
				END

				IF(@_vSponsor IS NULL OR LEN(LTRIM(RTRIM(@_vSponsor)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: Sponsor Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vSponsor +' Sponsor Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				INSERT INTO @_vPiller_Name_Table(Piller_Name)
				SELECT Value FROM dbo.Fn_SplitDelimetedData(CHAR(10), @_vPlant_Optimization_pillar) WHERE LEN(LTRIM(RTRIM(Value)))>0

	
				SET @_vPiller_Name=(SELECT ','+TGGD.Piller_Name FROM @_vPiller_Name_Table TGGD WHERE NOT EXISTS( SELECT 1 FROM GPM_Plant_Opt_Piller GGWM 
													WHERE GGWM.Piller_Name=TGGD.Piller_Name) FOR XML PATH(''))

				SET @_vPiller_Name=SUBSTRING(@_vPiller_Name,2, LEN(@_vPiller_Name))

				IF(LEN(@_vPiller_Name)>0)
					BEGIN
						SELECT @_vError_Desc += '|NMA : '+ @_vPiller_Name +' Plant Optimization pillar Not Found In Master Data'
					END
				
				IF EXISTS(
					SELECT COUNT(*) FROM Temp_Dmaic_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
					SELECT @_vError_Desc += '| Duplicate Gate Found'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_Dmaic_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_dMAIC_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='FI' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END


				END


			



				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_Dmaic_Error
								(
								Name,
								Sequence_number,
								Error_Desc
								) 
								Values
								(
								@_vName,
								@_vSequence_number,
								@_vError_Desc
								)


				END
				ELSE
				BEGIN
				INSERT INTO GPM_WT_DMAIC
					(
						DMAIC_Number,
						DMAIC_Name,
						Plan_Start_Date,
						Project_Defination,
						Project_Measure,
						Project_Analysis,
						Project_Improvement,
						Project_Control,
						Project_Metric_Cp ,
						Region_Code,
						Country_Code,
						Location_Id,
						BA_Id,
						Dept_Id,
						FN_BPO_Id,
						Product_Cat_Id,
						Proj_Main_Cat_Id,
						Proj_Cat_Id,
						Is_CapEx ,
						CapEx_Id,
						Fin_Impact_Ar_Id,
						Cost_Cat_Id ,
						Prim_Loss_Cat_Id,
						Ref_Idea_Id,
						Created_By,
						Created_Date,
						Last_Modified_By,
						Last_Modified_Date,
						Is_Best_Proj_Nom,
						Is_Deleted_Ind,
						Parent_DMAIC_Id
					)
					VALUES
					(
						@_vSequence_number,
						@_vName,
						@_vSystem_start_date,
						@_vDefine,
						@_vMeasure,
						@_vAnalyze,
						@_vImprove,
						@_vControl,
						@_vPrimary_Metric_and_Current_Performance,

						@_vRegion_Code, 
						@_vCountry_Code,
						@_vLocation_ID,
						@_vBA_Id,
						@_vDept_ID,
						@_vFN_BPO_ID,
						@_vProduct_Cat_Id,
						@_vProj_Main_Cat_Id,
						@_vProj_Cat_Id,
						
						(CASE WHEN @_vCapEx ='Yes' Then 'Y' 
							WHEN @_vCapEx ='No' Then 'N' 
							ELSE NULL END),

						@_vCapEx_ID,
						@_vFin_Impact_Ar_Id,
						@_vCost_Cat_Id,
						@_vPrim_Loss_Cat_Id,
						NULL,
						@_vCreated_By,
						@_vSystem_start_date,
						@_vCreated_By,
						@_vSystem_start_date,
						NULL,
						'N',
						NULL
					)
					
					SELECT @_vDMAIC_Id=NULL
					SELECT @_vDMAIC_Id=@@IDENTITY

					INSERT INTO GPM_WT_DMAIC_MS_Attrib(
													DMAIC_Id,
													DMAIC_Number,
													Piller_Id,
													Created_Date,
													Created_By,
													Last_Modified_Date,
													Last_Modified_By
													)
									SELECT
											@_vDMAIC_Id,
											RTRIM(LTRIM(@_vSequence_number)),
											GPOP.Piller_Id,
											@_vSystem_start_date,
											@_vCreated_By,
											@_vSystem_start_date,
											@_vCreated_By
									 FROM   @_vPiller_Name_Table TAB INNER JOIN GPM_Plant_Opt_Piller GPOP On RTRIM(LTRIM(Tab.Piller_Name))=GPOP.Piller_Name
					
					INSERT INTO GPM_WT_Project
					(
						WT_Code,
						WT_ID,
						WT_Project_Number,
						System_StartDate,
						System_EndDate,
						Status_Id,
						Created_By,
						Created_Date,
						Last_Modified_By,
						Last_Modified_Date
					)
					VALUES
					(
						'FI',
						@_vDMAIC_Id,
						@_vSequence_number,
						@_vSystem_start_date,
						@_vSystem_end_date,
						@_vStatus_Id,
						@_vCreated_By,
						Getdate(),
						@_vCreated_By,
						Getdate()
					)

					SELECT @_vWT_Project_Id=@@IDENTITY

					DELETE FROM @_vTabGate

					SELECT @_vActive_Gate=NULL

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_Dmaic_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL
								

					INSERT INTO GPM_WT_Project_Gate
					(
						WT_Project_Id,
						Gate_Id,
						Status_Id,
						Gate_Order_Id,
						Is_Currently_Active,
						Start_Date,
						End_Date,
						Created_By,
						Created_Date,
						Last_Modified_By,
						Last_Modified_Date
					)
					OUTPUT INSERTED.WT_Project_Id, INSERTED.Gate_Id, INSERTED.Gate_Order_Id INTO @_vTabGate(WT_Project_Id,Gate_Id, Gate_Order_Id)
					SELECT @_vWT_Project_Id, 
							GGWM.Gate_Id, 
							(SELECT  Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = CASE WHEN RTRIM(LTRIM(TDGA.Status))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(TDGA.Status)) END), 
							GGWM.Gate_Default_Order, 
							
							(CASE WHEN @_vActive_Gate=GG.Alt_Gate_Desc THEN 'Y' ELSE 'N' END),

							TDGA.System_start_date,
							TDGA.System_end_date,
							@_vCreated_By,
							Getdate(),
							@_vCreated_By,
							Getdate()
					FROM Temp_Dmaic_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='FI' AND Deliverable_Name IS NULL

					
					/*
					SELECT @_vWT_Project_Id, 
							GGWM.Gate_Id, 
							TDGA.Status,
							(SELECT  Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = RTRIM(LTRIM(TDGA.Status))), 
							GGWM.Gate_Default_Order, 
							
							(CASE WHEN @_vActive_Gate=GG.Alt_Gate_Desc THEN 'Y' ELSE 'N' END),

							TDGA.System_start_date,
							TDGA.System_end_date,
							@_vCreated_By,
							Getdate(),
							@_vCreated_By,
							Getdate()
					FROM Temp_Dmaic_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='FI' AND Deliverable_Name IS NULL
					*/

					
					IF((SELECT COUNT(*) FROM @_vTabGate)>0)
					BEGIN
				
							SELECT @_vMaxTabOrder=MAX(Gate_Order_Id), @_vTabCnt=MIN(Gate_Order_Id) FROM  @_vTabGate
							
							WHILE @_vTabCnt<(@_vMaxTabOrder+1)
							BEGIN

									SELECT @_vGate_Id=Gate_Id FROM @_vTabGate WHERE Gate_Order_Id=@_vTabCnt


					
												INSERT INTO GPM_WT_Project_Deliverable 
															(	
																WT_Project_Id, 
																Gate_Id, 
																Deliverable_Id,
																Status_Id,
																Perc_Complete,
																Start_Date, 
																End_Date,
																Is_Deliverable_Req,
																Is_Document_Req,	
																Created_By,
																Created_Date,
																Last_Modified_By,
																Last_Modified_Date
															)
													SELECT 
															@_vWT_Project_Id,
															@_vGate_Id,
															GGD.Deliverable_Id,
															(SELECT Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status=
															LTRIM(RTRIM(CASE WHEN TDGD.Status='Canceled' Then 'Not Started' 
																			 WHEN TDGD.Status='Proposed' Then 'Not Started' 
																			 Else TDGD.Status END))),
															NULL,
															TDGD.System_start_date,
															TDGD.System_end_date,
															'Y',
															'N',
															@_vCreated_By,
															TDGD.System_start_date,
															@_vCreated_By,
															TDGD.System_end_date
															FROM Temp_Dmaic_Gate_Deliverable TDGD INNER JOIN GPM_Gate_Deliverable GGD 
															On 
															LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable' Order by GGD.Deliverable_Default_Order


					

													INSERT INTO GPM_WT_Project_Team_Deliverable
															(
																WT_Project_ID,
																WT_Role_ID,
																Gate_Id,
																Deliverable_Id,
																GD_User_Id,
																Is_Deleted_Ind
															)
													SELECT 
														@_vWT_Project_Id,
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'FI' AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT TOP 1 GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIm(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM	Temp_Dmaic_Gate_Deliverable TDGD INNER JOIN GPM_Gate_Deliverable GGD 
															On LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable' 
															AND EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIm(RTRIM(TDGD.Project_Lead)))
															Order by GGD.Deliverable_Default_Order
	
													


											SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
										END
								END /*End Gate Loop*/


								/* Add Project Member*/

								SELECT @_vProject_Member_Id = NULL

							PRINT @_vSequence_number

							DELETE FROM @_vProjectMember_Table
								
								--INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									--SELECT 'Project Lead',LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead',@_vProject_Lead

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'MBB/FI-Expert',LTRIM(RTRIM(TDR.MBB_FI_Expert)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Process Owners',LTRIM(RTRIM(TDR.Process_Owner)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
									/*
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Sponsor',LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
									
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
									*/

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Sponsor',@_vSponsor
									
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',@_vFinancial_Rep

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_Dmaic_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
									) TAB 

									/*
							IF(@_vSequence_number='FI-01080')
								SELECT * FROM @_vProjectMember_Table
								*/

								IF((SELECT COUNT(*) FROM @_vProjectMember_Table)>0)
								BEGIN

									SELECT @_vMaxTabOrder=MAX(Row_Id), @_vTabCnt=MIN(Row_Id) FROM  @_vProjectMember_Table
							
									WHILE @_vTabCnt<(@_vMaxTabOrder+1)
									BEGIN

										SELECT @_vProject_Member_Id = NULL
										SELECT 
											@_vWT_Role_Name = WT_Role_Name,
											@_vProject_Member_Name = Project_Member_Name
										FROM @_vProjectMember_Table WHERE Row_Id=@_vTabCnt

									
										IF(LEN(@_vProject_Member_Name)>0)
										BEGIN

											SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vProject_Member_Name

											IF(@_vProject_Member_Id IS NOT NULL AND LEN(@_vProject_Member_Id)>0)
												BEGIN
													INSERT INTO GPM_WT_Project_Team
													(
													 WT_Project_ID,
													 WT_Role_ID,
													 GD_User_Id,
													 Is_Deleted_Ind,
													 Created_By,
													 Created_Date,
													 Last_Modified_By,
													 Last_Modified_Date
													)
													Values
													(
													@_vWT_Project_Id,
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='FI' AND WT_Role_Name=@_vWT_Role_Name),
													@_vProject_Member_Id,
													'N',
													@_vCreated_By,
													@_vSystem_start_date,
													@_vCreated_By,
													@_vSystem_end_date
													)
												END 
											ELSE
												BEGIN

											INSERT INTO Temp_Dmaic_MissingRoleMember_Error
												(
													Name,
													PowerSteering_ID,
													Sequence_number,
													WT_Role_Name,
													Error_Desc
												)
											VALUES
												(
													@_vName,
													@_vPowerSteering_ID,
													@_vSequence_number,
													@_vWT_Role_Name,
													@_vProject_Member_Name + ' missing in user table GPM_User'
												)


												END
										END

									
									SELECT @_vTabCnt=MIN(Row_Id) FROM @_vProjectMember_Table WHERE Row_Id>@_vTabCnt
								END
							END

/*
						INSERT INTO GPM_WT_Project_TDC_Saving
							(
								WT_Project_ID,
								Attrib_Id,
								YearMonth,
								Year,
								Month,
								Attrib_Value,
								Is_Lock,
								Created_By,
								Created_Date,
								Last_Modified_By,
								Last_Modified_Date
							)


						SELECT 
						@_vWT_Project_Id,
						GMTS.Attrib_Id,

						/*
						'20'+SUBSTRING(TDC.YearMonth,1,2) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,4,3)='January' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='February' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='March' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='April' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='June' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='July' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='August' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='September' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='October' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='November' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='December' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,1,2),
						--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
						SUBSTRING(TDC.YearMonth,4,3),
						
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
									REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')*-1
								ELSE
									REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')
								END
						END,
						*/
						'20'+SUBSTRING(TDC.YearMonth,LEN(TDC.YearMonth)-1,LEN(TDC.YearMonth)) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='January' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='February' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='March' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='April' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='June' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='July' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='August' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='September' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='October' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='November' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='December' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,LEN(TDC.YearMonth)-1,LEN(TDC.YearMonth)),
						SUBSTRING(TDC.YearMonth,1,3),
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
									REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'-$','-'),',',''),' ','')
								ELSE
									REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',',''),' ','')
								END
						END,
						1,
						@_vCreated_By,
						@_vSystem_start_date,
						@_vCreated_By,
						@_vSystem_end_date
					FROM Temp_Dmaic_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
					WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
					AND TDC.TDC_Type='Act+Fcst'
					ORDER BY 3,2


				INSERT INTO GPM_WT_Project_TDC_Saving_Baseline
							(
								WT_Project_ID,
								Attrib_Id,
								YearMonth,
								Year,
								Month,
								Attrib_Value,
								Is_Lock,
								Created_By,
								Created_Date,
								Last_Modified_By,
								Last_Modified_Date
							)


						SELECT 
						@_vWT_Project_Id,
						GMTS.Attrib_Id,

						/*
						'20'+SUBSTRING(TDC.YearMonth,1,2) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,4,3)='January' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='February' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='March' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='April' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='June' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='July' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='August' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='September' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='October' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='November' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='December' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,1,2),
						--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
						SUBSTRING(TDC.YearMonth,4,3),
						
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
									REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')*-1
								ELSE
									REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')
								END
						END,
						*/
						'20'+SUBSTRING(TDC.YearMonth,LEN(TDC.YearMonth)-1,LEN(TDC.YearMonth)) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='January' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='February' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='March' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='April' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='June' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='July' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='August' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='September' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='October' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='November' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,0,CHARINDEX('-',TDC.YearMonth))='December' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,LEN(TDC.YearMonth)-1,LEN(TDC.YearMonth)),
						SUBSTRING(TDC.YearMonth,1,3),
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
									REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'-$','-'),',',''),' ','')
								ELSE
									REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',',''),' ','')
								END
						END,
						1,
						@_vCreated_By,
						@_vSystem_start_date,
						@_vCreated_By,
						@_vSystem_end_date
					FROM Temp_Dmaic_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
					WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
					AND TDC.TDC_Type='Baseline' ORDER BY 3,2

					*/
				END /* Valid */

				FETCH NEXT FROM DMAIC_Cursor INTO 
				@_vName,
				@_vPowerSteering_ID,
				@_vSequence_number,
				@_vProject_Lead,
				@_vSystem_start_date,
				@_vActive_phase,
				@_vSystem_end_date,
				@_vStatus,
				@_vWork_Template,
				@_vWork_type,
				@_vComments,
				@_vConsequential_Metric,
				@_vExpected_Benefits,
				@_vExpected_Total_Savings_in_$,
				@_vExpected_Total_Savings_in_$_raw,
				@_vGoal_Statement,
				@_vPrimary_Metric_and_Current_Performance,
				@_vProblem_Statement,
				@_vProject_Scope_and_Scale,
				@_vSecondary_Metric,
				@_vBaseline,
				@_vLoss_Opportunity,
				@_vLoss_Opportunity_raw,
				@_vMeasures_of_Success,
				@_vTarget,
				@_vAnalyze,
				@_vCapEx,
				@_vCapEx_ID,
				@_vControl,
				@_vDefine,
				@_vImprove,
				@_vMeasure

			END
 
	 CLOSE DMAIC_Cursor;
	 DEALLOCATE DMAIC_Cursor;
	 IF CURSOR_STATUS('global','DMAIC_Cursor')>=-1
	 BEGIN
       DEALLOCATE DMAIC_Cursor
	 END



 END




