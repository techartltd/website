
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID,
ps.TannersStagingDate,(select top 1 li.[DisplayName] from LookupItem li where li.Id=ps.BreastsGenitalsId)BreastsGenitalStage
,(select top 1 li.[DisplayName] from LookupItem li where li.Id=ps.PubicHairId)PubicHairStage,
ps.CreateDate,ps.CreatedBy,ps.DeleteFlag
 from PatientTannersStaging ps
inner join Patient p on p.Id=ps.PatientId
inner join PatientMasterVisit pmv on pmv.Id=ps.PatientMasterVisitId