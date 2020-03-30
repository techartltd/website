

SELECT p.PersonId AS Person_Id
	,pmv.VisitDate AS Encounter_Date
	,NULL AS Encounter_ID
	,(
		SELECT TOP 1. [Name]
		FROM LookupItem li
		WHERE li.Id = pce.ExitReason
		) AS Discontinuation_Reason
	,pce.ExitDate AS ExitDate
	,pce.DateOfDeath
	,pce.TransferOutfacility AS Transfer_Facility
	,NULL AS Transfer_Date
	,pce.DeleteFlag AS Voided
FROM PatientCareending pce
INNER JOIN Patient p ON pce.PatientId = p.Id
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pce.PatientMasterVisitId
INNER JOIN PatientEnrollment pe ON pe.Id = pce.PatientEnrollmentId
INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
WHERE sa.Code = 'OTZ'

