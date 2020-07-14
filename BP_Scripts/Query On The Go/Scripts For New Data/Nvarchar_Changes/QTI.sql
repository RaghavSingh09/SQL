ALTER TABLE GPM_WT_NMTP ALTER COLUMN QTI_Name NVARCHAR(500)
GO

ALTER TABLE GPM_WT_NMTP ALTER COLUMN Code_Name NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN XCode_Desc NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Material_Trade_Name NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN ARD_Desc NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Network_Desc NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Unique_Desc NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN MIS_VPS_Desc NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN VSDS_Number NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Company_Name NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Plant_Location NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Contact_Name NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Agent_Company_Name NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Agent_Contatc_Name NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN PTM_Lead_Time NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN CSIS_Desc NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Vendor_Code NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Plant_Raw_Mat_Plan NVARCHAR(800)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Plant_Tech_Contact NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN COA_PPK_Data_Need NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Trial_Desc NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Dipped_Fabric_Width NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Spool_Length NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Spool_Type NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN VPS_Template NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Yarn_Type NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Construction NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Twist NVARCHAR(200)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Total_Ends NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN EPI NVARCHAR(100)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Treatment_Width NVARCHAR(100)
GO





ALTER TABLE GPM_WT_NMTP ALTER COLUMN Comments NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN SIS_New_Supp NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Requirement_Acpt NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Requirement_Excpt NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN PLS_Concept_Check NVARCHAR(4000)
GO


ALTER TABLE GPM_WT_NMTP ALTER COLUMN SQA_S1_Supp_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN SQA_S1_Concept_Check NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN SC_S1_Supp_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Packaging_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Mode_Requirement NVARCHAR(4000)
GO


ALTER TABLE GPM_WT_NMTP ALTER COLUMN Intermediate_Dest NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN QA_S1_Supp_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Beyond_Spec_Data_Need NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Plant_Spec_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Trial_Treatment NVARCHAR(4000)
GO


ALTER TABLE GPM_WT_NMTP ALTER COLUMN Proc_Vol_Trial_Duration NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Tech_Req_Data_Need NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN GMS_S2_Test_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Tire_SKU_Trial NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN GY_Supp_Spec_Diff NVARCHAR(4000)
GO


ALTER TABLE GPM_WT_NMTP ALTER COLUMN Supp_Cap_GY_Req NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN PS_S1_Supp_Requirement NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Plant_HSE_Review NVARCHAR(4000)
GO
ALTER TABLE GPM_WT_NMTP ALTER COLUMN Other_Consideration NVARCHAR(4000)
GO


/****** Object:  StoredProcedure [dbo].[Sp_AddWTNMTPDetails]    Script Date: 6/29/2019 1:05:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_AddWTNMTPDetails]
(
		   @vQTI_Name varchar(500),
           @vPlan_Start_Date datetime,
           @vMaterial_Cat_Id int,
           @vMaterial_Id int,
           @vMaterial_Group_Id int,
           @vProgram_Id int,
           @vPlant_Trial_Id int,
           @vValue_Date datetime,
           @vCode_Name nvarchar(200),
           @vXCode_Desc nvarchar(800),
           @vMaterial_Trade_Name nvarchar(800),
           @vARD_Desc nvarchar(800),
           @vNetwork_Desc nvarchar(800),
           @vUnique_Desc nvarchar(200),
           @vMIS_VPS_Desc nvarchar(800),
           @vVPS_Scheduled_Date datetime,
           @vVSDS_Number nvarchar(800),
           @vSupp_Company_Name nvarchar(800),
           @vSupp_Plant_Location nvarchar(800),
           @vSupp_Contact_Name varchar(200),
           @vSupp_Email varchar(100),
           @vSupp_Phone varchar(100),
           @vAgent_Company_Name nvarchar(800),
           @vAgent_Contatc_Name nvarchar(800),
           @vAgent_Email varchar(100),
           @vAgent_Phone varchar(100),
           @vPTM_Lead_Time nvarchar(100),
           @vCSIS_Desc nvarchar(200),
           @vVendor_Code nvarchar(200),
           @vRequired_Doc char(1),
           @vMat_Ship_Once char(1),
           @vComments nvarchar(4000),
           @vSIS_New_Supp nvarchar(4000),
           @vSupp_Requirement_Acpt nvarchar(4000),
           @vSupp_Requirement_Excpt nvarchar(4000),
           @vPLS_Concept_Check nvarchar(4000),
           @vSQA_S1_Supp_Requirement nvarchar(4000),
           @vSQA_S1_Concept_Check nvarchar(4000),
           @vSupp_Complaint char(1),
           @vPlant_Raw_Mat_Plan nvarchar(800),
           @vSC_S1_Supp_Requirement nvarchar(4000),
           @vPackaging_Requirement nvarchar(4000),
           @vPackaging_Req_Met char(1),
           @vMode_Requirement nvarchar(4000),
           @vMode_Requirement_Met char(1),
           @vImport_License_Required char(1),
           @vProc_Trial_Required char(1),
           @vTotal_Qty_Need int,
           @vPlant_Tech_Contact nvarchar(200),
           @vIntermediate_Dest nvarchar(4000),
           @vQA_S1_Supp_Requirement nvarchar(4000),
           @vCOA_PPK_Data_Need nvarchar(200),
           @vBeyond_Spec_Data_Need nvarchar(4000),
           @vPlant_Spec_Requirement nvarchar(4000),
           @vOther_Trial_Required char(1),
           @vTrial_Desc nvarchar(200),
           @vTrial_Treatment nvarchar(4000),
           @vDipped_Fabric_Width nvarchar(100),
           @vSpool_Length nvarchar(100),
           @vSpool_Type nvarchar(100),
           @vVPS_Template nvarchar(200),
           @vProc_Vol_Trial_Duration nvarchar(4000),
           @vProduct_Group_Id INT,
           @vTech_Req_Data_Need nvarchar(4000),
           @vGD_Spec_Same char(1),
           @vGD_Test_Method_Same char(1),
           @vSupp_Spec_Need char(1),
           @vSupp_Test_Method_Need char(1),
           @vGMS_S2_Test_Requirement nvarchar(4000),
           @vTire_Qty_Per_Trial int,
           @vTire_SKU_Trial nvarchar(4000),
           @vPlant_Vol_Need char(1),
           @vYarn_Type nvarchar(200),
           @vConstruction nvarchar(200),
           @vTwist nvarchar(200),
           @vTotal_Ends nvarchar(100),
           @vEPI nvarchar(100),
           @vTreatment_Width nvarchar(100),
           @vGY_Supp_Spec_Diff nvarchar(4000),
           @vSupp_Cap_GY_Req nvarchar(4000),
           @vSupp_Sign char(1),
           @vPS_S1_Supp_Requirement nvarchar(4000),
           @vSDS_Needed char(1),
           @vSDS_Received char(1),
           @vSDS_Ok char(1),
           @vCIRF_Needed char(1),
           @vCIRF_Received char(1),
           @vREACH_INV_Status_Ok char(1),
           @vHAPFree_Letter_Needed char(1),
           @vEHS_Proc_QS_Needed char(1),
           @vPlant_HSE_Review nvarchar(4000),
           @vOther_Consideration nvarchar(4000),
           @vRegion_Code varchar(5),
           @vCountry_Code char(3),
           @vLocation_Id int,
		   @vRef_Idea_Id INT=NULL,
		   @vProjectLead VARCHAR(8000),
		   @vTeamMembers VARCHAR(8000),
		   @vGBMaterialScienceManagers VARCHAR(8000),
		   @vGBProcurementCategoryManager VARCHAR(8000),
		   @vGBProcurementFinanceManagers VARCHAR(8000),
		   @vGBProductStewardshipManagers VARCHAR(8000),
		   @vSupplierDevelopmentManagers VARCHAR(8000),
           @vCreated_By varchar(10),
           @vLast_Modified_By varchar(10),
		   @vQTI_Number varchar(15) OUT,
		   @vWT_Project_Id int OUT,
		   @vMsg_Out Varchar(100) OUT
)
AS
Begin

DECLARE @_vQTI_Number VARCHAR(15)=NULL
DECLARE @_vQTI_Number_SEQ INT =NULL
DECLARE @_vQTI_Id INT
DECLARE @_vWT_Type Varchar(5)='RD'
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

IF NOT EXISTS(SELECT * FROM GPM_WT_NMTP)
       SELECT @_vQTI_Number=@_vWT_Type+'-00001'
ELSE
BEGIN
       SELECT @_vQTI_Number_SEQ=MAX(CAST(SUBSTRING(QTI_Number,CHARINDEX('-',QTI_Number,1)+1,LEN(QTI_Number)) AS INT))
FROM GPM_WT_NMTP WHERE CHARINDEX('-',QTI_Number,1)>0 AND UPPER(SUBSTRING(QTI_Number,1, CHARINDEX('-',QTI_Number,1)-1))=UPPER(@_vWT_Type)
AND ISNUMERIC(SUBSTRING(QTI_Number,CHARINDEX('-',QTI_Number,1)+1,LEN(QTI_Number)) )=1

       IF(@_vQTI_Number_SEQ IS NULL)
              SELECT @_vQTI_Number=@_vWT_Type+'-00001'
       ELSE
              BEGIN
                     SELECT @_vQTI_Number_SEQ=@_vQTI_Number_SEQ+1

                     IF(@_vQTI_Number_SEQ>99999)
                    BEGIN
						SELECT @vMsg_Out = 'Sequence Reached To Maximum Limit'
						RETURN 0
					 END
                     ELSE
                           SELECT @_vQTI_Number= @_vWT_Type+'-'+REPLICATE('0', 5-LEN(CAST(@_vQTI_Number_SEQ AS VARCHAR(10))) ) + CAST(@_vQTI_Number_SEQ AS VARCHAR(10))
              END


END

BEGIN TRAN
					
					INSERT INTO GPM_WT_NMTP
							(
								QTI_Number,
								QTI_Name,
								Plan_Start_Date,
								Material_Cat_Id,
								Material_Id,
								Material_Group_Id,
								Program_Id,
								Plant_Trial_Id,
								Value_Date,
								Code_Name,
								XCode_Desc,
								Material_Trade_Name,
								ARD_Desc,
								Network_Desc,
								Unique_Desc,
								MIS_VPS_Desc,
								VPS_Scheduled_Date,
								VSDS_Number,
								Supp_Company_Name,
								Supp_Plant_Location,
								Supp_Contact_Name,
								Supp_Email,
								Supp_Phone,
								Agent_Company_Name,
								Agent_Contatc_Name,
								Agent_Email,
								Agent_Phone,
								PTM_Lead_Time,
								CSIS_Desc,
								Vendor_Code,
								Required_Doc,
								Mat_Ship_Once,
								Comments,
								SIS_New_Supp,
								Supp_Requirement_Acpt,
								Supp_Requirement_Excpt,
								PLS_Concept_Check,
								SQA_S1_Supp_Requirement,
								SQA_S1_Concept_Check,
								Supp_Complaint,
								Plant_Raw_Mat_Plan,
								SC_S1_Supp_Requirement,
								Packaging_Requirement,
								Packaging_Req_Met,
								Mode_Requirement,
								Mode_Requirement_Met,
								Import_License_Required,
								Proc_Trial_Required,
								Total_Qty_Need,
								Plant_Tech_Contact,
								Intermediate_Dest,
								QA_S1_Supp_Requirement,
								COA_PPK_Data_Need,
								Beyond_Spec_Data_Need,
								Plant_Spec_Requirement,
								Other_Trial_Required,
								Trial_Desc,
								Trial_Treatment,
								Dipped_Fabric_Width,
								Spool_Length,
								Spool_Type,
								VPS_Template,
								Proc_Vol_Trial_Duration,
								Product_Group_Id,
								Tech_Req_Data_Need,
								GD_Spec_Same,
								GD_Test_Method_Same,
								Supp_Spec_Need,
								Supp_Test_Method_Need,
								GMS_S2_Test_Requirement,
								Tire_Qty_Per_Trial,
								Tire_SKU_Trial,
								Plant_Vol_Need,
								Yarn_Type,
								Construction,
								Twist,
								Total_Ends,
								EPI,
								Treatment_Width,
								GY_Supp_Spec_Diff,
								Supp_Cap_GY_Req,
								Supp_Sign,
								PS_S1_Supp_Requirement,
								SDS_Needed,
								SDS_Received,
								SDS_Ok,
								CIRF_Needed,
								CIRF_Received,
								REACH_INV_Status_Ok,
								HAPFree_Letter_Needed,
								EHS_Proc_QS_Needed,
								Plant_HSE_Review,
								Other_Consideration,
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
								@_vQTI_Number,
								@vQTI_Name,
								@vPlan_Start_Date,
								@vMaterial_Cat_Id,
								@vMaterial_Id,
								@vMaterial_Group_Id,
								@vProgram_Id,
								@vPlant_Trial_Id,
								@vValue_Date,
								@vCode_Name,
								@vXCode_Desc,
								@vMaterial_Trade_Name,
								@vARD_Desc,
								@vNetwork_Desc,
								@vUnique_Desc,
								@vMIS_VPS_Desc,
								@vVPS_Scheduled_Date,
								@vVSDS_Number,
								@vSupp_Company_Name,
								@vSupp_Plant_Location,
								@vSupp_Contact_Name,
								@vSupp_Email,
								@vSupp_Phone,
								@vAgent_Company_Name,
								@vAgent_Contatc_Name,
								@vAgent_Email,
								@vAgent_Phone,
								@vPTM_Lead_Time,
								@vCSIS_Desc,
								@vVendor_Code,
								@vRequired_Doc,
								@vMat_Ship_Once,
								@vComments,
								@vSIS_New_Supp,
								@vSupp_Requirement_Acpt,
								@vSupp_Requirement_Excpt,
								@vPLS_Concept_Check,
								@vSQA_S1_Supp_Requirement,
								@vSQA_S1_Concept_Check,
								@vSupp_Complaint,
								@vPlant_Raw_Mat_Plan,
								@vSC_S1_Supp_Requirement,
								@vPackaging_Requirement,
								@vPackaging_Req_Met,
								@vMode_Requirement,
								@vMode_Requirement_Met,
								@vImport_License_Required,
								@vProc_Trial_Required,
								@vTotal_Qty_Need,
								@vPlant_Tech_Contact,
								@vIntermediate_Dest,
								@vQA_S1_Supp_Requirement,
								@vCOA_PPK_Data_Need,
								@vBeyond_Spec_Data_Need,
								@vPlant_Spec_Requirement,
								@vOther_Trial_Required,
								@vTrial_Desc,
								@vTrial_Treatment,
								@vDipped_Fabric_Width,
								@vSpool_Length,
								@vSpool_Type,
								@vVPS_Template,
								@vProc_Vol_Trial_Duration,
								@vProduct_Group_Id,
								@vTech_Req_Data_Need,
								@vGD_Spec_Same,
								@vGD_Test_Method_Same,
								@vSupp_Spec_Need,
								@vSupp_Test_Method_Need,
								@vGMS_S2_Test_Requirement,
								@vTire_Qty_Per_Trial,
								@vTire_SKU_Trial,
								@vPlant_Vol_Need,
								@vYarn_Type,
								@vConstruction,
								@vTwist,
								@vTotal_Ends,
								@vEPI,
								@vTreatment_Width,
								@vGY_Supp_Spec_Diff,
								@vSupp_Cap_GY_Req,
								@vSupp_Sign,
								@vPS_S1_Supp_Requirement,
								@vSDS_Needed,
								@vSDS_Received,
								@vSDS_Ok,
								@vCIRF_Needed,
								@vCIRF_Received,
								@vREACH_INV_Status_Ok,
								@vHAPFree_Letter_Needed,
								@vEHS_Proc_QS_Needed,
								@vPlant_HSE_Review,
								@vOther_Consideration,
								@vRegion_Code,
								@vCountry_Code,
								@vLocation_Id,
								@vRef_Idea_Id,
								'N',
								'N',
								GETDATE(),
								@vCreated_By,
								GETDATE(),
								@vLast_Modified_By
							)


							IF (@@ERROR <> 0) GOTO ERR_HANDLER

							SELECT @_vQTI_Id=@@IDENTITY

							SELECT @vQTI_Number=@_vQTI_Number

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
								@_vQTI_Id,
								@_vQTI_Number,
								@vCreated_By,
								Getdate(),
								@vLast_Modified_By,
								Getdate()
							)

							SELECT @vWT_Project_Id=@@IDENTITY
							IF (@@ERROR <> 0) GOTO ERR_HANDLER

					/* Add Gate Against NMTP Work Type*/

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
																NULL, 
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
															(SELECT WT_Role_Id FROM GPM_Project_Template_Role WHERE WT_Code= @_vWT_Type AND WT_Role_Name = 'Deliverable Leader' AND Is_Deleted_Ind='N'),
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
													
						IF(LEN(@vTeamMembers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vTeamMembers)
										
						IF(LEN(@vGBMaterialScienceManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGBMaterialScienceManagers)

						IF(LEN(@vGBProcurementCategoryManager)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGBProcurementCategoryManager)

						IF(LEN(@vGBProcurementFinanceManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGBProcurementFinanceManagers)

						IF(LEN(@vGBProductStewardshipManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGBProductStewardshipManagers)

						IF(LEN(@vSupplierDevelopmentManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vSupplierDevelopmentManagers)

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
									),2,100000) +' for project '+ @vQTI_Name,
								@vQTI_Name,
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
			/*
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
				*/
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
									'IDEA '+GWI.Idea_Name+' has been converted into Project '+@vQTI_Name,
									@vQTI_Name,
									GETDATE(),
									'N'
									FROM GPM_WT_Idea GWI INNER JOIN GPM_WT_Project GWP On GWI.Idea_Id=GWP.WT_Id AND GWI.Idea_Number=GWP.WT_Project_Number 
									INNER JOIN GPM_WT_Project_Team GWPT On GWP.WT_Project_ID= GWPT.WT_Project_ID AND GWPT.WT_Role_ID IN(10,67)
									WHERE GWI.Idea_Id=@vRef_Idea_Id
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END

			SELECT @vMsg_Out='QTI Details Added Successfully'
	COMMIT TRAN
	RETURN 1
 

 ERR_HANDLER:
	BEGIN
		SELECT @vMsg_Out='Failed To Add QTI Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END

END

GO

/****** Object:  StoredProcedure [dbo].[Sp_UpdWTNMTPDetails]    Script Date: 6/29/2019 1:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_UpdWTNMTPDetails]
(
		   @vWT_Project_Id int,
		   @vQTI_Number varchar(15),
		   @vQTI_Name varchar(500),
           @vPlan_Start_Date datetime,
           @vMaterial_Cat_Id int,
           @vMaterial_Id int,
           @vMaterial_Group_Id int,
           @vProgram_Id int,
           @vPlant_Trial_Id int,
           @vValue_Date datetime,
           @vCode_Name nvarchar(200),
           @vXCode_Desc nvarchar(800),
           @vMaterial_Trade_Name nvarchar(800),
           @vARD_Desc nvarchar(800),
           @vNetwork_Desc nvarchar(800),
           @vUnique_Desc nvarchar(200),
           @vMIS_VPS_Desc nvarchar(800),
           @vVPS_Scheduled_Date datetime,
           @vVSDS_Number nvarchar(800),
           @vSupp_Company_Name nvarchar(800),
           @vSupp_Plant_Location nvarchar(800),
           @vSupp_Contact_Name nvarchar(200),
           @vSupp_Email varchar(100),
           @vSupp_Phone varchar(100),
           @vAgent_Company_Name nvarchar(800),
           @vAgent_Contatc_Name nvarchar(800),
           @vAgent_Email varchar(100),
           @vAgent_Phone varchar(100),
           @vPTM_Lead_Time nvarchar(100),
           @vCSIS_Desc nvarchar(200),
           @vVendor_Code nvarchar(200),
           @vRequired_Doc char(1),
           @vMat_Ship_Once char(1),
           @vComments nvarchar(4000),
           @vSIS_New_Supp nvarchar(4000),
           @vSupp_Requirement_Acpt nvarchar(4000),
           @vSupp_Requirement_Excpt nvarchar(4000),
           @vPLS_Concept_Check nvarchar(4000),
           @vSQA_S1_Supp_Requirement nvarchar(4000),
           @vSQA_S1_Concept_Check nvarchar(4000),
           @vSupp_Complaint char(1),
           @vPlant_Raw_Mat_Plan nvarchar(800),
           @vSC_S1_Supp_Requirement nvarchar(4000),
           @vPackaging_Requirement nvarchar(4000),
           @vPackaging_Req_Met char(1),
           @vMode_Requirement nvarchar(4000),
           @vMode_Requirement_Met char(1),
           @vImport_License_Required char(1),
           @vProc_Trial_Required char(1),
           @vTotal_Qty_Need int,
           @vPlant_Tech_Contact nvarchar(200),
           @vIntermediate_Dest nvarchar(4000),
           @vQA_S1_Supp_Requirement nvarchar(4000),
           @vCOA_PPK_Data_Need nvarchar(200),
           @vBeyond_Spec_Data_Need nvarchar(4000),
           @vPlant_Spec_Requirement nvarchar(4000),
           @vOther_Trial_Required char(1),
           @vTrial_Desc nvarchar(200),
           @vTrial_Treatment nvarchar(4000),
           @vDipped_Fabric_Width nvarchar(100),
           @vSpool_Length nvarchar(100),
           @vSpool_Type nvarchar(100),
           @vVPS_Template nvarchar(200),
           @vProc_Vol_Trial_Duration nvarchar(4000),
           @vProduct_Group_Id int,
           @vTech_Req_Data_Need nvarchar(4000),
           @vGD_Spec_Same char(1),
           @vGD_Test_Method_Same char(1),
           @vSupp_Spec_Need char(1),
           @vSupp_Test_Method_Need char(1),
           @vGMS_S2_Test_Requirement nvarchar(4000),
           @vTire_Qty_Per_Trial int,
           @vTire_SKU_Trial nvarchar(4000),
           @vPlant_Vol_Need char(1),
           @vYarn_Type nvarchar(200),
           @vConstruction nvarchar(200),
           @vTwist nvarchar(200),
           @vTotal_Ends nvarchar(100),
           @vEPI nvarchar(100),
           @vTreatment_Width nvarchar(100),
           @vGY_Supp_Spec_Diff nvarchar(4000),
           @vSupp_Cap_GY_Req nvarchar(4000),
           @vSupp_Sign char(1),
           @vPS_S1_Supp_Requirement nvarchar(4000),
           @vSDS_Needed char(1),
           @vSDS_Received char(1),
           @vSDS_Ok char(1),
           @vCIRF_Needed char(1),
           @vCIRF_Received char(1),
           @vREACH_INV_Status_Ok char(1),
           @vHAPFree_Letter_Needed char(1),
           @vEHS_Proc_QS_Needed char(1),
           @vPlant_HSE_Review nvarchar(4000),
           @vOther_Consideration nvarchar(4000),
           @vRegion_Code varchar(5),
           @vCountry_Code char(3),
           @vLocation_Id int,
		   @vProjectLead Varchar(8000)=NULL,
		   @vTeamMembers Varchar(8000)=NULL,
		   @vGlobalMaterialScienceManagers Varchar(8000)=NULL,
		   @vGlobalProcurementCategoryManager Varchar(8000)=NULL,		   
		   @vGlobalProcurementFinanceManagers Varchar(8000)=NULL,
		   @vGlobalProductStewardshipManagers Varchar(8000)=NULL,
		   @vSupplierDevelopmentManagers Varchar(8000)=NULL,
           @vLast_Modified_By varchar(10),	
 		   @vMsg_Out Varchar(100) OUT

		
 )
 AS
 BEGIN

DECLARE @_vQTI_Id INT
DECLARE @_vWT_Type Varchar(5)='RD'

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

IF (@vQTI_Number IS NULL OR LEN(LTRIM(RTRIM(@vQTI_Number)))<1)
	BEGIN
		SELECT @vMsg_Out='Invalid Project Number'
		RETURN 0
	END

SELECT @_vQTI_Id=B.QTI_Id  
FROM GPM_WT_Project A INNER JOIN GPM_WT_NMTP B ON A.WT_Id=B.QTI_Id AND A.WT_Project_Number=B.QTI_Number  
WHERE A.WT_Code=@_vWT_Type AND 
A.WT_Project_ID=@vWT_Project_Id AND
A.WT_Project_Number=LTRIM(RTRIM(@vQTI_Number))

SELECT @_vCurPL_Id=A.GD_User_Id FROM GPM_WT_Project_Team A INNER JOIN GPM_Project_Template_Role B On A.WT_Role_ID = B.WT_Role_Id
WHERE B.WT_Role_Name = 'Project Lead' AND B.WT_Code = @_vWT_Type AND A.Is_Deleted_Ind='N' AND A.WT_Project_ID = @vWT_Project_Id

IF (@_vQTI_Id IS NULL)
	BEGIN
		SELECT @vMsg_Out='Project Not Found'
		RETURN 0
	END


BEGIN TRAN

			UPDATE GPM_WT_NMTP
					    SET QTI_Name = @vQTI_Name,
							Plan_Start_Date = @vPlan_Start_Date,
							Material_Cat_Id = @vMaterial_Cat_Id,
							Material_Id = @vMaterial_Id,
							Material_Group_Id = @vMaterial_Group_Id,
							Program_Id = @vProgram_Id,
							Plant_Trial_Id = @vPlant_Trial_Id,
							Value_Date = @vValue_Date,
							Code_Name = @vCode_Name,
							XCode_Desc = @vXCode_Desc,
							Material_Trade_Name = @vMaterial_Trade_Name,
							ARD_Desc = @vARD_Desc,
							Network_Desc = @vNetwork_Desc,
							Unique_Desc = @vUnique_Desc,
							MIS_VPS_Desc = @vMIS_VPS_Desc,
							VPS_Scheduled_Date = @vVPS_Scheduled_Date,
							VSDS_Number = @vVSDS_Number,
							Supp_Company_Name = @vSupp_Company_Name,
							Supp_Plant_Location = @vSupp_Plant_Location,
							Supp_Contact_Name = @vSupp_Contact_Name,
							Supp_Email = @vSupp_Email,
							Supp_Phone = @vSupp_Phone,
							Agent_Company_Name = @vAgent_Company_Name,
							Agent_Contatc_Name = @vAgent_Contatc_Name,
							Agent_Email = @vAgent_Email,
							Agent_Phone = @vAgent_Phone,
							PTM_Lead_Time = @vPTM_Lead_Time,
							CSIS_Desc = @vCSIS_Desc,
							Vendor_Code = @vVendor_Code,	
							Required_Doc = @vRequired_Doc,
							Mat_Ship_Once = @vMat_Ship_Once,
							Comments = @vComments,
							SIS_New_Supp = @vSIS_New_Supp,
							Supp_Requirement_Acpt = @vSupp_Requirement_Acpt,
							Supp_Requirement_Excpt = @vSupp_Requirement_Excpt,
							PLS_Concept_Check = @vPLS_Concept_Check,
							SQA_S1_Supp_Requirement = @vSQA_S1_Supp_Requirement,
							SQA_S1_Concept_Check = @vSQA_S1_Concept_Check,
							Supp_Complaint = @vSupp_Complaint,
							Plant_Raw_Mat_Plan = @vPlant_Raw_Mat_Plan,
							SC_S1_Supp_Requirement = @vSC_S1_Supp_Requirement,
							Packaging_Requirement = @vPackaging_Requirement,
							Packaging_Req_Met = @vPackaging_Req_Met,
							Mode_Requirement = @vMode_Requirement,
							Mode_Requirement_Met = @vMode_Requirement_Met,
							Import_License_Required = @vImport_License_Required,
							Proc_Trial_Required = @vProc_Trial_Required,
							Total_Qty_Need = @vTotal_Qty_Need,
							Plant_Tech_Contact = @vPlant_Tech_Contact,
							Intermediate_Dest = @vIntermediate_Dest,
							QA_S1_Supp_Requirement = @vQA_S1_Supp_Requirement,
							COA_PPK_Data_Need = @vCOA_PPK_Data_Need,
							Beyond_Spec_Data_Need = @vBeyond_Spec_Data_Need,
							Plant_Spec_Requirement = @vPlant_Spec_Requirement,
							Other_Trial_Required = @vOther_Trial_Required,
							Trial_Desc = @vTrial_Desc,
							Trial_Treatment = @vTrial_Treatment,
							Dipped_Fabric_Width = @vDipped_Fabric_Width,
							Spool_Length = @vSpool_Length,
							Spool_Type = @vSpool_Type,
							VPS_Template = @vVPS_Template,
							Proc_Vol_Trial_Duration = @vProc_Vol_Trial_Duration,
							Product_Group_Id = @vProduct_Group_Id,
							Tech_Req_Data_Need = @vTech_Req_Data_Need,
							GD_Spec_Same = @vGD_Spec_Same,
							GD_Test_Method_Same = @vGD_Test_Method_Same,
							Supp_Spec_Need = @vSupp_Spec_Need,
							Supp_Test_Method_Need = @vSupp_Test_Method_Need,
							GMS_S2_Test_Requirement = @vGMS_S2_Test_Requirement,
							Tire_Qty_Per_Trial = @vTire_Qty_Per_Trial,
							Tire_SKU_Trial = @vTire_SKU_Trial,
							Plant_Vol_Need = @vPlant_Vol_Need,
							Yarn_Type = @vYarn_Type,
							Construction = @vConstruction,
							Twist = @vTwist,
							Total_Ends = @vTotal_Ends,
							EPI = @vEPI,
							Treatment_Width = @vTreatment_Width,
							GY_Supp_Spec_Diff = @vGY_Supp_Spec_Diff,
							Supp_Cap_GY_Req = @vSupp_Cap_GY_Req,
							Supp_Sign = @vSupp_Sign,
							PS_S1_Supp_Requirement = @vPS_S1_Supp_Requirement,
							SDS_Needed = @vSDS_Needed,
							SDS_Received = @vSDS_Received,
							SDS_Ok = @vSDS_Ok,
							CIRF_Needed = @vCIRF_Needed,
							CIRF_Received = @vCIRF_Received,
							REACH_INV_Status_Ok = @vREACH_INV_Status_Ok,
							HAPFree_Letter_Needed = @vHAPFree_Letter_Needed,
							EHS_Proc_QS_Needed = @vEHS_Proc_QS_Needed,
							Plant_HSE_Review = @vPlant_HSE_Review,
							Other_Consideration = @vOther_Consideration,
							Region_Code = @vRegion_Code,
							Country_Code = @vCountry_Code,
							Location_Id = @vLocation_Id,
							--Is_Best_Proj_Nom = @vIs_Best_Proj_Nom,
							--Ref_Idea_Id = @vRef_Idea_Id,
							Last_Modified_By = @vLast_Modified_By,
							Last_Modified_Date = Getdate()
						WHERE QTI_Number=LTRIM(RTRIM(@vQTI_Number))

						IF (@@ERROR <> 0) GOTO ERR_HANDLER

						/* Add Remove Team Members According to new member list*/

						IF(LEN(@vProjectLead)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vProjectLead)

						IF(LEN(@vTeamMembers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vTeamMembers)
													
						IF(LEN(@vGlobalMaterialScienceManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGlobalMaterialScienceManagers)
										
						IF(LEN(@vGlobalProcurementCategoryManager)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGlobalProcurementCategoryManager)

						IF(LEN(@vGlobalProcurementFinanceManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGlobalProcurementFinanceManagers)

						IF(LEN(@vGlobalProductStewardshipManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vGlobalProductStewardshipManagers)

						IF(LEN(@vSupplierDevelopmentManagers)>0)
							INSERT INTO @_vTabRoleMember(RoleMember) Values(@vSupplierDevelopmentManagers)


							SELECT * FROM @_vTabRoleMember

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
																/*
						/* Disable Role User List if it is already exist and not in new list */
								UPDATE GPM_WT_Project_Team
								SET
									Is_Deleted_Ind='Y',
									Last_Modified_By=@vLast_Modified_By,
									Last_Modified_Date=Getdate()
								FROM GPM_WT_Project_Team A LEFT OUTER JOIN Fn_SplitDelimetedData(',',@_vGDUserIdList) TAB On 
									A.GD_User_Id=TAB.Value  AND A.WT_Role_ID=ISNULL(@_vProjectRoleId,'')
								WHERE A.WT_Project_ID=@vWT_Project_Id 
								AND A.Is_Deleted_Ind='N' AND Tab.Value IS NULL 
								AND NOT EXISTS(SELECT 1 FROm @_vTabRoleMemberProc TMP WHERE TMP.WT_Role_Id=A.WT_Role_ID AND TMP.GD_User_Id=A.GD_User_Id)
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
								'You have been assigned as '+ GPTR.WT_Role_Name +' for project '+ @vQTI_Name,
								@vQTI_Name,
								GETDATE(),
								'N'
								 FROM @_vTabRoleMemberNotif TRN INNER JOIN
									GPM_Project_Template_Role GPTR On TRN.WT_Role_Id=GPTR.WT_Role_Id
									WHERE GPTR.WT_Code=@_vWT_Type

								 IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END


		SELECT @vMsg_Out='NMTP Details Updated Successfully'	
				
COMMIT TRAN
RETURN 1

 ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Update NMTP Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END
 END

GO







