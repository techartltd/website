
-- 27. HEI Outcome
select p.PersonId as Person_Id ,v.VisitDate as Encounter_Date, (select ltv.[Name] from LookupItem ltv  where ltv.Id =  he.Outcome24MonthId) as Child_hei_outcomes_HIV_Status,v.VisitDate as Child_hei_outcomes_exit_date
  from HEIEncounter he 
inner join PatientMasterVisit v on v.Id=he.PatientMasterVisitId
inner join Patient p on he.PatientId=p.Id
inner join  PatientEnrollment pe on p.Id =pe.PatientId
inner join Person per on per.Id=p.PersonId 
left join PatientVitals pvs on pvs.PatientId=he.PatientId  and pvs.PatientMasterVisitId=v.Id
where he.Outcome24MonthId is not null


