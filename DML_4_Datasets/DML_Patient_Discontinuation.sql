select DISTINCT
P.Id as Person_Id,
pe.Enrollment as Encounter_Date,
NULL as Encounter_ID,
sa.Code as Program,
pe.Enrollment as Date_Enrolled,
pe.ExitDate as Date_Completed,
pe.ExitReasonValue as Care_Ending_Reason,
pe.TransferOutfacility as Facility_Transfered_To,
pe.DateOfDeath as Death_Date
from Person P

INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN 
(select pce.PatientId,pce.ServiceAreaId,pce.Enrollment,pce.ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(select pce.PatientId,pce.ReenrollmentDate as Enrollment,pce.ServiceAreaId,CASE WHEN 
pce.ExitDate > pce.ReenrollmentDate then pce.ExitDate else NULL end as ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(
select pe.PatientId,pe.Id,pe.CareEnded,pce.Active,pce.DeleteFlag,pe.EnrollmentDate,pe.ServiceAreaId
,pce.ExitDate,pce.ExitReason,lti.DisplayName as ExitReasonValue,pce.TransferOutfacility,pre.ReenrollmentDate,pce.DateOfDeath from PatientEnrollment pe
inner join PatientCareending pce on pce.PatientId=pe.PatientId
inner join PatientReenrollment pre on pre.PatientId=pce.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
where pce.DeleteFlag='1'
)pce
union 
select pce.PatientId,pce.EnrollmentDate as Enrollment,pce.ServiceAreaId,pce.ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(
select pe.PatientId,pe.CareEnded,pe.ServiceAreaId,pe.EnrollmentDate,pce.ExitDate,lti.DisplayName as ExitReasonValue,pce.TransferOutfacility,pce.DeleteFlag,pce.DateOfDeath
from PatientEnrollment pe 
left join PatientCareending pce on pce.PatientId = pe.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
)pce)pce )pe on pe.PatientId=PT.Id
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId
INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id 
WHERE pe.ExitDate is not null