DECLARE @vWT_Project_Id INT
BEGIN
DECLARE @vdynInsert VARCHAR(MAX)
DECLARE @vDL_User_Id VARCHAR(10)
DECLARE @vGate_Id int
DECLARE @vDeliverable_Id int
DECLARE @_vCnt INT=0


DECLARE Deliverable_Team CURSOR LOCAL FOR 
		SELECT C.WT_Project_ID,D.Created_By FROM GPM_WT_Project_Team A 
		INNER JOIN GPM_Project_Template_Role B On A.WT_Role_ID=B.WT_Role_Id 
		INNER JOIN GPM_WT_Project C On C.WT_Project_ID = A.WT_Project_ID
		INNER JOIN GPM_WT_DMAIC D On D.DMAIC_Id = C.WT_Id
		where A.WT_Role_ID = 16 AND D.Is_Deleted_Ind = 'N' AND C.WT_Project_ID NOT IN(6539,6541)--D.Created_By = 'A398351' 

OPEN Deliverable_Team

FETCH NEXT FROM Deliverable_Team INTO @vWT_Project_Id, @vDL_User_Id

WHILE @@FETCH_STATUS = 0
	
	BEGIN
		SELECT @_vCnt=1, @vGate_Id=41,@vDeliverable_Id=26
		WHILE(@_vCnt<=4)
			BEGIN
				SET @vdynInsert='INSERT INTO GPM_WT_Project_Team_Deliverable(WT_Project_ID,WT_Role_ID,Gate_Id,Deliverable_Id,GD_User_Id,Is_Deleted_Ind)VALUES('+CAST(@vWT_Project_Id AS VARCHAR)+','+'68'+','+'41'+','+CAST(@vDeliverable_Id AS VARCHAR)+','''+@vDL_User_Id+''')'
				SET @_vCnt = @_vCnt+1
				SET @vDeliverable_Id = @vDeliverable_Id+1
				PRINT @vdynInsert --AS Insert_Query
			END
			SET @_vCnt=5
			SET @vDeliverable_Id=30
		WHILE(@_vCnt<=6)
			BEGIN
			SET @vdynInsert='INSERT INTO GPM_WT_Project_Team_Deliverable(WT_Project_ID,WT_Role_ID,Gate_Id,Deliverable_Id,GD_User_Id,Is_Deleted_Ind)VALUES('+CAST(@vWT_Project_Id AS VARCHAR)+','+'68'+','+'42'+','+CAST(@vDeliverable_Id AS VARCHAR)+','''+@vDL_User_Id+''')'
				SET @_vCnt = @_vCnt+1
				SET @vDeliverable_Id = @vDeliverable_Id+1
				PRINT @vdynInsert --AS Insert_Query
			END
			SET @_vCnt=7
			SET @vDeliverable_Id=32
		WHILE(@_vCnt<=8)
			BEGIN
			SET @vdynInsert='INSERT INTO GPM_WT_Project_Team_Deliverable(WT_Project_ID,WT_Role_ID,Gate_Id,Deliverable_Id,GD_User_Id,Is_Deleted_Ind)VALUES('+CAST(@vWT_Project_Id AS VARCHAR)+','+'68'+','+'43'+','+CAST(@vDeliverable_Id AS VARCHAR)+','''+@vDL_User_Id+''')'
				SET @_vCnt = @_vCnt+1
				SET @vDeliverable_Id = @vDeliverable_Id+1
				PRINT @vdynInsert --AS Insert_Query
			END
			SET @_vCnt=9
			SET @vDeliverable_Id=34
		WHILE(@_vCnt<=20) 
			BEGIN
			SET @vdynInsert='INSERT INTO GPM_WT_Project_Team_Deliverable(WT_Project_ID,WT_Role_ID,Gate_Id,Deliverable_Id,GD_User_Id,Is_Deleted_Ind)VALUES('+CAST(@vWT_Project_Id AS VARCHAR)+','+'68'+','+'44'+','+CAST(@vDeliverable_Id AS VARCHAR)+','''+@vDL_User_Id+''')'
				SET @_vCnt = @_vCnt+1
				SET @vDeliverable_Id = @vDeliverable_Id+1
				PRINT @vdynInsert --AS Insert_Query
			END
			
			FETCH NEXT FROM Deliverable_Team INTO @vWT_Project_Id, @vDL_User_Id
	END

		--Print @vdynInsert;
		--Execute(@@vdynInsert)
CLOSE Deliverable_Team;

DEALLOCATE Deliverable_Team; 
END