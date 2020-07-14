BEGIN

--Custom Fields
DECLARE @_vName VARCHAR(4000)
DECLARE @_vPowerSteering_ID VARCHAR(4000)
DECLARE @_vSequence_number VARCHAR(4000)
DECLARE @_vProject_Lead VARCHAR(4000)
DECLARE @_vSystem_start_date VARCHAR(4000)
DECLARE @_vActive_phase VARCHAR(4000)
DECLARE @_vSystem_end_date VARCHAR(4000)
DECLARE @_vStatus VARCHAR(4000)
DECLARE @_vWork_Template VARCHAR(4000)
DECLARE @_vWork_type VARCHAR(4000)
DECLARE @_vComments VARCHAR(4000)
DECLARE @_vConsequential_Metric VARCHAR(4000)
DECLARE @_vExpected_Benefits VARCHAR(4000)
DECLARE @_vExpected_Total_Savings_in_$ VARCHAR(4000)
DECLARE @_vExpected_Total_Savings_in_$_raw VARCHAR(4000)
DECLARE @_vGoal_Statement VARCHAR(4000)
DECLARE @_vPrimary_Metric_and_Current_Performance VARCHAR(4000)
DECLARE @_vProblem_Statement VARCHAR(4000)
DECLARE @_vProject_Scope_and_Scale VARCHAR(4000)
DECLARE @_vSecondary_Metric VARCHAR(4000)
DECLARE @_vProject_Summary VARCHAR(4000)
DECLARE @_vAnnual_Spend VARCHAR(4000)
DECLARE @_vAnnual_Spend_raw VARCHAR(4000)
DECLARE @_vCA_Local_Currency VARCHAR(4000)
DECLARE @_vCA_Local_Currency_raw VARCHAR(4000)
DECLARE @_vCapEx VARCHAR(4000)
DECLARE @_vCurrent_PO VARCHAR(4000)
DECLARE @_vEBIT_Local_Currency VARCHAR(4000)
DECLARE @_vEBIT_Local_Currency_raw VARCHAR(4000)
DECLARE @_vGL_Account VARCHAR(4000)
DECLARE @_vGSGPC VARCHAR(4000)
DECLARE @_vIn_AOP VARCHAR(4000)
DECLARE @_vLCC_Sourcing VARCHAR(4000)
DECLARE @_vNet_Savings_Local_Currency VARCHAR(4000)
DECLARE @_vNet_Savings_Local_Currency_raw VARCHAR(4000)
DECLARE @_vPrebateRebate VARCHAR(4000)
DECLARE @_vPrior_PO VARCHAR(4000)
DECLARE @_vProbability_Adjustment VARCHAR(4000)
DECLARE @_vProbability_Adjustment_raw VARCHAR(4000)
DECLARE @_vTotal_Opportunity VARCHAR(4000)
DECLARE @_vTotal_Opportunity_raw VARCHAR(4000)
DECLARE @_vVendor_Name VARCHAR(4000)
DECLARE @_vWorking_Capital_Impact_Date VARCHAR(4000)
DECLARE @_vWorking_Capital_Impact_Date_raw VARCHAR(4000)
DECLARE @_vYearly_Volume VARCHAR(4000)
DECLARE @_vYearly_Volume_raw VARCHAR(4000)
DECLARE @_vEstimated_Baseline_Savings VARCHAR(4000)
DECLARE @_vEstimated_Baseline_Savings_raw VARCHAR(4000)
DECLARE @_vEstimated_Timeline VARCHAR(4000)
DECLARE @_vFull_Potential_Savings VARCHAR(4000)
DECLARE @_vFull_Potential_Savings_raw VARCHAR(4000)
DECLARE @_vProbability_of_Achieving_Savings VARCHAR(4000)
DECLARE @_vProbability_of_Achieving_Savings_raw VARCHAR(4000)
DECLARE @_vProject_Description VARCHAR(4000)
DECLARE @_vProject_Rejected_On_Hold VARCHAR(4000)
DECLARE @_vBaseline_Spend VARCHAR(4000)
DECLARE @_vBaseline_Supplier VARCHAR(4000)
DECLARE @_vBusiness_case_Benefits_Risks_etc VARCHAR(4000)
DECLARE @_vEstimated_Implementation_Costs VARCHAR(4000)
DECLARE @_vEstimated_Procurement_Resources VARCHAR(4000)

DECLARE @_vPSC_Id INT 
DECLARE @_vWT_Project_Id INT

--Roles and Tags
DECLARE @_vTeam_Member VARCHAR(4000)
DECLARE @_vMBB_FI_Expert VARCHAR(4000)
DECLARE @_vBlack_Belt VARCHAR(4000)
DECLARE @_vProcess_Owner VARCHAR(4000)
DECLARE @_vSponsor VARCHAR(4000)
DECLARE @_vFinancial_Rep VARCHAR(4000)
DECLARE @_vRegional_Category_Manager VARCHAR(4000)
DECLARE @_vPlant_Purchasing_Manager VARCHAR(4000)
DECLARE @_vAssociate_Editors VARCHAR(4000)
DECLARE @_vProject_Manager VARCHAR(4000)
DECLARE @_vManager VARCHAR(4000)
DECLARE @_vStakeholder VARCHAR(4000)
DECLARE @_vBusiness_Area VARCHAR(4000)
DECLARE @_vCost_Category VARCHAR(4000)
DECLARE @_vCountry VARCHAR(4000)
DECLARE @_vDepartments VARCHAR(4000)
DECLARE @_vFinance_BPO VARCHAR(4000)
DECLARE @_vFinancial_Impact_Area VARCHAR(4000)
DECLARE @_vLocation VARCHAR(4000)
DECLARE @_vPlant_Optimization_pillar VARCHAR(4000)
DECLARE @_vPrimary_Loss_Categories VARCHAR(4000)
DECLARE @_vProduct_Category VARCHAR(4000)
DECLARE @_vProject_Allocation VARCHAR(4000)
DECLARE @_vProject_Category VARCHAR(4000)
DECLARE @_vProject_Codification VARCHAR(4000)
DECLARE @_vProject_Main_Category VARCHAR(4000)
DECLARE @_vRegions VARCHAR(4000)
DECLARE @_vSub_Cost_Categories VARCHAR(4000)
DECLARE @_vOld_Payment_Terms VARCHAR(4000)
DECLARE @_vNew_Payment_Terms VARCHAR(4000)
DECLARE @_vBest_Project_Award VARCHAR(4000)
DECLARE @_vProject_Tracking_Indicator VARCHAR(4000)
DECLARE @_vRate_or_Non_Rate VARCHAR(4000)
DECLARE @_vRegional_or_Plant_Project VARCHAR(4000)
DECLARE @_vRegional_Tracking_Category VARCHAR(4000)
DECLARE @_vTW_Loss_Categories VARCHAR(4000)
DECLARE @_vWorking_Capital_Type VARCHAR(4000)
DECLARE @_vGPH_Category VARCHAR(4000)
DECLARE @_vGPH_Sub_Category VARCHAR(4000)
DECLARE @_vProject_Status VARCHAR(4000)
DECLARE @_vProject_Type VARCHAR(4000)
DECLARE @_vSpend_Type VARCHAR(4000)

--Primary Keys
DECLARE @_vProj_Track_Id INT
DECLARE @_vSpend_Type_Id INT
DECLARE @_vProj_Type_Id INT
DECLARE @_vRate_Type_Id INT
DECLARE @_vRegTrack_Cat_Id INT
DECLARE @_vFin_Impact_Ar_Id INT
DECLARE @_vGPH_Cat_Id INT
DECLARE @_vGPH_Sub_Cat_Id INT
DECLARE @_vRegion_Code VARCHAR(5)
DECLARE @_vCountry_Code VARCHAR(3)
DECLARE @_vLocation_Id INT
--DECLARE @_vRef_Idea_Id INT
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

--Clear previous data
TRUNCATE TABLE Temp_PSC_Error

TRUNCATE TABLE Temp_PSC_MissingRoleMember_Error

TRUNCATE TABLE Temp_PSC_Gate_Deliverable_Error

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving_Baseline

--TRUNCATE TABLE GPM_WT_Project_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Team

--TRUNCATE TABLE GPM_WT_Project_Team_Deliverable

--TRUNCATE TABLE GPM_WT_Project_Gate

--DELETE FROM GPM_WT_Project

DELETE FROM GPM_WT_Procurement

SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='PSC'  AND Is_Deleted_Ind='N'

DECLARE PSC_Cursor CURSOR FOR
	SELECT 
		[Name],
		[PowerSteering_ID],
		[Sequence_number],
		[Project_Lead],
		[System_start_date],
		[Active_phase],
		[System_end_date],
		[Status],
		[Work_Template],
		[Work_type],
		[Comments:],
		[Consequential_Metric],
		[Expected_Benefits],
		[Expected_Total_Savings_in_$],
		[Expected_Total_Savings_in_$_-_raw],
		[Goal_Statement],
		[Primary_Metric_and_Current_Performance],
		[Problem_Statement],
		[Project_Scope_and_Scale],
		[Secondary_Metric],
		[Project_Summary],
		[Annual_Spend],
		[Annual_Spend_-_raw],
		[CA_(Local_Currency)],
		[CA_(Local_Currency)_-_raw],
		[CapEx],
		[Current_PO],
		[EBIT_(Local_Currency)],
		[EBIT_(Local_Currency)_-_raw],
		[GL_Account],
		[GSGPC],
		[In_AOP?],
		[LCC_Sourcing?],
		[Net_Savings_(Local_Currency)],
		[Net_Savings_(Local_Currency)_-_raw],
		[Prebate/Rebate?],
		[Prior_PO],
		[Probability_Adjustment_(%)],
		[Probability_Adjustment_(%)_-_raw],
		[Total_Opportunity],
		[Total_Opportunity_-_raw],
		[Vendor_Name],
		[Working_Capital_Impact_Date],
		[Working_Capital_Impact_Date_-_raw],
		[Yearly_Volume],
		[Yearly_Volume_-_raw],
		[Estimated_Baseline_Savings_($)],
		[Estimated_Baseline_Savings_($)_-_raw],
		[Estimated_Timeline],
		[Full_Potential_Savings_($)],
		[Full_Potential_Savings_($)_-_raw],
		[Probability_of_Achieving_Savings_(%)],
		[Probability_of_Achieving_Savings_(%)_-_raw],
		[Project_Description],
		[Project_Rejected/_On_Hold],
		[Baseline_Spend],
		[Baseline_Supplier],
		[Business_case_(Benefits,_Risks,_etc.)],
		[Estimated_Implementation_Costs],
		[Estimated_Procurement_Resources]

	FROM
		Temp_PSC_Custom_Fields

	OPEN PSC_Cursor
		FETCH NEXT FROM PSC_Cursor INTO
			@_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,@_vWork_Template,@_vWork_type,@_vComments,
			@_vConsequential_Metric,@_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,@_vProblem_Statement,
			@_vProject_Scope_and_Scale,@_vSecondary_Metric,@_vProject_Summary,@_vAnnual_Spend,@_vAnnual_Spend_raw,@_vCA_Local_Currency,@_vCA_Local_Currency_raw,@_vCapEx,@_vCurrent_PO,@_vEBIT_Local_Currency,
			@_vEBIT_Local_Currency_raw,@_vGL_Account,@_vGSGPC,@_vIn_AOP,@_vLCC_Sourcing,@_vNet_Savings_Local_Currency,@_vNet_Savings_Local_Currency_raw,@_vPrebateRebate,@_vPrior_PO,@_vProbability_Adjustment,
			@_vProbability_Adjustment_raw,@_vTotal_Opportunity,@_vTotal_Opportunity_raw,@_vVendor_Name,@_vWorking_Capital_Impact_Date,@_vWorking_Capital_Impact_Date_raw,@_vYearly_Volume,@_vYearly_Volume_raw,
			@_vEstimated_Baseline_Savings,@_vEstimated_Baseline_Savings_raw,@_vEstimated_Timeline,@_vFull_Potential_Savings,@_vFull_Potential_Savings_raw,@_vProbability_of_Achieving_Savings,@_vProbability_of_Achieving_Savings_raw,
			@_vProject_Description,@_vProject_Rejected_On_Hold,@_vBaseline_Spend,@_vBaseline_Supplier,@_vBusiness_case_Benefits_Risks_etc,@_vEstimated_Implementation_Costs,@_vEstimated_Procurement_Resources

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
				 @_vGPH_Category = NULL,
				 @_vGPH_Sub_Category = NULL,
				 @_vProject_Status = NULL,
				 @_vProject_Type = NULL,
				 @_vSpend_Type = NULL,

				 @_vProj_Track_Id = NULL,
				 @_vSpend_Type_Id = NULL,
				 @_vProj_Type_Id = NULL,
				 @_vRate_Type_Id = NULL,
				 @_vRegTrack_Cat_Id = NULL,
				 @_vFin_Impact_Ar_Id = NULL,
				 @_vGPH_Cat_Id = NULL,
				 @_vGPH_Sub_Cat_Id = NULL,
				 @_vRegion_Code = NULL,
				 @_vCountry_Code = NULL,
				 @_vLocation_Id = NULL

				 SELECT
					@_vTeam_Member = [Team_Member],
					@_vMBB_FI_Expert = [MBB/FI-Expert],
					@_vBlack_Belt = [Black_Belt],
					@_vProcess_Owner = [Process_Owner],
					@_vSponsor = [Sponsor],
					@_vFinancial_Rep = [Financial_Rep],
					@_vRegional_Category_Manager = [Regional_Category_Manager],
					@_vPlant_Purchasing_Manager = [Plant_Purchasing_Manager],
					@_vAssociate_Editors = [Associate_Editors],
					@_vProject_Manager = [Project_Manager],
					@_vManager = [Manager],
					@_vStakeholder = [Stakeholder],
					@_vActive_phase = [Active_phase],
					@_vSystem_end_date = [System_end_date],
					@_vBusiness_Area = [Business_Area],
					@_vCost_Category = [Cost_Category],
					@_vCountry = [Country],
					@_vDepartments = [Departments],
					@_vFinance_BPO = [Finance_BPO],
					@_vFinancial_Impact_Area = [Financial_Impact_Area],
					@_vLocation = [Location],
					@_vPlant_Optimization_pillar = [Plant_Optimization_pillar],
					@_vPrimary_Loss_Categories = [Primary_Loss_Categories],
					@_vProduct_Category = [Product_Category],
					@_vProject_Allocation = [Project_Allocation],
					@_vProject_Category = [Project_Category],
					@_vProject_Codification = [Project_Codification],
					@_vProject_Main_Category = [Project_Main_Category],
					@_vRegions = [Regions],
					@_vSub_Cost_Categories = [Sub_Cost_Categories],
					@_vOld_Payment_Terms = [1.)_Old_Payment_Terms],
					@_vNew_Payment_Terms = [2.)_New_Payment_Terms],
					@_vBest_Project_Award = [Best_Project_Award],
					@_vProject_Tracking_Indicator = [Project_Tracking_Indicator],
					@_vRate_or_Non_Rate = [Rate_or_Non_Rate],
					@_vRegional_or_Plant_Project = [Regional_or_Plant_Project?],
					@_vRegional_Tracking_Category = [Regional_Tracking_Category],
					@_vTW_Loss_Categories = [T&W_Loss_Categories],
					@_vWorking_Capital_Type = [Working_Capital_Type],
					@_vGPH_Category = [GPH_Category],
					@_vGPH_Sub_Category = [GPH_Sub-Category],
					@_vProject_Status = [Project_Status_],
					@_vProject_Type = [Project_Type],
					@_vSpend_Type = [Spend_Type]

				FROM Temp_PSC_RoleAndTags
				WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))

				
				SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry)) OR RTRIM(LTRIM(Alt_Country_Name))=RTRIM(LTRIM(@_vCountry))
				SELECT @_vFin_Impact_Ar_Id=Fin_Impact_Ar_Id FROM GPM_Finance_Impact_Area WHERE RTRIM(LTRIM(Fin_Impact_Ar_Desc))=RTRIM(LTRIM(@_vFinancial_Impact_Area)) 
				SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
				SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
				SELECT @_vRate_Type_Id=Rate_Type_Id FROM GPM_Rate_Type WHERE RTRIM(LTRIM(Rate_Type_Desc))=RTRIM(LTRIM(@_vRate_or_Non_Rate))
				SELECT @_vRegTrack_Cat_Id=RegTrack_Cat_Id FROM GPM_Reg_Track_Category WHERE RTRIM(LTRIM(RegTrack_Cat_Desc))=RTRIM(LTRIM(@_vRegional_Tracking_Category))
				SELECT @_vGPH_Sub_Cat_Id=TW_Loss_Cat_Id FROM GPM_TW_Loss_Category WHERE RTRIM(LTRIM(TW_Loss_Cat_Desc))=RTRIM(LTRIM(@_vTW_Loss_Categories))
				SELECT @_vGPH_Cat_Id=GPH_Cat_Id FROM GPM_GPH_Category WHERE RTRIM(LTRIM(GPH_Cat_Desc))=RTRIM(LTRIM(@_vGPH_Category))
				SELECT @_vGPH_Sub_Cat_Id=GPH_Sub_Cat_Id FROM GPM_GPH_Sub_Category WHERE RTRIM(LTRIM(GPH_Sub_Cat_Desc))=RTRIM(LTRIM(@_vGPH_Sub_Category)) AND GPH_Cat_Id=@_vGPH_Cat_Id
				SELECT @_vProj_Type_Id=Proj_Type_Id FROM GPM_Project_Type WHERE RTRIM(LTRIM(Proj_Type_Desc))=RTRIM(LTRIM(@_vProject_Type))
				SELECT @_vSpend_Type_Id=Spend_Type_Id FROM GPM_Spend_Type WHERE RTRIM(LTRIM(Spend_Type_Desc))=RTRIM(LTRIM(@_vSpend_Type))
				--SELECT @_vProj_Track_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = RTRIM(LTRIM(@_vStatus))				
				SELECT @_vProj_Track_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
				SELECT @_vCreated_By=GD_User_Id FROM GPM_USer WHERE User_First_Name +' '+User_Last_Name = RTRIM(LTRIM(@_vProject_Lead))

				SELECT @_vError_Desc=''

				--Add NA and NMA validation here

				IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : MDPO Name Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vStatus IS NULL OR LEN(LTRIM(RTRIM(@_vStatus)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Status Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProj_Track_Id IS NULL OR  @_vProj_Track_Id<=0)
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

				IF(@_vFull_Potential_Savings IS NULL OR LEN(LTRIM(RTRIM(@_vFull_Potential_Savings)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Full Potential Savings Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProbability_of_Achieving_Savings IS NULL OR LEN(LTRIM(RTRIM(@_vProbability_of_Achieving_Savings)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Probability of Achieving Savings Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vEstimated_Baseline_Savings IS NULL OR LEN(LTRIM(RTRIM(@_vEstimated_Baseline_Savings)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Estimated Baseline Savings Is Blank'
					SELECT @_vValidData='FALSE'
				END

				/*
				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


				IF(@_vProject_Lead IS NOT NULL AND LEN(LTRIM(RTRIM(@_vProject_Lead)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vProject_Lead


				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
				BEGIN
					SELECT @_vProject_Lead = 'BluePrint Test'
					--SELECT @_vError_Desc += '| MA : Project Lead Is Blank'
					--SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vProject_Lead +' Project Lead Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vFinancial_Rep= NULL

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				IF(@_vFinancial_Rep IS NOT NULL AND LEN(LTRIM(RTRIM(@_vFinancial_Rep)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vFinancial_Rep

				IF(@_vFinancial_Rep IS NULL OR LEN(LTRIM(RTRIM(@_vFinancial_Rep)))<=0)
				BEGIN
					SELECT @_vFinancial_Rep = 'BluePrint Test'
					--SELECT @_vError_Desc += '| MA : Financial Rep Is Blank'
					--SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vFinancial_Rep +' Financial_Rep Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				SELECT @_vProject_Member_Id=NULL
				SELECT @_vSponsor= NULL

				SELECT @_vSponsor=LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				IF(@_vSponsor IS NOT NULL AND LEN(LTRIM(RTRIM(@_vSponsor)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vSponsor

				IF(@_vSponsor IS NULL OR LEN(LTRIM(RTRIM(@_vSponsor)))<=0)
				BEGIN
					SELECT @_vSponsor = 'BluePrint Test'
					--SELECT @_vError_Desc += '| MA : Sponsor Is Blank'
					--SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vSponsor +' Sponsor Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				SELECT @_vProject_Member_Id=NULL
				SELECT @_vManager= NULL

				SELECT @_vManager=LTRIM(RTRIM(TDR.Manager)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				IF(@_vManager IS NOT NULL AND LEN(LTRIM(RTRIM(@_vManager)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vManager

				IF(@_vManager IS NULL OR LEN(LTRIM(RTRIM(@_vManager)))<=0)
				BEGIN
					SELECT @_vManager = 'BluePrint Test'
					--SELECT @_vError_Desc += '| MA : Manager Is Blank'
					--SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : '+ @_vManager +' Manager Not Found In User table'
					SELECT @_vValidData='FALSE'
				END
				*/

				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


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

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

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

				SELECT @_vSponsor=LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
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

				
				SELECT @_vProject_Member_Id=NULL
				SELECT @_vManager=NULL

				SELECT @_vManager=LTRIM(RTRIM(TDR.Manager)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
				IF(@_vManager IS NOT NULL AND LEN(LTRIM(RTRIM(@_vManager)))>0)
				BEGIN
					SELECT TOP 1 @_vManager = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vManager, CHAR(10),'|'))))) TAB 
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vManager

					IF(@_vProject_Member_Id IS NULL)
					BEGIN
					SELECT TOP 1 @_vManager = LTRIM(RTRIM(REPLACE(REPLACE(TAB.Value, CHAR(10),''),CHAR(13),'')))	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(@_vManager, CHAR(13),'|'))))) TAB 
					END
				END

				IF(@_vManager IS NULL OR LEN(LTRIM(RTRIM(@_vManager)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: Manager Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vManager +' Manager Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				IF EXISTS(
					SELECT COUNT(*) FROM Temp_PSC_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
					SELECT @_vError_Desc += '| Duplicate Gate Found'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_PSC_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_PSC_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='PSC' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END

				END

				--Add data in DB
				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_PSC_Error
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
					
					INSERT INTO GPM_WT_Procurement
							   (
								   PSC_Number,
								   PSC_Name,
								   Plan_Start_Date,
								   Proj_Track_Id,
								   Spend_Type_Id,
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
								   Business_Case,
								   Baseline_Spend,
								   Baseline_Supp,
								   Est_Timeline,
								   Est_Proc_Resource,
								   Est_Implement_Cost,
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
								   @_vProj_Track_Id,
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
								   @_vLocation_Id,
								   CASE WHEN LEN(LTRIM(RTRIM(@_vFull_Potential_Savings)))>0 THEN
								   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vFull_Potential_Savings,'$',''),',','') ,')',''),'(','-'),' ','') ELSE NULL END,
								   @_vProbability_of_Achieving_Savings,
								   CASE WHEN LEN(LTRIM(RTRIM(@_vEstimated_Baseline_Savings)))>0 THEN
								   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vEstimated_Baseline_Savings,'$',''),',','') ,')',''),'(','-'),' ','') ELSE NULL END,
								   @_vBusiness_case_Benefits_Risks_etc,
								   @_vBaseline_Spend,
								   @_vBaseline_Supplier,
								   @_vEstimated_Timeline,
								   @_vEstimated_Procurement_Resources,
								   @_vEstimated_Implementation_Costs,
								   NULL,--@_vRef_Idea_Id,
								   'N',
								   'N',
								   GETDATE(),
								   @_vCreated_By,
								   GETDATE(),
								   @_vCreated_By
							   )

					SELECT @_vPSC_Id=NULL
					SELECT @_vPSC_Id=@@IDENTITY

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
						'PSC',
						@_vPSC_Id,
						@_vSequence_number,
						@_vSystem_start_date,
						@_vSystem_end_date,
						@_vProj_Track_Id,
						@_vCreated_By,
						Getdate(),
						@_vCreated_By,
						Getdate()
					)

					SELECT @_vWT_Project_Id=@@IDENTITY


					-- Start for Gate & Deliverable	

					DELETE FROM @_vTabGate

					SELECT @_vActive_Gate=NULL

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_PSC_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL
						

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
					FROM Temp_PSC_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='PSC' AND UPPER(TDGA.Work_type)='GATE'


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
															(SELECT Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status=LTRIM(RTRIM(CASE WHEN TDGD.Status='Canceled' Then 'Cancelled' Else TDGD.Status END))),
															NULL,
															TDGD.System_start_date,
															TDGD.System_end_date,
															'Y',
															'N',
															@_vCreated_By,
															TDGD.System_start_date,
															@_vCreated_By,
															TDGD.System_end_date
															FROM Temp_PSC_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND
															(CASE WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 1' THEN 'Month 1 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 2' THEN 'Month 2 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 3' THEN 'Month 3 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 4' THEN 'Month 4 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 5' THEN 'Month 5 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 6' THEN 'Month 6 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 7' THEN 'Month 7 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 8' THEN 'Month 8 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 9' THEN 'Month 9 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 10' THEN 'Month 10 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 11' THEN 'Month 11 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 12' THEN 'Month 12 - Savings Input (Act+Fcst)'
																ELSE 
																	LTRIM(RTRIM(TDGD.Deliverable_Name))
															END)=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable' 
															AND GGD.WT_Code='PSC'
															Order by GGD.Deliverable_Default_Order


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
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'PSC' AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT TOP 1 GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM	Temp_PSC_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND
															(CASE WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 1' THEN 'Month 1 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 2' THEN 'Month 2 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 3' THEN 'Month 3 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 4' THEN 'Month 4 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 5' THEN 'Month 5 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 6' THEN 'Month 6 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 7' THEN 'Month 7 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 8' THEN 'Month 8 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 9' THEN 'Month 9 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 10' THEN 'Month 10 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 11' THEN 'Month 11 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings input month 12' THEN 'Month 12 - Savings Input (Act+Fcst)'
																ELSE 
																	LTRIM(RTRIM(TDGD.Deliverable_Name))
															END)=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable'
															AND GGD.WT_Code='PSC'
															AND EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead)))
															Order by GGD.Deliverable_Default_Order

											SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
										END
								END /*End Gate Loop*/
							
							/* Add Project Member*/

							SELECT @_vProject_Member_Id = NULL

							PRINT @_vSequence_number

							DELETE FROM @_vProjectMember_Table
								
								--INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								--	SELECT 'Project Lead',LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead',LTRIM(RTRIM(@_vProject_Lead))

								--INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								--	SELECT 'Sponsor',LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								SELECT 'Sponsor', LTRIM(RTRIM(@_vSponsor))

								--INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								--	SELECT 'Financial Rep',LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',LTRIM(RTRIM(@_vFinancial_Rep))

								--INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								--	SELECT 'Managers',LTRIM(RTRIM(TDR.Manager)) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
								
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Managers',LTRIM(RTRIM(@_vManager))

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_PSC_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
									) TAB 


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
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='PSC' AND WT_Role_Name=@_vWT_Role_Name),
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

											INSERT INTO Temp_PSC_MissingRoleMember_Error
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

							-- starts TDC Saving
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


								SELECT @_vWT_Project_Id,GMTS.Attrib_Id,
								--TDC.YearMonth,
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
								1,
								@_vCreated_By,
								@_vSystem_start_date,
								@_vCreated_By,
								@_vSystem_end_date
							FROM Temp_PSC_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
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
								1,
								@_vCreated_By,
								@_vSystem_start_date,
								@_vCreated_By,
								@_vSystem_end_date
							FROM Temp_PSC_TDC TDC INNER JOIN GPM_Metrics_TDC_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
							AND TDC.TDC_Type='Baseline' ORDER BY 3,2
							*/
						END /* Valid */

					FETCH NEXT FROM PSC_Cursor INTO 
					@_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,@_vWork_Template,@_vWork_type,@_vComments,
					@_vConsequential_Metric,@_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,@_vProblem_Statement,
					@_vProject_Scope_and_Scale,@_vSecondary_Metric,@_vProject_Summary,@_vAnnual_Spend,@_vAnnual_Spend_raw,@_vCA_Local_Currency,@_vCA_Local_Currency_raw,@_vCapEx,@_vCurrent_PO,@_vEBIT_Local_Currency,
					@_vEBIT_Local_Currency_raw,@_vGL_Account,@_vGSGPC,@_vIn_AOP,@_vLCC_Sourcing,@_vNet_Savings_Local_Currency,@_vNet_Savings_Local_Currency_raw,@_vPrebateRebate,@_vPrior_PO,@_vProbability_Adjustment,
					@_vProbability_Adjustment_raw,@_vTotal_Opportunity,@_vTotal_Opportunity_raw,@_vVendor_Name,@_vWorking_Capital_Impact_Date,@_vWorking_Capital_Impact_Date_raw,@_vYearly_Volume,@_vYearly_Volume_raw,
					@_vEstimated_Baseline_Savings,@_vEstimated_Baseline_Savings_raw,@_vEstimated_Timeline,@_vFull_Potential_Savings,@_vFull_Potential_Savings_raw,@_vProbability_of_Achieving_Savings,@_vProbability_of_Achieving_Savings_raw,
					@_vProject_Description,@_vProject_Rejected_On_Hold,@_vBaseline_Spend,@_vBaseline_Supplier,@_vBusiness_case_Benefits_Risks_etc,@_vEstimated_Implementation_Costs,@_vEstimated_Procurement_Resources

			END

		 CLOSE PSC_Cursor;
		 DEALLOCATE PSC_Cursor;
		 IF CURSOR_STATUS('global','PSC_Cursor')>=-1
		 BEGIN
		   DEALLOCATE PSC_Cursor
		 END
END