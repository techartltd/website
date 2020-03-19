-- 13. IPT Program Enrollment
exec pr_OpenDecryptedSession;
select Distinct p.PersonId
	,pmv.VisitDate as EncounterDate
	,NULL as Encounter_ID
	,pipt.IptStartDate as IPT_Start_Date
	,NULL as Indication_for_IPT
	,ltv.ItemDisplayName as IPT_Outcome
	,pio.IPTOutComeDate as Outcome_Date
	,pipt.CreateDate created_at
	,pipt.CreatedBy created_by
from PatientIptWorkup pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId
left join PatientIptOutcome pio on pio.PatientId=pipt.PatientId
left join LookupItemView ltv on ltv.itemId=pio.IptEvent 
and ltv.MasterName='IptOutcome'
