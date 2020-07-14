DECLARE @vTableName VARCHAR(100)    

--Select 1 from sys.tables ST INNER JOIN sys.columns SC On ST.object_id=SC.object_id WHERE ST.name NOT Like 'Temp%' AND ST.name NOT Like '%_WT%' AND SC.name = 'Created_By'

DECLARE add_col_cur CURSOR FOR     
Select ST.name from sys.tables ST WHERE ST.name IN('GPM_Spend_Type','GPM_Rate_Type','GPM_Program','GPM_Plant_Opt_Piller','GPM_Reg_Track_Category','GPM_Plant_Trial','GPM_TW_Loss_Category','GPM_Global_MDPO_Type','GPM_Project_Type','GPM_Project_Tracking','GPM_Product_Group','GPM_MDPO_Initiative','GPM_Constraint','GPM_Material_Group','GPM_Account','GPM_Project_Status','GPM_Impact')
--NOT Like 'Temp%' AND ST.name NOT Like '%_WT_%'    
  
OPEN add_col_cur    
  
FETCH NEXT FROM add_col_cur INTO @vTableName
  
	WHILE @@FETCH_STATUS = 0    
	BEGIN    
		IF EXISTS(SELECT 1 FROM PMT_Migration.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @vTableName AND COLUMN_NAME = 'Created_By')
			PRINT @vTableName+' Already Has Columns'
		ELSE
			BEGIN
				EXEC(
				'ALTER TABLE '+@vTableName+' ADD [Created_By] VARCHAR(10) NULL
				ALTER TABLE '+@vTableName+' ADD [Created_Date] DATETIME NULL
				ALTER TABLE '+@vTableName+' ADD [Last_Modified_By] VARCHAR(10) NULL
				ALTER TABLE '+@vTableName+' ADD [Last_Modified_Date] VARCHAR NULL'
				)

				PRINT 'Added Columns To '+@vTableName
			END
  
      
		FETCH NEXT FROM add_col_cur INTO @vTableName
   
	END     
CLOSE add_col_cur;    
DEALLOCATE add_col_cur;    