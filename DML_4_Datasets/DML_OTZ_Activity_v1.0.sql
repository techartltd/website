SELECT 
P.PersonId as Person_Id,
format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd') AS Encounter_Date,
NULL as Encounter_ID,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '1. OTZ Orientation')) IS NOT NULL THEN 'Yes' ELSE 'No' END as Orientation,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '3. OTZ Leadership')) IS NOT NULL THEN 'Yes' ELSE 'No' END as Leadership,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '2. OTZ Participation')) IS NOT NULL THEN 'Yes' ELSE 'No' END as Participation,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '6. OTZ Treatment Literacy')) IS NOT NULL THEN 'Yes' ELSE 'No' END AS Treatment_literacy,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '5. OTZ Transition to Adult Care')) IS NOT NULL THEN 'Yes' ELSE 'No' END AS Transition_to_adult_care,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '4. OTZ Making Decisions for the future')) IS NOT NULL THEN 'Yes' ELSE 'No' END AS Making_Decision_future,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '7. OTZ SRH')) IS NOT NULL THEN 'Yes' ELSE 'No' END AS Srh,
CASE WHEN (SELECT top 1 Id FROM [dbo].[OtzActivityTopics] AT WHERE AT.ActivityFormId = AF.Id and AT.TopicId = (SELECT top 1 ItemId FROM LookupItemView WHERE MasterName = 'OTZ_Modules' AND ItemName = '8. OTZ Beyond the 3rd 90')) IS NOT NULL THEN 'Yes' ELSE 'No' END AS Beyond_third_ninety,
AF.AttendedSupportGroup as Attended_Support_Group,
AF.Remarks,
AF.DeleteFlag as Voided

FROM [dbo].[OtzActivityForm] AF 
INNER JOIN PatientMasterVisit PM ON PM.Id = AF.PatientMasterVisitId
INNER JOIN Patient P ON P.Id = PM.PatientId
WHERE PM.VisitType IS NULL;
