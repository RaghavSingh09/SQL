
BEGIN
DECLARE @_vName VARCHAR(2000)
DECLARE @_vPowerSteering_ID VARCHAR(2000)
DECLARE @_vSequence_number VARCHAR(2000)
DECLARE @_vProject_Lead VARCHAR(2000)
DECLARE @_vSystem_start_date VARCHAR(2000)
DECLARE @_vActive_phase VARCHAR(2000)
DECLARE @_vSystem_end_date VARCHAR(2000)
DECLARE @_vStatus VARCHAR(2000)
DECLARE @_vWork_Template VARCHAR(2000)
DECLARE @_vWork_type VARCHAR(2000)
DECLARE @_vComments VARCHAR(4000)
DECLARE @_vConsequential_Metric VARCHAR(2000)
DECLARE @_vExpected_Benefits VARCHAR(8000)
DECLARE @_vExpected_Total_Savings_in_$ VARCHAR(2000)
DECLARE @_vExpected_Total_Savings_in_$_raw VARCHAR(2000)
DECLARE @_vGoal_Statement VARCHAR(4000)
DECLARE @_vPrimary_Metric_and_Current_Performance VARCHAR(4000)
DECLARE @_vProblem_Statement VARCHAR(4000)
DECLARE @_vProject_Scope_and_Scale VARCHAR(4000)
DECLARE @_vSecondary_Metric VARCHAR(2000)
DECLARE @_vBaseline VARCHAR(2000)
DECLARE @_vLoss_Opportunity VARCHAR(2000)
DECLARE @_vLoss_Opportunity_raw VARCHAR(2000)
DECLARE @_vMeasures_of_Success VARCHAR(2000)
DECLARE @_vTarget VARCHAR(2000)
DECLARE @_vExpected_Savings_Other_Location_in_$ VARCHAR(2000)
DECLARE @_vExpected_Savings_Other_Location_in_$_raw VARCHAR(2000)
DECLARE @_vSolutions_description VARCHAR(4000)


--DECLARE @_vName varchar(2000)
--DECLARE @_vPowerSteering_ID varchar (2000)
--DECLARE @_vSequence_number varchar (2000)
--DECLARE @_vProject_Lead varchar (2000)
--DECLARE @_vStatus varchar (2000)
--DECLARE @_vSystem_start_date varchar (2000),
--DECLARE @_vWork_Template varchar (2000),
--DECLARE @_vWork_type varchar (2000),
DECLARE @_vTeam_Member varchar(2000)
DECLARE @_vMBB_FI_Expert varchar(2000)
DECLARE @_vBlack_Belt varchar(2000)
DECLARE @_vProcess_Owner varchar(2000)
DECLARE @_vSponsor varchar(2000)
DECLARE @_vFinancial_Rep varchar(2000)
DECLARE @_vMilliken_users varchar(2000)
DECLARE @_vPillar_Approver varchar(2000)
DECLARE @_vProject_Coach varchar(2000)
--DECLARE @_vActive_phase varchar (2000)
--DECLARE @_vSystem_end_date varchar (2000)
DECLARE @_vBest_Project_Nomination varchar(2000)
DECLARE @_vBusiness_Area varchar(2000)
DECLARE @_vCost_Category varchar(2000)
DECLARE @_vCountry varchar(2000)
DECLARE @_vDepartments varchar(2000)
DECLARE @_vFinance_BPO varchar(2000)
DECLARE @_vFinancial_Impact_Area varchar(2000)
DECLARE @_vLocation varchar(2000)
DECLARE @_vPlant_Optimization_pillar varchar(2000)
DECLARE @_vPrimary_Loss_Categories varchar(2000)
DECLARE @_vProduct_Category varchar(2000)
DECLARE @_vProject_Allocation varchar(2000)
DECLARE @_vProject_Category varchar(2000)
DECLARE @_vProject_Codification varchar(2000)
DECLARE @_vProject_Main_Category varchar(2000)
DECLARE @_vRegions varchar(2000)
DECLARE @_vSub_Cost_Categories varchar(2000)
DECLARE @_vBusinessUnit varchar(2000)
DECLARE @_vExpected_Savings_Other_Location varchar(2000)
DECLARE @_vGBS_department varchar(2000)
DECLARE @_vGBS_Project_Category varchar(2000)
DECLARE @_vGBS_Project_Type varchar(2000)
DECLARE @_vGBS_Served_Geographies varchar(2000)

DECLARE @_vGBS_Id INT
DECLARE @_vWT_Project_Id INT
DECLARE @_vBA_Id INT
DECLARE @_vCost_Cat_Id INT
DECLARE @_vCountry_Code VARCHAR(3)
DECLARE @_vDept_ID INT
DECLARE @_vFN_BPO_ID INT
DECLARE @_vFin_Impact_Ar_Id INT
DECLARE @_vLocation_ID INT
--DECLARE @_vPiller_Name VARCHAR(8000)
DECLARE @_vPrim_Loss_Cat_Id INT
DECLARE @_vProduct_Cat_Id INT
DECLARE @_vProj_Main_Cat_Id INT
DECLARE @_vProj_Cat_Id INT
DECLARE @_vProject_Codification_Id INT
DECLARE @_vRegion_Code VARCHAR(5)
DECLARE @_vSub_Cost_Cat_Id INT
DECLARE @_vGbs_Buss_Unit_Id INT
DECLARE @_vGbs_ExpSV_Loc_Id INT
DECLARE @_vGbs_Dept_Id INT
DECLARE @_vGbs_Proj_Cat_Id INT
DECLARE @_vGbs_Proj_Type_Id INT
DECLARE @_vGbs_Geography_Id INT


--DECLARE @_vPiller_Name_Table AS Table(Piller_Name VARCHAR(500))

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

DECLARE @_vGBS_Geography_Table AS Table(Gbs_Geography_Desc VARCHAR(2000))
DECLARE @_vGbs_Geography_Name VARCHAR(8000)


TRUNCATE TABLE Temp_GBS_Error
TRUNCATE TABLE Temp_GBS_MissingRoleMember_Error
TRUNCATE TABLE Temp_GBS_Gate_Deliverable_Error

--TRUNCATE TABLE GPM_WT_Project_TDC_Saving
--TRUNCATE TABLE GPM_WT_Project_TDC_Saving_Baseline
--TRUNCATE TABLE GPM_WT_Project_Deliverable
--TRUNCATE TABLE GPM_WT_Project_Team
--TRUNCATE TABLE GPM_WT_Project_Team_Deliverable
--TRUNCATE TABLE GPM_WT_Project_Gate

--DELETE FROM GPM_WT_Project
DELETE FROM GPM_WT_GBS_MS_Attrib
DELETE FROM GPM_WT_GBS

SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='GBP'  AND Is_Deleted_Ind='N'


DECLARE GBS_Cursor CURSOR FOR
	SELECT	Name,
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
			Baseline,
			Loss_Opportunity,
			Loss_Opportunity_raw,
			Measures_of_Success,
			Target,
			Expected_Savings_Other_Location_in_$,
			Expected_Savings_Other_Location_in_$_raw,
			Solutions_description
	FROM Temp_GBS_Custom_Fields
	--WHERE Sequence_number='GBP-00330'


	

	OPEN GBS_Cursor

	FETCH NEXT FROM GBS_Cursor INTO
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
			@_vExpected_Savings_Other_Location_in_$,
			@_vExpected_Savings_Other_Location_in_$_raw,
			@_vSolutions_description


			WHILE @@FETCH_STATUS = 0
       
			BEGIN

					SELECT
					@_vValidData = 'TRUE',
					--@_vTeam_Member = NULL,
					--@_vMBB_FI_Expert = NULL,
					--@_vBlack_Belt = NULL,
					--@_vProcess_Owner = NULL,
					--@_vSponsor = NULL,
					--@_vFinancial_Rep = NULL,
					--@_vMilliken_users = NULL,
					--@_vPillar_Approver = NULL,
					--@_vProject_Coach = NULL,
					@_vBest_Project_Nomination = NULL,
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
					@_vBusinessUnit = NULL,
					@_vExpected_Savings_Other_Location = NULL,
					@_vGBS_department = NULL,
					@_vGBS_Project_Category = NULL,
					@_vGBS_Project_Type = NULL,
					@_vGBS_Served_Geographies = NULL,

					@_vBA_Id = NULL,
					@_vCost_Cat_Id = NULL,
					@_vCountry_Code = NULL,
					@_vDept_ID = NULL,
					@_vFN_BPO_ID = NULL,
					@_vFin_Impact_Ar_Id = NULL,
					@_vLocation_ID = NULL,
					--@_vPiller_Name = NULL,
					@_vGbs_Geography_Name = NULL,
					@_vPrim_Loss_Cat_Id = NULL,
					@_vProduct_Cat_Id = NULL,
					@_vProj_Main_Cat_Id = NULL,
					@_vProj_Cat_Id = NULL,
					@_vRegion_Code = NULL,
					@_vSub_Cost_Cat_Id = NULL,
					@_vGbs_Buss_Unit_Id = NULL,
					@_vGbs_ExpSV_Loc_Id = NULL,
					@_vGbs_Dept_Id = NULL,
					@_vGbs_Proj_Cat_Id = NULL,
					@_vGbs_Proj_Type_Id = NULL,
					@_vGbs_Geography_Id = NULL,
					@_vStatus_Id= NULL

					--DELETE FROM @_vPiller_Name_Table

					SELECT 
					@_vBest_Project_Nomination = Best_Project_Nomination,
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
					@_vBusinessUnit = BusinessUnit,
					@_vExpected_Savings_Other_Location = Expected_Savings_Other_Location,
					@_vGBS_department = GBS_department,
					@_vGBS_Project_Category = GBS_Project_Category,
					@_vGBS_Project_Type = (CASE WHEN LTRIM(RTRIM(GBS_Project_Type))='C1- FTE Efficiency â€“ Headcount reduction' THEN 'C1- FTE Efficiency – Headcount reduction' ELSE GBS_Project_Type END),
					@_vGBS_Served_Geographies = GBS_Served_Geographies
					FROM Temp_GBS_RoleAndTags WHERE Sequence_number=@_vSequence_number

					
					SELECT @_vBA_Id=BA_Id FROM GPM_Business_Area WHERE RTRIM(LTRIM(BA_Name))=RTRIM(LTRIM(@_vBusiness_Area))
					SELECT @_vCost_Cat_Id=Cost_Cat_Id FROM GPM_Cost_Category WHERE RTRIM(LTRIM(Cost_Cat_Desc))=RTRIM(LTRIM(@_vCost_Category)) 
					SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
					SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry))
					SELECT @_vDept_Id=Dept_ID FROM GPM_Department WHERE RTRIM(LTRIM(Dept_Name))=RTRIM(LTRIM(@_vDepartments)) AND BA_Id=@_vBA_Id
					SELECT @_vFN_BPO_Id=FN_BPO_ID FROM GPM_Finance_BPO WHERE RTRIM(LTRIM(FN_BPO_Name))=RTRIM(LTRIM(@_vFinance_BPO)) AND BA_Id=@_vBA_Id AND Dept_ID=@_vDept_ID
					SELECT @_vFin_Impact_Ar_Id=Fin_Impact_Ar_Id FROM GPM_Finance_Impact_Area WHERE RTRIM(LTRIM(Fin_Impact_Ar_Desc))=RTRIM(LTRIM(@_vFinancial_Impact_Area)) 
					SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
					SELECT @_vPrim_Loss_Cat_Id=Prim_Loss_Cat_Id FROM GPM_Primary_Loss_Category WHERE RTRIM(LTRIM(Prim_Loss_Cat_Desc))=RTRIM(LTRIM(@_vPrimary_Loss_Categories)) 
					SELECT @_vProduct_Cat_Id=Product_Cat_Id FROM GPM_Product_Category WHERE RTRIM(LTRIM(Product_Cat_Desc))=RTRIM(LTRIM(@_vProduct_Category))
					SELECT @_vProj_Main_Cat_Id=Proj_Main_Cat_Id FROM GPM_Proj_Main_Category WHERE RTRIM(LTRIM(Proj_Main_Cat_Desc))=RTRIM(LTRIM(@_vProject_Main_Category))
					SELECT @_vProj_Cat_Id=Proj_Cat_Id FROM GPM_Proj_Category WHERE RTRIM(LTRIM(Proj_Cat_Desc))=RTRIM(LTRIM(@_vProject_Category)) AND Proj_Main_Cat_Id=@_vProj_Main_Cat_Id
					SELECT @_vProject_Codification_Id=Project_Codification_Id FROM GPM_Project_Codification WHERE RTRIM(LTRIM(Project_Codification_Desc))=RTRIM(LTRIM(@_vProject_Codification))
					SELECT @_vSub_Cost_Cat_Id= Sub_Cost_Cat_Id FROM GPM_Sub_Cost_Category WHERE RTRIM(LTRIM(Sub_Cost_Cat_Desc))=RTRIM(LTRIM(@_vSub_Cost_Categories)) AND Fin_Impact_Ar_Id=@_vFin_Impact_Ar_Id AND Cost_Cat_Id=@_vCost_Cat_Id
					SELECT @_vGbs_Dept_Id= Gbs_Dept_Id FROM GPM_GBS_Department WHERE RTRIM(LTRIM(Gbs_Dept_Name))=RTRIM(LTRIM(@_vGBS_department)) 
					SELECT @_vGbs_Buss_Unit_Id= Gbs_Buss_Unit_Id FROM GPM_GBS_Business_Unit WHERE RTRIM(LTRIM(Gbs_Buss_Unit_Desc))=RTRIM(LTRIM(@_vBusinessUnit))  AND Gbs_Dept_Id=@_vGbs_Dept_Id
					SELECT @_vGbs_Proj_Cat_Id=Gbs_Proj_Cat_Id FROM GPM_GBS_Project_Category WHERE RTRIM(LTRIM(Gbs_Proj_Cat_Desc))=RTRIM(LTRIM(@_vGBS_Project_Category)) 
					SELECT @_vGbs_Proj_Type_Id=Gbs_Proj_Type_Id FROM GPM_GBS_Project_Type WHERE RTRIM(LTRIM(Gbs_Proj_Type_Desc))=RTRIM(LTRIM(@_vGBS_Project_Type)) 
					SELECT @_vGbs_Geography_Id=Gbs_Geography_Id FROM GPM_GBS_Geography WHERE RTRIM(LTRIM(Gbs_Geography_Desc))=RTRIM(LTRIM(@_vGBS_Served_Geographies))
					SELECT @_vGbs_ExpSV_Loc_Id=Gbs_ExpSV_Loc_Id FROM GPM_GBS_ExpSaving_Loc WHERE RTRIM(LTRIM(Gbs_ExpSV_Loc_Desc))=RTRIM(LTRIM(@_vExpected_Savings_Other_Location))
					SELECT @_vStatus_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
					SELECT @_vCreated_By=GD_User_Id FROM GPM_USer WHERE User_First_Name +' '+User_Last_Name = RTRIM(LTRIM(@_vProject_Lead))

					

					SELECT @_vTempGateCnt=0
			
					SELECT @_vError_Desc=''

					--DELETE FROM @_vPiller_Name_Table

					--SELECT @_vPiller_Name=NULL

					DELETE FROM @_vGBS_Geography_Table

					

					IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : GBS Name Is Blank'
						SELECT @_vValidData='FALSE'
					END

					IF(@_vSystem_start_date IS NULL)
					BEGIN
						SELECT @_vError_Desc += '|MA : Planned Start Date Is Blank'
						SELECT @_vValidData='FALSE'
					END

					IF(@_vStatus IS NULL OR LEN(LTRIM(RTRIM(@_vStatus)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Status Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vStatus_Id IS NULL OR  @_vStatus_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA :'+ @_vStatus +' Status Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				

					IF(@_vProblem_Statement IS NULL OR LEN(RTRIM(LTRIM(@_vProblem_Statement)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Problem Statement Is Blank'
						SELECT @_vValidData='FALSE'
					END

					IF(@_vGoal_Statement IS NULL OR LEN(RTRIM(LTRIM(@_vGoal_Statement)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Goal Statement Is Blank'
						SELECT @_vValidData='FALSE'
					END

					IF(@_vGBS_Project_Type IS NULL OR LEN(RTRIM(LTRIM(@_vGBS_Project_Type)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : GBS Project Type Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vGbs_Proj_Type_Id IS NULL OR @_vGbs_Proj_Type_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA :'+ @_vGBS_Project_Type +' GBS Project Type Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END



					IF(@_vGBS_Project_Category IS NULL OR LEN(RTRIM(LTRIM(@_vGBS_Project_Category)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : GBS Project Category Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vGbs_Proj_Cat_Id IS NULL OR @_vGbs_Proj_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA :'+ @_vGBS_Project_Category +' GBS Project Category Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
					
					/*
					IF(@_vGBS_Served_Geographies IS NULL OR LEN(RTRIM(LTRIM(@_vGBS_Served_Geographies)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : GBS Served Geographies Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vGbs_Geography_Id IS NULL OR @_vGbs_Geography_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA :'+ @_vGBS_Served_Geographies +' GBS Served Geographies Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
					*/
					
					IF(@_vGBS_department IS NULL OR LEN(RTRIM(LTRIM(@_vGBS_department)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : GBS department Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vGbs_Dept_Id IS NULL OR @_vGbs_Dept_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA :'+ @_vGBS_department +' GBS department Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END

					IF(@_vRegions IS NULL OR LEN(LTRIM(RTRIM(@_vRegions)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Regions Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vRegion_Code IS NULL OR LEN(LTRIM(RTRIM(@_vRegion_Code)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : '+ @_vRegions +' Regions  Not Found In Master Data'
						SELECT @_vValidData='FALSE'
					END


					IF(@_vCountry IS NULL OR LEN(LTRIM(RTRIM(@_vCountry)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Country Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vCountry_Code IS NULL OR LEN(LTRIM(RTRIM(@_vCountry_Code)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : '+ @_vCountry +' Country  Not Found In Master Data'
						SELECT @_vValidData='FALSE'
					END


					IF(@_vLocation IS NULL OR LEN(LTRIM(RTRIM(@_vLocation)))<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : Location Is Blank'
						SELECT @_vValidData='FALSE'
					END
					ELSE
					IF(@_vLocation_Id IS NULL OR @_vLocation_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|MA : '+ @_vLocation +' Location Not Found In Master Data'
						SELECT @_vValidData='FALSE'
					END

				/*
				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
				IF(@_vProject_Lead IS NOT NULL AND LEN(LTRIM(RTRIM(@_vProject_Lead)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vProject_Lead

					
				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : Project Lead Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : '+ @_vProject_Lead +' Project Lead Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vSponsor=NULL

				SELECT @_vSponsor=LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
				IF(@_vSponsor IS NOT NULL AND LEN(LTRIM(RTRIM(@_vSponsor)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vSponsor

				IF(@_vSponsor IS NULL OR LEN(LTRIM(RTRIM(@_vSponsor)))<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : Sponsor Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : '+ @_vSponsor +' Sponsor Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vFinancial_Rep=NULL

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				IF(@_vFinancial_Rep IS NOT NULL AND LEN(LTRIM(RTRIM(@_vFinancial_Rep)))>0)
					SELECT @_vProject_Member_Id=GU.GD_User_Id FROM GPM_User GU WHERE GU.User_First_Name +' '+GU.User_Last_Name = @_vFinancial_Rep

				IF(@_vFinancial_Rep IS NULL OR LEN(LTRIM(RTRIM(@_vFinancial_Rep)))<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : Financial Rep Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '|MA : '+ @_vFinancial_Rep +' Financial_Rep Not Found In User table'
					SELECT @_vValidData='FALSE'
				END
				*/

				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Project_Lead)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


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

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Financial_Rep)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

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

				SELECT @_vSponsor=LTRIM(RTRIM(TDR.Sponsor)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

				
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

				IF EXISTS(
					SELECT COUNT(*) FROM Temp_GBS_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
				
					SELECT @_vError_Desc += '| Duplicate Gate Found '
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_GBS_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_GBS_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='GBP' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END


				END


				/*Validate Non Mandatory Attribute*/

				IF(LEN(LTRIM(RTRIM(@_vFinance_BPO)))>0)
				BEGIN
					IF(@_vFN_BPO_ID IS NULL OR  @_vFN_BPO_ID<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vFinance_BPO +' Finance BPO Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END

				IF(LEN(LTRIM(RTRIM(@_vFinancial_Impact_Area)))>0)
				BEGIN
					IF(@_vFin_Impact_Ar_Id IS NULL OR  @_vFin_Impact_Ar_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vFinancial_Impact_Area +' Financial Impact_Area Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END

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

				IF(LEN(LTRIM(RTRIM(@_vProject_Main_Category)))>0)
				BEGIN
					IF(@_vProj_Main_Cat_Id IS NULL OR  @_vProj_Main_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vProject_Main_Category +' Project Main Category Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END
				

				IF(LEN(LTRIM(RTRIM(@_vProject_Category)))>0)
				BEGIN
					IF(@_vProj_Cat_Id IS NULL OR  @_vProj_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vProject_Category +' Project Category Not Found in DB Master Data'
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

				IF(LEN(LTRIM(RTRIM(@_vSub_Cost_Categories)))>0)
				BEGIN
					IF(@_vSub_Cost_Cat_Id IS NULL OR  @_vSub_Cost_Cat_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vSub_Cost_Categories +' Sub Cost Categories Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END

				IF(LEN(LTRIM(RTRIM(@_vBusinessUnit)))>0)
				BEGIN
					IF(@_vGbs_Buss_Unit_Id IS NULL OR  @_vGbs_Buss_Unit_Id<=0)
					BEGIN
						SELECT @_vError_Desc += '|NMA :'+ @_vBusinessUnit +' GBS Business Unit Not Found in DB Master Data'
						SELECT @_vValidData='FALSE'
					END
				END

				
				INSERT INTO @_vGBS_Geography_Table(Gbs_Geography_Desc)
				SELECT Value FROM dbo.Fn_SplitDelimetedData(CHAR(10), @_vGBS_Served_Geographies) WHERE LEN(LTRIM(RTRIM(Value)))>0

	
				SET @_vGbs_Geography_Name=(SELECT ','+TGGD.Gbs_Geography_Desc FROM @_vGBS_Geography_Table TGGD WHERE NOT EXISTS(SELECT 1 FROM GPM_GBS_Geography GGWM 
													WHERE GGWM.Gbs_Geography_Desc=TGGD.Gbs_Geography_Desc) FOR XML PATH(''))

				SET @_vGbs_Geography_Name=SUBSTRING(@_vGbs_Geography_Name,2, LEN(@_vGbs_Geography_Name))

				IF(LEN(@_vGbs_Geography_Name)>0)
					BEGIN
						SELECT @_vError_Desc += '|MA : '+ @_vGbs_Geography_Name +' Gbs Served Geographies Not Found In Master Data'
						SELECT @_vValidData='FALSE'
					END
				

				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_GBS_Error
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

					INSERT INTO GPM_WT_GBS
					(
						GBS_Number,
						GBS_Name,
						Plan_Start_Date,
						Problem_Statement,
						Goal_Statement,
						Project_Metric_Cp,
						Gbs_ExpSv_OT_Loc_Id,
						Expected_Benefits,
						ExpSv_OT_Loc_USD,
						Expected_Saving_USD,
						Comments,
						Gbs_Proj_Type_Id,
						Gbs_Proj_Cat_Id,
						Dept_Id,
						Gbs_Buss_Unit_Id,
						Region_Code,
						Country_Code,
						Location_Id,
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
						@_vSequence_number,
						@_vName,
						@_vSystem_start_date,
						@_vProblem_Statement,
						@_vGoal_Statement,
						@_vPrimary_Metric_and_Current_Performance,
						@_vGbs_ExpSV_Loc_Id,
						@_vExpected_Benefits,
						CASE WHEN LEN(LTRIM(RTRIM(@_vExpected_Savings_Other_Location_in_$)))>0 THEN
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vExpected_Savings_Other_Location_in_$,'$',''),',','') ,')',''),'(',''),' ','')
						ELSE NULL END,
						CASE WHEN LEN(LTRIM(RTRIM(@_vExpected_Total_Savings_in_$)))>0 THEN
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vExpected_Total_Savings_in_$,'$',''),',','') ,')',''),'(',''),' ','')
						ELSE NULL END,
						@_vComments,
						@_vGbs_Proj_Type_Id,
						@_vGbs_Proj_Cat_Id,
						@_vGbs_Dept_Id,
						@_vGbs_Buss_Unit_Id,
						@_vRegion_Code,
						@_vCountry_Code,
						@_vLocation_Id,
						NULL,
						'N',
						'N',
						@_vSystem_start_date,
						@_vCreated_By,
						@_vSystem_start_date,
						@_vCreated_By
 
					)


					SELECT @_vGBS_Id=NULL
					SELECT @_vGBS_Id=@@IDENTITY


				  INSERT INTO GPM_WT_GBS_MS_Attrib(
							GBS_Id,
							GBS_Number,
							Gbs_Geography_Id,
							Created_Date,
							Created_By,
							Last_Modified_Date,
							Last_Modified_By
						)
				SELECT
							@_vGBS_Id,
							RTRIM(LTRIM(@_vSequence_number)),
							GPOP.Gbs_Geography_Id,
							@_vSystem_start_date,
							@_vCreated_By,
							@_vSystem_start_date,
							@_vCreated_By
					FROM   @_vGBS_Geography_Table TAB INNER JOIN GPM_GBS_Geography GPOP On RTRIM(LTRIM(Tab.Gbs_Geography_Desc))=GPOP.Gbs_Geography_Desc


					
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
						'GBP',
						@_vGBS_Id,
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

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_GBS_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL


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
					FROM Temp_GBS_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='GBP' AND UPPER(TDGA.Work_type)='GATE'



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
															FROM Temp_GBS_Gate_Deliverable TDGD INNER JOIN GPM_Gate_Deliverable GGD 
															On 
													
													-- Case used when flat file Deliverable_Name  is not matching with Master table Deliverable_Name 
															
															(CASE WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 1' THEN 'Month 1 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 2' THEN 'Month 2 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 3' THEN 'Month 3 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 4' THEN 'Month 4 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 5' THEN 'Month 5 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 6' THEN 'Month 6 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 7' THEN 'Month 7 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 8' THEN 'Month 8 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 9' THEN 'Month 9 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 10' THEN 'Month 10 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 11' THEN 'Month 11 - Savings Input (Act+Fcst)'
																  WHEN LTRIM(RTRIM(TDGD.Deliverable_Name)) = 'Savings Month 12' THEN 'Month 12 - Savings Input (Act+Fcst)'
																else 
																	LTRIM(RTRIM(TDGD.Deliverable_Name))
															END)=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable' Order by GGD.Deliverable_Default_Order


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
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'GBP' AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT TOP 1 GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM	Temp_GBS_Gate_Deliverable TDGD INNER JOIN GPM_Gate_Deliverable GGD 
															On LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable' 
															AND EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead)))
															Order by GGD.Deliverable_Default_Order

											SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
										END
								END /*End Gate Loop*/

			
						/* Add Project Member*/

							SELECT @_vProject_Member_Id = NULL

							PRINT @_vSequence_number

							DELETE FROM @_vProjectMember_Table

							INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Lead',LTRIM(RTRIM(@_vProject_Lead))

							INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
								SELECT 'Sponsor', LTRIM(RTRIM(@_vSponsor))

							INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Financial Rep',LTRIM(RTRIM(@_vFinancial_Rep))


							INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Project Coach',LTRIM(RTRIM(TDR.Project_Coach)) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


									INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_GBS_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
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
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='GBP' AND WT_Role_Name=@_vWT_Role_Name),
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

											INSERT INTO Temp_GBS_MissingRoleMember_Error
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
							INSERT INTO GPM_WT_Project_GBS_Saving_ActFcst
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
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
							AND TDC.TDC_Type='Act + Fcst'
							

							INSERT INTO GPM_WT_Project_GBS_Saving_Baseline
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
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
							AND TDC.TDC_Type='Baseline'

							

							INSERT INTO GPM_WT_Project_GBS_Saving_OtherLoc
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
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE RTRIM(LTRIM(TDC.Sequence_number))=@_vSequence_number AND GMTS.Is_Computed_Attrib='N'
							AND TDC.TDC_Type='Act-Fcst Other Location'

							*/

				END

				FETCH NEXT FROM GBS_Cursor INTO
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
								@_vExpected_Savings_Other_Location_in_$,
								@_vExpected_Savings_Other_Location_in_$_raw,
								@_vSolutions_description

			END	


CLOSE GBS_Cursor;
DEALLOCATE GBS_Cursor;
IF CURSOR_STATUS('global','GBS_Cursor')>=-1
	BEGIN
	   DEALLOCATE GBS_Cursor
	END

END