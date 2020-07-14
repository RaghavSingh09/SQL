--DELETE from GPM_WT_Project_GBS_Saving_ActFcst  WHERE WT_Project_ID IN(Select WT_Project_ID FROM GPM_WT_Project B where B.WT_Code = 'GBP')
--DELETE from GPM_WT_Project_GBS_Saving_Baseline  WHERE WT_Project_ID IN(Select WT_Project_ID FROM GPM_WT_Project B where B.WT_Code = 'GBP')
--DELETE from GPM_WT_Project_GBS_Saving_OtherLoc  WHERE WT_Project_ID IN(Select WT_Project_ID FROM GPM_WT_Project B where B.WT_Code = 'GBP')

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


								SELECT GWP.WT_Project_ID,GMTS.Attrib_Id,
								--TDC.YearMonth,
								'20'+SUBSTRING(TDC.YearMonth,5,2) +''+ 
									   CASE WHEN SUBSTRING(TDC.YearMonth,1,3)='Jan' Then '01'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Feb' Then '02'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Mar' Then '03'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Apr' Then '04'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='May' Then '05'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jun' Then '06'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jul' Then '07'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Aug' Then '08'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Sep' Then '09'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Oct' Then '10'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Nov' Then '11'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Dec' Then '12'
										END,

								'20'+SUBSTRING(TDC.YearMonth,5,2),
								--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
								SUBSTRING(TDC.YearMonth,1,3),
								CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
										CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'-$','-'),',',''),' ','')
										ELSE
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',',''),' ','')
										END
								END,
								1,
								GWP.Created_By,
								GWP.Created_Date,
								GWP.Last_Modified_By,
								GWP.Last_Modified_Date
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_WT_Project GWP on RTRIM(LTRIM(TDC.Sequence_number))= GWP.WT_Project_Number
							INNER JOIN (SELECT GBS_Number FROM GPM_WT_GBS WHERE GBS_Number NOT IN(SELECT Sequence_number FROM Temp_GBS_Error)) TAB ON TDC.Sequence_number=TAB.GBS_Number
							INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE GMTS.Is_Computed_Attrib='N' AND GWP.WT_Code = 'GBP'
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


								SELECT GWP.WT_Project_ID,GMTS.Attrib_Id,
								--TDC.YearMonth,
								'20'+SUBSTRING(TDC.YearMonth,5,2) +''+ 
									   CASE WHEN SUBSTRING(TDC.YearMonth,1,3)='Jan' Then '01'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Feb' Then '02'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Mar' Then '03'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Apr' Then '04'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='May' Then '05'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jun' Then '06'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jul' Then '07'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Aug' Then '08'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Sep' Then '09'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Oct' Then '10'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Nov' Then '11'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Dec' Then '12'
										END,

								'20'+SUBSTRING(TDC.YearMonth,5,2),
								--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
								SUBSTRING(TDC.YearMonth,1,3),
								CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
								/*
										CASE WHEN CHARINDEX('(', TDC.Attrib_Value,1)>0 THEN 
											REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')*-1
										ELSE
											REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',','')
										END
								*/
										CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'-$','-'),',',''),' ','')
										ELSE
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',',''),' ','')
										END
								END,
								1,
								GWP.Created_By,
								GWP.Created_Date,
								GWP.Last_Modified_By,
								GWP.Last_Modified_Date
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_WT_Project GWP on RTRIM(LTRIM(TDC.Sequence_number))= GWP.WT_Project_Number
							INNER JOIN (SELECT GBS_Number FROM GPM_WT_GBS WHERE GBS_Number NOT IN(SELECT Sequence_number FROM Temp_GBS_Error)) TAB ON TDC.Sequence_number=TAB.GBS_Number
							INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE GMTS.Is_Computed_Attrib='N' AND GWP.WT_Code = 'GBP'
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


								SELECT GWP.WT_Project_ID,GMTS.Attrib_Id,
								--TDC.YearMonth,
								'20'+SUBSTRING(TDC.YearMonth,5,2) +''+ 
									   CASE WHEN SUBSTRING(TDC.YearMonth,1,3)='Jan' Then '01'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Feb' Then '02'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Mar' Then '03'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Apr' Then '04'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='May' Then '05'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jun' Then '06'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Jul' Then '07'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Aug' Then '08'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Sep' Then '09'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Oct' Then '10'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Nov' Then '11'
											WHEN SUBSTRING(TDC.YearMonth,1,3)='Dec' Then '12'
										END,

								'20'+SUBSTRING(TDC.YearMonth,5,2),
								--FORMAT(CONVERT (DATE, TDC.YearMonth+'01'),'MMM'),
								SUBSTRING(TDC.YearMonth,1,3),
								CASE WHEN LEN(LTRIM(RTRIM(TDC.Attrib_Value)))<=0 THEN 0 ELSE
										CASE WHEN CHARINDEX('-', TDC.Attrib_Value,1)>0 THEN 
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'-$','-'),',',''),' ','')
										ELSE
											REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(TDC.Attrib_Value,'(',''),')',''),'$',''),',',''),' ','')
										END
								END,
								1,
								GWP.Created_By,
								GWP.Created_Date,
								GWP.Last_Modified_By,
								GWP.Last_Modified_Date
							FROM Temp_GBS_TDC TDC INNER JOIN GPM_WT_Project GWP on RTRIM(LTRIM(TDC.Sequence_number))= GWP.WT_Project_Number
							INNER JOIN (SELECT GBS_Number FROM GPM_WT_GBS WHERE GBS_Number NOT IN(SELECT Sequence_number FROM Temp_GBS_Error)) TAB ON TDC.Sequence_number=TAB.GBS_Number
							INNER JOIN GPM_Metrics_GBS_Saving GMTS On LTRIM(RTRIM(TDC.TDC_Attrib))=GMTS.Attrib_Name
							WHERE GMTS.Is_Computed_Attrib='N' AND GWP.WT_Code = 'GBP'
							AND TDC.TDC_Type='Act-Fcst Other Location'