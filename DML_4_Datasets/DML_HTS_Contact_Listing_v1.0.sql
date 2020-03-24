EXEC pr_OpenDecryptedSession;
select 
PT.PersonId Person_Id,
PT.ID,
PR.PersonId Contact_Person_Id,
format(cast(PR.CreateDate AS DATE), 'yyyy-MM-dd') Encounter_Date,
NULL  Encounter_ID,
NULL  Consent,
CAST(DECRYPTBYKEY(P.FirstName) AS VARCHAR(50))  First_Name,
CAST(DECRYPTBYKEY(P.MidName) AS VARCHAR(50))  Middle_Name,
CAST(DECRYPTBYKEY(P.LastName) AS VARCHAR(50))  Last_Name,
Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else ItemName end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = P.Sex),
format(cast(P.DateOfBirth AS DATE), 'yyyy-MM-dd')  DoB,
Marital_Status = (SELECT TOP 1 ItemName FROM PatientMaritalStatus PM INNER JOIN LookupItemView LK ON LK.ItemId = PM.MaritalStatusId WHERE PM.PersonId = P.Id AND PM.DeleteFlag = 0 AND LK.MasterName = 'MaritalStatus'),
Physical_Address = (SELECT TOP 1 CAST(DECRYPTBYKEY(PC.PhysicalAddress) AS VARCHAR(50)) FROM PersonContact PC WHERE PC.PersonId = P.Id AND PC.DeleteFlag = 0 ORDER BY ID DESC),
Phone_Number = (SELECT TOP 1 CAST(DECRYPTBYKEY(PC.MobileNumber) AS VARCHAR(50)) FROM PersonContact PC WHERE PC.PersonId = P.Id AND PC.DeleteFlag = 0 ORDER BY ID DESC),
Relationship_To_Index = (SELECT TOP 1 ItemName FROM LookupItemView WHERE MasterName = 'Relationship' AND ItemId = PR.RelationshipTypeId),
PNSScreeningDate = (SELECT TOP 1 format(cast(ScreeningDate AS DATE), 'yyyy-MM-dd') FROM HtsScreeningOptions WHERE PersonId = PR.PersonId),
Currently_Living_With_Index = (SELECT ItemName FROM LookupItemView WHERE MasterName ='YesNo' AND ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'LivingWithClient') ORDER BY Id DESC)),
IPV_Physically_Hurt = (SELECT ItemName FROM LookupItemView WHERE MasterName ='YesNo' AND ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'PnsPhysicallyHurt') ORDER BY Id DESC)),
IPV_Threatened_Hurt = (SELECT ItemName FROM LookupItemView WHERE MasterName ='YesNo' AND ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'PnsThreatenedHurt') ORDER BY Id DESC)),
IPV_Sexual_Hurt = (SELECT ItemName FROM LookupItemView WHERE MasterName ='YesNo' AND ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'PnsForcedSexual') ORDER BY Id DESC)),
IPV_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'IPVOutcome') ORDER BY Id DESC)),
HIV_Status = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'HIVStatus') ORDER BY Id DESC)),
PNS_Approach = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = (SELECT TOP 1 ScreeningValueId FROM PatientScreening WHERE PatientId = PT.Id AND ScreeningTypeId = (SELECT TOP 1 MasterId FROM LookupItemView WHERE MasterName = 'PnsScreening') AND ScreeningCategoryId=(SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'PnsScreening' AND ItemName = 'PNSApproach') ORDER BY Id DESC)),
DateTracingDone = (select top 1 DateTracingDone from Tracing where PersonId = PR.PersonId AND TracingType = (select ItemId from LookupItemView where MasterName = 'TracingType' and ItemName = 'Partner')),
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE MasterName = 'TracingMode' AND ItemId = (select top 1 Mode from Tracing where PersonId = PR.PersonId AND TracingType = (select ItemId from LookupItemView where MasterName = 'TracingType' and ItemName = 'Partner'))),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE MasterName = 'PnsTracingOutcome' AND ItemId = (select top 1 Outcome from Tracing where PersonId = PR.PersonId AND TracingType = (select ItemId from LookupItemView where MasterName = 'TracingType' and ItemName = 'Partner'))),
Reason_uncontacted = NULL,
Booking_Date = (select top 1 DateBookedTesting from Tracing where PersonId = PR.PersonId AND TracingType = (select ItemId from LookupItemView where MasterName = 'TracingType' and ItemName = 'Partner')),
Consent_For_Testing = (SELECT ItemName FROM LookupItemView WHERE MasterName = 'YesNo' AND ItemId = (select top 1 Consent from Tracing where PersonId = PR.PersonId AND TracingType = (select ItemId from LookupItemView where MasterName = 'TracingType' and ItemName = 'Partner'))),
Date_Reminded = NULL,
NULL Voided

FROM [dbo].[PersonRelationship] PR
LEFT JOIN dbo.Patient AS PT ON PT.Id = PR.PatientId
INNER JOIN HtsEncounter HE ON HE.PersonId = PT.PersonId
LEFT JOIN [dbo].[Person] P ON P.Id = PR.PersonId
ORDER BY PT.Id ASC