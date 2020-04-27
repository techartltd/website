INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'Alcohol Screening','Number of Patients', COUNT(*) 
from  (
select DISTINCT pt.PersonId,pe.VisitDate as Encounter_Date,NULL as Encounter_ID 
,pdra.Answer as DrinkAlcohol
,pss.Answer as Smoke
,pudd.Answer as UseDrugs,
trss.Answer as [TriedStopSmoking],
asq1.Answer as FeltCutDownDrinkingorDrugUse,
asq2.Answer as AnnoyedByCriticizingDrinkingorDrugUse,
asq3.Answer as FeltGuiltyDrinkingorDrugUse,
asq4.Answer as UseToSteadyNervesGetRidHangover,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided
from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType' OR MasterName='SocialHistoryQuestions' )
liv on liv.ItemId=pe.EncounterTypeId
where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id

inner join(select psc.PatientId,psc.PatientMasterVisitId from PatientScreening psc where
			ScreeningCategoryID in (select Distinct itemID from LookupItemView where MasterName='SocialHistoryQuestions')
 )psq on psq.PatientId=pe.PatientId and psq.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='DrinkAlcohol'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdra on pdra.PatientId=pe.PatientId and pdra.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='Smoke'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pss on pss.PatientId=pe.PatientId and pss.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='UseDrugs'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pudd on pudd.PatientId=pe.PatientId and pudd.PatientMasterVisitId=pe.PatientMasterVisitId

   left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SmokingScreeningQuestions'  and ItemName='SmokingScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  trss on trss.PatientId=pe.PatientId and trss.PatientMasterVisitId=pe.PatientMasterVisitId


  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq1 on asq1.PatientId=pe.PatientId and asq1.PatientMasterVisitId=pe.PatientMasterVisitId

    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq2 on asq2.PatientId=pe.PatientId and asq2.PatientMasterVisitId=pe.PatientMasterVisitId

  
    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq3 on asq3.PatientId=pe.PatientId and asq3.PatientMasterVisitId=pe.PatientMasterVisitId


      left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq4 on asq4.PatientId=pe.PatientId and asq4.PatientMasterVisitId=pe.PatientMasterVisitId

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
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitID
)BB