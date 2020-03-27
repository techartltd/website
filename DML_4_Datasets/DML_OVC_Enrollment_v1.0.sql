select ovf.PersonId as Person_Id,ovf.EnrollmentDate as Encounter_Date,
NULL as Encounter_Id,
pr.Caregiver_enrolled_here as Caregiver_enrolled_here,
pr.FirstName +  ' ' + pr.LastName as Caregiver_name,
pr.Gender,
pr.RelationshipType,
pr.Phonenumber as Caregiver_Phone_Number,
(select top 1  lt.[Name] from LookupItem  lt where lt.Id=ovf.CPMISEnrolled) as Client_Enrolled_cpims,
ovf.PartnerOVCServices,
ovf.CreatedBy created_by,
cast(ovf.CreateDate as date) created_at
  from OvcEnrollmentForm ovf
  left join (select * from(SELECT
	ISNULL(ROW_NUMBER() OVER(ORDER BY PR.Id ASC), -1) AS RowID,
	PR.PersonId,
	PR.PatientId,
	CAST(DECRYPTBYKEY(P.[FirstName]) AS VARCHAR(50)) AS [FirstName],
	CAST(DECRYPTBYKEY(P.[MidName]) AS VARCHAR(50)) AS [MidName],
	CAST(DECRYPTBYKEY(P.[LastName]) AS VARCHAR(50)) AS [LastName],
	CAST(DECRYPTBYKEY(pcc.MobileNumber)AS VARCHAR(100)) as Phonenumber,
	P.DateOfBirth,
	P.Sex,
	Gender = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = P.Sex AND MasterName = 'Gender'),
	PR.RelationshipTypeId,
	RelationshipType = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PR.RelationshipTypeId AND MasterName = 'CaregiverRelationship'),
	ROW_NUMBER() OVER(Partition by PR.PersonId order by PR.CreateDate desc)rownum,
	CASE WHEN pii.IdentifierValue is not null then  'Yes' end as Caregiver_enrolled_here
FROM [dbo].[PersonRelationship] PR

INNER JOIN dbo.Patient AS PT ON PT.Id = PR.PatientId
INNER JOIN [dbo].[Person] P ON P.Id = PR.PersonId
left join  Patient ptr on ptr.PersonId=P.Id
left join (select * from (select  pc.PersonId,pc.MobileNumber,pc.DeleteFlag,ROW_NUMBER() OVER(partition by pc.PersonId order by pc.CreateDate desc)rownum  from PersonContact pc 
where pc.DeleteFlag is null or pc.DeleteFlag =0
)ptc where ptc.rownum='1')pcc on pcc.PersonId=P.Id
left join (select 
pii.PatientId,pii.IdentifierValue
 from (select pii.PatientId,pii.IdentifierValue,pii.CreateDate,pii.DeleteFlag,pii.IdentifierTypeId,
ROW_NUMBER() OVER(partition by pii.PatientId order by pii.CreateDate desc)rownum
 from PatientIdentifier pii
left join Identifiers i  on i.Id=pii.IdentifierTypeId 
where i.Code='CCCNumber') pii where pii.rownum='1')pii on pii.PatientId=ptr.Id
where PR.DeleteFlag=0 or PR.DeleteFlag is null
)tr where tr.rownum='1' )pr on pr.PatientId=OVF.Id