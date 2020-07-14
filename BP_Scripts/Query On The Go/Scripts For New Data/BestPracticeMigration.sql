BEGIN
/* Plant Nomination Parameters*/
DECLARE @_vName varchar(8000)
DECLARE @_vPowerSteering_ID varchar(8000)
DECLARE @_vBPC_Sequence_number varchar(8000)
DECLARE @_vParent_Sequence_number varchar(8000)
DECLARE @_vBest_Practice_Status varchar(8000)
DECLARE @_vGate_Plant_Approved_By varchar(8000)
DECLARE @_vGate_Plant_Approved_UserId varchar(10)
DECLARE @_vSpecific_BP int
DECLARE @_vMeets_Doc_Req int
DECLARE @_vRoot_Cause_Analysis int
DECLARE @_vEnough_info int
DECLARE @_vAcceptable_KPI int
DECLARE @_vStat_validation int
DECLARE @_vProven_results int
DECLARE @_vFinancial_Calculations int
DECLARE @_vProject_updated int
DECLARE @_vSign_off int
DECLARE @_vTotal int


/*Regional Gate Parameters */

DECLARE @_vGate_Regional_Approved_By varchar(8000)
DECLARE @_vGate_Regional_Approved_Userid varchar(10)
DECLARE @_vSafety_Enhancement_Project INT
DECLARE @_vAligned_with_Buss INT
DECLARE @_vProven_to_reduce_costs INT
DECLARE @_vCustomer_requirement INT
DECLARE @_vCreates_stability_consistency INT
DECLARE @_vCan_be_replicated INT
DECLARE @_vImproves_Ergonomics INT
DECLARE @_vIncrease_people_capability INT
DECLARE @_vFinancial_Payback INT
DECLARE @_vNew_Engineering_discovery INT
DECLARE @_vSign_off_from_Regional_ProcExpt INT

/*Global Analaysis Gate Parameters*/

DECLARE @_vGate_Global_Analysis_Approved_By varchar(8000)
DECLARE @_vGate_Global_Analysis_Approved_UserId varchar(10)
DECLARE @_vGlobal_FI INT
DECLARE @_vGlobal_Quality INT
DECLARE @_vGlobal_Engr INT
DECLARE @_vGlobal_EHSS INT
DECLARE @_vGlobal_PO INT
DECLARE @_vEMEA INT
DECLARE @_vAP INT
DECLARE @_vNA INT
DECLARE @_vLA INT
DECLARE @_vGlobal_Analysis_Comments varchar(MAX)

/* Process Council Gate Parameters */
DECLARE @_vGate_Process_Council_Approved_By VARCHAR(8000)
DECLARE @_vGate_Process_Council_Approved_UserId VARCHAR(10)
DECLARE @_vProcess_Council INT
DECLARE @_vProcess_Council_Comments varchar(MAX)


DECLARE @_vError_Comments VARCHAR(MAX)=''
DECLARE @_vBPValid VARCHAR(10)='TRUE'
DECLARE @_vWT_Project_ID INT
DECLARE @_vWT_Code VARCHAR(10)
DECLARE @_vWT_Id INT
DECLARE @_vWT_Project_Number VARCHAR(15)
--DECLARE @_vCreated_By VARCHAR(10)
--DECLARE @_vTabGate AS TABLE (WT_Project_Id INT, Gate_Id INT, Gate_Order_Id NUMERIC(3,1))

DECLARE Cur_BP_Projects CURSOR FOR
		SELECT  DISTINCT 
				Parent_Sequence_number
		FROM
			Temp_BP_Plant_Nomination --WHERE Parent_Sequence_number='FI-00151'

			OPEN Cur_BP_Projects
			FETCH NEXT FROM Cur_BP_Projects INTO 
				@_vParent_Sequence_number
		
				WHILE @@FETCH_STATUS = 0
       
				BEGIN
					--DELETE FROM @_vTabGate

					SELECT 
							@_vBPValid='TRUE',
							@_vWT_Project_ID =NULL,
							@_vWT_Code = NULL,
							@_vWT_Id = NULL,
							@_vWT_Project_Number = NULL

					SELECT 
							@_vName = NULL,
							@_vPowerSteering_ID = NULL,
							@_vBPC_Sequence_number = NULL,
							@_vBest_Practice_Status = NULL,
							@_vGate_Plant_Approved_By = NULL,
							@_vGate_Global_Analysis_Approved_UserId = NULL,
							@_vSpecific_BP = NULL,
							@_vMeets_Doc_Req = NULL,
							@_vRoot_Cause_Analysis = NULL,
							@_vEnough_info = NULL,
							@_vAcceptable_KPI = NULL,
							@_vStat_validation = NULL,
							@_vProven_results = NULL,
							@_vFinancial_Calculations = NULL,
							@_vProject_updated = NULL,
							@_vSign_off = NULL,
							@_vTotal = NULL,

							@_vGate_Regional_Approved_By = NULL,
							@_vGate_Regional_Approved_Userid = NULL,
							@_vSafety_Enhancement_Project = NULL,
							@_vAligned_with_Buss = NULL,
							@_vProven_to_reduce_costs = NULL,
							@_vCustomer_requirement = NULL,
							@_vCreates_stability_consistency = NULL,
							@_vCan_be_replicated = NULL,
							@_vImproves_Ergonomics = NULL,
							@_vIncrease_people_capability = NULL,
							@_vFinancial_Payback = NULL,
							@_vNew_Engineering_discovery = NULL,
							@_vSign_off_from_Regional_ProcExpt = NULL,

							@_vGate_Global_Analysis_Approved_By = NULL,
							@_vGate_Global_Analysis_Approved_UserId = NULL,
							@_vGlobal_FI = NULL,
							@_vGlobal_Quality = NULL,
							@_vGlobal_Engr = NULL,
							@_vGlobal_EHSS = NULL,
							@_vGlobal_PO = NULL,
							@_vEMEA = NULL,
							@_vAP = NULL,
							@_vNA = NULL,
							@_vLA = NULL,
							@_vGlobal_Analysis_Comments = NULL,

							@_vGate_Process_Council_Approved_By = NULL,
							@_vGate_Process_Council_Approved_UserId = NULL,
							@_vProcess_Council = NULL,
							@_vProcess_Council_Comments = NULL,
							@_vError_Comments =''


							SELECT 
								@_vName=Name,
								@_vPowerSteering_ID=PowerSteering_ID,
								@_vBPC_Sequence_number=BPC_Sequence_number,
								@_vBest_Practice_Status=Best_Practice_Status,
								@_vGate_Plant_Approved_By=Gate_Approved_By,
								@_vSpecific_BP=Specific_BP,
								@_vMeets_Doc_Req=Meets_Doc_Req,
								@_vRoot_Cause_Analysis=Root_Cause_Analysis,
								@_vEnough_info=Enough_info,
								@_vAcceptable_KPI=Acceptable_KPI,
								@_vStat_validation=Stat_validation,
								@_vProven_results=Proven_results,
								@_vFinancial_Calculations=Financial_Calculations,
								@_vProject_updated=Project_updated,
								@_vSign_off=Sign_off,
								@_vTotal=Total
							FROM 
									Temp_BP_Plant_Nomination WHERE Parent_Sequence_number=@_vParent_Sequence_number


												
						IF NOT EXISTS (SELECT 1 FROM Temp_BP_Regional_Analysis WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number)))
						BEGIN
								SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Regional Analysis Gate Info Not Found'
								SELECT @_vBPValid='FALSE'
						END

						IF NOT EXISTS (SELECT 1 FROM Temp_BP_Global_Analysis WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number)))
						BEGIN
								SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Global Analysis Gate Info Not Found'
								SELECT @_vBPValid='FALSE'
						END

						IF NOT EXISTS (SELECT 1 FROM Temp_BP_Process_Council WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number)))
						BEGIN
								SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Process Council Gate Info Not Found'
								SELECT @_vBPValid='FALSE'
						END

						IF NOT EXISTS (SELECT 1 FROM GPM_WT_Project WHERE RTRIM(LTRIM(WT_Project_Number))=RTRIM(LTRIM(@_vParent_Sequence_number)))
						BEGIN
								SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Project Not Migrated Yet'
								SELECT @_vBPValid='FALSE'
						END

						--PRINT @_vError_Comments

						IF(@_vBPValid='TRUE')
						BEGIN


								SELECT 
									@_vGate_Regional_Approved_By = Gate_Approved_By,
									@_vSafety_Enhancement_Project = Safety_Enhancement_Project,
									@_vAligned_with_Buss = Aligned_with_Buss,
									@_vProven_to_reduce_costs = Proven_to_reduce_costs,
									@_vCustomer_requirement = Customer_requirement,
									@_vCreates_stability_consistency = Creates_stability_consistency,
									@_vCan_be_replicated = Can_be_replicated,
									@_vImproves_Ergonomics = Improves_Ergonomics,
									@_vIncrease_people_capability = Increase_people_capability,
									@_vFinancial_Payback = Financial_Payback,
									@_vNew_Engineering_discovery = New_Engineering_discovery,
									@_vSign_off_from_Regional_ProcExpt = Sign_off_from_Regional_ProcExpt
							FROM Temp_BP_Regional_Analysis 
								WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number))


							SELECT
										@_vGate_Global_Analysis_Approved_By = Gate_Approved_By,
										@_vGlobal_FI = Global_FI,
										@_vGlobal_Quality = Global_Quality,
										@_vGlobal_Engr = Global_Engr,
										@_vGlobal_EHSS = [Global_EHS&S],
										@_vGlobal_PO = Global_PO,
										@_vEMEA = EMEA,
										@_vAP = AP,
										@_vNA = NA,
										@_vLA = LA,
										@_vGlobal_Analysis_Comments = Comments
									FROM Temp_BP_Global_Analysis 
									WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number))

							SELECT 
										@_vGate_Process_Council_Approved_By = Gate_Approved_By,
										@_vProcess_Council = Process_Council,
										@_vProcess_Council_Comments = Comments
							FROM Temp_BP_Process_Council 
									WHERE RTRIM(LTRIM(Parent_Sequence_number))=RTRIM(LTRIM(@_vParent_Sequence_number))

							IF(@_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%') 
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Plant Nomination Gate Approver '+ @_vGate_Plant_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Plant_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By))
							END

							IF(@_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%') 
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Plant Nomination Gate Approver '+ @_vGate_Plant_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Plant_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By))

								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Regional_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Regional Analysis Gate Approver '+ @_vGate_Regional_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Regional_Approved_Userid=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Regional_Approved_By))

							END

							IF(@_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%') 
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Plant Nomination Gate Approver '+ @_vGate_Plant_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Plant_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By))



								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Regional_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Regional Analysis Gate Approver '+ @_vGate_Regional_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Regional_Approved_Userid=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Regional_Approved_By))



								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Global_Analysis_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Global Analysis Gate Approver '+ @_vGate_Global_Analysis_Approved_By+' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Global_Analysis_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Global_Analysis_Approved_By))
							END

							IF(@_vBest_Practice_Status LIKE '%Process Council Gate Approved%') 
							BEGIN
								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') =  RTRIM(LTRIM(@_vGate_Plant_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Plant Nomination Gate Approver '+@_vGate_Plant_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Plant_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Plant_Approved_By))



								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') =  RTRIM(LTRIM(@_vGate_Regional_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Regional Analysis Gate Approver '+ @_vGate_Regional_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
								SELECT @_vGate_Regional_Approved_Userid=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Regional_Approved_By))



								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') =  RTRIM(LTRIM(@_vGate_Global_Analysis_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Global Analysis Gate Approver '+ @_vGate_Global_Analysis_Approved_By +' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ElSE
									SELECT @_vGate_Global_Analysis_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Global_Analysis_Approved_By))

								IF NOT EXISTS(SELECT 1 FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Process_Council_Approved_By)))
								BEGIN
									SELECT @_vError_Comments=@_vError_Comments+'|'+ 'Process Council Gate Approver '+@_vGate_Process_Council_Approved_By+' Not Found'
									SELECT @_vBPValid='FALSE'
								END
								ELSE
									SELECT @_vGate_Process_Council_Approved_UserId=GD_User_Id FROM GPM_User WHERE ISNULL(User_First_Name,'') +' '+ISNULL(User_Last_Name,'') = RTRIM(LTRIM(@_vGate_Process_Council_Approved_By))
							END
	
						END

						IF(@_vBest_Practice_Status LIKE '%Project Submitted%')
							SELECT  @_vGate_Plant_Approved_UserId='A398351'

						IF(@_vBPValid='TRUE')
						BEGIN
							SELECT 
									@_vWT_Project_ID =WT_Project_ID,
									@_vWT_Code = WT_Code,
									@_vWT_Id = WT_Id,
									@_vWT_Project_Number = WT_Project_Number 
							FROM GPM_WT_Project WHERE RTRIM(LTRIM(WT_Project_Number))=RTRIM(LTRIM(@_vParent_Sequence_number))


							DELETE FROM GPM_WT_Project_BP_Criteria_Comments WHERE WT_Project_Id=@_vWT_Project_ID
								
							DELETE GPM_WT_Project_BP_Criteria WHERE WT_Project_Id=@_vWT_Project_ID
								
							DELETE FROM GPM_WT_Project_BP_Gate WHERE WT_Project_ID=@_vWT_Project_ID

							

							
							IF(
								(@_vBest_Practice_Status LIKE '%Project Submitted%') OR
								(@_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%') OR
								(@_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%') OR
								(@_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%')
							)
							BEGIN	
								IF (@_vWT_Code='FI') 
									UPDATE GPM_WT_DMAIC SET Is_Best_Proj_Nom='Y', BP_Status_Id=10  WHERE DMAIC_Id=@_vWT_Id AND DMAIC_Number=@_vWT_Project_Number
								

								IF (@_vWT_Code='GDI') 
									UPDATE GPM_WT_GDI SET Is_Best_Proj_Nom='Y', BP_Status_Id=10  WHERE GDI_Id=@_vWT_Id AND GDI_Number=@_vWT_Project_Number
							END
							ELSE
							IF(@_vBest_Practice_Status LIKE '%Process Council Gate Approved%')
							BEGIN
								IF (@_vWT_Code='FI') 
									UPDATE GPM_WT_DMAIC SET Is_Best_Proj_Nom='Y', BP_Status_Id=11  WHERE DMAIC_Id=@_vWT_Id AND DMAIC_Number=@_vWT_Project_Number
								

								IF (@_vWT_Code='GDI') 
									UPDATE GPM_WT_GDI SET Is_Best_Proj_Nom='Y', BP_Status_Id=11  WHERE GDI_Id=@_vWT_Id AND GDI_Number=@_vWT_Project_Number
							END


							PRINT @_vParent_Sequence_number
								INSERT INTO GPM_WT_Project_BP_Gate
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
											Last_Modified_Date,
											Approved_By

										)

									--OUTPUT INSERTED.WT_Project_Id, INSERTED.Gate_Id, INSERTED.Gate_Order_Id INTO @_vTabGate(WT_Project_Id,Gate_Id, Gate_Order_Id)
									SELECT @_vWT_Project_ID,
										GGWM.Gate_Id,
										CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN 10
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN 11
														 ELSE 10 END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN 11
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN 11
														 ELSE 10 END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN 11
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN 11
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN 11
														 ELSE 10 END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN 11
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN 11
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN 11
														 WHEN GG.Gate_Desc='4 - Process Council' THEN 11 END
											ELSE NULL 
										END,
										GGWM.Gate_Default_Order AS Gate_Order_Id,
										CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN
												CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN 'Y' ELSE 'N' END
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN
												CASE WHEN GG.Gate_Desc='2 - Regional Analysis' THEN 'Y' ELSE 'N' END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
												CASE WHEN GG.Gate_Desc='3 - Global Analysis' THEN 'Y' ELSE 'N' END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
												CASE WHEN GG.Gate_Desc='4 - Process Council' THEN 'Y' ELSE 'N' END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
												'N'
										END,
										GETDATE(),

										--GETDATE(),

											CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN NULL
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN (select  Global_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN (select  Global_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='4 - Process Council' THEN (select  Process_Council_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName) END
											ELSE NULL 
										END,


										@_vGate_Plant_Approved_UserId,
										GETDATE(),
										CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN NULL
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN @_vGate_Global_Analysis_Approved_UserId
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN @_vGate_Global_Analysis_Approved_UserId
														 WHEN GG.Gate_Desc='4 - Process Council' THEN @_vGate_Plant_Approved_UserId END
											ELSE NULL 
										END,
										--GETDATE(),

										CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN NULL
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN (select  Global_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN (select Plant_Nomination_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN (select  Regional_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN (select  Global_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
														 WHEN GG.Gate_Desc='4 - Process Council' THEN (select  Process_Council_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName) END
											ELSE NULL 
										END,

										CASE WHEN @_vBest_Practice_Status LIKE '%Project Submitted%' THEN NULL
											WHEN @_vBest_Practice_Status LIKE '%Plant Nomination Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Regional Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Global Analysis Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN @_vGate_Global_Analysis_Approved_UserId
														 ELSE NULL END
											WHEN @_vBest_Practice_Status LIKE '%Process Council Gate Approved%' THEN 
													CASE WHEN GG.Gate_Desc='1 - Plant Nomination' THEN @_vGate_Plant_Approved_UserId 
														 WHEN GG.Gate_Desc='2 - Regional Analysis' THEN @_vGate_Regional_Approved_Userid
														 WHEN GG.Gate_Desc='3 - Global Analysis' THEN @_vGate_Global_Analysis_Approved_UserId
														 WHEN GG.Gate_Desc='4 - Process Council' THEN @_vGate_Plant_Approved_UserId END
											ELSE NULL 
										END
									FROM GPM_Gate GG INNER JOIN GPM_Gate_WT_Map GGWM On GG.Gate_Id=GGWM.Gate_Id 
									where GG.Gate_Process_Type_Id = 14 AND GGWM.WT_Code='BPC'
									AND GG.Is_Deleted_Ind='N'

									


							/*Plant  Nomination Criteria*/

								INSERT INTO GPM_WT_Project_BP_Criteria ( WT_Project_Id,Gate_Id,BP_Criteria_Id,BP_Score_Type_Code,Created_By,Created_Date,Last_Modified_By,Last_Modified_Date)
								select @_vWT_Project_ID,27,10,CASE WHEN @_vSpecific_BP=1 THEN 'Yes' WHEN @_vSpecific_BP=0 THEN 'No' WHEN @_vSpecific_BP IS NULL Then 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,11,CASE WHEN @_vMeets_Doc_Req=1 THEN 'Yes' WHEN @_vMeets_Doc_Req=0 THEN 'No' WHEN @_vMeets_Doc_Req IS NULL Then 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,12,CASE WHEN @_vRoot_Cause_Analysis=1 THEN 'Yes' WHEN @_vRoot_Cause_Analysis=0 THEN 'No' WHEN @_vRoot_Cause_Analysis IS NULL Then 'None' ELSE NULL END , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,13,CASE WHEN @_vEnough_info=1 THEN 'Yes' WHEN @_vEnough_info=0 THEN 'No' WHEN @_vEnough_info IS NULL Then 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()     
								UNION ALL
								select @_vWT_Project_ID,27,14,CASE WHEN @_vAcceptable_KPI=1 THEN 'Yes' WHEN @_vAcceptable_KPI=0 THEN 'No' WHEN @_vAcceptable_KPI IS NULL Then 'None' ELSE NULL END , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,15,CASE WHEN @_vStat_validation=1 THEN 'Yes' WHEN @_vStat_validation=0 THEN 'No' WHEN @_vStat_validation IS NULL Then 'None' ELSE NULL END , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,16,CASE WHEN @_vProven_results=1 THEN 'Yes' WHEN @_vProven_results=0 THEN 'No' WHEN @_vProven_results IS NULL Then 'None' ELSE NULL END  , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,17,CASE WHEN @_vFinancial_Calculations=1 THEN 'Yes' WHEN @_vFinancial_Calculations=0 THEN 'No' WHEN @_vFinancial_Calculations IS NULL Then 'None' ELSE NULL END  , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,18,CASE WHEN @_vProject_updated=1 THEN 'Yes' WHEN @_vProject_updated=0 THEN 'No' WHEN @_vProject_updated IS NULL Then 'None' ELSE NULL END  , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,27,19,CASE WHEN @_vSign_off=1 THEN 'Yes' WHEN @_vSign_off=0 THEN 'No' WHEN @_vSign_off IS NULL Then 'None' ELSE NULL END  , @_vGate_Plant_Approved_UserId, GETDATE(), @_vGate_Plant_Approved_UserId, GETDATE()   



								/*Regional Analysis Criteria*/
								INSERT INTO GPM_WT_Project_BP_Criteria ( WT_Project_Id,Gate_Id,BP_Criteria_Id,BP_Score_Type_Code,Created_By,Created_Date,Last_Modified_By,Last_Modified_Date)
								select @_vWT_Project_ID,28,20, CASE WHEN @_vSafety_Enhancement_Project = 0 THEN 'Yes' WHEN @_vSafety_Enhancement_Project = 0 THEN 'No' WHEN @_vSafety_Enhancement_Project IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,21, CASE WHEN @_vAligned_with_Buss = 0 THEN 'Yes' WHEN @_vAligned_with_Buss = 0 THEN 'No' WHEN @_vAligned_with_Buss IS NULL THEN 'None' ELSE NULL END,  @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,22, CASE WHEN @_vProven_to_reduce_costs = 0 THEN 'Yes' WHEN @_vProven_to_reduce_costs = 0 THEN 'No' WHEN @_vProven_to_reduce_costs IS NULL THEN 'None' ELSE NULL END,  @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,23, CASE WHEN @_vCustomer_requirement = 0 THEN 'Yes' WHEN @_vCustomer_requirement = 0 THEN 'No' WHEN @_vCustomer_requirement IS NULL THEN 'None' ELSE NULL END,  @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,24, CASE WHEN @_vCreates_stability_consistency = 0 THEN 'Yes' WHEN @_vCreates_stability_consistency = 0 THEN 'No' WHEN @_vCreates_stability_consistency IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,25, CASE WHEN @_vCan_be_replicated = 0 THEN 'Yes' WHEN @_vCan_be_replicated = 0 THEN 'No' WHEN @_vCan_be_replicated IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,26, CASE WHEN @_vImproves_Ergonomics = 0 THEN 'Yes' WHEN @_vImproves_Ergonomics = 0 THEN 'No' WHEN @_vImproves_Ergonomics IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,27, CASE WHEN @_vIncrease_people_capability = 0 THEN 'Yes' WHEN @_vIncrease_people_capability = 0 THEN 'No' WHEN @_vIncrease_people_capability IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,28, CASE WHEN @_vFinancial_Payback = 0 THEN 'Yes' WHEN @_vFinancial_Payback = 0 THEN 'No' WHEN @_vFinancial_Payback IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,29, CASE WHEN @_vNew_Engineering_discovery = 0 THEN 'Yes' WHEN @_vNew_Engineering_discovery = 0 THEN 'No' WHEN @_vNew_Engineering_discovery IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   
								UNION ALL
								select @_vWT_Project_ID,28,30, CASE WHEN @_vSign_off_from_Regional_ProcExpt = 0 THEN 'Yes' WHEN @_vSign_off_from_Regional_ProcExpt = 0 THEN 'No' WHEN @_vSign_off_from_Regional_ProcExpt IS NULL THEN 'None' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Regional_Approved_Userid IS NULL THEN @_vGate_Plant_Approved_UserId ELSE  @_vGate_Regional_Approved_Userid END, GETDATE()   

								/*Global Analysis Gate Criteria */
								INSERT INTO GPM_WT_Project_BP_Criteria ( WT_Project_Id,Gate_Id,BP_Criteria_Id,BP_Score_Type_Code,Created_By,Created_Date,Last_Modified_By,Last_Modified_Date)
								SELECT @_vWT_Project_ID,29,31, CASE WHEN @_vGlobal_FI = 0 THEN 'None' WHEN @_vGlobal_FI = 1 THEN 'Could' WHEN @_vGlobal_FI = 3 THEN 'Should' WHEN @_vGlobal_FI = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,32, CASE WHEN @_vGlobal_Quality = 0 THEN 'None' WHEN @_vGlobal_Quality = 1 THEN 'Could' WHEN @_vGlobal_Quality = 3 THEN 'Should' WHEN @_vGlobal_Quality = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,33, CASE WHEN @_vGlobal_Engr = 0 THEN 'None' WHEN @_vGlobal_Engr = 1 THEN 'Could' WHEN @_vGlobal_Engr = 3 THEN 'Should' WHEN @_vGlobal_Engr = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,45, CASE WHEN @_vGlobal_EHSS = 0 THEN 'None' WHEN @_vGlobal_EHSS = 1 THEN 'Could' WHEN @_vGlobal_EHSS = 3 THEN 'Should' WHEN @_vGlobal_EHSS = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,40, CASE WHEN @_vGlobal_PO = 0 THEN 'None' WHEN @_vGlobal_PO = 1 THEN 'Could' WHEN @_vGlobal_PO = 3 THEN 'Should' WHEN @_vGlobal_PO = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,34, CASE WHEN @_vEMEA = 0 THEN 'None' WHEN @_vEMEA = 1 THEN 'Could' WHEN @_vEMEA = 3 THEN 'Should' WHEN @_vEMEA = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()
								UNION ALL
								SELECT @_vWT_Project_ID,29,35, CASE WHEN @_vAP = 0 THEN 'None' WHEN @_vAP = 1 THEN 'Could' WHEN @_vAP = 3 THEN 'Should' WHEN @_vAP = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE() 
								UNION ALL
								SELECT @_vWT_Project_ID,29,36, CASE WHEN @_vNA = 0 THEN 'None' WHEN @_vNA = 1 THEN 'Could' WHEN @_vNA = 3 THEN 'Should' WHEN @_vNA = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								UNION ALL
								SELECT @_vWT_Project_ID,29,37, CASE WHEN @_vLA = 0 THEN 'None' WHEN @_vLA = 1 THEN 'Could' WHEN @_vLA = 3 THEN 'Should' WHEN @_vLA = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Global_Analysis_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Global_Analysis_Approved_UserId END, GETDATE()   
								PRINT @_vParent_Sequence_number
								INSERT INTO GPM_WT_Project_BP_Criteria_Comments
									(
										WT_Project_Id,
										Gate_Id,
										Comments,
										Comments_By,
										Comments_Date
									)
									VALUES
									(
									@_vWT_Project_ID,
									29,
									@_vGlobal_Analysis_Comments,
									@_vGate_Global_Analysis_Approved_UserId,
									(select  Global_Analysis_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
									)
										
								/*Process Council Gate Criteria */
								INSERT INTO GPM_WT_Project_BP_Criteria ( WT_Project_Id,Gate_Id,BP_Criteria_Id,BP_Score_Type_Code,Created_By,Created_Date,Last_Modified_By,Last_Modified_Date)
								SELECT @_vWT_Project_ID,30,44, CASE WHEN @_vProcess_Council = 0 THEN 'None' WHEN @_vProcess_Council = 1 THEN 'Could' WHEN @_vProcess_Council = 3 THEN 'Should' WHEN @_vProcess_Council = 5 THEN 'Must' ELSE NULL END, @_vGate_Plant_Approved_UserId, GETDATE(), CASE WHEN @_vGate_Process_Council_Approved_UserId IS NULL THEN @_vGate_Plant_Approved_UserId ELSE @_vGate_Process_Council_Approved_UserId END, GETDATE()   
								PRINT @_vParent_Sequence_number
								INSERT INTO GPM_WT_Project_BP_Criteria_Comments
									(
										WT_Project_Id,
										Gate_Id,
										Comments,
										Comments_By,
										Comments_Date
									)
									VALUES
									(
									@_vWT_Project_ID,
									30,
									@_vProcess_Council_Comments,
									@_vGate_Process_Council_Approved_UserId,
									(select  Process_Council_Gate_Approved from Temp_BP_Gate WHERE Parent_Sequence_number=@_vParent_Sequence_number AND Name=@_vName)
									)
										
					
						
						END
						ELSE
						BEGIN
							IF(LEN(@_vError_Comments)>0)
								INSERT INTO Temp_BP_Error
											(
											Name ,
											PowerSteering_ID,
											BPC_Sequence_number,
											Parent_Sequence_number,
											Error_Comments
											)
										VALUES
										(
										@_vName,
										@_vPowerSteering_ID,
										@_vBPC_Sequence_number,
										@_vParent_Sequence_number,
										SUBSTRING(@_vError_Comments,2, LEN(@_vError_Comments))
										)

						END


						FETCH NEXT FROM Cur_BP_Projects INTO 
						@_vParent_Sequence_number
		
				END
 
	 CLOSE Cur_BP_Projects;
	 DEALLOCATE Cur_BP_Projects;
	 IF CURSOR_STATUS('global','Cur_BP_Projects')>=-1
	 BEGIN
       DEALLOCATE Cur_BP_Projects
	END
	

END


		
