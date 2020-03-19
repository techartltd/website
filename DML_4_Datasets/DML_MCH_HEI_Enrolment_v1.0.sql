
---Hei Visit st_hei_enrollment 

exec pr_OpenDecryptedSession;
select distinct p.PersonId as Person_Id,
v.Id,
  CAST(DECRYPTBYKEY(per.FirstName) AS VARCHAR(50)) AS First_Name,
  CAST(DECRYPTBYKEY(per.MidName) AS VARCHAR(50)) AS Middle_Name,
  CAST(DECRYPTBYKEY(per.LastName) AS VARCHAR(50)) AS Last_Name,
  per.DateOfBirth as DOB,
  Sex = (SELECT (case when ItemName = 'Female' then 'F' when ItemName = 'Male' then 'M' else '' end) FROM LookupItemView WHERE MasterName = 'GENDER' AND ItemId = per.Sex),
  pid.IdentifierValue as UPN,
  v.VisitDate as Encounter_Date,
  NULL as gestation_at_birth,
  he.BirthWeight,
  NULL as child_exposed,
  pid.IdentifierValue as hei_id_number,
  NULL spd_number,
  NULL birth_length,
  NULL birth_order,
 NULL birth_type,
(select lt.[Name] from LookupItem lt where lt.Id=he.PlaceOfDeliveryId) as place_of_delivery,
(select lt.[Name] from LookupItem lt where lt.Id=he.ModeOfDeliveryId) as mode_of_delivery,
birth_notification_number =(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthNotification' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
date_birth_notification_number_issued =(select top 1 pdd.CreateDate from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthNotification' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
birth_certificate_number =(select top 1 pdd.IdentifierValue from (select pid.PersonId,pid.IdentifierId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PersonIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Person')pdd on pdd.Id=pid.IdentifierId  ) pdd where pdd.PersonId = p.PersonId and pdd.[Name]='BirthCertificate' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ) ,
pe.EnrollmentDate as date_first_enrolled_in_hei_care,
NULL birth_registration_place,
pe.EnrollmentDate as birth_registration_date,
mf.FacilityName as  health_Facility_name,
he.MotherName AS Mothers_name,
NULL as Fathers_name,
NULL as Guardians_name,
NULL as Community_HealthWorkers_name,
NULL as Alternate_Contact_name,
NULL as Contactcs,
NULL as need_for_special_care,
NULL as reason_for_special_care,
NULL as hiv_status_at_exit,
CASE WHEN pif.ContactWithTb='1' then 'Yes' when pif.ContactWithTB='0' then 'No'
else NULL end as TB_contact_history_in_household, 
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherStatusId) as Mother_alive,
hf.Feeding as mother_breastfeeding,
hf.InfantFeeding as mother_breastfeedingmode,
NULL referral_source,
null as transfer_in,
null as transfer_in_date,
NULL as facility_transferred_from,
NULL as district_transferred_from,
(select  lt.[Name] from LookupItem lt where lt.Id=he.ArvProphylaxisId) as arv_prophylaxis,
case when hf.InfantFeeding in ('Exclusive Breast Feeding (EBF)','Breastfeeding','Mixed Feeding (MF)') and (he.ArvProphylaxisId in (    select ItemId from LookupItemView
  where MasterName='ARVProphylaxis' and ItemName like '%NVP%') or (he.ArvProphylaxisOther like '%NVP%') ) then 'Yes' else  'No' end as  mother_on_NVP_during_breastfeeding,
NULL as infant_mother_link,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherPMTCTDrugsId) as mother_on_pmtct_drugs,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherPMTCTRegimenId) as mother_on_pmtct_drugsregimen,
he.MotherPMTCTRegimenOther as mother_on_pmtct_otherregimen ,
(select lt.[Name] from LookupItem lt where lt.Id=he.MotherArtInfantEnrolId) as mother_On_art_at_infant_enrollment,
(select  lt.[Name] from LookupItem lt where lt.Id=he.MotherArtInfantEnrolRegimenId) as mother_drug_regimen,
(select  lt.[Name] from LookupItem lt where lt.Id=he.ArvProphylaxisId) as infant_prophylaxis,
he.ArvProphylaxisOther as infant_prophylaxis_other,
he.MotherCCCNumber as parent_ccc_number,
pcr.OrderedByDate as date_sample_collected,
(  select top 1 v.VisitDate from [HEIEncounter] h
  inner join PatientMasterVisit v on h.PatientMasterVisitId=v.Id and h.PatientMasterVisitId=he.PatientMasterVisitId 
  where Outcome24MonthId!=0
  order by VisitDate asc
) as  exit_date_result_given,
CASE WHEN vt.Vaccine is not null then 'Yes' else NULL end  as immunization_given,
vt.VaccineDate as  date_immunized,
TCAs.AppointmentDate as Date_of_next_appointment,
case when p.id in (SELECT PatientId FROM HEIEncounter   group by patientid  having count(distinct(PatientMasterVisitId))>1) 
then 'Yes' else 'No' end as revisit_this_year,
(select lt.[Name]  from LookupItem lt where lt.Id=he.PrimaryCareGiverID) as Primary_Care_Give,
datediff(month,p.DateOfBirth,v.VisitDate) as Age,
pvs.Muac,
case when hf.InfantFeeding in ('Exclusive Breast Feeding (EBF)') and datediff(month,p.DateOfBirth,v.VisitDate) <=6 then 'Yes' else 'No' end as Exclusive_breastfeeding_0_6_months,
case when pml.[Status] in ('Regressed','Delayed') then 'Yes' when pml.Status='Normal' then 'No' else null end as [Stunted?],
NULL as Medication_Given_If_HIV_Expose,
tbs.ScreeningValue as  Tb_Assessment_Outcome,
pml.MilestoneType as Development_Milestones_by_ge,
pml.[Status] as Achieving_Milestones,
NULL as Weight_Category,
NULL as Type_of_Follow_up ,
NULL as  Test_COntextual_Status,
NULL First_DBS_Sample_Code,
NULL Date_First_DBS_Sample_Code_Result_Collected,
hrt.TestResults as Final_Antibody_test,
hrt.ReportedByDate as Date_Final_Antibody_test,
hrt.TestResults as 	Final_DBS_Sample_Code_Result ,
NULL as	DBS_Sample_Code,
NULL as	Date_DBS_Sample_Code_Result_collected,
NULL as [Tetracycline_Eye_Ointment_(TEO)_Given],
NULL PUPIL,
NULL SIGHT,
NULL [SQUINT(Crossed_Eyes)],
NULL Deworming_and_Vitamin_A_Supp,
NULL Deworming_Next_Visit,
NULL Deworming_Drug,
NULL Deworming_Dosage_Units,
NULL Vitamin_A,
NULL Any_disability,
(SELECT distinct [Description]  FROM PatientAppointment where PatientMasterVisitId = he.PatientMasterVisitId) as ClinicianS_Notes,
NULL Counselled_On,
NULL [Supplemented_with_MNPS_6-23_Months],
NULL [Physical Features Colouration],
vt.Immunization as Immunization_vaccinine,
NULL Immunization_Batch_num,
NULL Immunization_Expiry_Date,
NULL Immunization_Dose,
vt.VaccineDate as Immunization_Dte_Given,
NULL Immunization_BCG_ScarChecked,
NULL Immunization_BCG_Date_Checked,
NULL Immunization_BCG_Repeated,
NULL Immunization_Vitamin_Capsule_Given_Dose ,
NULL Immunization_Vitamin_Capsule_Given,     
NULL	Immunization_Vitamin_Capsule_Date_Given , 
NULL Immunization_Vitamin_Capsule_Date_Of_Next_visit , 
NULL Immunization_Vitamin_Capsule_Fully_Immunized_child, 
NULL	Immunization_Vitamin_Capsule_Date_Given_Last_Vaccine,
CASE WHEN he.Outcome24MonthId > 0 then v.VisitDate  else NULL end as  	Child_Hei_Outcomes_Exit_date,			
(select lt.[Name]  from LookupItem lt where lt.Id=he.Outcome24MonthId)	Child_Hei_Outcomes_HIV_Status		
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
	
	