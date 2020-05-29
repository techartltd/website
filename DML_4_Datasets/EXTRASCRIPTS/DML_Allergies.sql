
select p.PersonId as Person_Id
,pmv.VisitDate as Encounter_Date,
NULL as Encounter_ID,
CASE when LEN(pa.Allergen) > 0
then 'YES' ELSE NULL  end as Has_Known_allergies,
(select top 1 li.[Name] from LookupItem li where
li.Id=pa.Allergen) as
 Allegies_causative_agents,
 (select top 1 li.[Name] from LookupItem li
 where li.Id=pa.Reaction) as Allergies_reactions,
 (select top 1 li.[Name] from LookupItem li
 where li.Id=pa.Severity) as Allergies_severity,
 pa.DeleteFlag

from PatientAllergy pa
inner join Patient p on p.Id=pa.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pa.PatientMasterVisitId