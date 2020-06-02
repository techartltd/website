select
T.PersonID as Person_Id,
prel.Relationship,
ind.PersonId as Index_PersonId,
Encounter_Date = T.DateTracingDone,
Encounter_ID = NULL,
Contact_Type = (SELECT top 1 ItemName FROM LookupItemView WHERE ItemId=T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT top 1 ItemName FROM LookupItemView WHERE ItemId=T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT top 1 ItemName FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
T.OtherReasonSpecify,
T.Remarks,
T.DeleteFlag Voided,
T.CreatedBy,
T.CreateDate

 from(select re.PersonId,re.PatientId,re.FinalResult from (SELECT pe.PatientEncounterId,pe.PatientMasterVisitId,pe.PatientId,pe.PersonId,pe.FinalResult,ROW_NUMBER() OVER(
 partition by pe.PatientId  order by pe.PatientMasterVisitId desc)rownum
  from(SELECT DISTINCT
PE.Id PatientEncounterId,
PE.PatientMasterVisitId,
PE.PatientId PatientId,
HE.PersonId,
ResultOne = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = (SELECT TOP 1 RoundOneTestResult FROM [dbo].[HtsEncounterResult] WHERE HtsEncounterId = HE.Id ORDER BY Id DESC)),
ResultTwo = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = (SELECT TOP 1 RoundTwoTestResult FROM [dbo].[HtsEncounterResult] WHERE HtsEncounterId = HE.Id ORDER BY Id DESC)),
FinalResult = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = (SELECT TOP 1 FinalResult FROM [dbo].[HtsEncounterResult] WHERE HtsEncounterId = HE.Id ORDER BY Id DESC)),
FinalResultGiven = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = HE.FinalResultGiven)

FROM [dbo].[PatientEncounter] PE
INNER JOIN [dbo].[PatientMasterVisit] PM ON PM.Id = PE.PatientMasterVisitId
INNER JOIN [dbo].[HtsEncounter] HE ON PE.Id = HE.PatientEncounterID
)pe where pe.FinalResult='Positive'


) re where re.rownum=1 )ind 
inner join(
select  pr.PersonId as RelativePersonId,pr.RelationshipTypeId,r.[itemName] as Relationship,
pr.PatientId as IndexPatientId ,p.PersonId as IndexPersonId from PersonRelationship pr
left join Patient p on p.Id=pr.PatientId
inner join (SELECT  *  FROM LookupItemView  where MasterName = 'Relationship')
r on r.ItemId=pr.RelationshipTypeId
where r.ItemName in ('Co-Wife','Partner','Spouse'))prel 
on prel.IndexPersonId=ind.PersonId and prel.IndexPatientId=ind.PatientId
inner join  Tracing T on T.PersonID=prel.RelativePersonId