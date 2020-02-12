-- 1. Demographics/Registration  DML
exec pr_OpenDecryptedSession;
SELECT
P.Id Person_Id, 
PT.Id Patient_Id,
CAST(DECRYPTBYKEY(P.FirstName) AS VARCHAR(50)) AS FirstName,
CAST(DECRYPTBYKEY(P.MidName) AS VARCHAR(50)) AS MiddleName,
CAST(DECRYPTBYKEY(P.LastName) AS VARCHAR(50)) AS LastName,
CAST(DECRYPTBYKEY(P.NickName) AS VARCHAR(50)) AS Nickname,
format(cast(ISNULL(P.DateOfBirth, PT.DateOfBirth) as date),'yyyy-MM-dd') AS DOB,
CASE(ISNULL(P.DobPrecision, PT.DobPrecision))
	WHEN 0 THEN 'EXACT'
	WHEN 1 THEN 'ESTIMATED'
	ELSE 'ESTIMATED' END AS Exact_DOB,
Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else ItemName end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = P.Sex),
UPN = (SELECT IdentifierValue FROM PatientEnrollment PTE INNER JOIN PatientIdentifier PIE ON PIE.PatientEnrollmentId = PTE.Id WHERE PTE.ServiceAreaId = 1 AND PIE.IdentifierTypeId = 1 AND PIE.DeleteFlag = 0 AND PTE.DeleteFlag = 0 AND PTE.PatientId = PT.Id AND PIE.PatientId = PT.Id),
format(cast(ISNULL(P.RegistrationDate, PT.RegistrationDate) as date),'yyyy-MM-dd') AS Encounter_Date,
NULL Encounter_ID,
(CASE(Select t.IdentifierValue from (select PIR.IdentifierValue from PersonIdentifier PIR
INNER JOIN Identifiers IDE ON IDE.Id = PIR.IdentifierId
WHERE IDE.Name = 'NationalID' AND PIR.PersonId = P.Id) t)
WHEN NULL THEN PT.NationalId
ELSE (Select t.IdentifierValue from (select PIR.IdentifierValue from PersonIdentifier PIR
INNER JOIN Identifiers IDE ON IDE.Id = PIR.IdentifierId
WHERE IDE.Name = 'NationalID' AND PIR.PersonId = P.Id) t) END) AS National_id_No,
(SELECT PatientClinicID FROM mst_Patient MSP WHERE MSP.Ptn_Pk = PT.ptn_pk) AS Patient_clinic_number,
Birth_certificate=(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = P.Id and pdd.[Name]='BirthCertificate' and pdd.DeleteFlag=0 order by pdd.CreateDate desc),
Birth_notification=(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = P.Id and pdd.[Name]='BirthNotification' and pdd.DeleteFlag=0 order by pdd.CreateDate desc),
Hei_no=(select top 1 pdd.IdentifierValue from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  ) pdd where pdd.PatientId = PT.Id and pdd.[Code]='HEIRegistration' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
Passport=(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = P.Id and pdd.[Name]='Passport' and pdd.DeleteFlag=0 order by pdd.CreateDate desc),
Alien_Registration=(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = P.Id and pdd.[Name]='AlienRegistration' and pdd.DeleteFlag=0 order by pdd.CreateDate desc),
CAST(DECRYPTBYKEY((SELECT TOP 1 PC.MobileNumber FROM PersonContact PC WHERE PC.DeleteFlag = 0 AND PC.PersonId = P.Id ORDER BY Id DESC)) AS VARCHAR(50)) AS Phone_number,
CAST(DECRYPTBYKEY((SELECT TOP 1 PC.AlternativeNumber FROM PersonContact PC WHERE PC.DeleteFlag = 0 AND PC.PersonId = P.Id ORDER BY Id DESC)) AS VARCHAR(50)) Alternate_Phone_number,
CAST(DECRYPTBYKEY((SELECT TOP 1 PC.PhysicalAddress FROM PersonContact PC WHERE PC.DeleteFlag = 0 AND PC.PersonId = P.Id ORDER BY Id DESC)) AS VARCHAR(50)) Postal_Address,
CAST(DECRYPTBYKEY((SELECT TOP 1 PC.EmailAddress FROM PersonContact PC WHERE PC.DeleteFlag = 0 AND PC.PersonId = P.Id ORDER BY Id DESC)) AS VARCHAR(50)) Email_address,
County = (select TOP 1 C.CountyName from PersonLocation PL INNER JOIN County C ON C.CountyId = PL.County WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Sub_county = (select TOP 1 C.Subcountyname from PersonLocation PL INNER JOIN County C ON C.SubcountyId = PL.SubCounty WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Ward = (select TOP 1 C.WardName from PersonLocation PL INNER JOIN County C ON C.WardId = PL.Ward WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Village = (select TOP 1 PL.Village from PersonLocation PL WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Landmark = (select TOP 1 PL.LandMark from PersonLocation PL WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Nearest_Health_Centre = (select TOP 1 PL.NearestHealthCentre from PersonLocation PL WHERE PL.PersonId = P.Id AND PL.DeleteFlag = 0 ORDER BY PL.Id DESC),
Marital_status = (SELECT TOP 1 ItemName FROM PatientMaritalStatus PM INNER JOIN LookupItemView LK ON LK.ItemId = PM.MaritalStatusId WHERE PM.PersonId = P.Id AND PM.DeleteFlag = 0 AND LK.MasterName = 'MaritalStatus'),
Occupation = (SELECT TOP 1 ItemName FROM PersonOccupation PO INNER JOIN LookupItemView LK ON LK.ItemId = PO.Occupation WHERE PO.PersonId = P.Id AND MasterName = 'Occupation' AND PO.DeleteFlag = 0 ORDER BY Id DESC),
Education_level = (SELECT TOP 1 ItemName FROM PersonEducation EL INNER JOIN LookupItemView LK ON LK.ItemId = EL.EducationLevel WHERE EL.PersonId = P.Id and MasterName = 'EducationalLevel' AND EL.DeleteFlag = 0 ORDER BY Id DESC),
Dead = (SELECT top 1  'Yes' FROM PatientCareending WHERE DeleteFlag = 0 AND ExitReason = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death') AND PatientId = PT.Id AND DateOfDeath IS NOT NULL ORDER BY Id DESC),
Death_date = (SELECT TOP 1 DateOfDeath FROM PatientCareending WHERE DeleteFlag = 0 AND ExitReason = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death') AND PatientId = PT.Id AND DateOfDeath IS NOT NULL ORDER BY Id DESC),
PT.DeleteFlag AS voided 


FROM Person P
LEFT JOIN Patient PT ON PT.PersonId = P.Id
ORDER BY P.Id ASC