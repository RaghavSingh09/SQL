
ALTER TABLE GPM_WT_Procurement ALTER COLUMN PSC_Name NVARCHAR(500)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Project_Description NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Business_Case NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Baseline_Spend NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Baseline_Supp NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Est_Timeline NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Est_Proc_Resource NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_Procurement ALTER COLUMN Est_Implement_Cost NVARCHAR(4000)
GO


/****** Object:  StoredProcedure [dbo].[Sp_AddWTPSCDetails]    Script Date: 6/29/2019 1:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_AddWTPSCDetails]
(
	@vPSC_Name nvarchar(500),
    @vPlan_Start_Date datetime,
    @vProj_Track_Id int,
    @vSpend_Type_Id int,
    @vProj_Type_Id int,
    @vRate_Type_Id int,
    @vProject_Description nvarchar(4000),
    @vRegTrack_Cat_Id int,
    @vFin_Impact_Ar_Id int,
    @vGPH_Cat_Id int,
    @vGPH_Sub_Cat_Id int,
    @vRegion_Code varchar(5),
    @vCountry_Code char(3),
    @vLocation_Id int,
    @vPotential_Saving_USD numeric(16,4),
    @vSaving_Probablity_Per numeric(16,4),
    @vEst_Base_Saving_USD numeric(16,4),
    @vBusiness_Case nvarchar(4000),
    @vBaseline_Spend nvarchar(4000),
    @vBaseline_Supp nvarchar(4000),
    @vEst_Timeline nvarchar(4000),
    @vEst_Proc_Resource nvarchar(4000),
    @vEst_Implement_Cost nvarchar(4000),
	@vRef_Idea_Id INT=NULL,
	@vProjectLead Varchar(8000)=NULL,
	@vSponsor Varchar(8000)=NULL,
	@vFinancialRep Varchar(8000)=NULL,
	@vManagers Varchar(8000)=NULL,
	@vTeamMembers Varchar(8000)=NULL,
	@vCreated_Date datetime,
    @vCreated_By varchar(10),
    @vLast_Modified_Date datetime,
    @vLast_Modified_By varchar(10),
    @vPSC_Number varchar(15) OUT,
	@vWT_Project_Id int OUT,
	@vMsg_Out Varchar(100) OUT
)
AS
Begin
DECLARE @_vPSC_Number VARCHAR(15)=NULL
DECLARE @_vPSC_Number_SEQ INT =NULL
DECLARE @_vPSC_Id INT
DECLARE @_vWT_Type Varchar(5)='PSC'
DECLARE @_vTabGate AS TABLE (WT_Project_Id INT, Gate_Id INT, Gate_Order_Id INT)

DECLARE @_vTabCnt INT
DECLARE @_vMaxGateOrder INT
DECLARE @_vStartDate DATETIME=NULL
DECLARE @_vEndDate DATETIME=NULL
DECLARE @_vGate_Id INT

DECLARE @_vTDCstartDate DATE = DATEADD(MONTH, -1,  GETDATE())
DECLARE @_vTDCendDate DATE
DECLARE @_vTabTDCDate AS TABLE (Tdc_Date DATE)
DECLARE @_vMinTDCDT AS DATE

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

IF NOT EXISTS(SELECT * FROM GPM_WT_Procurement)
       SELECT @_vPSC_Number=@_vWT_Type+'-00001'
ELSE
BEGIN
       SELECT @_vPSC_Number_SEQ=MAX(CAST(SUBSTRING(PSC_Number,CHARINDEX('-',PSC_Number,1)+1,LEN(PSC_Number)) AS INT))
FROM GPM_WT_Procurement WHERE CHARINDEX('-',PSC_Number,1)>0 AND UPPER(SUBSTRING(PSC_Number,1, CHARINDEX('-',PSC_Number,1)-1))=UPPER(@_vWT_Type)
AND ISNUMERIC(SUBSTRING(PSC_Number,CHARINDEX('-',PSC_Number,1)+1,LEN(PSC_Number)) )=1

       IF(@_vPSC_Number_SEQ IS NULL)
              SELECT @_vPSC_Number=@_vWT_Type+'-00001'
       ELSE
              BEGIN
                     SELECT @_vPSC_Number_SEQ=@_vPSC_Number_SEQ+1

                     IF(@_vPSC_Number_SEQ>99999)
                     BEGIN
						SELECT @vMsg_Out = 'Sequence Reached To Maximum Limit'
						RETURN 0
					 END
                     ELSE
                           SELECT @_vPSC_Number= @_vWT_Type+'-'+REPLICATE('0', 5-LEN(CAST(@_vPSC_Number_SEQ AS VARCHAR(10))) ) + CAST(@_vPSC_Number_SEQ AS VARCHAR(10))
              END


END

BEGIN TRAN
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
								   @_vPSC_Number,
								   @vPSC_Name,
								   @vPlan_Start_Date,
								   @vProj_Track_Id,
								   @vSpend_Type_Id,
								   @vProj_Type_Id,
								   @vRate_Type_Id,
								   @vProject_Description,
								   @vRegTrack_Cat_Id,
								   @vFin_Impact_Ar_Id,
								   @vGPH_Cat_Id,
								   @vGPH_Sub_Cat_Id,
								   @vRegion_Code,
								   @vCountry_Code,
								   @vLocation_Id,
								   @vPotential_Saving_USD, 
								   @vSaving_Probablity_Per,
								   @vEst_Base_Saving_USD,
								   @vBusiness_Case,
								   @vBaseline_Spend,
								   @vBaseline_Supp,
								   @vEst_Timeline,
								   @vEst_Proc_Resource,
								   @vEst_Implement_Cost,
								   @vRef_Idea_Id,
								   'N',
								   'N',
								   GETDATE(),
								   @vCreated_By,
								   GETDATE(),
								   @vLast_Modified_By
							   )

							IF (@@ERROR <> 0) GOTO ERR_HANDLER

							SELECT @_vPSC_Id=@@IDENTITY

							SELECT @vPSC_Number=@_vPSC_Number

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
								@_vPSC_Id,
								@_vPSC_Number,
								@vCreated_By,
								Getdate(),
								@vLast_Modified_By,
								Getdate()
							)

							SELECT @vWT_Project_Id=@@IDENTITY
							IF (@@ERROR <> 0) GOTO ERR_HANDLER

					
					/* Add Gate Against Procurement Work Type*/

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


					/* Add Deliverables Against PSC Work Type*/

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
											FROM GPM_Gate_Deliverable WHERE WT_Code=@_vWT_Type AND Gate_Id=@_vGate_Id

											WHILE @_vDvCnt<(@_DvCntMax+1)
												BEGIN
				
					
													SELECT 
														@_vDeliverable_Id=Deliverable_Id,
														@_vNoOfDays=No_Of_Days,
														@_vDeliverable_Order=Deliverable_Default_Order							
														FROM GPM_Gate_Deliverable WHERE WT_Code=@_vWT_Type AND Gate_Id=@_vGate_Id AND Deliverable_Default_Order=@_vDvCnt


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
																CASE WHEN @_vDeliverable_Id IN(229,230,231,232,233,234,235,236,237,238,239) THEN 'N' ELSE 'Y' END, 
																NULL, 
																@vCreated_By, 
																GETDATE(), 
																@vLast_Modified_By, 
																GETDATE()  
															)

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
															SUBSTRING(@vProjectLead,CHARINDEX('|',@vProjectLead,1)+1, len(@vProjectLead)),
															'N'
														  ) 
	
													IF (@@ERROR <> 0) GOTO ERR_HANDLER


												SELECT @_vDvCnt=MIN(Deliverable_Default_Order) FROM GPM_Gate_Deliverable WHERE WT_Code=@_vWT_Type AND Gate_Id=@_vGate_Id AND
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

						IF(LEN(@vProjectLead)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vProjectLead)
													
						IF(LEN(@vSponsor)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vSponsor)
										
						IF(LEN(@vFinancialRep)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vFinancialRep)

						IF(LEN(@vTeamMembers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vTeamMembers)

						IF(LEN(@vManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vManagers)

						
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
								10,
								GD_User_Id,
								@vLast_Modified_By,
								'You have been assigned as '+ 
								
								SUBSTRING((
								SELECT ',' + GPTR.WT_Role_Name
									FROM GPM_Project_Template_Role GPTR INNER JOIN  @_vTabRoleMemberNotif TRN
									ON GPTR.WT_Role_Id=TRN.WT_Role_Id 
									WHERE TRN.GD_User_Id=TAB.GD_User_Id AND GPTR.WT_Code=@_vWT_Type
								FOR XML PATH('')
									),2,100000) +' for project '+ @vPSC_Name,
								@vPSC_Name,
								GETDATE(),
								'N'
								FROM (SELECT DISTINCT GD_User_Id FROM @_vTabRoleMemberNotif )TAB
						 
							IF (@@ERROR <> 0) GOTO ERR_HANDLER

			/* SAVE TDC Default Matrics with values 0 for 3 Years (Including Current Month) Plus Previous month respective current date*/
			/*
			IF (@vPlan_Start_Date IS NOT NULL)
				SELECT @_vTDCstartDate = DATEADD(MONTH, -1,  @vPlan_Start_Date)
			ELSE
				SELECT @_vTDCstartDate = DATEADD(MONTH, -1,  GETDATE())

			SELECT @_vTDCendDate = DATEADD(MONTH, 35,  @_vTDCstartDate)
			*/

			IF (@vPlan_Start_Date IS NOT NULL)
				SELECT @_vTDCstartDate = DATEADD(YEAR, -2,  @vPlan_Start_Date)
			ELSE
				SELECT @_vTDCstartDate = DATEADD(YEAR, -2,  GETDATE())

			

			IF (@vPlan_Start_Date IS NOT NULL)
				SELECT @_vTDCendDate = DATEADD(YEAR, 3,  @vPlan_Start_Date)
			ELSE
				SELECT @_vTDCendDate = DATEADD(YEAR, 3,  GETDATE())

				UPDATE GPM_WT_Project 
							SET Metric_ActFcst_StartDate=@_vTDCstartDate, 
								Metric_ActFcst_EndDate=@_vTDCendDate,
								Metric_Baseline_StartDate=@_vTDCstartDate,
								Metric_Baseline_EndDate=@_vTDCendDate
				WHERE WT_Project_ID=@vWT_Project_Id


			  
			;WITH CTE AS
			 (
				SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
  				UNION ALL
   			    SELECT DATEADD(MONTH, 1, Dates)
				FROM CTE
				WHERE CONVERT(DATE, Dates) <= CONVERT(DATE, @_vTDCendDate)
			)
			INSERT INTO @_vTabTDCDate(Tdc_Date)
			SELECT Dates  FROM CTE

			/*
			SELECT @_vMinTDCDT=MIN(Tdc_Date) FROM @_vTabTDCDate

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
				VALUES
				(
						@vWT_Project_Id, 
						56, 
						CAST(CONVERT(CHAR(6),@_vMinTDCDT, 112) AS INT),
						DATENAME(YEAR, @_vMinTDCDT),
						FORMAT(@_vMinTDCDT,'MMM'),
						0,
						0,
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				
				)*/

				/*Save TDC Actual And Forecast*/
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
				/*
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='SAVINGS' AND A.Is_Computed_Attrib='N'
				UNION ALL
				*/
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='LOSS AMOUNT' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='WC IMPROVEMENT' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 
						(CASE WHEN A.Attrib_Id=18 THEN 1 ELSE 0 END)
						END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='GROSS SAVINGS' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='(HW)/TW' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='COST AVOIDANCE' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='COST OF SAVINGS' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='CONVERSION SCORECARD' AND A.Is_Computed_Attrib='N' 

				IF (@@ERROR <> 0) GOTO ERR_HANDLER


				/*Save TDC for Base Line*/
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
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='LOSS AMOUNT' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='WC IMPROVEMENT' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 
						(CASE WHEN A.Attrib_Id=18 THEN 1 ELSE 0 END)
						END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='GROSS SAVINGS' AND A.Is_Computed_Attrib='N'
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='(HW)/TW' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='COST AVOIDANCE' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='COST OF SAVINGS' AND A.Is_Computed_Attrib='N' 
				UNION ALL
				SELECT  @vWT_Project_Id, 
						A.Attrib_Id, 
						CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) As YearMonth,  
						DATENAME(YEAR, B.Tdc_Date),
						FORMAT(B.Tdc_Date,'MMM'), 
						0, 
						CASE WHEN CAST(CONVERT(CHAR(6),B.Tdc_Date, 112) AS INT) = CAST(CONVERT(CHAR(6),@_vTDCstartDate, 112) AS INT) THEN 1 ELSE 0 END, 
						@vCreated_By, 
						GETDATE(),
						@vLast_Modified_By, 
						GETDATE() 
				FROM GPM_Metrics_TDC_Saving A CROSS JOIN @_vTabTDCDate B 
				WHERE A.Attrib_Type='CONVERSION SCORECARD' AND A.Is_Computed_Attrib='N' 

				IF (@@ERROR <> 0) GOTO ERR_HANDLER

				IF (@vRef_Idea_Id IS NOT NULL AND @vRef_Idea_Id>0)
				BEGIN

				INSERT INTO GPM_WT_Project_Attachment 
						(
						WT_Project_Id,
						Gate_id,
						Attachment_Loc,
						Attachment_Name,
						Work_Desc,
						Description,
						Is_Locked,
						Status_Id,
						Created_By,
						Createda_Date,
						Last_Modified_By,
						Last_Modified_Date,
						Attachment_Size
						)
					SELECT 
						@vWT_Project_Id,
						NULL,
						GWPA.Attachment_Loc,
						GWPA.Attachment_Name,
						GWPA.Work_Desc,
						GWPA.Description,
						GWPA.Is_Locked,
						GWPA.Status_Id,
						@vCreated_By,
						GETDATE(),
						@vCreated_By,
						Getdate(),
						GWPA.Attachment_Size
					FROM GPM_WT_Idea GWI INNER JOIN GPM_WT_Project GWP On GWI.Idea_Id=GWP.WT_Id AND GWI.Idea_Number=GWP.WT_Project_Number 
							INNER JOIN GPM_WT_Project_Attachment  GWPA On GWP.WT_Project_Id=GWPA.WT_Project_Id
					WHERE GWI.Idea_Id=@vRef_Idea_Id

					IF (@@ERROR <> 0) GOTO ERR_HANDLER
				END

				IF(@vRef_Idea_Id IS NOT NULL OR @vRef_Idea_Id>0)
					BEGIN
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

								SELECT DISTINCT @vWT_Project_Id,
									16,
									GWPT.GD_User_Id,
									@vLast_Modified_By,
									'IDEA '+GWI.Idea_Name+' has been converted into Project '+@vPSC_Name,
									@vPSC_Name,
									GETDATE(),
									'N'
									FROM GPM_WT_Idea GWI INNER JOIN GPM_WT_Project GWP On GWI.Idea_Id=GWP.WT_Id AND GWI.Idea_Number=GWP.WT_Project_Number 
									INNER JOIN GPM_WT_Project_Team GWPT On GWP.WT_Project_ID= GWPT.WT_Project_ID AND GWPT.WT_Role_ID IN(10,67)
									WHERE GWI.Idea_Id=@vRef_Idea_Id
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END

			SELECT @vMsg_Out='Procurement Details Added Successfully'
	COMMIT TRAN
	RETURN 1
 

 ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Add Procurement Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END
GO

/****** Object:  StoredProcedure [dbo].[Sp_UpdWTPSCDetails]    Script Date: 6/29/2019 1:16:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_UpdWTPSCDetails]
(
	@vWT_Project_Id int,
	@vPSC_Number varchar(15),
	@vPSC_Name nvarchar(500),
    @vPlan_Start_Date datetime,
    @vProj_Track_Id int,
    @vSpend_Type_Id int,
    @vProj_Type_Id int,
    @vRate_Type_Id int,
    @vProject_Description nvarchar(4000),
    @vRegTrack_Cat_Id int,
    @vFin_Impact_Ar_Id int,
    @vGPH_Cat_Id int,
	@vGPH_Sub_Cat_Id int,
    @vRegion_Code varchar(5),
    @vCountry_Code char(3),
    @vLocation_Id int,
    @vPotential_Saving_USD numeric(16,4),
    @vSaving_Probablity_Per numeric(16,4),
    @vEst_Base_Saving_USD numeric(16,4),
    @vBusiness_Case nvarchar(4000),
    @vBaseline_Spend nvarchar(4000),
    @vBaseline_Supp nvarchar(4000),
    @vEst_Timeline nvarchar(4000),
    @vEst_Proc_Resource nvarchar(4000),
    @vEst_Implement_Cost nvarchar(4000),
	@vProjectLead Varchar(8000)=NULL,
	@vSponsor Varchar(8000)=NULL,
	@vFinancialRep Varchar(8000)=NULL,
	@vManager Varchar(8000)=NULL,
	@vTeamMembers Varchar(8000)=NULL,
    @vLast_Modified_By varchar(10),
	@vMsg_Out Varchar(100) OUT

 )
 AS
 BEGIN

DECLARE @_vPSC_Id INT
DECLARE @_vWT_Type Varchar(5)='PSC'

DECLARE @_vTabRoleMember As TABLE(id INT Identity(1,1), RoleMember VARCHAR(8000))
DECLARE @_vTabRoleMemberProc As TABLE(WT_Role_Id Int, GD_User_Id VARCHAR(10))
DECLARE @_vTabRoleMemberNotif As TABLE(WT_Role_Id INT,GD_User_Id VARCHAR(10))
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

IF (@vPSC_Number IS NULL OR LEN(LTRIM(RTRIM(@vPSC_Number)))<1)
	BEGIN
		SELECT @vMsg_Out='Invalid Project Number'
		RETURN 0
	END


SELECT @_vPSC_Id=B.PSC_Id  
FROM GPM_WT_Project A INNER JOIN GPM_WT_Procurement B ON A.WT_Id=B.PSC_Id AND A.WT_Project_Number=B.PSC_Number  
WHERE A.WT_Code=@_vWT_Type AND 
A.WT_Project_ID=@vWT_Project_Id AND
A.WT_Project_Number=LTRIM(RTRIM(@vPSC_Number)) 

SELECT @_vCurPL_Id=A.GD_User_Id FROM GPM_WT_Project_Team A INNER JOIN GPM_Project_Template_Role B On A.WT_Role_ID = B.WT_Role_Id
WHERE B.WT_Role_Name = 'Project Lead' AND B.WT_Code = @_vWT_Type AND A.Is_Deleted_Ind='N' AND A.WT_Project_ID = @vWT_Project_Id

IF (@_vPSC_Id IS NULL)
	BEGIN
		SELECT @vMsg_Out='Project Not Found'
		RETURN 0
	END


BEGIN TRAN

	UPDATE GPM_WT_Procurement
		   SET PSC_Name  =  @vPSC_Name,		   
			   Plan_Start_Date  =  @vPlan_Start_Date,
			   Proj_Track_Id  =  @vProj_Track_Id,
			   Spend_Type_Id  =  @vSpend_Type_Id,
			   Proj_Type_Id  =  @vProj_Type_Id,
			   Rate_Type_Id  =  @vRate_Type_Id,
			   Project_Description  =  @vProject_Description,
			   RegTrack_Cat_Id  =  @vRegTrack_Cat_Id,
			   Fin_Impact_Ar_Id  =  @vFin_Impact_Ar_Id,
			   GPH_Cat_Id = @vGPH_Cat_Id,
			   GPH_Sub_Cat_Id = @vGPH_Sub_Cat_Id,
			   Region_Code  =  @vRegion_Code,
			   Country_Code  =  @vCountry_Code,
			   Location_Id  =  @vLocation_Id,
			   Potential_Saving_USD  =  @vPotential_Saving_USD,
			   Saving_Probablity_Per  =  @vSaving_Probablity_Per,
			   Est_Base_Saving_USD  =  @vEst_Base_Saving_USD,
			   Business_Case  =  @vBusiness_Case,
			   Baseline_Spend  =  @vBaseline_Spend,
			   Baseline_Supp  =  @vBaseline_Supp,
			   Est_Timeline  =  @vEst_Timeline,
			   Est_Proc_Resource  =  @vEst_Proc_Resource,
			   Est_Implement_Cost  =  @vEst_Implement_Cost,
			   Last_Modified_By = @vLast_Modified_By,
			   Last_Modified_Date = Getdate()
		WHERE PSC_Id=@_vPSC_Id

		IF (@@ERROR <> 0) GOTO ERR_HANDLER

		/* Add Remove Team Members According to new member list*/

						IF(LEN(@vProjectLead)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vProjectLead)
													
						IF(LEN(@vSponsor)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vSponsor)
										
						IF(LEN(@vFinancialRep)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vFinancialRep)

						IF(LEN(@vTeamMembers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vTeamMembers)

						IF(LEN(@vManager)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vManager)

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
								OUTPUT INSERTED.WT_Role_ID, INSERTED.GD_User_Id INTO @_vTabRoleMemberNotif (WT_Role_Id,GD_User_Id)
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
								OUTPUT INSERTED.WT_Role_ID, INSERTED.GD_User_Id INTO @_vTabRoleMemberNotif (WT_Role_Id,GD_User_Id)
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

								SELECT @_vNewPL_Id=GD_User_Id FROM @_vTabRoleMemberProc	WHERE WT_Role_Id = (SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code=@_vWT_Type AND WT_Role_Name = 'Project Lead' AND Is_Deleted_Ind='N')

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

							IF (@@ERROR <> 0) GOTO ERR_HANDLER


							/* Send Notification */
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
								10,
								GD_User_Id,
								@vLast_Modified_By,
								'You have been assigned as '+ GPTR.WT_Role_Name +' for project '+ @vPSC_Name,
								@vPSC_Name,
								GETDATE(),
								'N'
								 FROM @_vTabRoleMemberNotif TRN INNER JOIN
									GPM_Project_Template_Role GPTR On TRN.WT_Role_Id=GPTR.WT_Role_Id
									WHERE GPTR.WT_Code=@_vWT_Type

							IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END

		SELECT @vMsg_Out='Procurement Details Updated Successfully'	
				
COMMIT TRAN
RETURN 1

 ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Update Procurement Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END

GO 








