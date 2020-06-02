
select p.PersonId,pmv.VisitDate as EncounterDate,
NULL as Encounter_ID,'Yes' as Has_adverse_drug_reaction,
ae.EventCause as Medicine_causing_drug_reaction,
ae.EventName as Drug_reaction,
(select  top 1 [Name] from LookupItem where Id=Severity) as Drug_reaction_severity,

NULL as Drug_reaction_onset_date,
ae.[Action] as  Drug_reaction_action_taken,
ae.DeleteFlag,
ae.CreateBy,
ae.CreateDate
 from AdverseEvent ae
inner join Patient p on p.Id =ae.PatientId
inner join PatientMasterVisit pmv on pmv.Id=ae.PatientMasterVisitId


