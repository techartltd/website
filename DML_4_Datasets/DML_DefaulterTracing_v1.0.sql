select pce.PersonId as Person_Id,
pce.Id as PatientsId,
pce.start as Encounter_Date,
pce.ExitDate as Exit_Date,pce.ExitReason as Exit_Reason,NULL as Encounter_ID,NULL as Tracing_type,
pce.TracingOutcome as Tracing_Outcome,
pce.ReasonLostToFollowup as Reason_LostToFollowup,
NULL as Attempt_number,
NUll as Is_final_trace,
NULL as True_status,
pce.ReasonsForDeath as  Cause_of_death,
pce.CareEndingNotes as Comments,
pce.DeleteFlag  as Voided
 from(select p.id, p.PersonId,pce.PatientId,pce.PatientMasterVisitId,pmv.Start, pmv.VisitDate,pce.ExitDate,
(select top 1. [Name] from Lookupitem where id= pce.ExitReason) as ExitReason,
pce.DeleteFlag,
(select top 1. [Name] from Lookupitem where id= pce.TracingOutome) as TracingOutcome ,
(select top 1. [Name] from Lookupitem where id= pce.ReasonLostToFollowup) as ReasonLostToFollowup
,(select top 1. [Name] from Lookupitem where id= pce.ReasonsForDeath) as ReasonsForDeath
,pce.CareEndingNotes
from PatientCareending pce
inner join Patient p on p.Id=pce.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId and pce.patientId=pmv.PatientId
)pce
where pce.ExitReason='LostToFollowUp' and pce.DeleteFlag=0