exec pr_OpenDecryptedSession;
select distinct  p.PersonId as Person_Id,
pr.PersonId as Relative_Person_Id,
pr.CreateDate as Encounter_Date,
NULL as Encounter_ID,
(CAST(DECRYPTBYKEY(pre.FirstName) AS VARCHAR(50)) + '' + CAST(DECRYPTBYKEY(pre.MidName) AS VARCHAR(50)) +  '' + CAST(DECRYPTBYKEY(pre.LastName ) AS VARCHAR(50))) as [Name],
CAST(DECRYPTBYKEY(pre.FirstName) AS VARCHAR(50)) AS RelativeFirst_Name,
CAST(DECRYPTBYKEY(pre.MidName) AS VARCHAR(50)) AS  RelativeMiddle_Name,
CAST(DECRYPTBYKEY(pre.LastName ) AS VARCHAR(50)) AS RelativeLast_Name,
pre.DateOfBirth as DOB,
DATEDIFF(hour,pre.DateOfBirth,GETDATE())/8766 as Age,
NULL as Age_unit,
(Select Top 1	[Name] From LookupItem LI	Where LI.Id = pr.RelationshipTypeId) Relationship,
(select top 1 [Name] from LookupItem li where li.Id=pr.BaselineResult) as   BaselineResult,
re.FinalResult as  Hiv_status,
CASE when pcc.IdentifierValue is not null then 'Yes' else 'No' end as In_Care,
plink.CCCNumber as Linkage_CCC_Number,
pcc.IdentifierValue as CCCNumber,
pr.DeleteFlag
 from Patient P
 inner join PersonRelationship pr on pr.PatientId=p.Id

left join Person pre on pre.Id=pr.PersonId
 left join PatientLinkage plink on plink.PersonId=pr.PersonId
 left join(  select pcc.PatientId,pcc.IdentifierValue,pcc.PersonId from( select pid.PatientId,p.PersonId,pid.PatientEnrollmentId,ROW_NUMBER() OVER(partition by pid.PatientId order by pid.PatientEnrollmentId desc)rownum,pid.IdentifierTypeId,pid.IdentifierValue,id.Code
    from PatientIdentifier pid
	inner join Patient p on p.Id=pid.PatientId
	inner join Identifiers id on id.Id=pid.IdentifierTypeId
	where id.Code='CCCNumber' and (pid.DeleteFlag is not null or pid.DeleteFlag='0'))
	pcc where pcc.rownum='1'
	)pcc on pcc.PersonId=pr.PersonId
 left join (select re.PersonId,re.PatientId,re.FinalResult from (SELECT pe.PatientEncounterId,pe.PatientMasterVisitId,pe.PatientId,pe.PersonId,pe.FinalResult,ROW_NUMBER() OVER(
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
)pe where pe.FinalResult is not null


) re where re.rownum=1)re on re.PersonId=pr.PersonId

