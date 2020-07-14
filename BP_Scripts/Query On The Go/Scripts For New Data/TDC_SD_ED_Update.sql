--ALTER TABLE  GPM_WT_Project ADD Metric_ActFcst_StartDate DATE
--ALTER TABLE  GPM_WT_Project ADD Metric_ActFcst_EndDate DATE
--ALTER TABLE  GPM_WT_Project ADD Metric_Baseline_StartDate DATE
--ALTER TABLE  GPM_WT_Project ADD Metric_Baseline_EndDate DATE
--ALTER TABLE  GPM_WT_Project ADD Metric_OtherLoc_StartDate DATE
--ALTER TABLE  GPM_WT_Project ADD Metric_OtherLoc_EndDate DATE


--SELECT CONVERT(DATE,CAST( MIN(YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving  WHERE WT_Project_ID = 46585

--SELECT CONVERT(DATE,CAST( MAX(YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving  WHERE WT_Project_ID = 46585

--SELECT CONVERT(DATE,CAST( MIN(YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline  WHERE WT_Project_ID = 46585

--SELECT CONVERT(DATE,CAST( MAX(YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline  WHERE WT_Project_ID = 46585


UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='SC' --AND A.WT_Project_ID=46585


UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='GDI' ---AND A.WT_Project_ID=46585



UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='FI' ---AND A.WT_Project_ID=46585


UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='PSC' ---AND A.WT_Project_ID=46585


UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='PSIMP' ---AND A.WT_Project_ID=46585




UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='MDPO' ---AND A.WT_Project_ID=46585



UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_TDC_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='REP' ---AND A.WT_Project_ID=46585




UPDATE A SET A.Metric_ActFcst_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_ActFcst B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_ActFcst_EndDate=(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_ActFcst B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_Baseline_EndDate =(SELECT CONVERT(DATE,CAST( MAX(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_Baseline B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_OtherLoC_StartDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_OtherLoc B  WHERE B.WT_Project_ID =  A.WT_Project_ID),
A.Metric_OtherLoC_EndDate=(SELECT CONVERT(DATE,CAST( MIN(B.YearMonth) AS VARCHAR(6)) +'01',112) from GPM_WT_Project_GBS_Saving_OtherLoc B  WHERE B.WT_Project_ID =  A.WT_Project_ID)
FROM GPM_WT_project A WHERE A.WT_Code='GBP' ---AND A.WT_Project_ID=46585