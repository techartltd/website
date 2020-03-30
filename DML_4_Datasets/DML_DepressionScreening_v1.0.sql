select distinct p.PersonId as Person_Id
,pmv.VisitDate as Encounter_Date,
NULL as Encounter_ID,
ds1.Answer as  FeelingDownDepressed,
ds2.Answer as LittleNoInterest,
phq1.Answer as PHQLittleNoInterest,
phq2.Answer as PHQFeelingDownDepressed,
phq3.Answer as PHQTroubleSleeping,
phq4.Answer as PHQFeelingTiredLittleEnergy,
phq5.Answer as PHQPoorAppetiteOvereating,
phq6.Answer as PHQFeelingBadAboutYourSelf,
phq7.Answer as PHQTroubleConcentrating,
phq8.Answer as PHQMovingSpeakingSlowly,
rcm.ClinicalNotes as RecommendedManagement,
dss.ClinicalNotes as DepressionSeverity,
dst.ClinicalNotes as DepressionTotal

 from  PatientEncounter pe
inner join
(select * from LookupItemView where MasterName='EncounterType'
and ItemName in('DepressionScreening','Adherence-Barriers') )ab on ab.ItemId=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
and pmv.PatientId=pe.PatientId
inner join Patient p on p.Id=pe.PatientId
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Question1' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq1 on  phq1.PatientId=p.id  and phq1.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions2' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq2 on  phq2.PatientId=p.id  and phq2.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions3' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq3 on  phq3.PatientId=p.id  and phq3.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions4' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq4 on  phq4.PatientId=p.id  and phq4.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions5' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq5 on  phq5.PatientId=p.id  and phq5.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions6' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq6 on  phq6.PatientId=p.id  and phq6.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions7' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq7 on  phq7.PatientId=p.id  and phq7.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PHQ9Questions8' and lt.MasterName='PHQ9Questions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) phq8 on  phq8.PatientId=p.id  and phq8.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='DSQuestion1' and lt.MasterName='DepressionScreeningQuestions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) ds1 on  ds1.PatientId=p.id  and ds1.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='DSQuestion2' and lt.MasterName='DepressionScreeningQuestions'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) ds2 on  ds2.PatientId=p.id  and ds2.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ReccommendedManagement' and lt.MasterName='DepressionScreeningNotes'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) rcm on  rcm.PatientId=p.id  and rcm.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DepressionSeverity' and lt.MasterName='DepressionScreeningNotes'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dss on  dss.PatientId=p.id  and dss.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DepressionTotal' and lt.MasterName='DepressionScreeningNotes'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dst on  dst.PatientId=p.id  and dst.PatientMasterVisitId=pmv.Id