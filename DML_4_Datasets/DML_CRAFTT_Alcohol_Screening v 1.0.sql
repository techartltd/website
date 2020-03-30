
select DISTINCT pt.PersonId,pe.VisitDate,pdr.Answer as DrinkAlcoholMorethanSips,
pc2ma.Answer as SmokeAnyMarijuana,
pcq3.Answer as UseAnythingElseGetHigh,
crs1.Answer as CARDrivenandHigh,
crs2.Answer as UseDrugorAlcoholRelax,
crs3.Answer as UseDrugByYourself,
crs4.Answer as ForgetWhileUsingAlcohol,
crs5.Answer as FamilyTellYouCutDownDrugs,
crs6.Answer as TroubleWhileUsingDrugs,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided,
pe.CreateDate,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=pe.CreatedBy) 
as CreatedBy


from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag,pe.CreateDate,pe.CreatedBy  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType')
liv on liv.ItemId=pe.EncounterTypeId
where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id
inner join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pcss on pcss.PatientId=pe.PatientId and pcss.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdr on pdr.PatientId=pe.PatientId and pdr.PatientMasterVisitId=pe.PatientMasterVisitId

left join( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)pc2ma on pc2ma.PatientId=pe.PatientId
  and pc2ma.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  )pcq3 on pcq3.PatientId=pe.PatientId and pcq3.PatientMasterVisitId=pe.PatientMasterVisitId

left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs1 on crs1.PatientId=pe.PatientId and crs1.PatientMasterVisitId=pe.PatientMasterVisitId



  left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs2 on crs2.PatientId=pe.PatientId and crs2.PatientMasterVisitId=pe.PatientMasterVisitId


   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs3 on crs3.PatientId=pe.PatientId and crs3.PatientMasterVisitId=pe.PatientMasterVisitId



   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs4 on crs4.PatientId=pe.PatientId and crs4.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion5'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs5 on crs5.PatientId=pe.PatientId and crs5.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion6'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs6 on crs6.PatientId=pe.PatientId and crs6.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholRiskLevel')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)arll on arll.PatientId=pe.PatientId and arll.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholScore')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)als on als.PatientId=pe.PatientId and als.PatientMasterVisitId=pe.PatientMasterVisitId



left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocialHistory' and lt.ItemName='SocialNotes')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitId