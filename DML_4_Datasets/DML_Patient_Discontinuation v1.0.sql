SELECT p.PersonId AS Person_Id
	,(
		SELECT [Start]
		FROM PatientMasterVisit PMV
		WHERE PMV.Id = PC.PatientMasterVisitId
		) AS Encounter_Date
	,NULL AS Encounter_ID
	,(
		SELECT Code
		FROM ServiceArea
		WHERE ID = (
				SELECT TOP 1 ServiceAreaId
				FROM PatientEnrollment
				WHERE PatientId = PC.PatientId
				)
		) AS Program
	,(
		SELECT TOP 1 EnrollmentDate
		FROM PatientEnrollment
		WHERE PatientId = PC.PatientId
		) AS Date_Enrolled
	,PC.ExitDate Date_Completed
	,(
		SELECT DisplayName
		FROM LookupItem
		WHERE Id = PC.ExitReason
		) AS Care_Ending_Reason
	,PC.TransferOutfacility AS Facility_Transfered_To
	,PC.DateOfDeath AS Death_Date
FROM PatientCareending PC
JOIN Patient P ON PC.PatientId = P.Id