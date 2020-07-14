--USE [PMT_Migration]
--GO
--/****** Object:  StoredProcedure [dbo].[Temp_PSIMP_DATA_LOAD]    Script Date: 4/3/2019 7:00:35 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER PROCEDURE [dbo].[Temp_PSIMP_DATA_LOAD]
--AS
--Below variable for PSIMP Coustom Field


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
DECLARE @_vProject_Summary varchar(2000)
-- new add val.. for PSIMP
DECLARE @_vAnnual_Spend varchar(2000)
DECLARE @_vAnnual_Spend_raw varchar(2000)
DECLARE @_vCA_Local_Currency varchar(2000)
DECLARE @_vCA_Local_Currency_raw varchar(2000)
DECLARE @_vCapEx varchar(2000)
DECLARE @_vCurrent_PO varchar(2000)
DECLARE @_vEBIT_Local_Currency varchar(2000)
DECLARE @_vEBIT_Local_Currency_raw varchar(2000)
DECLARE @_vGL_Account varchar(2000)
DECLARE @_vGSGPC varchar(2000)
DECLARE @_vIn_AOP varchar(2000)
DECLARE @_vLCC_Sourcing varchar(2000)
DECLARE @_vNet_Savings_Local_Currency varchar(2000)
DECLARE @_vNet_Savings_Local_Currency_raw varchar(2000)
DECLARE @_vPrebate_Rebate varchar(2000)
DECLARE @_vPrior_PO varchar(2000)
DECLARE @_vProbability_Adjustment varchar(2000)
DECLARE @_vProbability_Adjustment_raw varchar(2000)
DECLARE @_vTotal_Opportunity varchar(2000)
DECLARE @_vTotal_Opportunity_raw varchar(2000)
DECLARE @_vVendor_Name varchar(2000)
DECLARE @_vWorking_Capital_Impact_Date varchar(2000)
DECLARE @_vWorking_Capital_Impact_Date_raw varchar(2000)
DECLARE @_vYearly_Volume varchar(2000)
DECLARE @_vYearly_Volume_raw varchar(2000)
DECLARE @_vEstimated_Baseline_Savings_$ varchar(2000)
DECLARE @_vEstimated_Baseline_Savings_$_raw varchar(2000)
DECLARE @_vEstimated_Timeline varchar(2000)
DECLARE @_vFull_Potential_Savings_$ varchar(2000)
DECLARE @_vFull_Potential_Savings_$_raw varchar(2000)
DECLARE @_vProbability_of_Achieving_Savings varchar(2000)
DECLARE @_vProbability_of_Achieving_Savings_raw varchar(2000)
DECLARE @_vProject_Description nvarchar(MAX)
DECLARE @_vProject_Rejected_On_Hold varchar(2000)
 --
DECLARE @_vPSIMP_Id INT 
DECLARE @_vWT_Project_Id INT

--Below variable for role&tags without repetition value.(TAGS)

DECLARE @_vTeam_Member VARCHAR(2000)
DECLARE @_vMBB_FI_Expert VARCHAR(2000)
DECLARE @_vBlack_Belt VARCHAR(2000)
DECLARE @_vProcess_Owner VARCHAR(2000)
DECLARE @_vSponsor VARCHAR(2000)
DECLARE @_vFinancial_Rep VARCHAR(2000)

-- Add 6 new TAGS for PSIMP role&tags without repetition value

DECLARE @_vRegional_Category_Manager VARCHAR(2000)
DECLARE @_vPlant_Purchasing_Manager VARCHAR(2000)
DECLARE @_vAssociate_Editors VARCHAR(2000)
DECLARE @_vProject_Manager VARCHAR(2000)
DECLARE @_vManager VARCHAR(2000)
DECLARE @_vStakeholder VARCHAR(2000)

--DECLARE @_vBest_Project_Nomination VARCHAR(2000)

DECLARE @_vBusiness_Area VARCHAR(2000)
DECLARE @_vCost_Category VARCHAR(2000)
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
DECLARE @_vProject_Tracking_Indicator VARCHAR(2000)

-- Add 15 new TAGS for PSIMP role&tags without repetition value.(TAGS),,

DECLARE @_vOld_Payment_Terms VARCHAR(2000)
DECLARE @_vNew_Payment_Terms VARCHAR(2000)
DECLARE @_vBest_Project_Award VARCHAR(2000)
--DECLARE @_vProject_Tracking_Indicator VARCHAR(2000)--
DECLARE @_vRate_or_Non_Rate VARCHAR(2000)
DECLARE @_vRegional_or_Plant_Project VARCHAR(2000)
DECLARE @_vRegional_Tracking_Category VARCHAR(2000)
DECLARE @_vStakeholder_Rep VARCHAR(2000)
DECLARE @_vTW_Loss_Categories VARCHAR(2000)
DECLARE @_vWorking_Capital_Type VARCHAR(2000)
DECLARE @_vGPH_Category VARCHAR(2000)
DECLARE @_vGPH_Sub_Category VARCHAR(2000)
DECLARE @_vProject_Status  VARCHAR(2000)
DECLARE @_vProject_Type VARCHAR(2000)
DECLARE @_vSpend_Type VARCHAR(2000)


DECLARE @_vGlobal_PSIMP_Type VARCHAR(2000)
DECLARE @_vPSIMP_Initiative VARCHAR(2000)

--Add Primari key for PSIMP.. 
DECLARE @_vBA_Id INT
DECLARE @_vCost_Cat_Id INT
DECLARE @_vCountry_Code VARCHAR(3)
DECLARE @_vDept_ID INT
DECLARE @_vFN_BPO_ID INT
DECLARE @_vFin_Impact_Ar_Id INT
DECLARE @_vLocation_ID INT
--DECLARE @_vBP_Score_Type_Code VARCHAR(20) not in PSIMP
DECLARE @_vPiller_Id INT
DECLARE @_vPrim_Loss_Cat_Id INT
DECLARE @_vProduct_Cat_Id INT
--projectlocation?
DECLARE @_vProj_Cat_Id INT
DECLARE @_vProject_Codification_Id INT
DECLARE @_vProj_Main_Cat_Id INT
DECLARE @_vRegion_Code VARCHAR(5)
DECLARE @_vSub_Cost_Cat_Id INT

--Not find Primari key for below..
--Old_Payment_Terms
--New_Payment_Terms
--Best_Project_Award
--Project_Tracking_Indicator
DECLARE @_vRate_Type_Id INT
--Regional_or_Plant_Project?
DECLARE @_vRegTrack_Cat_Id INT
DECLARE @_vTW_Loss_Cat_Id INT
DECLARE @_vGPH_Cat_Id INT
DECLARE @_vGPH_Sub_Cat_Id INT
DECLARE @_vProj_Status_Id INT
DECLARE @_vProj_Type_Id INT
DECLARE @_vSpend_Type_Id INT


DECLARE @_vGlobal_PSIMP_Type_Id INT
DECLARE @_vPSIMP_Initiative_Id INT

DECLARE @_vProject_Allocation_Id INT
DECLARE @_vPlant_Trial_Id INT
DECLARE @_vAccount_Id INT
DECLARE @_vProject_Tracking_Indicator_Id INT

DECLARE @_vStatus_Id INT
DECLARE @_vStakeHolder_Id INT
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




TRUNCATE TABLE Temp_PSIMP_Error

TRUNCATE TABLE Temp_PSIMP_MissingRoleMember_Error

TRUNCATE TABLE Temp_PSIMP_Gate_Deliverable_Error

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving_Baseline

--TRUNCATE TABLE GPM_WT_Project_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Team

--TRUNCATE TABLE GPM_WT_Project_Team_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Gate

--DELETE FROM GPM_WT_Project

--DELETE FROM GPM_WT_Procurement_Simple

SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='PSIMP'  AND Is_Deleted_Ind='N'

 --Copy Past all Custom Field Variable and modify for Cursor

DECLARE PSIMP_Cursor CURSOR FOR
		SELECT
			Name,	
			PowerSteering_ID,	
			Sequence_number,
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
			Project_Summary,
			Annual_Spend,
			Annual_Spend_raw,
			CA_Local_Currency,
			CA_Local_Currency_raw,
			CapEx,
			Current_PO,
			EBIT_Local_Currency,
			EBIT_Local_Currency_raw,
			GL_Account,
			GSGPC,
			In_AOP,
			LCC_Sourcing,
			Net_Savings_Local_Currency,
			Net_Savings_Local_Currency_raw,
			Prebate_Rebate,
			Prior_PO,
			Probability_Adjustment,
			Probability_Adjustment_raw,
			Total_Opportunity,
			Total_Opportunity_raw,
			Vendor_Name,
			Working_Capital_Impact_Date,
			Working_Capital_Impact_Date_raw,
			Yearly_Volume,
			Yearly_Volume_raw,
			Estimated_Baseline_Savings_$,
			Estimated_Baseline_Savings_$_raw,
			Estimated_Timeline,
			Full_Potential_Savings_$,
			Full_Potential_Savings_$_raw,
			Probability_of_Achieving_Savings,
			Probability_of_Achieving_Savings_raw,
			Project_Description,
			Project_Rejected_On_Hold
			
	FROM
		Temp_PSIMP_Custom_Fields 
		--WHERE Sequence_number IN('PSIMP-39741','PSIMP-38941')

	OPEN PSIMP_Cursor
	FETCH NEXT FROM PSIMP_Cursor INTO 
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
			@_vProject_Summary,
			@_vAnnual_Spend,
			@_vAnnual_Spend_raw,
			@_vCA_Local_Currency,
			@_vCA_Local_Currency_raw,
			@_vCapEx,
			@_vCurrent_PO,
			@_vEBIT_Local_Currency,
			@_vEBIT_Local_Currency_raw,
			@_vGL_Account,
			@_vGSGPC,
			@_vIn_AOP,
			@_vLCC_Sourcing,
			@_vNet_Savings_Local_Currency,
			@_vNet_Savings_Local_Currency_raw,
			@_vPrebate_Rebate,
			@_vPrior_PO,
			@_vProbability_Adjustment,
			@_vProbability_Adjustment_raw,
			@_vTotal_Opportunity,
			@_vTotal_Opportunity_raw,
			@_vVendor_Name,
			@_vWorking_Capital_Impact_Date,
			@_vWorking_Capital_Impact_Date_raw,
			@_vYearly_Volume,
			@_vYearly_Volume_raw,
			@_vEstimated_Baseline_Savings_$,
			@_vEstimated_Baseline_Savings_$_raw,
			@_vEstimated_Timeline,
			@_vFull_Potential_Savings_$,
			@_vFull_Potential_Savings_$_raw,
			@_vProbability_of_Achieving_Savings,
			@_vProbability_of_Achieving_Savings_raw,
			@_vProject_Description,
			@_vProject_Rejected_On_Hold
			


-- Chanhe with NULL  all Tags..

		WHILE @@FETCH_STATUS = 0
       
			BEGIN

				SELECT 
				@_vValidData = 'TRUE',
				@_vBusiness_Area = NULL,
				@_vCost_Category = NULL,
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

				--Add Primari key for PSIMP.. 
				 @_vBA_Id = NULL,
				 @_vCost_Cat_Id = NULL,
				 @_vCountry_Code = NULL,
				 @_vDept_ID = NULL,
				 @_vFN_BPO_ID = NULL,
				 @_vFin_Impact_Ar_Id = NULL,
				 @_vLocation_ID = NULL,
				--DECLARE @_vBP_Score_Type_Code VARCHAR(20) not in PSIMP
				 @_vPiller_Id = NULL,
				 @_vPrim_Loss_Cat_Id = NULL,
				 @_vProduct_Cat_Id = NULL,
				--projectlocation?
				 @_vProj_Cat_Id = NULL,
				 @_vProject_Codification_Id = NULL,
				 @_vProj_Main_Cat_Id = NULL,
				 @_vRegion_Code = NULL,
				 @_vSub_Cost_Cat_Id = NULL,
				 @_vRate_Type_Id = NULL,
				--Regional_or_Plant_Project?
				 @_vRegTrack_Cat_Id = NULL,
				 @_vTW_Loss_Cat_Id = NULL,
				 @_vGPH_Cat_Id = NULL,
				 @_vGPH_Sub_Cat_Id = NULL,
				 @_vProj_Status_Id = NULL,
				 @_vProj_Type_Id = NULL,
				 @_vSpend_Type_Id = NULL

				 	
			SELECT 
				@_vBusiness_Area = Business_Area,
				@_vCost_Category = Cost_Category,
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
				@_vSub_Cost_Categories = Sub_Cost_Categories,
				@_vProject_Tracking_Indicator = Project_Tracking_Indicator,
				@_vTW_Loss_Categories = [T&W_Loss_Categories],
				@_vRegional_Tracking_Category= Regional_Tracking_Category,
				@_vGPH_Category= GPH_Category,
				@_vGPH_Sub_Category = GPH_Sub_Category,
				@_vProject_Status = [Project_Status ],

				@_vTeam_Member = Team_Member,
				@_vMBB_FI_Expert = MBB_FI_Expert,
				@_vBlack_Belt = Black_Belt,
				@_vProcess_Owner = Process_Owner,
				@_vSponsor = Sponsor,
				@_vFinancial_Rep = Financial_Rep,
				
				@_vRegional_Category_Manager = Regional_Category_Manager,
				@_vPlant_Purchasing_Manager = Plant_Purchasing_Manager,
				@_vAssociate_Editors = Associate_Editors,
				@_vProject_Manager = Project_Manager,
				@_vManager = Manager,
				@_vStakeholder = Stakeholder,
				@_vOld_Payment_Terms = Old_Payment_Terms,
				@_vNew_Payment_Terms = New_Payment_Terms,
				@_vBest_Project_Award = Best_Project_Award,
				@_vWorking_Capital_Type = Working_Capital_Type,
				@_vActive_phase = Active_phase,
				@_vProject_Type = Project_Type,
				@_vSpend_Type = Spend_Type,
				@_vRate_or_Non_Rate=Rate_or_Non_Rate

				--@_vProposed_Plant_Trial = Proposed_Plant_Trial,
				--@_vAccounting_Code = Accounting_Code,

				--@_vGlobal_PSIMP_Type = Global_PSIMP_Type,
				--@_vPSIMP_Initiative = PSIMP_Initiative,
				
				
				FROM Temp_PSIMP_RoleAndTags
				WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))

				IF(RTRIM(LTRIM(@_vGPH_Category))='Marketing & Com' OR RTRIM(LTRIM(@_vGPH_Category))='Marketing & Comm')
					SET @_vGPH_Category = 'Marketing & Communications' 
				
				SELECT @_vBA_Id=BA_Id FROM GPM_Business_Area WHERE RTRIM(LTRIM(BA_Name))=RTRIM(LTRIM(@_vBusiness_Area))
				SELECT @_vCost_Cat_Id=Cost_Cat_Id FROM GPM_Cost_Category WHERE RTRIM(LTRIM(Cost_Cat_Desc))=RTRIM(LTRIM(@_vCost_Category)) 
				SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry))
				SELECT @_vDept_ID = Dept_ID FROM GPM_Department WHERE RTRIM(LTRIM(Dept_Name))=RTRIM(LTRIM(@_vDepartments)) AND BA_Id=@_vBA_Id
				SELECT @_vFN_BPO_ID=FN_BPO_ID FROM GPM_Finance_BPO WHERE RTRIM(LTRIM(FN_BPO_Name))=RTRIM(LTRIM(@_vFinance_BPO)) AND BA_Id=@_vBA_Id AND Dept_ID=@_vDept_ID
				SELECT @_vFin_Impact_Ar_Id=Fin_Impact_Ar_Id FROM GPM_Finance_Impact_Area WHERE RTRIM(LTRIM(Fin_Impact_Ar_Desc))=RTRIM(LTRIM(@_vFinancial_Impact_Area)) 
				SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN  RTRIM(LTRIM(@_vLocation)) ='NA Regional MFG' THEN 'NA HQ' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
				SELECT @_VPiller_Id=Piller_Id FROM GPM_Plant_Opt_Piller WHERE RTRIM(LTRIM(Piller_Name))= RTRIM(LTRIM(@_vPlant_Optimization_pillar))
				SELECT @_vPrim_Loss_Cat_Id=Prim_Loss_Cat_Id FROM GPM_Primary_Loss_Category WHERE RTRIM(LTRIM(Prim_Loss_Cat_Desc))=RTRIM(LTRIM(@_vPrimary_Loss_Categories)) 
				SELECT @_vProduct_Cat_Id=Product_Cat_Id FROM GPM_Product_Category WHERE RTRIM(LTRIM(Product_Cat_Desc))=RTRIM(LTRIM(@_vProduct_Category))

				SELECT @_vProject_Allocation_Id=NULL /*Master Table not found*/
				SELECT @_vProj_Main_Cat_Id=Proj_Main_Cat_Id FROM GPM_Proj_Main_Category WHERE RTRIM(LTRIM(Proj_Main_Cat_Desc))=RTRIM(LTRIM(@_vProject_Main_Category))
				SELECT @_vProj_Cat_Id=Proj_Cat_Id FROM GPM_Proj_Category WHERE RTRIM(LTRIM(Proj_Cat_Desc))=RTRIM(LTRIM(@_vProject_Category)) AND Proj_Main_Cat_Id=@_vProj_Main_Cat_Id
				SELECT @_vProject_Codification_Id=Project_Codification_Id FROM GPM_Project_Codification WHERE RTRIM(LTRIM(Project_Codification_Desc))=RTRIM(LTRIM(@_vProject_Codification))

				SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
				SELECT @_vSub_Cost_Cat_Id= Sub_Cost_Cat_Id FROM GPM_Sub_Cost_Category WHERE RTRIM(LTRIM(Sub_Cost_Cat_Desc))=RTRIM(LTRIM(@_vSub_Cost_Categories)) AND Fin_Impact_Ar_Id=@_vFin_Impact_Ar_Id AND Cost_Cat_Id=@_vCost_Cat_Id

				--SELECT @_vPlant_Trial_Id=Plant_Trial_Id FROM GPM_Plant_Trial WHERE RTRIM(LTRIM(Plant_Trial_Desc))=RTRIM(LTRIM(@_vProposed_Plant_Trial))
				-- New 8 are added for PSIMP

				SELECT @_vRate_Type_Id=Rate_Type_Id FROM GPM_Rate_Type WHERE RTRIM(LTRIM(Rate_Type_Desc))=RTRIM(LTRIM(@_vRate_or_Non_Rate))
				SELECT @_vRegTrack_Cat_Id=RegTrack_Cat_Id FROM GPM_Reg_Track_Category WHERE RTRIM(LTRIM(RegTrack_Cat_Desc))=RTRIM(LTRIM(@_vRegional_Tracking_Category))
				SELECT @_vGPH_Sub_Cat_Id=TW_Loss_Cat_Id FROM GPM_TW_Loss_Category WHERE RTRIM(LTRIM(TW_Loss_Cat_Desc))=RTRIM(LTRIM(@_vTW_Loss_Categories))
				
				
				SELECT @_vGPH_Cat_Id=GPH_Cat_Id FROM GPM_GPH_Category WHERE RTRIM(LTRIM(GPH_Cat_Desc))=RTRIM(LTRIM(@_vGPH_Category))
				SELECT @_vGPH_Sub_Cat_Id=GPH_Sub_Cat_Id FROM GPM_GPH_Sub_Category WHERE RTRIM(LTRIM(GPH_Sub_Cat_Desc))=RTRIM(LTRIM(@_vGPH_Sub_Category)) AND GPH_Cat_Id=@_vGPH_Cat_Id
				

				SELECT @_vProj_Status_Id=Proj_Status_Id FROM GPM_Project_Status WHERE RTRIM(LTRIM(Proj_Status_Desc))=RTRIM(LTRIM(@_vProject_Status))
				SELECT @_vProj_Type_Id=Proj_Type_Id FROM GPM_Project_Type WHERE RTRIM(LTRIM(Proj_Type_Desc))=RTRIM(LTRIM(@_vProject_Type))
				SELECT @_vSpend_Type_Id=Spend_Type_Id FROM GPM_Spend_Type WHERE RTRIM(LTRIM(Spend_Type_Desc))=RTRIM(LTRIM(@_vSpend_Type))
				SELECT @_vStatus_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
				SELECT @_vProject_Tracking_Indicator_Id=Proj_Track_Id FROM GPM_Project_Tracking WHERE RTRIM(LTRIM(Proj_Track_Status))=RTRIM(LTRIM(@_vProject_Tracking_Indicator))
				SELECT @_vCreated_By=GD_User_Id FROM GPM_USer WHERE User_First_Name +' '+User_Last_Name = RTRIM(LTRIM(@_vProject_Lead))

				
				SELECT @_vError_Desc=''

				IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : PSIMP Name Is Blank'
					SELECT @_vValidData='FALSE'
				END

				

				IF(@_vProject_Tracking_Indicator IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Tracking_Indicator)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Tracking Indicator Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProject_Tracking_Indicator_Id IS NULL OR  @_vProject_Tracking_Indicator_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vProject_Tracking_Indicator +' Project Tracking Indicator Not Found in DB Master Data'
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

				IF(@_vSpend_Type IS NULL OR LEN(LTRIM(RTRIM(@_vSpend_Type)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Spend Type Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vSpend_Type_Id IS NULL OR  @_vSpend_Type_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vSpend_Type +' Spend Type Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProject_Type IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Type)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Type Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProj_Type_Id IS NULL OR  @_vProj_Type_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vProject_Type +' Project Type Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END


				IF(@_vProject_Description IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Description)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Project Description Is Blank'
					SELECT @_vValidData='FALSE'
				END
				

				IF(@_vRate_or_Non_Rate IS NULL OR LEN(LTRIM(RTRIM(@_vRate_or_Non_Rate)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Rate or Non_Rate Type Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vRate_Type_Id IS NULL OR  @_vRate_Type_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vRate_or_Non_Rate +' Rate or Non_Rate Type Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END


				IF(@_vRegional_Tracking_Category IS NULL OR LEN(LTRIM(RTRIM(@_vRegional_Tracking_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Regional Tracking Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vRegTrack_Cat_Id IS NULL OR  @_vRegTrack_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vRegional_Tracking_Category +' Regional Tracking Category Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vFinancial_Impact_Area IS NULL OR LEN(LTRIM(RTRIM(@_vFinancial_Impact_Area)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Financial Impact Area Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vFin_Impact_Ar_Id IS NULL OR  @_vFin_Impact_Ar_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vFinancial_Impact_Area +' Financial Impact Area Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vGPH_Category IS NULL OR LEN(LTRIM(RTRIM(@_vGPH_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : GPH Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vGPH_Cat_Id IS NULL OR  @_vGPH_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vGPH_Category +' GPH Category Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vGPH_Sub_Category IS NULL OR LEN(LTRIM(RTRIM(@_vGPH_Sub_Category)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : GPH Sub Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vGPH_Sub_Cat_Id IS NULL OR  @_vGPH_Sub_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vGPH_Sub_Category +' GPH Sub Category Not Found in DB Master Data'
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
					SELECT @_vError_Desc += '| MA :'+ @_vRegions +' Region Not Found in DB Master Data'
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
					SELECT @_vError_Desc += '| MA :'+ @_vCountry +' Country Not Found in DB Master Data'
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


				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


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

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

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


				IF EXISTS(
					SELECT COUNT(*) FROM Temp_PSIMP_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
					SELECT @_vError_Desc += '| Duplicate Gate Found'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_PSIMP_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_PSIMP_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='PSIMP' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END


				END


				IF(LEN(LTRIM(RTRIM(@_vFinance_BPO)))>0)
				BEGIN
					IF(@_vFN_BPO_ID IS NULL OR  @_vFN_BPO_ID<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vFinance_BPO +' Finance BPO Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				
				
				/*
				IF(LEN(LTRIM(RTRIM(@_vPlant_Optimization_pillar)))>0)
				BEGIN
					IF(@_vPiller_Id IS NULL OR  @_vPiller_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vPlant_Optimization_pillar +' Plant Optimization pillar Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				ELSE
				*/
				
				IF(LEN(LTRIM(RTRIM(@_vPrimary_Loss_Categories)))>0)
				BEGIN
					IF(@_vPrim_Loss_Cat_Id IS NULL OR  @_vPrim_Loss_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vPrimary_Loss_Categories +' Primary Loss Categories Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				
				
				IF(LEN(LTRIM(RTRIM(@_vProduct_Category)))>0)
				BEGIN
					IF(@_vProduct_Cat_Id IS NULL OR  @_vProduct_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vProduct_Category +' Product Category Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				

				IF(LEN(LTRIM(RTRIM(@_vProject_Codification)))>0)
				BEGIN
					IF(@_vProject_Codification_Id IS NULL OR  @_vProject_Codification_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vProject_Codification +' Project Codification Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				/*
				IF EXISTS(
					SELECT *
					FROM Temp_PSIMP_Gate_Deliverable TPGD WHERE TPGD.Sequence_number=@_vSequence_number AND TPGD.Work_Type='Gate'
					AND (SELECT COUNT(*) FROM GPM_Gate_Deliverable GGD INNER JOIN GPM_Gate GG On GGD.Gate_Id=GG.Gate_Id INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id
					WHERE GGWM.WT_Code='PSIMP' AND GG.Alt_Gate_Desc=TPGD.Gate_Name) !=(SELECT COUNT(*)
					FROM Temp_PSIMP_Gate_Deliverable TPGD1 WHERE TPGD1.Sequence_number=@_vSequence_number AND TPGD1.Work_Type='Deliverable'
					AND TPGD1.Gate_Name=TPGD.Gate_Name) 
				)

				BEGIN
					SELECT @_vError_Desc += '| No Of Deliverable Not Matching in Gate ' +TPGD.Gate_Name
					FROM Temp_PSIMP_Gate_Deliverable TPGD WHERE TPGD.Sequence_number=@_vSequence_number AND TPGD.Work_Type='Gate'
					AND (SELECT COUNT(*) FROM GPM_Gate_Deliverable GGD INNER JOIN GPM_Gate GG On GGD.Gate_Id=GG.Gate_Id INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id
					WHERE GGWM.WT_Code='PSIMP' AND GG.Alt_Gate_Desc=TPGD.Gate_Name) !=(SELECT COUNT(*)
					FROM Temp_PSIMP_Gate_Deliverable TPGD1 WHERE TPGD1.Sequence_number=@_vSequence_number AND TPGD1.Work_Type='Deliverable'
					AND TPGD1.Gate_Name=TPGD.Gate_Name) 

					SELECT @_vValidData='FALSE'
				END
				*/

				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_PSIMP_Error
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
										-- Use Add_SP for insert value into GPM_WT_PSIMP or PSIMP...now PSIMP
												-- Error came here..after full running
				
				INSERT INTO GPM_WT_Procurement_Simple
					(
						PSIMP_Number,
						PSIMP_Name,
						Plan_Start_Date,
						Proj_Track_Id,
						Proj_Status_Id,
						Proj_Spend_Type_Id,
						Proj_Type_Id,
						Rate_Type_Id,
						Project_Description,
						RegTrack_Cat_Id,
						Fin_Impact_Ar_Id,
						GPH_Cat_Id,
						GPH_Sub_Cat_Id,
						Region_Code,
						Country_Code,
						Location_Id,
						Potential_Saving_USD,
						Saving_Probablity_Per,
						Est_Base_Saving_USD,
						Est_Timeline,
						Ref_Idea_Id,
						Is_Best_Proj_Nom,
						Is_Deleted_Ind,
						Created_Date,
						Created_By,
						Last_Modified_Date,
						Last_Modified_By
 
					)
					VALUES
					(
						RTRIM(LTRIM(@_vSequence_number)),
						RTRIM(LTRIM(@_vName)),
						@_vSystem_start_date,
						@_vProject_Tracking_Indicator_id,
						@_vProj_Status_Id,
						@_vSpend_Type_Id,
						@_vProj_Type_Id,
						@_vRate_Type_Id,
						@_vProject_Description,
						@_vRegTrack_Cat_Id,
						@_vFin_Impact_Ar_Id,
						@_vGPH_Cat_Id,
						@_vGPH_Sub_Cat_Id,
						@_vRegion_Code,
						@_vCountry_Code,
						@_vLocation_ID,
						CASE WHEN LEN(LTRIM(RTRIM(@_vFull_Potential_Savings_$)))>0 THEN
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vFull_Potential_Savings_$,'$',''),',','') ,')',''),'(','-'),' ','')
						ELSE NULL END,
						@_vProbability_of_Achieving_Savings,

						CASE WHEN LEN(LTRIM(RTRIM(@_vEstimated_Baseline_Savings_$)))>0 THEN
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vEstimated_Baseline_Savings_$,'$',''),',','') ,')',''),'(','-'),' ','')
						ELSE NULL END,
						
						@_vEstimated_Timeline,
						NULL,
						'N',
						'N',
						Getdate(),
						@_vCreated_By,
						Getdate(),
						@_vCreated_By
 
					)
			
		
					SELECT @_vPSIMP_Id=NULL
					SELECT @_vPSIMP_Id=@@IDENTITY

					
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
						'PSIMP',
						@_vPSIMP_Id,
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

				
			-- Start for Gate & Deliverable	

					DELETE FROM @_vTabGate

					SELECT @_vActive_Gate=NULL

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_PSIMP_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL
					--			

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
					FROM Temp_PSIMP_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='PSIMP' AND Deliverable_Name IS NULL

					-- Below For Test
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
					FROM Temp_PSIMP_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='PSIMP' AND Deliverable_Name IS NULL
					*/


					IF((SELECT COUNT(*) FROM @_vTabGate)>0)
					BEGIN
				
							SELECT @_vMaxTabOrder=MAX(Gate_Order_Id), @_vTabCnt=MIN(Gate_Order_Id) FROM  @_vTabGate
							
							WHILE @_vTabCnt<(@_vMaxTabOrder+1)
							BEGIN

									SELECT @_vGate_Id=Gate_Id FROM @_vTabGate WHERE Gate_Order_Id=@_vTabCnt


			--Start for Deliverable
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
															FROM Temp_PSIMP_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND
															(CASE WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 1 - Update Financial Metric' THEN 'Month 1 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 2 - Update Financial Metric' THEN 'Month 2 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 3 - Update Financial Metric' THEN 'Month 3 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 4 - Update Financial Metric' THEN 'Month 4 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 5 - Update Financial Metric' THEN 'Month 5 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 6 - Update Financial Metric' THEN 'Month 6 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 7 - Update Financial Metric' THEN 'Month 7 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 8 - Update Financial Metric' THEN 'Month 8 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 9 - Update Financial Metric' THEN 'Month 9 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 10 - Update Financial Metric' THEN 'Month 10 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 11 - Update Financial Metric' THEN 'Month 11 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 12 - Update Financial Metric' THEN 'Month 12 - Savings Input (Act+Fcst)'
																ELSE 
																	LTRIM(RTRIM(TDGD.Deliverable_Name))
															END)=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable'
															AND GGD.WT_Code='PSIMP'
															Order by GGD.Deliverable_Default_Order


													-- Insert start for Master table GPM_WT_Project_Team_Deliverable no changes only table name change

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
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'PSIMP' AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM	Temp_PSIMP_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND
															(CASE WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 1 - Update Financial Metric' THEN 'Month 1 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 2 - Update Financial Metric' THEN 'Month 2 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 3 - Update Financial Metric' THEN 'Month 3 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 4 - Update Financial Metric' THEN 'Month 4 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 5 - Update Financial Metric' THEN 'Month 5 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 6 - Update Financial Metric' THEN 'Month 6 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 7 - Update Financial Metric' THEN 'Month 7 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 8 - Update Financial Metric' THEN 'Month 8 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 9 - Update Financial Metric' THEN 'Month 9 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 10 - Update Financial Metric' THEN 'Month 10 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 11 - Update Financial Metric' THEN 'Month 11 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Month 12 - Update Financial Metric' THEN 'Month 12 - Savings Input (Act+Fcst)'
																ELSE 
																	LTRIM(RTRIM(TDGD.Deliverable_Name))
															END)=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable'
															AND GGD.WT_Code='PSIMP' 
															AND EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIm(RTRIM(TDGD.Project_Lead)))
															Order by GGD.Deliverable_Default_Order
	
													


											SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
										END
								END /*End Gate Loop*/

							
								/* Add Project Member*/

								SELECT @_vProject_Member_Id = NULL

							PRINT @_vSequence_number

							DELETE FROM @_vProjectMember_Table
								
	
	/*							INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead',LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
*/

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead', @_vProject_Lead

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Sponsor',LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

									/*
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
									*/

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',@_vFinancial_Rep

									
								
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
									) TAB 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Managers',LTRIM(RTRIM(TDR.Manager)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Stakeholders',LTRIM(RTRIM(TDR.Stakeholder)) FROM Temp_PSIMP_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

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
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='PSIMP' AND WT_Role_Name=@_vWT_Role_Name),
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

											INSERT INTO Temp_PSIMP_MissingRoleMember_Error
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

							-- starts TDS Saving
							
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

						--TDC.YearMonth,
						/*
						'20'+SUBSTRING(TDC.YearMonth,1,2) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,4,3)='Jan' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Feb' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Mar' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Apr' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Jun' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Jul' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Aug' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Sep' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Oct' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Nov' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Dec' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,1,2),
						--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
						SUBSTRING(TDC.YearMonth,4,3),
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('(', TDC.Attrib_Value,1)>0 THEN 
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
					FROM Temp_PSIMP_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
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

						--TDC.YearMonth,
						/*
						'20'+SUBSTRING(TDC.YearMonth,1,2) +''+ 
							   CASE WHEN SUBSTRING(TDC.YearMonth,4,3)='Jan' Then '01'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Feb' Then '02'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Mar' Then '03'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Apr' Then '04'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='May' Then '05'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Jun' Then '06'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Jul' Then '07'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Aug' Then '08'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Sep' Then '09'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Oct' Then '10'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Nov' Then '11'
									WHEN SUBSTRING(TDC.YearMonth,4,3)='Dec' Then '12'
								END,

						'20'+SUBSTRING(TDC.YearMonth,1,2),
						--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
						SUBSTRING(TDC.YearMonth,4,3),
						CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								CASE WHEN CHARINDEX('(', TDC.Attrib_Value,1)>0 THEN 
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
					FROM Temp_PSIMP_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
					WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
					AND TDC.TDC_Type='Baseline' ORDER BY 3,2
					*/
				END /* Valid */
			
			
-- Again use Curser..
		
	FETCH NEXT FROM PSIMP_Cursor INTO 
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
			@_vProject_Summary,
			@_vAnnual_Spend,
			@_vAnnual_Spend_raw,
			@_vCA_Local_Currency,
			@_vCA_Local_Currency_raw,
			@_vCapEx,
			@_vCurrent_PO,
			@_vEBIT_Local_Currency,
			@_vEBIT_Local_Currency_raw,
			@_vGL_Account,
			@_vGSGPC,
			@_vIn_AOP,
			@_vLCC_Sourcing,
			@_vNet_Savings_Local_Currency,
			@_vNet_Savings_Local_Currency_raw,
			@_vPrebate_Rebate,
			@_vPrior_PO,
			@_vProbability_Adjustment,
			@_vProbability_Adjustment_raw,
			@_vTotal_Opportunity,
			@_vTotal_Opportunity_raw,
			@_vVendor_Name,
			@_vWorking_Capital_Impact_Date,
			@_vWorking_Capital_Impact_Date_raw,
			@_vYearly_Volume,
			@_vYearly_Volume_raw,
			@_vEstimated_Baseline_Savings_$,
			@_vEstimated_Baseline_Savings_$_raw,
			@_vEstimated_Timeline,
			@_vFull_Potential_Savings_$,
			@_vFull_Potential_Savings_$_raw,
			@_vProbability_of_Achieving_Savings,
			@_vProbability_of_Achieving_Savings_raw,
			@_vProject_Description,
			@_vProject_Rejected_On_Hold
	
			END
 
	
	

	 CLOSE PSIMP_Cursor;
	 DEALLOCATE PSIMP_Cursor;
	 IF CURSOR_STATUS('global','PSIMP_Cursor')>=-1
	 BEGIN
       DEALLOCATE PSIMP_Cursor
	 END
 END




