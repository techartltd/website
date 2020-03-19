-- 14. IPT Program Followup
EXEC pr_OpenDecryptedSession;

SELECT p.PersonId
	,pmv.VisitDate AS EncounterDate
	,NULL AS Encounter_ID
	,pipt.IptDueDate AS Ipt_due_date
	,pipt.IptDateCollected AS Date_collected_ipt
	,pipt.[Weight] AS [Weight]
	,CASE 
		WHEN pipt.Hepatotoxicity = 0
			THEN 'No'
		WHEN pipt.Hepatotoxicity = 1
			THEN 'Yes'
		ELSE NULL
		END AS Hepatotoxity
	,HepatotoxicityAction AS Hepatotoxity_Action
	,CASE 
		WHEN pipt.Peripheralneoropathy = 0
			THEN 'No'
		WHEN pipt.Peripheralneoropathy = 1
			THEN 'Yes'
		ELSE NULL
		END AS Peripheralneoropathy
	,pipt.PeripheralneoropathyAction AS Peripheralneuropathy_Action
	,CASE 
		WHEN pipt.Rash = 0
			THEN 'No'
		WHEN pipt.Rash = 1
			THEN 'Yes'
		ELSE NULL
		END AS Rash
	,pipt.RashAction AS Rash_Action
	,ltv.DisplayName AS Adherence
	,pipt.AdheranceMeasurementAction AS AdheranceMeasurement_Action
	,lto.ItemDisplayName AS IPT_Outcome
	,pio.IPTOutComeDate AS Outcome_Date
	,pipt.CreateDate created_at
	,pipt.CreatedBy created_by
FROM PatientIpt pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId
INNER JOIN Patient p ON p.Id = pipt.PatientId
LEFT JOIN LookupItemView ltv ON ltv.ItemId = pipt.AdheranceMeasurement
LEFT JOIN PatientIptOutcome pio ON pio.PatientId = pipt.PatientId 
	AND ltv.MasterName = 'AdheranceMeasurement'
LEFT JOIN LookupItemView lto ON lto.itemId = pio.IptEvent
	AND ltv.MasterName = 'IptOutcome'