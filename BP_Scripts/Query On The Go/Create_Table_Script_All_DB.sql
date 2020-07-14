BEGIN
DECLARE @vDB_Name VARCHAR(100)
DECLARE @vTABLE_SCHEMA nvarchar(256)
DECLARE @vTABLE_NAME sysname
DECLARE @vCOLUMN_NAME sysname
DECLARE @vDATA_TYPE nvarchar(256)
DECLARE @vCHARACTER_MAXIMUM_LENGTH int
DECLARE @vIS_NULLABLE varchar(3)
DECLARE @vCOLUMN_DEFAULT nvarchar(2000)
DECLARE @vNUMERIC_PRECISION int
DECLARE @vNUMERIC_SCALE int
DECLARE @vTNC sysname = NULL
DECLARE @vCTS nvarchar(MAX) = ''
DECLARE @vCTHeader nvarchar(MAX) = ''
DECLARE @vCursorDynQuery NVARCHAR(MAX) = ''
DECLARE @vInnerSelectQuery NVARCHAR(MAX) = ''

DECLARE Get_DB_Name CURSOR LOCAL FOR
	
	SELECT NAME FROM SYS.DATABASES WHERE DATABASE_ID > 4 ORDER BY NAME

OPEN Get_DB_Name
	FETCH NEXT FROM Get_DB_Name INTO @vDB_Name

		WHILE @@FETCH_STATUS = 0

						BEGIN
						PRINT @vDB_Name
									
						DECLARE @GetTableInfo CURSOR
																
							SET @vCursorDynQuery= ('SET @cursor =  CURSOR FORWARD_ONLY STATIC FOR  SELECT TOP 10 TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE,COLUMN_DEFAULT,NUMERIC_PRECISION,NUMERIC_SCALE FROM ['+@vDB_Name+'].INFORMATION_SCHEMA.COLUMNS ORDER BY ORDINAL_POSITION OPEN @cursor')
								
							EXEC SYS.SP_EXECUTESQL @vCursorDynQuery,N'@cursor cursor output',@GetTableInfo OUTPUT

							FETCH NEXT FROM @GetTableInfo INTO @vTABLE_SCHEMA,@vTABLE_NAME,@vCOLUMN_NAME,@vDATA_TYPE,@vCHARACTER_MAXIMUM_LENGTH,@vIS_NULLABLE,@vCOLUMN_DEFAULT,@vNUMERIC_PRECISION,@vNUMERIC_SCALE

								WHILE @@FETCH_STATUS = 0
	
								BEGIN										
											--SELECT @vDB_Name,@vTABLE_SCHEMA,@vTABLE_NAME,@vCOLUMN_NAME,@vDATA_TYPE,@vCHARACTER_MAXIMUM_LENGTH,@vIS_NULLABLE,@vCOLUMN_DEFAULT,@vNUMERIC_PRECISION,@vNUMERIC_SCALE								
											SET @vCTHeader = 'CREATE TABLE ['+@vTABLE_SCHEMA+'].['+@vTABLE_NAME+']( '+CHAR(13)
											SET @vCTS += @vCOLUMN_NAME+' '+CASE WHEN UPPER(@vDATA_TYPE) LIKE '%CHAR' THEN @vDATA_TYPE+'('+CAST(@vCHARACTER_MAXIMUM_LENGTH AS VARCHAR)+'),'+CHAR(13)
																				WHEN UPPER(@vDATA_TYPE) IN('NUMERIC','FLOAT','DOUBLE') THEN @vDATA_TYPE+'('+CAST(@vNUMERIC_PRECISION AS VARCHAR)+','+CAST(@vNUMERIC_SCALE AS VARCHAR)+'),'+CHAR(13) 
																				ELSE @vDATA_TYPE+','+CHAR(13) END

									FETCH NEXT FROM @GetTableInfo INTO @vTABLE_SCHEMA,@vTABLE_NAME,@vCOLUMN_NAME,@vDATA_TYPE,@vCHARACTER_MAXIMUM_LENGTH,@vIS_NULLABLE,@vCOLUMN_DEFAULT,@vNUMERIC_PRECISION,@vNUMERIC_SCALE
								END
								CLOSE @GetTableInfo
								DEALLOCATE @GetTableInfo
								--IF CURSOR_STATUS('global','@GetTableInfo')>=-1
								--BEGIN
								--	DEALLOCATE @GetTableInfo
								--END
											
						SET @vCursorDynQuery = ''
						PRINT @vCTHeader+@vCTS+')'
						FETCH NEXT FROM Get_DB_Name INTO @vDB_Name
		END
		CLOSE Get_DB_Name
		IF CURSOR_STATUS('global','Get_DB_Name')>=-1
		BEGIN
			DEALLOCATE Get_DB_Name
		END

END