
-- 12. IPT Screening
exec pr_OpenDecryptedSession;


 select p.PersonId,
pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,CASE WHEN pipt.YellowColouredUrine =0 then 'No' when pipt.YellowColouredUrine=1 then 'Yes'
else NULL
 end as Yellow_urine
 ,CASE WHEN pipt.Numbness =0 then 'No' when pipt.Numbness=1 then 'Yes'
else NULL
 end as Numbness
 ,CASE WHEN pipt.YellownessOfEyes =0 then 'No' when pipt.YellownessOfEyes=1 then 'Yes'
else NULL
 end as Yellow_eyes,
 CASE WHEN pipt.AbdominalTenderness =0 then 'No' when pipt.AbdominalTenderness=1 then 'Yes'
else NULL
 end as Tenderness
,pipt.IptStartDate as IPT_Start_Date

from PatientIptWorkup pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId

-- 13. IPT Program Enrollment
exec pr_OpenDecryptedSession;


select p.PersonId,
pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,pipt.IptStartDate as IPT_Start_Date,
NULL as Indication_for_IPT,
ltv.ItemDisplayName as IPT_Outcome
,pio.IPTOutComeDate as Outcome_Date

from PatientIptWorkup pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId
left join PatientIptOutcome pio on pio.PatientId=pipt.PatientId
and pio.PatientMasterVisitId=pipt.PatientMasterVisitId
left join LookupItemView ltv on ltv.itemId=pio.IptEvent 
and ltv.MasterName='IptOutcome'

-- 14. IPT Program Followup
exec pr_OpenDecryptedSession;


  select p.PersonId
,pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,pipt.IptDueDate as Ipt_due_date
,pipt.IptDateCollected as Date_collected_ipt
,pipt.[Weight] as [Weight]
,CASE WHEN pipt.Hepatotoxicity =0 then 'No' when pipt.Hepatotoxicity=1 then 'Yes'
else NULL
 end as Hepatotoxity,
 HepatotoxicityAction as Hepatotoxity_Action,
 CASE WHEN pipt.Peripheralneoropathy =0 then 'No' when pipt.Peripheralneoropathy=1 then 'Yes'
else NULL
end as Peripheralneoropathy
,pipt.PeripheralneoropathyAction as Peripheralneuropathy_Action
 ,CASE WHEN pipt.Rash =0 then 'No' when pipt.Rash=1 then 'Yes'
else NULL
 end as Rash,
 pipt.RashAction as Rash_Action,
 ltv.DisplayName as Adherence,
 pipt.AdheranceMeasurementAction as AdheranceMeasurement_Action,
 lto.ItemDisplayName as IPT_Outcome,
 pio.IPTOutComeDate as Outcome_Date
from  PatientIpt pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId
left join LookupItemView ltv on ltv.ItemId=pipt.AdheranceMeasurement
left join PatientIptOutcome pio on pio.PatientId = pipt.PatientId and pio.PatientMasterVisitId=pipt.PatientMasterVisitId
and ltv.MasterName='AdheranceMeasurement'
left join LookupItemView lto on lto.itemId=pio.IptEvent 
and ltv.MasterName='IptOutcome'