select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date, NULL as Encounter_ID,
'Yes' as Vaccinations_today,(select top 1.[Name] from LookupItem where Id=v.VaccineStage)Vaccine_Stage,
(select top 1.[Name] from LookupItem where Id=v.Vaccine)Vaccine,v.VaccineDate as Vaccination_Date,
(select top 1.[Name] from LookupItem where Id=v.PeriodId) as [Period],v.CreatedBy,v.CreateDate,v.DeleteFlag
 from Vaccination v
inner join Patient p on p.Id=v.PatientId
inner join PatientMasterVisit pmv on pmv.Id=v.PatientMasterVisitId