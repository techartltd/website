select  p.PersonId,pmv.VisitDate as Encounter_Date,
NULL as Encounter_ID,
'Yes' as Has_Chronic_illnesses_cormobidities,
(select top 1 [Name] from LookupItem where Id=pcs.ChronicIllness) as Chronic_illnesses_name,
pcs.OnsetDate,
pcs.Treatment,
pcs.Dose,
pcs.Duration,
pcs.DeleteFlag,
pcs.CreateBy,
pcs.CreateDate
from PatientChronicIllness pcs
inner join Patient p on p.Id=pcs.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pcs.PatientMasterVisitId


