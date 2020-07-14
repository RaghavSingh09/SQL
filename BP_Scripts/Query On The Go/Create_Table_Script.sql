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


DECLARE create_table_script_cur CURSOR LOCAL FOR     
SELECT TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE,COLUMN_DEFAULT,NUMERIC_PRECISION,NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN(SELECT TOP 5 NAME FROM SYS.TABLES WHERE NAME LIKE 'GPM_%')--= 'GPM_WT_DMAIC'
ORDER BY TABLE_NAME,ORDINAL_POSITION    
  
OPEN create_table_script_cur    
  
FETCH NEXT FROM create_table_script_cur INTO @vTABLE_SCHEMA,@vTABLE_NAME,@vCOLUMN_NAME,@vDATA_TYPE,@vCHARACTER_MAXIMUM_LENGTH,@vIS_NULLABLE,@vCOLUMN_DEFAULT,@vNUMERIC_PRECISION,@vNUMERIC_SCALE
  
	WHILE @@FETCH_STATUS = 0    
	BEGIN
		IF(@vTNC = @vTABLE_NAME OR @vTNC IS NULL)
		BEGIN
			SET @vCTHeader = 'SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE ['+@vTABLE_SCHEMA+'].['+@vTABLE_NAME+']( '+CHAR(13)
			SET @vCTS += @vCOLUMN_NAME+' '+CASE WHEN UPPER(@vDATA_TYPE) LIKE '%CHAR' THEN @vDATA_TYPE+'('+CAST(@vCHARACTER_MAXIMUM_LENGTH AS VARCHAR)+'),'+CHAR(13)
												WHEN UPPER(@vDATA_TYPE) IN('NUMERIC','FLOAT','DOUBLE') THEN @vDATA_TYPE+'('+CAST(@vNUMERIC_PRECISION AS VARCHAR)+','+CAST(@vNUMERIC_SCALE AS VARCHAR)+'),'+CHAR(13) 
												ELSE @vDATA_TYPE+','+CHAR(13) END
			SET @vTNC = @vTABLE_NAME
		END
		ELSE
		BEGIN
			PRINT REPLACE(@vCTHeader+@vCTS+')' +CHAR(13)+'GO
SET ANSI_PADDING OFF
GO',','+CHAR(13)+')',CHAR(13)+')')
			SET @vTNC = @vTABLE_NAME
			SET @vCTHeader =''
			SET @vCTS =''
		END
		
		FETCH NEXT FROM create_table_script_cur INTO @vTABLE_SCHEMA,@vTABLE_NAME,@vCOLUMN_NAME,@vDATA_TYPE,@vCHARACTER_MAXIMUM_LENGTH,@vIS_NULLABLE,@vCOLUMN_DEFAULT,@vNUMERIC_PRECISION,@vNUMERIC_SCALE
   
	END     
CLOSE create_table_script_cur;
--PRINT @vCTHeader+@vCTS+')'
DEALLOCATE create_table_script_cur;    