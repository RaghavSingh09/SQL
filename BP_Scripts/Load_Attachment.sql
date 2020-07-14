DECLARE @vAttchmentValues NVARCHAR(MAX)
DECLARE add_attach_cur CURSOR FOR     
SELECT Attach_Info FROM TEMP_ATTACH 
--WHERE SUBSTRING(Attach_Info,0,12)='PSIMP-00811'
OPEN add_attach_cur    
  
FETCH NEXT FROM add_attach_cur INTO @vAttchmentValues
  
	WHILE @@FETCH_STATUS = 0    
	BEGIN    
		
		INSERT INTO Temp_GPM_Attachment
		SELECT
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 1, '^') AS Project_Number,
		  (SELECT SUBSTRING(@vAttchmentValues,1,LEN(@vAttchmentValues)-CHARINDEX('^',REVERSE(@vAttchmentValues)))) AS Attach_Name,
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 3, '^') AS Attach_Status,
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 4, '^') AS Attach_Desc,
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 5, '^') AS Attach_Size_Byte,
		  CAST(SUBSTRING(dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 6, '^'),0,11) AS DATETIME) AS Attach_Date,
		  dbo.UFN_SEPARATES_COLUMNS(@vAttchmentValues, 7, '^') AS Attach_Size_KB
      
		FETCH NEXT FROM add_attach_cur INTO @vAttchmentValues
   
	END     
CLOSE add_attach_cur;    
DEALLOCATE add_attach_cur;

GO
/* Insert Data to Main Attachment Table */
/*
INSERT INTO GPM_WT_Project_Attachment(WT_Project_Id,Attachment_Name,Description,Createda_Date,Attachment_Size)
SELECT 
GWP.WT_Project_ID,
TGA.Attach_Name,
TGA.Attach_Desc,
TGA.Attach_Date,
TGA.Attach_Size_KB
FROM Temp_GPM_Attachment TGA INNER JOIN GPM_WT_Project GWP On TGA.Project_Number = GWP.WT_Project_Number
--WHERE GWP.WT_Project_ID NOT IN(SELECT WT_Project_Id FROM GPM_WT_Project_Attachment)
--WHERE TGA.Project_Number+'^'+TGA.Attach_Name+'^'+TGA.Attach_Status+'^'+TGA.Attach_Desc NOT IN(SELECT Attach_Name FROM GPM_WT_Project_Attachment GWPA WHERE GWPA.WT_Project_Id=GWP.WT_Project_ID)
*/

/* Delete Duplicate Attachment */
/*
 WITH CTE AS(
   SELECT WT_Project_Id,Attachment_Name,Description,Createda_Date,Attachment_Size,
       RN = ROW_NUMBER()OVER(PARTITION BY WT_Project_Id,Attachment_Name,Description,Createda_Date,Attachment_Size ORDER BY WT_Project_Id)--,Attachment_Name,Description,Createda_Date,Attachment_Size)
   FROM dbo.GPM_WT_Project_Attachment
)
DELETE FROM CTE WHERE RN > 1
*/