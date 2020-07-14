/*
UPDATE GU1 SET 
			GU1.User_First_Name=LTRIM(RTRIM(A.First_Name)),
				GU1.User_Last_Name=LTRIM(RTRIM(A.Last_Name)),
				GU1.Region_Code = R.Region_Code,
				GU1.Country_Code=C.Country_Code,
				GU1.Primary_Email=A.Email,
				GU1.Location_Id=L.Location_ID,
				GU1.BA_Id=b.BA_Id,
				GU1.Dept_Id=d.Dept_ID,
				GU1.Is_Deleted_Ind='N'			
FROM
Temp_GPM_Users A INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.Username)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Regions)) = LTRIM(RTRIM(R.Region_Code))
LEFT OUTER JOIN GPM_Country C on LTRIM(RTRIM(A.Country)) = LTRIM(RTRIM(C.Country_Name)) 
LEFT OUTER JOIN GPM_Location L on LTRIM(RTRIM(A.Location)) = LTRIM(RTRIM(L.Location_Name))
LEFT OUTER JOIN GPM_Business_Area B on LTRIM(RTRIM(A.[Business_Area])) = LTRIM(RTRIM(B.BA_Name))
LEFT OUTER JOIN GPM_Department D on LTRIM(RTRIM(A.Departments)) = LTRIM(RTRIM(D.Dept_Name)) and D.BA_Id = B.BA_Id


--INSERT INTO GPM_User(GD_User_Id,User_First_Name,User_Last_Name,Primary_Email,Region_Code,Country_Code,Location_Id,BA_Id,Dept_Id,Currency_Code,Is_Deleted_Ind)
SELECT A.Username,A.First_Name,A.Last_Name,A.Email,CAST(R.Region_Code AS VARCHAR(5)) AS Region_Code, CAST(C.Country_Code AS CHAR(3)) AS Country_Code, CAST(L.Location_Id AS INT) AS Location_Id,
       CAST(B.BA_Id AS INT) AS BA_Id, CAST(D.Dept_Id AS INT) AS Dept_Id, CAST(C.Currency_Code AS CHAR(3)) AS Currency_Code, 'N' AS Is_Deleted_Ind
FROM Temp_GPM_Users A --INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.Username)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Regions)) = LTRIM(RTRIM(R.Region_Code))
LEFT OUTER JOIN GPM_Country C on LTRIM(RTRIM(A.Country)) = LTRIM(RTRIM(C.Country_Name)) 
LEFT OUTER JOIN GPM_Location L on LTRIM(RTRIM(A.Location)) = LTRIM(RTRIM(L.Location_Name))
LEFT OUTER JOIN GPM_Business_Area B on LTRIM(RTRIM(A.[Business_Area])) = LTRIM(RTRIM(B.BA_Name))
LEFT OUTER JOIN GPM_Department D on LTRIM(RTRIM(A.Departments)) = LTRIM(RTRIM(D.Dept_Name)) and D.BA_Id = B.BA_Id
WHERE NOT EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE LTRIM(RTRIM(A.Username))=GU.GD_User_Id) AND LEN(A.Username)<=10

--INSERT INTO GPM_User(GD_User_Id,User_First_Name,User_Last_Name,Primary_Email,Region_Code,Country_Code,Location_Id,BA_Id,Dept_Id,Currency_Code,Is_Deleted_Ind,Is_Non_Access_User)
SELECT A.Username,SUBSTRING(A.Name,0,CHARINDEX(CHAR(32),A.Name,0)),SUBSTRING(A.Name,CHARINDEX(CHAR(32),A.Name,0)+1,LEN(A.Name)),
		NULL,CAST(R.Region_Code AS VARCHAR(5)) AS Region_Code, CAST(C.Country_Code AS CHAR(3)) AS Country_Code, CAST(L.Location_Id AS INT) AS Location_Id,
       CAST(B.BA_Id AS INT) AS BA_Id, CAST(D.Dept_Id AS INT) AS Dept_Id, CAST(C.Currency_Code AS CHAR(3)) AS Currency_Code, 'N' AS Is_Deleted_Ind,CASE WHEN Is_No_Access='false' THEN 'N' WHEN Is_No_Access='true' THEN 'Y' ELSE NULL END
FROM Temp_GPM_Users_NonAccess A --INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.Username)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Regions)) = LTRIM(RTRIM(R.Region_Code))
LEFT OUTER JOIN GPM_Country C on LTRIM(RTRIM(A.Country)) = LTRIM(RTRIM(C.Country_Name)) 
LEFT OUTER JOIN GPM_Location L on LTRIM(RTRIM(A.Location)) = LTRIM(RTRIM(L.Location_Name))
LEFT OUTER JOIN GPM_Business_Area B on LTRIM(RTRIM(A.[Business_Area])) = LTRIM(RTRIM(B.BA_Name))
LEFT OUTER JOIN GPM_Department D on LTRIM(RTRIM(A.Departments)) = LTRIM(RTRIM(D.Dept_Name)) and D.BA_Id = B.BA_Id
WHERE NOT EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE LTRIM(RTRIM(A.Username))=GU.GD_User_Id) AND LEN(A.Username)<=10  AND A.Username!=''


--SELECT Username FROM Temp_GPM_Users WHERE LEN(Username)>10
Select * from GPM_User
--Access, Super and Functional User Add
*/

UPDATE GU1 SET 
				GU1.User_First_Name=LTRIM(RTRIM(SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)))),
				GU1.User_Last_Name=LTRIM(RTRIM(SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)))),
				GU1.Primary_Email = A.Email_Address,
				GU1.Region_Code = R.Region_Code,
				GU1.Last_Modified_Date = GETDATE(),
				GU1.Is_Deleted_Ind='N'			
FROM
Temp_Access_Users A INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))

UPDATE GU1 SET 
				GU1.User_First_Name=LTRIM(RTRIM(SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)))),
				GU1.User_Last_Name=LTRIM(RTRIM(SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)))),
				GU1.Primary_Email = A.Email_Address,
				GU1.Region_Code = R.Region_Code,
				GU1.Last_Modified_Date = GETDATE(),
				GU1.Is_Deleted_Ind='N'			
FROM
Temp_Functional_Users A INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))

UPDATE GU1 SET 
				GU1.User_First_Name=LTRIM(RTRIM(SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)))),
				GU1.User_Last_Name=LTRIM(RTRIM(SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)))),
				GU1.Primary_Email = A.Email_Address,
				GU1.Region_Code = R.Region_Code,
				GU1.Last_Modified_Date = GETDATE(),
				GU1.Is_Deleted_Ind='N'			
FROM
Temp_Super_Users A INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))


--Insert New Users
INSERT INTO GPM_User(GD_User_Id,User_First_Name,User_Last_Name,Primary_Email,Region_Code,Is_Deleted_Ind)
SELECT A.User_Id,SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)),SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)),A.Email_Address,CAST(R.Region_Code AS VARCHAR(5)) AS Region_Code, 'N' AS Is_Deleted_Ind
FROM Temp_Access_Users A --INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))
WHERE NOT EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE LTRIM(RTRIM(A.User_Id))=GU.GD_User_Id) AND LEN(A.User_Id)<=10

INSERT INTO GPM_User(GD_User_Id,User_First_Name,User_Last_Name,Primary_Email,Region_Code,Is_Deleted_Ind)
SELECT A.User_Id,SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)),SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)),A.Email_Address,CAST(R.Region_Code AS VARCHAR(5)) AS Region_Code, 'N' AS Is_Deleted_Ind
FROM Temp_Functional_Users A --INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))
WHERE NOT EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE LTRIM(RTRIM(A.User_Id))=GU.GD_User_Id) AND LEN(A.User_Id)<=10

INSERT INTO GPM_User(GD_User_Id,User_First_Name,User_Last_Name,Primary_Email,Region_Code,Is_Deleted_Ind)
SELECT A.User_Id,SUBSTRING(A.Name,0,CHARINDEX(' ',A.Name)),SUBSTRING(A.Name,CHARINDEX(' ',A.Name)+1,LEN(A.Name)),A.Email_Address,CAST(R.Region_Code AS VARCHAR(5)) AS Region_Code, 'N' AS Is_Deleted_Ind
FROM Temp_Super_Users A --INNER JOIN GPM_User GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id
LEFT OUTER JOIN GPM_Region R on LTRIM(RTRIM(A.Region)) = LTRIM(RTRIM(R.Region_Code))
WHERE NOT EXISTS(SELECT GU.GD_User_Id FROM GPM_User GU WHERE LTRIM(RTRIM(A.User_Id))=GU.GD_User_Id) AND LEN(A.User_Id)<=10


--Update user if already present in AD_Group_Map
UPDATE GU1 SET GU1.Is_Deleted_Ind='N'
from Temp_Access_Users A INNER JOIN GPM_AD_Group_User_Map GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id WHERE GU1.AD_Group_Id=10 AND GU1.Is_Deleted_Ind='Y'
UPDATE GU1 SET GU1.Is_Deleted_Ind='N'
from Temp_Functional_Users A INNER JOIN GPM_AD_Group_User_Map GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id WHERE GU1.AD_Group_Id=12 AND GU1.Is_Deleted_Ind='Y'
UPDATE GU1 SET GU1.Is_Deleted_Ind='N'
from Temp_Super_Users A INNER JOIN GPM_AD_Group_User_Map GU1 On LTRIM(RTRIM(A.User_Id)) = GU1.GD_User_Id WHERE GU1.AD_Group_Id=11 AND GU1.Is_Deleted_Ind='Y'

--Insert user if not present in AD_Group_Map
INSERT INTO GPM_AD_Group_User_Map
	(
	GD_User_ID,AD_Group_Id,Is_Deleted_Ind,Last_Modified_By,Last_Modified_Date
	)
SELECT 
	AGT.User_ID,
	(SELECT GAG1.AD_Group_Id FROM GPM_AD_Group GAG1 WHERE RTRIM(LTRIM(UPPER(GAG1.AD_Group_Desc)))=RTRIM(LTRIM(UPPER(AGT.Access_Type)))),
	'N','ZA46134',GETDATE()
FROM Temp_Access_Users AGT WHERE NOT EXISTS(SELECT 1 FROM GPM_AD_Group_User_Map A WHERE A.GD_User_Id = AGT.User_ID AND A.AD_Group_Id=10)

INSERT INTO GPM_AD_Group_User_Map
	(
	GD_User_ID,AD_Group_Id,Is_Deleted_Ind,Last_Modified_By,Last_Modified_Date
	)
SELECT 
	AGT.User_ID,
	(SELECT GAG1.AD_Group_Id FROM GPM_AD_Group GAG1 WHERE RTRIM(LTRIM(UPPER(GAG1.AD_Group_Desc)))=RTRIM(LTRIM(UPPER(AGT.Access_Type)))),
	'N','ZA46134',GETDATE()
FROM Temp_Functional_Users AGT WHERE NOT EXISTS(SELECT 1 FROM GPM_AD_Group_User_Map A WHERE A.GD_User_Id = AGT.User_ID AND A.AD_Group_Id=12)

INSERT INTO GPM_AD_Group_User_Map
	(
	GD_User_ID,AD_Group_Id,Is_Deleted_Ind,Last_Modified_By,Last_Modified_Date
	)
SELECT 
	AGT.User_ID,
	(SELECT GAG1.AD_Group_Id FROM GPM_AD_Group GAG1 WHERE RTRIM(LTRIM(UPPER(GAG1.AD_Group_Desc)))=RTRIM(LTRIM(UPPER(AGT.Access_Type)))),
	'N','ZA46134',GETDATE()
FROM Temp_Super_Users AGT WHERE NOT EXISTS(SELECT 1 FROM GPM_AD_Group_User_Map A WHERE A.GD_User_Id = AGT.User_ID AND A.AD_Group_Id=11)