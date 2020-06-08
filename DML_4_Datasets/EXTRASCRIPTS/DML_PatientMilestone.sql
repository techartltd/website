select pmi.PatientId,pmi.PatientMasterVisitId,(select li.Name from LookupItem li where li.Id=pmi.id)
as TypeAssessed,
CASE WHEN AchievedId=1 then 'YES' end as MilestoneAchieved,
(select  li.[Name] from LookupItem li where li.Id=pmi.StatusId ) as Status,
pmi.Comment as Milestone_Comment,
pmi.DateAssessed as Milestone_Date_Assessed,
pmi.CreateDate,
pmi.CreatedBy,
pmi.DeleteFlag
 from PatientMilestone pmi