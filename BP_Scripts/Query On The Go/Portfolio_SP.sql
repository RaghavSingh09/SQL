USE [PMT]
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetPortfolioDetails_ByPFId_Test]    Script Date: 2/1/2019 12:44:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_GetPortfolioDetails_ByPFId_Test]
@vPortfolio_Id INT
AS
BEGIN

Declare @vRow_ID INT
Declare @vWT_Codes varchar(1000)
Declare @vWT_Code  varchar(10)
Declare @vWT_Table_Name varchar(100)
Declare @vWT_Table_Names varchar(100) 
Declare @vWT_Table_FK_Col_Name varchar(100) 
Declare @vTG_Table_Name varchar(100)
Declare @vTG_Table_PK_Col_Name varchar(100)
Declare @vPortfolio_Tag_Value varchar(8000)
DECLARE @dynSql nvarchar(Max) = ''
Declare @vDyn_SQL_Table TABLE (Row_ID INT IDENTITY(1,1), WT_Table_Name varchar(100), WT_Table_FK_Col_Name varchar(100), TG_Table_Name varchar(100), TG_Table_PK_Col_Name varchar(100), Portfolio_Tag_Value varchar(8000))

SELECT @vWT_Codes=WT_Codes FROM GPM_WT_Portfolio WHERE Portfolio_Id=@vPortfolio_Id

DECLARE Outer_Cursor CURSOR FOR
	SELECT WT_Code, WT_Table_Name FROM GPM_Project_Template_Table WHERE WT_Code IN(SELECT Value FROM Fn_SplitDelimetedData(',',@vWT_Codes))

OPEN Outer_Cursor
FETCH NEXT FROM Outer_Cursor INTO @vWT_Code, @vWT_Table_Name


WHILE @@FETCH_STATUS = 0
	
BEGIN

	SELECT  @dynSql = N'SELECT '+@vWT_Table_Name+N'.* from '+@vWT_Table_Name

	INSERT INTO @vDyn_SQL_Table (WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value)
	SELECT B.WT_Table_Name, B.WT_Table_FK_ColName, B.TG_Table_Name, B.TG_Table_PK_ColName,A.Portfolio_Tag_Value FROM GPM_WT_Portfolio_Tag_Value A 
	INNER JOIN GPM_Portfolio_Tag B On A.Portfolio_Tag_Id=B.Portfolio_Tag_Id
	WHERE B.WT_Table_Name=@vWT_Table_Name

	
	IF((SELECT COUNT(*) FROM @vDyn_SQL_Table)>0)
	BEGIN

			DECLARE Inner_cursor CURSOR FOR 
			SELECT WT_Table_Name,WT_Table_FK_Col_Name,TG_Table_Name,TG_Table_PK_Col_Name FROM @vDyn_SQL_Table
						
			OPEN Inner_cursor
			FETCH NEXT FROM Inner_Cursor INTO @vWT_Table_Names,@vWT_Table_FK_Col_Name,@vTG_Table_Name,@vTG_Table_PK_Col_Name

					WHILE @@FETCH_STATUS = 0
					BEGIN
				
						SET @dynSql += N' INNER JOIN '+ @vTG_Table_Name +N' ON '+@vWT_Table_Names+N'.'+@vWT_Table_FK_Col_Name+N' = '+@vTG_Table_Name+N'.'+@vTG_Table_PK_Col_Name;
						
						FETCH NEXT FROM Inner_cursor INTO @vWT_Table_Names,@vWT_Table_FK_Col_Name,@vTG_Table_Name,@vTG_Table_PK_Col_Name
						
					END

							DECLARE WC_Cursor CURSOR FOR
							SELECT Row_ID,TG_Table_Name,TG_Table_PK_Col_Name,Portfolio_Tag_Value FROM @vDyn_SQL_Table 
							OPEN WC_Cursor
							FETCH NEXT FROM WC_Cursor INTO @vRow_ID,@vTG_Table_Name,@vTG_Table_PK_Col_Name,@vPortfolio_Tag_Value
									WHILE @@FETCH_STATUS = 0
									BEGIN
										--SELECT * from @vDyn_SQL_Table
										DECLARE @_vRowCount INT
										SET @_vRowCount =(Select COUNT(*) FROM @vDyn_SQL_Table)
										IF(@_vRowCount>1)
											BEGIN
												IF(@vRow_ID=1)
												SET @dynSql += ' WHERE ' + @vTG_Table_Name+N'.'+@vTG_Table_PK_Col_Name + ' IN ('+@vPortfolio_Tag_Value+') AND '
												ELSE IF(@vRow_ID<@_vRowCount)
												SET @dynSql += ' ' + @vTG_Table_Name+N'.'+@vTG_Table_PK_Col_Name + ' IN ('+@vPortfolio_Tag_Value+') AND '
												ELSE
												SET @dynSql += ' ' + @vTG_Table_Name+N'.'+@vTG_Table_PK_Col_Name + ' IN ('+@vPortfolio_Tag_Value+')'
											END
										ELSE
										SET @dynSql += ' WHERE ' + @vTG_Table_Name+N'.'+@vTG_Table_PK_Col_Name + ' IN ('+@vPortfolio_Tag_Value+')'

										FETCH NEXT FROM WC_Cursor INTO @vRow_ID,@vTG_Table_Name,@vTG_Table_PK_Col_Name,@vPortfolio_Tag_Value
									END
							CLOSE WC_Cursor;
							DEALLOCATE WC_Cursor;
							IF CURSOR_STATUS('global','WC_Cursor')>=-1
							BEGIN
							 DEALLOCATE WC_Cursor
							END

			CLOSE Inner_cursor;
			DEALLOCATE Inner_cursor;
			IF CURSOR_STATUS('global','Inner_cursor')>=-1
			BEGIN
			 DEALLOCATE Inner_cursor
			END
		END
			
			FETCH NEXT FROM Outer_Cursor INTO @vWT_Code, @vWT_Table_Name

			DELETE FROM @vDyn_SQL_Table
			IF (LEN(@dynSql)>1)
			Print @dynSql
			Execute(@dynSql)
END
CLOSE Outer_Cursor;
DEALLOCATE Outer_Cursor;
IF CURSOR_STATUS('global','Outer_Cursor')>=-1
BEGIN
	DEALLOCATE Outer_Cursor
END
END 

