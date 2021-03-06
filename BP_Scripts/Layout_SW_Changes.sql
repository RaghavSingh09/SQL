/****** Object:  StoredProcedure [dbo].[Sp_AddWTLayoutDetails]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_AddWTLayoutDetails]
@vLayout_Name	VARCHAR(500),
@vLayout_Desc	VARCHAR(8000),
@vLayout_Admin	VARCHAR(10),
@vLayout_Tags VARCHAR(MAX),
@vLayoutPLTags VARCHAR(MAX),
@vLayoutCustomFields VARCHAR(MAX),
@vLayoutMetrics VARCHAR(MAX),
@vLayoutMeasures VARCHAR(MAX),
@vLayout_Share_People VARCHAR(MAX),
@vLayout_Share_Facility VARCHAR(MAX),
@vLayout_Order VARCHAR(MAX),
@vEditable_By_Sharee CHAR(1),
@vIs_Deleted_Ind CHAR(1),
@vCreated_By VARCHAR(10),
@vLast_Modified_By VARCHAR(10),
@vLayout_Id INT OUT,
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN

DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRMSepPos INT=0
DECLARE @_vRMSepPosSc INT=0

DECLARE @_vTabLayoutCF TABLE(id INT Identity(1,1), CF VARCHAR(8000))
DECLARE @_vCF_Values VARCHAR(8000)=NULL
DECLARE @_vCF_Id INT=0
DECLARE @_vCF_CustName VARCHAR(500)=NULL
DECLARE @_vCF_DL INT=0

DECLARE @_vTabLayoutTags TABLE(id INT Identity(1,1), Tags VARCHAR(8000))
DECLARE @_vLayoutTag_Id INT=0
DECLARE @_vTag_Values VARCHAR(8000)=NULL
DECLARE @_vLO_Tags VARCHAR(8000)=NULL

DECLARE @_vTabLayoutPLTags TABLE(id INT Identity(1,1), PLTags VARCHAR(8000))
DECLARE @_vLayoutPLTag_Id INT=0
DECLARE @_vPLTag_Values VARCHAR(8000)=NULL
DECLARE @_vPLLO_Tags VARCHAR(8000)=NULL

DECLARE @_vTabLayoutMetrics TABLE(id INT Identity(1,1), MetStr VARCHAR(8000))
DECLARE @_vTabLayoutMetricsVal TABLE(id INT Identity(1,1), MetValue VARCHAR(500))
DECLARE @_vLayoutMetricsVal VARCHAR(500)=NULL

DECLARE @_vTabLayoutShare TABLE(id INT Identity(1,1), ShareWithValue VARCHAR(8000))
DECLARE @_vShare_Type_Id INT=0
DECLARE @_vShare_With_Values VARCHAR(8000)=NULL
DECLARE @_vLO_ShareValues VARCHAR(8000)=NULL

DECLARE @_vTabLayoutOrdering TABLE(id INT Identity(1,1), TagType CHAR(2),TagId INT, Attrib_Seq VARCHAR(500))

BEGIN TRAN


			INSERT INTO GPM_WT_Layout
				(
					Layout_Name,
					Layout_Desc,
					Layout_Admin,
					Is_Deleted_Ind,
					Created_By,
					Created_Date,
					Last_Modified_By,
					Last_Modified_Date,
					Edit_By_Sharees
				)
				VALUES
				(
					@vLayout_Name,
					@vLayout_Desc,
					@vLayout_Admin,
					'N',
					@vCreated_By,
					GETDATE(),
					@vLast_Modified_By,
					GETDATE(),
					@vEditable_By_Sharee
				)


				IF (@@ERROR <> 0) GOTO ERR_HANDLER

				SELECT @vLayout_Id=@@IDENTITY

				IF(LEN(@vLayout_Tags)>0)
					BEGIN
						INSERT INTO @_vTabLayoutTags(Tags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayout_Tags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutTags

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLO_Tags=Tags FROM @_vTabLayoutTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vLO_Tags,1)
								SELECT @_vLayoutTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vLO_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vTag_Values=SUBSTRING(@_vLO_Tags,@_vRMSepPos+1, len(@_vLO_Tags))

								
								INSERT INTO GPM_WT_Layout_Tag_Value
								(
									Layout_Id,
									Layout_Tag_Id,
									Custom_ColName,
									Created_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vLayout_Id,
									@_vLayoutTag_Id,
									@_vTag_Values,
									@vCreated_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								)
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutTags WHERE id>@_vCnt
							END

						END
					END

					IF(LEN(@vLayoutPLTags)>0)
					BEGIN
						INSERT INTO @_vTabLayoutPLTags(PLTags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayoutPLTags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutPLTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutPLTags

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPLLO_Tags=PLTags FROM @_vTabLayoutPLTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPLLO_Tags,1)
								SELECT @_vLayoutPLTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPLLO_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vPLTag_Values=SUBSTRING(@_vPLLO_Tags,@_vRMSepPos+1, len(@_vPLLO_Tags))

								
								INSERT INTO GPM_WT_Layout_PL_Tag_Value
								(
									Layout_Id,
									Layout_PL_Tag_Id,
									Custom_PL_ColName,
									Created_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vLayout_Id,
									@_vLayoutPLTag_Id,
									@_vPLTag_Values,
									@vCreated_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								)
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutPLTags WHERE id>@_vCnt
							END

						END
					END

					IF(LEN(LTRIM(RTRIM(@vLayoutCustomFields)))>0)
					INSERT INTO @_vTabLayoutCF(CF)
					SELECT 	Tab.Value
					FROM Fn_SplitDelimetedData('~',@vLayoutCustomFields) Tab
					WHERE Len(RTRIM(LTRIM(Value)))>0

				
					IF((SELECT COUNT(*) FROM @_vTabLayoutCF)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutCF

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT  @_vCF_Id=NULL,
										@_vCF_CustName=NULL,
										@_vCF_DL=NULL

								SELECT @_vCF_Values=CF FROM @_vTabLayoutCF WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vCF_Values,1)
								SELECT @_vRMSepPosSc=CHARINDEX('|',@_vCF_Values,@_vRMSepPos+1)								


								SELECT @_vCF_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vCF_Values,1, @_vRMSepPos-1))) AS INT)

								IF(LEN(LTRIM(RTRIM(@_vCF_Id)))<=0)
								SELECT @_vCF_Id=NULL

								SELECT @_vCF_CustName =RTRIM(LTRIM(SUBSTRING(@_vCF_Values,@_vRMSepPos+1, @_vRMSepPosSc-(@_vRMSepPos+1))))

								IF(LEN(LTRIM(RTRIM(@_vCF_CustName)))<=0)
								SELECT @_vCF_CustName=NULL
									
								SELECT @_vCF_DL =CAST(SUBSTRING(@_vCF_Values,@_vRMSepPosSc+1, len(@_vCF_Values)) AS INT)

								SELECT @_vCF_DL=CASE WHEN @_vCF_DL=0 OR @_vCF_DL=NULL THEN 8000 ELSE @_vCF_DL END 

								IF NOT(@_vCF_Id IS NULL AND @_vCF_CustName IS NULL AND @_vCF_DL IS NULL)
								INSERT INTO GPM_WT_Layout_Custom_Fields
									(
										Layout_Id,
										Custom_Field_Tag_Id,
										Custom_Field_Cust_ColName,
										Custom_Field_Display_Len
									)
								Values
									(
										@vLayout_Id,
										@_vCF_Id,
										@_vCF_CustName,
										@_vCF_DL 
									)

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

							SELECT @_vCnt=MIN(id) FROM @_vTabLayoutCF WHERE id>@_vCnt
						END
					END

					IF(LEN(@vLayoutMetrics)>0)
					BEGIN
						INSERT INTO @_vTabLayoutMetrics(MetStr)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayoutMetrics) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutMetrics)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutMetrics
							
							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLayoutMetricsVal = MetStr FROM @_vTabLayoutMetrics WHERE id=@_vCnt

								DELETE FROM @_vTabLayoutMetricsVal

								INSERT INTO @_vTabLayoutMetricsVal(MetValue)
								SELECT 
								CASE WHEN LEN(RTRIM(LTRIM(Value)))>0 THEN Value ELSE NULL END
								from Fn_SplitDelimetedData('|',@_vLayoutMetricsVal)
								
								INSERT INTO GPM_WT_Layout_Metrics_Value
								(
									Layout_Id,
									Metric_Id,
									Metric_TDC_Type_Id,
									Metric_Field_Id,
									Period_Id,
									Start_Month_Id,
									Start_Quarter_Id,
									Start_Year,
									End_Month_Id,
									End_Quarter_Id,
									End_Year,
									Custom_ColName,
									Precision,
									Program_Id,
									Created_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT  @vLayout_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+0) AS Metric_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+1) AS Metric_TDC_Type_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+2) AS Metric_Field_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+3) AS Period_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+4) AS Start_Month_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+5) AS Start_Quarter_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+6) AS Start_Year,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+7) AS End_Month_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+8) AS End_Quarter_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+9) AS End_Year,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+10) AS Custom_ColName,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+11) AS Precision,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+12) AS Program_Id,
									   @vCreated_By,
									   GETDATE(),
									   @vLast_Modified_By,
									   GETDATE()

								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutMetrics WHERE id>@_vCnt
							END

						END
					END

				
					IF(LEN(RTRIM(LTRIM(@vLayout_Share_People)))>0)
					INSERT INTO @_vTabLayoutShare(ShareWithValue) VALUES(@vLayout_Share_People)


					IF(LEN(@vLayout_Share_Facility)>0)
					BEGIN
						INSERT INTO @_vTabLayoutShare(ShareWithValue)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayout_Share_Facility) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutShare)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutShare

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLO_ShareValues=ShareWithValue FROM @_vTabLayoutShare WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vLO_ShareValues,1)
								SELECT @_vShare_Type_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vLO_ShareValues,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vShare_With_Values=SUBSTRING(@_vLO_ShareValues,@_vRMSepPos+1, len(@_vLO_ShareValues))

								
								INSERT INTO GPM_WT_Layout_Sharing
								(
									Layout_Id,
									Share_Type_Id,
									Share_With_Values,
									Share_By,
									Created_Date,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT
									@vLayout_Id,
									@_vShare_Type_Id,
									Tab.Value,
									@vCreated_By,
									GETDATE(),
									@vLast_Modified_By,
									GETDATE()
								FROM Fn_SplitDelimetedData(',',@_vShare_With_Values) Tab
									WHERE Len(RTRIM(LTRIM(Value)))>0

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutShare WHERE id>@_vCnt
							END

						END
					END
					
					IF(LEN(@vLayout_Order)>0)
					BEGIN
						INSERT INTO @_vTabLayoutOrdering(TagType,TagId, Attrib_Seq)
						/*
						 SELECT RTRIM(LTRIM(SUBSTRING(TAB.TagValue,1, (CHARINDEX('|',TAB.TagValue,1))-1))),
								SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue,1))+1, len(TAB.TagValue))
								*/

						SELECT RTRIM(LTRIM(SUBSTRING(TAB.TagValue,1, (CHARINDEX('|',TAB.TagValue,1))-1))),
								RTRIM(LTRIM(SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue,1))+1, ((CHARINDEX('|',TAB.TagValue, (CHARINDEX('|',TAB.TagValue,1))+1 )))- ((CHARINDEX('|',TAB.TagValue,1))+1)))),
										RTRIM(LTRIM(SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue, (CHARINDEX('|',TAB.TagValue,1))+1 ))+1, len(TAB.TagValue))))

							FROM
								(
									SELECT 	Tab.Value AS TagValue
										FROM Fn_SplitDelimetedData('~',@vLayout_Order) Tab
											WHERE Len(RTRIM(LTRIM(Value)))>0
										)	TAB

								INSERT INTO GPM_WT_Layout_Tag_Order
								(
									Layout_Id,
									Layout_Tag_Order_Id,
									Layout_Tag_Type_Id,
									Layout_Tag_Id,
									Attrib_Seq
								)
								SELECT @vLayout_Id,
								id, 
								--(SELECT CASE WHEN TagType='PL' THEN 10 WHEN TagType='PT' THEN 11 WHEN TagType='PC' THEN 12 WHEN TagType='PM' THEN 13 END),
								TagType,
								TagId,
								Attrib_Seq
								FROM @_vTabLayoutOrdering


							IF (@@ERROR <> 0) GOTO ERR_HANDLER

					END

					IF((LEN(RTRIM(LTRIM(@vLayout_Share_People)))>0 OR LEN(RTRIM(LTRIM(@vLayout_Share_Facility)))>0) AND @vLayout_Share_Facility!='~')
					BEGIN
						
						DECLARE @_vShareWithString VARCHAR(MAX)= @vLayout_Share_People +'~'+ @vLayout_Share_Facility
						
						DECLARE	@_vShared_UserList VARCHAR(MAX)
						EXEC	[Sp_GetUserList_ByShareWithString]
								@vSharewith =@_vShareWithString,
								@vUserList = @_vShared_UserList OUTPUT
						
						IF(LEN(RTRIM(LTRIM(@_vShared_UserList)))>0 OR ISNULL(@_vShared_UserList,'Y')!='Y')
							INSERT INTO GPM_WT_Layout_Visibility VALUES(@vLayout_Id,@_vShared_UserList)
						

						IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END

				SELECT @vMsg_Out ='Layout Added Successfully'
	COMMIT TRAN
	RETURN 1
			
	ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Add Layout Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END

END





GO
/****** Object:  StoredProcedure [dbo].[Sp_DelLayout]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_DelLayout]
@vLayout_Id INT,
@vLast_Modified_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN

IF EXISTS(SELECT 1 FROM GPM_WT_Layout WHERE Layout_Id=@vLayout_Id AND Is_Deleted_Ind='Y' )
	SELECT @vMsg_Out='Layout Already Deleted'

IF NOT EXISTS(SELECT 1 FROM GPM_WT_Layout WHERE Layout_Id=@vLayout_Id)
	SELECT @vMsg_Out='Layout To Be Deleted Not Found'
ELSE
	BEGIN
	IF EXISTS(SELECT 1 FROM GPM_WT_Layout WHERE Created_By = @vLast_Modified_By AND Layout_Id = @vLayout_Id)
		BEGIN
			UPDATE GPM_WT_Layout 
			SET Is_Deleted_Ind='Y', Last_Modified_By = @vLast_Modified_By, Last_Modified_Date = GETDATE()
			WHERE Layout_Id=@vLayout_Id

			DELETE FROM GPM_WT_Layout_Visibility WHERE Layout_Id=@vLayout_Id
			DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id=@vLayout_Id

			SELECT @vMsg_Out='Layout Deleted Successfully'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Layout_Visibility WHERE User_List  = @vLast_Modified_By AND Layout_Id=@vLayout_Id)
		BEGIN
			DELETE FROM GPM_WT_Layout_Visibility WHERE Layout_Id=@vLayout_Id
			DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id=@vLayout_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Layout Deleted Successfully For Shared User'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Layout_Visibility WHERE User_List LIKE '%'+@vLast_Modified_By+',%' AND Layout_Id=@vLayout_Id)
		BEGIN
			UPDATE GPM_WT_Layout_Visibility SET User_List = REPLACE(User_List,@vLast_Modified_By+',','') WHERE Layout_Id=@vLayout_Id
			DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id=@vLayout_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Layout Deleted Successfully For Shared User'
		END
	ELSE IF EXISTS(SELECT 1 FROM GPM_WT_Layout_Visibility WHERE User_List LIKE '%'+@vLast_Modified_By AND Layout_Id=@vLayout_Id)
		BEGIN
			UPDATE GPM_WT_Layout_Visibility SET User_List = REPLACE(User_List,','+@vLast_Modified_By,'') WHERE Layout_Id=@vLayout_Id
			DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id=@vLayout_Id AND Share_With_Values=@vLast_Modified_By
			SELECT @vMsg_Out='Layout Deleted Successfully For Shared User'
		END
	END
END



GO
/****** Object:  StoredProcedure [dbo].[Sp_GetLayoutDetails_ByLOId]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetLayoutDetails_ByLOId]
@vLayout_Id INT
AS
BEGIN

DECLARE @_vLO_Tag VARCHAR(MAX) = NULL
DECLARE @_vLO_PLTag VARCHAR(MAX) = NULL
DECLARE @_vLO_CF VARCHAR(MAX) = NULL
DECLARE @_vLO_Metric VARCHAR(MAX) = NULL
DECLARE @_vSharedWith VARCHAR(MAX) = NULL
DECLARE @_vLayoutOrder VARCHAR(MAX) = NULL

SELECT @_vLO_Tag = (SELECT +'~'+ISNULL(CAST(Layout_Tag_Id AS VARCHAR),'')+'|'+ISNULL(Custom_ColName,'') FROM GPM_WT_Layout_Tag_Value WHERE Layout_Id = @vLayout_Id FOR XML PATH(''))
SELECT @_vLO_PLTag = (SELECT +'~'+ISNULL(CAST(Layout_PL_Tag_Id AS VARCHAR),'')+'|'+ISNULL(Custom_PL_ColName,'') FROM GPM_WT_Layout_PL_Tag_Value WHERE Layout_Id = @vLayout_Id FOR XML PATH(''))
SELECT @_vLO_CF = (SELECT +'~'+ISNULL(CAST(Custom_Field_Tag_Id AS VARCHAR),'')+'|'+ISNULL(Custom_Field_Cust_ColName,'')+'|'+ISNULL(CAST(Custom_Field_Display_Len AS VARCHAR),'') FROM GPM_WT_Layout_Custom_Fields WHERE Layout_Id = @vLayout_Id FOR XML PATH(''))
SELECT @_vLO_Metric = (SELECT +'~'+ISNULL(CAST(Metric_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Metric_TDC_Type_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Metric_Field_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Period_Id AS VARCHAR),'')
					   +'|'+ISNULL(CAST(Start_Month_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Start_Quarter_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Start_Year AS VARCHAR),'')
					   +'|'+ISNULL(CAST(End_Month_Id AS VARCHAR),'')+'|'+ISNULL(CAST(End_Quarter_Id AS VARCHAR),'')+'|'+ISNULL(CAST(End_Year AS VARCHAR),'')
					   +'|'+ISNULL(Custom_ColName,'')+'|'+ISNULL(Precision,'')+'|'+ISNULL(CAST(Program_Id AS VARCHAR),'')+'|'
					   FROM GPM_WT_Layout_Metrics_Value WHERE Layout_Id = @vLayout_Id FOR XML PATH(''))
SELECT @_vSharedWith = (SELECT SUBSTRING((SELECT '~' + TAB.PFShareValues FROM 
						(SELECT DISTINCT GWPS.Layout_Id,
						CAST(Share_Type_Id AS VARCHAR(10))+'|'+(SUBSTRING((SELECT ',' + GWPS1.Share_With_Values FROM GPM_WT_Layout_Sharing GWPS1 
						WHERE GWPS1.Layout_Id=@vLayout_Id and GWPS1.Share_Type_Id=GWPS.Share_Type_Id
						FOR XML PATH('')),2,100000)) AS PFShareValues
						FROM GPM_WT_Layout_Sharing GWPS WHERE GWPS.Layout_Id=@vLayout_Id) TAB	WHERE TAB.Layout_Id=@vLayout_Id FOR XML PATH('')),2,100000) AS SharedWith)
/*
SELECT @_vLayoutOrder = (SELECT +'~'+ISNULL(CAST(Layout_Tag_Order_Id AS VARCHAR),'')+'|'+ ISNULL(CAST(Layout_Tag_Type_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Layout_Tag_Id AS VARCHAR),'')+'|' from GPM_WT_Layout_Tag_Order WHERE Layout_Id = @vLayout_Id  ORDER BY Layout_Tag_Order_Id FOR XML PATH(''))
*/

SELECT @_vLayoutOrder = (SELECT +'~'+ ISNULL(CAST(Layout_Tag_Order_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Layout_Tag_Type_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Layout_Tag_Id AS VARCHAR),'')+'|'+ISNULL(CAST(Attrib_Seq AS VARCHAR),'') FROM GPM_WT_Layout_Tag_Order where Layout_Id=@vLayout_Id ORDER BY Layout_Tag_Order_Id FOR XML PATH(''))


SELECT GWL.Layout_Id, GWL.Layout_Name, GWL.Layout_Desc, GWL.Layout_Admin, 
SUBSTRING(@_vLO_Tag,2,LEN(@_vLO_Tag)) AS Layout_Tags,SUBSTRING(@_vLO_PLTag,2,LEN(@_vLO_PLTag)) AS Layout_PL_Tags,
SUBSTRING(@_vLO_Metric,2,LEN(@_vLO_Metric)) AS Layout_Metric_Tags,SUBSTRING(@_vLO_CF,2,LEN(@_vLO_CF))  AS Layout_CF_Tags, 
SUBSTRING(@_vSharedWith,1,LEN(@_vSharedWith)) AS SharedWith, SUBSTRING(@_vLayoutOrder,2,LEN(@_vLayoutOrder)) AS LayoutOrder,
GWL.Edit_By_Sharees,GWL.Is_Global
FROM GPM_WT_Layout GWL 
WHERE GWL.Layout_Id = @vLayout_Id AND GWL.Is_Deleted_Ind = 'N'

END







GO
/****** Object:  StoredProcedure [dbo].[Sp_GetLayoutList_ByUser]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- now for Layout
/****** Object:  StoredProcedure [dbo].[Sp_GetPortofolioList_ByUser]    Script Date: 05-Mar-19 1:05:37 PM ******/

CREATE PROCEDURE [dbo].[Sp_GetLayoutList_ByUser]
@vGD_User_Id VARCHAR(10)
AS
BEGIN
DECLARE @_vPeople INT=(SELECT Layout_Share_Type_Id FROM GPM_Layout_Share_Type WHERE Layout_Share_Type_Desc='People')
DECLARE @_vRegion INT=(SELECT Layout_Share_Type_Id FROM GPM_Layout_Share_Type WHERE Layout_Share_Type_Desc='Region')
DECLARE @_vCountry INT=(SELECT Layout_Share_Type_Id FROM GPM_Layout_Share_Type WHERE Layout_Share_Type_Desc='Country')
DECLARE @_vLocation INT=(SELECT Layout_Share_Type_Id FROM GPM_Layout_Share_Type WHERE Layout_Share_Type_Desc='Location')



SELECT GWP.Layout_Id,GWP.Layout_Name,GWP.Layout_Desc, GWP.Created_By As Layout_Onwer_Id, 
ISNULL(GU.User_First_Name,'')+' '+ISNULL(GU.User_Last_Name,'') AS Layout_Owner,NULL As Is_Active,ISNULL(Edit_By_Sharees,'N') AS Edit_By_Sharees,GWP.Is_Global,

/*
SUBSTRING((SELECT '~' + CAST(GWPS.Share_Type_Id AS VARCHAR(10))+'|'+GWPS.Share_With_Values FROM GPM_WT_Layout_Sharing GWPS WHERE GWPS.Layout_Id=GWP.Layout_Id
FOR XML PATH('')),2,100000) AS ShareWith

*/

SUBSTRING((SELECT '~' + TAB.PFShareValues FROM 

(SELECT DISTINCT GWPS.Layout_Id,
CAST(Share_Type_Id AS VARCHAR(10))+'|'+(SUBSTRING((SELECT ',' + GWPS1.Share_With_Values FROM GPM_WT_Layout_Sharing GWPS1 
WHERE GWPS1.Layout_Id=GWP.Layout_Id and GWPS1.Share_Type_Id=GWPS.Share_Type_Id
FOR XML PATH('')),2,100000)) AS PFShareValues
FROM GPM_WT_Layout_Sharing GWPS WHERE GWPS.Layout_Id=GWP.Layout_Id) TAB

WHERE TAB.Layout_Id=GWP.Layout_Id
FOR XML PATH('')),2,100000) AS SharedWith



FROM GPM_WT_Layout GWP LEFT OUTER JOIN GPM_User GU On GWP.Created_By=GU.GD_User_Id 
	LEFT OUTER JOIN GPM_WT_Layout_Visibility GWLV On GWP.Layout_Id=GWLV.Layout_Id
WHERE GWP.Layout_Id IN(
	SELECT Layout_Id FROM  GPM_WT_Layout WHERE Created_By=@vGD_User_Id
	/*
	UNION
	SELECT Layout_Id FROM GPM_WT_Layout_Sharing WHERE Share_Type_Id=@_vPeople AND Share_With_Values=@vGD_User_Id
	UNION 
	SELECT Layout_Id FROM GPM_WT_Layout_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Region_Code
	WHERE Share_Type_Id=@_vRegion AND GU.GD_User_Id=@vGD_User_Id
	UNION
	SELECT Layout_Id FROM GPM_WT_Layout_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Country_Code
	WHERE Share_Type_Id=@_vCountry AND GU.GD_User_Id=@vGD_User_Id
	UNION
	SELECT Layout_Id FROM GPM_WT_Layout_Sharing GWPT INNER JOIN GPM_User GU On GWPT.Share_With_Values=GU.Location_Id
	WHERE Share_Type_Id=@_vLocation AND GU.GD_User_Id=@vGD_User_Id
	*/
)
 AND GWP.Is_Deleted_Ind='N' OR GWLV.User_List LIKE '%'+@vGD_User_Id+'%'
 ORDER BY GWP.Layout_Name

END







GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdProjectTDCData_ByWTProjectId]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_UpdProjectTDCData_ByWTProjectId]
@vWT_Project_Id INT,
@vTDCDataString VARCHAR(MAX),
@vTDC_Tab_Id INT,
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN

IF(@vTDCDataString IS NULL OR LEN(LTRIM(RTRIM(@vTDCDataString)))<=0)
BEGIN
	SELECT @vMsg_Out = 'No Financial Data To Update'
	RETURN 0
END
ELSE
BEGIN

       DECLARE @_vWT_Code VARCHAR(10)=NULL
	   SELECT @_vWT_Code=WT_Code FROM GPM_WT_Project WHERE WT_Project_ID=@vWT_Project_Id
       DECLARE @vTdcProjValues AS TABLE(Attrib_Id INT,YearMonth INT, Attrib_Value NUMERIC(38,15))

	   INSERT INTO @vTdcProjValues
       SELECT RTRIM(LTRIM(SUBSTRING(TAB_Inner.TDCValue,1, (CHARINDEX('|',TAB_Inner.TDCValue,1))-1))) AS Attrib_Id,
              RTRIM(LTRIM(SUBSTRING(TAB_Inner.TDCValue,(CHARINDEX('|',TAB_Inner.TDCValue,1))+1, (CHARINDEX('|',TAB_Inner.TDCValue,CHARINDEX('|',TAB_Inner.TDCValue,1)+1)-CHARINDEX('|',TAB_Inner.TDCValue,1)-1)))) AS YearMonth,
			  CASE WHEN LEN(RTRIM(LTRIM(SUBSTRING(TAB_Inner.TDCValue,CHARINDEX('|',TAB_Inner.TDCValue,CHARINDEX('|',TAB_Inner.TDCValue,1)+1)+1, LEN(TAB_Inner.TDCValue)))))<=0 THEN 0.0
			  ELSE CAST(RTRIM(LTRIM(SUBSTRING(TAB_Inner.TDCValue,CHARINDEX('|',TAB_Inner.TDCValue,CHARINDEX('|',TAB_Inner.TDCValue,1)+1)+1, LEN(TAB_Inner.TDCValue)))) AS NUMERIC(38,15)) END
			  AS Attrib_Value
                                                       FROM
                                                              (
                                                                     SELECT        Tab.Value AS TDCValue
                                                                           FROM Fn_SplitDelimetedData('~',@vTDCDataString) Tab
                                                                                  WHERE LEN(RTRIM(LTRIM(Value)))>0
                                                                           )      TAB_Inner
			
			/*Update Act_Fcst Data*/
			IF(@vTDC_Tab_Id=10)
			BEGIN
				IF(@_vWT_Code = 'FI')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_DMAIC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'GDI')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_GDI TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'MDPO')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_MDPO TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'PSC')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_PSC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'PSIMP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_PSIMP TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'REP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_REP TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'SC')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_SC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'GBP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_ActFcst_GBS TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
			END
			
			/*Update Baseline Data*/
			IF(@vTDC_Tab_Id=11)
			BEGIN
				IF(@_vWT_Code = 'FI')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_DMAIC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'GDI')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_GDI TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'MDPO')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_MDPO TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'PSC')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_PSC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'PSIMP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_PSIMP TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'REP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_REP TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'SC')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_SC TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
				IF(@_vWT_Code = 'GBP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_Baseline_GBS TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
			END

			/*Update GBP Other Location Data*/
			IF(@vTDC_Tab_Id=12)
			BEGIN
				IF(@_vWT_Code = 'GBP')
					UPDATE TDC_TAB SET TDC_TAB.Attrib_Value=TUT.Attrib_Value 
					FROM GPM_WT_Project_TDC_Saving_OtherLoc_GBS TDC_TAB INNER JOIN @vTdcProjValues TUT ON TDC_TAB.WT_Project_ID=@vWT_Project_Id
					WHERE TDC_TAB.WT_Project_ID = @vWT_Project_Id AND TDC_TAB.YearMonth = TUT.YearMonth AND TDC_TAB.Attrib_Id = TUT.Attrib_Id
			END
	SELECT @vMsg_Out = 'Financial Data Updated Successfully'
	RETURN 1
END
END
GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdWTLayoutDetails]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_UpdWTLayoutDetails]
@vLayout_Id INT,
@vLayout_Name	VARCHAR(500),
@vLayout_Desc	VARCHAR(8000),
@vLayout_Admin	VARCHAR(10),
@vLayout_Tags VARCHAR(MAX),
@vLayoutPLTags VARCHAR(MAX),
@vLayoutCustomFields VARCHAR(MAX),
@vLayoutMetrics VARCHAR(MAX),
@vLayoutMeasures VARCHAR(MAX),
@vLayout_Share_People VARCHAR(MAX),
@vLayout_Share_Facility VARCHAR(MAX),
@vLayout_Order VARCHAR(MAX),
@vLast_Modified_By VARCHAR(10),
@vEditable_By_Sharee CHAR(1),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN

DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vRMSepPos INT=0
DECLARE @_vRMSepPosSc INT=0

DECLARE @_vTabLayoutCF TABLE(id INT Identity(1,1), CF VARCHAR(8000))
DECLARE @_vCF_Values VARCHAR(8000)=NULL
DECLARE @_vCF_Id INT=0
DECLARE @_vCF_CustName VARCHAR(500)=NULL
DECLARE @_vCF_DL INT=0

DECLARE @_vTabLayoutTags TABLE(id INT Identity(1,1), Tags VARCHAR(8000))
DECLARE @_vLayoutTag_Id INT=0
DECLARE @_vTag_Values VARCHAR(8000)=NULL
DECLARE @_vLO_Tags VARCHAR(8000)=NULL

DECLARE @_vTabLayoutPLTags TABLE(id INT Identity(1,1), PLTags VARCHAR(8000))
DECLARE @_vLayoutPLTag_Id INT=0
DECLARE @_vPLTag_Values VARCHAR(8000)=NULL
DECLARE @_vPLLO_Tags VARCHAR(8000)=NULL

DECLARE @_vTabLayoutMetrics TABLE(id INT Identity(1,1), MetStr VARCHAR(8000))
DECLARE @_vTabLayoutMetricsVal TABLE(id INT Identity(1,1), MetValue VARCHAR(500))
DECLARE @_vLayoutMetricsVal VARCHAR(500)=NULL

DECLARE @_vTabLayoutShare TABLE(id INT Identity(1,1), ShareWithValue VARCHAR(8000))
DECLARE @_vShare_Type_Id INT=0
DECLARE @_vShare_With_Values VARCHAR(8000)=NULL
DECLARE @_vLO_ShareValues VARCHAR(8000)=NULL

DECLARE @_vTabLayoutOrdering TABLE(id INT Identity(1,1), TagType CHAR(2),TagId INT, Attrib_Seq VARCHAR(500))

BEGIN TRAN


			UPDATE GPM_WT_Layout
				SET
					Layout_Name=@vLayout_Name,
					Layout_Desc=@vLayout_Desc,
					Layout_Admin=@vLayout_Admin,
					Is_Deleted_Ind='N',
					Last_Modified_By=@vLast_Modified_By,
					Last_Modified_Date=GETDATE(),
					Edit_By_Sharees = @vEditable_By_Sharee
				WHERE Layout_Id = @vLayout_Id

				IF (@@ERROR <> 0) GOTO ERR_HANDLER

				IF(LEN(@vLayout_Tags)>0)
					BEGIN
						INSERT INTO @_vTabLayoutTags(Tags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayout_Tags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutTags
							
							DELETE FROM GPM_WT_Layout_Tag_Value WHERE Layout_Id = @vLayout_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLO_Tags=Tags FROM @_vTabLayoutTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vLO_Tags,1)
								SELECT @_vLayoutTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vLO_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vTag_Values=SUBSTRING(@_vLO_Tags,@_vRMSepPos+1, len(@_vLO_Tags))

								
								INSERT INTO GPM_WT_Layout_Tag_Value
								(
									Layout_Id,
									Layout_Tag_Id,
									Custom_ColName,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vLayout_Id,
									@_vLayoutTag_Id,
									@_vTag_Values,
									@vLast_Modified_By,
									GETDATE()
								)
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutTags WHERE id>@_vCnt
							END

						END
					END
					ELSE
					DELETE FROM GPM_WT_Layout_Tag_Value WHERE Layout_Id = @vLayout_Id


					IF(LEN(@vLayoutPLTags)>0)
					BEGIN
						INSERT INTO @_vTabLayoutPLTags(PLTags)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayoutPLTags) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutPLTags)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutPLTags

							DELETE FROM GPM_WT_Layout_PL_Tag_Value WHERE Layout_Id = @vLayout_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vPLLO_Tags=PLTags FROM @_vTabLayoutPLTags WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vPLLO_Tags,1)
								SELECT @_vLayoutPLTag_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vPLLO_Tags,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vPLTag_Values=SUBSTRING(@_vPLLO_Tags,@_vRMSepPos+1, len(@_vPLLO_Tags))

								
								INSERT INTO GPM_WT_Layout_PL_Tag_Value
								(
									Layout_Id,
									Layout_PL_Tag_Id,
									Custom_PL_ColName,
									Last_Modified_By,
									Last_Modified_Date
								)
								Values
								(
									@vLayout_Id,
									@_vLayoutPLTag_Id,
									@_vPLTag_Values,
									@vLast_Modified_By,
									GETDATE()
								)
								
								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutPLTags WHERE id>@_vCnt
							END

						END
					END
					ELSE
					DELETE FROM GPM_WT_Layout_PL_Tag_Value WHERE Layout_Id = @vLayout_Id

					IF(LEN(LTRIM(RTRIM(@vLayoutCustomFields)))>0)
					BEGIN
					INSERT INTO @_vTabLayoutCF(CF)
					SELECT 	Tab.Value
						FROM Fn_SplitDelimetedData('~',@vLayoutCustomFields) Tab
					WHERE Len(RTRIM(LTRIM(Value)))>0

				
					IF((SELECT COUNT(*) FROM @_vTabLayoutCF)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutCF

							DELETE FROM GPM_WT_Layout_Custom_Fields WHERE Layout_Id = @vLayout_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT  @_vCF_Id=NULL,
										@_vCF_CustName=NULL,
										@_vCF_DL=NULL

								SELECT @_vCF_Values=CF FROM @_vTabLayoutCF WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vCF_Values,1)
								SELECT @_vRMSepPosSc=CHARINDEX('|',@_vCF_Values,@_vRMSepPos+1)								


								SELECT @_vCF_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vCF_Values,1, @_vRMSepPos-1))) AS INT)

								IF(LEN(LTRIM(RTRIM(@_vCF_Id)))<=0)
								SELECT @_vCF_Id=NULL

								SELECT @_vCF_CustName =RTRIM(LTRIM(SUBSTRING(@_vCF_Values,@_vRMSepPos+1, @_vRMSepPosSc-(@_vRMSepPos+1))))

								IF(LEN(LTRIM(RTRIM(@_vCF_CustName)))<=0)
								SELECT @_vCF_CustName=NULL
									
								SELECT @_vCF_DL =CAST(SUBSTRING(@_vCF_Values,@_vRMSepPosSc+1, len(@_vCF_Values)) AS INT)

								SELECT @_vCF_DL=CASE WHEN @_vCF_DL=0 OR @_vCF_DL=NULL THEN 8000 ELSE @_vCF_DL END 

								IF NOT(@_vCF_Id IS NULL AND @_vCF_CustName IS NULL AND @_vCF_DL IS NULL)
								INSERT INTO GPM_WT_Layout_Custom_Fields
									(
										Layout_Id,
										Custom_Field_Tag_Id,
										Custom_Field_Cust_ColName,
										Custom_Field_Display_Len
									)
								Values
									(
										@vLayout_Id,
										@_vCF_Id,
										@_vCF_CustName,
										@_vCF_DL 
									)

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

							SELECT @_vCnt=MIN(id) FROM @_vTabLayoutCF WHERE id>@_vCnt
						END
					END
					END
					ELSE
					DELETE FROM GPM_WT_Layout_Custom_Fields WHERE Layout_Id = @vLayout_Id

					IF(LEN(@vLayoutMetrics)>0)
					BEGIN
						INSERT INTO @_vTabLayoutMetrics(MetStr)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayoutMetrics) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0

					SELECT @_vCnt=0, @_vMaxCnt=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutMetrics)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutMetrics
							
							DELETE FROM GPM_WT_Layout_Metrics_Value WHERE Layout_Id = @vLayout_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLayoutMetricsVal = MetStr FROM @_vTabLayoutMetrics WHERE id=@_vCnt

								DELETE FROM @_vTabLayoutMetricsVal

								INSERT INTO @_vTabLayoutMetricsVal(MetValue)
								SELECT 
								CASE WHEN LEN(RTRIM(LTRIM(Value)))>0 THEN Value ELSE NULL END
								from Fn_SplitDelimetedData('|',@_vLayoutMetricsVal)
								
								INSERT INTO GPM_WT_Layout_Metrics_Value
								(
									Layout_Id,
									Metric_Id,
									Metric_TDC_Type_Id,
									Metric_Field_Id,
									Period_Id,
									Start_Month_Id,
									Start_Quarter_Id,
									Start_Year,
									End_Month_Id,
									End_Quarter_Id,
									End_Year,
									Custom_ColName,
									Precision,
									Program_Id,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT  @vLayout_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+0) AS Metric_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+1) AS Metric_TDC_Type_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+2) AS Metric_Field_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+3) AS Period_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+4) AS Start_Month_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+5) AS Start_Quarter_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+6) AS Start_Year,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+7) AS End_Month_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+8) AS End_Quarter_Id,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+9) AS End_Year,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+10) AS Custom_ColName,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+11) AS Precision,
									   (SELECT MetValue FROM @_vTabLayoutMetricsVal WHERE id=(SELECT MIN(id) FROM @_vTabLayoutMetricsVal)+12) AS Program_Id,
									   @vLast_Modified_By,
									   GETDATE()

								IF (@@ERROR <> 0) GOTO ERR_HANDLER
								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutMetrics WHERE id>@_vCnt
							END

						END
					END
					ELSE
					DELETE FROM GPM_WT_Layout_Metrics_Value WHERE Layout_Id = @vLayout_Id


					IF(LEN(RTRIM(LTRIM(@vLayout_Share_People)))>0)
					INSERT INTO @_vTabLayoutShare(ShareWithValue) VALUES(@vLayout_Share_People)


					IF(LEN(@vLayout_Share_Facility)>0)
					BEGIN
						INSERT INTO @_vTabLayoutShare(ShareWithValue)
							SELECT 	Tab.Value
									FROM Fn_SplitDelimetedData('~',@vLayout_Share_Facility) Tab
										WHERE Len(RTRIM(LTRIM(Value)))>0
					END
					SELECT @_vCnt=0, @_vMaxCnt=0, @_vRMSepPos=0

					IF((SELECT COUNT(*) FROM @_vTabLayoutShare)>0)
						BEGIN
							SELECT @_vCnt=MIN(id), @_vMaxCnt= MAX(id) FROM @_vTabLayoutShare

							DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id = @vLayout_Id

							WHILE(@_vCnt<@_vMaxCnt+1)
							BEGIN

								SELECT @_vLO_ShareValues=ShareWithValue FROM @_vTabLayoutShare WHERE id=@_vCnt

								SELECT @_vRMSepPos=CHARINDEX('|',@_vLO_ShareValues,1)
								SELECT @_vShare_Type_Id=CAST(RTRIM(LTRIM(SUBSTRING(@_vLO_ShareValues,1, @_vRMSepPos-1))) AS INT)
								SELECT @_vShare_With_Values=SUBSTRING(@_vLO_ShareValues,@_vRMSepPos+1, len(@_vLO_ShareValues))

								
								INSERT INTO GPM_WT_Layout_Sharing
								(
									Layout_Id,
									Share_Type_Id,
									Share_With_Values,
									Share_By,
									Last_Modified_By,
									Last_Modified_Date
								)
								SELECT
									@vLayout_Id,
									@_vShare_Type_Id,
									Tab.Value,
									@vLast_Modified_By,
									@vLast_Modified_By,
									GETDATE()
								FROM Fn_SplitDelimetedData(',',@_vShare_With_Values) Tab
									WHERE Len(RTRIM(LTRIM(Value)))>0

								IF (@@ERROR <> 0) GOTO ERR_HANDLER

								SELECT @_vCnt=MIN(id) FROM @_vTabLayoutShare WHERE id>@_vCnt
							END

						END
					ELSE
					DELETE FROM GPM_WT_Layout_Sharing WHERE Layout_Id = @vLayout_Id

					IF(LEN(@vLayout_Order)>0)
					BEGIN

						DELETE FROM GPM_WT_Layout_Tag_Order WHERE Layout_Id = @vLayout_Id

						INSERT INTO @_vTabLayoutOrdering(TagType,TagId, Attrib_Seq)
						/*
						 SELECT RTRIM(LTRIM(SUBSTRING(TAB.TagValue,1, (CHARINDEX('|',TAB.TagValue,1))-1))),
								SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue,1))+1, len(TAB.TagValue))
								*/

									SELECT RTRIM(LTRIM(SUBSTRING(TAB.TagValue,1, (CHARINDEX('|',TAB.TagValue,1))-1))),
								SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue,1))+1, ((CHARINDEX('|',TAB.TagValue, (CHARINDEX('|',TAB.TagValue,1))+1 )))- ((CHARINDEX('|',TAB.TagValue,1))+1)),
										SUBSTRING(TAB.TagValue,(CHARINDEX('|',TAB.TagValue, (CHARINDEX('|',TAB.TagValue,1))+1 ))+1, len(TAB.TagValue))
							FROM
								(
									SELECT 	Tab.Value AS TagValue
										FROM Fn_SplitDelimetedData('~',@vLayout_Order) Tab
											WHERE Len(RTRIM(LTRIM(Value)))>0
										)	TAB

								INSERT INTO GPM_WT_Layout_Tag_Order
								(
									Layout_Id,
									Layout_Tag_Order_Id,
									Layout_Tag_Type_Id,
									Layout_Tag_Id,
									Attrib_Seq
								)
								SELECT @vLayout_Id,
								id, 
								TagType,--(SELECT CASE WHEN TagType='PL' THEN 10 WHEN TagType='PT' THEN 11 WHEN TagType='PC' THEN 12 WHEN TagType='PM' THEN 13 END),
								TagId,
								Attrib_Seq
								FROM @_vTabLayoutOrdering


							IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END
					ELSE
					DELETE FROM GPM_WT_Layout_Tag_Order WHERE Layout_Id = @vLayout_Id

					IF((LEN(RTRIM(LTRIM(@vLayout_Share_People)))>0 OR LEN(RTRIM(LTRIM(@vLayout_Share_Facility)))>0) AND @vLayout_Share_Facility!='~')
					BEGIN
						DELETE FROM GPM_WT_Layout_Visibility WHERE Layout_Id = @vLayout_Id	
						DECLARE @_vShareWithString VARCHAR(MAX)= @vLayout_Share_People +'~'+ @vLayout_Share_Facility
						
						DECLARE	@_vShared_UserList VARCHAR(MAX)
						EXEC	[Sp_GetUserList_ByShareWithString]
								@vSharewith =@_vShareWithString,
								@vUserList = @_vShared_UserList OUTPUT
						
						IF(LEN(RTRIM(LTRIM(@_vShared_UserList)))>0 OR ISNULL(@_vShared_UserList,'Y')!='Y')
							INSERT INTO GPM_WT_Layout_Visibility VALUES(@vLayout_Id,@_vShared_UserList)
						
						IF (@@ERROR <> 0) GOTO ERR_HANDLER
					END
					ELSE
					DELETE FROM GPM_WT_Layout_Visibility WHERE Layout_Id = @vLayout_Id	


				SELECT @vMsg_Out ='Layout Updated Successfully'
	COMMIT TRAN
	RETURN 1
			
	ERR_HANDLER:
	BEGIN
			SELECT @vMsg_Out='Failed To Update Layout Details-'+ ERROR_MESSAGE();
		IF (@@TRANCOUNT>0)
		ROLLBACK TRAN
		RETURN 0
	END

END





GO
/****** Object:  Table [dbo].[GPM_WT_Layout_Visibility]    Script Date: 12/2/2019 9:52:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GPM_WT_Layout_Visibility](
	[Layout_Id] [int] NOT NULL,
	[User_List] [varchar](max) NOT NULL,
 CONSTRAINT [PK_GPM_WT_Layout_Visibility_Layout_Id] PRIMARY KEY CLUSTERED 
(
	[Layout_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[GPM_WT_Layout_Visibility]  WITH CHECK ADD  CONSTRAINT [FK_GPM_WT_Layout_GPM_WT_Portfolio_Visibility_Layout_Id] FOREIGN KEY([Layout_Id])
REFERENCES [dbo].[GPM_WT_Layout] ([Layout_Id])
GO
ALTER TABLE [dbo].[GPM_WT_Layout_Visibility] CHECK CONSTRAINT [FK_GPM_WT_Layout_GPM_WT_Portfolio_Visibility_Layout_Id]
GO
