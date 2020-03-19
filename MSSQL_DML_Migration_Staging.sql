-- DML TO RUN FROM MSSQL DBMS
-- Populates RAW Data to Mysql linked/staging database already created 
-- Run Second
-- Staging Database Scripts to populate DDL scripts created from MySQL 
-- Staging Database Scripts to RUN after running the DDLs in Mysql
-- 1. Demographics/Registration  DML

exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id, Patient_Id, First_Name, Middle_Name, Last_Name, Nickname, DOB, Exact_DOB, Sex, UPN, Encounter_Date, Encounter_ID, National_id_no, Patient_clinic_number
, Birth_certificate, Birth_notification, Hei_no, Passport, Alien_Registration, Phone_number, Alternate_Phone_number,
Postal_Address,Email_Address, County, Sub_county, Ward,Village, Landmark, Nearest_Health_Centre, Next_of_kin, Next_of_kin_phone, Next_of_kin_relationship
, Next_of_kin_address, Marital_Status, Occupation, Education_level, Dead, Death_date, Consent, Consent_decline_reason, voided FROM migration_st.st_demographics')

exec pr_OpenDecryptedSession;
SELECT
P.Id Person_Id, 
CAST(DECRYPTBYKEY(P.FirstName) AS VARCHAR(50)) AS First_Name,
CAST(DECRYPTBYKEY(P.MidName) AS VARCHAR(50)) AS Middle_Name,
CAST(DECRYPTBYKEY(P.LastName) AS VARCHAR(50)) AS Last_Name,
CAST(DECRYPTBYKEY(P.NickName) AS VARCHAR(50)) AS Nickname,
format(cast(ISNULL(P.DateOfBirth, PT.DateOfBirth) as date),'yyyy-MM-dd') AS DOB,
CASE(ISNULL(P.DobPrecision, PT.DobPrecision))
	WHEN 0 THEN 'EXACT'
	WHEN 1 THEN 'ESTIMATED'
	ELSE 'ESTIMATED' END AS Exact_DOB,
Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else ItemName end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = P.Sex),
UPN = (SELECT Top 1 IdentifierValue FROM PatientEnrollment PTE INNER JOIN PatientIdentifier PIE ON PIE.PatientEnrollmentId = PTE.Id WHERE PTE.ServiceAreaId = 1 AND PIE.IdentifierTypeId = 1 AND PIE.DeleteFlag = 0 AND PTE.DeleteFlag = 0 AND PTE.PatientId = PT.Id AND PIE.PatientId = PT.Id),
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
ts.Next_of_kin as Next_of_kin,
 ts.Next_of_kin_phone as  Next_of_kin_phone,
ts.Next_of_kin_relationship as Next_of_kin_relationship,
ts.Next_of_kin_address as  Next_of_kin_address,
Marital_status = (SELECT TOP 1 ItemName FROM PatientMaritalStatus PM INNER JOIN LookupItemView LK ON LK.ItemId = PM.MaritalStatusId WHERE PM.PersonId = P.Id AND PM.DeleteFlag = 0 AND LK.MasterName = 'MaritalStatus'),
Occupation = (SELECT TOP 1 ItemName FROM PersonOccupation PO INNER JOIN LookupItemView LK ON LK.ItemId = PO.Occupation WHERE PO.PersonId = P.Id AND MasterName = 'Occupation' AND PO.DeleteFlag = 0 ORDER BY Id DESC),
Education_level = (SELECT TOP 1 ItemName FROM PersonEducation EL INNER JOIN LookupItemView LK ON LK.ItemId = EL.EducationLevel WHERE EL.PersonId = P.Id and MasterName = 'EducationalLevel' AND EL.DeleteFlag = 0 ORDER BY Id DESC),
Dead = (SELECT top 1  'Yes' FROM PatientCareending WHERE DeleteFlag = 0 AND ExitReason = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death') AND PatientId = PT.Id AND DateOfDeath IS NOT NULL ORDER BY Id DESC),
Death_date = (SELECT TOP 1 DateOfDeath FROM PatientCareending WHERE DeleteFlag = 0 AND ExitReason = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death') AND PatientId = PT.Id AND DateOfDeath IS NOT NULL ORDER BY Id DESC),
ts.Consent as Consent,
ts.Consent_Decline_Reason as Consent_Decline_Reason,
PT.DeleteFlag AS voided 

FROM Person P
LEFT JOIN Patient PT ON PT.PersonId = P.Id
LEFT JOIN  (select t.PersonId,t.SupporterId,t.Next_of_kin,t.Next_of_kin_phone,t.Next_of_kin_relationship,t.Next_of_kin_address,t.Consent,t.Consent_Decline_Reason from (select  pts.PersonId ,pts.SupporterId,(pt.FirstName + ' ' + pt.MiddleName + ' '  + pt.LastName) as Next_of_kin,pts.ContactCategory,pts.ContactRelationship,lts.DisplayName as Next_of_kin_relationship 
 ,pts.MobileContact as Next_of_kin_phone,pcv.PhysicalAddress as [Next_of_kin_address],pcc.Consent,pcc.Consent_Decline_Reason
,pts.CreateDate ,ROW_NUMBER() OVER(Partition by   pts.PersonId order by pts.CreateDate desc)rownum  from PatientTreatmentSupporter pts
inner join PersonView p  on pts.PersonId=p.Id
inner join PersonView pt on pt.Id=pts.SupporterId
inner join ( SELECT        Id, PersonId, CAST(DECRYPTBYKEY(PhysicalAddress) AS VARCHAR(50)) AS PhysicalAddress, CAST(DECRYPTBYKEY(MobileNumber) AS VARCHAR(50)) AS MobileNumber, 
                         CAST(DECRYPTBYKEY(AlternativeNumber) AS VARCHAR(50)) AS AlternativeNumber, CAST(DECRYPTBYKEY(EmailAddress) AS VARCHAR(50)) AS EmailAddress, Active, DeleteFlag, CreatedBy, CreateDate
FROM            dbo.PersonContact
)pcv on pcv.PersonId=pts.SupporterId
inner join LookupItemView lt on lt.ItemId=pts.ContactCategory and lt.MasterName='ContactCategory'
inner join LookupItemView lts on lts.ItemId=pts.ContactRelationship and lts.MasterName='KinRelationship'
left join(select pc.PatientId,pc.PersonId,pc.ConsentValue,lt.DisplayName as Consent,pc.[Comments] as [Consent_Decline_Reason] from PatientConsent pc
inner join LookupItem lt on lt.Id=pc.ConsentValue) pcc on pcc.PersonId=pts.SupporterId
where lt.ItemName  in ('NextofKin','EmergencyContact')) t where t.rownum='1'
)ts on ts.PersonId=P.Id
ORDER BY P.Id ASC


-- -----------------------------2. HIV Enrollment DML ---------------------------------------------
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id, UPN, Encounter_Date, Encounter_ID, Patient_Type,Entry_Point,TI_Facility,Date_first_enrolled_in_care,
Transfer_in_date,Date_started_art_at_transferring_facility,Date_confirmed_hiv_positive,
Facility_confirmed_hiv_positive,Baseline_arv_use,Purpose_of_baseline_arv_use,
Baseline_arv_regimen,Baseline_arv_regimen_line,
Baseline_arv_date_last_used,
Baseline_who_stage,
Baseline_cd4_results,
Baseline_cd4_date,
Baseline_vl_results,
Baseline_vl_date,
Baseline_vl_ldl_results,
Baseline_vl_ldl_date,
Baseline_HBV_Infected,
Baseline_TB_Infected,
Baseline_Pregnant,
Baseline_Breastfeeding,
Baseline_Weight,
Baseline_Height,
Baseline_BMI,
Name_of_treatment_supporter,
Relationship_of_treatment_supporter,
Treatment_supporter_telephone,
Treatment_supporter_address,
voided
 FROM migration_st.st_hiv_enrollment')

SELECT
  P.Id as Person_Id, 
 UPN =(select top 1 pdd.IdentifierValue from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  ) pdd where pdd.PatientId = PT.Id and pdd.[Code]='CCCNumber' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
  format(cast(PE.EnrollmentDate as date),'yyyy-MM-dd') AS Encounter_Date,
  NULL Encounter_ID,
  Patient_Type=(select itemName from LookupItemView where MasterName='PatientType' and itemId=PT.PatientType),
  ent.Entry_point, 
  pti.FacilityFrom AS TI_Facility,
  PE.EnrollmentDate as Date_First_enrolled_in_care,
  bas.TransferInDate as Transfer_In_Date,
  bas.ARTInitiationDate as Date_started_art_at_transferring_facility,
  bas.HIVDiagnosisDate as Date_Confirmed_hiv_positive,
  bas.FacilityFrom as Facility_confirmed_hiv_positive,
  bas.HistoryARTUse as Baseline_arv_use,
  parv.Purpose  as Purpose_of_Baseline_arv_use, 
  bas.CurrentTreatmentName as Baseline_arv_regimen,
  bas.RegimenName as Baseline_arv_regimen_line,
  parv.DateLastUsed as Baseline_arv_date_last_used,
  bas.EnrollmentWHOStageName as Baseline_who_stage,
  bas.CD4Count as Baseline_cd4_results,
  bas.EnrollmentDate as Baseline_cd4_date,
  bas.BaselineViralload as Baseline_vl_results,
  bas.BaselineViralloadDate as Baseline_vl_date,
  NULL as Baseline_vl_ldl_results,
  NULL as Baseline_vl_ldl_date,
  bas.HBVInfected  as Baseline_HBV_Infected,
  bas.TBinfected as Baseline_TB_Infected,
  bas.Pregnant as Baseline_Pregnant,
  bas.BreastFeeding as Baseline_BreastFeeding,
  bas.[Weight] as Baseline_Weight,
  bas.[Height] as Baseline_Height,
  bas.BMI as Baseline_BMI,
  treatmentl.Name_of_treatment_supporter,
  treatmentl.Relationship_of_treatment_supporter,
  treatmentl.Treatment_supporter_telephone,
  treatmentl.Treatment_supporter_address,  
  0 as Voided
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
  left JOIN (select * from (select  *,ROW_NUMBER() OVER(partition by PersonId order by CreateDate desc)rownum from PersonLocation where (DeleteFlag =0 or DeleteFlag is null))PLL where PLL.rownum='1') PL ON PL.PersonId = P.Id
  left  join (select ent.PatientId,ent.Entry_point from (select se.PatientId,se.EntryPointId,lt.DisplayName as Entry_point,ROW_NUMBER() OVER(partition
by se.PatientId order by CreateDate desc)rownum from ServiceEntryPoint  se
inner join LookupItem lt on lt.Id=se.EntryPointId
where se.DeleteFlag <> 1)ent where ent.rownum='1')ent on ent.PatientId=PT.Id
left join(select * from (select * ,ROW_NUMBER() OVER(partition by ph.PatientId order by PatientMasterVisitId desc)rownum
 from PatientARVHistory  ph)parv where parv.rownum=1)parv on parv.PatientId=PT.Id
  left join mst_Patient mst on mst.Ptn_Pk=PT.ptn_pk
  left join PatientTransferIn pti on pti.PatientId =PT.Id
  left join 
  (select pts.PersonId,pts.SupporterId,CAST(DECRYPTBYKEY(pts.MobileContact)AS VARCHAR(100)) as Treatment_supporter_telephone,
pt.FirstName + ' ' + pt.MiddleName + ' ' + pt.LastName as Name_of_treatment_supporter,
pcv.PhysicalAddress as Treatment_supporter_address ,rel.[Name]  as Relationship_of_treatment_supporter
 from PatientTreatmentSupporter pts
 left join Patient pat on pat.PersonId=pts.PersonId
left join PersonView pt on pt.Id=pts.SupporterId 
left join PersonContactView pcv on pcv.PersonId=pts.SupporterId
left join  LookupItem lt on lt.Id=pts.ContactCategory
left join PersonRelationship prl on prl.PersonId =pts.SupporterId and prl.PatientId =pat.Id
left join LookupItem rel on rel.Id=prl.RelationshipTypeId
where (lt.Name='TreatmentSupporter' or pts.ContactCategory=1))treatmentl on treatmentl.PersonId=P.Id
  left join (select * from(select * ,ROW_NUMBER() OVER(partition by PatientId order by PatientMasterVisitId)rownum from PatientBaselineView)rte
where rte.rownum=1) bas on bas.PatientId=PT.Id


  LEFT OUTER JOIN (
                    SELECT
                      PatientId,
                      ExitReason,
                      ExitDate
                    FROM dbo.PatientCareending where deleteflag=0
                    UNION
                    SELECT dbo.Patient.Id AS PatientId
                      ,CASE (SELECT TOP 1 Name FROM mst_Decode WHERE CodeID=23 AND ID = (SELECT TOP 1 PatientExitReason FROM dtl_PatientCareEnded WHERE Ptn_Pk = dbo.Patient.ptn_pk AND CareEnded=1))
                       WHEN 'Lost to follow-up'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'LostToFollowUp')
                       WHEN 'HIV Negative'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'HIV Negative')
                       WHEN 'Death'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death')
                       WHEN 'Confirmed HIV Negative'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Confirmed HIV Negative')
                       WHEN 'Transfer to ART'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       WHEN 'Transfer to another LPTF'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       WHEN 'Discharged at 18 months'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Confirmed HIV Negative')
                       WHEN 'Transfered out'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       END AS ExitReason,
                      CareEndedDate
                    FROM dbo.dtl_PatientCareEnded
                      INNER JOIN dbo.Patient ON dbo.dtl_PatientCareEnded.Ptn_Pk = dbo.Patient.ptn_pk
                    WHERE dbo.Patient.Id NOT IN (SELECT PatientId FROM dbo.PatientCareending where deleteflag=0)
                  ) AS ptC ON PT.Id = ptC.PatientId
WHERE

 PE.ServiceAreaId=1 

-- 3. Triage Encounter 
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id, Encounter_Date, Visit_reason, Systolic_pressure, Diastolic_pressure
,Respiratory_rate, Pulse_rate, Oxygen_saturation, Weight, Height, Temperature, BMI, Muac, Weight_for_age_zscore
,Weight_for_height_zscore, BMI_Zscore, Head_Circumference, Nutritional_status, Last_menstrual_period, Nurse_comments, Voided FROM migration_st.st_triage')
SELECT
  P.Id,  
  format(cast(PM.VisitDate as date),'yyyy-MM-dd') AS Encounter_Date,
  NULL Visit_reason,
  PV.BPSystolic as Systolic_pressure,
  PV.BPDiastolic as Diastolic_pressure,
  PV.RespiratoryRate,
  PV.HeartRate as Pulse_rate,
  PV.SpO2 as Oxygen_saturation,
  Weight = PV.Weight,
  PV.Height,
  PV.Temperature, 
  PV.BMI as BMI,
  PV.Muac as Muac,
  PV.WeightForAge as Weight_for_age_zscore,
  PV.WeightForHeight as Weight_for_height_zscore,
  PV.BMIZ as BMI_Zscore,
  PV.HeadCircumference as Head_Circumference,
  NUll as Nutritional_status,
  lmp.LMP as Last_menstrual_period,
  NUll as Nurse_Comments,
  PV.DeleteFlag as Voided
FROM Person P
  INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientVitals PV ON PV.PatientId = PT.Id
  INNER JOIN PatientMasterVisit PM ON PM.PatientId = PT.Id
  INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
  INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id AND PI.PatientEnrollmentId = PE.Id
  INNER JOIN Identifiers I on PI.IdentifierTypeId=I.Id
  LEFT JOIN (select lm.PatientId,lm.LMP  from(select pid.PatientId,pid.PatientMasterVisitId,pid.LMP,ROW_NUMBER() OVER(Partition by pid.PatientId order by pid.PatientMasterVisitId desc)rownum
 from PregnancyIndicator pid
 where pid.LMP is not null)lm where lm.rownum='1') lmp on lmp.PatientId =PT.Id

-- order by First_Name

-- 4. HTS Initial Test
exec pr_OpenDecryptedSession;
insert into OpenQuery(IQCare_OPENMRS,'Select Person_Id,Encounter_Date,Encounter_ID,Pop_Type,Key_Pop_Type,
  Priority_Pop_Type,Patient_disabled,Disability,
Ever_Tested,Self_Tested,HTS_Strategy,HTS_Entry_Point,
Consented,Tested_As,TestType,Test_1_Kit_Name,Test_1_Lot_Number,Test_1_Expiry_Date,Test_1_Final_Result,
Test_2_Kit_Name,Test_2_Lot_Number,Test_2_Expiry_Date,Test_2_Final_Result,Final_Result,Result_given,Couple_Discordant,Tb_Screening_Results,Remarks,Voided from migration_st.st_hts_initial')

select P.Id as Person_Id,  
  hr.VisitDate as Encounter_Date,
  NULL Encounter_ID,
  PopType.PopulationType as Pop_Type,
  kpop.Population_Type as Key_Pop_Type ,
  prio.Population_Type as Priority_Pop_Type,
  Patient_disabled = (SELECT (case when hr.Disability != '' then 'Yes' else 'No' end)),
  hr.Disability,
  hr.TestedBefore as Ever_Tested,
  hr.clientSelfTestesd as Self_Tested,
  hr.StrategyHTS as HTS_Strategy,
  hr.[TestEntryPoint] as HTS_Entry_Point,
  hr.Consent as Consented,
  hr.ClientTestedAs as TestedAs,
  hr.TestType,
  hr.TestKitName1 as Test_1_Kit_Name,
  hr.TestKitLotNumber1 as Test_1_Lot_Number,
  hr.TestKitExpiryDate1 as Test_1_Expiry_Date,
  hr.FinalTestOneResult as Test_1_Final_Result,
  hr.TestKitName_2 as Test_2_Kit_Name,
  hr.TestKitLotNumber_2 as Test_2_Lot_Number,
  hr.TestKitExpiryDate_2 as Test_2_Expiry_Date,
  hr.FinalResultTestTwo as Test_2_Final_Result,
  hr.finalResultHTS as Final_Result,
  hr.FinalResultsGiven as Result_given,
  hr.CoupleDiscordant as Couple_Discordant,
  hr.TBScreeningHTS as TB_SCreening_Results,
  hr.Remarks as Remarks, 
  0 as Voided
 from HTS_LAB_Register hr
inner join Patient pat on pat.Id=hr.PatientID
inner join Person P on P.Id=pat.PersonId
 INNER JOIN PatientIdentifier PI ON PI.PatientId = hr.PatientID
left join(
select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)
and pp.PopulationType ='Key Population'
)t where rownum='1')kpop on kpop.PersonId=P.Id
left join(select pr.PersonId,pr.PopulationType,pr.Population_Type,pr.CreateDate from (select pr.Id,pr.PersonId,pr.PriorityId as PopulationCategory,
(select DisplayName from  LookupMaster where Name = 'PriorityPopulation') as PopulationType ,
(select l.DisplayName from LookupItem l where l.Id=pr.PriorityId) as Population_Type,pr.CreateDate,
ROW_NUMBER() OVER(partition
by pr.PersonId order by pr.CreateDate desc) rownum
from PersonPriority pr
)pr where rownum='1'
)prio on prio.PersonId=P.Id
left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)

)t where rownum='1')PopType on PopType.PersonId=P.Id
where (hr.TestType= 'Initial Test' or hr.TestType='Initial')


-- 5. HTS Retest Test
exec pr_OpenDecryptedSession;
insert into OpenQuery(IQCare_OPENMRS,'Select Person_Id,Encounter_Date,Encounter_ID,Pop_Type,Key_Pop_Type,
  Priority_Pop_Type,Patient_disabled,Disability,
Ever_Tested,Self_Tested,HTS_Strategy,HTS_Entry_Point,
Consented,Tested_As,TestType,Test_1_Kit_Name,Test_1_Lot_Number,Test_1_Expiry_Date,Test_1_Final_Result,
Test_2_Kit_Name,Test_2_Lot_Number,Test_2_Expiry_Date,Test_2_Final_Result,Final_Result,Result_given,Couple_Discordant,Tb_Screening_Results,Remarks,Voided from migration_st.st_hts_retest')

select P.Id as Person_Id, 
  hr.VisitDate as Encounter_Date,
  NULL Encounter_ID,
  PopType.PopulationType as Pop_Type,
  kpop.Population_Type as Key_Pop_Type ,
  prio.Population_Type as Priority_Pop_Type,
  Patient_disabled = (SELECT (case when hr.Disability != '' then 'Yes' else 'No' end)),
  hr.Disability,
  hr.TestedBefore as Ever_Tested,
  hr.clientSelfTestesd as Self_Tested,
  hr.StrategyHTS as HTS_Strategy,
  hr.[TestEntryPoint] as HTS_Entry_Point,
  hr.Consent as Consented,
  hr.ClientTestedAs as TestedAs,
  hr.TestType,
  hr.TestKitName1 as Test_1_Kit_Name,
  hr.TestKitLotNumber1 as Test_1_Lot_Number,
  hr.TestKitExpiryDate1 as Test_1_Expiry_Date,
  hr.FinalTestOneResult as Test_1_Final_Result,
  hr.TestKitName_2 as Test_2_Kit_Name,
  hr.TestKitLotNumber_2 as Test_2_Lot_Number,
  hr.TestKitExpiryDate_2 as Test_2_Expiry_Date,
  hr.FinalResultTestTwo as Test_2_Final_Result,
  hr.finalResultHTS as Final_Result,
  hr.FinalResultsGiven as Result_given,
  hr.CoupleDiscordant as Couple_Discordant,
  hr.TBScreeningHTS as TB_SCreening_Results,
  hr.Remarks as Remarks, 
  0 as Voided
 from HTS_LAB_Register hr
inner join Patient pat on pat.Id=hr.PatientID
inner join Person P on P.Id=pat.PersonId
 INNER JOIN PatientIdentifier PI ON PI.PatientId = hr.PatientID
left join(
select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)
and pp.PopulationType ='Key Population'
)t where rownum='1')kpop on kpop.PersonId=P.Id
left join(select pr.PersonId,pr.PopulationType,pr.Population_Type,pr.CreateDate from (select pr.Id,pr.PersonId,pr.PriorityId as PopulationCategory,
(select DisplayName from  LookupMaster where Name = 'PriorityPopulation') as PopulationType ,
(select l.DisplayName from LookupItem l where l.Id=pr.PriorityId) as Population_Type,pr.CreateDate,
ROW_NUMBER() OVER(partition
by pr.PersonId order by pr.CreateDate desc) rownum
from PersonPriority pr
)pr where rownum='1'
)prio on prio.PersonId=P.Id
left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)

)t where rownum='1')PopType on PopType.PersonId=P.Id
where hr.TestType='Repeat Test'

-- 6. HTS Client Tracing

SELECT 
PersonID,
Encounter_Date = T.DateTracingDone,
Encounter_ID = T.Id,
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT ItemName FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
T.OtherReasonSpecify,
T.Remarks,
T.DeleteFlag Voided

FROM Tracing T

-- 7. HTS Client Referral

select r.PersonId,r.ReferralDate  as Encounter_Date,NULL Encounter_ID, CASE WHEN r.OtherFacility is not null then r.OtherFacility else fc.FacilityName  end as Facility_Referred,
r.ExpectedDate as Date_To_Be_Enrolled
 from Referral r
 left join mst_Facility fc on fc.PosID=r.ToFacility

-- 8. HTS Client Linkage

 select 
    pl.PersonId as Person_Id,
    pl.LinkageDate as Encounter_Date,
    NULL as Encounter_ID,
    pl.Facility as Facility_Linked,
    pl.CCCNumber as CCC_Number,
    pl.HealthWorker as Health_Worker_Handed_To,
    pl.Cadre,CASE WHEN pl.Enrolled ='1' then pl.LinkageDate end as Date_Enrolled,
    pl.ArtStartDate as ART_Start_Date ,
    pl.Comments as Remarks,
    pl.DeleteFlag as Voided
   from PatientLinkage pl


-- 9. HTS Contact Listing

--7 HTS Client Referral
select r.PersonId,r.ReferralDate  as Encounter_Date,NULL Encounter_ID, CASE WHEN r.OtherFacility is not null then r.OtherFacility else fc.FacilityName  end as Facility_Referred,
r.ExpectedDate as Date_To_Be_Enrolled
 from Referral r
 left join mst_Facility fc on fc.PosID=r.ToFacility

 --8-HTS Client Linkage
 select pl.PersonId,pl.LinkageDate as Encounter_Date
 ,NULL as Encounter_ID,pl.Facility as Facility_Linked,pl.CCCNumber as CCC_Number,
 pl.HealthWorker as Health_Worker_Handed_To,pl.Cadre,CASE WHEN pl.Enrolled ='1' then pl.LinkageDate end as Date_Enrolled,pl.ArtStartDate,pl.Comments as Remarks,pl.DeleteFlag as Voided
   from PatientLinkage pl



   --9 HTC Contact Listing
   exec pr_OpenDecryptedSession
  select distinct p.PersonId as Person_Id,
  patr.PersonId as Contact_Person_Id,patr.Encounter_Date,NULL as Encounter_ID,
  	CASE WHEN patr.PersonId is not null then  'YES' end as Consent,
  patr.FirstName as First_Name,patr.MidName as Middle_Name,patr.LastName as Last_Name,
  patr.Sex,patr.DateOfBirth as DoB
  ,patr.MaritalStatus as Marital_Status
  ,patr.PhysicalAddress as Physical_Address
  ,patr.PhoneNumber as Phone_Number
  ,patr.RelationshipType as RelationShip_To_Index,
  PNS.ScreeningDate  as PNSScreeningDate,
  PNS.LivingWithClient as Currently_Living_With_Index,
  PNS.PnsPhysicallyHurt as IPV_Physically_Hurt,
  PNS.ThreatenedHurt as IPV_Threatened_Hurt,
  PNS.PnsForcedSexual as IPV_Sexual_Hurt,
  PNS.IPVOutcome as IPV_Outcome,
  PNS.HIVStatus as HIV_Status,
  PNS.PNSApproach as PNS_Approach,
  TC.Encounter_Date as DateTracingDone,
  TC.Contact_Type,
  TC.Contact_Outcome,
  TC.Reason_uncontacted,
  TC.Booking_Date as Booking_Date,
  TC.Consent_For_Testing,
  TC.Date_Reminded,
  0 as Voided
   from ( select  distinct pe.PatientId from PatientEnrollment  pe
  inner join ServiceArea sa on sa.Id=pe.ServiceAreaId
  where sa.Code='HTS'
  union 
  select distinct pt.Id
   from HtsEncounter e 
  inner join Patient pt on pt.PersonId=e.PersonId
  ) hts
  left join Patient p on p.Id=hts.PatientId
  left join Person per on per.Id=p.PersonId
 left join (SELECT
	ISNULL(ROW_NUMBER() OVER(ORDER BY PR.Id ASC), -1) AS RowID,
	PR.PersonId,
	PR.PatientId,
	CAST(DECRYPTBYKEY(P.[FirstName]) AS VARCHAR(50)) AS [FirstName],
	CAST(DECRYPTBYKEY(P.[MidName]) AS VARCHAR(50)) AS [MidName],
	CAST(DECRYPTBYKEY(P.[LastName]) AS VARCHAR(50)) AS [LastName],
	CAST(DECRYPTBYKEY(pc.MobileNumber) AS VARCHAR(50)) as PhoneNumber,
	P.DateOfBirth,
	P.Sex,
	CAST(DECRYPTBYKEY(pc.[PhysicalAddress]) AS VARCHAR(50)) AS [PhysicalAddress],
	Gender = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = P.Sex AND MasterName = 'Gender'),
	PR.RelationshipTypeId,
	MaritalStatus=(Select top 1 itemName from LookupItemView where itemId= pms.MaritalStatusId AND MasterName='MaritalStatus'),
	RelationshipType = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PR.RelationshipTypeId AND MasterName = 'Relationship'),
	PR.CreateDate as Encounter_Date
	
FROM [dbo].[PersonRelationship] PR
inner JOIN dbo.Patient AS PT ON PT.Id = PR.PatientId
left join PatientMaritalStatus pms on pms.PersonId=pr.PersonId
left JOIN [dbo].[Person] P ON P.Id = PR.PersonId
left join PersonContact pc on pc.PersonId=PR.PersonId
)patr on patr.PatientId=hts.PatientId
left join (select T.PersonId as PersonId,T.PatientId as PatientId
,T.PatientMasterVisitId as PatientMasterVisitId,
T.BookingDate as BookingDate
,T.Comment as Comment ,T.EligibleTesting as EligibleTesting ,T.HIVStatus as HIVStatus,
T.IPVOutcome as IPVOutcome,T.LivingWithClient as LivingWithClient
,T.Occupation as Occupation 
,T.PNSApproach as PNSApproach 
,T.PnsForcedSexual as PnsForcedSexual ,T.PnsPhysicallyHurt as PnsPhysicallyHurt
,T.PnsRelationship as PnsRelationship 
,T.PnsThreatenedHurt as ThreatenedHurt
,T.ScreeningDate as ScreeningDate 
, T.ScreeningHivStatus as ScreeningHivStatus
,T.VisitDate as VisitDate

from (SELECT distinct  a.[PersonId],b.[PatientId],pmv.VisitDate,[PatientMasterVisitId],b.[ScreeningDate],ScreeningCategory=
					(SELECT        TOP 1 ItemName
					  FROM            [dbo].[LookupItemView]
					  WHERE        ItemId = b.[ScreeningCategoryId]),ScreeningValue=
					(SELECT        TOP 1 ItemName
					  FROM            [dbo].[LookupItemView]
					  WHERE        ItemId = b.ScreeningValueId),[Occupation],[BookingDate] ,[Comment]
			FROM [dbo].[HtsScreening]a 
			inner join [dbo].[PatientScreening] b on b.Id=a.PatientScreeningId 
			left join PatientMasterVisit pmv on pmv.Id=b.PatientMasterVisitId
			left join [dbo].[HtsScreeningOptions] c on c.id=a.HtsScreeningOptionsId and a.personid=c.personid)y
				PIVOT (max(y.ScreeningValue) FOR ScreeningCategory IN (PnsRelationship ,PnsPhysicallyHurt,PnsThreatenedHurt,PnsForcedSexual,
			IPVOutcome,LivingWithClient,HIVStatus,PNSApproach,EligibleTesting,ScreeningHivStatus))T)PNS on PNS.PatientId=hts.PatientId and patr.PersonId=PNS.PersonId
left join (SELECT 
PersonID,
Encounter_Date = T.DateTracingDone,
Encounter_ID = T.Id,
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT ItemId FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
Consent_For_Testing=(SELECT [Name] from LookupItem where Id=  T.Consent),
T.OtherReasonSpecify,
T.DateBookedTesting as Booking_Date,
T.ReminderDate as Date_Reminded,
T.Remarks,
T.DeleteFlag Voided

FROM Tracing T

) TC on TC.PersonID=patr.PersonId  and TC.Encounter_Date=PNS.ScreeningDate






-- 10. Patient programs--HIV Program Enrollment
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY(IQCARE_OPENMRS,'Select Person_Id,Encounter_Date,Encounter_ID,Program,Date_Enrolled,Date_Completed   
from migration_st.st_program_enrollment')

select 
  P.Id as Person_Id,
  pe.Enrollment as Encounter_Date,
  NULL as Encounter_ID,
  sa.Code as Program,
  pe.Enrollment as Date_Enrolled,
  pe.ExitDate as Date_Completed 
from Person P

INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN 
(select pce.PatientId,pce.ServiceAreaId,pce.Enrollment,pce.ExitDate from(select pce.PatientId,pce.ReenrollmentDate as Enrollment,pce.ServiceAreaId,CASE WHEN 
pce.ExitDate > pce.ReenrollmentDate then pce.ExitDate else NULL end as ExitDate  from(
select pe.PatientId,pe.Id,pe.CareEnded,pce.Active,pce.DeleteFlag,pe.EnrollmentDate,pe.ServiceAreaId
,pce.ExitDate,pce.ExitReason,pre.ReenrollmentDate from PatientEnrollment pe
inner join PatientCareending pce on pce.PatientId=pe.PatientId
inner join PatientReenrollment pre on pre.PatientId=pce.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
where pce.DeleteFlag='1'
)pce
union 
select pce.PatientId,pce.EnrollmentDate as Enrollment,pce.ServiceAreaId,pce.ExitDate from(
select  pe.PatientId,pe.CareEnded,pe.ServiceAreaId,pe.EnrollmentDate,pce.ExitDate,pce.DeleteFlag
  from PatientEnrollment  pe 
left join PatientCareending pce on pce.PatientId = pe.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
)pce)pce  )pe on pe.PatientId=PT.Id
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId
where pe.ServiceAreaId=1




-- 11. Patient discontinuation
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY(IQCARE_OPENMRS,'Select Person_Id,Encounter_Date,Encounter_ID,Program,Date_Enrolled,Date_Completed,
Care_Ending_Reason,Facility_Transfered_To,Death_Date 
from migration_st.st_program_discontinuation')

select 
P.Id as Person_Id,
pe.Enrollment as Encounter_Date,
NULL as Encounter_ID,
sa.Code as Program,
pe.Enrollment as Date_Enrolled,
pe.ExitDate as Date_Completed,
pe.ExitReasonValue as Care_Ending_Reason,
pe.TransferOutfacility as Facility_Transfered_To,
pe.DateOfDeath as Death_Date
from Person P

INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN 
(select pce.PatientId,pce.ServiceAreaId,pce.Enrollment,pce.ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(select pce.PatientId,pce.ReenrollmentDate as Enrollment,pce.ServiceAreaId,CASE WHEN 
pce.ExitDate > pce.ReenrollmentDate then pce.ExitDate else NULL end as ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(
select pe.PatientId,pe.Id,pe.CareEnded,pce.Active,pce.DeleteFlag,pe.EnrollmentDate,pe.ServiceAreaId
,pce.ExitDate,pce.ExitReason,lti.DisplayName as ExitReasonValue,pce.TransferOutfacility,pre.ReenrollmentDate,pce.DateOfDeath from PatientEnrollment pe
inner join PatientCareending pce on pce.PatientId=pe.PatientId
inner join PatientReenrollment pre on pre.PatientId=pce.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
where pce.DeleteFlag='1'
)pce
union 
select pce.PatientId,pce.EnrollmentDate as Enrollment,pce.ServiceAreaId,pce.ExitDate,pce.ExitReasonValue,pce.TransferOutfacility,pce.DateOfDeath from(
select pe.PatientId,pe.CareEnded,pe.ServiceAreaId,pe.EnrollmentDate,pce.ExitDate,lti.DisplayName as ExitReasonValue,pce.TransferOutfacility,pce.DeleteFlag,pce.DateOfDeath
from PatientEnrollment pe 
left join PatientCareending pce on pce.PatientId = pe.PatientId
left join LookupItem lti on lti.Id=pce.ExitReason
and pce.PatientEnrollmentId=pe.Id
)pce)pce )pe on pe.PatientId=PT.Id
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId
INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id 
WHERE pe.ExitDate is not null

-- 12. IPT Screening
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id, Encounter_Date,Encounter_ID,Yellow_urine,Numbness,Yellow_eyes,Tenderness,IPT_Start_Date
 FROM migration_st.st_ipt_screening')

 select p.PersonId,
pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,CASE WHEN pipt.YellowColouredUrine =0 then 'No' when pipt.YellowColouredUrine=1 then 'Yes'
else NULL
 end as Yellow_urine
 ,CASE WHEN pipt.Numbness =0 then 'No' when pipt.Numbness=1 then 'Yes'
else NULL
 end as Numbness
 ,CASE WHEN pipt.YellownessOfEyes =0 then 'No' when pipt.YellownessOfEyes=1 then 'Yes'
else NULL
 end as Yellow_eyes,
 CASE WHEN pipt.AbdominalTenderness =0 then 'No' when pipt.AbdominalTenderness=1 then 'Yes'
else NULL
 end as Tenderness
,pipt.IptStartDate as IPT_Start_Date

from PatientIptWorkup pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId

-- 13. IPT Program Enrollment
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id,Encounter_Date,Encounter_ID,IPT_Start_Date,Indication_for_IPT,IPT_Outcome,Outcome_Date
 FROM migration_st.st_ipt_program')


select p.PersonId,
pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,pipt.IptStartDate as IPT_Start_Date,
NULL as Indication_for_IPT,
ltv.ItemDisplayName as IPT_Outcome
,pio.IPTOutComeDate as Outcome_Date

from PatientIptWorkup pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId
left join PatientIptOutcome pio on pio.PatientId=pipt.PatientId
and pio.PatientMasterVisitId=pipt.PatientMasterVisitId
left join LookupItemView ltv on ltv.itemId=pio.IptEvent 
and ltv.MasterName='IptOutcome'

-- 14. IPT Program Followup
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id,Encounter_Date,Encounter_ID,IPT_due_date,Date_collected_ipt,Weight,Hepatotoxity,Hepatotoxity_Action,Peripheral_neuropathy,Peripheralneuropathy_Action,
Rash,Rash_Action,Adherence,AdheranceMeasurement_Action,IPT_Outcome,Outcome_Date
 FROM migration_st.st_ipt_followup')

  select p.PersonId
,pmv.VisitDate as EncounterDate
,NULL as Encounter_ID
,pipt.IptDueDate as Ipt_due_date
,pipt.IptDateCollected as Date_collected_ipt
,pipt.[Weight] as [Weight]
,CASE WHEN pipt.Hepatotoxicity =0 then 'No' when pipt.Hepatotoxicity=1 then 'Yes'
else NULL
 end as Hepatotoxity,
 HepatotoxicityAction as Hepatotoxity_Action,
 CASE WHEN pipt.Peripheralneoropathy =0 then 'No' when pipt.Peripheralneoropathy=1 then 'Yes'
else NULL
end as Peripheralneoropathy
,pipt.PeripheralneoropathyAction as Peripheralneuropathy_Action
 ,CASE WHEN pipt.Rash =0 then 'No' when pipt.Rash=1 then 'Yes'
else NULL
 end as Rash,
 pipt.RashAction as Rash_Action,
 ltv.DisplayName as Adherence,
 pipt.AdheranceMeasurementAction as AdheranceMeasurement_Action,
 lto.ItemDisplayName as IPT_Outcome,
 pio.IPTOutComeDate as Outcome_Date
from  PatientIpt pipt
inner join PatientMasterVisit pmv on pmv.Id=pipt.PatientMasterVisitId
inner join Patient p on p.Id=pipt.PatientId
left join LookupItemView ltv on ltv.ItemId=pipt.AdheranceMeasurement
left join PatientIptOutcome pio on pio.PatientId = pipt.PatientId and pio.PatientMasterVisitId=pipt.PatientMasterVisitId
and ltv.MasterName='AdheranceMeasurement'
left join LookupItemView lto on lto.itemId=pio.IptEvent 
and ltv.MasterName='IptOutcome'

-- 15. Regimen History
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS,
'select  Person_Id, Encounter_Date,Encounter_ID,                   
  Program,                         
  Regimen ,                         
  Regimen_Name,                     
  Regimen_Line,                     
  Date_Started,                     
  Date_Stopped,            
  Regimen_Discontinued,             
  Date_Discontinued,                
  Reason_Discontinued,              
  RegimenSwitchTo,	
  CurrentRegimen,				
  Voided,                           
  Date_voided                    
from migration_st.st_regimen_history')

 select p.Id  as Person_Id,part.DispensedByDate as Encounter_Date
, 'NULL' as Encounter_ID,
 pstart.TreatmentProgram as Program,
 NULL as Regimen,
 pstart.Regimen as Regimen_Name,
 pstart.RegimenLine as Regimen_Line,
 pstart.DispensedByDate as Date_Started, 
  pr.VisitDate as Date_Stopped
 ,CASE WHEN pr.VisitDate is not null then pstart.Regimen else NULL end  as Regimen_Discontinued
 ,pr.VisitDate as [Date_Discontinued],
 pr.TreatmentReason  as Reason_Discontinued
,pr.Regimen as RegimenSwitchTo
 ,part.Regimen as CurrentRegimen
 ,0 as Voided
 ,NULL as Date_Voided
  from (select distinct PatientId from PatientTreatmentTrackerView pt)ptr 
  inner join Patient pt on pt.Id=ptr.PatientId
left join Person p on p.Id =pt.PersonId
left join (
select  pts.PatientId,lt.DisplayName as [Regimen],pts.RegimenLine,pts.TreatmentStatus,pts.DispensedByDate,pts.VisitDate,pts.TreatmentProgram from (select tv.PatientId,tv.RegimenId,tv.Regimen,tv.RegimenLine,tv.TreatmentStatusId,tv.TreatmentStatus,tv.DispensedByDate,tv.VisitDate,dc.[Name] as TreatmentProgram,
ROW_NUMBER() OVER(partition by tv.PatientId order by tv.PatientMasterVisitId desc)rownum
 from PatientTreatmentTrackerView tv
 left join ord_PatientPharmacyOrder pho on pho.PatientMasterVisitId =tv.PatientMasterVisitId
 left join mst_Decode dc on dc.ID =pho.ProgID
 )pts 
 inner join LookupItem lt on lt.Id=pts.RegimenId
 where pts.rownum =1
 )part on part.PatientId=pt.Id
left join(select  pts.PatientId,lt.DisplayName as [Regimen],pts.RegimenLine,pts.TreatmentStatus,pts.DispensedByDate,pts.VisitDate,pts.TreatmentProgram from (select tv.PatientId,tv.RegimenId,tv.Regimen,tv.RegimenLine,tv.TreatmentStatusId,tv.TreatmentStatus,tv.DispensedByDate,tv.VisitDate,
ROW_NUMBER() OVER(partition by tv.PatientId order by tv.PatientMasterVisitId asc)rownum, dc.[Name] as TreatmentProgram
 from PatientTreatmentTrackerView tv
  left join ord_PatientPharmacyOrder pho on pho.PatientMasterVisitId =tv.PatientMasterVisitId
   left join mst_Decode dc on dc.ID =pho.ProgID
 )pts 
 inner join LookupItem lt on lt.Id=pts.RegimenId
 where pts.rownum =1
)pstart  on pstart.PatientId=pt.Id
left join(
select pr.PatientId,pr.RegimenLine,pr.Regimen,pr.TreatmentStatus,pr.VisitDate,pr.DispensedByDate,pr.TreatmentReason from (select p.PatientId,p.RegimenId,p.RegimenLine,ltr.DisplayName as [Regimen],p.TreatmentReason,p.TreatmentStatus,p.TreatmentStatusId,p.VisitDate,p.DispensedByDate,ROW_NUMBER() 
 OVER(Partition by p.PatientId order by p.PatientMasterVisitId desc)rownum  from PatientTreatmentTrackerView   p
inner join LookupItem lt on lt.Id=p.TreatmentStatusId
inner join LookupItem ltr on ltr.Id=p.RegimenId
left join LookupItem lts on lts.Id =p.TreatmentStatusReasonId
where lt.[Name]='DrugSwitches')pr  where pr.rownum='1'
)pr on pr.PatientId=pt.Id

-- 16. HIV Follow up
exec pr_OpenDecryptedSession;
insert into OpenQuery(IQCare_OPENMRS,'Select Person_Id,Encounter_Date,Encounter_ID,
  Visit_scheduled,          
  Visit_by,          
  Visit_by_other,   
  Nutritional_status,        
  Population_type,       
  Key_population_type,       
  Who_stage,      
  Presenting_complaints,
  Complaint,  
  Duration,
  Onset_Date,
  Clinical_notes,
  Has_known_allergies,      
  Allergies_causative_agents,
  Allergies_reactions,
  Allergies_severity,      
  Has_Chronic_illnesses_cormobidities,
  Chronic_illnesses_name,
  Chronic_illnesses_onset_date, 
  Has_adverse_drug_reaction,
  Medicine_causing_drug_reaction, 
  Drug_reaction,
  Drug_reaction_severity,     
  Drug_reaction_onset_date,  
  Drug_reaction_action_taken, 
  Vaccinations_today,
  Vaccine_Stage,
  Vaccination_Date,
  Last_menstrual_period,      
  Pregnancy_status,
  Wants_pregnancy ,
  Pregnancy_outcome, 
  Anc_number,               
  Anc_profile,               
  Expected_delivery_date,    
  Gravida,   
  Parity,                 
  Family_planning_status,    
  Family_planning_method ,   
  Reason_not_using_family_planning,  
  General_examinations_findings ,
  System_review_finding,
  Skin,    
  Skin_finding_notes,        
  Eyes,       
  Eyes_finding_notes,        
  ENT,      
  ENT_finding_notes,         
  Chest,        
  Chest_finding_notes,       
  CVS,      
  CVS_finding_notes,         
  Abdomen,                   
  Abdomen_finding_notes,  
  CNS,               
  CNS_finding_notes,      
  Genitourinary,           
  Genitourinary_finding_notes,
  Diagnosis,             
  Treatment_plan,           
  Ctx_adherence,            
  Ctx_dispensed,            
  Dapsone_adherence,       
  Dapsone_dispensed,        
  Morisky_forget_taking_drugs,   
  Morisky_careless_taking_drugs, 
  Morisky_stop_taking_drugs_feeling_worse,  
  Morisky_stop_taking_drugs_feeling_better,  
  Morisky_took_drugs_yesterday,    
  Morisky_stop_taking_drugs_symptoms_under_control, 
  Morisky_feel_under_pressure_on_treatment_plan,
  Morisky_how_often_difficulty_remembering,
  Arv_adherence,      
  Condom_provided,        
  Screened_for_substance_abuse,
  Pwp_disclosure,       
  Pwp_partner_tested,      
  Cacx_screening,           
  Screened_for_sti,         
  Stability,              
  Next_appointment_date,    
  Next_appointment_reason,  
  Appointment_type,       
  Differentiated_care,     
  Voided 
  FROM migration_st.st_hiv_followup')

exec pr_OpenDecryptedSession;
  select  P.Id as Person_Id,
  CAST(DECRYPTBYKEY(P.FirstName) AS VARCHAR(50)) AS First_Name,
  CAST(DECRYPTBYKEY(P.MidName) AS VARCHAR(50)) AS Middle_Name,
  CAST(DECRYPTBYKEY(P.LastName) AS VARCHAR(50)) AS Last_Name,
  format(cast(ISNULL(P.DateOfBirth, PT.DateOfBirth) as date),'yyyy-MM-dd') AS DOB,
  Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else '' end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = P.Sex),
  UPN =P.Id,
  pmv.VisitDate  as [EncounterDate],
  CASE WHEN pmv.VisitScheduled='0' then 'No' when pmv.VisitScheduled='1' then 'Yes' end as visit_scheduled,
ltv.[Name] as VisitBy,
NULL Visit_by_other
,pvs.[Weight],pvs.Height,pvs.Systolic_pressure,pvs.Diastolic_pressure,pvs.Temperature,
pvs.Pulse_rate,pvs.Respiratory_rate,pvs.Oxygen_Saturation,pvs.BMI,pvs.Muac,
psc.ItemDisplayName as Nutritional_status,
pop.PopulationType as Population_type,
pop.Population_Type as Key_populationType,
pws.WHO_Stage as Who_Stage,
pres.PresentingComplaint as Presenting_complaints,
cl.ClinicalNotes as Clinical_notes,
CASE when pic.OnAntiTbDrugs='0' then 'No' when pic.OnAntiTbDrugs='1' then 'Yes' end as On_anti_tb_drugs,
CASE when pic.Cough='0' then 'No' when pic.Cough='1' then 'Yes' end as Tb_Screening_cough,
CASE when pic.Fever='0' then 'No' when pic.Fever='1' then 'Yes' end as Tb_Screening_Fever,
CASE when pic.WeightLoss='0' then 'No' when pic.WeightLoss='1' then 'Yes' end as Tb_Screening_weightloss,
CASE when pic.NightSweats='0' then 'No' when pic.NightSweats='1' then 'Yes' end as Tb_Screening_night_sweats,
NULL as  Tests_ordered,
picf.Spatum_smear_Ordered,
picf.Chest_xray_ordered,
picf.Genexpert_ordered,
picf.Spatum_smear_result,
picf.Chest_xray_result,
picf.Geneexpert_result,
NULL as Referral,
NULL as clinical_tb_diagnosis,
CASE when pia.InvitationOfContacts='0' then 'No' when pia.InvitationOfContacts='1' then 'Yes' end as Contact_invitation,
CASE when pia.EvaluatedForIpt='0' then 'No' when pia.EvaluatedForIpt='1' then 'Yes' end as   Evaluated_for_ipt,
ptb.Tb_Status,
trx.TBRxStartDate as Tb_treatment_date,
trx.RegimenName as  Tb_regimen,
CASE WHEN paa.Has_Known_allergies is null then 'No' else paa.Has_Known_allergies end as Has_Known_allergies,
paa.Allergies_causative_agents,
paa.Allergies_reactions,
paa.Allergies_severity,
chr.Has_Chronic_illnesses_cormobidities,
chr.Chronic_illnesses_name,
chr.Chronic_illnesses_onset_date,
CASE WHEN paa.Has_Known_allergies is null then 'No' else paa.Has_Known_allergies end as Has_adverse_drug_reaction,
paa.Allergies_causative_agents as Medicine_causing_drug_reaction,
paa.Allergies_reactions as Drug_reaction,
paa.Allergies_severity as Drug_reaction_severity,
paa.OnsetDate as Drug_reaction_onset_date,
NULL as Drug_reaction_action_taken,
vss.Vaccinations_today,
vss.VaccineStage as Vaccine_Stage,
vss.VaccineDate as Vaccine_Date,
pov.LMP as Last_menstrual_period,
pov.PregnancyStatus,
pov.PlanningGetPregnant as Wants_Pregnancy,
pov.Outcome as Pregnancy_Outcome,
panc.IdentifierValue as Anc_number,
pov.Anc_Profile,
pov.EDD  as Expected_delivery_date,
pov.Gravidae as Gravida,
pov.Parity as Parity,
pfm.FamilyPlanningStatus as Family_planning_status,
pfm.FamilyPlanningMethod as Family_planning_method,
pfm.Reason_not_using_family_planning,
ge.Exam as General_examinations_findings,
CASE when srs.System_review_finding is null then 'No' else srs.System_review_finding end as System_review_finding,
ey.Findings as Eyes,
ey.FindingsNotes as Eyes_Finding_notes,
sk.Findings as Skins,
sk.FindingsNotes as Skin_finding_notes,
ch.Findings as Chest,
ch.FindingsNotes as Chest_finding_notes,
cvs.Findings as CVS,
cvs.FindingsNotes as CVS_Finding_notes,
ab.Findings as Abdomen,
ab.FindingsNotes as Abdomen_Finding_notes,
cns.Findings as CNS,
cns.FindingsNotes as CNS_finding_notes,
gn.Findings as Genitourinary,
gn.FindingsNotes as Genitourinary_finding_notes,
pd.Diagnosis as Diagnosis,
pd.ManagementPlan as Treatment_plan,
ctx.ScoreName as Ctx_adherence,
ctx.VisitDate as Ctx_dispensed,
NULL as Dapson_adherence,
NULL as Dapsone_dispensed,
adass.Morisky_forget_taking_drugs,
adass.Morisky_careless_taking_drugs,
adass.Morisky_stop_taking_drugs_feeling_worse,
adass.Morisky_stop_taking_drugs_feeling_better,
adass.Morisky_took_drugs_yesterday,
adass.Morisky_stop_taking_drugs_symptoms_under_control,
adass.Morisky_feel_under_pressure_on_treatment_plan,
adass.Morisky_how_often_difficulty_remembering,
adv.ScoreName as Arv_adherence,
phdp.Condom_Provided,
phdp.Screened_for_substance_abuse,
phdp.Pwp_Disclosure,
phdp.Pwp_partner_tested,
cacx.ScreeningValue  as Cacx_Screening,
phdp.Screened_for_sti,
pcc.Stability as Stability,
papp.Next_appointment_date,
papp.Next_appointment_reason,
papp.Appointment_type,
pdd.DifferentiatedCare as Differentiated_care,
'0' as Voided
  from Person P
   INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientEncounter pe on pe.PatientId=PT.Id
   inner join 
LookupItem lt  on lt.Id=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join mst_User u on u.UserID=pe.CreatedBy
inner join LookupItem ltv on ltv.Id=pmv.VisitBy
left join (
select pvs.Patientid,pvs.PatientMasterVisitId,pmv.VisitDate,
pvs.[Weight] ,pvs.[Height],pvs.BPSystolic as Systolic_pressure,
pvs.BPDiastolic as Diastolic_pressure,
pvs.Temperature,pvs.HeartRate as Pulse_rate,
pvs.RespiratoryRate as Respiratory_rate,
pvs.SpO2 as Oxygen_Saturation,
pvs.BMI as BMI,
pvs.Muac as Muac
from PatientVitals pvs 
inner join  PatientMasterVisit pmv on pvs.PatientMasterVisitId=pmv.Id
 inner join Patient p on p.Id=pmv.PatientId
 )pvs on pvs.PatientId=pe.PatientId
 and pvs.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ItemDisplayName,psc.DeleteFlag,psc.Active from( select  psc.PatientId,psc.PatientMasterVisitId ,psc.ScreeningTypeId,(select [Name] from LookupMaster where Id =psc.ScreeningTypeId) as MasterName
  ,psc.ScreeningValueId,(select DisplayName from LookupItem where Id=psc.ScreeningValueId) as ItemDisplayName,psc.DeleteFlag,psc.Active
   from PatientScreening psc
   )psc where psc.MasterName='NutritionStatus' and (psc.DeleteFlag=0 or psc.DeleteFlag is null))
   psc on psc.PatientMasterVisitId=pe.PatientMasterVisitId and psc.PatientId =pe.PatientId
  left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null))t where t.rownum=1) pop on pop.PersonId=P.Id
left join (select * from(select pws.PatientId,pws.PatientMasterVisitId,pws.WHOStage,ltv.itemName as WHO_Stage,ROW_NUMBER() OVER(partition by
pws.PatientId,pws.PatientMasterVisitId order by pws.PatientMasterVisitId)rownum from PatientWHOStage pws
inner join LookupItemView ltv on ltv.MasterName='WHOStage' and pws.WHOStage=ltv.ItemId)pw where pw.rownum=1
)pws on pws.PatientId=pe.PatientMasterVisitId and pws.PatientId=pe.PatientId
left join (select PatientId,PatientMasterVisitId,PresentingComplaintsId,PresentingComplaint from (select  PatientId,PatientMasterVisitId,PresentingComplaintsId,CreatedBy,CreatedDate,lt.DisplayName as PresentingComplaint,
ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by CreatedDate desc)rownum
 from PresentingComplaints pres
 inner join LookupItem lt on lt.Id=pres.PresentingComplaintsId
 ) pre where rownum='1')pres on pres.PatientId=pe.PatientId and pres.PatientMasterVisitId=pe.PatientMasterVisitId
 left join(select t.PatientId,t.PatientMasterVisitId,t.ClinicalNotes from(select PatientId,PatientMasterVisitId ,ClinicalNotes,NotesCategoryId,DeleteFlag ,CreateDate,Active,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by CreateDate desc )rownum
 from PatientClinicalNotes where 
 NotesCategoryId is null and (DeleteFlag is null or DeleteFlag=0)) t where t.rownum='1')cl on cl.PatientId=pe.PatientId and cl.PatientMasterVisitId=pe.PatientMasterVisitId
 left join PatientIcf pic on pic.PatientId=pe.PatientId and pic.PatientMasterVisitId =pe.PatientMasterVisitId
left join(select pic.PatientId,pic.PatientMasterVisitId,pic.SputumSmear,CASE WHEN ltv.itemName = 'Ordered'
 then ltv.ItemName else NULL end as Spatum_smear_Ordered,
 CASE when  ltv.ItemName != 'Ordered' then ltv.DisplayName
else NULL end as Spatum_smear_result,
  pic.ChestXray,
CASE when glv.itemName='Ordered' then glv.DisplayName else NULL end as 
Genexpert_ordered,
CASE when  glv.ItemName != 'Ordered' then glv.DisplayName
else NULL end as Geneexpert_result,
CASE when clv.itemName='Ordered' then clv.DisplayName else NULL end as 
Chest_xray_ordered
,CASE when  clv.ItemName != 'Ordered' then clv.DisplayName
else NULL end as Chest_xray_result
,pic.GeneXpert,glv.DisplayName
from PatientIcfAction pic
left join LookupItemView ltv on ltv.ItemId=pic.SputumSmear and ltv.MasterName='SputumSmear'
left join LookupItemView glv on glv.ItemId=pic.GeneXpert and glv.MasterName='GeneExpert'
left Join LookupItemView clv on clv.ItemId=pic.ChestXray and clv.MasterName='ChestXray')
picf on picf.PatientId=pe.PatientId and picf.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select psc.Patientid,psc.PatientMasterVisitId ,psc.ScreeningValueId,lt.[Name],lti.DisplayName as  Tb_Status
 from PatientScreening psc
 inner join LookupItem lt on lt.Id= psc.ScreeningValueId
 inner join LookupMasterItem lti on lti.LookupItemId=lt.Id
 inner join LookupMaster lm on lm.Id=lti.LookupMasterId
  where lm.[Name] ='TBFindings' and (psc.DeleteFlag = 0 or psc.DeleteFlag is null))ptb on
  ptb.PatientId=pe.PatientId and ptb.PatientMasterVisitId=pe.PatientMasterVisitId
  left join (select * from (select *,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by PatientMasterVisitId desc)rownum from PatientIcfAction where DeleteFlag is null or DeleteFlag =0)pia where pia.rownum=1)pia on pia.PatientId =pe.PatientId
  and pia.PatientMasterVisitId=pe.PatientMasterVisitId
  left join (select tt.PatientId,tt.PatientMasterVisitId,tt.TBRxEndDate,tt.TBRxStartDate,tt.RegimenId,li.DisplayName as [RegimenName] from (select tt.PatientId,tt.PatientMasterVisitId,tt.TBRxStartDate,tt.TBRxEndDate,tt.RegimenId,ROW_NUMBER() OVER(partition by tt.PatientId,tt.PatientMasterVisitId order by tt.PatientMasterVisitId desc)rownum from TuberclosisTreatment tt)tt
  inner join LookupItem li on li.Id=tt.RegimenId
   where tt.rownum=1)trx on trx.PatientId=pe.PatientId and trx.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select PatientId,PatientMasterVisitId,OnsetDate ,AllergenName as Allergies_causative_agents,ReactionName as Allergies_reactions,'Yes' as Has_Known_allergies,
SeverityName as Allergies_severity,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by  PatientMasterVisitId desc)rownum

 from PatientAllergyView)pav where pav.rownum =1)paa on paa.PatientId=pe.PatientId and paa.PatientMasterVisitId =pe.PatientMasterVisitId
 left join (select * from (select PatientId,PatientMasterVisitId ,ChronicIllness as Chronic_illnesses_name,
OnsetDate as Chronic_illnesses_onset_date ,'Yes' as Has_Chronic_illnesses_cormobidities,
ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by  PatientMasterVisitId desc)rownum

 from PatientChronicIllnessView)pav where pav.rownum =1
)chr on chr.PatientId =pe.PatientId and chr.PatientMasterVisitId =pe.PatientMasterVisitId
left join(
 select  distinct  vs.PatientId,vs.PatientMasterVisitId,vs.PeriodId,vs.Vaccinations_today,lti.DisplayName as VaccineStage,vs.VaccinationStage,vs.VaccineStageId,vs.VaccineDate from (select v.PatientId,v.PatientMasterVisitId,v.Vaccine,lt.DisplayName as [Vaccinations_today],CASE WHEN 
 isNumeric(v.VaccineStage) =1  then v.VaccineStage else NULL end as VaccineStage ,v.VaccineStageId,ltt.DisplayName as [VaccinationStage],v.PeriodId,v.VaccineDate from Vaccination v
 left join LookupItem ltt on ltt.Id=v.VaccineStageId
 left join LookupItem lt on lt.Id=v.Vaccine) vs
 left join LookupItem lti on lti.id=vs.VaccineStage )vss on vss.PatientId=pe.PatientId and vss.PatientMasterVisitId=pe.PatientMasterVisitId
 left join (
SELECT        dbo.PregnancyIndicator.Id,dbo.Pregnancy.Gravidae,dbo.Pregnancy.Parity, dbo.PregnancyIndicator.PatientId, dbo.PregnancyIndicator.PatientMasterVisitId, dbo.PregnancyIndicator.LMP, dbo.PregnancyIndicator.EDD,CASE WHEN dbo.PregnancyIndicator.ANCProfile='1' then 'Yes' when dbo.PregnancyIndicator.ANCProfile='0' then 'No' end as Anc_Profile,

                             (SELECT        TOP (1) DisplayName
                               FROM            dbo.LookupItemView
                               WHERE        (ItemId = dbo.PregnancyIndicator.PregnancyStatusId) AND (MasterName = 'PregnancyStatus')) AS PregnancyStatus,
                             (SELECT        TOP (1) DisplayName
                               FROM            dbo.LookupItemView AS LookupItemView_1
                               WHERE        (ItemId = dbo.Pregnancy.Outcome)) AS Outcome,
							   PregnancyIndicator.PregnancyStatusId,
							   Pregnancy.Outcome OutcomeStatus,
							   PregnancyIndicator.PlanningToGetPregnant,
							   lt.[Name] as [PlanningGetPregnant]
							
FROM            dbo.Pregnancy  inner JOIN
                         dbo.PregnancyIndicator ON dbo.PregnancyIndicator.PatientId = dbo.Pregnancy.PatientId AND dbo.PregnancyIndicator.PatientMasterVisitId = dbo.Pregnancy.PatientMasterVisitId
						 left join LookupItem lt on lt.Id=PregnancyIndicator.PlanningToGetPregnant)pov on pov.PatientId =pe.PatientId and pov.PatientMasterVisitId=pe.PatientMasterVisitId
left join( select * from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag,ROW_NUMBER() OVER(partition by pid.PatientId order by pid.CreateDate desc) rownum from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  where pdd.[Code]= 'ANCNumber'
and (pid.DeleteFlag is null or pid.DeleteFlag =0))pidd where pidd.rownum ='1')panc on panc.PatientId=pe.PatientId
left join(select p.PatientId,p.PatientMasterVisitId,p.FamilyPlanningStatusId,ltr.DisplayName as [Reason_not_using_family_planning],lt.[DisplayName] as FamilyPlanningStatus,ltf.DisplayName as FamilyPlanningMethod from  PatientFamilyPlanning p
left join PatientFamilyPlanningMethod pfm on pfm.PatientFPId=p.Id
left join LookupItem ltf on ltf.Id =pfm.FPMethodId
inner join LookupItem lt on lt.Id =p.FamilyPlanningStatusId
left join LookupItem ltr on ltr.Id=p.ReasonNotOnFPId
)pfm on pfm.PatientId=pe.PatientId and pfm.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e
)ex where ex.ExaminationType='GeneralExamination'
)ex where ex.rownum ='1') ge on ge.PatientId=pe.PatientId and ge.PatientMasterVisitId =pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Eyes'

)ex 
where ex.rownum ='1'
)ey on ey.PatientId =pe.PatientId and ey.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Skin'

)ex 
where ex.rownum ='1'
)sk on sk.PatientId =pe.PatientId and sk.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Chest'

)ex 
where ex.rownum ='1'
)ch on ch.PatientId =pe.PatientId and ch.PatientMasterVisitId=pe.PatientMasterVisitId



left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='CVS'

)ex 
where ex.rownum ='1'
)cvs on cvs.PatientId =pe.PatientId and cvs.PatientMasterVisitId=pe.PatientMasterVisitId




left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Abdomen'

)ex 
where ex.rownum ='1'
)ab on ab.PatientId =pe.PatientId and ab.PatientMasterVisitId=pe.PatientMasterVisitId




left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='CNS'

)ex 
where ex.rownum ='1'
)cns on cns.PatientId =pe.PatientId and cns.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam like 'Genito-urinary'

)ex 
where ex.rownum ='1'

)gn on gn.PatientId =pe.PatientId and gn.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes,'Yes' as System_review_finding
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' 

)ex 
where ex.rownum ='1'
)
srs on srs.PatientId =pe.PatientId and srs.PatientMasterVisitId=pe.PatientMasterVisitId


left join(select  * from (select * ,ROW_NUMBER() OVER(partition by pd.PatientId
,pd.PatientMasterVisitId order by pd.CreateDate desc)rownum from (select pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan ,ic.[Name] as Diagnosis,pd.CreateDate from (
select   pd.PatientId,pd.PatientMasterVisitId,CASE WHEN isNumeric(pd.Diagnosis)= 0 then NULL else pd.Diagnosis end as Diagnosis,pd.ManagementPlan,pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 0 and pd.DeleteFlag is null or pd.DeleteFlag=0 
)pd 
inner join mst_ICDCodes ic on ic.Id=pd.Diagnosis
union all
select   pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,pd.Diagnosis,
pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 1 and pd.DeleteFlag is null or pd.DeleteFlag =0
and ISNUMERIC(pd.Diagnosis) =0
union all

select pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,lt.DisplayName as [Diagnosis],pd.CreateDate from (
select   pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,pd.Diagnosis,
pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 1 and pd.DeleteFlag is null or pd.DeleteFlag =0
and ISNUMERIC(pd.Diagnosis) =1)pd inner join LookupItem lt on lt.Id=pd.Diagnosis

 )pd)pd where pd.rownum =1)pd on pd.PatientId=pe.PatientId and pd.PatientMasterVisitId=pe.PatientMasterVisitId

 left join(select * from (select ao.Id,ao.PatientId,ao.PatientMasterVisitId,ao.Score,ROW_NUMBER() OVER(partition by ao.PatientId,
 ao.PatientMasterVisitId order by ao.CreateDate desc)rownum,
ao.AdherenceType,lm.[Name] as AdherenceTypeName,
 lti.DisplayName as ScoreName ,ao.DeleteFlag,pmv.VisitDate from AdherenceOutcome  ao
inner join  LookupMaster  lm on lm.Id=ao.AdherenceType
inner join LookupItem lti on lti.Id=ao.Score
inner join PatientMasterVisit pmv on pmv.Id =ao.PatientMasterVisitId
WHERE lm.[Name]='ARVAdherence' and (ao.DeleteFlag is null or ao.DeleteFlag  =0))adv where adv.rownum ='1')adv
on adv.PatientId =pe.PatientId and adv.PatientMasterVisitId=pe.PatientMasterVisitId

 left join(select * from (select ao.Id,ao.PatientId,ao.PatientMasterVisitId,ao.Score,ROW_NUMBER() OVER(partition by ao.PatientId,
 ao.PatientMasterVisitId order by ao.CreateDate desc)rownum,
ao.AdherenceType,lm.[Name] as AdherenceTypeName, lti.DisplayName as ScoreName ,ao.DeleteFlag,pmv.VisitDate from AdherenceOutcome  ao
inner join  LookupMaster  lm on lm.Id=ao.AdherenceType
inner join LookupItem lti on lti.Id=ao.Score
inner join PatientMasterVisit pmv on pmv.Id =ao.PatientMasterVisitId
WHERE lm.[Name]='CTXAdherence' and (ao.DeleteFlag is null or ao.DeleteFlag  =0))adv where adv.rownum ='1')ctx
on ctx.PatientId =pe.PatientId and ctx.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (select  a.PatientId,a.PatientMasterVisitId,case when a.ForgetMedicine=0 then 'No' when a.ForgetMedicine='1' then 'Yes' end  as  Morisky_forget_taking_drugs,
CASE WHEN a.CarelessAboutMedicine= 0 then 'No' WHEN a.CarelessAboutMedicine ='1' then 'Yes' end  as Morisky_careless_taking_drugs,
CASE WHEN a.FeelWorse= 0 then 'No' WHEN a.FeelWorse='1' then 'Yes' end  as Morisky_stop_taking_drugs_feeling_worse,
CASE WHEN a.FeelBetter= 0 then 'No'  when a.FeelBetter ='1' then 'Yes' end  as Morisky_stop_taking_drugs_feeling_better,
CASE WHEN a.TakeMedicine =0 then 'No' when a.TakeMedicine ='1' then 'Yes' end as Morisky_took_drugs_yesterday,
CASE WHEN a.StopMedicine=0 then 'No' when a.StopMedicine ='1' then 'Yes' end  as Morisky_stop_taking_drugs_symptoms_under_control,
CASE WHEN a.UnderPressure=0 then 'No' when a.UnderPressure ='1' then 'Yes' end  as Morisky_feel_under_pressure_on_treatment_plan,
CASE WHEN a.DifficultyRemembering=0 then 'Never/Rarely' 
WHEN a.DifficultyRemembering=0.25 then 'Once in a while'
WHEN a.DifficultyRemembering=0.5 then 'Sometimes'
WHEN a.DifficultyRemembering=0.75 then 'Usually'
WHEN a.DifficultyRemembering=1 then 'All the Time' end 
 as Morisky_how_often_difficulty_remembering ,ROW_NUMBER() OVER(partition by a.PatientId,a.PatientMasterVisitId order by a.Id desc)rownum
 from AdherenceAssessment a where Deleteflag =0 )
 ad where ad.rownum='1')adass on adass.PatientId=pe.PatientId and adass.PatientMasterVisitId=pe.PatientMasterVisitId
 left join (select  * from (select   pd.PatientId,pd.PatientMasterVisitId,CASE when pcd.DisplayName is not null then 'Yes' else 'No' end  as Condom_Provided,pd.DeleteFlag ,
CASE when SA.DisplayName  is not null then 'Yes' else' No' end as Screened_for_substance_abuse,
CASE when dis.DisplayName is not null then 'Yes' else 'No' end  as Pwp_Disclosure,
CASE when pt.DisplayName is not null then 'Yes' else 'No' end  as  Pwp_partner_tested,
CASE when st.DisplayName is not null then 'Yes' else 'No' end  as  Screened_for_sti
,ROW_NUMBER() OVER(partition by pd.PatientId,pd.PatientMasterVisitId order by pd.Id desc)rownum
from 
 PatientPHDP pd
 left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='CD')pcd on pcd.PatientMasterVisitId=pd.PatientMasterVisitId 
 left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='SA')SA on SA.PatientMasterVisitId=pd.PatientMasterVisitId
 left join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='DIS')dis on dis.PatientMasterVisitId=pd.PatientMasterVisitId
left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='STI')st on st.PatientMasterVisitId=pd.PatientMasterVisitId
 left join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='PT')pt on pt.PatientMasterVisitId=pd.PatientMasterVisitId
  --left join LookupItem lt on lt.Id=pd.Phdp and lt.[Name]='SA'

 where  pd.DeleteFlag is null  or pd.DeleteFlag=0)pd where pd.rownum= '1') phdp on  phdp.PatientId=pe.PatientId and  phdp.PatientMasterVisitId=pe.PatientMasterVisitId
 left join(select pa.PatientId,pa.PatientMasterVisitId,pa.AppointmentReason as Next_appointment_reason,pa.Appointment_type,pa.AppointmentDate as Next_appointment_date from(select pa.PatientId,pa.PatientMasterVisitId,pa.AppointmentDate,pa.DifferentiatedCareId ,pa.ReasonId,li.DisplayName as AppointmentReason,ROW_NUMBER() OVER(partition by pa.PatientId,pa.PatientMasterVisitId order by pa.CreateDate desc)rownum ,lt.DisplayName as Appointment_type,pa.DeleteFlag,pa.ServiceAreaId,pa.CreateDate from PatientAppointment pa
inner join LookupItem li on li.Id =pa.ReasonId
inner join LookupItem lt on lt.Id=pa.DifferentiatedCareId 

where pa.DeleteFlag is null or pa.DeleteFlag= 0
)pa where  pa.rownum =1
)papp on papp.PatientId=pe.PatientId and papp.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select pc.PatientId,pc.PatientMasterVisitId,CASE WHEN  pc.Categorization =2 then 'Unstable' WHEN pc.Categorization =1 then 'Stable' end as Stability
,ROW_NUMBER( )OVER(partition by pc.PatientId ,pc.PatientMasterVisitId order by pc.id desc)rownum   from PatientCategorization pc)pc where pc.rownum=1)pcc on pcc.PatientId=pe.PatientId
and pcc.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select pad.PatientId,pad.PatientMasterVisitId,'Yes'   as DifferentiatedCare from PatientArtDistribution pad where DeleteFlag = 0 or DeleteFlag is null)pdd
on pdd.PatientId =pe.PatientId and pdd.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select psc.PatientId,psc.PatientMasterVisitId,lm.[DisplayName] as ScreeningType,psc.DeleteFlag,psc.VisitDate,psc.ScreeningDate,psc.CreateDate,
lt.DisplayName as ScreeningValue,ROW_NUMBER() OVER(partition by psc.PatientId,psc.PatientMasterVisitId  order by psc.CreateDate desc)rownum
 from PatientScreening  psc
 inner join LookupMaster lm on lm.[Id] =psc.ScreeningTypeId
 inner join LookupItem lt on  lt.Id=psc.ScreeningValueId
 where lm.[Name] ='CacxScreening' and (psc.DeleteFlag is null or psc.DeleteFlag =0))psc where psc.rownum='1')cacx on cacx.PatientId=pe.PatientId and
 cacx.PatientMasterVisitId=pe.PatientMasterVisitId
 where lt.[Name]='ccc-encounter' 
 

   

 
 
 --17 LaboratoryExtract
 
 

exec pr_OpenDecryptedSession;
insert into OpenQuery(IQCare_OPENMRS,'
select Person_Id,Encounter_Date,Encounter_ID,
Lab_test,
Urgency
,Test_Result,
Date_test_requested,
Date_test_result_received,
Test_Requested_By,
PreClinicLabDate,
ClinicalOrderNotes ,
OrderNumber ,
CreateDate ,
CreatedBy   ,
OrderStatus ,
DeletedBy ,
DeleteDate ,
DeleteReason ,
ResultStatus  ,
StatusDate ,
LabResult  ,
ResultValue ,
ResultText ,
ResultOption ,
Undetectable ,
DetectionLimit ,
ResultUnit ,
HasResult  ,
LabTestName ,
ParameterName ,
LabDepartmentName ,
Voided INT(11)
 FROM migration_st.st_laboratory_extract')
select p.PersonId as Person_Id 
,v.VisitDate as Encounter_Date,
NULL as Encounter_ID,
vlw.LabTestName as Lab_test,
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
 vlw.LabDepartmentName,
  plo.DeleteFlag as Voided

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



 
 ---18  st_mch_antenatal_visit
 
 
 
 
 exec  pr_OpenDecryptedSession;
INSERT INTO OpenQuery(IQCare_OPENMRS,'SELECT  [Person_Id]
      ,[Encounter_Date]
      ,[Encounter_ID]
      ,[Anc_visit_number]
      ,[ANC_number]
      ,[Temperature]
      ,[PulseRate]
      ,[Systolic_kp]
      ,[Diastolic_bp]
      ,[Respiratory_rate]
      ,[Oxygen_saturation]
      ,[Weight]
      ,[Height]
      ,[BMI]
      ,[Muac]
      ,[Hemoglobin]
      ,[Breast_exam_done]
      ,[Pallor]
      ,[Maturity]
      ,[Fundal_Height]
      ,[Fetal_presentation]
      ,[Lie]
      ,[Fetal_Heart_Rate]
      ,[Fetal_Movement]
      ,[WHOStage]
      ,[Cd4]
      ,[Viral_load_sample_taken]
      ,[Viral_load]
      ,[Ldl]
      ,[Arv_Status]
      ,[Test_1_kit_name]
      ,[Test_1_kit_lot_no]
      ,[Test_1_kit_expiry]
      ,[Test_1_result]
      ,[Test_2_kit_name]
      ,[Test_2_kit_lot_no]
      ,[Test_2_kit_expiry]
      ,[Test_2_result]
      ,[Final_test_result]
      ,[Patient_given_result]
      ,[Urine_mocroscopy]
      ,[Glucose_measurement]
      ,[Urine_ph]
      ,[Urine_nitrite_test]
      ,[Urine_leukocyte_esterace_test]
      ,[Urinary_ketone]
      ,[Urine_bile_salt_test]
      ,[Urine_colour]
      ,[Urine_turbidity]
      ,[Urine_dipstick_for_blood]
      ,[Syphilis_test_status]
      ,[Syphilis_treated_status]
      ,[Bs_for_mps]
      ,[Anc_exercises]
      ,[Tb_Screening]
      ,[Cacx_screening]
      ,[Cacx_screening_method]
      ,[Prophylaxis_given]
      ,[Baby_azt_dispensed]
      ,[Baby_nvp_dispensed]
      ,[Illnes_name]
      ,[Illnes_Onset_Date]
      ,[Drug]
      ,[Dose]
      ,[Units]
      ,[Frequency]
      ,[Duration]
      ,[Duration_units]
      ,[Anc_counselled]
      ,[Counselled_subject]
      ,[Referred_from]
      ,[Referred_to]
      ,[Next_appointment_date]
      ,[Clinical_notes]
      ,[Plus]
      ,[Parity]
      ,[LMP]
      ,[EDD]
      ,[AgeAtMenarche]
      ,[Gravidae]
      ,[CervicalCancerComment]
      ,[On ARV Before 1st ANC Visit]
      ,[Started HAART in ANC]
      ,[Deworming]
      ,[IPT 1-3]
      ,[TT Dose]
      ,[Supplementation]
      ,[Received ITN]
      ,[PartnerTested]
      ,[PartnerHIVResult]
      ,[Voided] from migration_st.st_mch_antenatal_visit')

select  pe.Id as Person_Id,d.VisitDate as Encounter_Date,
NULL as Encounter_ID,h.VisitNumber as Anc_visit_number,
h.IdentifierValue as ANC_number,k.Temperature,k.HeartRate as PulseRate,
k.BPSystolic as Systolic_kp,k.BPDiastolic as Diastolic_bp,
k.RespiratoryRate as Respiratory_rate,
k.SpO2 as Oxygen_saturation,
k.[Weight],
k.[Height],
k.BMI,
k.Muac,
NULL Hemoglobin,
BAC.BreastExamDone as Breast_exam_done,
NULL  Pallor,
pri.Gestation as Maturity,
NULL Fundal_Height,
NULL Fetal_presentation,
NULL Lie,
NULL Fetal_Heart_Rate,
NULL Fetal_Movement,
WHO.[WHOStage],
NULL as Cd4,
pscvs.[Value]  as Viral_load_sample_taken,
NULL as Viral_load,
NULL as Ldl,
BAC.HivStatusBeforeAnc as Arv_Status,
HIVTest.OneKitId as Test_1_kit_name,
HIVTest.OneLotNumber as Test_1_kit_lot_no,
HIVTest.OneExpiryDate as Test_1_kit_expiry,
HIVTest.FinalTestOneResult as Test_1_result,
HIVTest.twokitid as Test_2_kit_name,
HIVTest.twolotnumber as Test_2_kit_lot_no,
HIVTest.twoexpirydate as Test_2_kit_expiry,
HIVTest.FinalTestTwoResult as Test_2_result,
z.FinalResult as Final_test_result, 
 NULL as Patient_given_result,
 NULL Urine_mocroscopy,
 NULL Glucose_measurement,
 NULL Urine_ph,
 NULL Urine_nitrite_test,
 NULL Urine_leukocyte_esterace_test,
 NULL Urinary_ketone,
 NULL Urine_bile_salt_test,
 NULL Urine_colour,
 NULL Urine_turbidity,
 NULL Urine_dipstick_for_blood,
 BAC.TreatedForSyphillis Syphilis_test_status,
 BAC.SyphilisResults Syphilis_treated_status,
 NULL Bs_for_mps,
 NULL  Blood_group, 
 NULL Anc_exercises,
 TBScreen.TBScreening as Tb_Screening,
 CaCX.CaCxScreening as Cacx_screening,
 CaCX.CacxScreeningMethod as Cacx_screening_method,
 CTX.CTX as Prophylaxis_given,
 [AZT for Baby] as Baby_azt_dispensed,
 [NVP for Baby] as Baby_nvp_dispensed,
 PCS.ChronicIllness as Illnes_name,
 PCS.OnsetDate as Illnes_Onset_Date,
 NULL Drug,
 NULL Dose,
 NULL Units,
 NULL Frequency,
 NULL Duration,
 NULL Duration_units,
 CASE when pcouns.CounselledTopic is not null then 'YES' else NULL end as  Anc_counselled, 
pcouns.CounselledTopic as Counselled_subject,
Refferals.ReferredFrom as Referred_from,
Refferals.ReferredTo as Referred_to,
TCAs.AppointmentDate as Next_appointment_date,
TCAs.[Description] as  Clinical_notes,
 
pri.Parity2 as Plus,
pri.Parity,
CAST(pri.LMP as date)LMP,
CAST(pri.EDD as Date)EDD,
pri.AgeAtMenarche as AgeAtMenarche,
pri.Gravidae,
CACX.Comment as CervicalCancerComment,
j.[On ARV Before 1st ANC Visit] as [On ARV Before 1st ANC Visit],
HAARTANC.[Started HAART in ANC] as  [Started HAART in ANC],
[Deworming],
IPT [IPT 1-3],
 TTDose [TT Dose], 
 Supplementation, 
 TreatedNets AS [Received ITN],
 partnerTesting.PartnerTested,
partnerTesting.PartnerHIVResult,
d.DeleteFlag as Voided 

from Patient p 
inner join Person pe on pe.Id =p.PersonId 
inner join dbo.PatientMasterVisit d ON p.Id = d.PatientId INNER JOIN
    (select a.patientID,EnrollmentDate,IdentifierValue,Visitdate,PatientMasterVisitId,
							VisitType ,[VisitNumber] ,[DaysPostPartum]  from PatientEnrollment a 
							inner  join ServiceArea b on a.ServiceAreaId=b.id
								inner join PatientIdentifier c on c.PatientId=a.PatientId
							inner join ServiceAreaIdentifiers d on c.IdentifierTypeId=d.IdentifierId and b.id=d.ServiceAreaId
							inner join dbo.VisitDetails AS g ON a.PatientId = g.PatientId AND b.Id = g.ServiceAreaId
							where b.name='ANC'  )  h ON p.Id = h.patientID and d.Id = h.PatientMasterVisitId 

LEFT OUTER JOIN
	(select  * from(SELECT      a.PatientId, a.PatientMasterVisitId, case when d.DisplayName='Known Positive' then'KP'
		when d.DisplayName='Unknown' then'U' when d.DisplayName='Revisit' then'Revisit' end as HivStatusBeforeAnc, 
		e.DisplayName TreatedForSyphillis, f.DisplayName BreastExamDone,a.DeleteFlag,a.CreateDate,(select [Name] from LookupItem where Id = a.SyphilisResults ) as SyphilisResults,ROW_NUMBER() OVER(Partition by a.PatientId,a.PatientMasterVisitId order by a.CreateDate desc)rownum 
	FROM            [dbo].[BaselineAntenatalCare] a INNER JOIN
							 dbo.PatientEncounter b  ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
							 dbo.LookupItem c ON c.Id = b.EncounterTypeId LEFT OUTER JOIN
							 dbo.LookupItem d ON d.Id = a.HivStatusBeforeAnc LEFT OUTER JOIN
							 dbo.LookupItem e ON e.Id = a.TreatedForSyphilis LEFT OUTER JOIN
							 dbo.LookupItem f ON f.Id = a.BreastExamDone
							 
	WHERE        (c.DisplayName = 'ANC-Encounter'))bac where bac.rownum=1
) BAC on BAC.PatientId=p.Id and d.Id = BAC.PatientMasterVisitId
left join   PatientVitals k on k.Id=p.Id and k.PatientMasterVisitId=d.Id
left outer join
		(SELECT  [PatientId] ,[PatientMasterVisitId] ,b.itemname [WHOStage]
		FROM [PatientWHOStage] a inner join lookupitemview b on b.itemid=a.[WHOStage])WHO on WHO.patientid=p.Id and WHO.PatientMasterVisitId=d.id
left join Pregnancy pri on pri.Id=p.Id and  pri.PatientMasterVisitId=d.Id
left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,lm.[Name] as ScreeningCategory,psc.ScreeningValueId,lt.DisplayName as [Value]
 from PatientScreening psc
 inner join LookupItem lt on lt.Id=psc.ScreeningValueId
 inner join LookupMaster lm on lm.Id=psc.ScreeningTypeId
where lm.[Name] = 'ViralLoadSampleTaken'
 )pscvs on pscvs.PatientId=p.Id and pscvs.PatientMasterVisitId=d.Id
 left join 
	(SELECT distinct e.PersonId, one.kitid AS OneKitId, one.kitlotNumber AS OneLotNumber, one.Outcome AS FinalTestOneResult, one.encountertype as encounterone,
		two.Outcome AS FinalTestTwoResult, one.expirydate AS OneExpiryDate, two.kitid AS twokitid, 
		two.kitlotnumber AS twolotnumber, two.expirydate AS twoexpirydate,one.encountertype as encountertwo,
		(select  DisplayName from LookupItem l where l.Id= e.FinalResultGiven) as FinalResultGiven
		FROM  Testing t INNER JOIN [HtsEncounter] e ON t .htsencounterid = e.id 
		left join  [dbo].[PatientEncounter] pe on pe.id=e.PatientEncounterID  inner join lookupitemview c on c.itemid=pe.EncounterTypeId
		left outer JOIN
		(SELECT   htsencounterid, b.ItemName kitid, kitlotnumber, expirydate, PersonId, l.ItemName AS outcome,e.encountertype
		FROM [Testing] t inner join  [HtsEncounter] e on t.HtsEncounterId=e.id inner join  [LookupItemView] l on l.itemid=t.Outcome
		inner join lookupitemview b on b.itemid=t.KitId inner join  [dbo].[PatientEncounter] pe on pe.id=e.PatientEncounterID  
		inner join lookupitemview c on c.itemid=pe.EncounterTypeId
		WHERE  e.encountertype = 1 and t.testround =1 and c.ItemName='anc-encounter') one ON one.personid = e.PersonId FULL OUTER JOIN
		(SELECT  htsencounterid, b.ItemName kitid, kitlotnumber, expirydate, PersonId, l.ItemName AS outcome,e.encountertype
		FROM  [Testing] t inner join  [HtsEncounter] e on t.HtsEncounterId=e.id inner join  [LookupItemView] l on l.itemid=t.Outcome
		inner join lookupitemview b on b.itemid=t.KitId inner join  [dbo].[PatientEncounter] pe on pe.id=e.PatientEncounterID  
		inner join lookupitemview c on c.itemid=pe.EncounterTypeId
		where t.testround =2 and c.ItemName='anc-encounter' ) two ON two.personid = e.PersonId
		where c.ItemName='anc-encounter')HIVTest on HIVTest.PersonId=p.PersonId 

 LEFT OUTER JOIN
                             (SELECT   distinct     he.PersonId, he.PatientEncounterID, lk.ItemName AS FinalResult
                               FROM            dbo.HtsEncounter AS he INNER JOIN
                                                         dbo.HtsEncounterResult AS her ON he.Id = her.HtsEncounterId INNER JOIN
                                                         dbo.PatientEncounter AS pe ON pe.Id = he.PatientEncounterID LEFT OUTER JOIN
                                                         dbo.LookupItemView AS lk1 ON lk1.ItemId = pe.EncounterTypeId LEFT OUTER JOIN
                                                         dbo.LookupItemView AS lk ON lk.ItemId = her.FinalResult
                               WHERE        (lk1.ItemName = 'ANC-Encounter')) AS z ON z.PersonId = p.PersonId
	left join 	(SELECT distinct  ps.PatientId,ps.PatientMasterVisitId, lk.ItemName AS TBScreening
	FROM dbo.PatientScreening ps left JOIN
	dbo.LookupItemView AS lv ON ps.ScreeningTypeId = lv.masterid left join
	dbo.LookupItemView AS lk ON ps.ScreeningValueId = lk.itemid
	WHERE lv.MasterName like'%TBScreeningPMTCT%') TBScreen on TBScreen.PatientId=p.Id and TBScreen.PatientMasterVisitId=d.Id
	LEFT JOIN	(SELECT  distinct  ps.PatientId,ps.PatientMasterVisitId,ps.Comment, lk.ItemName AS CaCxScreening,lvc.ItemName as CacxScreeningMethod
	FROM dbo.PatientScreening ps INNER JOIN
	dbo.LookupItemView AS lv ON ps.ScreeningTypeId = lv.masterid inner join
	dbo.LookupItemView AS lk ON ps.ScreeningValueId = lk.itemid left join
	dbo.LookupItemView as lvc on lvc.ItemId=ps.ScreeningCategoryId 
	WHERE lv.MasterName LIKE '%CaCxScreening%')CaCX on CaCX.PatientId=p.Id and CaCX.PatientMasterVisitId=d.Id 

left outer join 
	(SELECT distinct b.PatientId,b.PatientMasterVisitId,c.[ItemName] [CTX]
	FROM dbo.PatientDrugAdministration b inner join  [dbo].[LookupItemView]a  on b.DrugAdministered=a.itemid
	inner join [dbo].[LookupItemView]c on c.itemid=b.value
	where a.itemname ='Cotrimoxazole')CTX on CTX.PatientId=p.Id and CTX.PatientMasterVisitId=d.Id 

	Left Outer join
	(SELECT  distinct b.PatientId,b.PatientMasterVisitId,[ItemName] [AZT for Baby]
	FROM [dbo].[LookupItemView]a inner join dbo.PatientDrugAdministration b on b.value=a.itemid
	where description ='AZT for the baby dispensed')AZTBaby on AZTBaby.PatientId=p.Id and AZTBaby.PatientMasterVisitId=d.Id left outer join 
	(SELECT distinct  b.PatientId,b.PatientMasterVisitId,[ItemName] [NVP for Baby]
	FROM [dbo].[LookupItemView]a inner join dbo.PatientDrugAdministration b on b.value=a.itemid
	where description ='NVP for the baby dispensed')NVPBaby on NVPBaby.PatientId=p.Id and NVPBaby.PatientMasterVisitId=d.Id
 left join 
	(select distinct pcs.PatientId,pcs.PatientMasterVisitId,pcs.ItemName as ChronicIllness,pcs.OnsetDate from (SELECT  SS.PatientId,[PatientMasterVisitId],  lk.ItemName ,SS.OnsetDate,SS.CreateDate,ROW_NUMBER() OVER(Partition by SS.PatientId,SS.PatientMasterVisitId order by SS.CreateDate desc)rownum 
		FROM PatientChronicIllness SS inner join lookupitemview lk on lk.itemid=SS.ChronicIllness
		WHERE SS.PatientId = SS.PatientId and mastername ='ChronicIllness')pcs where pcs.rownum =1
		)pcs on pcs.PatientId=p.Id and pcs.PatientMasterVisitId=d.Id
	left join (select  distinct pcs.PatientId,pcs.PatientMasterVisitId,pcs.ItemName as CounselledTopic,pcs.CounsellingDate from (SELECT  SS.PatientId,[PatientMasterVisitId],  lk.ItemName ,SS.CounsellingDate,SS.CreateDate,ROW_NUMBER() OVER(Partition by SS.PatientId,SS.PatientMasterVisitId order by SS.CreateDate desc)rownum 
		FROM PatientCounselling SS inner join lookupitemview lk on lk.itemid=SS.CounsellingTopicId
		WHERE SS.PatientId = SS.PatientId and mastername ='counselledOn')pcs where pcs.rownum =1
		)pcouns on pcouns.PatientId=p.Id and pcouns.PatientMasterVisitId=d.Id

LEFT JOIN	(SELECT     distinct   a.PatientId, a.PatientMasterVisitId,d.itemname ReferredFrom, e.itemname ReferredTo
	FROM            dbo.PMTCTReferral a INNER JOIN
							 dbo.PatientEncounter b  ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
							 dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
							 dbo.LookupItemView d ON d.ItemId = a.ReferredFrom LEFT OUTER JOIN
							 dbo.LookupItemView e ON e.ItemId = a.ReferredTo
	WHERE        (c.ItemName = 'ANC-Encounter'))Refferals on Refferals.PatientId=p.Id and Refferals.PatientMasterVisitId=d.id
	LEFT JOIN (select distinct * from (select * ,ROW_NUMBER() OVER(partition by tc.PatientId,tc.PatientMasterVisitId order by tc.CreateDate desc)rownum 
	from(SELECT  [PatientMasterVisitId]
		  ,[PatientId]
		  ,[AppointmentDate]
		  ,[AppointmentReason]=(SELECT        TOP 1 ItemName
		  FROM            [dbo].[LookupItemView]
		  WHERE        ItemId = [ReasonId])
		  ,[Description]
		  ,DeleteFlag
		  ,CreateDate
	  FROM [dbo].[PatientAppointment]
	  where deleteflag = 0 and serviceareaid=3)
	  tc where tc.AppointmentReason='Follow Up')tc where tc.rownum=1
	  )TCAs on TCAs.PatientId=p.Id and TCAs.PatientMasterVisitId=d.Id 
	LEFT JOIN  (SELECT distinct[PatientId],[PatientMasterVisitId],lkup1.itemName [On ARV Before 1st ANC Visit],[Description]
		FROM [dbo].[PatientDrugAdministration] j  Left outer join dbo.LookupItemView lkup1 on lkup1.ItemId=j.Value 
		where [description] ='On ARV before 1st ANC Visit') j ON p.Id = j.PatientId AND d.Id = j.PatientMasterVisitId 
	left outer join 
	(SELECT DISTINCT b.PatientId,b.PatientMasterVisitId,c.[ItemName] [Started HAART in ANC]
	FROM dbo.PatientDrugAdministration b inner join  [dbo].[LookupItemView]a  on b.DrugAdministered=a.itemid
	inner join [dbo].[LookupItemView]c on c.itemid=b.value
	where b.[Description] ='Started HAART in ANC')HAARTANC on HAARTANC.PatientId=p.Id and HAARTANC.PatientMasterVisitId=d.Id

	-------------Treatment 
	left join (SELECT DISTINCT [PatientId] PatientId,PatientMasterVisitId,'Yes' [Deworming]
	FROM [dbo].[LookupItemView]a inner join [dbo].[PatientPreventiveServices] b on b.[PreventiveServiceid]=a.itemid
	where ItemName ='Dewormed')Dewormed on Dewormed.PatientId=p.Id and Dewormed.PatientMasterVisitId=d.Id left join 
	(SELECT DISTINCT [PatientId] PatientId,PatientMasterVisitId,[ItemName] TTDose
	FROM [dbo].[LookupItemView]a inner join [dbo].[PatientPreventiveServices] b on b.[PreventiveServiceid]=a.itemid
	where Itemname in('TT1','TT2','TT3','TT4','TT5'))TTDose on TTDose.PatientId=p.Id and TTDose.PatientMasterVisitId=d.Id left join 
	(SELECT DISTINCT [PatientId] PatientId,PatientMasterVisitId,[ItemName] IPT
	FROM [dbo].[LookupItemView]a inner join [dbo].[PatientPreventiveServices] b on b.[PreventiveServiceid]=a.itemid
	where Itemname in('IPTp1','IPTp2','IPTp3'))IPTDose on IPTDose.PatientId=p.Id and IPTDose.PatientMasterVisitId=d.Id left join 
	(SELECT DISTINCT [PatientId] PatientId,PatientMasterVisitId,'Yes' Supplementation
	FROM [dbo].[LookupItemView]a inner join [dbo].[PatientPreventiveServices] b on b.[PreventiveServiceid]=a.itemid
	where ItemName ='Folate'or ItemName='Calcium' or ItemName ='Iron'or ItemName ='Vitamins')Vitamins on Vitamins.PatientId=p.Id and Vitamins.PatientMasterVisitId=d.Id left join 
	(SELECT DISTINCT [PatientId]PatientId,PatientMasterVisitId,itemname ANC_Exercises
	FROM [dbo].[PatientPreventiveServices] b  inner join lookupitemview l on l.itemid=b.PreventiveServiceId
	where Description ='Antenatal exercise')ANC_Exercises on ANC_Exercises.PatientId=p.Id and ANC_Exercises.PatientMasterVisitId=d.Id left join 
	(SELECT DISTINCT [PatientId]PatientId,PatientMasterVisitId,itemname TreatedNets
	FROM [dbo].[PatientPreventiveServices] b inner join lookupitemview l on l.itemid=b.PreventiveServiceId 
	where Description ='Insecticide treated nets given')TreatedNets on TreatedNets.PatientId=p.Id and TreatedNets.PatientMasterVisitId=d.Id 
	left join 	(SELECT    distinct    a.PatientId, a.PatientMasterVisitId,d.itemname [PartnerTested], e.itemname [PartnerHIVResult]
	FROM            [dbo].[PatientPartnerTesting] a INNER JOIN
							 dbo.PatientEncounter b  ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
							 dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
							 dbo.LookupItemView d ON d.ItemId = a.[PartnerTested] LEFT OUTER JOIN
							 dbo.LookupItemView e ON e.ItemId = a.[PartnerHIVResult]
	WHERE        (c.ItemName = 'ANC-Encounter'))partnerTesting on partnerTesting.PatientId=p.Id and partnerTesting.PatientMasterVisitId=d.id
 
 
 
 
 --MCH Delivery
 
 

EXEC Pr_opendecryptedsession;


SELECT p.id AS Person_Id,
       d.visitdate AS Encounter_Date,
       NULL AS Encounter_ID,
       h.identifiervalue AS Admission_Number,
	   I.gestation AS Gestation_Weeks,
	   delivery.durationoflabour AS Duration_Labour,
       delivery.modeofdelivery AS Delivery_Mode,
       delivery.dateofdelivery AS Delivery_Date_Time,
	   delivery.placentacomplete,

       I.lmp,
       I.edd,
       I.ageatmenarche AS AgeAtMenarche,
       I.parity AS Parity,
       I.parity2 AS Plus,
       I.gravidae,
     
       pd.diagnosis AS Diagnosis,
       pd.managementplan AS ManagementPlan,
      
       delivery.timeofdelivery AS DeliveryTime,
       delivery.bloodlossclassification AS Blood_Loss,
       delivery.bloodlosscapacity AS [Blood_LossValue(mls)],
       delivery.mothercondition AS Mother_Condition,
    
       delivery.maternaldeathaudited AS Death_Audited,
       delivery.maternaldeathauditdate,
       CASE
           WHEN dbbi.resuscitationdone = 1 THEN 'Yes'
           WHEN dbbi.resuscitationdone = 0 THEN 'No'
           ELSE NULL
       END AS ResuscitationDone,
       delivery.deliverycomplicationsexperienced AS Delivery_Complications,
       NULL AS delivery_Complications_Type,
       delivery.deliverycomplicationnotes AS Deilvery_Complications_Other ,
       NULL Delivery_Place,
            delivery.deliveryconductedby AS Delivery_Conducted_By,
            NULL AS Delivery_Cadre,
            NULL AS Delivery_Outcome,
            PatOutcome.datedischarged AS Delivery_DischargeDate,
            NULL Baby_Name,
                 Baby_Sex=
  (SELECT TOP 1 itemname
   FROM [dbo].[lookupitemview]
   WHERE itemid = dbbi.sex),
                 dbbi.birthweight AS Baby_Weight,
                 PatOutcome.outcomestatus AS Baby_Condition,
                 CASE
                     WHEN dbbi.birthdeformity = 0 THEN 'No'
                     WHEN dbbi.birthdeformity = 1 THEN 'Yes'
                     ELSE NULL
                 END AS Birth_Deformity,
                 CASE
                     WHEN dbbi.teogiven = 0 THEN 'No'
                     WHEN dbbi.teogiven = 1 THEN 'Yes'
                     ELSE NULL
                 END AS TEO_Birth,
                 CASE
                     WHEN dbbi.breastfedwithinhr = 0 THEN 'No'
                     WHEN dbbi.breastfedwithinhr = 1 THEN 'Yes'
                     ELSE NULL
                 END AS BF_At_Birth_Less_1_hr,
                 apgar.apgar1min AS Apgar_1,
                 apgar.apgar5min AS Apgar_5,
                 apgar.apgar10min AS Apgar_10,
                 dbbi.birthnotificationnumber,
                 dbbi.birthcomments,
                 HIVTest.onekitid AS Test_1_kit_name,
                 HIVTest.onelotnumber AS Test_1_kit_lot_no,
                 HIVTest.oneexpirydate AS Test_1_kit_expiry,
                 HIVTest.finaltestoneresult AS Test_1_result,
                 HIVTest.twokitid AS Test_2_kit_name,
                 HIVTest.twolotnumber AS Test_2_kit_lot_no,
                 HIVTest.twoexpirydate AS Test_2_kit_expiry,
                 HIVTest.finaltesttworesult AS Test_2_result,
                 z.finalresult AS Final_test_Result,
                 HIVTest.testtype AS Test_Type,
                 HIVTest.finalresultgiven AS Patient_given_result,
                 partnerTesting.partnertested AS Partner_hiv_tested,
                 partnerTesting.partnerhivresult AS Partner_hiv_status,
                 NULL AS Next_HIV_Date,
                 tst.finding AS TestedForSyphillis,
                 tss.finding AS Syphillis_Treated,
                 CTX.ctx AS Prophylaxis_given,
                 [azt for baby] AS Baby_azt_dispensed,
                 [nvp for baby] AS Baby_nvp_dispensed,
                 HAARTMAT.[started haart mat],
                 HAARTANC.[started haart in anc],
                 VITS.[vitaminasupplementation],
                 TCAs.[description] AS Clinical_notes,
                 TCAs.appointmentdate AS Next_Appointment_Date,
                 d.deleteflag AS Voided 
FROM person p
INNER JOIN patient b ON b.personid = p.id
INNER JOIN patientmastervisit d ON b.id = d.patientid
INNER JOIN
  (SELECT a.patientid,
          enrollmentdate,
          identifiervalue,
          NAME,
          visitdate,
          patientmastervisitid,
          visittype,
          [visitnumber],
          [dayspostpartum]
   FROM patientenrollment a
   INNER JOIN servicearea b ON a.serviceareaid = b.id
   INNER JOIN patientidentifier c ON c.patientid = a.patientid
   INNER JOIN serviceareaidentifiers d ON c.identifiertypeid = d.identifierid
   AND b.id = d.serviceareaid
   INNER JOIN dbo.visitdetails AS g ON a.patientid = g.patientid
   AND b.id = g.serviceareaid
   WHERE b.NAME = 'Maternity') AS h ON b.id = h.patientid
AND d.id = h.patientmastervisitid
LEFT JOIN dbo.pregnancy AS I ON b.id = I.patientid
AND I.patientmastervisitid = h.patientmastervisitid
LEFT JOIN
  (SELECT DISTINCT delivery.deliveryid,
                   [patientmastervisitid],
                   [durationoflabour],
                   [dateofdelivery],
                   [timeofdelivery],
                   lkup2.itemname ModeOfDelivery,
                   lkup3.itemname [PlacentaComplete],
                   [bloodlosscapacity],
                   lkup4.itemname [MotherCondition],
                   lkup.itemname [DeliveryComplicationsExperienced],
                   [deliverycomplicationnotes],
                   [deliveryconductedby],
                   [maternaldeathauditdate],
                   lt.[name] AS MaternalDeathAudited,
                   lkbl.itemname AS [BloodLossClassification]
   FROM dbo.patientdelivery AS delivery
   LEFT JOIN dbo.lookupitemview AS lkup2 ON lkup2.itemid = delivery.[modeofdelivery]
   LEFT JOIN dbo.lookupitemview AS lkup3 ON lkup3.itemid = delivery.[placentacomplete]
   LEFT JOIN dbo.lookupitemview AS lkup4 ON lkup4.itemid = delivery.[mothercondition]
   LEFT JOIN dbo.lookupitemview AS lkup ON lkup.itemid = delivery.[deliverycomplicationsexperienced]
   LEFT JOIN dbo.lookupitemview AS lkbl ON lkbl.itemid = delivery.bloodlossclassification
   LEFT JOIN lookupitem lt ON lt.id = delivery.maternaldeathaudited) delivery ON delivery.patientmastervisitid = d.id
LEFT JOIN dbo.deliveredbabybirthinformation dbbi ON dbbi.patientmastervisitid = d.id
AND delivery.deliveryid = dbbi.deliveryid
LEFT JOIN
  (SELECT b.patientid,
          [patientmastervisitid],
          [datedischarged],
          [OutcomeStatus]=
     (SELECT TOP 1 itemname
      FROM [dbo].[lookupitemview]
      WHERE itemid = a.[outcomestatus]),
          [outcomedescription]
   FROM [dbo].[patientoutcome]a
   INNER JOIN patientmastervisit b ON a.patientmastervisitid = b.id
   WHERE a.deleteflag = 0)PatOutcome ON PatOutcome.patientid = b.id
AND PatOutcome.patientmastervisitid = d.id
LEFT JOIN
  (SELECT deliveredbabybirthinformationid,
          Max(apgar1min)APGAR1min,
          Max(apgar1min)APGAR5min,
          Max(apgar1min)APGAR10min
   FROM
     (SELECT a.id,
             a.[deliveredbabybirthinformationid],
             APGAR1min=
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 1 min') ,
             APGAR5min=
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 5 min') ,
             APGAR10min =
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 10 min')
      FROM [dbo].[deliveredbabyapgarscore] a
      INNER JOIN [dbo].[deliveredbabybirthinformation]b ON a.[deliveredbabybirthinformationid] = b.[id])a GROUP  BY deliveredbabybirthinformationid)apgar ON apgar.deliveredbabybirthinformationid = dbbi.id
LEFT OUTER JOIN ------------------HIV tests

  (SELECT DISTINCT e.personid,
                   Isnull(Cast((CASE e.encountertype
                                    WHEN 1 THEN 'Initial Test'
                                    WHEN 2 THEN 'Repeat Test'
                                END) AS VARCHAR(50)), 'Initial') AS TestType,
                   one.kitid AS OneKitId,
                   one.kitlotnumber AS OneLotNumber ,
                   one.outcome AS FinalTestOneResult,
                   one.encountertype AS encounterone ,
                   two.outcome AS FinalTestTwoResult,
                   one.expirydate AS OneExpiryDate,
                   two.kitid AS twokitid,
                   two.kitlotnumber AS twolotnumber ,
                   two.expirydate AS twoexpirydate,
                   one.encountertype AS encountertwo ,
                   FinalResultGiven =
     (SELECT TOP 1 itemname
      FROM [dbo].[lookupitemview]
      WHERE itemid = e.finalresultgiven)
   FROM testing t
   INNER JOIN [htsencounter] e ON t .htsencounterid = e.id
   LEFT JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
   INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
   LEFT OUTER JOIN
     (SELECT DISTINCT htsencounterid,
                      b.itemname kitid,
                      kitlotnumber,
                      expirydate,
                      personid,
                      l.itemname AS outcome,
                      e.encountertype
      FROM [testing] t
      INNER JOIN [htsencounter] e ON t.htsencounterid = e.id
      INNER JOIN [lookupitemview] l ON l.itemid = t.outcome
      INNER JOIN lookupitemview b ON b.itemid = t.kitid
      INNER JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
      INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
      WHERE e.encountertype = 1
        AND t.testround = 1
        AND c.itemname = 'maternity-encounter') one ON one.personid = e.personid
   FULL OUTER JOIN
     (SELECT DISTINCT htsencounterid,
                      b.itemname kitid,
                      kitlotnumber,
                      expirydate,
                      personid,
                      l.itemname AS outcome,
                      e.encountertype
      FROM [testing] t
      INNER JOIN [htsencounter] e ON t.htsencounterid = e.id
      INNER JOIN [lookupitemview] l ON l.itemid = t.outcome
      INNER JOIN lookupitemview b ON b.itemid = t.kitid
      INNER JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
      INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
      WHERE t.testround = 2
        AND c.itemname = 'maternity-encounter') two ON two.personid = e.personid
   WHERE c.itemname = 'maternity-encounter')HIVTest ON HIVTest.personid = b.personid
LEFT OUTER JOIN
  (SELECT he.personid,
          he.patientencounterid,
          lk.itemname AS FinalResult
   FROM dbo.htsencounter AS he
   INNER JOIN dbo.htsencounterresult AS her ON he.id = her.htsencounterid
   INNER JOIN dbo.patientencounter AS pe ON pe.id = he.patientencounterid
   LEFT OUTER JOIN dbo.lookupitemview AS lk1 ON lk1.itemid = pe.encountertypeid
   LEFT OUTER JOIN dbo.lookupitemview AS lk ON lk.itemid = her.finalresult
   WHERE (lk1.itemname = 'Maternity')) AS z ON z.personid = b.personid
LEFT OUTER JOIN
  (SELECT DISTINCT a.patientid,
                   a.patientmastervisitid,
                   d.itemname [PartnerTested],
                   e.itemname [PartnerHIVResult]
   FROM [dbo].[patientpartnertesting] a
   INNER JOIN dbo.patientencounter b ON a.patientmastervisitid = b.patientmastervisitid
   LEFT OUTER JOIN dbo.lookupitemview c ON c.itemid = b.encountertypeid
   LEFT OUTER JOIN dbo.lookupitemview d ON d.itemid = a.[partnertested]
   LEFT OUTER JOIN dbo.lookupitemview e ON e.itemid = a.[partnerhivresult]
   WHERE (c.itemname = 'maternity-encounter')) partnerTesting ON partnerTesting.patientid = b.id
AND partnerTesting.patientmastervisitid = d.id
LEFT JOIN
  (SELECT b.id PatientId,
          [orderedbydate],
          [reportedbydate],
          [testresults],
          [testresults1],
          [visitdate]
   FROM [dbo].[vw_patientlaboratory] a
   INNER JOIN patient b ON b.ptn_pk = a.ptn_pk
   WHERE testname LIKE '%RPR%'
     AND hasresult = 1)RPRLab ON RPRLab.patientid = b.id
AND RPRLab.orderedbydate = d.[visitdate]
LEFT JOIN
  (SELECT pe.patientid,
          pe.patientmastervisitid,
          pe.examinationtypeid,
          lm.[name] AS ExaminationType,
          pe.examid,
          lt.[name] AS ExaminationName,
          pe.findingid AS FindingId,
          ltf.[name] AS Finding,
          pe.deleteflag,
          pe.createby
   FROM physicalexamination pe
   LEFT JOIN lookupmaster lm ON lm.id = pe.examinationtypeid
   INNER JOIN lookupitem lt ON lt.id = pe.examid
   LEFT JOIN lookupitem ltf ON ltf.id = pe.findingid
   WHERE lt.[name] = 'Treated Syphilis')tss ON tss.patientid = b.id
AND tss.patientmastervisitid = d.id
LEFT JOIN
  (SELECT pe.patientid,
          pe.patientmastervisitid,
          pe.examinationtypeid,
          lm.[name] AS ExaminationType,
          pe.examid,
          lt.[name] AS ExaminationName,
          pe.findingid AS FindingId,
          ltf.[name] AS Finding,
          pe.deleteflag,
          pe.createby
   FROM physicalexamination pe
   LEFT JOIN lookupmaster lm ON lm.id = pe.examinationtypeid
   INNER JOIN lookupitem lt ON lt.id = pe.examid
   LEFT JOIN lookupitem ltf ON ltf.id = pe.findingid
   WHERE lt.[name] = 'Treated For Syphilis') tst ON tst.patientid = b.id
AND tst.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [CTX]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE a.itemname = 'Cotrimoxazole')CTX ON CTX.patientid = b.id
AND CTX.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   [itemname] [AZT for Baby]
   FROM [dbo].[lookupitemview]a
   INNER JOIN dbo.patientdrugadministration b ON b.value = a.itemid
   WHERE description = 'AZT for the baby dispensed'
     OR description = 'Infant Provided With ARV prophylaxis' )AZTBaby ON AZTBaby.patientid = b.id
AND AZTBaby.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   [itemname] [NVP for Baby]
   FROM [dbo].[lookupitemview]a
   INNER JOIN dbo.patientdrugadministration b ON b.value = a.itemid
   WHERE description = 'NVP for the baby dispensed') NVPBaby ON NVPBaby.patientid = b.id
AND NVPBaby.patientmastervisitid = d.id
LEFT JOIN
  (SELECT DISTINCT *
   FROM
     (SELECT *,
             Row_number() OVER(PARTITION BY tc.patientid, tc.patientmastervisitid
                               ORDER BY tc.createdate DESC)rownum
      FROM
        (SELECT [patientmastervisitid],
                [patientid],
                [appointmentdate],
                [AppointmentReason]=
           (SELECT TOP 1 itemname
            FROM [dbo].[lookupitemview]
            WHERE itemid = [reasonid]),
                [description],
                deleteflag,
                createdate
         FROM [dbo].[patientappointment]
         WHERE deleteflag = 0
           AND serviceareaid = 3) tc
      WHERE tc.appointmentreason = 'Follow Up')tc
   WHERE tc.rownum = 1)TCAs ON TCAs.patientid = b.id
AND TCAs.patientmastervisitid = d.id
LEFT JOIN
  (SELECT *
   FROM patientdiagnosis pd
   WHERE (pd.deleteflag IS NULL
          OR pd.deleteflag = 0))pd ON pd.patientmastervisitid = d.id
AND pd.patientid = b.id
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [Started HAART in ANC]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'Started HAART in ANC')HAARTANC ON HAARTANC.patientid = b.id
AND HAARTANC.patientmastervisitid = d.id
LEFT OUTER JOIN dbo.patientdiagnosis AS diag ON diag.patientmastervisitid = d.id
LEFT OUTER JOIN dbo.patientvitals AS k ON d.id = k.patientmastervisitid
AND b.id = k.patientid
AND k.visitdate = d.visitdate
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [Started HAART MAT]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'ARVs Started in Maternity')HAARTMAT ON HAARTMAT.patientid = b.id
AND HAARTMAT.patientmastervisitid = d.id
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [VitaminASupplementation]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'Vitamin A Supplementation')VITS ON VITS.patientid = b.id
AND VITS.patientmastervisitid = d.id



---PNCVisit
-- 20.  MCH PNC Visit
EXEC Pr_opendecryptedsession;
SELECT distinct
b.PersonId as Person_Id,
h.VisitDate as Encounter_Date,
NULL as Encounter_ID,
h.IdentifierValue AS [PNC_Register_Number],
h.VisitNumber as PNC_VisitNumber,
delivery.DateOfDelivery as Delivery_Date,
lkdel.itemName Mode_Of_Delivery,
''Place_Of_Delivery,
k.Temperature,
k.[HeartRate] as Pulse_rate,
k.BPSystolic as Systolic_bp,
k.BPDiastolic as Diastolic_bp,
k.RespiratoryRate as Respiratory_rate,
k.SpO2 as Oxygen_Saturation,
k.[Weight],
k.Height,
k.BMI,
k.Muac,
NULL as General_Condition,
pallor.Pallor,
breast.Breast as Breast_Examination,
PPH.PPH as PPH,
C_SectionSite.C_SectionSite as CS_Scar,
NUll AS Haemoglobin,
Uterus.Uterus as Involution_Of_Uterus,
Episiotomy.Episiotomy as Condition_Of_Episiotomy,
Lochia.Lochia,
pcc.Counselling as Counselling_On_Infant_Feeding,
NULL Counselling_On_FamilyPlanning,
NULL Delivery_Outcome,
bcc.babyCondition as Baby_Condition,
Breastfeeding.Breastfeeding as Breast_Feeding,
NULL as Feeding_Method,
NULL as Umblical_Cord,
NULL as Immunization_Started
,case when h.[DaysPostPartum] between 0 and 2 then 1 when h.[DaysPostPartum] between 3 and 30 then 2 when h.[DaysPostPartum] between 31 and 44 then 3 end as [DaysPostPartum],
HIVTest.OneKitId as Test_1_kit_name,
HIVTest.OneLotNumber as Test_1_kit_lot_no,
HIVTest.OneExpiryDate as Test_1_kit_expiry,
HIVTest.FinalTestOneResult as Test_1_result
,HIVTest.twokitid as Test_2_kit_name
,HIVTest.twolotnumber as Test_2_kit_lot_no,
HIVTest.twoexpirydate as Test_2_kit_expiry
,HIVTest.FinalTestTwoResult as Test_2_result
,z.FinalResult as Final_test_result,
HIVTest.TestType as Test_type,
HIVTest.FinalResultGiven as Patient_given_result,
partnerTesting.[PartnerTested] as Partner_hiv_Tested,
partnerTesting.[PartnerHIVResult] as Partner_hiv_status,
CTX.CTX as Prophylaxis_given ,
[AZT for Baby] [Baby_azt_dispensed],
[NVP for Baby] [Baby_nvp_dispensed],
[Started HAART PNC] as HAART_PNC,
PNCExercise as Pnc_exercises,
NULL Maternal_Condition,
hae.hae as Iron_Supplementation,
Cacx.Results [Cacx_screening],
Cacx.ScreeningCategory [Cacx_screening_method],
Fistula_Screening.Fistula_Screening,
pfp.FamilyPlanning as On_FP,
----Remember <=6wks and >6wks
FP.FP as FP_Method ,
ref.ReferredFrom as Referred_From,ref.ReferredTo as Referred_To
,diag.Diagnosis as Diagnosis
,TCAs.[Description] as Clinical_notes,
TCAs.AppointmentDate as Next_Appointment_Date
FROM
dbo.Patient AS b INNER JOIN
dbo.PatientMasterVisit AS d ON b.Id = d.PatientId INNER JOIN
(select a.patientID,EnrollmentDate,IdentifierValue,Name,Visitdate,PatientMasterVisitId,
VisitType ,[VisitNumber] ,[DaysPostPartum] from PatientEnrollment a
inner join ServiceArea b on a.ServiceAreaId=b.id
inner join PatientIdentifier c on c.PatientId=a.PatientId
inner join ServiceAreaIdentifiers d on c.IdentifierTypeId=d.IdentifierId and b.id=d.ServiceAreaId
inner join dbo.VisitDetails AS g ON a.PatientId = g.PatientId AND b.Id = g.ServiceAreaId
where b.name='PNC') AS h ON b.ID = h.patientID and d.Id = h.PatientMasterVisitId
LEFT OUTER JOIN
(SELECT DISTINCT b.PatientId,b.PatientMasterVisitId,c.[ItemName] [Started HAART PNC]
FROM dbo.PatientDrugAdministration b inner join [dbo].[LookupItemView]a on b.DrugAdministered=a.itemid
inner join [dbo].[LookupItemView]c on c.itemid=b.value
where b.[Description] ='Started HAART in PNC')HAARTPNC on HAARTPNC.PatientId=b.Id and HAARTPNC.PatientMasterVisitId=d.Id left outer join
dbo.PatientDiagnosis AS diag ON diag.PatientMasterVisitId = d.Id LEFT OUTER JOIN
dbo.PatientVitals AS k ON d.VisitDate = k.VisitDate AND b.Id = k.PatientId LEFT OUTER JOIN
dbo.PatientDelivery AS delivery ON delivery.PatientMasterVisitID = d.Id left JOIN
dbo.LookupItemView AS lkdel ON lkdel.ItemId = delivery.[ModeOfDelivery] LEFT OUTER JOIN
dbo.PatientOutcome AS outc ON outc.PatientMasterVisitID = d.Id LEFT OUTER JOIN
dbo.DeliveredBabyBirthInformation AS baby ON baby.PatientMasterVisitId = d.Id Left Outer join
(SELECT DISTINCT b.PatientId,b.PatientMasterVisitId,case when [ItemName] in ('Start','Continue') then 'Yes' else [ItemName] end as [AZT for Baby]
FROM [dbo].[LookupItemView]a inner join dbo.PatientDrugAdministration b on b.value=a.itemid
where description like'%AZT%')AZTBaby on AZTBaby.PatientId=b.Id and AZTBaby.PatientMasterVisitId=d.Id left outer join
(SELECT DISTINCT b.PatientId,b.PatientMasterVisitId,case when [ItemName] in ('Start','Continue') then 'Yes' else [ItemName] end as [NVP for Baby]
FROM [dbo].[LookupItemView]a inner join dbo.PatientDrugAdministration b on b.value=a.itemid
where description like'%NVP%')NVPBaby on NVPBaby.PatientId=b.Id and NVPBaby.PatientMasterVisitId=d.Id
left join (select distinct patientid,PatientMasterVisitId,b.ItemName as PNCExercise from PatientPncExercises a inner join lookupitemview b on b.itemid=PncExercisesDone)PncExer on d.ID=pncexer.PatientMasterVisitId and b.id=pncexer.PatientID
left outer join
(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Breast
from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Breast') breast on d.id=breast.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Uterus from [dbo].[PhysicalExamination] a
inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Uterus')Uterus on d.id=Uterus.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName as PPH
from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='PostPartumHaemorrhage')PPH on d.id=PPH.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Lochia from [dbo].[PhysicalExamination] a
inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Lochia')Lochia on d.id=Lochia.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Pallor from [dbo].[PhysicalExamination] a
inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Pallor')Pallor on d.id=Pallor.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName as Episiotomy from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Episiotomy')Episiotomy on d.id=Episiotomy.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as C_SectionSite from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='C_SectionSite')C_SectionSite on d.id=C_SectionSite.[PatientMasterVisitId] LEFT OUTER JOIN
(select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName as BabyCondition
from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='babycondition') bcc on
bcc.PatientId =b.Id and bcc.PatientMasterVisitId=d.Id

left Outer Join (select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Fistula_Screening
from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Fistula_Screening')Fistula_Screening on d.id=Fistula_Screening.[PatientMasterVisitId] LEFT OUTER JOIN

(select distinct [PatientId],[PatientMasterVisitId], lkup1.ItemName as Breastfeeding from [dbo].[PhysicalExamination] a
inner join lookupitemview lkup on lkup.itemid=a.ExamId inner join lookupitemview lkup1 on lkup1.itemid=a.FindingId where lkup.itemname='Breastfeeding')Breastfeeding on d.id=Breastfeeding.[PatientMasterVisitId] LEFT OUTER JOIN
(SELECT distinct a.PatientId, a.PatientMasterVisitId,d.itemname [PartnerTested], e.itemname [PartnerHIVResult]
FROM [dbo].[PatientPartnerTesting] a INNER JOIN
dbo.PatientEncounter b ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
dbo.LookupItemView d ON d.ItemId = a.[PartnerTested] LEFT OUTER JOIN
dbo.LookupItemView e ON e.ItemId = a.[PartnerHIVResult]
WHERE (c.ItemName = 'pnc-encounter'))partnerTesting on partnerTesting.PatientId=b.Id and partnerTesting.PatientMasterVisitId=d.id
left join (select pfp.PatientId,pfp.PatientMasterVisitId,pfp.FamilyPlanningStatusId,CASE WHEN lt.[Name]= 'NOFP' then 'No' when lt.[Name]='FP' then 'Yes' end as FamilyPlanning from PatientFamilyPlanning pfp
inner join LookupItem lt on lt.Id=pfp.FamilyPlanningStatusId) pfp on pfp.PatientId=b.Id and pfp.PatientMasterVisitId=d.Id
left outer join
(SELECT a.[PatientId],b.ItemName FP,PatientMasterVisitId FROM [dbo].[PatientFamilyPlanningMethod] a inner join lookupitemview b on b.ItemId=a.[FPMethodId] inner join [PatientFamilyPlanning]c on c.[Id]=a.PatientFPId
inner join [PatientMasterVisit] d on d.[Id]=c.[PatientMasterVisitId] where b.ItemName not in ('UND') or [FPMethodId] is null)FP on FP.PatientId=b.Id and FP.PatientMasterVisitId=d.id left outer join
(SELECT distinct [PatientId],[PatientMasterVisitId],[ScreeningDate],c.Itemname ScreeningCategory,d.itemname Results,[VisitDate]
FROM [dbo].[PatientScreening] a inner join lookupitemview b on b.masterid=a.[ScreeningTypeId]
inner join lookupitemview c on c.itemid=a.[ScreeningCategoryId] inner join lookupitemview d on d.itemid=a.[ScreeningValueId]
where b.mastername='CacxMethod')Cacx on Cacx.PatientId=b.Id and Cacx.PatientMasterVisitId=d.id left join

(SELECT DISTINCT
e.PersonId, one.kitid AS OneKitId, one.KitLotNumber AS OneLotNumber, one.outcome AS FinalTestOneResult,ISNULL(CAST((CASE e.EncounterType WHEN 1 THEN 'Initial Test' WHEN 2 THEN 'Repeat Test' END) AS VARCHAR(50)),'Initial') AS TestType, FinalResultGiven = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = e.FinalResultGiven),
two.outcome AS FinalTestTwoResult, one.ExpiryDate AS OneExpiryDate, two.kitid AS twokitid,
two.KitLotNumber AS twolotnumber, two.ExpiryDate AS twoexpirydate
FROM dbo.Testing AS t INNER JOIN
dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id FULL OUTER JOIN
(SELECT DISTINCT t.HtsEncounterId, b.ItemName AS kitid, t.KitLotNumber, t.ExpiryDate, e.PersonId, l.ItemName AS outcome
FROM dbo.Testing AS t INNER JOIN
dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id INNER JOIN
dbo.LookupItemView AS l ON l.ItemId = t.Outcome INNER JOIN
dbo.LookupItemView AS b ON b.ItemId = t.KitId INNER JOIN
dbo.PatientEncounter AS pe ON pe.Id = e.PatientEncounterID LEFT OUTER JOIN
dbo.LookupItemView AS lk ON lk.ItemId = pe.EncounterTypeId
WHERE (t.TestRound = 1) AND (lk.ItemName = 'pnc-encounter')) AS one ON one.PersonId = e.PersonId FULL OUTER JOIN
(SELECT DISTINCT t.HtsEncounterId, b.ItemName AS kitid, t.KitLotNumber, t.ExpiryDate, e.PersonId, l.ItemName AS outcome
FROM dbo.Testing AS t INNER JOIN
dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id INNER JOIN
dbo.LookupItemView AS l ON l.ItemId = t.Outcome INNER JOIN
dbo.LookupItemView AS b ON b.ItemId = t.KitId INNER JOIN
dbo.PatientEncounter AS pe ON pe.Id = e.PatientEncounterID LEFT OUTER JOIN
dbo.LookupItemView AS lk ON lk.ItemId = pe.EncounterTypeId
WHERE (t.TestRound = 2) AND (lk.ItemName = 'pnc-encounter')) AS two ON two.PersonId = e.PersonId) AS HIVTest ON HIVTest.PersonId = b.PersonId LEFT OUTER JOIN
(SELECT he.PersonId, he.PatientEncounterID, lk.ItemName AS FinalResult
FROM dbo.HtsEncounter AS he INNER JOIN
dbo.HtsEncounterResult AS her ON he.Id = her.HtsEncounterId INNER JOIN
dbo.PatientEncounter AS pe ON pe.Id = he.PatientEncounterID LEFT OUTER JOIN
dbo.LookupItemView AS lk1 ON lk1.ItemId = pe.EncounterTypeId LEFT OUTER JOIN
dbo.LookupItemView AS lk ON lk.ItemId = her.FinalResult
WHERE (lk1.ItemName = 'pnc-encounter')) AS z ON z.PersonId = b.PersonId
left join (select pc.PatientId,pc.PatientMasterVisitId,lt.[Name],CASE WHEN pc.CounsellingTopicId  = 0 then 'No' when pc.CounsellingTopicId > 0 then 'Yes' end as Counselling,pc.CounsellingTopicId,pc.CounsellingDate
 from PatientCounselling pc
 inner join LookupItem lt on lt.Id=pc.CounsellingTopicId where [Name]='Infant Feeding'
)pcc on pcc.PatientId=b.Id and pcc.PatientMasterVisitId=d.Id
left outer join
(SELECT distinct b.PatientId,b.PatientMasterVisitId,c.[ItemName] [CTX]
FROM dbo.PatientDrugAdministration b inner join [dbo].[LookupItemView]a on b.DrugAdministered=a.itemid
inner join [dbo].[LookupItemView]c on c.itemid=b.value
where a.itemname ='Cotrimoxazole')CTX on CTX.PatientId=b.Id and CTX.PatientMasterVisitId=d.Id

left outer join
(SELECT distinct b.PatientId,b.PatientMasterVisitId,c.[ItemName] [hae]
FROM dbo.PatientDrugAdministration b inner join [dbo].[LookupItemView]a on b.DrugAdministered=a.itemid
inner join [dbo].[LookupItemView]c on c.itemid=b.value
where a.itemname ='Haematinics given')hae on hae.PatientId=b.Id and hae.PatientMasterVisitId=d.Id
left join (SELECT distinct a.PatientId, a.PatientMasterVisitId,d.itemname ReferredFrom, e.itemname ReferredTo
FROM dbo.PMTCTReferral a INNER JOIN
dbo.PatientEncounter b ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
dbo.LookupItemView d ON d.ItemId = a.ReferredFrom LEFT OUTER JOIN
dbo.LookupItemView e ON e.ItemId = a.ReferredTo
)ref on ref.PatientId=b.Id and ref.PatientMasterVisitId=d.Id

LEFT JOIN (select distinct * from (select *,ROW_NUMBER() OVER(partition by tc.PatientId,tc.PatientMasterVisitId order by tc.CreateDate desc)rownum
from(SELECT [PatientMasterVisitId]
,[PatientId]
,[AppointmentDate]
,[AppointmentReason]=(SELECT TOP 1 ItemName
FROM [dbo].[LookupItemView]
WHERE ItemId = [ReasonId])
,[Description]
,DeleteFlag
,CreateDate
FROM [dbo].[PatientAppointment]
where deleteflag = 0 and serviceareaid=3)
tc where tc.AppointmentReason='Follow Up')tc where tc.rownum=1
)TCAs on TCAs.PatientId=b.Id and TCAs.PatientMasterVisitId=d.Id
WHERE (h.Name = 'PNC')

---Hei Visit st_hei_enrollment 

exec pr_OpenDecryptedSession;
select distinct p.PersonId as Person_Id,
v.VisitDate as Encounter_Date,
   NULL as Encounter_ID,   
  NULL as Gestation_at_birth,
  he.BirthWeight as Birth_weight,
  NULL as Child_exposed,
  pid.IdentifierValue as Hei_id_number,
  NULL Spd_number,
  NULL Birth_length,
  NULL Birth_order,
  NULL Birth_type,
(select lt.[Name] from LookupItem lt where lt.Id=he.PlaceOfDeliveryId) as Place_of_delivery,
(select lt.[Name] from LookupItem lt where lt.Id=he.ModeOfDeliveryId) as Mode_of_delivery,
Birth_notification_number =(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthNotification' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
Date_birth_notification_number_issued =(select top 1 pdd.CreateDate from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthNotification' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
Birth_certificate_number =(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthCertificate' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ) ,
pe.EnrollmentDate as Date_first_enrolled_in_hei_care,
NULL Birth_registration_place,
pe.EnrollmentDate as Birth_registration_date,
mf.FacilityName as  Health_Facility_name,
he.MotherName AS Mothers_name,
NULL as Fathers_name,
NULL as Guardians_name,
NULL as Community_HealthWorkers_name,
NULL as Alternative_Contact_name,
NULL as Contacts_For_Alternative_Contact,
NULL as Need_for_special_care,
NULL as Reason_for_special_care,
NULL as Hiv_status_at_exit,
CASE WHEN pif.ContactWithTb='1' then 'Yes' when pif.ContactWithTB='0' then 'No'
else NULL end as TB_contact_history_in_household,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherStatusId) as Mother_alive,
hf.Feeding as Mother_breastfeeding,
hf.InfantFeeding as Mother_breastfeeding_mode,
NULL Referral_source,
NULL Transfer_in,
NULL Transfer_in_date,
NULL as Facility_transferred_from,
NULL as District_transferred_from,
NULL as Mother_on_NVP_during_breastfeeding,
NULL as Infant_mother_link,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherPMTCTDrugsId) as Mother_on_pmtct_drugs,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherPMTCTRegimenId) as Mother_on_pmtct_drugs_regimen,
he.MotherPMTCTRegimenOther as Mother_on_pmtct_other_regimen ,
(select lt.[Name] from LookupItem lt where lt.Id=he.MotherArtInfantEnrolId) as Mother_on_art_at_infant_enrollment,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherArtInfantEnrolRegimenId) as Mother_drug_regimen,
(select  lt.[Name] from LookupItem lt where lt.Id=he.ArvProphylaxisId) as Child_arv_prophylaxis,
he.ArvProphylaxisOther as Infant_prophylaxis_other,
he.MotherCCCNumber as Mother_ccc_number,
pcr.OrderedByDate as Date_sample_collected,
NULL as  Exit_date_result_collected,
CASE WHEN vt.Vaccine is not null then 'Yes' else NULL end  as Immunization_given,
vt.VaccineDate as  Date_immunized,
TCAs.AppointmentDate as Date_of_next_appointment,
NULL as Revisit_this_year,
(select lt.[Name]  from LookupItem lt where lt.Id=he.PrimaryCareGiverID) as Primary_care_giver,
pvs.Muac as MUAC,
NULL as Exclusive_breastfeeding_0_6_Months,
NULL as Stunted,
NULL as Medication_Given_If_HIV_Exposed,
tbs.ScreeningValue as  TB_screening_outcome,
pml.MilestoneType as Development_milestones_by_age,
pml.[Status] as Achieving_milestones,
NULL as Weight_category,
NULL as Type_of_follow_up ,
NULL as  Test_contextual_status,
NULL as  Contextual_status_results,
NULL as First_DBS_sample_code,
NULL Date_first_DBS_sample_code_result_collected,
hrt.TestResults as First_antibody_test,
hrt.ReportedByDate as Date_first_antibody_test,


NULL as  First_DBS_sample_code_result,
NULL as  Final_DBS_sample_code,
NULL as  Date_Final_DBS_Sample_Code_Result_collected,
NULL as  Final_Antibody_test,
NULL as  Date_Final_Antibody_test,
NULL as  Final_DBS_Sample_Code_Result,
NULL as  DBS_Sample_Code,
NULL as  Date_DBS_Sample_Code_Result_collected,
NULL as  Tetracycline_Eye_Ointment,
NULL Pupil,
NULL Sight,
NULL Squint,
NULL Deworming_and_Vitamin_A_supp,
NULL Deworming_Next_Visit,
NULL Deworming_Drug,
NULL Deworming_Dosage_Units,
NULL Vitamin_A,
NULL Any_disability,
NULL Clinicians_notes,
NULL Counselled_On,
NULL Supplemented_with_MNPS_6_23_Months,
NULL Physical_features_colouration,
vt.Immunization as Immunization_vaccine,
NULL Immunization_Batch_num,
NULL Immunization_Expiry_Date,
NULL Immunization_Dose,
vt.VaccineDate as Immunization_Date_Given,
NULL Immunization_BCG_scar_checked,
NULL Immunization_BCG_date_checked,
NULL Immunization_BCG_repeated,
NULL Immunization_Vitamin_capsule_given_dose ,
NULL Immunization_Vitamin_capsule_given,     
NULL Immunization_Vitamin_capsule_date_given,
NULL Immunization_Vitamin_capsule_date_of_Next_visit , 
NULL Immunization_Vitamin_capsule_fully_immunized_child, 
NULL Immunization_Vitamin_capsule_date_given_last_vaccine,
CASE WHEN he.Outcome24MonthId > 0 then v.VisitDate  else NULL end as Child_Hei_Outcomes_Exit_date,			
(select lt.[Name]  from LookupItem lt where lt.Id=he.Outcome24MonthId)as	Child_Hei_Outcomes_HIV_Status	
from   dbo.PatientMasterVisit AS v INNER JOIN
                         dbo.Patient AS p ON v.PatientId = p.Id INNER JOIN
						  dbo.mst_Patient AS mp ON mp.Ptn_Pk = p.ptn_pk INNER JOIN
                         dbo.PatientEnrollment AS pe ON p.Id = pe.PatientId INNER JOIN
                         dbo.PatientIdentifier AS pid ON p.Id = pid.PatientId INNER JOIN
						   Person  per on per.Id=p.PersonId INNER JOIN
                         dbo.HEIEncounter AS he ON v.Id = he.PatientMasterVisitId
						 left join mst_Facility mf on mf.PosID=mf.FacilityID and (mf.DeleteFlag = 0 or mf.DeleteFlag is null)
						 left join PatientIcf pif on pif.PatientId=p.Id and pif.PatientMasterVisitId=he.PatientMasterVisitId
						 left join(select hf.PatientId,hf.PatientMasterVisitId,hf.FeedingModeId,lt.[Name] as InfantFeeding,
						 CASE WHEN lt.[Name]='Not Breastfeeding' then 'No'
						 when lt.[Name] is not null  and lt.[Name] !='Not Breastfeeding' then 'Yes'
						 else null end as Feeding
						  from  HEIFeeding hf
						  left join LookupItem lt on lt.Id=hf.FeedingModeId)hf
						   on hf.PatientId=p.Id and hf.PatientMasterVisitId=he.PatientMasterVisitId
						   left join (	Select	O.Id				LabId
		,o.Ptn_Pk
		,o.PatientMasterVisitId
		,o.PatientId
		,O.LocationId
		,O.OrderedBy		OrderedByName
		,O.OrderNumber
		,o.OrderDate		OrderedByDate
		,Ot.ResultBy		ReportedByName
		,OT.ResultDate		ReportedByDate
		,O.OrderedBy		CheckedbyName
		,o.OrderDate		CheckedbyDate
		,O.PreClinicLabDate
		,LT.ParameterName	TestName
		,LT.ParameterId		TestId
		,LT.LabTestId		[Test GroupId]
		,lt.LabTestName		[Test GroupName]
		,LT.DepartmentId	LabDepartmentId
		,LT.LabDepartmentName
		,0					LabTypeId
		,'Additional Lab'	LabTypeName
		,R.ResultValue		TestResults
		,R.ResultText		TestResults1
		,R.ResultOptionId	 TestResultId
		,R.ResultOption		[Parameter Result]
		,R.Undetectable
		,R.DetectionLimit
		,R.ResultUnit
		,R.HasResult
		,V.VisitDate
		,Null				LabPeriod
		,LT.TestReferenceId
		,LT.ParameterReferenceId		
	From dbo.ord_LabOrder O
	Inner Join dtl_LabOrderTest OT On OT.LabOrderId = O.Id
	Inner Join dtl_LabOrderTestResult R On R.LabOrderTestId = OT.Id
	Inner Join VW_LabTest LT On LT.ParameterId = R.ParameterId
	Inner Join ord_Visit V On v.Visit_Id = O.VisitId
	Where    (o.DeleteFlag is null or o.DeleteFlag=0) and ParameterName='PCR')pcr
	on pcr.PatientId=p.id and pcr.PatientMasterVisitId=he.PatientMasterVisitId

left join( select PatientId,PatientMasterVisitId,Vaccine,lti.[Name] as Immunization,VaccineStage,lt.[Name] as Stage,v.VaccineDate,v.DeleteFlag from Vaccination v
left join LookupItem lti on lti.Id=v.Vaccine
left join LookupItem lt on lt.Id=v.VaccineStage
where (v.DeleteFlag is null or v.DeleteFlag =0))vt on vt.PatientId=p.Id and vt.PatientMasterVisitId=he.PatientMasterVisitId

LEFT JOIN (select distinct * from (select * ,ROW_NUMBER() OVER(partition by tc.PatientId,tc.PatientMasterVisitId order by tc.CreateDate desc)rownum 
	from(SELECT  [PatientMasterVisitId]
		  ,[PatientId]
		  ,[AppointmentDate]
		  ,[AppointmentReason]=(SELECT        TOP 1 ItemName
		  FROM            [dbo].[LookupItemView]
		  WHERE        ItemId = [ReasonId])
		  ,[Description]
		  ,DeleteFlag
		  ,CreateDate
	  FROM [dbo].[PatientAppointment]
	  where deleteflag = 0 and serviceareaid=3)
	  tc where tc.AppointmentReason='Follow Up')tc where tc.rownum=1
	  )TCAs on TCAs.PatientId=p.Id and TCAs.PatientMasterVisitId=he.PatientMasterVisitId
	  left join PatientVitals pvs on pvs.PatientId=p.Id and pvs.PatientMasterVisitId=he.PatientMasterVisitId

	  left join(select ps.PatientId,ps.PatientMasterVisitId,ps.ScreeningTypeId,ltv.MasterName as ScreeningType,
lt.[Name] as ScreeningValue
 from PatientScreening ps
inner join LookupItemView ltv on ltv.MasterId=ps.ScreeningTypeId
inner join LookupItem lt on lt.Id=ps.ScreeningValueId
 where  ltv.MasterName='TbScreeningOutcome')tbs on tbs.PatientId=p.Id and tbs.PatientMasterVisitId=he.PatientMasterVisitId
left join(select pmi.PatientId,pmi.PatientMasterVisitId,pmi.TypeAssessedId, lt.[Name] as MilestoneType
,pmi.StatusId,lti.[Name] as [Status],pmi.DeleteFlag ,pmi.DateAssessed from PatientMilestone pmi
inner join LookupItem lt on lt.Id=pmi.TypeAssessedId
inner join LookupItem lti on lti.Id=pmi.StatusId
where (pmi.DeleteFlag is null or pmi.DeleteFlag =0)) pml on pml.PatientId=p.Id and pml.PatientMasterVisitId=he.PatientMasterVisitId

left join (	Select	O.Id				LabId
		,o.Ptn_Pk
		,o.PatientMasterVisitId
		,o.PatientId
		,O.LocationId
		,O.OrderedBy		OrderedByName
		,O.OrderNumber
		,o.OrderDate		OrderedByDate
		,Ot.ResultBy		ReportedByName
		,OT.ResultDate		ReportedByDate
		,O.OrderedBy		CheckedbyName
		,o.OrderDate		CheckedbyDate
		,O.PreClinicLabDate
		,LT.ParameterName	TestName
		,LT.ParameterId		TestId
		,LT.LabTestId		[Test GroupId]
		,lt.LabTestName		[Test GroupName]
		,LT.DepartmentId	LabDepartmentId
		,LT.LabDepartmentName
		,0					LabTypeId
		,'Additional Lab'	LabTypeName
		,R.ResultValue		TestResults
		,R.ResultText		TestResults1
		,R.ResultOptionId	 TestResultId
		,R.ResultOption		[Parameter Result]
		,R.Undetectable
		,R.DetectionLimit
		,R.ResultUnit
		,R.HasResult
		,V.VisitDate
		,Null				LabPeriod
		,LT.TestReferenceId
		,LT.ParameterReferenceId		
	From dbo.ord_LabOrder O
	Inner Join dtl_LabOrderTest OT On OT.LabOrderId = O.Id
	Inner Join dtl_LabOrderTestResult R On R.LabOrderTestId = OT.Id
	Inner Join VW_LabTest LT On LT.ParameterId = R.ParameterId
	Inner Join ord_Visit V On v.Visit_Id = O.VisitId
	Where    (o.DeleteFlag is null or o.DeleteFlag=0) and ParameterName='HIV Rapid Test')hrt
	on hrt.PatientId=p.id and hrt.PatientMasterVisitId=he.PatientMasterVisitId
	
	
	
	
	---- 26. HEI Followup
	select  
 p.PersonId as Person_Id,
 pen.VisitDate as Encounter_Date,
 NULL as Encounter_ID,
he.BirthWeight as [Weight],
 pvs.Height as  [Height],
 (select lt.[Name]  from LookupItem lt where lt.Id=he.PrimaryCareGiverID) as Primary_Care_Give,
hf.InfantFeeding as Infant_Feeding,
tbs.ScreeningValue as TB_Assessment_Outcome,

m.[Social_smile_milestone_<2Months],
m.Social_smile_milestone_2Months,
m.Head_control_milestone_3Months,
m.Head_control_milestone_4Months,
m.Hand_extension_milestone_9months,
m.Sitting_milestone_12months,
m.Standing_milestone_15months,
m.Walking_milestone_18months,
m.Talking_milestone_36months,
rlabs.[1st_DNA_PCRSampleDate],
rlabs.[1st_DNA_PCRResult],
rlabs.[1st_DNA_PCRResultDate],
rlabs.[2nd_DNA_PCRSampleDate],
rlabs.[2nd_DNA_PCRResult],
rlabs.[2nd_DNA_PCRResultDate],
rlabs.[3rd_DNA_PCRSampleDate],
rlabs.[3rd_DNA_PCRResult],
rlabs.[3rd_DNA_PCRResultDate],
rlabs.ConfimatoryPCR_SampleDate,
rlabs.ConfirmatoryPCR_Result,
rlabs.ConfimatoryPCR_ResultDate,
rlabs.RepeatConfirmatoryPCR_SampleDate,
rlabs.RepeatConfirmatoryPCR_Result,
rlabs.RepeatConfirmatoryPCR_ResultDate,
rlabs.BaselineViralLoadSampleDate,
rlabs.BaselineViralLoadResult,
rlabs.BaselineViralLoadResultDate,
rlabs.Final_AntibodySampleDate,
rlabs.Final_AntibodyResult,
rlabs.Final_AntibodyResultDate,
NULL Dna_pcr_sample_date,
NULL Dna_pcr_contextual_status,
NULL Dna_pcr_result,
NULL Dna_pcr_results,
CASE WHEN ltazt.[Name]='AZT liquid BID for 12 weeks' then 'Yes' 
when ltazt.[Name]='AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks' then 'Yes'
end as Azt_given,
CASE WHEN ltazt.[Name]='NVP liquid OD for 12 weeks' then 'Yes'
when ltazt.[Name]='AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks' then 'Yes'
end as NVP_Given,
NULL CTX_Given,
ltazt.[Name] as  [ARVProphylaxisReceived],
he.ArvProphylaxisOther as [OtherARVProphylaxisReceived],
NULL First_antibody_sample_date ,
NULL First_antibody_result,      
 NULL First_antibody_dbs_sample_code,
 NULL First_antibody_result_date,
 NULL Final_antibody_sample_date,  
 NULL Final_antibody_result,   
 NULL Final_antibody_dbs_sample_code,
NULL  Final_antibody_result_date,
NULL  Tetracycline_Eye_Ointment,
NULL Pupil,
NULL Sight,
NULL Squint,
NULL Deworming_Drug,
NULL Deworming_Dosage_Units,
heapp.AppointmentDate as [Date_of_next_appointment],
heapp.[Description] as [Comment],
he.DeleteFlag as Voided
 

  from HEIEncounter he
inner join Patient p on he.PatientId=p.Id
inner join (select pe.PatientId,pe.PatientMasterVisitId,pe.EncounterTypeId,pmv.VisitDate,ltv.ItemName as EncounterType from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId 
inner join LookupItemView ltv on ltv.ItemId=pe.EncounterTypeId and ltv.MasterName='EncounterType'
where ltv.ItemName='hei-encounter'
)pen
on pen.PatientId =he.PatientId and pen.PatientMasterVisitId=he.PatientMasterVisitId 
inner join Person per on per.Id=p.PersonId 
left join PatientVitals pvs on pvs.PatientId=he.PatientId  and pvs.PatientMasterVisitId=he.PatientMasterVisitId
left join(select hf.PatientId,hf.PatientMasterVisitId,hf.FeedingModeId,lt.[Name] as InfantFeeding,
						 CASE WHEN lt.[Name]='Not Breastfeeding' then 'No'
						 when lt.[Name] is not null  and lt.[Name] !='Not Breastfeeding' then 'Yes'
						 else null end as Feeding
						  from  HEIFeeding hf
						  left join LookupItem lt on lt.Id=hf.FeedingModeId)hf
						   on hf.PatientId=p.Id and hf.PatientMasterVisitId=he.PatientMasterVisitId
  left join(select * from (select  ps.PatientId,ps.PatientMasterVisitId,ps.ScreeningTypeId,ltv.[Name] as ScreeningType,ps.DeleteFlag,ROW_NUMBER() OVER(partition by ps.PatientId,ps.PatientMasterVisitId
  order by ps.Id desc)rownum,
lt.[Name] as ScreeningValue
 from PatientScreening ps
inner join LookupMaster ltv on ltv.Id=ps.ScreeningTypeId
inner join LookupItem lt on lt.Id=ps.ScreeningValueId
 where  ltv.[Name]='TbScreeningOutcome' and (ps.DeleteFlag is null or ps.DeleteFlag=0))ps where ps.rownum='1')tbs on tbs.PatientId=p.Id and tbs.PatientMasterVisitId=he.PatientMasterVisitId
left join(select   t.PatientId,t.PatientMasterVisitId,max(t.[<2 Months]) as [Social_smile_milestone_<2Months],
max(t.[2 Months]) as [Social_smile_milestone_2Months],
max(t.[3 Months]) as Head_control_milestone_3Months,
max(t.[4 Months]) as  Head_control_milestone_4Months,
max(t.[6 Months]) as Response_to_sound_milestone_6months,
max(t.[9 Months]) as Hand_extension_milestone_9months,
max(t.[12 Months]) as Sitting_milestone_12months,
max(t.[15 Months]) as Standing_milestone_15months,
max(t.[18 Months]) as Walking_milestone_18months,
max(t.[36 Months]) as Talking_milestone_36months
  from(select pmi.PatientId,pmi.PatientMasterVisitId,pmi.TypeAssessedId, lt.[Name] as MilestoneType
,pmi.StatusId,lti.[Name] as [Status],pmi.DeleteFlag ,pmi.DateAssessed from PatientMilestone pmi
inner join LookupItem lt on lt.Id=pmi.TypeAssessedId
inner join LookupItem lti on lti.Id=pmi.StatusId
where (pmi.DeleteFlag is null or pmi.DeleteFlag =0) )
m 
pivot (max(m.[Status]) for MilestoneType In ([<2 Months], [2 Months]
,[3 Months],[4 Months] ,[6 Months] ,[9 Months] ,[12 Months] ,[15 Months] ,[18 Months] ,[36 Months])

)T  group by T.PatientId,T.PatientMasterVisitId)m on m.PatientId=he.PatientId
and m.PatientMasterVisitId =he.PatientMasterVisitId
left join(select r.PatientId,r.PatientMasterVisitId,r.[1st DNA PCRResult] as [1st_DNA_PCRResult] 
,CAST(r.[1st DNA PCRSampleDate] as datetime) as [1st_DNA_PCRSampleDate]
,CAST(r.[1st DNA PCRResultDate] as datetime) as  [1st_DNA_PCRResultDate]
,r.[2nd DNA PCRResult] as [2nd_DNA_PCRResult]
,CAST(r.[2nd DNA PCRSampleDate] as datetime) as [2nd_DNA_PCRSampleDate]
,CAST(r.[2nd DNA PCRResultDate] as datetime) as [2nd_DNA_PCRResultDate]
,r.[3rd DNA PCRResult] as  [3rd_DNA_PCRResult]
,CAST(r.[3rd DNA PCRSampleDate] as datetime) as [3rd_DNA_PCRSampleDate]
,CAST(r.[3rd DNA PCRResultDate] as datetime) as [3rd_DNA_PCRResultDate]
,r.[Final AntibodyResult] as [Final_AntibodyResult]
,CAST(r.[Final AntibodySampleDate] as datetime) as [Final_AntibodySampleDate],
CAST(r.[Final AntibodyResultDate] as datetime) as Final_AntibodyResultDate,
r.[Confirmatory PCR (for  +ve)Result] as ConfirmatoryPCR_Result,
CAST(r.[Confirmatory PCR (for  +ve)SampleDate] as datetime) as ConfimatoryPCR_SampleDate
,CAST(r.[Confirmatory PCR (for  +ve)ResultDate] as datetime) as ConfimatoryPCR_ResultDate
,r.[Repeat confirmatory PCR (for +ve)Result] as RepeatConfirmatoryPCR_Result,
CAST(r.[Repeat confirmatory PCR (for +ve)SampleDate] as datetime) as RepeatConfirmatoryPCR_SampleDate
,CAST(r.[Repeat confirmatory PCR (for +ve)ResultDate] as datetime) as RepeatConfirmatoryPCR_ResultDate,
[Baseline Viral Load (for +ve)Result] as BaselineViralLoadResult
,CAST([Baseline Viral Load (for +ve)SampleDate] as datetime) as BaselineViralLoadSampleDate
,CAST([Baseline Viral Load (for +ve)ResultDate] as datetime) as BaselineViralLoadResultDate


 from (select heilabs.PatientId,heilabs.PatientMasterVisitId,ColumnName,ColumnValue from (select hes.PatientId,lab.PatientMasterVisitId,hes.LabOrderId,hes.HeiLabTestTypeId,ltv.ItemName,lab.SampleDate ,lab.ResultDate,COALESCE(CAST(lab.TestResults as VARCHAR),lab.TestResults1)Result from HeiLabTests hes 
inner join LookupItemView ltv on ltv.ItemId=hes.HeiLabTestTypeId  and ltv.MasterName='HeiHivTestTypes'
inner join (Select	O.Id				LabId
		,o.Ptn_Pk
		,o.PatientMasterVisitId
		,o.PatientId
		,O.LocationId
		,O.OrderedBy		OrderedByName
		,O.OrderNumber
		,o.OrderDate		OrderedByDate
		,Ot.ResultBy		ReportedByName
		,OT.ResultDate		ReportedByDate
		,O.OrderedBy		CheckedbyName
		,o.OrderDate		CheckedbyDate
		,O.PreClinicLabDate
		,LT.ParameterName	TestName
		,LT.ParameterId		TestId
		,LT.LabTestId		[Test GroupId]
		,lt.LabTestName		[Test GroupName]
		,LT.DepartmentId	LabDepartmentId
		,LT.LabDepartmentName
		,0					LabTypeId
		,'Additional Lab'	LabTypeName
		,R.ResultValue		TestResults
		,R.ResultText		TestResults1
		,R.ResultOptionId	 TestResultId
		,R.ResultOption		[Parameter Result]
		,R.Undetectable
		,R.DetectionLimit
		,R.ResultUnit
		,R.HasResult
		,V.VisitDate
		,Null				LabPeriod
		,LT.TestReferenceId
		,LT.ParameterReferenceId,
		plt.SampleDate,
	   plt.ResultDate,
	   plt.ResultOptions		
	From dbo.ord_LabOrder O
	left Join dtl_LabOrderTest OT On OT.LabOrderId = O.Id
	left Join dtl_LabOrderTestResult R On R.LabOrderTestId = OT.Id
	left join(	Select	P.Id	ParameterId
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
	Left Outer Join mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID)LT on LT.ParameterID=R.ParameterId
	left join PatientLabTracker plt on plt.LabOrderId=O.Id
    left Join ord_Visit V On v.Visit_Id = O.VisitId
	Where  (O.DeleteFlag is null or O.DeleteFlag =0) ) lab on lab.LabId=hes.LabOrderId)heilabs
	cross apply(
	select (heilabs.ItemName + 'Result') , CAST(heilabs.Result as varchar(max))   union all
	select (heilabs.ItemName + 'SampleDate'),CAST( heilabs.SampleDate as varchar(max))  union all
	select (heilabs.ItemName   + 'ResultDate') ,CAST(heilabs.ResultDate as varchar(max))  
	)c(ColumnName,ColumnValue)
	)t pivot(
	max(ColumnValue)
	for columnname in ([1st DNA PCRResult],[1st DNA PCRSampleDate],[1st DNA PCRResultDate],[2nd DNA PCRResult],[2nd DNA PCRSampleDate]
,[2nd DNA PCRResultDate],[3rd DNA PCRResult],[3rd DNA PCRSampleDate],[3rd DNA PCRResultDate],[Final AntibodyResult],[Final AntibodySampleDate],[Final AntibodyResultDate],
[Confirmatory PCR (for  +ve)Result],[Confirmatory PCR (for  +ve)SampleDate],[Confirmatory PCR (for  +ve)ResultDate],[Repeat confirmatory PCR (for +ve)Result],
[Repeat confirmatory PCR (for +ve)SampleDate],[Repeat confirmatory PCR (for +ve)ResultDate],
[Baseline Viral Load (for +ve)Result],[Baseline Viral Load (for +ve)SampleDate],[Baseline Viral Load (for +ve)ResultDate])

)r)rlabs on rlabs.PatientId=he.PatientId and rlabs.PatientMasterVisitId=he.PatientMasterVisitId
left join LookupItem ltazt on ltazt.Id=he.ArvProphylaxisId
left join  (select * from (select pa.PatientId,pa.PatientMasterVisitId,pa.ServiceAreaId,sa.Code,pa.AppointmentDate,pa.[Description],pa.StatusDate
 as Comment,ROW_NUMBER() OVER(partition by pa.PatientId,pa.PatientMasterVisitId order by pa.Id desc)rownum from PatientAppointment pa 
 inner join ServiceArea sa on sa.Id=pa.ServiceAreaId
 where (pa.DeleteFlag is null or pa.DeleteFlag =0)
 and  sa.Code='HEI'

 )t where t.rownum='1')heapp on heapp.PatientMasterVisitId=he.PatientMasterVisitId  and heapp.PatientId=he.PatientId



-- 27. HEI Outcome
select p.PersonId as Person_Id ,v.VisitDate as Encounter_Date, (select ltv.[Name] from LookupItem ltv  where ltv.Id =  he.Outcome24MonthId) as Child_hei_outcomes_HIV_Status,v.VisitDate as Child_hei_outcomes_exit_date
  from HEIEncounter he 
inner join PatientMasterVisit v on v.Id=he.PatientMasterVisitId
inner join Patient p on he.PatientId=p.Id
inner join  PatientEnrollment pe on p.Id =pe.PatientId
inner join Person per on per.Id=p.PersonId 
left join PatientVitals pvs on pvs.PatientId=he.PatientId  and pvs.PatientMasterVisitId=v.Id
where he.Outcome24MonthId is not null





 -- 28. HEI Immunization
	
	
select  p.PersonId,v.VisitDate as Encounter_Date,NULL Encounter_ID,imm.BCG,
imm.BCG_Date,imm.BCG_Period,
imm.OPV_Birth,imm.OPV_Birth_Date,imm.OPV_Birth_Period,
imm.[OPV_1],imm.[OPV_1_Date],imm.[OPV_1_Period],
imm.[OPV_2],imm.[OPV_2_Date],imm.[OPV_2_Period],
imm.[OPV_3],imm.[OPV_3_Date],imm.[OPV_3_Period],
imm.DPT_Hep_B_Hib_1,imm.DPT_Hep_B_Hib_2,imm.DPT_Hep_B_Hib_3,
imm.IPV,imm.IPV_Date,imm.IPV_Period,
imm.ROTA_1,
imm.ROTA_1_Date,
imm.ROTA_1_Period,
imm.ROTA_2,
imm.ROTA_2_Date,
imm.ROTA_2_Period,
convert(varchar(50), NULL) as   Measles_rubella_1 ,
convert(varchar(50), NULL)  as Measles_rubella_2,
convert(varchar(50), NULL) as Yellow_fever,
imm.Measles_6_months,imm.Measles_6_Date,imm.Measles_6_Period,
imm.Measles_9_Months,imm.Measles_9_Date,imm.Measles_9_Period,
imm.Measles_18_Months,imm.Measles_18_Date,imm.Measles_18_Period,
imm.Pentavalent_1,imm.Pentavalent_1_Date,imm.Pentavalent_1_Period,
imm.Pentavalent_2,imm.Pentavalent_2_Date,imm.Pentavalent_2_Period,
imm.Pentavalent_3,imm.Pentavalent_3_Date,imm.Pentavalent_3_Period,
imm.[PCV_10_1]  ,imm.[PCV_10_1_Date],imm.[PCV_10_1_Period],
imm.[PCV_10_2],imm.[PCV_10_2_Date],imm.[PCV_10_2_Period],
imm.[PCV_10_3],imm.[PCV_10_3_Date],imm.[PCV_10_3_Period],
imm.Other,imm.Other_Date,imm.Other_Period,
imm.VitaminA_6_months,
imm.VitaminA_1_yr,
imm.VitaminA_1_and_half_yr,
imm.VitaminA_2_yr,
imm.VitaminA2_to_5_yr,
imm.fully_immunized,
imm.Voided

  from  HEIEncounter he 
inner join PatientMasterVisit v on v.Id=he.PatientMasterVisitId
inner join Patient p on he.PatientId=p.Id
inner join  PatientEnrollment pe on p.Id =pe.PatientId
inner join Person per on per.Id=p.PersonId 
left join  (
select r.PatientId,r.PatientMasterVisitId,r.BCG,cast(r.BCG_Date as datetime) as BCG_Date,r.BCG_Period,r.[OPV 0] as OPV_Birth,CAST(r.[OPV 0_Date] as datetime) as [OPV_Birth_Date],r.[OPV 0_Period] as [OPV_Birth_Period],
r.[OPV 1] as OPV_1,CAST(r.[OPV 1_Date] as datetime) as [OPV_1_Date]  ,r.[OPV 1_Period] as OPV_1_Period,r.[OPV 2] as OPV_2,cast(r.[OPV 2_Date] as datetime) as [OPV_2_Date]  ,r.[OPV 2_Period] as OPV_2_Period
,r.[OPV 3] as OPV_3 ,cast (r.[OPV 3_Date] as datetime) as [OPV_3_Date] ,r.[OPV 3_Period] as OPV_3_Period 
,r.IPV,cast(r.IPV_Date as datetime) as IPV_Date,r.IPV_Period,NULL DPT_Hep_B_Hib_1  ,
NULL DPT_Hep_B_Hib_2  ,NULL DPT_Hep_B_Hib_3,r.[PCV-10 1] as PCV_10_1,cast(r.[PCV-10 1_Date] as datetime) as [PCV_10_1_Date]  
 ,r.[PCV-10 1_Period] as PCV_10_1_Period, r.[PCV-10 2] as PCV_10_2 ,cast(r.[PCV-10 2_Date] as datetime) as [PCV_10_2_Date],r.[PCV-10 2_Period]
 as PCV_10_2_Period
 ,r.[PCV-10 3] as PCV_10_3,
cast(r.[PCV-10 3_Date] as datetime) as [PCV_10_3_Date] ,r.[PCV-10 3_Period] as PCV_10_3_Period,
r.[Rota virus 1] as ROTA_1,cast(r.[Rota virus 1_Date] as datetime) as ROTA_1_Date,r.[Rota virus 1_Period] as ROTA_1_Period,r.[Rota Virus 2] as ROTA_2,
cast(r.[Rota Virus 2_Date] as datetime) as ROTA_2_Date,r.[Rota Virus 2_Period] as ROTA_2_Period,
r.[Measles 6 Months] as Measles_6_months,
cast(r.[Measles 6 Months_Date] as datetime) as  Measles_6_Date
,r.[Measles 6 Months_Period] as Measles_6_Period,
r.[Measles 9 Months] as Measles_9_Months
,cast(r.[Measles 9 Months_Date] as datetime)  as Measles_9_Date,r.[Measles 9 Months_Period] as Measles_9_Period
,r.[Measles 18 Months] as Measles_18_Months ,
cast(r.[Measles 18 Months_Date] as datetime)  as Measles_18_Date 
,r.[Measles 18 Months_Period] as Measles_18_Period,
r.Other,cast(r.Other_Date as datetime) as Other_Date,r.Other_Period,

r.[Pentavalent 1] as Pentavalent_1,cast(r.[Pentavalent 1_Date] as datetime) as Pentavalent_1_Date,r.[Pentavalent 1_Period] as Pentavalent_1_Period 
,r.[Pentavalent 2] as  Pentavalent_2,cast(r.[Pentavalent 2_Date] as datetime) as  Pentavalent_2_Date,r.[Pentavalent 2_Period] as Pentavalent_2_Period,r.[Pentavalent 3] as Pentavalent_3 ,
cast(r.[Pentavalent 3_Date] as datetime) as Pentavalent_3_Date 
,r.[Pentavalent 3_Period] as Pentavalent_3_Period,
convert(varchar(50), NULL) as VitaminA_6_months,
convert(varchar(50), NULL) as VitaminA_1_yr,
convert(varchar(50), NULL) as VitaminA_1_and_half_yr,
convert(varchar(50), NULL) as VitaminA_2_yr,
convert(varchar(50), NULL) as VitaminA2_to_5_yr,
CONVERT(Datetime,NULL) as  fully_immunized,
r.DeleteFlag  as Voided
 from(
 select  v.PatientId,v.PatientMasterVisitId,v.DeleteFlag,ColumnName,ValueVaccine from(
select PatientId,PatientMasterVisitId,Vaccine,lti.[Name] as Immunization,VaccineStage,lt.[Name] as Stage,v.VaccineDate,v.DeleteFlag from Vaccination v
left join LookupItem lti on lti.Id=v.Vaccine
left join LookupItem lt on lt.Id=v.VaccineStage
where (v.DeleteFlag is null or v.DeleteFlag =0)
)v
cross apply( 

select (v.Immunization) ,'YES' union all
select (v.Immunization +'_Period' ),CAST(v.Stage as varchar(max)) union all
select (v.Immunization + '_Date' )
,CAST(v.VaccineDate as varchar(max))
) c( ColumnName,ValueVaccine) 
)t pivot 
(
 max(ValueVaccine) 
 for columnname in ([Measles 18 Months],[Measles 18 Months_Period],[Measles 18 Months_Date],[Measles 9 Months],[Measles 9 Months_Period],[Measles 9 Months_Date],[Measles 6 Months],[Measles 6 Months_Period]
 ,[Measles 6 Months_Date],IPV,IPV_Period,IPV_Date,[Rota Virus 2],[Rota Virus 2_Period],[Rota Virus 2_Date],[Rota virus 1],[Rota virus 1_Period],[Rota virus 1_Date],
 [PCV-10 3], [PCV-10 3_Period], [PCV-10 3_Date],
[PCV-10 2],[PCV-10 2_Period],[PCV-10 2_Date],[PCV-10 1],[PCV-10 1_Period],[PCV-10 1_Date],[Pentavalent 3],[Pentavalent 3_Period],[Pentavalent 3_Date]
,[Pentavalent 2] ,[Pentavalent 2_Period],[Pentavalent 2_Date]
,[Pentavalent 1],[Pentavalent 1_Period],[Pentavalent 1_Date]
,[OPV 3],[OPV 3_Period],[OPV 3_Date]
,[OPV 2],[OPV 2_Period],[OPV 2_Date]
,[OPV 1],[OPV 1_Period],[OPV 1_Date]
,[OPV 0],[OPV 0_Period],[OPV 0_Date]
,BCG,BCG_Period,BCG_Date
,Other,Other_Period,Other_Date )
)r)imm on imm.PatientId=he.PatientId and imm.PatientMasterVisitId=v.Id




-- ART Treatment preparation




  select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL
   as Encounter_ID,
   psc.Understands_hiv_art_benefits,
   psc.Screened_negative_substance_abuse,
   psc.Screened_negative_psychiatric_illness,
   psc.HIV_status_disclosure,
   psc.Trained_drug_admin,
   psc.Informed_drug_side_effects,
   psc.Caregiver_committed,
   psc.Adherance_barriers_identified,
   psc.Caregiver_location_contacts_known,
   psc.Ready_to_start_art,
   pssc.Identified_drug_time,
   pssc.Treatment_supporter_engaged,
   pssc.Support_grp_meeting_awareness,
   pssc.Enrolled_in_reminder_system,
   pssc.Other_support_systems,
   part.DeleteFlag
  from (
  select  psc.PatientId,psc.PatientMasterVisitId,psc.DeleteFlag from PatientSupportSystemCriteria 
  psc
  union 
  select  pscr.PatientId,pscr.PatientMasterVisitId,pscr.DeleteFlag from PatientPsychosocialCriteria pscr
  )part   inner join Patient p on p.Id=part.PatientId
  inner join PatientMasterVisit pmv on pmv.Id=part.PatientMasterVisitId
 left join(select  psc.PatientId,psc.PatientMasterVisitId,
 CASE when psc.BenefitART ='1' then 'Yes' when psc.BenefitART='0' then 'No'
 end as  Understands_hiv_art_benefits,
 CASE when psc.Alcohol='1' then 'Yes' when psc.Alcohol='0' then 'No'
 end as Screened_negative_substance_abuse,
 CASE when psc.Depression ='1' then 'Yes' when psc.Depression='0' then 
 'No' end as Screened_negative_psychiatric_illness,
 CASE when psc.Disclosure='1' then 'Yes' when psc.Disclosure='0' then
 'No' end as HIV_status_disclosure,
 CASE when psc.AdministerART='1' then 'Yes' when psc.AdministerART='0' then
 'No' end as Trained_drug_admin,
 CASE when psc.effectsART='1' then 'Yes' when psc.effectsART='0' then 'No' end as
 Informed_drug_side_effects,
 CASE when psc.dependents='1' then 'Yes' when psc.dependents='0' then 'No' end as Caregiver_committed,
 CASE when psc.AdherenceBarriers='1' then 'Yes' when psc.AdherenceBarriers='0' then 'No'
 end as Adherance_barriers_identified,
 CASE when psc.AccurateLocator='1' then 'Yes' when psc.AccurateLocator='0' then 'No'
 end as Caregiver_location_contacts_known,
CASE when psc.StartART ='1' then 'Yes' when psc.StartART='0' then 'No' end as
 Ready_to_start_art

  from  PatientPsychosocialCriteria psc
 
)psc on psc.PatientId=part.PatientId  
and psc.PatientMasterVisitId =part.PatientMasterVisitId
left join (
select psc.PatientId,psc.PatientMasterVisitId,
  CASE when psc.TakingART='1' then 'Yes' when psc.TakingART='0' then 'No' end 
  as Identified_drug_time,
  CASE when psc.TSIdentified='1' then 'Yes' when psc.TSIdentified='0' then 'No'
  end as Treatment_supporter_engaged,
  CASE when psc.supportGroup='1' then 'Yes' when psc.supportGroup='0' then 'No'
  end as Support_grp_meeting_awareness,
  CASE when psc.EnrollSMSReminder='1' then 'Yes' when 
  psc.EnrollSMSReminder='0' then 'No' end as Enrolled_in_reminder_system,
  CASE when psc.OtherSupportSystems='1' then 'Yes' when 
  psc.OtherSupportSystems='0' then 'No' end as Other_support_systems
   from PatientSupportSystemCriteria psc)
   pssc on pssc.PatientId=part.PatientId and pssc.PatientMasterVisitId=part.PatientMasterVisitId
   
   
   
   
   ----- 30. Enhanced Adherence Screening
   select * from ( select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'1' as Session_number,
pilladh.Answer as Pill_Count,
NULL as Arv_adherence,
mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
uvfeel.Answer as Vl_results_feeling,
uvcause.Answer as Cause_of_high_vl,
NULL as Way_Forward,
cognhiv.Answer as  Patient_hiv_knowledge,
behhiv.Answer as Patient_drugs_uptake,
behhiv2.Answer as  Patient_drugs_reminder_tools,
behhiv3.Answer as Patient_drugs_uptake_during_travels,
behhiv4.Answer as Patient_drugs_side_effects_response,
behhiv5.Answer as Patient_drugs_uptake_most_difficult_times,
emq1.Answer as   Patient_drugs_daily_uptake_feeling,
emq2.Answer as Patient_ambitions,
sociq1.Answer as Patient_has_people_to_talk,
sociq2.Answer as Patient_enlisting_social_support,
sociq3.Answer as Patient_income_sources,
sociq4scr.Answer as Patient_challenges_reaching_clinicScreening,
sociq4.Answer as Patient_challenges_reaching_clinic,
sociq5scr.Answer as Patient_worried_of_accidental_disclosureScreening,
sociq5.Answer	as  Patient_worried_of_accidental_disclosure,
sociq6scr.Answer as Patient_treated_differentlyScreening,
sociq6.Answer as Patient_treated_differently,
sociq7scr.Answer as Stigma_hinders_adherenceScreening,
sociq7.Answer as Stigma_hinders_adherence,
sociq8scr.Answer as Patient_tried_faith_healingScreening,
sociq8.Answer as Patient_tried_faith_healing,
NULL as Patient_adherence_improved,
NULL as Patient_doses_missed,
NULL as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='PillAdherence' and lt.ItemName='PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas4screeningNotes' and lt.ItemName='mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas4screeningNotes' and lt.ItemName='mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas8screeningNotes' and lt.ItemName='mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId
and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas8screeningNotes' and lt.ItemName='mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId
and mmas8Adher.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ1')lt
on lt.ItemId=pc.NotesCategoryId
)uvfeel on uvfeel.PatientMasterVisitId=pd.PatientMasterVisitId
and uvfeel.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ2')lt
on lt.ItemId=pc.NotesCategoryId
)uvcause on uvcause.PatientMasterVisitId=pd.PatientMasterVisitId
and uvcause.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='CognitiveBarriers' and lt.ItemName='CognitiveBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)cognhiv on cognhiv.PatientMasterVisitId=pd.PatientMasterVisitId and cognhiv.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv on behhiv.PatientMasterVisitId=pd.PatientMasterVisitId
and behhiv.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv2 on behhiv2.PatientMasterVisitId=pd.PatientMasterVisitId
 and behhiv2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ3')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv3 on behhiv3.PatientMasterVisitId=pd.PatientMasterVisitId
and behhiv3.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ4')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv4 on behhiv4.PatientMasterVisitId=pd.PatientMasterVisitId and behhiv4.PatientId =pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ5')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv5 on behhiv5.PatientMasterVisitId=pd.PatientMasterVisitId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EmotionalBarriers' and lt.ItemName='EmotionalBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)emq1 on emq1.PatientMasterVisitId=pd.PatientMasterVisitId and emq1.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EmotionalBarriers' and lt.ItemName='EmotionalBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)emq2 on emq2.PatientMasterVisitId=pd.PatientMasterVisitId
 and emq2.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq1 on sociq1.PatientMasterVisitId =pd.PatientMasterVisitId and 
sociq1.PatientId =pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)sociq2 on sociq2.PatientMasterVisitId=pd.PatientMasterVisitId
and sociq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sociq3 on sociq3.PatientMasterVisitId=pd.PatientMasterVisitId and sociq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq4Scr on sociq4Scr.PatientMasterVisitId =pd.PatientMasterVisitId and sociq4Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ4')lt
on lt.ItemId=pc.NotesCategoryId
)sociq4 on sociq4.PatientMasterVisitId=pd.PatientMasterVisitId and sociq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sociq5 on sociq5.PatientMasterVisitId=pd.PatientMasterVisitId and sociq5.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ5')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq5Scr on sociq5Scr.PatientMasterVisitId =pd.PatientMasterVisitId
and sociq5Scr.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ6')lt
on lt.ItemId=pc.NotesCategoryId
)sociq6 on sociq6.PatientMasterVisitId=pd.PatientMasterVisitId
and sociq6.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ6')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq6Scr on sociq6Scr.PatientMasterVisitId =pd.PatientMasterVisitId
and sociq6Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ7')lt
on lt.ItemId=pc.NotesCategoryId
)sociq7 on sociq7.PatientMasterVisitId=pd.PatientMasterVisitId

and sociq7.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ7')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq7Scr on sociq7Scr.PatientMasterVisitId =pd.PatientMasterVisitId and
sociq7Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ8')lt
on lt.ItemId=pc.NotesCategoryId
)sociq8 on sociq8.PatientMasterVisitId=pd.PatientMasterVisitId and sociq8.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ8')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq8Scr on sociq8Scr.PatientMasterVisitId =pd.PatientMasterVisitId and sociq8Scr.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId
 and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId
and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session1PillAdherence' and lt.ItemName='Session1FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId
and session1followup.PatientId=pd.PatientId



union 

select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'2' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence,
mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2PillAdherence' and lt.ItemName='Session2PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas4screeningNotes' and lt.ItemName='Session2mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas4screeningNotes' and lt.ItemName='Session2mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas8screeningNotes' and lt.ItemName='Session2mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas8screeningNotes' and lt.ItemName='Session2mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=mmas8Adher.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ1')lt
on lt.ItemId=pc.NotesCategoryId
)uvfeel on uvfeel.PatientMasterVisitId=pd.PatientMasterVisitId and uvfeel.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=sessionrefq3.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId =pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2PillAdherence' and lt.ItemName='Session2FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2AdherenceReviews'
and lt.ItemName='Session2AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2AdherenceReviews'
and lt.ItemName='Session2AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2AdherenceReviews' and lt.ItemName='Session2AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId

union

select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'3' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence
,mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3PillAdherence' and lt.ItemName='Session3PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas4screeningNotes' and lt.ItemName='Session3mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas4screeningNotes' and lt.ItemName='Session3mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas8screeningNotes' and lt.ItemName='Session3mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas8screeningNotes' and lt.ItemName='Session3mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3PillAdherence' and lt.ItemName='Session3FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3AdherenceReviews'
and lt.ItemName='Session3AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3AdherenceReviews'
and lt.ItemName='Session3AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3AdherenceReviews' and lt.ItemName='Session3AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId



union 



select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'4' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence
,mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4PillAdherence' and lt.ItemName='Session4PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas4screeningNotes' and lt.ItemName='Session4mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas4screeningNotes' and lt.ItemName='Session4mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas8screeningNotes' and lt.ItemName='Session4mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas8screeningNotes' and lt.ItemName='Session4mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4PillAdherence' and lt.ItemName='Session4FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4AdherenceReviews'
and lt.ItemName='Session4AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4AdherenceReviews'
and lt.ItemName='Session4AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4AdherenceReviews' and lt.ItemName='Session4AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId

union


select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'5' as Session_number,NULL as Pill_Count,NULL as Arv_adherence,
NULL as MMAS4AdherenceRating,
NULL as MMAS4Score,
NULL as MMAS8Score,
NULL as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
EndSessQ1.Answer as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
NULL as Patient_adherence_improved,
NULL as Patient_doses_missed,
NULL as Review_and_Barriers_to_adherence,
NULL as Other_referrals,
NULL as Appointments_honoured,
NULL as Referral_experience,
NULL as Home_visit_benefit,
NULL as Adherence_Plan,
NULL as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd left join(
select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EndSessionViralLoad' and lt.ItemName='EndSessionViralLoadQ1')lt
on lt.ItemId=pc.NotesCategoryId
)EndSessQ1 on  EndSessQ1.PatientMasterVisitId =pd.PatientMasterVisitId and EndSessQ1.PatientId=pd.PatientId
left join(
select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'EndSessionViralLoad' and lt.ItemName='EndSessionViralLoadQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
EndSessQ2 on EndSessQ2.PatientMasterVisitId =pd.PatientMasterVisitId and EndSessQ2.PatientId=pd.PatientId


)t




---Defaultet Tracing
   

   
select pce.PersonId as Person_Id,pce.VisitDate as Encounter_Date,pce.ExitDate as Exit_Date,pce.ExitReason as Exit_Reason,NULL as Encounter_ID,NULL as Tracing_type,
pce.TracingOutcome as Tracing_Outcome,
pce.ReasonLostToFollowup as Reason_LostToFollowup,
NULL as Attempt_number,
NUll as Is_final_trace,
NULL as True_status,
pce.ReasonsForDeath as  Cause_of_death,
pce.CareEndingNotes as Comments,
pce.DeleteFlag  as Voided
 from(select p.PersonId,pce.PatientId,pce.PatientMasterVisitId,pmv.VisitDate,pce.ExitDate,
(select top 1. [Name] from Lookupitem where id= pce.ExitReason) as ExitReason,
pce.DeleteFlag,
(select top 1. [Name] from Lookupitem where id= pce.TracingOutome) as TracingOutcome ,
(select top 1. [Name] from Lookupitem where id= pce.ReasonLostToFollowup) as ReasonLostToFollowup
,(select top 1. [Name] from Lookupitem where id= pce.ReasonsForDeath) as ReasonsForDeath
,pce.CareEndingNotes
from PatientCareending pce
inner join Patient p on p.Id=pce.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId
)pce
where pce.ExitReason='LostToFollowUp'

  
  
  
-- -- 31. Gender Based Violence Screening (Grouped)
 select distinct  p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID ,psyh.Answer as Violence_within_past_year,
 physi.Answer as Physical_Hurt,
 pvtr.Answer as Threatens,
 sex.Answer as  Sexual_Violence,
 pvup.Answer as Violence_from_unrelated_person,
 psgb.DeleteFlag
 
    from Patient p
	inner  join(  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' 
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all 
 select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' 
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId
 )psgb on psgb.PatientId=p.Id 
 inner join PatientMasterVisit pmv on pmv.PatientId=psgb.PatientId and pmv.Id=psgb.PatientMasterVisitId
 left join(
  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvPhysicallyHurt'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId
 )psyh on psyh.PatientId=psgb.PatientId and psyh.PatientMasterVisitId=psgb.PatientMasterVisitId
left join(
select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipPhysicalAssault'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 physi on physi.PatientId=psgb.PatientId and physi.PatientMasterVisitId=psgb.PatientMasterVisitId

 left join(
  select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipVerbalAssault'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 pvtr on pvtr.PatientId=psgb.PatientId and pvtr.PatientMasterVisitId=psgb.PatientMasterVisitId

 left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvRelationshipUncomfSexAct'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)sex on sex.PatientId =psgb.PatientId
 and sex.PatientMasterVisitId=psgb.PatientMasterVisitId
left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVAssessment' and ItemName='GbvNonRelationshipViolence'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  union all
    select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='GBVQuestions' and ItemName='GBVQuestion5'
  )ltv on ltv.ItemId=psc.ScreeningTypeId 
 left join LookupItem lti on lti.Id=psc.ScreeningValueId)
 pvup on pvup.PatientId =psgb.PatientId and pvup.PatientMasterVisitId=psgb.PatientMasterVisitId



--where  (psgb.DeleteFlag is null or psgb.DeleteFlag =0)




--32 CageAid Alcohol Screening


select pt.PersonId,pe.VisitDate as Encounter_Date,NULL as Encounter_ID ,pdra.Answer as DrinkAlcohol,pss.Answer as Smoke,pudd.Answer as UseDrugs,
trss.Answer as [TriedStopSmoking],
asq1.Answer as FeltCutDownDrinkingorDrugUse,
asq2.Answer as AnnoyedByCriticizingDrinkingorDrugUse,
asq3.Answer as FeltGuiltyDrinkingorDrugUse,
asq4.Answer as UseToSteadyNervesGetRidHangover,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided

 from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType')
liv on liv.ItemId=pe.EncounterTypeId
where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id

inner join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  psq on psq.PatientId=pe.PatientId and psq.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='DrinkAlcohol'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdra on pdra.PatientId=pe.PatientId and pdra.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='Smoke'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pss on pss.PatientId=pe.PatientId and pss.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='UseDrugs'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pudd on pudd.PatientId=pe.PatientId and pudd.PatientMasterVisitId=pe.PatientMasterVisitId

   left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SmokingScreeningQuestions'  and ItemName='SmokingScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  trss on trss.PatientId=pe.PatientId and trss.PatientMasterVisitId=pe.PatientMasterVisitId




  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq1 on asq1.PatientId=pe.PatientId and asq1.PatientMasterVisitId=pe.PatientMasterVisitId

    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq2 on asq2.PatientId=pe.PatientId and asq2.PatientMasterVisitId=pe.PatientMasterVisitId

  
    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq3 on asq3.PatientId=pe.PatientId and asq3.PatientMasterVisitId=pe.PatientMasterVisitId


      left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq4 on asq4.PatientId=pe.PatientId and asq4.PatientMasterVisitId=pe.PatientMasterVisitId

  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholRiskLevel')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)arll on arll.PatientId=pe.PatientId and arll.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholScore')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)als on als.PatientId=pe.PatientId and als.PatientMasterVisitId=pe.PatientMasterVisitId



left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocialHistory' and lt.ItemName='SocialNotes')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitId





---Crafft Alcohol Screening


select pt.PersonId,pe.VisitDate,pdr.Answer as DrinkAlcoholMorethanSips,
pc2ma.Answer as SmokeAnyMarijuana,
pcq3.Answer as UseAnythingElseGetHigh,
crs1.Answer as CARDrivenandHigh,
crs2.Answer as UseDrugorAlcoholRelax,
crs3.Answer as UseDrugByYourself,
crs4.Answer as ForgetWhileUsingAlcohol,
crs5.Answer as FamilyTellYouCutDownDrugs,
crs6.Answer as TroubleWhileUsingDrugs,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided

from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType')
liv on liv.ItemId=pe.EncounterTypeId
where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id
inner join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pcss on pcss.PatientId=pe.PatientId and pcss.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdr on pdr.PatientId=pe.PatientId and pdr.PatientMasterVisitId=pe.PatientMasterVisitId

left join( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)pc2ma on pc2ma.PatientId=pe.PatientId
  and pc2ma.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  )pcq3 on pcq3.PatientId=pe.PatientId and pcq3.PatientMasterVisitId=pe.PatientMasterVisitId

left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs1 on crs1.PatientId=pe.PatientId and crs1.PatientMasterVisitId=pe.PatientMasterVisitId



  left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs2 on crs2.PatientId=pe.PatientId and crs2.PatientMasterVisitId=pe.PatientMasterVisitId


   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs3 on crs3.PatientId=pe.PatientId and crs3.PatientMasterVisitId=pe.PatientMasterVisitId



   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs4 on crs4.PatientId=pe.PatientId and crs4.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion5'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs5 on crs5.PatientId=pe.PatientId and crs5.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,ltv.ItemName,ltv.DisplayName as Question
  ,lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion6'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs6 on crs6.PatientId=pe.PatientId and crs6.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholRiskLevel')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)arll on arll.PatientId=pe.PatientId and arll.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholScore')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)als on als.PatientId=pe.PatientId and als.PatientMasterVisitId=pe.PatientMasterVisitId



left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocialHistory' and lt.ItemName='SocialNotes')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitId



----otz enrollment

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

---otz_activity

select pt.PersonId as Person_Id 
,oaf.VisitDate as Encounter_Date,NULL as Encounter_ID,
CASE WHEN otz1.Topic is not null then 'Yes' else NULL end as Orientation,
CASE WHEN otz3.Topic is not null then 'Yes' else NULL end as Leadership,
CASE WHEN otz2.Topic is not null then 'Yes' else NULL end as Participation,
CASE WHEN otz6.Topic is not null then 'Yes' else NULL end as Treatment_literacy,
CASE WHEN otz5.Topic is not null then 'Yes' else NULL end as Transition_to_adult_care,
CASE WHEN otz4.Topic is not null then 'Yes' else NULL end as Making_Decision_future,
CASE WHEN otz7.Topic is not null then 'Yes' else NULL end as Srh,
CASE WHEN otz8.Topic is not null then 'Yes' else NULL end as Beyond_third_ninety,
oaf.AttendedSupportGroup as Attended_Support_Group,
oaf.Remarks,
pmv.DeleteFlag as Voided
  from OtzActivityForms oaf
    inner join Patient pt on pt.Id=oaf.PatientId
	inner join OtzActivityForm oafs on oafs.Id=oaf.Id
	inner join PatientMasterVisit pmv on pmv.Id=oafs.PatientMasterVisitId

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
   and ItemName='2. OTZ Participation' )otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz2 on otz2.Id=oaf.Id


   
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='3. OTZ Leadership' or itemName= 'Leadership')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz3 on otz3.Id=oaf.Id

left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='4. OTZ Making Decisions for the future' or itemName= 'Decision Making')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz4 on otz4.Id=oaf.Id
left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='5. OTZ Transition to Adult Care' or itemName= 'Transition to Adult care')otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz5 on otz5.Id=oaf.Id
   left join  (select  tt.Id,tt.VisitDate,tt.AttendedSupportGroup,tt.DateCompleted,tt.Topic 
 from( select otzf.Id,otzf.VisitDate,otzf.AttendedSupportGroup,otzm.ItemName as Topic ,ott.DateCompleted,ott.TopicId,
  ROW_NUMBER() OVER(partition by otzf.Id, otzf.VisitDate order by ott.Id desc)rownum
   from OtzActivityForms otzf
   inner join OtzActivityTopics ott on ott.ActivityFormId=otzf.Id
   inner join (select * from LookupItemView where MasterName='OTZ_Modules'
   and ItemName='6. OTZ Treatment Literacy' or itemName= 'OTZ Treatment Literacy' ) otzm on otzm.ItemId=ott.TopicId)
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
   and ItemName='8. OTZ Beyond the 3rd 90'  or itemName= 'Orientation - Operation Triple Zero' )otzm on otzm.ItemId=ott.TopicId)
   tt where tt.rownum='1'
   )otz8 on otz8.Id=oaf.Id

--ovc enrollment

select ovf.PersonId as Person_Id,ovf.EnrollmentDate as Encounter_Date,
NULL as Encounter_Id,
pr.Caregiver_enrolled_here as Caregiver_enrolled_here,
pr.FirstName +  ' ' + pr.LastName as Caregiver_name,
pr.Gender,
pr.RelationshipType,
pr.Phonenumber as Caregiver_Phone_Number,
(select top 1  lt.[Name] from LookupItem  lt where lt.Id=ovf.CPMISEnrolled) as Client_Enrolled_cpims,
ovf.PartnerOVCServices

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



--otz   outcome
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID
,(select top 1.[Name] from LookupItem li where li.Id=pce.ExitReason)as 
Discontinuation_Reason,pce.ExitDate as ExitDate,
pce.DateOfDeath,
pce.TransferOutfacility as Transfer_Facility,
NULL as Transfer_Date,
pce.DeleteFlag as Voided
  from PatientCareending  pce
  inner join Patient p on pce.PatientId=p.Id
  inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId
inner join PatientEnrollment pe on  pe.Id=pce.PatientEnrollmentId
inner join ServiceArea sa on sa.Id=pe.ServiceAreaId 
where sa.Code='OTZ' 



--ovc outcome
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID
,pce.ExitDate as ExitDate,(select top 1.[Name] from LookupItem li where li.Id=pce.ExitReason)as 
Exit_Reason,
pce.TransferOutfacility as Transfer_Facility,
CASE WHEN pce.ExitReason in (
select itemId from LookupItemView where MasterName like 'OVC_CareEndedOptions'
and  ItemName in ('TransferOutNonPepfarFacility','TransferOutPepfarFacility')) then 
pce.ExitDate else NULL end  as  Transfer_Date,
pce.DeleteFlag as Voided
  from PatientCareending  pce
  inner join Patient p on pce.PatientId=p.Id
  inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId
inner join PatientEnrollment pe on  pe.Id=pce.PatientEnrollmentId
inner join ServiceArea sa on sa.Id=pe.ServiceAreaId 
where sa.Code='OVC' 




--Users


select u.UserID,u.UserFirstName,u.UserLastName,u.UserName,Status = Case u.DeleteFlag      
    when 0 then 'Active' when 1 then 'InActive' end,ds.[Name] as Designation,ltg.GroupNames into UserListGroup   from mst_User u
left join mst_Employee me on me.EmployeeID=u.EmployeeId
left join mst_Designation ds on ds.Id=me.DesignationID
left join (
select  ltu.UserID ,STUFF((select distinct ',' + msg.GroupName from 
 lnk_UserGroup lu
inner join mst_Groups msg on lu.GroupID=msg.GroupID
where lu.UserID=ltu.UserID
for xml path('')),1,1,'') as GroupNames
from lnk_UserGroup ltu
group by ltu.UserID
)ltg on ltg.UserID=u.UserID
where u.UserID != 1;





--st_family_history

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



--ARTFastTrack



select p.PersonId  as Person_Id,pmv.VisitDate as Encounter_Date
,NULL as Encounter_ID,
(select top 1 [Name] from LookupItem li where li.Id=paa.ArtRefillModel) as Refill_Model,
NULL as Condoms_Dispensed,
CASE when paa.MissedArvDoses=0 then 'No' when paa.MissedArvDoses=1 then 'Yes' end as Missed_doses,
CASE when paa.Fatigue=0 then 'No' when paa.Fatigue=1 then 'Yes' end as Fatigue,
CASE when paa.Cough=0 then 'No' when paa.Cough=1 then 'Yes' end as Cough,
CASE when paa.Fever=0 then 'No' when paa.Fever=1 then 'Yes' end as Fever,
CASE when paa.Rash=0 then 'No' when paa.Rash=1 then 'Yes' end as Rash,
CASE when paa.Nausea=0 then 'No' when paa.Nausea=1 then 'Yes' end as Nausea_vomiting,
CASE when paa.GenitalSore=0 then 'No' when paa.GenitalSore=1 then 'Yes' end as Genital_sore_discharge,
CASE when paa.Diarrhea=0 then 'No' when paa.Diarrhea=1 then 'Yes' end as Diarrhea,
paa.OtherSymptom as Other_symptoms,
CASE when paa.NewMedication =0 then 'No' when paa.NewMedication=1 then 'Yes' end as Other_medications,
paa.NewMedicationText as Other_medications_specify,
(select top 1 [Name] from LookupItem li where li.Id=paa.PregnancyStatus)as Pregnancy_Status,
CASE when paa.FamilyPlanning =0 then 'No' when paa.FamilyPlanning=1 then 'Yes' end as FP_use,
paa.FamilyPlanningMethod as FP_use_specify,
NULL as Reason_not_using_FP,
CASE when paa.ReferedToClinic= 0 then 'No' when paa.ReferedToClinic=1 then 'Yes' end as Referred,
NULL as Referral_Specify,
paa.ReferedToClinicDate as Next_Appointment_Date,
paa.DeleteFlag as Voided
 from PatientArtDistribution paa
inner join Patient p on p.Id=paa.PatientId
inner join PatientMasterVisit pmv on pmv.Id=paa.PatientMasterVisitId
and pmv.PatientId=paa.PatientId




--HTS Contact Tracing

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
T.DeleteFlag Voided
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


---relationship


exec pr_OpenDecryptedSession
Select 
	
	P.PersonId as Index_Person_Id,
	PR.PersonId as Relative_Person_Id,
	CAST(DECRYPTBYKEY(R.FirstName) as varchar(100)) RelativeFirstName,
	CAST(DECRYPTBYKEY(R.MidName) as varchar(100)) as RelativeMiddleName
	,CAST(DECRYPTBYKEY(R.LastName) as varchar(100)) as  RelativeLastName
	,(Select Top 1	Name	From LookupItem LI	Where LI.Id = R.Sex)	RelativeSex
	,(Select Top 1	Name From LookupItem LI	Where LI.Id = PR.RelationshipTypeId) Relationship,
	PR.DeleteFlag as Voided
From Patient P
Inner Join PersonRelationship PR On P.Id = PR.PatientId
Inner Join Person R On R.Id = PR.PersonId
Inner Join Person PD On PD.Id = P.PersonId
Where p.DeleteFlag = 0
And PR.DeleteFlag = 0
And R.DeleteFlag = 0 
order by PR.PatientId desc


 ---PharmacyExtract
exec pr_OpenDecryptedSession
select p.PersonId,
CAST(DECRYPTBYKEY(pe.FirstName) as varchar(100)) as First_Name
,CAST(DECRYPTBYKEY(pe.MidName) as varchar(100))
as Middle_Name
,CAST(DECRYPTBYKEY(pe.LastName) as varchar(100)) as Last_Name,
pe.DateOfBirth,
(select top 1 [Name] from LookupItem where Id=pe.Sex) as Gender,
p.PersonId as UPN,
v.VisitDate as EncounterDate,
dpo.Drug,
dcc.[Name] as TreatmentProgram,
CASE when dcc.[Name]   in ('ART','PMTCT','HBV','Hepatitis B') and   dpo.Prophylaxis = 'No'
then 'Yes'   end as Is_arv,
NULL Is_ctx,
NULL Is_dapsone,
dpo.Prophylaxis,
dpo.StrengthName,
dpo.Drug as Drug_name, 
dpo.SingleDose as Dose,
dpo.MorningDose,
dpo.MiddayDose,
dpo.EveningDose,
dpo.NightDose,
NULL as Unit,
dpo.FrequencyName as Frequency,
dpo.FrequencyMultiplier,
dpo.Duration,
dpo.Duration_units,
NULL Duration_in_days,
dpo.OrderedQuantity,
dpo.DispensedQuantity,
dpo.BatchName,
dpo.ExpiryDate,
oby.UserName as Prescription_providerName,
pho.OrderedBy  as Prescription_provider,
dby.UserName  as Dispensing_providerName,
pho.DispensedBy as Dispensing_Provider,
CASE when pho.RegimenLine < 5 and  pho.PatientMasterVisitId is null then (select [Name]  from mst_RegimenLine where Id=pho.RegimenLine) 
WHEN  pho.PatientMasterVisitId is not null  then  (select  top 1 [Name] from LookupItem where Id=pho.RegimenLine ) end as RegimenLine,
artv.Regimen as Regimen,
artv.TreatmentPlanText as TreatmentPlan,
artv.TreatmentPlanReason as TreatmentPlanReason,
NULL as Adverse_effects,
NULL as Date_of_refill,
pho.DeleteFlag as Voided,
NULL as Date_Voided

from ord_PatientPharmacyOrder pho
left join Patient p on p.ptn_pk=pho.Ptn_pk
left join Person pe on pe.Id=p.PersonId
left join(select dc.ID,dc.[Name]
  from mst_Decode dc
inner join mst_Code  c  on c.CodeID=dc.CodeID
 where c.[Name]='Treatment Program') dcc on dcc.ID=pho.ProgID
left join mst_User oby on oby.UserID =pho.OrderedBy
left join mst_User dby on dby.UserID =pho.DispensedBy
left join ord_Visit v on v.Visit_Id=pho.VisitID
 left join (
select artt.PatientId,artt.PatientMasterVisitId,artt.RegimenLineId,artt.TreatmentStatusId,artt.CreateBy,artt.CreateDate,
(lti.name + '(' + lti.displayname + ')') as Regimen 
,lti.Id as RegimenId,
ltt.DisplayName as TreatmentPlanText,
ltt.Id as TreatmentPlan,
ltrr.Id as TreatmentPlanReasonId,
ltrr.DisplayName as TreatmentPlanReason
from ARVTreatmentTracker artt
 left join LookupItem lti on lti.Id=artt.RegimenId
left join LookupItem ltt on ltt.Id =artt.TreatmentStatusId

left join LookupItem ltrr on ltrr.Id =artt.TreatmentStatusReasonId
where artt.RegimenId > 0
)artv on artv.PatientMasterVisitId=pho.PatientMasterVisitId and artv.RegimenLineId=pho.RegimenLine
left join(select ptn_pharmacy_pk,ms.ItemName as Drug ,mst.StrengthName
as StrengthName,msf.[Name] as FrequencyName
,msf.[multiplier] as FrequencyMultiplier,
dpo.SingleDose,dpo.Duration,NULL as Duration_units,
NULL as Unit,
dpo.OrderedQuantity,
dpo.DispensedQuantity,
CASE WHEN dpo.Prophylaxis=0 then 'No'
when dpo.Prophylaxis=1 then 'Yes' end as Prophylaxis,
ba.[Name] as BatchName,
ba.ExpiryDate,
dpo.MorningDose,
dpo.MiddayDose,
dpo.EveningDose,
dpo.NightDose

 from dtl_PatientPharmacyOrder
dpo
left join Mst_ItemMaster ms on ms.Item_PK=dpo.Drug_Pk
left join mst_Strength mst on mst.StrengthId=dpo.StrengthID
left join mst_Frequency msf on msf.ID=dpo.Id
left join Mst_Batch ba on ba.Id=dpo.BatchNo
)dpo on dpo.ptn_pharmacy_pk=pho.ptn_pharmacy_pk






 
 
 
 
 
 
 