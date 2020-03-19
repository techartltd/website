-- 12. IPT Screening
EXEC pr_OpenDecryptedSession;

SELECT p.PersonId
	,pmv.VisitDate AS EncounterDate
	,NULL AS Encounter_ID
	,CASE 
		WHEN pipt.YellowColouredUrine = 0
			THEN 'No'
		WHEN pipt.YellowColouredUrine = 1
			THEN 'Yes'
		ELSE NULL
		END AS Yellow_urine
	,CASE 
		WHEN pipt.Numbness = 0
			THEN 'No'
		WHEN pipt.Numbness = 1
			THEN 'Yes'
		ELSE NULL
		END AS Numbness
	,CASE 
		WHEN pipt.YellownessOfEyes = 0
			THEN 'No'
		WHEN pipt.YellownessOfEyes = 1
			THEN 'Yes'
		ELSE NULL
		END AS Yellow_eyes
	,CASE 
		WHEN pipt.AbdominalTenderness = 0
			THEN 'No'
		WHEN pipt.AbdominalTenderness = 1
			THEN 'Yes'
		ELSE NULL
		END AS Tenderness
	,pipt.IptStartDate AS IPT_Start_Date
	,pipt.CreateDate created_at
	,pipt.CreatedBy created_by
FROM PatientIptWorkup pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId
INNER JOIN Patient p ON p.Id = pipt.PatientId