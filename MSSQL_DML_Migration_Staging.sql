-- DML TO RUN FROM MSSQL DBMS
-- Populates RAW Data to Mysql linked/staging database already created 
-- Run Second
-- Staging Database Scripts to populate DDL scripts created from MySQL 
-- Staging Database Scripts to RUN after running the DDLs in Mysql
-- 1. Demographics/Registration  DML

exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS, 'SELECT Person_Id, First_Name, Middle_Name, Last_Name, Nickname, DOB, Exact_DOB, Sex, UPN, Encounter_Date, Encounter_ID, National_id_no, Patient_clinic_number
, Birth_certificate, Birth_notification, Hei_no, Passport, Alien_Registration, Phone_number, Alternate_Phone_number,
Postal_Address,Email_Address, County, Sub_county, Ward,Village, Landmark, Nearest_Health_Centre, Next_of_kin, Next_of_kin_phone, Next_of_kin_relationship
, Next_of_kin_address, Marital_Status, Occupation, Education_level, Dead, Death_date, Consent, Consent_decline_reason, voided FROM migration_st.st_demographics')

SELECT distinct
  P.Id as Person_Id,
  CAST(DECRYPTBYKEY(P.FirstName) AS VARCHAR(50)) AS First_Name,
  CAST(DECRYPTBYKEY(P.MidName) AS VARCHAR(50)) AS Middle_Name,
  CAST(DECRYPTBYKEY(P.LastName) AS VARCHAR(50)) AS Last_Name,
  CAST(DECRYPTBYKEY(P.NickName) AS VARCHAR(50)) AS Nickname,
format(cast(ISNULL(P.DateOfBirth, PT.DateOfBirth) as date),'yyyy-MM-dd') AS DOB,
 NULL Exact_DOB,
  Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else '' end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = P.Sex),
  UPN =(select top 1 pdd.IdentifierValue from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  ) pdd where pdd.PatientId = PT.Id and pdd.[Code]='CCCNumber' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
 format(cast(PT.RegistrationDate as date),'yyyy-MM-dd') AS Encounter_Date,
  NULL Encounter_ID,
  National_id_No =(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name] from PersonIdentifier pid
inner join (
select id.Id,id.[Name] as [Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId ) pdd where pdd.PersonId = P.Id and pdd.[Name]='NationalID'),
 Patient_clinic_number=(select top 1 pdd.IdentifierValue from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  ) pdd where pdd.PatientId = PT.Id and pdd.[Code]='CCCNumber' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
  
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
pcv.MobileNumber as Phone_number,
pcv.AlternativeNumber as Alternate_Phone_number,
pcv.PhysicalAddress as Postal_Address,
pcv.EmailAddress as EmailAddress,
 County = (SELECT TOP 1 CountyName FROM County WHERE CountyId = PL.County),
 Sub_county=(select TOP 1 Subcountyname from County where  SubcountyId=PL.SubCounty),
 Ward=(SELECT TOP 1 WardName from County where WardId=PL.Ward),
 PL.Village as Village,
 PL.LandMark as LandMark,
 PL.NearestHealthCentre as Nearest_Health_Centre,
 ts.Next_of_kin,
 ts.Next_of_kin_phone,
  ts.Next_of_kin_relationship,
 ts.Next_of_kin_address,

 MaritalStatus = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PM.MaritalStatusId AND MasterName = 'MaritalStatus'),
 Occupation = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PO.Occupation AND MasterName = 'Occupation'),
Education_level = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PED.EducationLevel AND MasterName = 'EducationalLevel'),
pend.Dead,
pend.DateOfDeath as Death_date,
ts.Consent,
ts.Consent_Decline_Reason,
P.DeleteFlag as Voided 
 -- into PatientDemographics
FROM Person P
  left JOIN (select * from (select * ,ROW_NUMBER() OVER(partition by PersonId order by CreateDate desc)rownum from PersonLocation where (DeleteFlag =0 or DeleteFlag is null))PLL where PLL.rownum='1') PL ON PL.PersonId = P.Id
  INNER JOIN Patient PT ON PT.PersonId = P.Id
  LEFT JOin PersonContactView pcv on pcv.PersonId=P.Id
 LEFT JOIN( select t.PersonId,t.SupporterId,t.Next_of_kin,t.Next_of_kin_phone,t.Next_of_kin_relationship,t.Next_of_kin_address,t.Consent,t.Consent_Decline_Reason from (select  pts.PersonId ,pts.SupporterId,(pt.FirstName + ' ' + pt.MiddleName + ' '  + pt.LastName) as Next_of_kin,pts.ContactCategory,pts.ContactRelationship,lts.DisplayName as Next_of_kin_relationship 
 ,pts.MobileContact as Next_of_kin_phone,pcv.PhysicalAddress as [Next_of_kin_address],pcc.Consent,pcc.Consent_Decline_Reason
,pts.CreateDate ,ROW_NUMBER() OVER(Partition by   pts.PersonId order by pts.CreateDate desc)rownum  from PatientTreatmentSupporter pts
inner join PersonView p  on pts.PersonId=p.Id
inner join PersonView pt on pt.Id=pts.SupporterId
inner join PersonContactView pcv on pcv.PersonId=pts.SupporterId
inner join LookupItemView lt on lt.ItemId=pts.ContactCategory and lt.MasterName='ContactCategory'
inner join LookupItemView lts on lts.ItemId=pts.ContactRelationship and lts.MasterName='KinRelationship'
left join(select pc.PatientId,pc.PersonId,pc.ConsentValue,lt.DisplayName as Consent,pc.[Comments] as [Consent_Decline_Reason] from PatientConsent pc
inner join LookupItem lt on lt.Id=pc.ConsentValue) pcc on pcc.PersonId=pts.SupporterId
where lt.ItemName  in ('NextofKin','EmergencyContact')) t where t.rownum='1')ts on ts.PersonId= P.Id
LEFT JOIN PatientMaritalStatus PM ON PM.PersonId = P.Id
LEFT JOIN PersonEducation PED ON PED.PersonId = P.Id
LEFT JOIN PersonOccupation PO ON PO.PersonId = P.Id
LEFT JOIN( select pend.PatientId,pend.DateOfDeath, CASE WHEN pend.ExitDate is not null then 'Yes' else 'No' end as Dead from (select pce.PatientId,CASE WHEN pce.DateOfDeath is null then pce.ExitDate else pce.DateOfDeath end as DateOfDeath,pce.ExitReason a,pce.ExitDate,lt.DisplayName,ROW_NUMBER() OVER(partition by pce.PatientId order by pce.CreateDate desc)rownum from PatientCareending  pce
inner join  LookupItemView lt on lt.ItemId=pce.ExitReason and lt.MasterName='CareEnded'
where lt.ItemName='Death'
)pend where pend.rownum='1')pend on pend.PatientId=PT.Id
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
  PatientType=(select itemName from LookupItemView where MasterName='PatientType' and itemId=PT.PatientType),
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
 INNER JOIN (select * from (select  *,ROW_NUMBER() OVER(partition by PersonId order by CreateDate desc)rownum from PersonLocation where (DeleteFlag =0 or DeleteFlag is null))PLL where PLL.rownum='1') PL ON PL.PersonId = P.Id
  INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
  INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id AND PI.PatientEnrollmentId = PE.Id
  INNER JOIN Identifiers I on PI.IdentifierTypeId=I.Id
  left  join (select ent.PatientId,ent.Entry_point from (select se.PatientId,se.EntryPointId,lt.DisplayName as Entry_point,ROW_NUMBER() OVER(partition
by se.PatientId order by CreateDate desc)rownum from ServiceEntryPoint  se
inner join LookupItem lt on lt.Id=se.EntryPointId
where se.DeleteFlag <> 1)ent where ent.rownum='1')ent on ent.PatientId=PT.Id
left join(select * from (select * ,ROW_NUMBER() OVER(partition by ph.PatientId order by PatientMasterVisitId desc)rownum
 from PatientARVHistory  ph)parv where parv.rownum=1)parv on parv.PatientId=PT.Id
  left join mst_Patient mst on mst.Ptn_Pk=PT.ptn_pk
  left join PatientTransferIn pti on pti.PatientId =PT.Id
  left join (select pts.PersonId,pts.SupporterId,CAST(DECRYPTBYKEY(pts.MobileContact)AS VARCHAR(100)) as Treatment_supporter_telephone,
pt.FirstName + ' ' + pt.MiddleName + ' ' + pt.LastName as Name_of_treatment_supporter,
pcv.PhysicalAddress as Treatment_supporter_address ,rel.[Name]  as Relationship_of_treatment_supporter
 from PatientTreatmentSupporter pts
 left join Patient pat on pat.PersonId=pts.PersonId
inner join PersonView pt on pt.Id=pts.SupporterId 
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
WHERE PI.IdentifierTypeId = 1 and PE.ServiceAreaId=1 

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


-- 6. Patient programs
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
)pce)pce )pe on pe.PatientId=PT.Id
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId
INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id 



-- 7. Patient discontinuation
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

-- 8. IPT Screening
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

-- 9. IPT Program Enrollment
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

-- 10. IPT Program Followup
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

-- 11. Regimen History
exec pr_OpenDecryptedSession;
INSERT INTO OPENQUERY (IQCARE_OPENMRS,
'select  Person_Id, Encounter_Date,Encounter_ID,                   
  Program,                         
  Regimen ,                         
  Regimen_Name,                     
  Regimen_Line,                     
  Date_Started,                     
  Date_Stopped,                   
  Discontinued,                     
  Regimen_Discontinued,             
  Date_Discontinued,                
  Reason_Discontinued,              
  RegimenSwitchTo,					
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
  pr.VisitDate as [Date_Stopped]
 ,pr.VisitDate as Discontinued
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
 