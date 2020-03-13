SELECT p.PersonId AS Person_Id,
PC.ExitDate as Encounter_Date,
NULL as Encounter_ID,
(SELECT Code FROM ServiceArea WHERE ID = (SELECT TOP 1 ServiceAreaId FROM PatientEnrollment WHERE PatientId = PC.PatientId)) AS Program,
(SELECT TOP 1 EnrollmentDate FROM PatientEnrollment WHERE PatientId = PC.PatientId) AS Date_Enrolled,
(SELECT DisplayName FROM LookupItem WHERE Id = PC.ExitReason) AS Care_Ending_Reason,
PC.TransferOutfacility as Facility_Transfered_To,
PC.DateOfDeath as Death_Date
FROM PatientCareending PC 
JOIN Patient P ON PC.PatientId = P.Id