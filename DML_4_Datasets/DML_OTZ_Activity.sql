select pt.PersonId as Person_Id 
,oaf.VisitDate as Encounter_Date,NULL as Encounter_ID,
CASE WHEN otz1.Topic is not null then 'Yes' else NULL end as Orientation,
CASE WHEN otz3.Topic is not null then 'Yes' else NULL end as Leadership,
CASE WHEN otz2.Topic is not null then 'Yes' else NULL end as Participation,
CASE WHEN otz6.Topic is not null then 'Yes' else NULL end as Treatment_literacy,
CASE WHEN otz5.Topic is not null then 'Yes' else NULL end as Transition_to_adult_care,
CASE WHEN otz4.Topic is not null then 'Yes' else NULL end as Making_Decision_future,
CASE WHEN otz7.Topic is not null then 'Yes' else NULL end as Srh,
CASE WHEN otz8.Topic is not null then 'Yes' else NULL end as Beyond_third_ninety,
oaf.AttendedSupportGroup as Attended_Support_Group,
oaf.Remarks,
pmv.DeleteFlag as Voided
  from OtzActivityForms oaf
    inner join Patient pt on pt.Id=oaf.PatientId
	inner join OtzActivityForm oafs on oafs.Id=oaf.Id
	inner join PatientMasterVisit pmv on pmv.Id=oafs.PatientMasterVisitId

left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='1. OTZ Orientation')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz1 on otz1.Id=oaf.Id

left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='2. OTZ Participation' )otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz2 on otz2.Id=oaf.Id


   
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='3. OTZ Leadership' or itemName= 'Leadership')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz3 on otz3.Id=oaf.Id

left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='4. OTZ Making Decisions for the future' or itemName= 'Decision Making')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz4 on otz4.Id=oaf.Id
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='5. OTZ Transition to Adult Care' or itemName= 'Transition to Adult care')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz5 on otz5.Id=oaf.Id
   left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='6. OTZ Treatment Literacy' or itemName= 'OTZ Treatment Literacy' ) otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz6 on otz6.Id=oaf.Id

   left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='7. OTZ SRH')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz7 on otz7.Id=oaf.Id
  left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='8. OTZ Beyond the 3rd 90'  or itemName= 'Orientation - Operation Triple Zero' )otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz8 on otz8.Id=oaf.Id


