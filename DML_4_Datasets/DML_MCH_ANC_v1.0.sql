
 ---18  st_mch_antenatal_visit
  
 exec  pr_OpenDecryptedSession;

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
 
 
 