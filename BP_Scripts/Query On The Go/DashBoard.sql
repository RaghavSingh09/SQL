DECLARE @vPortfolio_Id INT=1056
DECLARE @vLayout_Id INT=1121

Declare @_vRow_ID INT
DECLARE @_vdynSql nvarchar(Max) = ''
DECLARE @_vCnt INT=0, @_vMaxCnt INT=0
DECLARE @_vObjCnt INT=0, @_vObjMaxCnt INT=0
DECLARE @_vDummy INT=0
DECLARE @_vWT_Project_Table_Name VARCHAR(100)='GPM_WT_Project'
DECLARE @_vLocationClause VARCHAR(max)=NULL
DECLARE @_vPF_WT_Codes varchar(1000)

DECLARE @_vProcessedWTndTag_Table AS TABLE (WT_Code varchar(10), TG_Table_Name VARCHAR(100))



DECLARE @_vRegion_Table AS TABLE (Region_Code Varchar(5))
DECLARE @_vRegionList VARCHAR(8000)=NULL
DECLARE @_vRegion_Code varchar(5)

DECLARE @_vCountry_Table AS TABLE (Country_Code char(3))
DECLARE @_vCountryList VARCHAR(8000)=NULL
DECLARE @_vCountry_Code char(3)

DECLARE @_vLocation_Table AS TABLE (Location_Id VARCHAR(5))
DECLARE @_vLocationList VARCHAR(8000)=NULL
DECLARE @_vLocation_Id VARCHAR(10)

--DECLARE @_vRegionList VARCHAR(8000)='NA,EMEA'

--DECLARE @_vCountryList VARCHAR(8000)='USA,KOR,CHN,IND'

--DECLARE @_vLocationList VARCHAR(8000)='307,308,309,312,157'


Declare @_vProcessedTag TABLE (Portfolio_Tag_Id INT)


DECLARE @_vWTQueriesTab AS TABLE(WT_Code VARCHAR(5), SelectField VARCHAR(MAX), SelectFrom VARCHAR(MAX), SelectWhere VARCHAR(MAX))
DECLARE @_vdynSqlSelectField nvarchar(Max) = ''
DECLARE @_vdynSqlFrom nvarchar(Max) = ''
DECLARE @_vdynSqlWhere nvarchar(Max) = ''
DECLARE @_vdynSqlFinalQuery nvarchar(Max) = ''

Declare @_vTab_Dyn_SQL_Table TABLE (Row_ID INT IDENTITY(1,1), Portfolio_Tag_Id Int,WT_Table_Name varchar(100), WT_Table_FK_Col_Name varchar(100), TG_Table_Name varchar(100), TG_Table_PK_Col_Name varchar(100), Portfolio_Tag_Value varchar(8000))       
Declare @_vPortfolio_Tag_Id int
Declare @_vPortfolio_Tag_Value varchar(8000)
Declare @_vWT_Table_Name varchar(100) 
Declare @_vWT_Table_FK_Col_Name varchar(100) 
Declare @_vTG_Table_Name varchar(100)
Declare @_vTG_Table_PK_Col_Name varchar(100)



DECLARE @_vLayoutTag_Table AS TABLE(Row_ID INT IDENTITY(1,1),LayoutTag_Id Int, TG_Table_Name VARCHAR(500),TG_Table_Desc_ColName VARCHAR(500),Custom_ColName VARCHAR(500))
DECLARE @_vLayoutTag_Id Int 
DECLARE @_vLayout_TG_Table_Name VARCHAR(500)
DECLARE @_vLayout_vTG_Table_Desc_ColName VARCHAR(500)
DECLARE @_vLayout_vCustom_ColName VARCHAR(500)

DECLARE @_vLayoutMetric_Table AS TABLE(Row_ID INT IDENTITY(1,1),Layout_Id int,Metric_Id int,Metric_TDC_Type_Id int, Metric_Field_Id int,Period_Id int,Start_Date datetime,End_Date datetime, 
										Custom_ColName varchar(500),Precision varchar(5),Program_Id int)
DECLARE  @_vLayout_Id int
DECLARE @_vMetric_Id int
DECLARE @_vMetric_TDC_Type_Id int
DECLARE @_vMetric_Field_Id int
DECLARE @_vPeriod_Id int
DECLARE @_vStart_Date datetime
DECLARE @_vEnd_Date datetime
DECLARE @_vCustom_ColName varchar(500)
DECLARE @_vPrecision varchar(5)
DECLARE @_vProgram_Id int


DECLARE @_vLayoutMetricPeriod_Table AS TABLE(TDCDate DATE)
DECLARE @_vTDCstartDate DATE
DECLARE @_vTDCendDate DATE
DECLARE @_vTDCMinDate DATE
DECLARE @_vTDCMaxDate DATE

DECLARE @_vMetColName VARCHAR(20)

                       
SELECT @_vPF_WT_Codes=WT_Codes FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id

DECLARE Outer_Cursor CURSOR FOR
       SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN
       (SELECT Value FROM Fn_SplitDelimetedData(',',@_vPF_WT_Codes))

DECLARE @_vWT_Table_Name_Cur varchar(100)
DECLARE @_vWT_Code_Cur  varchar(10)



INSERT INTO @_vLayoutTag_Table(LayoutTag_Id,TG_Table_Name,TG_Table_Desc_ColName,Custom_ColName)
       SELECT GWLTV.Layout_Tag_Id, GLT.TG_Table_Name,GLT.TG_Table_Desc_ColName,GWLTV.Custom_ColName 
       FROM GPM_Layout_Tag GLT INNER JOIN GPM_WT_Layout_Tag_Value GWLTV On GLT.Layout_Tag_Id=GWLTV.Layout_Tag_Id
       WHERE GWLTV.Layout_Id=@vLayout_Id


INSERT INTO @_vLayoutMetric_Table(Layout_Id,Metric_Id,Metric_TDC_Type_Id, Metric_Field_Id,Period_Id,Start_Date,End_Date, 
       Custom_ColName,Precision,Program_Id)
SELECT Layout_Id,Metric_Id,Metric_TDC_Type_Id, Metric_Field_Id,Period_Id,Start_Date,End_Date, 
       Custom_ColName,Precision,Program_Id FROM GPM_WT_Layout_Metrics_Value
       WHERE Layout_Id=@vLayout_Id

       SELECT * FROM @_vLayoutMetric_Table
       

OPEN Outer_Cursor
FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

SELECT * FROM @_vLayoutTag_Table


WHILE @@FETCH_STATUS = 0
       
BEGIN

PRINT @_vWT_Code_Cur

                           SELECT 
                                                  @_vPortfolio_Tag_Id=NULL,
                                                  @_vWT_Table_Name=NULL,
                                                  @_vWT_Table_FK_Col_Name=NULL,
                                                  @_vTG_Table_Name=NULL,
                                                  @_vTG_Table_PK_Col_Name= NULL,
                                                  @_vPortfolio_Tag_Value=NULL,
                                                  @_vdynSql=NULL,
                                                  @_vdynSqlWhere=NULL,
                                                  @_vdynSqlSelectField=NULL,
                                                  @_vdynSqlFrom=NULL

                                                

                                                --SELECT  @_vdynSqlSelectField = N'SELECT '+@_vWT_Table_Name_Cur+N'.* '

                                                
                                                --SELECT @_vdynSqlFrom=CASE WHEN @_vWT_Code_Cur='FI' AND @_vWT_Table_Name_Cur='GPM_WT_DMAIC' THEN
                                                --                                              ' FROM  GPM_WT_Project INNER JOIN GPM_WT_DMAIC ON GPM_WT_Project.WT_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_DMAIC.DMAIC_Number'
                                                --                                       WHEN @_vWT_Code_Cur='MDPO' AND @_vWT_Table_Name_Cur='GPM_WT_MDPO' THEN
                                                --                                              ' FROM  GPM_WT_Project INNER JOIN GPM_WT_MDPO ON GPM_WT_Project.WT_Id=GPM_WT_MDPO.MDPO_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_MDPO.MDPO_Number' END

                                                IF(@_vWT_Code_Cur='FI' AND @_vWT_Table_Name_Cur='GPM_WT_DMAIC')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_DMAIC ON GPM_WT_Project.WT_Id=GPM_WT_DMAIC.DMAIC_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_DMAIC.DMAIC_Number'

                                                       SELECT @_vdynSqlSelectField='SELECT GPM_WT_DMAIC.DMAIC_Number AS Project_Seq,GPM_WT_DMAIC.DMAIC_Name As Project_Name'
                                                END

                                                IF(@_vWT_Code_Cur='MDPO' AND @_vWT_Table_Name_Cur='GPM_WT_MDPO')
                                                BEGIN
                                                       SELECT @_vdynSqlFrom=' FROM  GPM_WT_Project INNER JOIN GPM_WT_MDPO ON GPM_WT_Project.WT_Id=GPM_WT_MDPO.MDPO_Id AND GPM_WT_Project.WT_Project_Number=GPM_WT_MDPO.MDPO_Number' 

                                                       SELECT @_vdynSqlSelectField='SELECT GPM_WT_MDPO.MDPO_Number AS Project_Seq,GPM_WT_MDPO.MDPO_Name As Project_Name'

                                                END
                                                ----PRINT @_vdynSqlFrom                                              
       
                                                INSERT INTO @_vTab_Dyn_SQL_Table (Portfolio_Tag_Id,WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value)
                                                SELECT B.Portfolio_Tag_Id, B.WT_Table_Name, B.WT_Table_FK_ColName, B.TG_Table_Name, B.TG_Table_PK_ColName,A.Portfolio_Tag_Value
                                                FROM GPM_WT_Portfolio_Tag_Value A 
                                                INNER JOIN GPM_Portfolio_Tag B On A.Portfolio_Tag_Id=B.Portfolio_Tag_Id
                                                WHERE a.Portfolio_Id=@vPortfolio_Id AND B.WT_Table_Name=@_vWT_Table_Name_Cur

                                                --SELECT * FROM @_vTab_Dyn_SQL_Table

                                                INSERT INTO @_vRegion_Table (Region_Code)
                                                SELECT Region_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id

                                                INSERT INTO @_vCountry_Table (Country_Code)
                                                SELECT Country_Code FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id

                                                INSERT INTO @_vLocation_Table (Location_Id)
                                                SELECT Location_ID FROM GPM_WT_Portfolio_DescendFrom WHERE Portfolio_Id=@vPortfolio_Id
												                                                

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region' 

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vRegion_Table (Region_Code)
                                                       SELECT TAB.Value FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vRegion_Table RT WHERE RT.Region_Code=TAB.Value)
                                                       
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)

                                                       ---SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name
                                                END

                                                --ELSE

                                                IF((SELECT COUNT(*) FROM @_vRegion_Table)>0)
                                                BEGIN
                                                SELECT
                                                              @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
                                                              @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
                                                              @_vTG_Table_Name=GPT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
                                                FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Region'

                                                INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
                                                
                                                SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name
                                                END

                                                
                                                IF((SELECT COUNT(*) FROM @_vRegion_Table)>0 
                                                AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL') )
                                                BEGIN
                                                              SET @_vRegionList= (SELECT  ','+''''+ Region_Code+'''' FROM @_vRegion_Table FOR XML PATH(''))
                                                              SET @_vRegionList= SUBSTRING(@_vRegionList,2, LEN(@_vRegionList))
                                                              SELECT @_vdynSqlWhere =' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vRegionList+')'

                                                              PRINT 'Yes ALL'
                                                END
                                                

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vCountry_Table (Country_Code)
                                                       SELECT TAB.Value FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vCountry_Table CT WHERE CT.Country_Code=TAB.Value)
                                                
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                       
                                                       --SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

                                                       
                                                END

                                                --ELSE
                                                IF((SELECT COUNT(*) FROM @_vCountry_Table)>0)
                                                BEGIN
                                                SELECT
                                                              @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
                                                              @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
                                                              @_vTG_Table_Name=GPT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
                                                FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Country'

                                                INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)

                                                SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

                                                END



                                                IF((SELECT COUNT(*) FROM @_vCountry_Table)>0 
                                                AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL')
                                                AND  NOT EXISTS(SELECT 1 FROM @_vCountry_Table WHERE Country_Code='ALL')
                                                )
                                                BEGIN
                                                              SET @_vCountryList= (SELECT  ','+''''+ Country_Code+'''' FROM @_vCountry_Table FOR XML PATH(''))
                                                              SET @_vCountryList= SUBSTRING(@_vCountryList,2, LEN(@_vCountryList))
                                                              IF (LEN(@_vdynSqlWhere)>0)
                                                                     SELECT @_vdynSqlWhere += ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'
                                                              ELSE
                                                                     SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vCountryList+')'

                                                END

                                                SELECT
                                                              @_vPortfolio_Tag_Id= TDT.Portfolio_Tag_Id,
                                                              @_vPortfolio_Tag_Value=TDT.Portfolio_Tag_Value ,
                                                              @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                              @_vTG_Table_Name=TDT.TG_Table_Name,
                                                              @_vTG_Table_PK_Col_Name=TDT.TG_Table_PK_Col_Name                                                              
                                                FROM @_vTab_Dyn_SQL_Table TDT INNER JOIN GPM_Portfolio_Tag GPT ON TDT.Portfolio_Tag_Id=GPT.Portfolio_Tag_Id
                                                WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

                                                IF(LEN(LTRIM(RTRIM(@_vPortfolio_Tag_Value))))>0
                                                BEGIN
                                                       
                                                       INSERT INTO @_vLocation_Table (Location_Id)
                                                       SELECT TAB.Value FROM Fn_SplitDelimetedData(',',@_vPortfolio_Tag_Value) TAB
                                                       WHERE NOT EXISTS (SELECT 1 FROM @_vLocation_Table LT WHERE LT.Location_Id=TAB.Value)
													   
                                                       INSERT INTO @_vProcessedTag(Portfolio_Tag_Id) VALUES(@_vPortfolio_Tag_Id)
                                                       
                                                       --SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name

                                                END
                                                --ELSE
                                                IF((SELECT COUNT(*) FROM @_vLocation_Table)>0 AND NOT EXISTS(SELECT 1 FROM @_vLocation_Table WHERE Location_Id='ALL'))
                                                BEGIN
                                                SELECT
                                                              @_vPortfolio_Tag_Id= GPT.Portfolio_Tag_Id,
                                                              @_vWT_Table_FK_Col_Name=GPT.WT_Table_FK_ColName,
                                                              @_vTG_Table_Name=GPT.TG_Table_Name,
                                                             @_vTG_Table_PK_Col_Name=GPT.TG_Table_PK_ColName                                                        
                                                FROM GPM_Portfolio_Tag GPT WHERE GPT.WT_Code=@_vWT_Code_Cur AND GPT.TG_TABLE_NAME='GPM_Location'

                                                INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)
												
                                                SELECT @_vdynSqlFrom += ' LEFT OUTER JOIN '+@_vTG_Table_Name + ' ON '+@_vWT_Table_Name_Cur +'.'+@_vWT_Table_FK_Col_Name +'='+@_vTG_Table_Name+'.'+@_vTG_Table_PK_Col_Name
                                                END
												
                                                IF((SELECT COUNT(*) FROM @_vLocation_Table)>0
                                                AND NOT EXISTS(SELECT 1 FROM @_vRegion_Table WHERE Region_Code='ALL')
                                                AND  NOT EXISTS(SELECT 1 FROM @_vCountry_Table WHERE Country_Code='ALL')
                                                AND  NOT EXISTS(SELECT 1 FROM @_vLocation_Table WHERE Location_Id='ALL')
                                                )
                                                BEGIN
                                                              SET @_vLocationList= (SELECT  ','+ Location_Id FROM @_vLocation_Table FOR XML PATH(''))
                                                              SET @_vLocationList= SUBSTRING(@_vLocationList,2, LEN(@_vLocationList))
															  --SELECT * from @_vLocation_Table
                                                              IF (LEN(@_vdynSqlWhere)>0)
                                                                     SELECT @_vdynSqlWhere += ' AND '+@_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
                                                              ELSE
                                                                     SELECT @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name_Cur+'.'+@_vWT_Table_FK_Col_Name + ' IN ('+@_vLocationList+')'
                                                END

													--SELECT @_vdynSqlWhere

                                                --PRINT @_vdynSqlFrom
                                                --PRINT @_vdynSqlWhere

                                  IF((SELECT COUNT(*) FROM @_vTab_Dyn_SQL_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vTab_Dyn_SQL_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=NULL,
                                                       @_vWT_Table_Name=NULL,
                                                       @_vWT_Table_FK_Col_Name=NULL,
                                                       @_vTG_Table_Name=NULL,
                                                       @_vTG_Table_PK_Col_Name= NULL,
                                                       @_vPortfolio_Tag_Value=NULL

                                                SELECT 
                                                       @_vPortfolio_Tag_Id=Portfolio_Tag_Id,
                                                       @_vWT_Table_Name=WT_Table_Name,
                                                       @_vWT_Table_FK_Col_Name=WT_Table_FK_Col_Name,
                                                       @_vTG_Table_Name=TG_Table_Name,
                                                       @_vTG_Table_PK_Col_Name=TG_Table_PK_Col_Name,
                                                       @_vPortfolio_Tag_Value=Portfolio_Tag_Value
                                                FROM @_vTab_Dyn_SQL_Table WHERE Row_ID=@_vCnt

                                                print 'ABC '+cast(@_vPortfolio_Tag_Id as varchAR(10)) +' ,'+ cast(@_vCnt as varchar(10)) +' '+CAST(@_vMaxCnt AS VARCHAR(10))

                                                IF NOT EXISTS(SELECT 1 FROM @_vProcessedTag PT WHERE PT.Portfolio_Tag_Id=@_vPortfolio_Tag_Id)
                                                       BEGIN

                                                                     INSERT INTO @_vProcessedWTndTag_Table (WT_Code,TG_Table_Name) VALUES(@_vWT_Code_Cur,@_vTG_Table_Name)

                                                                     SET @_vdynSqlFrom += N' LEFT OUTER JOIN '+ @_vTG_Table_Name +N' ON '+@_vWT_Table_Name+N'.'+@_vWT_Table_FK_Col_Name+N' = '+@_vTG_Table_Name+N'.'+@_vTG_Table_PK_Col_Name;

                                                                     IF(@_vdynSqlWhere IS NULL OR @_vdynSqlWhere='')
                                                                           SET @_vdynSqlWhere = ' WHERE '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
                                                                     ELSE
                                                                           SET @_vdynSqlWhere +=' AND '+ @_vWT_Table_Name +'.'+ @_vWT_Table_FK_Col_Name + ' IN ('+@_vPortfolio_Tag_Value+')'
                                                                     
                                                       END

                                                SELECT @_vCnt=MIN(Row_Id) FROM @_vTab_Dyn_SQL_Table WHERE Row_ID>@_vCnt
                                                       
                                         END
                                  END


                                  
                                  IF((SELECT COUNT(*) FROM @_vLayoutTag_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vLayoutTag_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT  @_vLayoutTag_Id = LayoutTag_Id,
                                                              @_vLayout_TG_Table_Name = TG_Table_Name,
                                                              @_vLayout_vTG_Table_Desc_ColName = TG_Table_Desc_ColName,
                                                              @_vLayout_vCustom_ColName = Custom_ColName
                                                FROM @_vLayoutTag_Table WHERE Row_Id=@_vCnt

                                                print @_vLayoutTag_Id
                                                print @_vLayout_TG_Table_Name
                                                

                                                IF EXISTS(SELECT 1 FROM @_vProcessedWTndTag_Table PTG WHERE PTG.TG_Table_Name=@_vLayout_TG_Table_Name)
                                                                     SELECT @_vdynSqlSelectField += ','+ @_vLayout_TG_Table_Name +'.'+@_vLayout_vTG_Table_Desc_ColName +' AS '+ @_vLayout_vCustom_ColName
                                                              
                                                ELSE
                                                                     SELECT @_vdynSqlSelectField += ','+ ' NULL AS ['+ @_vLayout_vCustom_ColName+']'
                                                                     
                                                              
                                                
                                                       SELECT @_vCnt=MIN(Row_Id) FROM @_vLayoutTag_Table WHERE Row_ID>@_vCnt
                                                

                                         END

                                  END


                                  

                                  SELECT @_vTDCstartDate = '2017-01-01',@_vTDCendDate = '2018-01-01'

                                  
                                  ;WITH CTE AS
                                  (
                                                SELECT CONVERT(DATE, @_vTDCstartDate) AS Dates
                                                UNION ALL
                                                SELECT DATEADD(MONTH, 1, Dates)
                                                FROM CTE
                                                WHERE CONVERT(DATE, Dates) <= CONVERT(DATE, @_vTDCendDate)
                                  )                    
                                  INSERT @_vLayoutMetricPeriod_Table(TDCDate)
                                  --SELECT CAST(Convert(VARCHAR(6),Dates,112) AS INT) AS YearMonth, Convert(VARCHAR(4),Dates,112) +'-'+ FORMAT(Dates,'MMMM') As MetColName 
                                  SELECT Dates FROM CTE
                                  ORDER BY Dates

                                  SELECT * FROM @_vLayoutMetricPeriod_Table
                                  

                                  IF((SELECT COUNT(*) FROM @_vLayoutMetric_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vLayoutMetric_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT  
                                                       @_vLayout_Id = Layout_Id,
                                                       @_vMetric_Id = Metric_Id,
                                                       @_vMetric_TDC_Type_Id = Metric_TDC_Type_Id,
                                                       @_vMetric_Field_Id = Metric_Field_Id,
                                                       @_vPeriod_Id = Period_Id,
                                                       @_vStart_Date = Start_Date,
                                                       @_vEnd_Date = End_Date,
                                                       @_vCustom_ColName = Custom_ColName,
                                                       @_vPrecision = Precision,
                                                       @_vProgram_Id = Program_Id
                                                FROM @_vLayoutMetric_Table WHERE Row_Id=@_vCnt
                                                
                                                
                                                
                                                SELECT @_vTDCMinDate=MIN(TDCDate), @_vTDCMaxDate= MAX(TDCDate) FROM @_vLayoutMetricPeriod_Table

                                                       WHILE(@_vTDCMinDate<DATEADD(DAY,1,@_vTDCMaxDate))
                                                              BEGIN
                                                                     
                                                                     SELECT @_vdynSqlSelectField += ','+ ' (SELECT Attrib_Value FROM GPM_WT_Project_TDC_Saving 
                                                                                  WHERE GPM_WT_Project_TDC_Saving.WT_Project_ID=16 AND 
                                                                                  GPM_WT_Project_TDC_Saving.Attrib_Id='+CAST(@_vMetric_Field_Id AS VARCHAR(10)) +' 
                                                                                  AND YearMonth='+CONVERT(VARCHAR(6),@_vTDCMinDate,112)+') AS '''+ Convert(VARCHAR(4),@_vTDCMinDate,112) +'-'+ FORMAT(@_vTDCMinDate,'MMMM')+''''

                                                              
                                                                     SELECT @_vTDCMinDate=MIN(TDCDate) FROM @_vLayoutMetricPeriod_Table WHERE TDCDate>@_vTDCMinDate
                                                              END



                                                SELECT @_vCnt=MIN(Row_Id) FROM @_vLayoutMetric_Table WHERE Row_ID>@_vCnt
                                                END
                                         END
                     



                     
                     SELECT @_vdynSql=ISNULL(@_vdynSqlSelectField,'')+@_vdynSqlFrom+@_vdynSqlWhere

                     INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere) 
                      VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere)

                     IF (LEN(@_vdynSql)>1)
                           Print @_vdynSql
                                         
                                  
                     FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

                     DELETE FROM @_vTab_Dyn_SQL_Table

                     DELETE FROM @_vProcessedWTndTag_Table

                     

                     --SELECT * FROM @_vTab_WTLocation_Table
                     --SELECT * FROM @_vTab_CDLocation_Table
                     --Execute(@_dynSql)
END
CLOSE Outer_Cursor;
DEALLOCATE Outer_Cursor;
IF CURSOR_STATUS('global','Outer_Cursor')>=-1
BEGIN
       DEALLOCATE Outer_Cursor
END
                     
SELECT * FROm @_vProcessedWTndTag_Table


SELECT * FROM @_vWTQueriesTab
SET @_vdynSqlFinalQuery = (SELECT SelectField+' '+SelectFrom FROM @_vWTQueriesTab)

EXECUTE(@_vdynSqlFinalQuery)


/*


       INSERT INTO @_vLayoutTag_Table(LayoutTag_Id,TG_Table_Name,TG_Table_Desc_ColName,Custom_ColName)
       SELECT GWLTV.Layout_Tag_Id, GLT.TG_Table_Name,GLT.TG_Table_Desc_ColName,GWLTV.Custom_ColName 
       FROM GPM_Layout_Tag GLT INNER JOIN GPM_WT_Layout_Tag_Value GWLTV On GLT.Layout_Tag_Id=GWLTV.Layout_Tag_Id
       WHERE GWLTV.Layout_Id=@vLayout_Id


DECLARE Outer_Cursor CURSOR FOR
       SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN(SELECT Value FROM Fn_SplitDelimetedData(',',@_vWT_Codes_Cur))

       
       OPEN Outer_Cursor
                     FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur
                     

                     WHILE @@FETCH_STATUS = 0
       
                           BEGIN

                                  PRINT @_vWT_Code_Cur



                                  IF((SELECT COUNT(*) FROM @_vLayoutTag_Table)>0)
                                         BEGIN
                                  
                                                SELECT @_vCnt=MIN(Row_ID), @_vMaxCnt= MAX(Row_ID) FROM @_vLayoutTag_Table

                                                WHILE(@_vCnt<@_vMaxCnt+1)
                                                BEGIN

                                                SELECT  @_vLayoutTag_Id = LayoutTag_Id,
                                                              @_vLayout_TG_Table_Name = TG_Table_Name,
                                                              @_vLayout_vTG_Table_Desc_ColName = TG_Table_Desc_ColName,
                                                              @_vLayout_vCustom_ColName = Custom_ColName
                                                FROM @_vLayoutTag_Table WHERE Row_Id=@_vCnt


                                                --IF(LEN(@_vdynSqlSelectField)>0)
                                                --            SELECT @_vdynSqlSelectField += 
                                                
                                                       SELECT @_vCnt=MIN(Row_Id) FROM @_vLayoutTag_Table WHERE Row_ID>@_vCnt
                                                END
                                  END

                           FETCH NEXT FROM Outer_Cursor INTO @_vWT_Code_Cur, @_vWT_Table_Name_Cur

                     INSERT INTO @_vWTQueriesTab(WT_Code, SelectField,SelectFrom,SelectWhere) 
                      VALUES(@_vWT_Code_Cur, @_vdynSqlSelectField,@_vdynSqlFrom,@_vdynSqlWhere)

                     
END
CLOSE Outer_Cursor;
DEALLOCATE Outer_Cursor;
IF CURSOR_STATUS('global','Outer_Cursor')>=-1
BEGIN
       DEALLOCATE Outer_Cursor
END
*/
