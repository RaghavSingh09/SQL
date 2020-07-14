
UPDATE A SET A.SC_Name=B.Name,A.Project_Description=B.Project_Description,A.Est_Timeline=B.Estimated_Timeline from GPM_WT_Supply_Chain A INNER JOIN Temp_SC_Custom_Fields B On A.SC_Number=B.Sequence_number

UPDATE A SET A.DMAIC_Name=B.Name,A.Project_Defination=B.Define,A.Project_Measure=Measure,A.Project_Analysis=Analyze,A.Project_Improvement=Improve,A.Project_Control=Control,A.Project_Metric_Cp=Primary_Metric_and_Current_Performance FROM GPM_WT_DMAIC A INNER JOIN Temp_Dmaic_Custom_Fields B On A.DMAIC_Number=B.Sequence_number

UPDATE A SET A.GBS_Name=B.Name,A.Problem_Statement=B.Problem_Statement,A.Goal_Statement=B.Goal_Statement,A.Project_Metric_Cp=B.Primary_Metric_and_Current_Performance,A.Expected_Benefits=B.Expected_Benefits,A.Comments=B.Comments FROM GPM_WT_GBS A INNER JOIN Temp_GBS_Custom_Fields B On A.GBS_Number=B.Sequence_number

UPDATE A SET A.MDPO_Name=B.Name,A.Project_Scope_Scale=B.Project_Scope_and_Scale,A.Expected_Benefits=B.Expected_Benefits,A.SR_Actual_Proj_Status=B.SR_Actual_Project_Status,A.SR_NextStep=B.SR_Next_Steps_Actions FROM GPM_WT_MDPO A INNER JOIN Temp_Mdpo_Custom_Fields B On A.MDPO_Number=B.Sequence_number

UPDATE A SET A.PSC_Name=B.Name,A.Project_Description=B.Project_Description,A.Business_Case=B.[Business_case_(Benefits,_Risks,_etc.)],A.Baseline_Spend=B.Baseline_Spend,A.Baseline_Supp=B.Baseline_Supplier,A.Est_Timeline=B.Estimated_Timeline,A.Est_Proc_Resource=B.Estimated_Procurement_Resources,A.Est_Implement_Cost=B.Estimated_Implementation_Costs FROM GPM_WT_Procurement A INNER JOIN Temp_PSC_Custom_Fields B On A.PSC_Number=B.Sequence_number

UPDATE A SET A.PSIMP_Name=B.Name,A.Project_Description=B.Project_Description,A.Est_Timeline=B.Estimated_Timeline from GPM_WT_Procurement_Simple A INNER JOIN Temp_PSIMP_Custom_Fields B On A.PSIMP_Number=B.Sequence_number

UPDATE A SET A.Replication_Name=B.Name,A.Project_Summary=B.Project_Summary,A.Project_Metric_Cp=B.Primary_Metric_and_Current_Performance from GPM_WT_Replication A INNER JOIN Temp_Replication_Custom_Fields B On A.Replication_Number=B.Sequence_number

UPDATE A SET A.GDI_Name=B.Name,A.Project_Summary=B.Project_Summary,A.Project_Metric_Cp=B.Primary_Metric_and_Current_Performance from GPM_WT_GDI A INNER JOIN Temp_GDI_Custom_Fields B On A.GDI_Number=B.Sequence_number

UPDATE A SET A.QTI_Name=B.Name,
A.Code_Name=B.Code_Name,
A.XCode_Desc=B.Xcode,
A.Material_Trade_Name=B.Material_Trade_Name,
A.ARD_Desc=B.ARD#,
A.Network_Desc=B.Network_#,
A.Unique_Desc=B.Unique_#,
A.MIS_VPS_Desc=B.MISVPS_#,
A.VSDS_Number=B.VSDS_number_,
A.Supp_Company_Name=B.Supplier_Company_Name,
A.Supp_Plant_Location=B.Supplier_Plant_Location,
A.Supp_Contact_Name=B.Supplier_Contact_Name,
A.Agent_Company_Name=B.Agent_Company_Name,
A.Agent_Contatc_Name=B.Agent_Contact_Name,
A.PTM_Lead_Time=B.Lead_Time_for_Process_Trial_Material_No_of_days,
A.CSIS_Desc=B.CSIS_#,
A.Vendor_Code=B.Vendor_code,
A.Plant_Raw_Mat_Plan=B.Plant_Raw_Material_Planner,
A.Plant_Tech_Contact=B.Plant_Technical_Contact,
A.COA_PPK_Data_Need=B.COA_ppk_data_needed_,
A.Trial_Desc=B.If_yes_what_trials,
A.Dipped_Fabric_Width=B.Dipped_Fabric_Width,
A.Spool_Length=B.Spool_Length,
A.Spool_Type=B.Spool_Type,
A.VPS_Template=B.VPS_template,
A.Yarn_Type=B.Yarn_Type,
A.Construction=B.Construction_dtex,
A.Twist=B.Twist,
A.Total_Ends=B.Total_Ends,
A.EPI=B.EPI,
A.Treatment_Width=B.Treatment_Width_suffix
from GPM_WT_NMTP A INNER JOIN Temp_QTI_Custom_Fields B On A.QTI_Number=B.Sequence_number

 