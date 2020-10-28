
GO
ALTER PROC [dbo].[sp_CompareDb]
(
	@SourceDB SYSNAME,
	@TargetDb SYSNAME
)
AS
BEGIN
/*
	DECLARE @SourceDB SYSNAME='DB1',@TargetDb SYSNAME='DB2'
*/
	SET NOCOUNT ON;
	SET ANSI_WARNINGS ON;
	SET ANSI_NULLS ON;   

	DECLARE @sqlStr VARCHAR(8000)
	SET @SourceDB = RTRIM(LTRIM(@SourceDB))
	IF DB_ID(@SourceDB) IS NULL 
	BEGIN
		PRINT 'Error: Unable to find the database '+ @SourceDB +'!!!'
		RETURN
	END

	SET @TargetDb = RTRIM(LTRIM(@TargetDb))
	IF DB_ID(@SourceDB) IS NULL 
	BEGIN
		PRINT 'Error: Unable to find the database '+ @TargetDb +'!!!'
		RETURN
	END
	
	PRINT Replicate('-', Len(@SourceDB) + Len(@TargetDb) + 25); 
	PRINT 'Comparing databases ' + @SourceDB + ' and ' + @TargetDb; 
	PRINT Replicate('-', Len(@SourceDB) + Len(@TargetDb) + 25);
     
	----------------------------------------------------------------------------------------- 
	-- Create temp tables needed to hold the db structure 
	----------------------------------------------------------------------------------------- 	
	
	IF OBJECT_ID('TEMPDB..#TABLIST_SOURCE')IS NOT NULL
		DROP TABLE #TABLIST_SOURCE;
	IF OBJECT_ID('TEMPDB..#TABLIST_TARGET') IS NOT NULL
		DROP TABLE #TABLIST_TARGET;
	IF OBJECT_ID('TEMPDB..#SpVwFn_SOURCE') IS NOT NULL
		DROP TABLE #SpVwFn_SOURCE
	IF OBJECT_ID('TEMPDB..#SpVwFn_TARGET') IS NOT NULL
		DROP TABLE #SpVwFn_TARGET
	IF OBJECT_ID('TEMPDB..#TAB_RESULTS') IS NOT NULL
		DROP TABLE #TAB_RESULTS
	IF OBJECT_ID('TEMPDB..#SpVwFn_RESULTS') IS NOT NULL
		DROP TABLE #SpVwFn_RESULTS

	CREATE TABLE #TABLIST_SOURCE
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15)
	);

	CREATE TABLE #TABLIST_TARGET
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15)
	);
	
	CREATE TABLE #TAB_RESULTS (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15),
		REASON VARCHAR(150)
	);

	CREATE TABLE #SpVwFn_SOURCE
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		ObjectNAME SYSNAME,
		ObjectType VARCHAR(50),
		ObjectTextLen INT
	);

	CREATE TABLE #SpVwFn_TARGET
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		ObjectNAME SYSNAME,
		ObjectType VARCHAR(50),
		ObjectTextLen INT
	);

	CREATE TABLE #SpVwFn_RESULTS
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		ObjectNAME SYSNAME,
		ObjectType VARCHAR(50),
		ObjectTextLen INT,
		REASON VARCHAR(150)
	);

	PRINT 'Getting table and column list!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	--BEGIN
	INSERT INTO #TABLIST_SOURCE (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE)
	EXEC ('SELECT ''' + @SourceDB + ''', T.TABLE_NAME TABLENAME, 
				 C.COLUMN_NAME COLUMNNAME,
				 TY.name + case when TY.name IN (''char'',''varchar'',''nvarchar'') THEN	
					''(''+CASE WHEN C.CHARACTER_MAXIMUM_LENGTH>0 THEN CAST(C.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) ELSE ''max''END+'')''
					ELSE	
						''''
					END
					DATATYPE,
					CASE WHEN C.is_nullable=''NO'' THEN	
						''NOT NULL'' 
						ELSE
						''NULL''
					END NULLABLE
						FROM ' + @SourceDB + '.INFORMATION_SCHEMA.TABLES T 
							INNER JOIN  ' + @SourceDB + '.INFORMATION_SCHEMA.COLUMNS C
								ON T.TABLE_NAME=C.TABLE_NAME
								and T.TABLE_CATALOG=C.TABLE_CATALOG
								and T.TABLE_SCHEMA=C.TABLE_SCHEMA
								and T.TABLE_TYPE = ''BASE TABLE''
							 INNER JOIN ' + @SourceDB + '.sys.types TY
							ON C.DATA_TYPE =TY.name		
							ORDER BY TABLENAME, COLUMNNAME,C.ORDINAL_POSITION');

	INSERT INTO #TABLIST_TARGET (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE)
	EXEC ('SELECT ''' + @TargetDB + ''', T.TABLE_NAME TABLENAME, 
				 C.COLUMN_NAME COLUMNNAME,
				 TY.name + case when TY.name IN (''char'',''varchar'',''nvarchar'') THEN	
					''(''+CASE WHEN C.CHARACTER_MAXIMUM_LENGTH>0 THEN CAST(C.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) ELSE ''max''END+'')''
					ELSE	
						''''
					END
					DATATYPE,
					CASE WHEN C.is_nullable=''NO'' THEN	
						''NOT NULL'' 
						ELSE
						''NULL''
					END NULLABLE
						FROM ' + @TargetDB + '.INFORMATION_SCHEMA.TABLES T 
							INNER JOIN  ' + @TargetDB + '.INFORMATION_SCHEMA.COLUMNS C
								ON T.TABLE_NAME=C.TABLE_NAME
								and T.TABLE_CATALOG=C.TABLE_CATALOG
								and T.TABLE_SCHEMA=C.TABLE_SCHEMA
								and T.TABLE_TYPE = ''BASE TABLE''
							 INNER JOIN ' + @TargetDB + '.sys.types TY
							ON C.DATA_TYPE =TY.name		
							ORDER BY TABLENAME, COLUMNNAME,C.ORDINAL_POSITION');

	/*SP Function and View Logic*/
	INSERT INTO #SpVwFn_SOURCE
	EXEC(
	'SELECT ''' + @SourceDB + ''', A.NAME, A.TYPE_DESC, SUM(LEN(RTRIM(LTRIM(B.text)))) FROM ' + @SourceDB + '.SYS.OBJECTS A
	INNER JOIN ' + @SourceDB + '.SYS.SYSCOMMENTS B On A.OBJECT_ID=B.ID
	WHERE A.TYPE IN(''P'',''V'',''FN'')
	GROUP BY A.NAME,B.ID,A.TYPE_DESC'
	)

	INSERT INTO #SpVwFn_TARGET
	EXEC(
	'SELECT ''' + @TargetDB + ''', A.NAME, A.TYPE_DESC, SUM(LEN(RTRIM(LTRIM(B.text)))) FROM ' + @TargetDB + '.SYS.OBJECTS A
	INNER JOIN ' + @TargetDB + '.SYS.SYSCOMMENTS B On A.OBJECT_ID=B.ID
	WHERE TYPE IN(''P'',''V'',''FN'')
	GROUP BY A.NAME,B.ID,A.TYPE_DESC'
	)

	INSERT INTO #SpVwFn_RESULTS
	SELECT @TargetDb,Tab1.ObjectNAME,Tab1.ObjectType,Tab1.ObjectTextLen,'Missing or Object Def didn''t Match' FROM
	(
	SELECT ObjectNAME, ObjectType, ObjectTextLen FROM #SpVwFn_SOURCE
	EXCEPT
	SELECT ObjectNAME, ObjectType, ObjectTextLen FROM #SpVwFn_TARGET
	) Tab1
	UNION ALL
	SELECT @SourceDB,Tab1.ObjectNAME,Tab1.ObjectType,Tab1.ObjectTextLen,'Missing or Object Def didn''t Match' FROM
	(
	SELECT ObjectNAME, ObjectType, ObjectTextLen FROM #SpVwFn_TARGET
	EXCEPT
	SELECT ObjectNAME, ObjectType, ObjectTextLen FROM #SpVwFn_SOURCE
	) Tab1


	PRINT 'Print column mismatches!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	INSERT INTO #TAB_RESULTS (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE, REASON)
		SELECT
			@TargetDb AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE
			EXCEPT
			SELECT
				TS.TABLENAME,
				TS.COLUMNNAME,
				TS.DATATYPE,
				TS.NULLABLE
			FROM #TABLIST_SOURCE TS
			INNER JOIN #TABLIST_TARGET TT
				ON TS.TABLENAME = TT.TABLENAME
				AND TS.COLUMNNAME = TT.COLUMNNAME) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Missing Column' AS Reason) Tab2
		UNION ALL
		SELECT
			@SourceDB AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET
			EXCEPT
			SELECT
				TT.TABLENAME,
				TT.COLUMNNAME,
				TT.DATATYPE,
				TT.NULLABLE
			FROM #TABLIST_TARGET TT
			INNER JOIN #TABLIST_SOURCE TS
				ON TS.TABLENAME = TT.TABLENAME
				AND TS.COLUMNNAME = TT.COLUMNNAME) TAB_MATCH
		CROSS JOIN (SELECT
				'Missing column ' AS Reason) Tab2
	
	
	--NON MATCHING COLUMNS
	INSERT INTO #TAB_RESULTS (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TS.TABLENAME,
					TS.COLUMNNAME,
					TS.DATATYPE,
					TS.NULLABLE
				FROM #TABLIST_SOURCE TS
				INNER JOIN #TABLIST_TARGET TT
					ON TS.TABLENAME = TT.TABLENAME
					AND TS.COLUMNNAME = TT.COLUMNNAME) T
			EXCEPT
			(SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE
			INTERSECT
			SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET)) TT1
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) t

		UNION ALL

		SELECT
			@TargetDb AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TT.TABLENAME,
					TT.COLUMNNAME,
					TT.DATATYPE,
					TT.NULLABLE
				FROM #TABLIST_TARGET TT
				INNER JOIN #TABLIST_SOURCE TS
					ON TS.TABLENAME = TT.TABLENAME
					AND TS.COLUMNNAME = TT.COLUMNNAME) T
			EXCEPT
			(SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET
			INTERSECT
			SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE)) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) T;

	
	--Print Final Results	
	DECLARE @vObjectCountTab AS TABLE (DB_Name SYSNAME, Object_Count INT, Object_Type VARCHAR(50))

	INSERT INTO @vObjectCountTab
	SELECT DATABASENAME,COUNT(*) AS Object_Count,ObjectType FROM #SpVwFn_SOURCE GROUP BY DATABASENAME,ObjectType
	UNION ALL
	SELECT DATABASENAME,COUNT(*) AS Object_Count,ObjectType FROM #SpVwFn_TARGET GROUP BY DATABASENAME,ObjectType
	/*
	UNION ALL
	SELECT TOP 1 DATABASENAME, 
	(SELECT COUNT(TS.TABLENAME) FROM (SELECT DISTINCT TABLENAME FROM #TABLIST_SOURCE) TS) AS Object_Count,'TABLE' AS ObjectType FROM #TABLIST_SOURCE
	UNION ALL
	SELECT TOP 1 DATABASENAME, 
	(SELECT COUNT(TT.TABLENAME) FROM (SELECT DISTINCT TABLENAME FROM #TABLIST_TARGET) TT) AS Object_Count,'TABLE' AS ObjectType FROM #TABLIST_TARGET
	*/
	
	INSERT INTO @vObjectCountTab
	EXEC('SELECT '''+@SourceDB+''', COUNT(*) AS Object_Count,''TABLE'' FROM '+@SourceDB+'.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''BASE TABLE''')
	
	INSERT INTO @vObjectCountTab
	EXEC('SELECT '''+@TargetDB+''', COUNT(*) AS Object_Count,''TABLE'' FROM '+@TargetDB+'.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''BASE TABLE''')
	
	SELECT DB_Name,Object_Type,Object_Count FROM @vObjectCountTab Order BY Object_Type,DB_Name
	SELECT * FROM #SpVwFn_RESULTS ORDER BY ObjectNAME
	SELECT * FROM #TAB_RESULTS

END
GO