ALTER TABLE GPM_WT_DMAIC  ALTER COLUMN DMAIC_Name NVARCHAR(500)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Defination NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Measure NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Analysis NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Improvement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Control NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_DMAIC ALTER COLUMN Project_Metric_Cp NVARCHAR(4000)
GO


/****** Object:  StoredProcedure [dbo].[Sp_AddWTDMAICDetails]    Script Date: 6/29/2019 12:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Sp_AddWTDMAICDetails]
(
	@vDMAIC_Name Nvarchar(500),
	@vPlan_Start_Date datetime,
	@vProject_Defination nvarchar(4000),
	@vProject_Measure nvarchar(4000),
	@vProject_Analysis nvarchar(4000),
	@vProject_Improvement nvarchar(4000),
	@vProject_Control nvarchar(4000),
	@vProject_Metric_Cp nvarchar(4000),
	@vRegion_Code varchar(5),
	@vCountry_Code char(3),
	@vLocation_Id int,
	@vBA_Id int,
	@vDept_Id int,
	@vFN_BPO_Id int,
	@vProduct_Cat_Id int,
	@vPiller_Ids varchar(100),
	@vProj_Main_Cat_Id int,
	@vProj_Cat_Id int,
	@vIs_CapEx char(1),
	@vCapEx_Id varchar(200),
	@vFin_Impact_Ar_Id int,
	@vCost_Cat_Id int,
	@vPrim_Loss_Cat_Id int,
	@vIs_Best_Proj_Nom Char(1),
	@vRef_Idea_Id INT=NULL,
	@vProjectLead Varchar(8000)=NULL,
	@vSponsor Varchar(8000)=NULL,
	@vFinancialRep Varchar(8000)=NULL,
	@vTeamMembers Varchar(8000)=NULL,
	@vMBBFIExpert Varchar(8000)=NULL,
	@vProcessOwners Varchar(8000)=NULL,
	--@vWT_Project_Id_RepFrom int=NULL,
	@vCreated_By varchar(10),
	@vLast_Modified_By varchar(10),
	@vDMAIC_Number Varchar(15) OUT,
	@vWT_Project_Id int OUT,
	@vMsg_Out Varchar(100) OUT
	
 )
 AS
 BEGIN


DECLARE @_vDMAIC_Number VARCHAR(15)=NULL
DECLARE @_vDMAIC_Number_SEQ INT =NULL
DECLARE @_vDMAIC_Id INT
DECLARE @_vDMAIC_Id_REP INT=NULL
DECLARE @_vWT_Type Varchar(5)='FI'
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


	IF NOT EXISTS(SELECT * FROM GPM_WT_DMAIC)
		   SELECT @_vDMAIC_Number=@_vWT_Type+'-00001'
	ELSE
	BEGIN
		   SELECT @_vDMAIC_Number_SEQ=MAX(CAST(SUBSTRING(DMAIC_Number,CHARINDEX('-',DMAIC_Number,1)+1,LEN(DMAIC_Number)) AS INT))
	FROM GPM_WT_DMAIC WHERE CHARINDEX('-',DMAIC_Number,1)>0 AND UPPER(SUBSTRING(DMAIC_Number,1, CHARINDEX('-',DMAIC_Number,1)-1))=UPPER(@_vWT_Type)
	AND ISNUMERIC(SUBSTRING(DMAIC_Number,CHARINDEX('-',DMAIC_Number,1)+1,LEN(DMAIC_Number)) )=1

		   IF(@_vDMAIC_Number_SEQ IS NULL)
				  SELECT @_vDMAIC_Number=@_vWT_Type+'-00001'
		   ELSE
				  BEGIN
						 SELECT @_vDMAIC_Number_SEQ=@_vDMAIC_Number_SEQ+1

						 IF(@_vDMAIC_Number_SEQ>99999)
						 BEGIN
							SELECT @vMsg_Out = 'Sequence Reached To Maximum Limit'
							RETURN 0
						 END
						 ELSE
							   SELECT @_vDMAIC_Number= @_vWT_Type+'-'+REPLICATE('0', 5-LEN(CAST(@_vDMAIC_Number_SEQ AS VARCHAR(10))) ) + CAST(@_vDMAIC_Number_SEQ AS VARCHAR(10))
				  END


	END


 BEGIN TRAN
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
						@_vDMAIC_Number,
						@vDMAIC_Name,
						@vPlan_Start_Date,
						@vProject_Defination,
						@vProject_Measure,
						@vProject_Analysis,
						@vProject_Improvement,
						@vProject_Control,
						@vProject_Metric_Cp,
						@vRegion_Code,
						@vCountry_Code,
						@vLocation_Id,
						@vBA_Id,
						@vDept_Id,
						@vFN_BPO_Id,
						@vProduct_Cat_Id,
						@vProj_Main_Cat_Id,
						@vProj_Cat_Id,
						@vIs_CapEx,
						@vCapEx_Id,
						@vFin_Impact_Ar_Id,
						@vCost_Cat_Id,
						@vPrim_Loss_Cat_Id,
						@vRef_Idea_Id,
						@vCreated_By,
						Getdate(),
						@vLast_Modified_By,
						Getdate(),
						@vIs_Best_Proj_Nom,
						'N',
						ISNULL(@_vDMAIC_Id_REP,NULL)
					)

					 IF (@@ERROR <> 0) GOTO ERR_HANDLER

					SELECT @_vDMAIC_Id=@@IDENTITY

					SELECT @vDMAIC_Number=@_vDMAIC_Number

					INSERT INTO GPM_WT_DMAIC_MS_Attrib
					(
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
						@_vDMAIC_Number,
						Tab.Value,
						Getdate(),
						@vCreated_By,
						Getdate(),
						@vCreated_By
					FROM Fn_SplitDelimetedData(',',@vPiller_Ids) Tab
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
						@_vDMAIC_Id,
						@_vDMAIC_Number,
						@vCreated_By,
						Getdate(),
						@vLast_Modified_By,
						Getdate()
					)

					SELECT @vWT_Project_Id=@@IDENTITY

										
				
					/* Add Gate Against DMAIC Work Type*/

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

					IF (@@ERROR <> 0) GOTO ERR_HANDLER

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

						IF(LEN(@vMBBFIExpert)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vMBBFIExpert)

						IF(LEN(@vProcessOwners)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vProcessOwners)

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
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER

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
									),2,100000) +' for project '+ @vDMAIC_Name,
								@vDMAIC_Name,
								GETDATE(),
								'N'
								FROM (SELECT DISTINCT GD_User_Id FROM @_vTabRoleMemberNotif )TAB
						 

								
							IF (@@ERROR <> 0) GOTO ERR_HANDLER



			/* SAVE TDC Default Matrics with values 0 for 3 Years (Including Current Month) Plus Previous month respective current date*/

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
									'IDEA '+GWI.Idea_Name+' has been converted into Project '+@vDMAIC_Name,
									@vDMAIC_Name,
									GETDATE(),
									'N'
									FROM GPM_WT_Idea GWI INNER JOIN GPM_WT_Project GWP On GWI.Idea_Id=GWP.WT_Id AND GWI.Idea_Number=GWP.WT_Project_Number 
									INNER JOIN GPM_WT_Project_Team GWPT On GWP.WT_Project_ID= GWPT.WT_Project_ID AND GWPT.WT_Role_ID IN(10,67)
									WHERE GWI.Idea_Id=@vRef_Idea_Id
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END
			SELECT @vMsg_Out='DMAIC Details Added Successfully'
	
	COMMIT TRAN
	RETURN 1
 

 ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Add DMAIC Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END





GO



/****** Object:  StoredProcedure [dbo].[Sp_UpdWTDMAICDetails]    Script Date: 6/29/2019 12:28:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_UpdWTDMAICDetails]  
(  
 @vWT_Project_Id int ,  
 @vDMAIC_Number Varchar(15),  
 @vDMAIC_Name Nvarchar(500),  
 @vPlan_Start_Date datetime,  
 @vProject_Defination nvarchar(4000),  
 @vProject_Measure nvarchar(4000),  
 @vProject_Analysis nvarchar(4000),  
 @vProject_Improvement nvarchar(4000),  
 @vProject_Control nvarchar(4000),  
 @vProject_Metric_Cp nvarchar(4000),  
 @vRegion_Code varchar(5),  
 @vCountry_Code char(3),  
 @vLocation_Id int,  
 @vBA_Id int,  
 @vDept_Id int,  
 @vFN_BPO_Id int,  
 @vProduct_Cat_Id int,  
 @vPiller_Ids VARCHAR(100),  
 @vProj_Main_Cat_Id int,  
 @vProj_Cat_Id int,  
 @vIs_CapEx char(1),  
 @vCapEx_Id varchar(200),  
 @vFin_Impact_Ar_Id int,  
 @vCost_Cat_Id int,  
 @vPrim_Loss_Cat_Id int,  
 @vProjectLead Varchar(8000)=NULL,
 @vSponsor Varchar(8000)=NULL,
 @vFinancialRep Varchar(8000)=NULL,
 @vTeamMembers Varchar(8000)=NULL,
 @vMBBFIExpert Varchar(8000)=NULL,
 @vProcessOwners Varchar(8000)=NULL,
 @vIs_Best_Proj_Nom char(1)=NULL,
 @vLast_Modified_By varchar(10),  
 @vMsg_Out Varchar(100) OUT  
    
 )  
 AS  
 BEGIN  
  
 DECLARE @_vDMAIC_Id INT =NULL 
 DECLARE @_vWT_Type Varchar(5)='FI'  
 
 
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
  
 IF (@vDMAIC_Number IS NULL OR LEN(LTRIM(RTRIM(@vDMAIC_Number)))<1)  
 BEGIN  
  SELECT @vMsg_Out='Invalid Project Number'  
  RETURN 0  
 END  
  
SELECT @_vDMAIC_Id=B.DMAIC_Id  
FROM GPM_WT_Project A INNER JOIN GPM_WT_DMAIC B ON A.WT_Id=B.DMAIC_Id AND A.WT_Project_Number=B.DMAIC_Number  
WHERE A.WT_Code=@_vWT_Type AND 
A.WT_Project_ID=@vWT_Project_Id AND
A.WT_Project_Number=LTRIM(RTRIM(@vDMAIC_Number))  

SELECT @_vCurPL_Id=A.GD_User_Id FROM GPM_WT_Project_Team A INNER JOIN GPM_Project_Template_Role B On A.WT_Role_ID = B.WT_Role_Id
WHERE B.WT_Role_Name = 'Project Lead' AND B.WT_Code = @_vWT_Type AND A.Is_Deleted_Ind='N' AND A.WT_Project_ID = @vWT_Project_Id

  
IF (@_vDMAIC_Id IS NULL)  
	BEGIN  
		  SELECT @vMsg_Out='Project Not Found'  
		RETURN 0  
	END  
ELSE
	BEGIN 
		BEGIN TRAN  
  
		UPDATE GPM_WT_DMAIC  
			SET DMAIC_Name = @vDMAIC_Name,  
				Plan_Start_Date = @vPlan_Start_Date,  
				Project_Defination = @vProject_Defination,  
				Project_Measure = @vProject_Measure,  
				Project_Analysis = @vProject_Analysis,  
				Project_Improvement = @vProject_Improvement,  
				Project_Control = @vProject_Control,  
				Project_Metric_Cp = @vProject_Metric_Cp,  
				Region_Code = @vRegion_Code,  
				Country_Code = @vCountry_Code,  
				Location_Id = @vLocation_Id,  
				BA_Id = @vBA_Id,  
				Dept_Id = @vDept_Id,  
				FN_BPO_Id = @vFN_BPO_Id,  
				Product_Cat_Id = @vProduct_Cat_Id,  
				Proj_Main_Cat_Id = @vProj_Main_Cat_Id,  
				Proj_Cat_Id =@vProj_Cat_Id,  
				Is_CapEx = @vIs_CapEx,  
				CapEx_Id = @vCapEx_Id,  
				Fin_Impact_Ar_Id = @vFin_Impact_Ar_Id,  
				Cost_Cat_Id = @vCost_Cat_Id,  
				Prim_Loss_Cat_Id = @vPrim_Loss_Cat_Id, 
				Is_Best_Proj_Nom=@vIs_Best_Proj_Nom, 
				Last_Modified_By = @vLast_Modified_By,  
				Last_Modified_Date = Getdate()  
		WHERE DMAIC_Id=@_vDMAIC_Id


		IF (@@ERROR <> 0) GOTO ERR_HANDLER
		
		IF(len(@vPiller_Ids)>0)
		BEGIN
			/*Delete piller ids if not in selected list*/
				DELETE FROM GPM_WT_DMAIC_MS_Attrib  WHERE DMAIC_Id=@_vDMAIC_Id
				AND Piller_Id IS NOT NULL

				IF (@@ERROR <> 0) GOTO ERR_HANDLER

			/*Add piller ids if they are additonal in selected list*/
				INSERT INTO GPM_WT_DMAIC_MS_Attrib
					(
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
					@vDMAIC_Number,
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
				DELETE FROM GPM_WT_DMAIC_MS_Attrib  WHERE DMAIC_Id=@_vDMAIC_Id
				AND Piller_Id IS NOT NULL

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

						IF(LEN(@vMBBFIExpert)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vMBBFIExpert)

						IF(LEN(@vProcessOwners)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vProcessOwners)

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
								'You have been assigned as '+ GPTR.WT_Role_Name +' for project '+ @vDMAIC_Name,
								@vDMAIC_Name,
								GETDATE(),
								'N'
								 FROM @_vTabRoleMemberNotif TRN INNER JOIN
									GPM_Project_Template_Role GPTR On TRN.WT_Role_Id=GPTR.WT_Role_Id
									WHERE GPTR.WT_Code=@_vWT_Type

							IF (@@ERROR <> 0) GOTO ERR_HANDLER
								
					END

					/*
					SELECT @_vDeliverableList=
					(
						SELECT ',' +  GGD.Deliverable_Desc FROM GPM_WT_Project_Deliverable GWPD INNER JOIN GPM_Gate_Deliverable GGD On GWPD.Gate_Id=GGD.Gate_Id
						WHERE GWPD.WT_Project_Id=@vWT_Project_Id
						FOR XML PATH('')
					)*/

  
		SELECT @vMsg_Out='DMAIC Details Updated Successfully'   
		COMMIT TRAN  
		RETURN 1  

 END     
  
 ERR_HANDLER:  
  BEGIN  
   SELECT @vMsg_Out='Failed To Update DMAIC Details-'+ ERROR_MESSAGE();  
   IF (@@TRANCOUNT>0)  
   ROLLBACK TRAN  
   RETURN 0  
  END  
 END

GO

