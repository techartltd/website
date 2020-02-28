select pt.PersonId as Person_Id 
,pe.EnrollmentDate as Encounter_Date,NULL as Encounter_ID,
CASE WHEN otz1.Topic is not null then 'Yes' else NULL end as Orientation,
CASE WHEN otz3.Topic is not null then 'Yes' else NULL end as Leadership,
CASE WHEN otz2.Topic is not null then 'Yes' else NULL end as Participation,
CASE WHEN otz6.Topic is not null then 'Yes' else NULL end as Treatment_literacy,
CASE WHEN otz5.Topic is not null then 'Yes' else NULL end as Transition_to_adult_care,
CASE WHEN otz4.Topic is not null then 'Yes' else NULL end as Making_Decision_future,
CASE WHEN otz7.Topic is not null then 'Yes' else NULL end as Srh,
CASE WHEN otz8.Topic is not null then 'Yes' else NULL end as Beyond_third_ninety,
CASE WHEN pe.TransferIn=1 then 'Yes'   when pe.TransferIn =1
then 'No' else NULL end as   Transfer_In,
pe.EnrollmentDate as Initial_Enrollment_Date,
pe.DeleteFlag as Voided
  from PatientEnrollment pe
  inner join Patient pt on pt.Id=pe.PatientId
inner join ServiceArea sa on sa.Id=pe.ServiceAreaId
inner join OtzActivityForms oaf on format(oaf.VisitDate,'M/dd/YYYY')=format(pe.EnrollmentDate,'M/dd/YYYY') and oaf.PatientId=pe.PatientId
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
   and ItemName='2. OTZ Participation')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz2 on otz2.Id=oaf.Id


   
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='3. OTZ Leadership')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz3 on otz3.Id=oaf.Id

left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='4. OTZ Making Decisions for the future')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz4 on otz4.Id=oaf.Id
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='5. OTZ Transition to Adult Care')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz5 on otz5.Id=oaf.Id
   left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='6. OTZ Treatment Literacy')otzm on otzm.ItemId=ott.TopicId)
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
   and ItemName='8. OTZ Beyond the 3rd 90')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz8 on otz8.Id=oaf.Id
where sa.Code='OTZ'

