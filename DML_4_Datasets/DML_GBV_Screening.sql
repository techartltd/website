 select distinct  p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID ,psyh.Answer as Violence_within_past_year,
 physi.Answer as Physical_Hurt,
 pvtr.Answer as Threatens,
 sex.Answer as  Sexual_Violence,
 pvup.Answer as Violence_from_unrelated_person,
 psgb.DeleteFlag
 
    from Patient p
	inner  join(  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' 
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all 
 select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' 
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId
 )psgb on psgb.PatientId=p.Id 
 inner join PatientMasterVisit pmv on pmv.PatientId=psgb.PatientId and pmv.Id=psgb.PatientMasterVisitId
 left join(
  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvPhysicallyHurt'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId
 )psyh on psyh.PatientId=psgb.PatientId and psyh.PatientMasterVisitId=psgb.PatientMasterVisitId
left join(
select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipPhysicalAssault'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 physi on physi.PatientId=psgb.PatientId and physi.PatientMasterVisitId=psgb.PatientMasterVisitId

 left join(
  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipVerbalAssault'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 pvtr on pvtr.PatientId=psgb.PatientId and pvtr.PatientMasterVisitId=psgb.PatientMasterVisitId

 left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipUncomfSexAct'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)sex on sex.PatientId =psgb.PatientId
 and sex.PatientMasterVisitId=psgb.PatientMasterVisitId
left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvNonRelationshipViolence'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion5'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 pvup on pvup.PatientId =psgb.PatientId and pvup.PatientMasterVisitId=psgb.PatientMasterVisitId



--where  (psgb.DeleteFlag is null or psgb.DeleteFlag =0)




