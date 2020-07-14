ALTER TABLE GPM_WT_Idea ALTER COLUMN Idea_Name NVARCHAR(500)
GO
ALTER TABLE GPM_WT_Idea ALTER COLUMN Requester_Details NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Idea ALTER COLUMN Problem_Statement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Idea ALTER COLUMN Idea_Description NVARCHAR(4000)
GO

/****** Object:  StoredProcedure [dbo].[Sp_AddWTIdeaDetails]    Script Date: 6/29/2019 12:45:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_AddWTIdeaDetails]
(
	@vIdea_Name nvarchar(500),
	@vPlan_Start_Date datetime,
	@vRequester_Details nvarchar(4000),
	@vRegion_Code varchar(5),
	@vCountry_Code char(3),
	@vLocation_Id int,
	@vBA_Id int,
	@vDept_Id int,
	@vCost_Cat_Id int,
	@vRegTrack_Cat_Id int,
	@vPiller_Ids varchar(100),
	@vProblem_Statement nvarchar(4000),
	@vIdea_Description nvarchar(4000),
	@vConstraint_Id int,
	@vExpected_Saving_USD numeric(16,4),
	@vPayback_Period_Mon numeric(10,2),
	@vProj_Main_Cat_Id int,
	@vProj_Cat_Id int,
	@vPrim_Loss_Cat_Id Int,
	@vFN_BPO_ID Int,
	@vFeasibility_Id Int,
	@vIs_Capex Char(1),
	@vExpected_Material_Saving_USD Numeric(16,4),
	@vTW_Loss_Cat_Id Int,
	@vIdeaApprover Varchar(8000),
	@vIdeaLeader Varchar(8000),
	@vCreated_By varchar(10),
	@vLast_Modified_By varchar(10),
	@vIDEA_Number VARCHAR(15) OUT,
	@vWT_Project_Id int OUT,
	@vMsg_Out Varchar(100) OUT
)
 AS
 BEGIN


DECLARE @_vIDEA_Number VARCHAR(15)=NULL
DECLARE @_vIDEA_Number_SEQ INT =NULL
DECLARE @_vIDEA_Id INT
DECLARE @_vWT_Type Varchar(5)='IDEA'
DECLARE @_vTabGate AS TABLE (WT_Project_Id INT, Gate_Id INT, Gate_Order_Id INT)

DECLARE @_vTabCnt INT
DECLARE @_vMaxGateOrder INT
DECLARE @_vStartDate DATETIME=NULL
DECLARE @_vEndDate DATETIME=NULL
DECLARE @_vGate_Id INT

DECLARE @_vTabRoleMember As TABLE(id INT Identity(1,1), RoleMember VARCHAR(8000))
DECLARE @_vTabRoleMemberNotif As TABLE(WT_Role_Id INT, GD_User_Id VARCHAR(10))

DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRoleMember VARCHAR(8000)=NULL
DECLARE @_vProjectRoleId INT=NULL
DECLARE @_vGDUserIdList VARCHAR(4000)=NULL
DECLARE @_vRMSepPos INT=0

DECLARE @_vNoOfDays INT=0
DECLARE @_vDeliverable_Id INT=0
DECLARE @_vDeliverable_Order INT=0
DECLARE @_vDvCnt INT=0, @_DvCntMax INT=0


IF NOT EXISTS(SELECT * FROM GPM_WT_Idea)
       SELECT @_vIDEA_Number=@_vWT_Type+'-00001'
ELSE
BEGIN
       SELECT @_vIDEA_Number_SEQ=MAX(CAST(SUBSTRING(IDEA_Number,CHARINDEX('-',IDEA_Number,1)+1,LEN(IDEA_Number)) AS INT))
FROM GPM_WT_Idea WHERE CHARINDEX('-',IDEA_Number,1)>0 AND UPPER(SUBSTRING(IDEA_Number,1, CHARINDEX('-',IDEA_Number,1)-1))=UPPER(@_vWT_Type)
AND ISNUMERIC(SUBSTRING(IDEA_Number,CHARINDEX('-',IDEA_Number,1)+1,LEN(IDEA_Number)) )=1


       IF(@_vIDEA_Number_SEQ IS NULL)
              SELECT @_vIDEA_Number=@_vWT_Type+'-00001'
			  
       ELSE
              BEGIN
                     SELECT @_vIDEA_Number_SEQ=@_vIDEA_Number_SEQ+1

                     IF(@_vIDEA_Number_SEQ>99999)
                     BEGIN
						SELECT @vMsg_Out = 'Sequence Reached To Maximum Limit'
						RETURN 0
					 END
                     ELSE
                           SELECT @_vIDEA_Number= @_vWT_Type+'-'+REPLICATE('0', 5-LEN(CAST(@_vIDEA_Number_SEQ AS VARCHAR(10))) ) + CAST(@_vIDEA_Number_SEQ AS VARCHAR(10))
              END
END

	BEGIN TRAN
		INSERT INTO GPM_WT_Idea
           (
			   Idea_Number,
			   Idea_Name,
			   Requester_Details,
			   Region_Code,
			   Country_Code,
			   Location_Id,
			   BA_Id,
			   Dept_Id,
			   Cost_Cat_Id,
			   RegTrack_Cat_Id,
			   Problem_Statement,
			   Idea_Description,
			   Constraint_Id,
			   Expected_Saving_USD,
			   Payback_Period_Mon,
			   Proj_Main_Cat_Id,
			   Proj_Cat_Id,
			   Prim_Loss_Cat_Id,
			   FN_BPO_ID,
			   Feasibility_Id,
			   Is_Capex,
			   Expected_Material_Saving_USD,
			   TW_Loss_Cat_Id,
			   Is_Deleted_Ind,
			   Created_Date,
			   Created_By,
			   Last_Modified_Date,
			   Last_Modified_By,
			   Plan_Start_Date,
			   Idea_Status_Id
			 )
		VALUES
			(
				@_vIDEA_Number,
				@vIdea_Name,
				@vRequester_Details,
				@vRegion_Code,
				@vCountry_Code,
				@vLocation_Id,
				@vBA_Id,
				@vDept_Id,
				@vCost_Cat_Id,
				@vRegTrack_Cat_Id,
				@vProblem_Statement,
				@vIdea_Description,
				@vConstraint_Id,
				@vExpected_Saving_USD,
				@vPayback_Period_Mon,
				@vProj_Main_Cat_Id,
				@vProj_Cat_Id,
				@vPrim_Loss_Cat_Id,
				@vFN_BPO_ID,
				@vFeasibility_Id,
				@vIs_Capex,
				@vExpected_Material_Saving_USD,
				@vTW_Loss_Cat_Id,
				'N',
				GETDATE(),
				@vCreated_By,
				GETDATE(),
				@vLast_Modified_By,
				@vPlan_Start_Date,
				10
			)
			
			IF (@@ERROR <> 0) GOTO ERR_HANDLER
			
					SELECT @_vIDEA_Id=@@IDENTITY

					SELECT @vIDEA_Number=@_vIDEA_Number

					INSERT INTO GPM_WT_Idea_MS_Attrib
					(
					Idea_Id,
					Idea_Number,
					Piller_Id,
					Created_Date,
					Created_By,
					Last_Modified_Date,
					Last_Modified_By
					)
					SELECT 
					@_vIDEA_Id,
					@_vIDEA_Number,
					Value,
					Getdate(),
					@vCreated_By,
					Getdate(),
					@vCreated_By
					FROM Fn_SplitDelimetedData(',',@vPiller_Ids)
					WHERE Len(RTRIM(LTRIM(Value)))>0

			IF (@@ERROR <> 0) GOTO ERR_HANDLER

					INSERT INTO GPM_WT_Project
					(
						WT_Code,
						WT_ID,
						WT_Project_Number,
						Created_By,
						Created_Date,
						Last_Modified_By,
						Last_Modified_Date
					)
					VALUES
					(
						@_vWT_Type,
						@_vIDEA_Id,
						@_vIDEA_Number,
						@vCreated_By,
						Getdate(),
						@vLast_Modified_By,
						Getdate()
					)

					
					IF (@@ERROR <> 0) GOTO ERR_HANDLER

					SELECT @vWT_Project_Id=@@IDENTITY

					 /* Add Gate Against Idea Work Type*/

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
					SELECT @vWT_Project_Id, 
						Gate_Id, 
						16, 
						Gate_Default_Order, 
						(CASE WHEN Gate_Default_Order = 1  THEN 'Y' ELSE 'N' END),
						NULL,
						NULL,
						@vCreated_By,
						Getdate(),
						@vLast_Modified_By,
						Getdate()
					FROM GPM_Gate_WT_Map WHERE WT_Code=@_vWT_Type AND  Is_Deleted_Ind = 'N'


					/* Add Deliverables Against DMAIC Work Type*/

					SELECT 
						@_vStartDate=NULL,
						@_vEndDate=DATEADD(DAY,-1,ISNULL(@vPlan_Start_Date,GETDATE()))
						

					IF((SELECT COUNT(*) FROM @_vTabGate)>0)
					BEGIN
				
							SELECT @_vMaxGateOrder=MAX(Gate_Order_Id), @_vTabCnt=MIN(Gate_Order_Id) FROM  @_vTabGate
							
							WHILE @_vTabCnt<(@_vMaxGateOrder+1)
							BEGIN

									SELECT @_vGate_Id=Gate_Id FROM @_vTabGate WHERE Gate_Order_Id=@_vTabCnt

									SELECT  @_vDvCnt=0, 
											@_DvCntMax=0					

									IF((SELECT COUNT(*) FROM GPM_Gate_Deliverable WHERE Gate_Id=@_vGate_Id)>0)
									BEGIN
											SELECT @_DvCntMax=MAX(Deliverable_Default_Order), @_vDvCnt=MIN(Deliverable_Default_Order)
											FROM GPM_Gate_Deliverable WHERE Gate_Id=@_vGate_Id

											WHILE @_vDvCnt<(@_DvCntMax+1)
												BEGIN
				
					
													SELECT 
														@_vDeliverable_Id=Deliverable_Id,
														@_vNoOfDays=No_Of_Days,
														@_vDeliverable_Order=Deliverable_Default_Order							
														FROM GPM_Gate_Deliverable WHERE Gate_Id=@_vGate_Id AND Deliverable_Default_Order=@_vDvCnt


													SELECT @_vStartDate=DATEADD(DAY,1,@_vEndDate)
													SELECT @_vEndDate=DATEADD(DAY, @_vNoOfDays,@_vStartDate )

							

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
													VALUES	(	@vWT_Project_Id,
																@_vGate_Id, 
																@_vDeliverable_Id, 
																16,
																NULL,
																@_vStartDate,
																@_vEndDate,
																'Y', 
																NULL, 
																@vCreated_By, 
																GETDATE(), 
																@vLast_Modified_By, 
																GETDATE()  
															)

													IF (@@ERROR <> 0) GOTO ERR_HANDLER

													INSERT INTO GPM_WT_Project_Team_Deliverable
															(
																WT_Project_ID,
																WT_Role_ID,
																Gate_Id,
																Deliverable_Id,
																GD_User_Id,
																Is_Deleted_Ind
															)
													VALUES(
															@vWT_Project_Id,
															(SELECT WT_Role_Id FROM GPM_Project_Template_Role where WT_Code= @_vWT_Type AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
															@_vGate_Id, 
															@_vDeliverable_Id,
															SUBSTRING(@vIdeaLeader,CHARINDEX('|',@vIdeaLeader,1)+1, len(@vIdeaLeader)),
															'N'
														  ) 
	
													IF (@@ERROR <> 0) GOTO ERR_HANDLER


												SELECT @_vDvCnt=MIN(Deliverable_Default_Order) FROM GPM_Gate_Deliverable WHERE Gate_Id=@_vGate_Id AND
												Deliverable_Default_Order>@_vDvCnt
										END
								END /*End Deliverable If And Loop*/

					
						UPDATE GPM_WT_Project_Gate 
						SET Start_Date= (SELECT MIN(Start_Date) FROM GPM_WT_Project_Deliverable WHERE WT_Project_Id=@vWT_Project_Id	AND Gate_Id=@_vGate_Id),
							End_Date=(SELECT MAX(End_Date) FROM GPM_WT_Project_Deliverable WHERE WT_Project_Id=@vWT_Project_Id AND Gate_Id=@_vGate_Id) 
						WHERE WT_Project_Id=@vWT_Project_Id AND Gate_Id=@_vGate_Id

						
						SELECT @_vTabCnt=MIN(Gate_Order_Id) FROM @_vTabGate WHERE Gate_Order_Id>@_vTabCnt
					END 
			END/* End Gate If and Loop*/

			
			UPDATE GPM_WT_Project SET Status_Id=16,
						 System_StartDate = (SELECT MIN(Start_Date) FROM GPM_WT_Project_Deliverable WHERE WT_Project_Id=@vWT_Project_Id),
						System_EndDate=(SELECT MAX(End_Date) FROM GPM_WT_Project_Deliverable WHERE WT_Project_Id=@vWT_Project_Id)
			WHERE WT_Project_Id=@vWT_Project_Id 


			/* Add Team Members*/

						IF(LEN(@vIdeaApprover)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vIdeaApprover)
													
						IF(LEN(@vIdeaLeader)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vIdeaLeader)
										
						

						IF((SELECT COUNT(*) FROM @_vTabRoleMember)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabRoleMember

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN
								SELECT @_vRoleMember=RoleMember FROM @_vTabRoleMember WHERE id=@_vCnt
								SELECT @_vRMSepPos=CHARINDEX('|',@_vRoleMember,1)
								SELECT @_vProjectRoleId=CAST(SUBSTRING(@_vRoleMember,1, @_vRMSepPos-1) AS INT),
										@_vGDUserIdList=SUBSTRING(@_vRoleMember,@_vRMSepPos+1, len(@_vRoleMember))

							
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
									OUTPUT INSERTED.WT_Role_ID, INSERTED.GD_User_Id INTO @_vTabRoleMemberNotif (WT_Role_Id,GD_User_Id)
								SELECT  @vWT_Project_Id,
										@_vProjectRoleId, 
										TAB.Value, 
										'N', 
										@vCreated_By,
										Getdate(),
										@vCreated_By,
										Getdate()
								FROM Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB 
								

							SELECT @_vCnt=MIN(id) FROM @_vTabRoleMember WHERE id>@_vCnt
						END
					END

					
					INSERT INTO GPM_WT_Project_Notification
								(
								WT_Project_Id,
								Notification_Id,
								GD_User_Id,
								Author_User_Id,
								Notification_Desc,
								Target_Desc,
								Notification_DT,
								Read_Status
								)

								SELECT distinct @vWT_Project_Id,
								13,
								GD_User_Id,
								@vLast_Modified_By,
								'You have been assigned as '+ 
								
								SUBSTRING((
								SELECT ',' + GPTR.WT_Role_Name
									FROM GPM_Project_Template_Role GPTR INNER JOIN  @_vTabRoleMemberNotif TRN
									ON GPTR.WT_Role_Id=TRN.WT_Role_Id 
									WHERE TRN.GD_User_Id=TAB.GD_User_Id AND GPTR.WT_Code=@_vWT_Type
								FOR XML PATH('')
									),2,100000) +' for project '+ @vIdea_Name,
								@vIdea_Name,
								GETDATE(),
								'N'
								FROM (SELECT DISTINCT GD_User_Id FROM @_vTabRoleMemberNotif )TAB
						 
								
							IF (@@ERROR <> 0) GOTO ERR_HANDLER
					

					SELECT @vMsg_Out='IDEA Details Added Successfully'
	COMMIT TRAN
	RETURN 1
 

 ERR_HANDLER:
	BEGIN
		SELECT @vMsg_Out='Failed To Add IDEA Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END

GO


/****** Object:  StoredProcedure [dbo].[Sp_UpdWTIdeaDetails]    Script Date: 6/29/2019 12:46:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_UpdWTIdeaDetails]
(
	@vWT_Project_Id int,
	@vPlan_Start_Date datetime,
	@vIDEA_Number VARCHAR(15),
	@vIdea_Name nvarchar(500),
	@vRequester_Details nvarchar(4000),
	@vRegion_Code varchar(5),
	@vCountry_Code char(3),
	@vLocation_Id int,
	@vBA_Id int,
	@vDept_Id int,
	@vCost_Cat_Id int,
	@vRegTrack_Cat_Id int,
	@vPiller_Ids varchar(100),
	@vProblem_Statement nvarchar(4000),
	@vIdea_Description nvarchar(4000),
	@vConstraint_Id int,
	@vExpected_Saving_USD numeric(16,4),
	@vPayback_Period_Mon numeric(10,2),
	@vProj_Main_Cat_Id int,
	@vProj_Cat_Id int,
	@vPrim_Loss_Cat_Id Int,
	@vFN_BPO_ID Int,
	@vFeasibility_Id Int,
	@vIs_Capex Char(1),
	@vExpected_Material_Saving_USD Numeric(16,4),
	@vTW_Loss_Cat_Id Int,
	@vIdeaApprover Varchar(8000),
	@vIdeaLeader Varchar(8000),
	@vLast_Modified_By varchar(10),
	@vMsg_Out Varchar(100) OUT	
	
 )
 AS
 BEGIN

DECLARE @_vIDEA_Id INT
DECLARE @_vWT_Type Varchar(5)='IDEA'

DECLARE @_vTabRoleMember As TABLE(id INT Identity(1,1), RoleMember VARCHAR(8000))
DECLARE @_vTabRoleMemberProc As TABLE(WT_Role_Id Int, GD_User_Id VARCHAR(10))
DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRoleMember VARCHAR(8000)=NULL
DECLARE @_vProjectRoleId INT=NULL
DECLARE @_vGDUserIdList VARCHAR(4000)=NULL
DECLARE @_vRMSepPos INT=0

DECLARE @_vCurPL_Id VARCHAR(10) 
DECLARE	@_vNewPL_Id VARCHAR(10)

DECLARE @_vGPM_WT_Project_Team_Deliverable_Table AS TABLE (WT_Project_ID	INT,WT_Role_ID	INT,Gate_Id	INT, Deliverable_Id	INT)

IF (@vWT_Project_Id IS NULL OR @vWT_Project_Id<1 )
	BEGIN
		SELECT @vMsg_Out='Invalid Project id'
		RETURN 0
	END

IF (@vIDEA_Number IS NULL OR LEN(LTRIM(RTRIM(@vIDEA_Number)))<1)
	BEGIN
		SELECT @vMsg_Out='Invalid Project Number'
		RETURN 0
	END


SELECT @_vIDEA_Id=B.Idea_Id  
FROM GPM_WT_Project A INNER JOIN GPM_WT_Idea B ON A.WT_Id=B.Idea_Id AND A.WT_Project_Number=B.Idea_Number  
WHERE A.WT_Code=@_vWT_Type AND 
A.WT_Project_ID=@vWT_Project_Id AND
A.WT_Project_Number=LTRIM(RTRIM(@vIDEA_Number))  

SELECT @_vCurPL_Id=A.GD_User_Id FROM GPM_WT_Project_Team A INNER JOIN GPM_Project_Template_Role B On A.WT_Role_ID = B.WT_Role_Id
WHERE B.WT_Role_Name = 'Idea Leader' AND B.WT_Code = @_vWT_Type AND A.Is_Deleted_Ind='N' AND A.WT_Project_ID = @vWT_Project_Id

  
IF (@_vIDEA_Id IS NULL)  
	BEGIN  
		  SELECT @vMsg_Out='Project Not Found'  
		RETURN 0  
	END  
ELSE
BEGIN
BEGIN TRAN

	UPDATE GPM_WT_IDEA
		SET Idea_Name = @vIdea_Name,
			Plan_Start_Date=@vPlan_Start_Date,
			Requester_Details = @vRequester_Details,
			Region_Code = @vRegion_Code,
			Country_Code = @vCountry_Code,
			Location_Id = @vLocation_Id,
			BA_Id = @vBA_Id,
			Dept_Id = @vDept_Id,
			Cost_Cat_Id = @vCost_Cat_Id,
			RegTrack_Cat_Id = @vRegTrack_Cat_Id,
			Problem_Statement = @vProblem_Statement,
			Idea_Description = @vIdea_Description,
			Constraint_Id = @vConstraint_Id,
			Expected_Saving_USD = @vExpected_Saving_USD,
			Payback_Period_Mon = @vPayback_Period_Mon,
			Proj_Main_Cat_Id = @vProj_Main_Cat_Id,
			Proj_Cat_Id = @vProj_Cat_Id,
			Prim_Loss_Cat_Id =@vPrim_Loss_Cat_Id,
			FN_BPO_ID=@vFN_BPO_ID,
			Feasibility_Id=@vFeasibility_Id,
			Is_Capex=@vIs_Capex,
			Expected_Material_Saving_USD=@vExpected_Material_Saving_USD,
			TW_Loss_Cat_Id = @vTW_Loss_Cat_Id,
			Last_Modified_By = @vLast_Modified_By,
			Last_Modified_Date = Getdate()
		WHERE IDEA_Id=@_vIDEA_Id

			 IF (@@ERROR <> 0) GOTO ERR_HANDLER

		
	
					IF(len(@vPiller_Ids)>0)
					BEGIN
						/*Delete piller ids if not in selected list*/

						DELETE FROM GPM_WT_Idea_MS_Attrib  WHERE Idea_Id=@_vIDEA_Id	AND Piller_Id IS NOT NULL

						IF (@@ERROR <> 0) GOTO ERR_HANDLER

						/*Add piller ids if they are additonal in selected list*/
							INSERT INTO GPM_WT_Idea_MS_Attrib
								(
									Idea_Id,
									Idea_Number,
									Piller_Id,
									Created_Date,
									Created_By,
									Last_Modified_Date,
									Last_Modified_By
								)
							SELECT
								@_vIDEA_Id,
								@vIDEA_Number,
								Tab.Value,
								Getdate(),
								@vLast_Modified_By,
								Getdate(),
								@vLast_Modified_By
							FROM Fn_SplitDelimetedData(',',@vPiller_Ids) Tab

							 IF (@@ERROR <> 0) GOTO ERR_HANDLER
		
			END
			ELSE
			/*Delete All piller ids if select list is blank*/
				DELETE FROM GPM_WT_Idea_MS_Attrib  WHERE Idea_Id=@_vIDEA_Id
				AND Piller_Id IS NOT NULL



		/* Add Remove Team Members According to new member list*/

			IF(LEN(@vIdeaApprover)>0)
				INSERT INTO @_vTabRoleMember(RoleMember) Values(@vIdeaApprover)
													
			IF(LEN(@vIdeaLeader)>0)
				INSERT INTO @_vTabRoleMember(RoleMember) Values(@vIdeaLeader)


								IF((SELECT COUNT(*) FROM @_vTabRoleMember)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabRoleMember

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN
								SELECT @_vRoleMember=RoleMember FROM @_vTabRoleMember WHERE id=@_vCnt
								SELECT @_vRMSepPos=CHARINDEX('|',@_vRoleMember,1)
								SELECT @_vProjectRoleId=CAST(SUBSTRING(@_vRoleMember,1, @_vRMSepPos-1) AS INT),
										@_vGDUserIdList=SUBSTRING(@_vRoleMember,@_vRMSepPos+1, len(@_vRoleMember))

							INSERT INTO @_vTabRoleMemberProc(WT_Role_Id,GD_User_Id) 
							SELECT @_vProjectRoleId, VALUE FROM Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB 
							WHERE NOT EXISTS(SELECT 1 FROM @_vTabRoleMemberProc TPC WHERE TPC.WT_Role_Id=@_vProjectRoleId AND TPC.GD_User_Id=TAB.Value)

							/* Enable Role User List if it is already exist and is deleted*/
							UPDATE GPM_WT_Project_Team
								SET
									Is_Deleted_Ind='N',
									Last_Modified_By=@vLast_Modified_By,
									Last_Modified_Date=Getdate()
								FROM GPM_WT_Project_Team A INNER JOIN Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB On 
									A.GD_User_Id=TAB.Value
								WHERE A.WT_Project_ID=@vWT_Project_Id AND A.WT_Role_Id=@_vProjectRoleId 
								AND A.Is_Deleted_Ind='Y'

								IF (@@ERROR <> 0) GOTO ERR_HANDLER
							/* Insert New Role User List */

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
								SELECT  @vWT_Project_Id,
										@_vProjectRoleId, 
										TAB.Value, 
										'N', 
										@vLast_Modified_By,
										Getdate(),
										@vLast_Modified_By,
										Getdate()
								FROM Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB 
								WHERE NOT EXISTS(SELECT 1 FROM GPM_WT_Project_Team GWPT 
								WHERE GWPT.WT_Project_ID=@vWT_Project_Id AND GWPT.WT_Role_ID=@_vProjectRoleId
								 AND GWPT.GD_User_Id=Tab.Value)
								
									 IF (@@ERROR <> 0) GOTO ERR_HANDLER

								/*/* Disable Role User List if it is already exist and not in new list */
								UPDATE GPM_WT_Project_Team
								SET
									Is_Deleted_Ind='Y',
									Last_Modified_By=@vLast_Modified_By,
									Last_Modified_Date=Getdate()
								FROM GPM_WT_Project_Team A LEFT OUTER JOIN Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB On 
									A.GD_User_Id=TAB.Value
								WHERE A.WT_Project_ID=@vWT_Project_Id AND A.WT_Role_ID=@_vProjectRoleId 
								AND A.Is_Deleted_Ind='N' AND Tab.Value IS NULL 
								*/
							SELECT @_vCnt=MIN(id) FROM @_vTabRoleMember WHERE id>@_vCnt
						END
						/* Disable Role User List if it is already exist and not in new list */
								UPDATE GPM_WT_Project_Team
								SET
									Is_Deleted_Ind='Y',
									Last_Modified_By=@vLast_Modified_By,
									Last_Modified_Date=Getdate()
								FROM GPM_WT_Project_Team A									
								WHERE A.WT_Project_ID=@vWT_Project_Id 
								AND A.Is_Deleted_Ind='N' AND NOT EXISTS(SELECT 1 FROm @_vTabRoleMemberProc TMP WHERE TMP.WT_Role_Id=A.WT_Role_ID AND TMP.GD_User_Id=A.GD_User_Id)
							 
							 IF (@@ERROR <> 0) GOTO ERR_HANDLER

					/*Update New Project Lead To Deliveralbe_Team Table*/

								SELECT @_vNewPL_Id=GD_User_Id FROM @_vTabRoleMemberProc	WHERE WT_Role_Id = 67

								IF(@_vCurPL_Id!=@_vNewPL_Id)
								BEGIN

									INSERT INTO @_vGPM_WT_Project_Team_Deliverable_Table
										(
										WT_Project_ID,
										WT_Role_ID,
										Gate_Id,
										Deliverable_Id 
										)
									SELECT 
										WT_Project_ID,
										WT_Role_ID,
										Gate_Id,
										Deliverable_Id
									FROM
										GPM_WT_Project_Team_Deliverable
											WHERE WT_Project_ID=@vWT_Project_Id
												AND	GD_User_Id = @_vCurPL_Id AND Is_Deleted_Ind='N'

										UPDATE GPM_WT_Project_Team_Deliverable
											SET Is_Deleted_Ind='Y'
												 WHERE WT_Project_ID=@vWT_Project_Id
														AND	GD_User_Id = @_vCurPL_Id
										
										
										
										UPDATE GWPTD SET Is_Deleted_Ind='N',
													Last_Modified_By=@vLast_Modified_By,
													Last_Modified_Date=Getdate()
											 FROM GPM_WT_Project_Team_Deliverable GWPTD INNER JOIN @_vGPM_WT_Project_Team_Deliverable_Table GWPTDTM 
											ON GWPTD.WT_Project_ID=GWPTDTM.WT_Project_ID AND GWPTD.WT_Role_ID=GWPTDTM.WT_Role_ID 
												AND GWPTD.Gate_Id=GWPTDTM.Gate_Id AND GWPTD.Deliverable_Id=GWPTDTM.Deliverable_Id
											WHERE GWPTD.GD_User_Id = @_vNewPL_Id AND Is_Deleted_Ind='Y'

											
											INSERT INTO GPM_WT_Project_Team_Deliverable
												(
												WT_Project_ID,
												WT_Role_ID,
												Gate_Id,
												Deliverable_Id,
												GD_User_Id,
												Is_Deleted_Ind,
												Created_By,
												Created_Date,
												Last_Modified_By,
												Last_Modified_Date
												)
											SELECT 
												WT_Project_ID,
												WT_Role_ID,
												Gate_Id,
												Deliverable_Id,
												@_vNewPL_Id,
												'N',
												@vLast_Modified_By,
												GETDATE(),
												@vLast_Modified_By,
												GETDATE()
											 FROM @_vGPM_WT_Project_Team_Deliverable_Table GWPTDTM
												WHERE NOT EXISTS( SELECT 1 FROM GPM_WT_Project_Team_Deliverable GWPTD WHERE 
													GWPTD.WT_Project_ID=GWPTDTM.WT_Project_ID AND GWPTD.WT_Role_ID=GWPTDTM.WT_Role_ID
														AND GWPTD.Gate_Id=GWPTDTM.Gate_Id AND GWPTD.Deliverable_Id=GWPTDTM.Deliverable_Id AND GWPTD.GD_User_Id = @_vNewPL_Id)

								END
					END
			
		SELECT @vMsg_Out='IDEA Details Updated Successfully'	
				
COMMIT TRAN
RETURN 1
END
 ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Update IDEA Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END

GO








