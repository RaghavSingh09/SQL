DECLARE @vtable VARCHAR(128),@vfile VARCHAR(2000),@vcmd VARCHAR(2000)
DECLARE @vDB_Name VARCHAR(128),@vSchema VARCHAR(100), @vTableName VARCHAR(500)

SET @vDB_Name = 'Test'

DECLARE BCP_Table_BKP CURSOR
    FOR SELECT TABLE_SCHEMA,TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
	OPEN BCP_Table_BKP;
	FETCH NEXT FROM BCP_Table_BKP INTO @vSchema,@vTableName;

	WHILE @@FETCH_STATUS = 0  
    BEGIN
		
		SET @vtable = @vDB_Name+'.'+@vSchema+'.'+@vTableName
		SET @vfile = 'C:\Users\rkumar699\Desktop\DB_BKPs\BCP\' + @vtable + '_' + CONVERT(CHAR(8), GETDATE(), 112)+ '.dat'
		SET @vcmd = 'bcp ' + @vtable + ' out ' + @vfile + ' -n -T '
		EXEC master..xp_cmdshell @vcmd

		SET @vtable=''
		SET @vfile=''
		SET @vcmd=''
		PRINT 'Copied Table '+@vSchema+'.'+@vTableName
        FETCH NEXT FROM BCP_Table_BKP INTO @vSchema,@vTableName;
    END;

	CLOSE BCP_Table_BKP;
	DEALLOCATE BCP_Table_BKP;