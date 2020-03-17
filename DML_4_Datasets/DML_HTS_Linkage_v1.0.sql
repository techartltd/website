select 
PL.PersonId Person_Id,
PL.LinkageDate Encounter_Date,
NULL Encounter_ID,
PL.Facility Facility_Linked,
PL.CCCNumber CCC_Number,
PL.HealthWorker Health_Worker_Handed_To,
PL.Cadre Cadre,
Date_Enrolled = (SELECT PE.EnrollmentDate FROM PatientEnrollment PE INNER JOIN Patient P ON P.Id = PE.PatientId WHERE P.PersonId = PL.PersonId AND ServiceAreaId = 1),
PL.ArtStartDate ART_Start_Date,
PL.Comments Remarks

from PatientLinkage PL