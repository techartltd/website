SELECT 
P.PersonId AS Person_Id,
format(cast(PE.EnrollmentDate AS DATE), 'yyyy-MM-dd') AS Encounter_Date,
NULL AS Encounter_ID,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '1. OTZ Orientation'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Orientation,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '3. OTZ Leadership'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Leadership,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '2. OTZ Participation'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Participation,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '6. OTZ Treatment Literacy'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Treatment_literacy,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '5. OTZ Transition to Adult Care'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Transition_to_adult_care,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '4. OTZ Making Decisions for the future'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Making_Decision_future,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '7. OTZ SRH'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Srh,
CASE WHEN (SELECT top 1 OTZT.TopicId
FROM [dbo].[OtzActivityForm] OTZF
INNER JOIN [dbo].[OtzActivityTopics] OTZT ON OTZT.ActivityFormId = OTZF.Id
INNER JOIN PatientMasterVisit PMV ON PMV.Id = OTZF.PatientMasterVisitId
WHERE OTZT.TopicId = (
		SELECT top 1 ItemId
		FROM LookupItemView
		WHERE MasterName = 'OTZ_Modules'
			AND ItemName = '8. OTZ Beyond the 3rd 90'
		) AND format(cast(PMV.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')) IS NOT NULL THEN 'Yes' ELSE NULL END AS Beyond_third_ninety,
		CASE 
WHEN PE.TransferIn = 1
THEN 'Yes'
WHEN PE.TransferIn = 0
THEN 'No'
ELSE NULL
END AS Transfer_In
,pe.EnrollmentDate AS Initial_Enrollment_Date
,pe.DeleteFlag AS Voided

FROM Patient P 
INNER JOIN PatientEnrollment PE ON PE.PatientId = P.Id
INNER JOIN PatientIdentifier PI ON PI.PatientId = P.Id AND PI.PatientEnrollmentId = PE.Id
LEFT JOIN ServiceArea SA ON SA.Id = PE.ServiceAreaId
INNER JOIN PatientMasterVisit PM ON PM.PatientId = P.Id AND PM.ServiceId = SA.Id
WHERE SA.Code = 'OTZ' AND  PM.VisitType = (select top 1 ItemId from LookupItemView where MasterName = 'VisitType' and ItemName = 'Enrollment');