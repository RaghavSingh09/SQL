
/****** Object:  StoredProcedure [dbo].[Sp_GetTDCMetricSummary_ByProject]    Script Date: 2/14/2019 4:00:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_GetTDCMetricSummary_ByProject]
@vWT_Project_ID INT,
@vStartDate DATETIME=NULL,
@vEndDate  DATETIME=NULL,
@vMsg_Out Varchar(100) OUT
AS
BEGIN

DECLARE @_vStartDate INT
DECLARE @_vEndDate  INT
DECLARE @_vProjectMTStartDate DATETIME
DECLARE @_vProjectMTEndDate DATETIME
DECLARE @_vTDCMetric AS Table(Attrib_Id INT, Attrib_Name Varchar(200), YearMonth Varchar(8), Attrib_Value Numeric(10,1), Is_Lock Bit, Display_Order Int)
DECLARE @_IsValidDate VARCHAR(5)='true'
		
	IF(@vStartDate IS NULL AND @vEndDate IS NULL)
	BEGIN
		SELECT @_vProjectMTStartDate= DATEADD(MONTH, -1,  System_StartDate) FROM GPM_WT_Project WHERE WT_Project_ID=@vWT_Project_ID

		SELECT @_vStartDate =CAST(CONVERT(VARCHAR(6), @_vProjectMTStartDate,112) AS INT)

		SELECT @_vEndDate =CAST(CONVERT(VARCHAR(6), DATEADD(MONTH, 12,@_vProjectMTStartDate),112) AS INT)

		SELECT @_IsValidDate='true'
	END
	ELSE
	BEGIN
		IF(@vStartDate IS NOT NULL AND @vEndDate IS NULL)
		BEGIN
			SELECT @vMsg_Out='Invalid End Date'
			SELECT @_IsValidDate='false'
		END
		ELSE
		IF(@vStartDate IS NULL AND @vEndDate IS NOT NULL)
		BEGIN
			SELECT @vMsg_Out='Invalid Start Date'
			SELECT @_IsValidDate='false'
		END
		ELSE
		IF(@vStartDate IS NOT NULL AND @vEndDate IS NOT NULL)
		BEGIN
			SELECT @_vProjectMTStartDate= DATEADD(MONTH, -1,  System_StartDate) FROM GPM_WT_Project WHERE WT_Project_ID=@vWT_Project_ID
			SELECT @_vProjectMTEndDate = DATEADD(MONTH, 35, @_vProjectMTStartDate)

			IF((CAST(CONVERT(VARCHAR(6),@vStartDate,112) AS INT)<(CAST(CONVERT(VARCHAR(6),@_vProjectMTStartDate,112) AS INT))))
			BEGIN
				SELECT @vMsg_Out='The start month year can not be less than project start month - 1 '+  FORMAT (@_vProjectMTStartDate, 'dd/MM/yyyy ') 
				SELECT @_IsValidDate='false'
			END
			ELSE
			IF(CAST(CONVERT(VARCHAR(6),@vEndDate,112) AS INT)>CAST(CONVERT(VARCHAR(6),@_vProjectMTEndDate,112) AS INT))
			BEGIN
				SELECT @vMsg_Out='The end month year can not be more than project start month year + 3 years '+  FORMAT (@_vProjectMTEndDate, 'dd/MM/yyyy ') 
				SELECT @_IsValidDate='false'
			END
			ELSE
			BEGIN
				SELECT @_vStartDate =CAST(CONVERT(VARCHAR(6), @vStartDate,112) AS INT)

				SELECT @_vEndDate =CAST(CONVERT(VARCHAR(6), @vEndDate,112) AS INT)

				SELECT @_IsValidDate='true'
			END
		END
	END

	
	SELECT @_IsValidDate='true'
	BEGIN	

			 INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Is_Lock, Display_Order)
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, 
			 A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='SAVINGS' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID  AND A.YearMonth between @_vStartDate AND @_vEndDate 
			 UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='WC IMPROVEMENT' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
			 UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='GROSS SAVINGS' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
			  UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='(HW)/TW' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
			 UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='COST AVOIDANCE' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
			 UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock,  B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='COST OF SAVINGS' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
			 UNION ALL
			 SELECT A.Attrib_Id, B.Attrib_Name, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth, A.Attrib_Value,A.Is_Lock, B.Display_Order from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE B.Attrib_Type='CONVERSION SCORECARD' AND B.Is_Computed_Attrib='N'
			 AND A.WT_Project_ID = @vWT_Project_ID AND A.YearMonth between @_vStartDate AND @_vEndDate 
	 

			 IF((SELECT COUNT(*) FROM @_vTDCMetric)>0)
			 INSERT @_vTDCMetric(Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Is_Lock, Display_Order)
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 49 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND  B.Attrib_Type='SAVINGS' AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id  
			 UNION ALL
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 50 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND B.Attrib_Type='WC IMPROVEMENT' AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
			 UNION ALL
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 51 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND B.Attrib_Type='GROSS SAVINGS' AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
 			 UNION ALL
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 52 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND B.Attrib_Type='(HW)/TW' AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
			  UNION ALL 
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 53 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND B.Attrib_Type='COST AVOIDANCE' AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
			  UNION ALL
			 SELECT Tab.Attrib_Id, B.Attrib_Name, Tab.YearMonth, Tab.Attrib_Value, 1 As Is_Lock,  B.Display_Order FROM
			 (SELECT 54 As Attrib_Id, SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),1,4)+'-'+SUBSTRING(CAST(A.YearMonth AS VARCHAR(6)),5,2) As YearMonth,SUM(A.ATTRIB_Value) As Attrib_Value from GPM_WT_Project_TDC_Saving A INNER JOIN GPM_Metrics_TDC_Saving B ON A.Attrib_Id=B.Attrib_Id
			 WHERE A.WT_Project_ID = @vWT_Project_ID AND B.Attrib_Type='COST OF SAVINGS'  AND  A.YearMonth between @_vStartDate AND @_vEndDate GROUP BY A.YearMonth ) TAB INNER JOIN GPM_Metrics_TDC_Saving B On Tab.Attrib_Id= B.Attrib_Id
			 UNION ALL
			 SELECT Attrib_Id, Attrib_Name, NULL As YearMonth, NULL As Attrib_Value, 1 Is_Lock,  Display_Order  FROM GPM_Metrics_TDC_Saving WHERE Attrib_Id=55
	 

			 SELECT Attrib_Id, Attrib_Name, YearMonth, Attrib_Value, Is_Lock, Display_Order	 FROM @_vTDCMetric
			 ORDER BY  YearMonth,Display_Order Asc
		
	 END
END


