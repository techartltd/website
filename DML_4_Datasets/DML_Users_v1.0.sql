SELECT u.UserID [User_Id]
	,u.UserFirstName [First_Name]
	,u.UserLastName [Last_Name]
	,u.UserName [User_Name]
	,[Status] = CASE u.DeleteFlag
		WHEN 0
			THEN 'Active'
		WHEN 1
			THEN 'InActive'
		END 
	,ds.[Name] AS Designation
	,ltg.GroupNames
FROM mst_User u
LEFT JOIN mst_Employee me ON me.EmployeeID = u.EmployeeId
LEFT JOIN mst_Designation ds ON ds.Id = me.DesignationID
LEFT JOIN (
	SELECT ltu.UserID
		,STUFF((
				SELECT DISTINCT ',' + msg.GroupName
				FROM lnk_UserGroup lu
				INNER JOIN mst_Groups msg ON lu.GroupID = msg.GroupID
				WHERE lu.UserID = ltu.UserID
				FOR XML path('')
				), 1, 1, '') AS GroupNames
	FROM lnk_UserGroup ltu
	GROUP BY ltu.UserID
	) ltg ON ltg.UserID = u.UserID
WHERE u.UserID != 1;





