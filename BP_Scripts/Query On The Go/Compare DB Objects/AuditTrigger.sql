USE [TEST]
GO
/****** Object:  Trigger [dbo].[trg_Emp_Audit]    Script Date: 12/12/2019 1:44:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[trg_Emp_Audit] ON [dbo].[Employee]
AFTER INSERT, UPDATE, DELETE
AS BEGIN

DECLARE  @Emp_Id INT,@Emp_Name VARCHAR(500),@Emp_Address VARCHAR(500)

--DECLARE @vColNameTab AS TABLE(Column_Id INT,Column_Name VARCHAR(100))

-- Get data from inserted/ updated
SELECT @Emp_Id= Emp_Id,
@Emp_Name = Emp_Name,
@Emp_Address = Emp_Address
FROM inserted

-- Get data from deleted
SELECT @Emp_Id= Emp_Id,
@Emp_Name = Emp_Name,
@Emp_Address = Emp_Address    
FROM deleted
	/*
	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) 
    BEGIN
        INSERT INTO Emp_Audit(Emp_Id, Emp_Name, Emp_Address, Action_Type,Audit_Comments,Audit_Date)
        VALUES(@Emp_Id, @Emp_Name, @Emp_Address, 'Insert','',GETDATE())
    END

	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
		INSERT INTO Emp_Audit(Emp_Id, Emp_Name, Emp_Address, Action_Type,Audit_Comments,Audit_Date)
        VALUES(@Emp_Id, @Emp_Name, @Emp_Address, 'Update','',GETDATE())
	END

	IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Emp_Audit(Emp_Id, Emp_Name, Emp_Address, Action_Type,Audit_Comments,Audit_Date)
        VALUES(@Emp_Id, @Emp_Name, @Emp_Address, 'Delete','This entry has been',GETDATE())
	END

	SELECT * FROM @vColNameTab
	*/

	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
	
	DECLARE @_vDyn NVARCHAR(MAX)=NULL
	DECLARE @_vAuditComment VARCHAR(MAX)=''
	/*
	SET @_vDyn = 'INSERT INTO Emp_Audit(Emp_Id, Emp_Name, Emp_Address, Action_Type,Audit_Comments,Audit_Date)
        VALUES('''+CAST(@Emp_Id AS VARCHAR)+''', '''+@Emp_Name+''', '''+@Emp_Address+''', ''Insert'','''',GETDATE())'
	EXEC(@_vDyn)
	*/
	DECLARE @_vCol_Id INT, @_vCol_Name VARCHAR(100)
	DECLARE curr_audit_check CURSOR FOR
		SELECT SC.column_id,SC.name FROM sys.tables ST INNER JOIN sys.columns SC On ST.object_id = SC.object_id WHERE ST.name = 'Employee'
	OPEN curr_audit_check    
  
	DECLARE @_vOldValue VARCHAR(500)=''
	DECLARE @_vNewValue VARCHAR(500)=''

	SELECT * INTO #inserted FROM inserted
	SELECT * INTO #deleted FROM deleted
	FETCH NEXT FROM curr_audit_check INTO @_vCol_Id,@_vCol_Name
  
		WHILE @@FETCH_STATUS = 0    
		BEGIN 
			SELECT @_vOldValue='',@_vNewValue='',@_vDyn=''

			SET @_vDyn='SELECT @_vNewValue='+@_vCol_Name+' FROM #inserted'
			EXECUTE SP_EXECUTESQL @_vDyn, N'@_vNewValue VARCHAR(500) OUTPUT',@_vNewValue OUTPUT

			SET @_vDyn='SELECT @_vOldValue='+@_vCol_Name+' FROM #deleted'
			EXECUTE SP_EXECUTESQL @_vDyn, N'@_vOldValue VARCHAR(500) OUTPUT',@_vOldValue OUTPUT

			IF(@_vNewValue != @_vOldValue)
				SELECT @_vAuditComment +=', Value of column: '+@_vCol_Name+' has changed from old value: '+@_vOldValue+' to new value : '+@_vNewValue
			
			FETCH NEXT FROM curr_audit_check INTO @_vCol_Id,@_vCol_Name
		END
	
	CLOSE curr_audit_check;    
	DEALLOCATE curr_audit_check;
	IF(LEN(@_vAuditComment)>0)
				INSERT INTO Emp_Audit(Emp_Id, Emp_Name, Emp_Address, Action_Type,Audit_Comments,Audit_Date)
				VALUES(@Emp_Id, @Emp_Name, @Emp_Address, 'Update',SUBSTRING(@_vAuditComment,2,LEN(@_vAuditComment)),GETDATE())
	END
END