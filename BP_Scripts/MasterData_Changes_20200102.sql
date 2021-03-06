/****** Object:  StoredProcedure [dbo].[Sp_AddTagMasterDetails]    Script Date: 1/2/2020 10:12:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_AddTagMasterDetails]
@vEdit_Tag_Id INT,
@vElement_Desc VARCHAR(200),
@vIs_MDPO CHAR(1)=NULL,
@vCreated_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @_vDynDelQuery NVARCHAR(MAX)=NULL
DECLARE @_vIs_Deleted_Ind CHAR(1)=''
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTTagName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIsMDPO CHAR(1)='N'
DECLARE @_vIs_Data INT
DECLARE @_vMaxRowCount INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTTagName=Edit_Tag_Desc,
			@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vIsMDPO=Is_MDPO 
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id
ELSE
	BEGIN
		SELECT @vMsg_Out = 'Invalid Master Table Tag'
		RETURN 0
	END

IF (@vElement_Desc IS NULL OR LEN(RTRIM(LTRIM(@vElement_Desc)))<1)
	BEGIN
		SELECT @vMsg_Out ='Invalid '+@_vMTTagName
		RETURN 0
	END

SET @_vDynDelQuery='SELECT @_vMaxRowCount=MAX('+@_vMTPKColName+') FROM '+@_vMTName
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vMaxRowCount INT OUTPUT', @_vMaxRowCount OUTPUT

SET @_vDynDelQuery = ''
SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT

IF(@_vIs_Data>0)
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery = ' SELECT @_vIs_Deleted_Ind = Is_Deleted_Ind FROM ' +  @_vMTName + ' WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
		EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Deleted_Ind CHAR(1) OUTPUT', @_vIs_Deleted_Ind OUTPUT
		
		IF(@_vIs_Deleted_Ind='N')
			SELECT @vMsg_Out =@_vMTTagName+' Already Exists'
		ELSE
		IF(@_vIs_Deleted_Ind IS NULL OR @_vIs_Deleted_Ind='Y')
		BEGIN
			
			IF(@_vIsMDPO='Y')
				BEGIN
					SET @_vDynDelQuery =''
					SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
							SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
							Is_Deleted_Ind=''N'',
							Is_MDPO=CASE WHEN '''+@vIs_MDPO+'''=''Y'' THEN ''Y'' ELSE ''N'' END,
							Last_Modified_By='''+@vCreated_By +''',
							Last_Modified_Date=GETDATE()
						WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'

						EXEC(@_vDynDelQuery)

						IF(@@Rowcount>0)
							SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
						ELSE
							SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
				END
			ELSE
				BEGIN
					SET @_vDynDelQuery =''
					SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
							SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
							Is_Deleted_Ind=''N'',
							Last_Modified_By='''+@vCreated_By +''',
							Last_Modified_Date=GETDATE()
						WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'

						EXEC(@_vDynDelQuery)

						IF(@@Rowcount>0)
							SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
						ELSE
							SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
				END
		END

		RETURN 1
	END
ELSE
	BEGIN
		IF(@_vIsMDPO='Y')
			BEGIN
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='INSERT INTO '+@_vMTName+
					'(
						'+@_vMTPKColName+',
						'+@_vMTPKColDescName+',
						Is_Deleted_Ind,
						Is_MDPO,
						Created_By,
						Created_Date
					)
				VALUES
					(
						'+CAST(@_vMaxRowCount+1 AS VARCHAR(10))+',
						'''+@vElement_Desc+''',
						''N'',
						CASE WHEN '''+@vIs_MDPO+'''=''Y'' THEN ''Y'' ELSE ''N'' END,
						'''+@vCreated_By+''',
						GETDATE()
					)'
			
				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
			END
		ELSE
			BEGIN
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='INSERT INTO '+@_vMTName+
					'(
						'+@_vMTPKColName+',
						'+@_vMTPKColDescName+',
						Is_Deleted_Ind,
						Created_By,
						Created_Date
					)
				VALUES
					(
						'+CAST(@_vMaxRowCount+1 AS VARCHAR(10))+',
						'''+@vElement_Desc+''',
						''N'',
						'''+@vCreated_By+''',
						GETDATE()
					)'
			
				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
			END
	END
RETURN 1

END
GO
/****** Object:  StoredProcedure [dbo].[Sp_AddTagMasterDetails_OneDep]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_AddTagMasterDetails_OneDep]
@vEdit_Tag_Id INT,
@vDep_Ele_Id INT,
@vElement_Desc VARCHAR(200),
@vCreated_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @_vDynDelQuery NVARCHAR(MAX)=NULL
DECLARE @_vIs_Deleted_Ind CHAR(1)=''
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTTagName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTFKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIsMDPO CHAR(1)='N'
DECLARE @_vIs_Data INT
DECLARE @_vMaxRowCount INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTTagName=Edit_Tag_Desc,
			@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vMTFKColName=Edit_Tag_Table_FKCol_Name,
			@_vIsMDPO=Is_MDPO 
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id
ELSE
	BEGIN
		SELECT @vMsg_Out = 'Invalid Master Table Tag'
		RETURN 0
	END

IF (@vElement_Desc IS NULL OR LEN(RTRIM(LTRIM(@vElement_Desc)))<1)
	BEGIN
		SELECT @vMsg_Out ='Invalid '+@_vMTTagName
		RETURN 0
	END

SET @_vDynDelQuery='SELECT @_vMaxRowCount=MAX('+@_vMTPKColName+') FROM '+@_vMTName
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vMaxRowCount INT OUTPUT', @_vMaxRowCount OUTPUT

SET @_vDynDelQuery = ''
SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE '+CAST(@_vMTFKColName AS VARCHAR)+' = '+CAST(@vDep_Ele_Id AS VARCHAR)+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT

IF(@_vIs_Data>0)
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery = ' SELECT @_vIs_Deleted_Ind = Is_Deleted_Ind FROM ' +  @_vMTName + ' WHERE '+CAST(@_vMTFKColName AS VARCHAR)+' = '+CAST(@vDep_Ele_Id AS VARCHAR)+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
		EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Deleted_Ind CHAR(1) OUTPUT', @_vIs_Deleted_Ind OUTPUT
		
		IF(@_vIs_Deleted_Ind='N')
			SELECT @vMsg_Out =@_vMTTagName+' Already Exists'
		ELSE
		IF(@_vIs_Deleted_Ind IS NULL OR @_vIs_Deleted_Ind='Y')
		BEGIN
			SET @_vDynDelQuery =''
			SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
					SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
					Is_Deleted_Ind=''N'',
					Last_Modified_By='''+@vCreated_By +''',
					Last_Modified_Date=GETDATE()
				WHERE '+CAST(@_vMTFKColName AS VARCHAR)+' = '+CAST(@vDep_Ele_Id AS VARCHAR)+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'

				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
		END
		

		RETURN 1
	END
ELSE
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery ='INSERT INTO '+@_vMTName+
			'(
				'+@_vMTPKColName+',
				'+@_vMTPKColDescName+',
				'+@_vMTFKColName+',
				Is_Deleted_Ind,
				Created_By,
				Created_Date
			)
		VALUES
			(
				'+CAST(@_vMaxRowCount+1 AS VARCHAR)+',
				'''+@vElement_Desc+''',
				'+CAST(@vDep_Ele_Id AS VARCHAR)+',
				''N'',
				'''+@vCreated_By+''',
				GETDATE()
			)'
			
		EXEC(@_vDynDelQuery)

		IF(@@Rowcount>0)
			SELECT @vMsg_Out =@_vMTTagName+' Added Successfully'
		ELSE
			SELECT @vMsg_Out ='Failed To Add '+@_vMTTagName
	END
RETURN 1

END
GO
/****** Object:  StoredProcedure [dbo].[Sp_DelTagMasterDetails]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_DelTagMasterDetails]
@vEdit_Tag_Id INT,
@vElement_Id INT,
@vLast_Modified_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @_vDynDelQuery NVARCHAR(MAX)=NULL
DECLARE @_vIs_Deleted_Ind CHAR(1)=''
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTTagName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIs_Data INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTTagName=Edit_Tag_Desc,
			@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name 
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id
ELSE
	BEGIN
		SELECT @vMsg_Out = 'Invalid Master Table Tag'
		RETURN 0
	END

	SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE ' + @_vMTPKColName +' = '+ CAST(@vElement_Id AS VARCHAR(10))
	EXECUTE sp_executeSQL @_vDynDelQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT

	IF(@_vIs_Data>0)
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery = ' SELECT @_vIs_Deleted_Ind = Is_Deleted_Ind FROM ' +  @_vMTName + ' WHERE ' + @_vMTPKColName +' = '+ CAST(@vElement_Id AS VARCHAR(10))
		EXECUTE sp_executeSQL @_vDynDelQuery, N'@_vIs_Deleted_Ind CHAR(1) OUTPUT', @_vIs_Deleted_Ind OUTPUT

		IF(@_vIs_Deleted_Ind='Y')
			SELECT @vMsg_Out =@_vMTTagName+' Already Deleted'
		ELSE
			BEGIN
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
					SET 
					Is_Deleted_Ind=''Y'',
					Last_Modified_By='''+@vLast_Modified_By +''',
					Last_Modified_Date=GETDATE()
				WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10)) 

				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Deleted Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Delete '+@_vMTTagName
			END		
	END

END


GO
/****** Object:  StoredProcedure [dbo].[Sp_GetAllMasterTags]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetAllMasterTags]
AS
BEGIN
	SELECT Edit_Tag_Id,Edit_Tag_Desc,ISNULL(REPLACE(REPLACE(Edit_Tag_Table_FK_Name,'GPM_',''),'_',' '),'') AS Edit_Tag_Dep_Desc,Is_MDPO,View_Col_Count FROM GPM_Master_Tags_Edit_Details WHERE Is_Deleted_Ind='N'
END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetMasterTagDetails_OneDep]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetMasterTagDetails_OneDep]
@vEdit_Tag_Id INT
AS
BEGIN
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTFKTableName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vMTFKColName VARCHAR(100)=NULL
DECLARE @_vMTFKColDescName VARCHAR(100)=NULL


IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vMTFKColName=Edit_Tag_Table_FKCol_Name,
			@_vMTFKColDescName=Edit_Tag_Table_FK_DescCol_Name,
			@_vMTFKTableName=Edit_Tag_Table_FK_Name
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id

DECLARE @_vTagObjDetails AS TABLE (Tag_Object_Id INT, Tag_Object_Desc VARCHAR(8000), Tag_FK_Object_Id INT, Tag_FK_Object_Desc VARCHAR(8000))


	IF(@vEdit_Tag_Id>40 AND @vEdit_Tag_Id NOT IN(41,43,46,49))
	BEGIN
		INSERT INTO @_vTagObjDetails (Tag_Object_Id,Tag_Object_Desc,Tag_FK_Object_Id,Tag_FK_Object_Desc)
		EXEC('SELECT A.'+@_vMTPKColName+', A.'+@_vMTPKColDescName+', B.'+@_vMTFKColName+', B.'+@_vMTFKColDescName+' FROM '+@_vMTName+' A LEFT OUTER JOIN '+@_vMTFKTableName+' B On A.'+@_vMTFKColName+' = B.'+@_vMTFKColName+' WHERE A.Is_Deleted_Ind=''N''')
	END

SELECT * FROM @_vTagObjDetails

END
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetMasterTagDetails_OneDepDropDownList]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetMasterTagDetails_OneDepDropDownList]
@vEdit_Tag_Id INT
AS
BEGIN
DECLARE @_vMTFKTableName VARCHAR(100)=NULL
DECLARE @_vMTFKColName VARCHAR(100)=NULL
DECLARE @_vMTFKColDescName VARCHAR(100)=NULL


IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTFKColName=Edit_Tag_Table_FKCol_Name,
			@_vMTFKColDescName=Edit_Tag_Table_FK_DescCol_Name,
			@_vMTFKTableName=Edit_Tag_Table_FK_Name
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id

DECLARE @_vTagObjDetails AS TABLE (Tag_Object_Id INT, Tag_Object_Desc VARCHAR(8000))


	IF(@vEdit_Tag_Id>40 AND @vEdit_Tag_Id NOT IN(41,43,46,49))
	BEGIN
		INSERT INTO @_vTagObjDetails (Tag_Object_Id,Tag_Object_Desc)
		EXEC('SELECT '+@_vMTFKColName+', '+@_vMTFKColDescName+' FROM '+@_vMTFKTableName+' WHERE Is_Deleted_Ind=''N''')
	END

SELECT * FROM @_vTagObjDetails

END

GO
/****** Object:  StoredProcedure [dbo].[Sp_GetTagMasterDetails]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_GetTagMasterDetails]
@vEdit_Tag_Id INT
AS
BEGIN
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIsMDPO CHAR(1)='N'
DECLARE @_vIs_Data INT
DECLARE @_vMaxRowCount INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vIsMDPO=Is_MDPO
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id

DECLARE @_vTagObjDetails AS TABLE (Tag_Object_Id INT, Tag_Object_Desc VARCHAR(8000), Tag_Is_Mdpo CHAR(1) DEFAULT 'N')

IF(@_vIsMDPO='Y')
	BEGIN
		INSERT INTO @_vTagObjDetails (Tag_Object_Id,Tag_Object_Desc,Tag_Is_Mdpo)
		EXEC('SELECT '+@_vMTPKColName+', '+@_vMTPKColDescName+',Is_MDPO FROM '+@_vMTName+' WHERE Is_Deleted_Ind=''N''')
	END
ELSE
	BEGIN
		INSERT INTO @_vTagObjDetails (Tag_Object_Id,Tag_Object_Desc)
		EXEC('SELECT '+@_vMTPKColName+', '+@_vMTPKColDescName+' FROM '+@_vMTName+' WHERE Is_Deleted_Ind=''N''')
	END

SELECT * FROM @_vTagObjDetails

END
GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdTagMasterDetails]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_UpdTagMasterDetails]
@vEdit_Tag_Id INT,
@vElement_Id INT,
@vElement_Desc VARCHAR(200),
@vIs_MDPO CHAR(1)=NULL,
@vLast_Modified_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @_vDynDelQuery NVARCHAR(MAX)=NULL
DECLARE @_vIs_Deleted_Ind CHAR(1)=''
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTTagName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIsMDPO CHAR(1)='N'
DECLARE @_vIs_Data INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTTagName=Edit_Tag_Desc,
			@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vIsMDPO=Is_MDPO 
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id
ELSE
	BEGIN
		SELECT @vMsg_Out = 'Invalid Master Table Tag'
		RETURN 0
	END

IF (@vElement_Desc IS NULL OR LEN(RTRIM(LTRIM(@vElement_Desc)))<1)
	BEGIN
		SELECT @vMsg_Out ='Invalid '+@_vMTTagName
		RETURN 0
	END

SET @_vDynDelQuery = ''
SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE '+@_vMTPKColName+' <> '+CAST(@vElement_Id AS VARCHAR(10))+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT
IF(@_vIs_Data>0)
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery = ' SELECT @_vIs_Deleted_Ind = Is_Deleted_Ind FROM ' +  @_vMTName + ' WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
		EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Deleted_Ind CHAR(1) OUTPUT', @_vIs_Deleted_Ind OUTPUT

		IF(@_vIs_Deleted_Ind='N')
			BEGIN
				SELECT @vMsg_Out =@_vMTTagName+' Already Exists'
				RETURN 0
			END
		ELSE
			BEGIN

			IF(@_vIsMDPO='Y')
				BEGIN
					SET @_vDynDelQuery =''
					SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
						SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
						Is_Deleted_Ind=''N'',
						Is_MDPO=CASE WHEN '''+@vIs_MDPO+'''=''Y'' THEN ''Y'' ELSE ''N'' END,
						Last_Modified_By='''+@vLast_Modified_By +''',
						Last_Modified_Date=GETDATE()
					WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'+CHAR(13)+

					'UPDATE '+ @_vMTName +'
						SET 
						Is_Deleted_Ind=''Y'',
						Last_Modified_By='''+@vLast_Modified_By +''',
						Last_Modified_Date=GETDATE()
					WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))
					PRINT @_vDynDelQuery
					EXEC(@_vDynDelQuery)

					IF(@@Rowcount>0)
						SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
					ELSE
						SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
				END
			ELSE
				BEGIN
					SET @_vDynDelQuery =''
					SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
						SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
						Is_Deleted_Ind=''N'',
						Last_Modified_By='''+@vLast_Modified_By +''',
						Last_Modified_Date=GETDATE()
					WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'+CHAR(13)+

					'UPDATE '+ @_vMTName +'
						SET 
						Is_Deleted_Ind=''Y'',
						Last_Modified_By='''+@vLast_Modified_By +''',
						Last_Modified_Date=GETDATE()
					WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))
					PRINT @_vDynDelQuery
					EXEC(@_vDynDelQuery)

					IF(@@Rowcount>0)
						SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
					ELSE
						SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
				END
		END
		RETURN 1
	END
ELSE
	BEGIN
		
		IF(@_vIsMDPO='Y')
			BEGIN
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
					SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
					Is_Deleted_Ind=''N'',
					Is_MDPO=CASE WHEN '''+@vIs_MDPO+'''=''Y'' THEN ''Y'' ELSE ''N'' END,
					Last_Modified_By='''+@vLast_Modified_By +''',
					Last_Modified_Date=GETDATE()
				WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))

				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
			END
		ELSE
			BEGIN
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
					SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
					Is_Deleted_Ind=''N'',
					Last_Modified_By='''+@vLast_Modified_By +''',
					Last_Modified_Date=GETDATE()
				WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))

				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
			END

	RETURN 1
	END

END
GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdTagMasterDetails_OneDep]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_UpdTagMasterDetails_OneDep]
@vEdit_Tag_Id INT,
@vElement_Id INT,
@vFK_Element_Id INT,
@vElement_Desc VARCHAR(200),
@vLast_Modified_By VARCHAR(10),
@vMsg_Out VARCHAR(100) OUT
AS
BEGIN
DECLARE @_vDynDelQuery NVARCHAR(MAX)=NULL
DECLARE @_vIs_Deleted_Ind CHAR(1)=''
DECLARE @_vMTName VARCHAR(100)=NULL
DECLARE @_vMTTagName VARCHAR(100)=NULL
DECLARE @_vMTPKColName VARCHAR(100)=NULL
DECLARE @_vMTFKColName VARCHAR(100)=NULL
DECLARE @_vMTPKColDescName VARCHAR(100)=NULL
DECLARE @_vIsMDPO CHAR(1)='N'
DECLARE @_vIs_Data INT

IF EXISTS(SELECT 1 FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id AND Is_Deleted_Ind='N')
	SELECT	@_vMTTagName=Edit_Tag_Desc,
			@_vMTName=Edit_Tag_Table_Name,
			@_vMTPKColName= Edit_Tag_Table_PKCol_Name, 
			@_vMTPKColDescName=Edit_Tag_Table_DescCol_Name,
			@_vMTFKColName=Edit_Tag_Table_FKCol_Name
	FROM GPM_Master_Tags_Edit_Details WHERE Edit_Tag_Id=@vEdit_Tag_Id
ELSE
	BEGIN
		SELECT @vMsg_Out = 'Invalid Master Table Tag'
		RETURN 0
	END

IF (@vElement_Desc IS NULL OR LEN(RTRIM(LTRIM(@vElement_Desc)))<1)
	BEGIN
		SELECT @vMsg_Out ='Invalid '+@_vMTTagName
		RETURN 0
	END

SET @_vDynDelQuery = ''
--SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE '+@_vMTPKColName+' <> '+CAST(@vElement_Id AS VARCHAR(10))+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
SET @_vDynDelQuery = 'SELECT @_vIs_Data = COUNT(1) FROM ' +  @_vMTName + ' WHERE '+@_vMTFKColName+' = '+CAST(@vFK_Element_Id AS VARCHAR(10))+ ' AND '+@_vMTPKColName+' <> '+CAST(@vElement_Id AS VARCHAR(10))+' AND UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
SELECT @_vDynDelQuery
EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Data INT OUTPUT', @_vIs_Data OUTPUT
IF(@_vIs_Data>0)
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery = ' SELECT @_vIs_Deleted_Ind = Is_Deleted_Ind FROM ' +  @_vMTName + ' WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'
		EXECUTE SP_EXECUTESQL @_vDynDelQuery, N'@_vIs_Deleted_Ind CHAR(1) OUTPUT', @_vIs_Deleted_Ind OUTPUT

		IF(@_vIs_Deleted_Ind='N')
			BEGIN
				SELECT @vMsg_Out =@_vMTTagName+' Already Exists'
				RETURN 0
			END
		ELSE
			BEGIN
			
				SET @_vDynDelQuery =''
				SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
					SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
					Is_Deleted_Ind=''N'',
					Last_Modified_By='''+@vLast_Modified_By +''',
					Last_Modified_Date=GETDATE()
				WHERE UPPER(RTRIM(LTRIM(' + @_vMTPKColDescName +'))) = UPPER(RTRIM(LTRIM('''+ @vElement_Desc+''')))'+CHAR(13)+

				'UPDATE '+ @_vMTName +'
					SET 
					Is_Deleted_Ind=''Y'',
					Last_Modified_By='''+@vLast_Modified_By +''',
					Last_Modified_Date=GETDATE()
				WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))
				PRINT @_vDynDelQuery
				EXEC(@_vDynDelQuery)

				IF(@@Rowcount>0)
					SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
				ELSE
					SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
				
		END
		RETURN 1
	END
ELSE
	BEGIN
		SET @_vDynDelQuery =''
		SET @_vDynDelQuery ='UPDATE '+ @_vMTName +'
			SET '+ @_vMTPKColDescName+' = '''+@vElement_Desc+''',
			'+@_vMTFKColName+' = '+CAST(@vFK_Element_Id AS VARCHAR)+',
			Is_Deleted_Ind=''N'',
			Last_Modified_By='''+@vLast_Modified_By +''',
			Last_Modified_Date=GETDATE()
		WHERE '+@_vMTPKColName +'='+  CAST(@vElement_Id AS VARCHAR(10))

		EXEC(@_vDynDelQuery)

		IF(@@Rowcount>0)
			SELECT @vMsg_Out =@_vMTTagName+' Updated Successfully'
		ELSE
			SELECT @vMsg_Out ='Failed To Update '+@_vMTTagName
			

	RETURN 1
	END

END
GO
/****** Object:  Table [dbo].[GPM_Master_Tags_Edit_Details]    Script Date: 1/2/2020 10:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GPM_Master_Tags_Edit_Details](
	[Edit_Tag_Id] [int] NOT NULL,
	[Edit_Tag_Desc] [varchar](100) NOT NULL,
	[Edit_Tag_Table_Name] [varchar](100) NOT NULL,
	[Edit_Tag_Table_PKCol_Name] [varchar](100) NULL,
	[Edit_Tag_Table_DescCol_Name] [varchar](100) NULL,
	[Is_Deleted_Ind] [char](1) NULL,
	[Is_MDPO] [char](1) NULL,
	[Created_By] [varchar](10) NULL,
	[Created_Date] [datetime] NULL,
	[Last_Modified_By] [varchar](10) NULL,
	[Last_Modified_Date] [datetime] NULL,
	[View_Col_Count] [int] NULL,
	[Edit_Tag_Table_FKCol_Name] [varchar](100) NULL,
	[Edit_Tag_Table_FK_DescCol_Name] [varchar](100) NULL,
	[Edit_Tag_Table_FK_Name] [varchar](100) NULL,
 CONSTRAINT [PK_Edit_Tag_Id_Edit_Tag_Desc_Edit_Tag_Table_Name] PRIMARY KEY CLUSTERED 
(
	[Edit_Tag_Id] ASC,
	[Edit_Tag_Desc] ASC,
	[Edit_Tag_Table_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (10, N'Cost Category', N'GPM_Cost_Category', N'Cost_Cat_Id', N'Cost_Cat_Desc', N'N', N'Y', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (11, N'Primary Loss Category', N'GPM_Primary_Loss_Category', N'Prim_Loss_Cat_Id', N'Prim_Loss_Cat_Desc', N'N', N'Y', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (12, N'Product Category', N'GPM_Product_Category', N'Product_Cat_Id', N'Product_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (13, N'GBS Served Geographies', N'GPM_GBS_Geography', N'Gbs_Geography_Id', N'Gbs_Geography_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (14, N'Finance Impact Area', N'GPM_Finance_Impact_Area', N'Fin_Impact_Ar_Id', N'Fin_Impact_Ar_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (15, N'GBS Project Category', N'GPM_GBS_Project_Category', N'Gbs_Proj_Cat_Id', N'Gbs_Proj_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (16, N'GBS Expected Saving Location', N'GPM_GBS_ExpSaving_Loc', N'Gbs_ExpSV_Loc_Id', N'Gbs_ExpSV_Loc_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (17, N'GBS Project Type', N'GPM_GBS_Project_Type', N'Gbs_Proj_Type_Id', N'Gbs_Proj_Type_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (18, N'Program', N'GPM_Program', N'Program_Id', N'Program_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (19, N'Plant Optimization Pillar', N'GPM_Plant_Opt_Piller', N'Piller_Id', N'Piller_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (20, N'Regional Tracking Category', N'GPM_Reg_Track_Category', N'RegTrack_Cat_Id', N'RegTrack_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (21, N'Accounting Code', N'GPM_Account', N'Account_Id', N'Account_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (22, N'Constraint', N'GPM_Constraint', N'Constraint_Id', N'Constraint_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (23, N'Global MDPO Type', N'GPM_Global_MDPO_Type', N'Global_MDPO_Type_Id', N'Global_MDPO_Type_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (24, N'Material Group', N'GPM_Material_Group', N'Material_Group_Id', N'Material_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (25, N'MDPO Initiative', N'GPM_MDPO_Initiative', N'MDPO_Initiative_Id', N'MDPO_Initiative_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (26, N'Plant Trial', N'GPM_Plant_Trial', N'Plant_Trial_Id', N'Plant_Trial_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (27, N'Project Status', N'GPM_Project_Status', N'Proj_Status_Id', N'Proj_Status_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (28, N'Project Tracking Indicator', N'GPM_Project_Tracking', N'Proj_Track_Id', N'Proj_Track_Status', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (29, N'Project Type', N'GPM_Project_Type', N'Proj_Type_Id', N'Proj_Type_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (30, N'Spend Type', N'GPM_Spend_Type', N'Spend_Type_Id', N'Spend_Type_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (31, N'Rate or Non Rate', N'GPM_Rate_Type', N'Rate_Type_Id', N'Rate_Type_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (32, N'T&W Loss Categories', N'GPM_TW_Loss_Category', N'TW_Loss_Cat_Id', N'TW_Loss_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (33, N'Feasibility of Idea', N'GPM_Impact', N'Impact_Id', N'Impact_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (34, N'Product Group', N'GPM_Product_Group', N'Product_Group_Id', N'Product_Group_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (35, N'Business Area', N'GPM_Business_Area', N'BA_Id', N'BA_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (36, N'GBS Department', N'GPM_GBS_Department', N'Gbs_Dept_Id', N'Gbs_Dept_Name', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (37, N'GPH Category', N'GPM_GPH_Category', N'GPH_Cat_Id', N'GPH_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (38, N'Material Category', N'GPM_Material_Category', N'Material_Cat_Id', N'Material_Cat_Code', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (39, N'Project Main Category', N'GPM_Proj_Main_Category', N'Proj_Main_Cat_Id', N'Proj_Main_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (40, N'Project Codification', N'GPM_Project_Codification', N'Project_Codification_Id', N'Project_Codification_Desc', N'N', N'Y', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (41, N'Country', N'GPM_Country', N'Country_Code', N'Country_Name,Currency_Code,Currency_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 5, N'Region_Code', NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (42, N'Department', N'GPM_Department', N'Dept_ID', N'Dept_Name', N'N', N'N', NULL, NULL, NULL, NULL, 2, N'BA_Id', N'BA_Name', N'GPM_Business_Area')
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (43, N'Finance BPO', N'GPM_Finance_BPO', N'FN_BPO_ID', N'FN_BPO_Name', N'N', N'N', NULL, NULL, NULL, NULL, 3, N'Dept_ID,BA_Id', NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (44, N'GBS Business Unit', N'GPM_GBS_Business_Unit', N'Gbs_Buss_Unit_Id', N'Gbs_Buss_Unit_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 2, N'Gbs_Dept_Id', N'Gbs_Dept_Name', N'GPM_GBS_Department')
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (45, N'GPH Sub Category', N'GPM_GPH_Sub_Category', N'GPH_Sub_Cat_Id', N'GPH_Sub_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 2, N'GPH_Cat_Id', N'GPH_Cat_Desc', N'GPM_GPH_Category')
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (46, N'Location', N'GPM_Location', N'Location_ID', N'Location_Name', N'N', N'N', NULL, NULL, NULL, NULL, 3, N'Country_Code,Region_Code', NULL, NULL)
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (47, N'Material', N'GPM_Material', N'Material_Id', N'Material_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 2, N'Material_Cat_Id', N'Material_Cat_Code', N'GPM_Material_Category')
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (48, N'Project Category', N'GPM_Proj_Category', N'Proj_Cat_Id', N'Proj_Cat_Desc', N'N', N'N', NULL, NULL, NULL, NULL, 2, N'Proj_Main_Cat_Id', N'Proj_Main_Cat_Desc', N'GPM_Proj_Main_Category')
INSERT [dbo].[GPM_Master_Tags_Edit_Details] ([Edit_Tag_Id], [Edit_Tag_Desc], [Edit_Tag_Table_Name], [Edit_Tag_Table_PKCol_Name], [Edit_Tag_Table_DescCol_Name], [Is_Deleted_Ind], [Is_MDPO], [Created_By], [Created_Date], [Last_Modified_By], [Last_Modified_Date], [View_Col_Count], [Edit_Tag_Table_FKCol_Name], [Edit_Tag_Table_FK_DescCol_Name], [Edit_Tag_Table_FK_Name]) VALUES (49, N'Region', N'GPM_Region', N'Region_Code', N'Region_Name', N'N', N'N', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL)
