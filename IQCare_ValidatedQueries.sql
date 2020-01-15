--1. Demographics
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


--2. HIV ENROLLMENT. Careful thought on this on
/*SELECT
PT.Id PatientId,
PT.PersonId Person_Id,
Patient_Type = (SELECT ItemName FROM LookupItemView LK WHERE LK.ItemId = PT.PatientType AND LK.MasterName = 'PatientType'),
Entry_point = (SELECT TOP 1 LK.ItemName FROM ServiceEntryPoint SE INNER JOIN LookupItemView LK ON LK.ItemId = EntryPointId WHERE SE.PatientId = PT.Id AND ServiceAreaId = 1 ORDER BY SE.Id DESC),
TI_Facility = (select FacilityFrom from PatientTransferIn PTI WHERE PTI.PatientId = PT.Id),
CASE (SELECT ItemName FROM LookupItemView LK WHERE LK.ItemId = PT.PatientType AND LK.MasterName = 'PatientType')
WHEN 'New' THEN PE.EnrollmentDate
WHEN 'Transit' THEN PE.EnrollmentDate
WHEN 'Transfer-In' THEN (SELECT TOP 1 EnrollmentDate from PatientHivDiagnosis PHD WHERE PHD.PatientId = PT.Id AND PHD.DeleteFlag = 0 ORDER BY Id DESC)
ELSE PE.EnrollmentDate END AS Date_First_enrolled_in_care,
CASE (SELECT ItemName FROM LookupItemView LK WHERE LK.ItemId = PT.PatientType AND LK.MasterName = 'PatientType')
WHEN 'New' THEN NULL
WHEN 'Transit' THEN NULL
WHEN 'Transfer-In' THEN (select TransferInDate from PatientTransferIn PTI WHERE PTI.PatientId = PT.Id AND PTI.DeleteFlag = 0)
ELSE NULL END AS Transfer_In_Date,
CASE (SELECT ItemName FROM LookupItemView LK WHERE LK.ItemId = PT.PatientType AND LK.MasterName = 'PatientType')
WHEN 'New' THEN NULL
WHEN 'Transit' THEN NULL
WHEN 'Transfer-In' THEN (select TreatmentStartDate from PatientTransferIn PTI WHERE PTI.PatientId = PT.Id AND PTI.DeleteFlag = 0)
ELSE NULL END AS Date_started_art_at_transferring_facility,


PT.DeleteFlag Voided


FROM Patient PT
INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
WHERE PE.ServiceAreaId = 1;*/

--3 Triage
SELECT 
P.PersonId Person_Id,
P.Id Patient_Id,
Encounter_Date = format(cast(PM.VisitDate as date),'yyyy-MM-dd'),
Encounter_ID = PM.Id,
Visit_reason = NULL,
Systolic_pressure = CAST(PV.BPSystolic AS decimal),
Diastolic_pressure = CAST(PV.BPDiastolic AS decimal),
Respiratory_rate = PV.RespiratoryRate,
Pulse_rate = PV.HeartRate,
Oxygen_saturation = PV.SpO2,
Weight = PV.Weight,
Height = PV.Height,
Temperature = PV.Temperature,
BMI = PV.BMI,
Muac = PV.Muac,
Weight_for_age_zscore = PV.WeightForAge,
Weight_for_height_zscore = PV.WeightForHeight,
BMI_Zscore = PV.BMIZ,
Head_circumference = PV.HeadCircumference,
NUll as Nutritional_status,
format(cast(PIR.LMP as date),'yyyy-MM-dd') as Last_menstrual_period,
CAST(PV.NursesComments AS varchar(MAX)) as Nurse_Comments,
PV.DeleteFlag as Voided

FROM [dbo].[PatientVitals] PV
INNER JOIN Patient P ON P.Id = PV.PatientId
INNER JOIN PatientMasterVisit PM ON PM.Id = PV.PatientMasterVisitId
LEFT JOIN PregnancyIndicator PIR ON PIR.PatientMasterVisitId = PM.Id
UNION
SELECT
Person_Id = P.PersonId,
P.Id Patient_Id,
Encounter_Date = format(cast(OV.VisitDate as date),'yyyy-MM-dd'),
Encounter_ID = OV.Visit_Id,
Visit_reason = NULL,
Systolic_pressure = DPV.BPSystolic,
Diastolic_pressure = DPV.BPDiastolic,
Respiratory_rate = NULL,
Pulse_rate = NULL,
Oxygen_saturation = DPV.SP02,
Weight = DPV.Weight,
Height = DPV.Height,
Temperature = DPV.Temp,
BMI = NULL,
Muac = DPV.Muac,
Weight_for_age_zscore = NULL,
Weight_for_height_zscore = NULL,
BMI_Zscore = NULL,
Head_circumference = NULL,
NUll as Nutritional_status,
format(cast(PCS.LMP as date),'yyyy-MM-dd') as Last_menstrual_period,
NULL as Nurse_Comments,
0 as Voided

FROM dtl_PatientVitals DPV
inner join Patient P on p.ptn_pk = DPV.Ptn_pk
inner join ord_Visit OV ON OV.Visit_Id = DPV.Visit_pk
inner join dtl_PatientClinicalStatus PCS ON PCS.Visit_pk = OV.Visit_Id;

-- KEY POPULATION
SELECT 
PersonId Person_Id,
Pop_Type = PopulationType,
Key_Pop_Type = (SELECT ItemName FROM LookupItemView LK WHERE LK.ItemId = PopulationCategory AND MasterName = 'KeyPopulation'),
Voided = DeleteFlag

FROM [dbo].[PatientPopulation]

-- DISABILITIES
SELECT 
PersonId Person_Id,
Encounter_ID = PatientEncounterID,
Disability = (SELECT * FROM LookupItemView WHERE MasterName = 'Disabilities'),
Voided  = DeleteFlag

FROM ClientDisability

-- 4. HTS Initial Encounter


---5.Laboratory
select p.PersonId as Person_Id 
,v.VisitDate as Encounter_Date,
NULL as Encounter_ID,
vlw.LabTestName as Lab_Test,
NULL as Urgency, 
COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText) as  Test_Result,
plo.OrderDate as Date_test_Requested,
OT.ResultDate as Date_test_result_received,
u.UserFirstName + ' ' + u.UserLastName as Test_Requested_By,
plo.PreClinicLabDate,
plo.ClinicalOrderNotes,
plo.OrderNumber,
plo.CreateDate,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=plo.CreatedBy) 
as CreatedBy,
plo.OrderStatus,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=plo.DeletedBy) as DeletedBy ,
plo.DeleteDate,
plo.DeleteReason,
 plo.DeleteFlag as Voided,
 OT.ResultStatus,
 OT.StatusDate,
 COALESCE(cast(r.ResultValue as varchar(max)),r.ResultText) as LabResult,
 r.ResultValue,
 r.ResultText,
 r.ResultOption,
 r.Undetectable,
 r.DetectionLimit,
 r.ResultUnit,
 r.HasResult,
 vlw.LabTestName,
 vlw.ParameterName,
 vlw.LabDepartmentName

from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
inner join Patient  p on p.ptn_pk=plo.Ptn_Pk
inner join ord_Visit v on v.Visit_Id=plo.VisitId
left join mst_User u on u.UserID=plo.OrderedBy
left join (Select	P.Id	ParameterId
			,P.ParameterName
			,P.ReferenceId ParameterReferenceId
			,T.Id	LabTestId
			,T.Name	LabTestName
			,T.ReferenceId TestReferenceId
			,T.IsGroup
			,T.DepartmentId
			,D.LabDepartmentName
			, T.DeleteFlag TestDeleteFlag
			,T.Active TestActive
			,P.DeleteFlag ParameterDeleteFlag
	From mst_LabTestMaster T
	Inner Join Mst_LabTestParameter P On T.Id = P.LabTestId
	Left Outer Join mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID)
	vlw on vlw.ParameterId=r.ParameterId





 
