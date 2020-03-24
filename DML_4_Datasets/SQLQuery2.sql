SELECT *  FROM PatientEncounter WHERE EncounterTypeId =  (SELECT ItemId FROM LookupItemView WHERE ItemName = 'EnhanceAdherence')

SELECT ItemId FROM LookupItemView WHERE ItemName = 'EnhanceAdherence'
SELECT * FROM LookupItemView WHERE ItemName LIKE '%PillAdherence%'
SELECT * FROM LookupItemView WHERE DisplayName LIKE '%MMAS%'

SELECT * FROM PatientClinicalNotes