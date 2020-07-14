BEGIN

DECLARE @_vName NVARCHAR(4000)
DECLARE @_vPowerSteering_ID NVARCHAR(4000)
DECLARE @_vSequence_number NVARCHAR(4000)
DECLARE @_vProject_Lead NVARCHAR(4000)
DECLARE @_vSystem_start_date NVARCHAR(4000)
DECLARE @_vActive_phase NVARCHAR(4000)
DECLARE @_vSystem_end_date NVARCHAR(4000)
DECLARE @_vStatus NVARCHAR(4000)
DECLARE @_vWork_Template NVARCHAR(4000)
DECLARE @_vWork_type NVARCHAR(4000)
DECLARE @_vComments NVARCHAR(4000)
DECLARE @_vConsequential_Metric NVARCHAR(4000)
DECLARE @_vExpected_Benefits NVARCHAR(4000)
DECLARE @_vExpected_Total_Savings_in_$ NVARCHAR(4000)
DECLARE @_vExpected_Total_Savings_in_$_raw NVARCHAR(4000)
DECLARE @_vGoal_Statement NVARCHAR(4000)
DECLARE @_vPrimary_Metric_and_Current_Performance NVARCHAR(4000)
DECLARE @_vProblem_Statement NVARCHAR(4000)
DECLARE @_vProject_Scope_and_Scale NVARCHAR(4000)
DECLARE @_vSecondary_Metric NVARCHAR(4000)
DECLARE @_vExpected_Material_Savings_in_$ NVARCHAR(4000)
DECLARE @_vExpected_Material_Savings_in_$_raw NVARCHAR(4000)
DECLARE @_vIdea_Description NVARCHAR(4000)
DECLARE @_vPayback_Time_in_month NVARCHAR(4000)
DECLARE @_vRequestor_Name_and_Contact_Info NVARCHAR(4000)
DECLARE @_vActual_start_date NVARCHAR(4000)
DECLARE @_vBaseline NVARCHAR(4000)
DECLARE @_vLoss_Opportunity NVARCHAR(4000)
DECLARE @_vLoss_Opportunity_raw NVARCHAR(4000)
DECLARE @_vMeasures_of_Success NVARCHAR(4000)
DECLARE @_vTarget NVARCHAR(4000)
DECLARE @_vAnalyze NVARCHAR(4000)
DECLARE @_vCapEx NVARCHAR(4000)
DECLARE @_vCapEx_ID_# NVARCHAR(4000)
DECLARE @_vControl NVARCHAR(4000)
DECLARE @_vDefine NVARCHAR(4000)
DECLARE @_vImprove NVARCHAR(4000)
DECLARE @_vMeasure NVARCHAR(4000)


DECLARE @_vIdea_Leader NVARCHAR(4000)
DECLARE @_vTeam_Member NVARCHAR(4000)
DECLARE @_vIdea_Approver NVARCHAR(4000)
DECLARE @_vSponsor NVARCHAR(4000)
DECLARE @_vFinancial_Rep NVARCHAR(4000)
DECLARE @_vBest_Project_Nomination NVARCHAR(4000)
DECLARE @_vBusiness_Area NVARCHAR(4000)
DECLARE @_vCost_Category NVARCHAR(4000)
DECLARE @_vCountry NVARCHAR(4000)
DECLARE @_vDepartments NVARCHAR(4000)
DECLARE @_vFinance_BPO NVARCHAR(4000)
DECLARE @_vFinancial_Impact_Area NVARCHAR(4000)
DECLARE @_vLocation NVARCHAR(4000)
DECLARE @_vPlant_Optimization_pillar NVARCHAR(4000)
DECLARE @_vPrimary_Loss_Categories NVARCHAR(4000)
DECLARE @_vProduct_Category NVARCHAR(4000)
DECLARE @_vProject_Allocation NVARCHAR(4000)
DECLARE @_vProject_Category NVARCHAR(4000)
DECLARE @_vProject_Codification NVARCHAR(4000)
DECLARE @_vProject_Main_Category NVARCHAR(4000)
DECLARE @_vRegions NVARCHAR(4000)
DECLARE @_vSub_Cost_Categories NVARCHAR(4000)
DECLARE @_vConstraints NVARCHAR(4000)
DECLARE @_vIdea_Feasibility NVARCHAR(4000)
DECLARE @_vRegional_Tracking_Category NVARCHAR(4000)
DECLARE @_vTW_Loss_Categories NVARCHAR(4000)

DECLARE @_vIdea_Id INT
DECLARE @_vRegion_Code VARCHAR(5)
DECLARE @_vCountry_Code VARCHAR(3)
DECLARE @_vLocation_Id INT
DECLARE @_vBA_Id INT
DECLARE @_vDept_Id INT
DECLARE @_vCost_Cat_Id INT
DECLARE @_vRegTrack_Cat_Id INT
DECLARE @_vPiller_Id INT
DECLARE @_vConstraint_Id INT
DECLARE @_vProj_Main_Cat_Id INT
DECLARE @_vProj_Cat_Id INT
DECLARE @_vPrim_Loss_Cat_Id INT
DECLARE @_vFN_BPO_ID INT
DECLARE @_vFeasibility_Id INT
DECLARE @_vTW_Loss_Cat_Id INT
DECLARE @_vIdea_Status_Id INT

DECLARE @_vStatus_Id INT
DECLARE @_vCreated_By VARCHAR(10)
DECLARE @_vWT_Project_Id INT

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

TRUNCATE TABLE Temp_IDEA_Error

TRUNCATE TABLE Temp_IDEA_MissingRoleMember_Error

DELETE FROM GPM_WT_IDEA_MS_Attrib

DELETE FROM GPM_WT_IDEA

SELECT @_vDBGateCnt=COUNT(*) FROM GPM_Gate_WT_Map WHERE WT_Code='IDEA'  AND Is_Deleted_Ind='N'

DECLARE IDEA_Cursor CURSOR FOR
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
			Expected_Material_Savings_in_$,
			Expected_Material_Savings_in_$_raw,
			Idea_Description,
			Payback_Time_in_month,
			Requestor_Name_and_Contact_Info,
			Actual_start_date,
			Baseline,
			Loss_Opportunity,
			Loss_Opportunity_raw,
			Measures_of_Success,
			Target,
			Analyze,
			CapEx,
			CapEx_ID_#,
			Control,
			Define,
			Improve,
			Measure
		FROM Temp_Idea_Custom_Fields

		OPEN IDEA_Cursor
			FETCH NEXT FROM IDEA_Cursor INTO @_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,@_vWork_Template,@_vWork_type,@_vComments,@_vConsequential_Metric,
											 @_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,@_vProblem_Statement,@_vProject_Scope_and_Scale,
											 @_vSecondary_Metric,@_vExpected_Material_Savings_in_$,@_vExpected_Material_Savings_in_$_raw,@_vIdea_Description,@_vPayback_Time_in_month,@_vRequestor_Name_and_Contact_Info,@_vActual_start_date,
											 @_vBaseline,@_vLoss_Opportunity,@_vLoss_Opportunity_raw,@_vMeasures_of_Success,@_vTarget,@_vAnalyze,@_vCapEx,@_vCapEx_ID_#,@_vControl,@_vDefine,@_vImprove,@_vMeasure

			WHILE @@FETCH_STATUS = 0
       
			BEGIN

				SELECT 
					@_vValidData = 'TRUE',
					@_vBest_Project_Nomination=NULL,
					@_vBusiness_Area=NULL,
					@_vCost_Category=NULL,
					@_vCountry=NULL,
					@_vDepartments=NULL,
					@_vFinance_BPO=NULL,
					@_vFinancial_Impact_Area=NULL,
					@_vLocation=NULL,
					@_vPlant_Optimization_pillar=NULL,
					@_vPrimary_Loss_Categories=NULL,
					@_vProduct_Category=NULL,
					@_vProject_Allocation=NULL,
					@_vProject_Category=NULL,
					@_vProject_Codification=NULL,
					@_vProject_Main_Category=NULL,
					@_vRegions=NULL,
					@_vSub_Cost_Categories=NULL,
					@_vConstraints=NULL,
					@_vIdea_Feasibility=NULL,
					@_vRegional_Tracking_Category=NULL,
					@_vTW_Loss_Categories=NULL,

					@_vIdea_Id=NULL,
					@_vRegion_Code=NULL,
					@_vCountry_Code=NULL,
					@_vLocation_Id=NULL,
					@_vBA_Id=NULL,
					@_vDept_Id=NULL,
					@_vCost_Cat_Id=NULL,
					@_vRegTrack_Cat_Id=NULL,
					@_vPiller_Id=NULL,
					@_vConstraint_Id=NULL,
					@_vProj_Main_Cat_Id=NULL,
					@_vProj_Cat_Id=NULL,
					@_vPrim_Loss_Cat_Id=NULL,
					@_vFN_BPO_ID=NULL,
					@_vFeasibility_Id=NULL,
					@_vTW_Loss_Cat_Id=NULL,
					@_vIdea_Status_Id=NULL

					SELECT 
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
						@_vCapEx = [Capex_Required],
						@_vConstraints = [Constraints],
						@_vIdea_Feasibility = [Feasibility_of_idea_],
						@_vRegional_Tracking_Category = [Regional_Tracking_Category],
						@_vTW_Loss_Categories = [TW_Loss_Categories]
					FROM Temp_Idea_RoleAndTags
					WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))


				SELECT @_vRegion_Code=Region_Code FROM GPM_Region WHERE RTRIM(LTRIM(Region_Code))=RTRIM(LTRIM(@_vRegions)) OR RTRIM(LTRIM(Region_Name))=RTRIM(LTRIM(@_vRegions))
				SELECT @_vCountry_Code=Country_Code FROM GPM_Country WHERE RTRIM(LTRIM(Country_Name))=RTRIM(LTRIM(@_vCountry))
				SELECT @_vLocation_ID=Location_ID FROM GPM_Location WHERE RTRIM(LTRIM(Location_Name))= CASE WHEN  RTRIM(LTRIM(@_vLocation)) ='Chemical - Beaumont' THEN 'Beaumont' 
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Goodyear Tire Mgt Shanghai LTDÂ' THEN 'Goodyear Tire Mgt Shanghai LTD'	
																											WHEN RTRIM(LTRIM(@_vLocation)) ='Chemical - Houston' THEN 'Houston' ELSE RTRIM(LTRIM(@_vLocation)) END
				SELECT @_vBA_Id=BA_Id FROM GPM_Business_Area WHERE RTRIM(LTRIM(BA_Name))=RTRIM(LTRIM(@_vBusiness_Area))
				SELECT @_vDept_ID = Dept_ID FROM GPM_Department WHERE RTRIM(LTRIM(Dept_Name))=RTRIM(LTRIM(@_vDepartments)) AND BA_Id=@_vBA_Id
				SELECT @_vCost_Cat_Id=Cost_Cat_Id FROM GPM_Cost_Category WHERE RTRIM(LTRIM(Cost_Cat_Desc))=RTRIM(LTRIM(@_vCost_Category)) 
				SELECT @_vFN_BPO_ID=FN_BPO_ID FROM GPM_Finance_BPO WHERE RTRIM(LTRIM(FN_BPO_Name))=RTRIM(LTRIM(@_vFinance_BPO)) AND BA_Id=@_vBA_Id AND Dept_ID=@_vDept_ID
				SELECT @_vProj_Main_Cat_Id=Proj_Main_Cat_Id FROM GPM_Proj_Main_Category WHERE RTRIM(LTRIM(Proj_Main_Cat_Desc))=RTRIM(LTRIM(@_vProject_Main_Category))
				SELECT @_vProj_Cat_Id=Proj_Cat_Id FROM GPM_Proj_Category WHERE RTRIM(LTRIM(Proj_Cat_Desc))=RTRIM(LTRIM(@_vProject_Category)) AND Proj_Main_Cat_Id=@_vProj_Main_Cat_Id
				SELECT @_vPrim_Loss_Cat_Id=Prim_Loss_Cat_Id FROM GPM_Primary_Loss_Category WHERE RTRIM(LTRIM(Prim_Loss_Cat_Desc))=RTRIM(LTRIM(@_vPrimary_Loss_Categories)) 
				SELECT @_vStatus_Id= Proj_Track_Id FROM GPM_Project_Tracking WHERE Proj_Track_Status = (CASE WHEN RTRIM(LTRIM(@_vStatus))='Canceled' Then 'Cancelled' Else LTRIM(RTRIM(@_vStatus)) END)
				
				SELECT @_vRegTrack_Cat_Id =RegTrack_Cat_Id FROM GPM_Reg_Track_Category WHERE RegTrack_Cat_Desc = LTRIM(RTRIM(@_vRegional_Tracking_Category))
				SELECT @_vConstraint_Id =Constraint_Id FROM GPM_Constraint WHERE Constraint_Name = LTRIM(RTRIM(@_vConstraints))
				SELECT @_vTW_Loss_Cat_Id =TW_Loss_Cat_Id FROM GPM_TW_Loss_Category WHERE TW_Loss_Cat_Desc = LTRIM(RTRIM(@_vTW_Loss_Categories))
				SELECT @_vFeasibility_Id =Impact_Id FROM GPM_Impact WHERE Impact_Desc = LTRIM(RTRIM(@_vIdea_Feasibility))

				SELECT @_vCreated_By=GD_User_Id FROM GPM_User WHERE User_First_Name +' '+User_Last_Name = RTRIM(LTRIM(@_vProject_Lead))

				
				SELECT @_vTempGateCnt=0
				SELECT @_vError_Desc=''

				IF(@_vName IS NULL OR LEN(LTRIM(RTRIM(@_vName)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Idea Name Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vRequestor_Name_and_Contact_Info IS NULL OR LEN(LTRIM(RTRIM(@_vRequestor_Name_and_Contact_Info)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Requestor Name and Contact Info Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vProblem_Statement IS NULL OR LEN(LTRIM(RTRIM(@_vProblem_Statement)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Problem Statement Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vIdea_Description IS NULL OR LEN(LTRIM(RTRIM(@_vIdea_Description)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Idea Description Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vExpected_Total_Savings_in_$ IS NULL OR LEN(LTRIM(RTRIM(@_vExpected_Total_Savings_in_$)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Expected Savings in $ Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vCapEx IS NULL OR LEN(LTRIM(RTRIM(@_vCapEx)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : CapEx Is Blank'
					SELECT @_vValidData='FALSE'
				END

				IF(@_vIdea_Feasibility IS NULL OR LEN(LTRIM(RTRIM(@_vIdea_Feasibility)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Idea Feasibility Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vFeasibility_Id IS NULL OR  LEN(LTRIM(RTRIM(@_vFeasibility_Id)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA :'+@_vIdea_Feasibility +' Idea Feasibility Not Found in DB Master Data'
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

				IF(@_vConstraints IS NULL OR LEN(LTRIM(RTRIM(@_vConstraints)))<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : Constraints Is Blank'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				IF(@_vConstraint_Id IS NULL OR @_vConstraint_Id<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA : ' + @_vConstraints + ' Constraints Not Found In Master Data'
					SELECT @_vValidData='FALSE'
				END
				
				DELETE FROM @_vPiller_Name_Table
				
				INSERT INTO @_vPiller_Name_Table(Piller_Name)
				SELECT Value FROM dbo.Fn_SplitDelimetedData(CHAR(10), @_vPlant_Optimization_pillar) WHERE LEN(LTRIM(RTRIM(Value)))>0

	
				SET @_vPiller_Name=(SELECT ','+TGGD.Piller_Name FROM @_vPiller_Name_Table TGGD WHERE NOT EXISTS( SELECT 1 FROM GPM_Plant_Opt_Piller GGWM 
													WHERE GGWM.Piller_Name=TGGD.Piller_Name) FOR XML PATH(''))

				SET @_vPiller_Name=SUBSTRING(@_vPiller_Name,2, LEN(@_vPiller_Name))

				IF(LEN(@_vPiller_Name)>0)
					BEGIN
						SELECT @_vError_Desc += '| NMA : '+ @_vPiller_Name +' Plant Optimization pillar Not Found In Master Data'
					END

				
				SELECT @_vProject_Member_Id=NULL

				IF(@_vProject_Lead IS NULL OR LEN(LTRIM(RTRIM(@_vProject_Lead)))<=0)
					SELECT @_vProject_Lead = LTRIM(RTRIM(TDR.Idea_Leader)) FROM Temp_IDEA_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 


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
					SELECT @_vError_Desc += '| MA: Idea Leader Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vProject_Lead +' Idea Leader Not Found In User table'
					SELECT @_vValidData='FALSE'
				END


				SELECT @_vProject_Member_Id=NULL
				SELECT @_vFinancial_Rep =NULL

				SELECT @_vFinancial_Rep=LTRIM(RTRIM(TDR.Idea_Approver)) FROM Temp_IDEA_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number 

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
					SELECT @_vError_Desc += '| MA: Idea Approver Is Blank And Replaced With "QA00242"'
					SELECT @_vProject_Member_Id='QA00242'
				END
				ELSE
				IF(@_vProject_Member_Id IS NULL OR LEN(@_vProject_Member_Id)<=0)
				BEGIN
					SELECT @_vError_Desc += '| MA: '+ @_vFinancial_Rep +' Idea Approver Not Found In User table'
					SELECT @_vValidData='FALSE'
				END

				
				IF EXISTS(
					SELECT COUNT(*) FROM Temp_IDEA_Gate_Deliverable  WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number))
				AND Work_type='Gate'
				GROUP BY Gate_Name HAVING COUNT(*)>1
				)
				BEGIN
					SELECT @_vError_Desc += '| Duplicate Gate Found'
					SELECT @_vValidData='FALSE'
				END
				ELSE
				BEGIN
						
						SELECT @_vTempGateCnt=COUNT(*) FROM Temp_IDEA_Gate_Deliverable WHERE Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND Work_type='GATE'

							IF(@_vDBGateCnt!=@_vTempGateCnt)
							BEGIN
								SELECT @_vError_Desc += '| Number Of Gate Not Matching In Database. Gate In DB are  '+ Cast(@_vDBGateCnt AS VARCHAR(10))+ ' And Gate in Given Data are  '+ Cast(@_vTempGateCnt AS VARCHAR(10))
								SELECT @_vValidData='FALSE'
							END
							ELSE
							IF EXISTS(SELECT 1 FROM Temp_IDEA_Gate_Deliverable TGGD WHERE TGGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number)) AND TGGD.Work_type='GATE'
										AND NOT EXISTS( SELECT 1 FROM GPM_Gate_WT_Map GGWM INNER JOIN GPM_Gate GG On GGWM.Gate_Id=GG.Gate_Id
													WHERE GGWM.WT_Code='IDEA' AND GG.Alt_Gate_Desc=TGGD.Gate_Name))
							BEGIN
								SELECT @_vError_Desc += '| One or more gate not found given data'
								SELECT @_vValidData='FALSE'
							END


				END
				
				IF(@_vValidData='FALSE')
				BEGIN
					INSERT INTO Temp_IDEA_Error
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
							INSERT INTO [dbo].[GPM_WT_Idea]
									   ([Idea_Number]
									   ,[Idea_Name]
									   ,[Requester_Details]
									   ,[Region_Code]
									   ,[Country_Code]
									   ,[Location_Id]
									   ,[BA_Id]
									   ,[Dept_Id]
									   ,[Cost_Cat_Id]
									   ,[RegTrack_Cat_Id]
									   ,[Problem_Statement]
									   ,[Idea_Description]
									   ,[Constraint_Id]
									   ,[Expected_Saving_USD]
									   ,[Payback_Period_Mon]
									   ,[Proj_Main_Cat_Id]
									   ,[Proj_Cat_Id]
									   ,[Prim_Loss_Cat_Id]
									   ,[FN_BPO_ID]
									   ,[Feasibility_Id]
									   ,[Is_Capex]
									   ,[Expected_Material_Saving_USD]
									   ,[TW_Loss_Cat_Id]
									   ,[Is_Best_Proj_Nom]
									   ,[Is_Deleted_Ind]
									   ,[Created_Date]
									   ,[Created_By]
									   ,[Last_Modified_Date]
									   ,[Last_Modified_By]
									   ,[Plan_Start_Date]
									   ,[Idea_Status_Id])
								 VALUES
									   (
										LTRIM(RTRIM(@_vSequence_number)),
										@_vName,
										@_vRequestor_Name_and_Contact_Info,
										@_vRegion_Code,
										@_vCountry_Code,
										@_vLocation_Id,
										@_vBA_Id,
										@_vDept_Id,
										@_vCost_Cat_Id,
										@_vRegTrack_Cat_Id,
										@_vProblem_Statement,
										@_vIdea_Description,
										@_vConstraint_Id,
										CASE WHEN LEN(LTRIM(RTRIM(@_vExpected_Total_Savings_in_$)))>0 THEN
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vExpected_Total_Savings_in_$,'$',''),',','') ,')',''),'(',''),' ','') ELSE NULL END,										
										@_vPayback_Time_in_month,
										@_vProj_Main_Cat_Id,
										@_vProj_Cat_Id,
										@_vPrim_Loss_Cat_Id,
										@_vFN_BPO_ID,
										@_vFeasibility_Id,
										CASE WHEN @_vCapEx='Yes' THEN 'Y' WHEN @_vCapEx='No' THEN 'N' ELSE NULL END,
										CASE WHEN LEN(LTRIM(RTRIM(@_vExpected_Material_Savings_in_$)))>0 THEN
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_vExpected_Material_Savings_in_$,'$',''),',','') ,')',''),'(',''),' ','') ELSE NULL END,
										@_vTW_Loss_Cat_Id,
										'N',
										'N',
										@_vSystem_start_date,
										@_vCreated_By,
										@_vSystem_start_date,
										@_vCreated_By,
										@_vSystem_start_date,
										10--@_vIdea_Status_Id

									   )




										SELECT @_vIDEA_Id=NULL
										SELECT @_vIDEA_Id=@@IDENTITY

										INSERT INTO GPM_WT_IDEA_MS_Attrib(
													IDEA_Id,
													IDEA_Number,
													Piller_Id,
													Created_Date,
													Created_By,
													Last_Modified_Date,
													Last_Modified_By
													)
									SELECT
											@_vIDEA_Id,
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
											'IDEA',
											@_vIDEA_Id,
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

					SELECT @_vActive_Gate=LTRIM(RTRIM(Active_Gate)) FROM Temp_IDEA_Gate_Deliverable WHERE RTRIM(LTRIM(Sequence_number))=RTRIM(LTRIM(@_vSequence_number)) AND Active_Gate IS NOT NULL
								

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
					FROM Temp_IDEA_Gate_Deliverable TDGA INNER JOIN GPM_Gate GG On RTRIM(LTRIM(TDGA.Gate_Name))=RTRIM(LTRIM(GG.Alt_Gate_Desc))
					INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id WHERE TDGA.Sequence_number = RTRIM(LTRIM(@_vSequence_number))
					AND GGWM.WT_Code='IDEA' AND Deliverable_Name IS NULL

				
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
															FROM Temp_IDEA_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND 
															LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable'
															AND GGD.WT_Code='IDEA'
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
														(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= 'IDEA' AND WT_Role_Name = 'Deliverable Leader'),
														@_vGate_Id,
														GGD.Deliverable_Id,
														(SELECT TOP 1 GU.GD_User_Id FROM GPM_User GU WHERE  GU.User_First_Name+' '+GU.User_Last_Name = LTRIM(RTRIM(TDGD.Project_Lead))),
														'N'
													FROM Temp_IDEA_Gate_Deliverable TDGD 
															INNER JOIN GPM_Gate GG On  RTRIM(LTRIM(TDGD.Gate_Name))=GG.Alt_Gate_Desc 
															INNER JOIN GPM_Gate_Deliverable GGD ON GG.Gate_Id=GGD.Gate_Id 
															AND 
															LTRIM(RTRIM(TDGD.Deliverable_Name))=GGD.Deliverable_Desc
															WHERE GGD.Gate_Id=@_vGate_Id AND TDGD.Sequence_number=RTRIM(LTRIM(@_vSequence_number))
															AND TDGD.Work_Type='Deliverable'
															AND GGD.WT_Code='IDEA'
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
									SELECT 'Idea Leader',@_vProject_Lead
	
									
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Idea Approver',@_vFinancial_Rep

								/*
								INSERT INTO @_vProjectMember_Table(WT_Role_Name,Project_Member_Name)
									SELECT 'Team Members', LTRIM(RTRIM(TAB.Value)) 	FROM Fn_SplitDelimetedData('|',
									(
									SELECT LTRIM(RTRIM(REPLACE(TDR.Team_Member, CHAR(10),'|'))) FROM Temp_IDEA_RoleAndTags TDR WHERE RTRIM(LTRIM(TDR.Sequence_number))= @_vSequence_number)
									) TAB 
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
													(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code='IDEA' AND WT_Role_Name=@_vWT_Role_Name),
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

											INSERT INTO Temp_IDEA_MissingRoleMember_Error
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
				END /* Valid */

				FETCH NEXT FROM IDEA_Cursor INTO @_vName,@_vPowerSteering_ID,@_vSequence_number,@_vProject_Lead,@_vSystem_start_date,@_vActive_phase,@_vSystem_end_date,@_vStatus,@_vWork_Template,@_vWork_type,@_vComments,@_vConsequential_Metric,
											 @_vExpected_Benefits,@_vExpected_Total_Savings_in_$,@_vExpected_Total_Savings_in_$_raw,@_vGoal_Statement,@_vPrimary_Metric_and_Current_Performance,@_vProblem_Statement,@_vProject_Scope_and_Scale,
											 @_vSecondary_Metric,@_vExpected_Material_Savings_in_$,@_vExpected_Material_Savings_in_$_raw,@_vIdea_Description,@_vPayback_Time_in_month,@_vRequestor_Name_and_Contact_Info,@_vActual_start_date,
											 @_vBaseline,@_vLoss_Opportunity,@_vLoss_Opportunity_raw,@_vMeasures_of_Success,@_vTarget,@_vAnalyze,@_vCapEx,@_vCapEx_ID_#,@_vControl,@_vDefine,@_vImprove,@_vMeasure

			END
			
			CLOSE IDEA_Cursor;
			DEALLOCATE IDEA_Cursor;
			IF CURSOR_STATUS('global','IDEA_Cursor')>=-1
			BEGIN
				DEALLOCATE IDEA_Cursor
			END
END