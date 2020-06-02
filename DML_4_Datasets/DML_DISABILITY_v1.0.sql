select cd.PersonId as Person_Id
,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID,(select top 1.name from Lookupitem li where li.Id=cd.DisabilityId)Disability,NULL as Disability_Type,cd.DeleteFlag,
cd.CreatedBy,cd.CreateDate 

  from ClientDisability cd
left join PatientEncounter pe on pe.Id=cd.PatientEncounterID
left join PatientMasterVisit pmv on pmv.Id =pe.PatientMasterVisitId