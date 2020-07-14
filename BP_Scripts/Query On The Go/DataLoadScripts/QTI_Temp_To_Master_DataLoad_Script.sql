BEGIN

--QTI Custom Fields
DECLARE @_vName NVARCHAR(MAX)
DECLARE @_vPowerSteering_ID NVARCHAR(MAX)
DECLARE @_vSequence_number NVARCHAR(MAX)
DECLARE @_vProject_Lead NVARCHAR(MAX)
DECLARE @_vSystem_start_date NVARCHAR(MAX)
DECLARE @_vActive_phase NVARCHAR(MAX)
DECLARE @_vSystem_end_date NVARCHAR(MAX)
DECLARE @_vStatus NVARCHAR(MAX)
DECLARE @_vWork_Template NVARCHAR(MAX)
DECLARE @_vWork_type NVARCHAR(MAX)
DECLARE @_vComments NVARCHAR(MAX)
DECLARE @_vConsequential_Metric NVARCHAR(MAX)
DECLARE @_vExpected_Benefits NVARCHAR(MAX)
DECLARE @_vExpected_Total_Savings_in_$ NVARCHAR(MAX)
DECLARE @_vExpected_Total_Savings_in_$_raw NVARCHAR(MAX)
DECLARE @_vGoal_Statement NVARCHAR(MAX)
DECLARE @_vPrimary_Metric_and_Current_Performance NVARCHAR(MAX)
DECLARE @_vProblem_Statement NVARCHAR(MAX)
DECLARE @_vProject_Scope_and_Scale NVARCHAR(MAX)
DECLARE @_vSecondary_Metric NVARCHAR(MAX)
DECLARE @_vLoss_Opportunity NVARCHAR(MAX)
DECLARE @_vLoss_Opportunity_raw NVARCHAR(MAX)
DECLARE @_vAgent_Company_Name NVARCHAR(MAX)
DECLARE @_vAgent_Contact_Name NVARCHAR(MAX)
DECLARE @_vAgent_Email NVARCHAR(MAX)
DECLARE @_vAgent_Phone_Number NVARCHAR(MAX)
DECLARE @_vARD# NVARCHAR(MAX)
DECLARE @_vAre_there_other_trials_that_require_this_material NVARCHAR(MAX)
DECLARE @_vCIRF_Needed NVARCHAR(MAX)
DECLARE @_vCIRF_Received NVARCHAR(MAX)
DECLARE @_vCOA_ppk_data_needed_ NVARCHAR(MAX)
DECLARE @_vCode_Name NVARCHAR(MAX)
DECLARE @_vComments_Deliverable NVARCHAR(MAX)
DECLARE @_vCompound_Treatment_for_trial NVARCHAR(MAX)
DECLARE @_vConstruction_dtex NVARCHAR(MAX)
DECLARE @_vCSIS_# NVARCHAR(MAX)
DECLARE @_vData_needs_beyond_the_specification NVARCHAR(MAX)
DECLARE @_vDescribe_any_technical_requirements_or_data_needs_ NVARCHAR(MAX)
DECLARE @_vDiff_bw_GY_Supplier_Specs_or_test_methods NVARCHAR(MAX)
DECLARE @_vDipped_Fabric_Width NVARCHAR(MAX)
DECLARE @_vDoes_Supplier_have_Required_Import_Documentation NVARCHAR(MAX)
DECLARE @_vEHS_Process_Questions_needed NVARCHAR(MAX)
DECLARE @_vEPI NVARCHAR(MAX)
DECLARE @_vGMS_Stage_2_Testing_Requirements NVARCHAR(MAX)
DECLARE @_vGoodyear_specification_sent NVARCHAR(MAX)
DECLARE @_vGoodyear_test_methods_sent NVARCHAR(MAX)
DECLARE @_vHAP_free_letter_needed NVARCHAR(MAX)
DECLARE @_vHas_supplier_signed_the_specification NVARCHAR(MAX)
DECLARE @_vIf_no_note_supplier_requirements_exceptions NVARCHAR(MAX)
DECLARE @_vIf_yes_what_trials NVARCHAR(MAX)
DECLARE @_vImport_License_Required NVARCHAR(MAX)
DECLARE @_vIntermediary_Destination_if_Applicable NVARCHAR(MAX)
DECLARE @_vLead_Time_for_Process_Trial_Material_No_of_days NVARCHAR(MAX)
DECLARE @_vMaterial_Trade_Name NVARCHAR(MAX)
DECLARE @_vMISVPS_# NVARCHAR(MAX)
DECLARE @_vMode_Requirements NVARCHAR(MAX)
DECLARE @_vNetwork_# NVARCHAR(MAX)
DECLARE @_vOther_Considerations NVARCHAR(MAX)
DECLARE @_vPackaging_Requirements NVARCHAR(MAX)
DECLARE @_vPlant_HSE_Review NVARCHAR(MAX)
DECLARE @_vPlant_Raw_Material_Planner NVARCHAR(MAX)
DECLARE @_vPlant_Specific_Requirements NVARCHAR(MAX)
DECLARE @_vPlant_Technical_Contact NVARCHAR(MAX)
DECLARE @_vPlant_volume_trial_needed NVARCHAR(MAX)
DECLARE @_vProcessing_and_Volume_trial_durations NVARCHAR(MAX)
DECLARE @_vProcessing_trial_required NVARCHAR(MAX)
DECLARE @_vProduct_Stewardship_Stage_1_Supplier_Requirements NVARCHAR(MAX)
DECLARE @_vProject_Leader_Concept_Check NVARCHAR(MAX)
DECLARE @_vQTY_of_Tires_per_Trial NVARCHAR(MAX)
DECLARE @_vQTY_of_Tires_per_Trial_raw NVARCHAR(MAX)
DECLARE @_vQuality_Stage_1_Supplier_Requirements NVARCHAR(MAX)
DECLARE @_vREACH_andor_Inventory_Status_OK NVARCHAR(MAX)
DECLARE @_vSDS_Needed NVARCHAR(MAX)
DECLARE @_vSDS_OK NVARCHAR(MAX)
DECLARE @_vSDS_Received NVARCHAR(MAX)
DECLARE @_vSIS_Material_Code_New_Supplier_ NVARCHAR(MAX)
DECLARE @_vSpool_Length NVARCHAR(MAX)
DECLARE @_vSpool_Type NVARCHAR(MAX)
DECLARE @_vSQA_Stage_1_Concept_Check NVARCHAR(MAX)
DECLARE @_vSQA_Stage_1_Supplier_Requirements NVARCHAR(MAX)
DECLARE @_vSupplier_Company_Name NVARCHAR(MAX)
DECLARE @_vSupplier_compliant_in_SIS NVARCHAR(MAX)
DECLARE @_vSupplier_Contact_Name NVARCHAR(MAX)
DECLARE @_vSupplier_Email NVARCHAR(MAX)
DECLARE @_vSupplier_is_capable_to_meet_Goodyear_requirements NVARCHAR(MAX)
DECLARE @_vSupplier_meets_mode_requirement NVARCHAR(MAX)
DECLARE @_vSupplier_meets_packaging_requirement NVARCHAR(MAX)
DECLARE @_vSupplier_Phone_# NVARCHAR(MAX)
DECLARE @_vSupplier_Plant_Location NVARCHAR(MAX)
DECLARE @_vSupplier_requirements_accepted NVARCHAR(MAX)
DECLARE @_vSupplier_specification_needed NVARCHAR(MAX)
DECLARE @_vSupply_Chain_Stage_1_Supplier_Requirements NVARCHAR(MAX)
DECLARE @_vTire_SKU_for_trial NVARCHAR(MAX)
DECLARE @_vTotal_Ends NVARCHAR(MAX)
DECLARE @_vTotal_quantity_needed_units NVARCHAR(MAX)
DECLARE @_vTreatment_Width_suffix NVARCHAR(MAX)
DECLARE @_vTwist NVARCHAR(MAX)
DECLARE @_vUnique_# NVARCHAR(MAX)
DECLARE @_vValue_Date NVARCHAR(MAX)
DECLARE @_vValue_Date_raw NVARCHAR(MAX)
DECLARE @_vVendor_code NVARCHAR(MAX)
DECLARE @_vVPS_Scheduled_Date NVARCHAR(MAX)
DECLARE @_vVPS_Scheduled_Date_raw NVARCHAR(MAX)
DECLARE @_vVPS_template NVARCHAR(MAX)
DECLARE @_vVSDS_number_ NVARCHAR(MAX)
DECLARE @_vWill_the_supplier_ship_all_material_at_once NVARCHAR(MAX)
DECLARE @_vXcode NVARCHAR(MAX)
DECLARE @_vYarn_Type NVARCHAR(MAX)

--QTI Roles and Tags

DECLARE @_vTeam_Member NVARCHAR(MAX)
DECLARE @_vMBB_FI_Expert NVARCHAR(MAX)
DECLARE @_vBlack_Belt NVARCHAR(MAX)
DECLARE @_vProcess_Owner NVARCHAR(MAX)
DECLARE @_vSponsor NVARCHAR(MAX)
DECLARE @_vFinancial_QTI NVARCHAR(MAX)
DECLARE @_vPlant_Level_Nomination_Approver NVARCHAR(MAX)
DECLARE @_vRegional_Down_Select_Approver NVARCHAR(MAX)
DECLARE @_vGlobal_Analysis_Approver NVARCHAR(MAX)
DECLARE @_vGlobal_Stakeholder_Approver NVARCHAR(MAX)
DECLARE @_vGlobal_Council_Approver NVARCHAR(MAX)
DECLARE @_vMilliken_users NVARCHAR(MAX)
DECLARE @_vPillar_Approver NVARCHAR(MAX)
DECLARE @_vGlobal_Material_Science_Manager NVARCHAR(MAX)
DECLARE @_vGlobal_Procurement_Category_Manager NVARCHAR(MAX)
DECLARE @_vGlobal_Product_Stewardship_Manager NVARCHAR(MAX)
DECLARE @_vGlobal_Procurement_Finance_Manager NVARCHAR(MAX)
DECLARE @_vSupplier_Development_Manager NVARCHAR(MAX)
DECLARE @_vBest_Project_Nomination NVARCHAR(MAX)
DECLARE @_vBusiness_Area NVARCHAR(MAX)
DECLARE @_vCost_Category NVARCHAR(MAX)
DECLARE @_vCountry NVARCHAR(MAX)
DECLARE @_vDepartments NVARCHAR(MAX)
DECLARE @_vFinance_BPO NVARCHAR(MAX)
DECLARE @_vFinancial_Impact_Area NVARCHAR(MAX)
DECLARE @_vLocation NVARCHAR(MAX)
DECLARE @_vPlant_Optimization_pillar NVARCHAR(MAX)
DECLARE @_vPrimary_Loss_Categories NVARCHAR(MAX)
DECLARE @_vProduct_Category NVARCHAR(MAX)
DECLARE @_vProject_Allocation NVARCHAR(MAX)
DECLARE @_vProject_Category NVARCHAR(MAX)
DECLARE @_vProject_Codification NVARCHAR(MAX)
DECLARE @_vProject_Main_Category NVARCHAR(MAX)
DECLARE @_vRegions NVARCHAR(MAX)
DECLARE @_vSub_Cost_Categories NVARCHAR(MAX)
DECLARE @_vTW_Loss_Categories NVARCHAR(MAX)
DECLARE @_vCategory NVARCHAR(MAX)
DECLARE @_vMaterial NVARCHAR(MAX)
DECLARE @_vMaterial_Group NVARCHAR(MAX)
DECLARE @_vProduct_Group NVARCHAR(MAX)
DECLARE @_vProgram NVARCHAR(MAX)
DECLARE @_vProposed_Plant_Trial NVARCHAR(MAX)

DECLARE @_vQTI_Id INT
DECLARE @_vMaterial_Cat_Id INT
DECLARE @_vMaterial_Id INT
DECLARE @_vMaterial_Group_Id INT
DECLARE @_vProgram_Id INT
DECLARE @_vPlant_Trial_Id INT
DECLARE @_vProduct_Group_Id INT
DECLARE @_vRegion_Code INT
DECLARE @_vCountry_Code INT
DECLARE @_vLocation_Id INT
DECLARE @_vRef_Idea_Id INT

DECLARE @_vCreated_By VARCHAR(10)
DECLARE @_vWT_Project_Id INT
DECLARE @_vStatus_Id INT

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

Truncate Table Temp_QTI_Error
Truncate Table Temp_QTI_Gate_Deliverable_Error
Truncate Table Temp_QTI_MissingRoleMember_Error
--Truncate Table GPM_WT_NMTP

SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='RD'  AND Is_Deleted_Ind='N'


DECLARE QTI_Cursor CURSOR FOR

					SELECT 
						[Name],[PowerSteering_ID],[Sequence_number],[Project_Lead],[System_start_date],[Active_phase],[System_end_date],[Status],[Work_Template],[Work_type],[Comments],[Consequential_Metric],[Expected_Benefits],
						[Expected_Total_Savings_in_$],[Expected_Total_Savings_in_$_raw],[Goal_Statement],[Primary_Metric_and_Current_Performance],[Problem_Statement],[Project_Scope_and_Scale],[Secondary_Metric],[Loss_Opportunity],
						[Loss_Opportunity_raw],[Agent_Company_Name],[Agent_Contact_Name],[Agent_Email],[Agent_Phone_Number],[ARD#],[Are_there_other_trials_that_require_this_material],[CIRF_Needed],[CIRF_Received],[COA_ppk_data_needed_],
						[Code_Name],[Comments_Deliverable],[Compound_Treatment_for_trial],[Construction_dtex],[CSIS_#],[Data_needs_beyond_the_specification],[Describe_any_technical_requirements_or_data_needs_],[Diff_bw_GY_Supplier_Specs_or_test_methods],
						[Dipped_Fabric_Width],[Does_Supplier_have_Required_Import_Documentation],[EHS_Process_Questions_needed],[EPI],[GMS_Stage_2_Testing_Requirements],[Goodyear_specification_sent],[Goodyear_test_methods_sent],[HAP_free_letter_needed],
						[Has_supplier_signed_the_specification],[If_no_note_supplier_requirements_exceptions],[If_yes_what_trials],[Import_License_Required],[Intermediary_Destination_if_Applicable],[Lead_Time_for_Process_Trial_Material_No_of_days],[Material_Trade_Name],
						[MISVPS_#],[Mode_Requirements],[Network_#],[Other_Considerations],[Packaging_Requirements],[Plant_HSE_Review],[Plant_Raw_Material_Planner],[Plant_Specific_Requirements],[Plant_Technical_Contact],[Plant_volume_trial_needed],[Processing_and_Volume_trial_durations],
						[Processing_trial_required],[Product_Stewardship_Stage_1_Supplier_Requirements],[Project_Leader_Concept_Check],[QTY_of_Tires_per_Trial],[QTY_of_Tires_per_Trial_raw],[Quality_Stage_1_Supplier_Requirements],[REACH_andor_Inventory_Status_OK],
						[SDS_Needed],[SDS_OK],[SDS_Received],[SIS_Material_Code_New_Supplier_],[Spool_Length],[Spool_Type],[SQA_Stage_1_Concept_Check],[SQA_Stage_1_Supplier_Requirements],[Supplier_Company_Name],[Supplier_compliant_in_SIS],
						[Supplier_Contact_Name],[Supplier_Email],[Supplier_is_capable_to_meet_Goodyear_requirements],[Supplier_meets_mode_requirement],[Supplier_meets_packaging_requirement],[Supplier_Phone_#],
						[Supplier_Plant_Location],[Supplier_requirements_accepted],[Supplier_specification_needed],[Supply_Chain_Stage_1_Supplier_Requirements],[Tire_SKU_for_trial],[Total_Ends],[Total_quantity_needed_units],
						[Treatment_Width_suffix],[Twist],[Unique_#],[Value_Date],[Value_Date_raw],[Vendor_code],[VPS_Scheduled_Date],[VPS_Scheduled_Date_raw],[VPS_template],[VSDS_number_],[Will_the_supplier_ship_all_material_at_once],[Xcode],[Yarn_Type]
					FROM
					Temp_QTI_Custom_Fields

			OPEN QTI_Cursor
			FETCH NEXT FROM QTI_Cursor INTO	@_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,
						@_vWork_Template,@_vWork_type,@_vComments,@_vConsequential_Metric,@_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,
						@_vProblem_Statement,@_vProject_Scope_and_Scale,@_vSecondary_Metric,@_vLoss_Opportunity,@_vLoss_Opportunity_raw,@_vAgent_Company_Name,@_vAgent_Contact_Name,@_vAgent_Email,@_vAgent_Phone_Number,
						@_vARD#,@_vAre_there_other_trials_that_require_this_material,@_vCIRF_Needed,@_vCIRF_Received,@_vCOA_ppk_data_needed_,@_vCode_Name,@_vComments_Deliverable,@_vCompound_Treatment_for_trial,
						@_vConstruction_dtex,@_vCSIS_#,@_vData_needs_beyond_the_specification,@_vDescribe_any_technical_requirements_or_data_needs_,@_vDiff_bw_GY_Supplier_Specs_or_test_methods,@_vDipped_Fabric_Width,
						@_vDoes_Supplier_have_Required_Import_Documentation,@_vEHS_Process_Questions_needed,@_vEPI,@_vGMS_Stage_2_Testing_Requirements,@_vGoodyear_specification_sent,@_vGoodyear_test_methods_sent,@_vHAP_free_letter_needed,
						@_vHas_supplier_signed_the_specification,@_vIf_no_note_supplier_requirements_exceptions,@_vIf_yes_what_trials,@_vImport_License_Required,@_vIntermediary_Destination_if_Applicable,@_vLead_Time_for_Process_Trial_Material_No_of_days,
						@_vMaterial_Trade_Name,@_vMISVPS_#,@_vMode_Requirements,@_vNetwork_#,@_vOther_Considerations,@_vPackaging_Requirements,@_vPlant_HSE_Review,@_vPlant_Raw_Material_Planner,@_vPlant_Specific_Requirements,
						@_vPlant_Technical_Contact,@_vPlant_volume_trial_needed,@_vProcessing_and_Volume_trial_durations,@_vProcessing_trial_required,@_vProduct_Stewardship_Stage_1_Supplier_Requirements,@_vProject_Leader_Concept_Check,
						@_vQTY_of_Tires_per_Trial,@_vQTY_of_Tires_per_Trial_raw,@_vQuality_Stage_1_Supplier_Requirements,@_vREACH_andor_Inventory_Status_OK,@_vSDS_Needed,@_vSDS_OK,@_vSDS_Received,@_vSIS_Material_Code_New_Supplier_,
						@_vSpool_Length,@_vSpool_Type,@_vSQA_Stage_1_Concept_Check,@_vSQA_Stage_1_Supplier_Requirements,@_vSupplier_Company_Name,@_vSupplier_compliant_in_SIS,@_vSupplier_Contact_Name,@_vSupplier_Email,
						@_vSupplier_is_capable_to_meet_Goodyear_requirements,@_vSupplier_meets_mode_requirement,@_vSupplier_meets_packaging_requirement,@_vSupplier_Phone_#,@_vSupplier_Plant_Location,@_vSupplier_requirements_accepted,
						@_vSupplier_specification_needed,@_vSupply_Chain_Stage_1_Supplier_Requirements,@_vTire_SKU_for_trial,@_vTotal_Ends,@_vTotal_quantity_needed_units,@_vTreatment_Width_suffix,
						@_vTwist,@_vUnique_#,@_vValue_Date,@_vValue_Date_raw,@_vVendor_code,@_vVPS_Scheduled_Date,@_vVPS_Scheduled_Date_raw,@_vVPS_template,@_vVSDS_number_,@_vWill_the_supplier_ship_all_material_at_once,@_vXcode,@_vYarn_Type

			WHILE @@FETCH_STATUS = 0
       
			BEGIN

				SELECT 
					@_vValidData = 'TRUE',@_vQTI_Id=NULL,@_vMaterial_Cat_Id=NULL,@_vMaterial_Id=NULL,@_vMaterial_Group_Id=NULL,@_vProgram_Id=NULL,@_vPlant_Trial_Id=NULL,
					@_vVendor_Code=NULL,@_vProduct_Group_Id=NULL,@_vRegion_Code=NULL,@_vCountry_Code=NULL,@_vLocation_Id=NULL,@_vRef_Idea_Id=NULL

					SELECT 
						@_vName = [Name],@_vPowerSteering_ID = [PowerSteering_ID],@_vSequence_number = [Sequence_number],@_vProject_Lead = [Project_Lead],@_vStatus = [Status],@_vSystem_start_date = [System_start_date],
						@_vWork_Template = [Work_Template],@_vWork_type = [Work_type],@_vTeam_Member = [Team_Member],@_vMBB_FI_Expert = [MBB_FI_Expert],@_vBlack_Belt = [Black_Belt],@_vProcess_Owner = [Process_Owner],
						@_vSponsor = [Sponsor],@_vFinancial_QTI = [Financial_Rep],@_vPlant_Level_Nomination_Approver = [Plant_Level_Nomination_Approver],@_vRegional_Down_Select_Approver = [Regional_Down_Select_Approver],
						@_vGlobal_Analysis_Approver = [Global_Analysis_Approver],@_vGlobal_Stakeholder_Approver = [Global_Stakeholder_Approver],@_vGlobal_Council_Approver = [Global_Council_Approver],
						@_vMilliken_users = [Milliken_users],@_vPillar_Approver = [Pillar_Approver],@_vGlobal_Material_Science_Manager = [Global_Material_Science_Manager],@_vGlobal_Procurement_Category_Manager = [Global_Procurement_Category_Manager],
						@_vGlobal_Product_Stewardship_Manager = [Global_Product_Stewardship_Manager],@_vGlobal_Procurement_Finance_Manager = [Global_Procurement_Finance_Manager],@_vSupplier_Development_Manager = [Supplier_Development_Manager],
						@_vActive_phase = [Active_phase],@_vSystem_end_date = [System_end_date],@_vBest_Project_Nomination = [Best_Project_Nomination],@_vBusiness_Area = [Business_Area],@_vCost_Category = [Cost_Category],
						@_vCountry = [Country],@_vDepartments = [Departments],@_vFinance_BPO = [Finance_BPO],@_vFinancial_Impact_Area = [Financial_Impact_Area],@_vLocation = [Location],@_vPlant_Optimization_pillar = [Plant_Optimization_pillar],
						@_vPrimary_Loss_Categories = [Primary_Loss_Categories],@_vProduct_Category = [Product_Category],@_vProject_Allocation = [Project_Allocation],@_vProject_Category = [Project_Category],
						@_vProject_Codification = [Project_Codification],@_vProject_Main_Category = [Project_Main_Category],@_vRegions = [Regions],@_vSub_Cost_Categories = [Sub_Cost_Categories],@_vTW_Loss_Categories = [TW_Loss_Categories],
						@_vCategory = [Category],@_vMaterial = [Material],@_vMaterial_Group = [Material_Group],@_vProduct_Group = [Product_Group],@_vProgram = [Program],@_vProposed_Plant_Trial = [Proposed_Plant_Trial]		
					FROM Temp_QTI_RoleAndTags
					WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))

				SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
				SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry))
				SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
				SELECT @_vMaterial_Cat_Id=Material_Cat_Id FROM GPM_Material_Category WHERE Material_Cat_Code = LTRIM(RTRIM(@_vCategory))
				SELECT @_vMaterial_Id=Material_Id FROM GPM_Material WHERE Material_Desc = LTRIM(RTRIM(@_vMaterial)) AND Material_Cat_Id = @_vMaterial_Cat_Id
				SELECT @_vMaterial_Group_Id=Material_Group_Id FROM GPM_Material_Group WHERE Material_Desc = LTRIM(RTRIM(@_vMaterial_Group))
				SELECT @_vProgram_Id=Program_Id FROM GPM_Program WHERE Program_Name = LTRIM(RTRIM(@_vProgram))
				SELECT @_vStatus_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
				SELECT @_vPlant_Trial_Id=Plant_Trial_Id FROM GPM_Plant_Trial WHERE Plant_Trial_Desc = LTRIM(RTRIM(@_vProposed_Plant_Trial))
				
				SELECT @_vTempGateCnt=0
				SELECT @_vError_Desc=''

				IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : QTI Name Is Blank'
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

				IF(@_vCategory IS NULL OR LEN(LTRIM(RTRIM(@_vCategory)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Material Category Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vMaterial_Cat_Id IS NULL OR  @_vMaterial_Cat_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vCategory +' Material Category Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vMaterial IS NULL OR LEN(LTRIM(RTRIM(@_vMaterial)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Material Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vMaterial_Id IS NULL OR  @_vMaterial_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vMaterial +' Material Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vMaterial_Group IS NULL OR LEN(LTRIM(RTRIM(@_vMaterial_Group)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Material Group Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vMaterial_Group_Id IS NULL OR  @_vMaterial_Group_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vMaterial_Group +' Material Group Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProgram IS NULL OR LEN(LTRIM(RTRIM(@_vProgram)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Program Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vProgram_Id IS NULL OR  @_vProgram_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vProgram +' Program Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProposed_Plant_Trial IS NULL OR LEN(LTRIM(RTRIM(@_vProposed_Plant_Trial)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Proposed Plant Trial Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vPlant_Trial_Id IS NULL OR  @_vPlant_Trial_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+ @_vProposed_Plant_Trial +' Proposed Plant Trial Not Found in DB Master Data'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vValue_Date IS NULL OR LEN(LTRIM(RTRIM(@_vValue_Date)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Value Date Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vVPS_Scheduled_Date IS NULL OR LEN(LTRIM(RTRIM(@_vVPS_Scheduled_Date)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : VPS Scheduled Date Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vSupplier_Company_Name IS NULL OR LEN(LTRIM(RTRIM(@_vSupplier_Company_Name)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Supplier Company Name Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vSupplier_Plant_Location IS NULL OR LEN(LTRIM(RTRIM(@_vSupplier_Plant_Location)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Supplier Plant Location Is Blank'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


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
					SELECT @_vError_Desc += '| MA: Project Lead Is Blank And REPLACEd With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vProject_Lead +' Project Lead Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				IF EXISTS(
					SELECT COUNT(*) FROM Temp_QTI_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
					SELECT @_vError_Desc += '| Duplicate Gate Found'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_QTI_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_QTI_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='RD' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END


				END

				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_QTI_Error
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
							INSERT INTO GPM_WT_NMTP
							(
								QTI_Number,QTI_Name,Plan_Start_Date,Material_Cat_Id,Material_Id,Material_Group_Id,Program_Id,Plant_Trial_Id,Value_Date,Code_Name,XCode_Desc,
								Material_Trade_Name,ARD_Desc,Network_Desc,Unique_Desc,MIS_VPS_Desc,VPS_Scheduled_Date,VSDS_Number,Supp_Company_Name,Supp_Plant_Location,Supp_Contact_Name,Supp_Email,Supp_Phone,
								Agent_Company_Name,Agent_Contatc_Name,Agent_Email,Agent_Phone,PTM_Lead_Time,CSIS_Desc,Vendor_Code,Required_Doc,Mat_Ship_Once,Comments,SIS_New_Supp,Supp_Requirement_Acpt,Supp_Requirement_Excpt,
								PLS_Concept_Check,SQA_S1_Supp_Requirement,SQA_S1_Concept_Check,Supp_Complaint,Plant_Raw_Mat_Plan,SC_S1_Supp_Requirement,Packaging_Requirement,Packaging_Req_Met,Mode_Requirement,
								Mode_Requirement_Met,Import_License_Required,Proc_Trial_Required,Total_Qty_Need,Plant_Tech_Contact,Intermediate_Dest,QA_S1_Supp_Requirement,COA_PPK_Data_Need,Beyond_Spec_Data_Need,
								Plant_Spec_Requirement,Other_Trial_Required,Trial_Desc,Trial_Treatment,Dipped_Fabric_Width,Spool_Length,Spool_Type,VPS_Template,Proc_Vol_Trial_Duration,Product_Group_Id,Tech_Req_Data_Need,
								GD_Spec_Same,GD_Test_Method_Same,Supp_Spec_Need,Supp_Test_Method_Need,GMS_S2_Test_Requirement,Tire_Qty_Per_Trial,Tire_SKU_Trial,Plant_Vol_Need,Yarn_Type,Construction,Twist,
								Total_Ends,EPI,Treatment_Width,GY_Supp_Spec_Diff,Supp_Cap_GY_Req,Supp_Sign,PS_S1_Supp_Requirement,SDS_Needed,SDS_Received,SDS_Ok,CIRF_Needed,CIRF_Received,REACH_INV_Status_Ok,HAPFree_Letter_Needed,
								EHS_Proc_QS_Needed,Plant_HSE_Review,Other_Consideration,Region_Code,Country_Code,Location_Id,Is_Best_Proj_Nom,Is_Deleted_Ind,Created_Date,Created_By,Last_Modified_Date,Last_Modified_By,Ref_Idea_Id
							)
							VALUES
							(
								@_vSequence_number,@_vName,@_vSystem_start_date,@_vMaterial_Cat_Id,@_vMaterial_Id,@_vMaterial_Group_Id,@_vProgram_Id,@_vPlant_Trial_Id,@_vValue_Date,@_vCode_Name,@_vXCode,@_vMaterial_Trade_Name,
								@_vARD#,@_vNetwork_#,@_vUnique_#,@_vMISVPS_#,@_vVPS_Scheduled_Date,@_vVSDS_number_,@_vSupplier_Company_Name,@_vSupplier_Plant_Location,@_vSupplier_Contact_Name,@_vSupplier_Email,@_vSupplier_Phone_#,
								@_vAgent_Company_Name,@_vAgent_Contact_Name,@_vAgent_Email,@_vAgent_Phone_Number,@_vLead_Time_for_Process_Trial_Material_No_of_days,--@_vPTM_Lead_Time,
								@_vCSIS_#,@_vVendor_Code,@_vDoes_Supplier_have_Required_Import_Documentation,@_vWill_the_supplier_ship_all_material_at_once,@_vComments,@_vSIS_Material_Code_New_Supplier_,@_vSupplier_requirements_accepted,
								@_vIf_no_note_supplier_requirements_exceptions,@_vProject_Leader_Concept_Check,@_vSQA_Stage_1_Supplier_Requirements,@_vSQA_Stage_1_Concept_Check,@_vSupplier_compliant_in_SIS,@_vPlant_Raw_Material_Planner,
								@_vSupply_Chain_Stage_1_Supplier_Requirements,@_vPackaging_Requirements,@_vSupplier_meets_packaging_requirement,--@_vPackaging_Req_Met,
								@_vMode_Requirements,@_vSupplier_meets_mode_requirement,--@_vMode_Requirement_Met,
								@_vImport_License_Required,@_vProcessing_trial_required,@_vTotal_quantity_needed_units,@_vPlant_Technical_Contact,@_vIntermediary_Destination_if_Applicable,@_vQuality_Stage_1_Supplier_Requirements,
								@_vCOA_ppk_data_needed_,@_vData_needs_beyond_the_specification,@_vPlant_Specific_Requirements,@_vAre_there_other_trials_that_require_this_material,@_vIf_yes_what_trials,--@_vTrials,
								@_vCompound_Treatment_for_trial,--@_vTrial_Treatment,
								@_vDipped_Fabric_Width,@_vSpool_Length,@_vSpool_Type,@_vVPS_Template,@_vProcessing_and_Volume_trial_durations,@_vProduct_Group_Id,@_vDescribe_any_technical_requirements_or_data_needs_,@_vGoodyear_specification_sent,
								@_vGoodyear_test_methods_sent,@_vSupplier_specification_needed,@_vDiff_bw_GY_Supplier_Specs_or_test_methods,--@_vSupplier_Test_Method_Need,
								@_vGMS_Stage_2_Testing_Requirements,@_vQTY_of_Tires_per_Trial,@_vTire_SKU_for_trial,@_vPlant_volume_trial_needed,@_vYarn_Type,@_vConstruction_dtex,@_vTwist,@_vTotal_Ends,@_vEPI,
								@_vTreatment_Width_suffix,@_vDiff_bw_GY_Supplier_Specs_or_test_methods,@_vSupplier_is_capable_to_meet_Goodyear_requirements,@_vHas_supplier_signed_the_specification,--@_vSupp_Sign,
								@_vProduct_Stewardship_Stage_1_Supplier_Requirements,@_vSDS_Needed,@_vSDS_Received,@_vSDS_Ok,@_vCIRF_Needed,@_vCIRF_Received,@_vREACH_andor_Inventory_Status_OK,@_vHAP_free_letter_needed,@_vEHS_Process_Questions_needed,
								@_vPlant_HSE_Review,@_vOther_Considerations,@_vRegion_Code,@_vCountry_Code,@_vLocation_Id,'N','N',@_vSystem_start_date,@_vCreated_By,@_vSystem_start_date,@_vCreated_By,NULL
							)

							SELECT @_vQTI_Id=NULL
							SELECT @_vQTI_Id=@@IDENTITY

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
											'RD',
											@_vQTI_Id,
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

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_QTI_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL
								

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
					FROM Temp_QTI_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='RD' AND Deliverable_Name IS NULL


					
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
													FROM Temp_QTI_Gate_Deliverable TDGD 
													INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
													INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
													AND	LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
													WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
													AND TDGD.Work_Type='Deliverable'
													AND GGD.WT_Code='RD'
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
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'RD' AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT TOP 1 GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIm(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM Temp_QTI_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND	LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
													WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
													AND TDGD.Work_Type='Deliverable'
													AND GGD.WT_Code='RD'
													AND EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIm(RTRIM(TDGD.Project_Lead)))
													Order by GGD.Deliverable_Default_Order

											SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
										END
								END /*End Gate Loop*/


								/* Add Project Member*/

								SELECT @_vProject_Member_Id = NULL

							PRINT @_vSequence_number

							DELETE FROM @_vProjectMember_Table
								
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead',@_vProject_Lead
	
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Global Material Science Managers',LTRIM(RTRIM(TDR.Global_Material_Science_Manager)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
									
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Global Procurement Category Manager',LTRIM(RTRIM(TDR.Global_Procurement_Category_Manager)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
								
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Global Procurement Finance Managers',LTRIM(RTRIM(TDR.Global_Procurement_Finance_Manager)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Global Product Stewardship Managers',LTRIM(RTRIM(TDR.Global_Product_Stewardship_Manager)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 
								
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Supplier Development Managers',LTRIM(RTRIM(TDR.Supplier_Development_Manager)) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_QTI_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
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
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='RD' AND WT_Role_Name=@_vWT_Role_Name),
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

											INSERT INTO Temp_QTI_MissingRoleMember_Error
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

					END
					FETCH NEXT FROM QTI_Cursor INTO @_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,
						@_vWork_Template,@_vWork_type,@_vComments,@_vConsequential_Metric,@_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,
						@_vProblem_Statement,@_vProject_Scope_and_Scale,@_vSecondary_Metric,@_vLoss_Opportunity,@_vLoss_Opportunity_raw,@_vAgent_Company_Name,@_vAgent_Contact_Name,@_vAgent_Email,@_vAgent_Phone_Number,
						@_vARD#,@_vAre_there_other_trials_that_require_this_material,@_vCIRF_Needed,@_vCIRF_Received,@_vCOA_ppk_data_needed_,@_vCode_Name,@_vComments_Deliverable,@_vCompound_Treatment_for_trial,
						@_vConstruction_dtex,@_vCSIS_#,@_vData_needs_beyond_the_specification,@_vDescribe_any_technical_requirements_or_data_needs_,@_vDiff_bw_GY_Supplier_Specs_or_test_methods,@_vDipped_Fabric_Width,
						@_vDoes_Supplier_have_Required_Import_Documentation,@_vEHS_Process_Questions_needed,@_vEPI,@_vGMS_Stage_2_Testing_Requirements,@_vGoodyear_specification_sent,@_vGoodyear_test_methods_sent,@_vHAP_free_letter_needed,
						@_vHas_supplier_signed_the_specification,@_vIf_no_note_supplier_requirements_exceptions,@_vIf_yes_what_trials,@_vImport_License_Required,@_vIntermediary_Destination_if_Applicable,@_vLead_Time_for_Process_Trial_Material_No_of_days,
						@_vMaterial_Trade_Name,@_vMISVPS_#,@_vMode_Requirements,@_vNetwork_#,@_vOther_Considerations,@_vPackaging_Requirements,@_vPlant_HSE_Review,@_vPlant_Raw_Material_Planner,@_vPlant_Specific_Requirements,
						@_vPlant_Technical_Contact,@_vPlant_volume_trial_needed,@_vProcessing_and_Volume_trial_durations,@_vProcessing_trial_required,@_vProduct_Stewardship_Stage_1_Supplier_Requirements,@_vProject_Leader_Concept_Check,
						@_vQTY_of_Tires_per_Trial,@_vQTY_of_Tires_per_Trial_raw,@_vQuality_Stage_1_Supplier_Requirements,@_vREACH_andor_Inventory_Status_OK,@_vSDS_Needed,@_vSDS_OK,@_vSDS_Received,@_vSIS_Material_Code_New_Supplier_,
						@_vSpool_Length,@_vSpool_Type,@_vSQA_Stage_1_Concept_Check,@_vSQA_Stage_1_Supplier_Requirements,@_vSupplier_Company_Name,@_vSupplier_compliant_in_SIS,@_vSupplier_Contact_Name,@_vSupplier_Email,
						@_vSupplier_is_capable_to_meet_Goodyear_requirements,@_vSupplier_meets_mode_requirement,@_vSupplier_meets_packaging_requirement,@_vSupplier_Phone_#,@_vSupplier_Plant_Location,@_vSupplier_requirements_accepted,
						@_vSupplier_specification_needed,@_vSupply_Chain_Stage_1_Supplier_Requirements,@_vTire_SKU_for_trial,@_vTotal_Ends,@_vTotal_quantity_needed_units,@_vTreatment_Width_suffix,
						@_vTwist,@_vUnique_#,@_vValue_Date,@_vValue_Date_raw,@_vVendor_code,@_vVPS_Scheduled_Date,@_vVPS_Scheduled_Date_raw,@_vVPS_template,@_vVSDS_number_,@_vWill_the_supplier_ship_all_material_at_once,@_vXcode,@_vYarn_Type
			END
			CLOSE QTI_Cursor;
			DEALLOCATE QTI_Cursor;
			IF CURSOR_STATUS('global','QTI_Cursor')>=-1
			BEGIN
				DEALLOCATE QTI_Cursor
			END
 
END