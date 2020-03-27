

---PNCVisit
-- 20.  MCH PNC Visit
EXEC Pr_opendecryptedsession;

SELECT  distinct  
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
 ,h.[DaysPostPartum], 
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
 CTX.CTX  as Prophylaxis_given ,
 [AZT for Baby] [Baby_azt_dispensed],
 [NVP for Baby] [Baby_nvp_dispensed],
 [Started HAART PNC] as HAART_PNC,
 PNCExercise as Pnc_exercises,
 NULL Maternal_Condition,
 hae.hae  as Iron_Supplementation,
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
							VisitType ,[VisitNumber] ,[DaysPostPartum]  from PatientEnrollment a 
							inner  join ServiceArea b on a.ServiceAreaId=b.id
								inner join PatientIdentifier c on c.PatientId=a.PatientId
							inner join ServiceAreaIdentifiers d on c.IdentifierTypeId=d.IdentifierId and b.id=d.ServiceAreaId
							inner join dbo.VisitDetails AS g ON a.PatientId = g.PatientId AND b.Id = g.ServiceAreaId
							where b.name='PNC') AS h ON b.ID = h.patientID and d.Id = h.PatientMasterVisitId
						 LEFT OUTER JOIN
						(SELECT DISTINCT b.PatientId,b.PatientMasterVisitId,c.[ItemName] [Started HAART PNC]
							FROM dbo.PatientDrugAdministration b inner join  [dbo].[LookupItemView]a  on b.DrugAdministered=a.itemid
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
							left join (select distinct patientid,PatientMasterVisitId,b.ItemName as PNCExercise  from PatientPncExercises a inner join  lookupitemview b on b.itemid=PncExercisesDone)PncExer on d.ID=pncexer.PatientMasterVisitId and b.id=pncexer.PatientID
							left outer join 
						 (select distinct [PatientId],[PatientMasterVisitId],  lkup.ItemName as Breast 
						  from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Breast') breast on d.id=breast.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId],  lkup.ItemName  as Uterus from [dbo].[PhysicalExamination] a 
						inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Uterus')Uterus on d.id=Uterus.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName  as PPH 
						from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='PostPartumHaemorrhage')PPH on d.id=PPH.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName   as Lochia from [dbo].[PhysicalExamination] a 
						inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Lochia')Lochia on d.id=Lochia.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName  as Pallor  from [dbo].[PhysicalExamination] a 
						inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Pallor')Pallor on d.id=Pallor.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName as Episiotomy from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Episiotomy')Episiotomy on d.id=Episiotomy.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName  as C_SectionSite from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='C_SectionSite')C_SectionSite on d.id=C_SectionSite.[PatientMasterVisitId] LEFT OUTER JOIN
						 (select distinct [PatientId],[PatientMasterVisitId],lkup.ItemName  as BabyCondition
						from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='babycondition') bcc on
						bcc.PatientId =b.Id and bcc.PatientMasterVisitId=d.Id

						left Outer Join (select distinct [PatientId],[PatientMasterVisitId], lkup.ItemName as Fistula_Screening 
						from [dbo].[PhysicalExamination] a inner join lookupitemview lkup on lkup.itemid=a.FindingId  inner join lookupitemview lkup1 on lkup1.itemid=a.ExamID where lkup1.itemname='Fistula_Screening')Fistula_Screening on d.id=Fistula_Screening.[PatientMasterVisitId] LEFT OUTER JOIN

						(select distinct [PatientId],[PatientMasterVisitId], lkup1.ItemName as Breastfeeding from [dbo].[PhysicalExamination] a 
						inner join lookupitemview lkup on lkup.itemid=a.ExamId inner join lookupitemview lkup1 on lkup1.itemid=a.FindingId where lkup.itemname='Breastfeeding')Breastfeeding on d.id=Breastfeeding.[PatientMasterVisitId] LEFT OUTER JOIN
						(SELECT    distinct    a.PatientId, a.PatientMasterVisitId,d.itemname [PartnerTested], e.itemname [PartnerHIVResult]
								FROM            [dbo].[PatientPartnerTesting] a INNER JOIN
														 dbo.PatientEncounter b  ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
														 dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
														 dbo.LookupItemView d ON d.ItemId = a.[PartnerTested] LEFT OUTER JOIN
														 dbo.LookupItemView e ON e.ItemId = a.[PartnerHIVResult]
								WHERE        (c.ItemName = 'pnc-encounter'))partnerTesting on partnerTesting.PatientId=b.Id and partnerTesting.PatientMasterVisitId=d.id 
								left join (select pfp.PatientId,pfp.PatientMasterVisitId,pfp.FamilyPlanningStatusId,CASE WHEN lt.[Name]= 'NOFP' then 'No' when lt.[Name]='FP' then 'Yes' end as FamilyPlanning from PatientFamilyPlanning pfp
								inner join LookupItem lt on lt.Id=pfp.FamilyPlanningStatusId) pfp on pfp.PatientId=b.Id and pfp.PatientMasterVisitId=d.Id
						left outer join
								(SELECT a.[PatientId],b.ItemName FP,PatientMasterVisitId FROM [dbo].[PatientFamilyPlanningMethod] a inner join lookupitemview b on b.ItemId=a.[FPMethodId] inner join [PatientFamilyPlanning]c on c.[Id]=a.PatientFPId
								inner join [PatientMasterVisit] d on d.[Id]=c.[PatientMasterVisitId]  where b.ItemName not in ('UND') or [FPMethodId] is null)FP on FP.PatientId=b.Id and FP.PatientMasterVisitId=d.id	left outer join
						(SELECT distinct [PatientId],[PatientMasterVisitId],[ScreeningDate],c.Itemname ScreeningCategory,d.itemname Results,[VisitDate]
							FROM [dbo].[PatientScreening] a inner join lookupitemview b on b.masterid=a.[ScreeningTypeId]
							inner join lookupitemview c on c.itemid=a.[ScreeningCategoryId] inner join lookupitemview d on d.itemid=a.[ScreeningValueId]
							where b.mastername='CacxMethod')Cacx on Cacx.PatientId=b.Id and Cacx.PatientMasterVisitId=d.id	 left join

                        (SELECT DISTINCT 
                                                         e.PersonId, one.kitid AS OneKitId, one.KitLotNumber AS OneLotNumber, one.outcome AS FinalTestOneResult,ISNULL(CAST((CASE e.EncounterType WHEN 1 THEN 'Initial Test' WHEN 2 THEN 'Repeat Test' END) AS VARCHAR(50)),'Initial') AS TestType, FinalResultGiven = (SELECT TOP 1 ItemName FROM [dbo].[LookupItemView] WHERE ItemId = e.FinalResultGiven),
														 two.outcome AS FinalTestTwoResult, one.ExpiryDate AS OneExpiryDate, two.kitid AS twokitid, 
                                                         two.KitLotNumber AS twolotnumber, two.ExpiryDate AS twoexpirydate
                               FROM            dbo.Testing AS t INNER JOIN
                                                         dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id FULL OUTER JOIN
                                                             (SELECT DISTINCT t.HtsEncounterId, b.ItemName AS kitid, t.KitLotNumber, t.ExpiryDate, e.PersonId, l.ItemName AS outcome
                                                               FROM            dbo.Testing AS t INNER JOIN
                                                                                         dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id INNER JOIN
                                                                                         dbo.LookupItemView AS l ON l.ItemId = t.Outcome INNER JOIN
                                                                                         dbo.LookupItemView AS b ON b.ItemId = t.KitId INNER JOIN
                                                                                         dbo.PatientEncounter AS pe ON pe.Id = e.PatientEncounterID LEFT OUTER JOIN
                                                                                         dbo.LookupItemView AS lk ON lk.ItemId = pe.EncounterTypeId
                                                               WHERE        (t.TestRound = 1) AND (lk.ItemName = 'pnc-encounter')) AS one ON one.PersonId = e.PersonId FULL OUTER JOIN
                                                             (SELECT DISTINCT t.HtsEncounterId, b.ItemName AS kitid, t.KitLotNumber, t.ExpiryDate, e.PersonId, l.ItemName AS outcome
                                                               FROM            dbo.Testing AS t INNER JOIN
                                                                                         dbo.HtsEncounter AS e ON t.HtsEncounterId = e.Id INNER JOIN
                                                                                         dbo.LookupItemView AS l ON l.ItemId = t.Outcome INNER JOIN
                                                                                         dbo.LookupItemView AS b ON b.ItemId = t.KitId INNER JOIN
                                                                                         dbo.PatientEncounter AS pe ON pe.Id = e.PatientEncounterID LEFT OUTER JOIN
                                                                                         dbo.LookupItemView AS lk ON lk.ItemId = pe.EncounterTypeId
                                                               WHERE        (t.TestRound = 2) AND (lk.ItemName = 'pnc-encounter')) AS two ON two.PersonId = e.PersonId) AS HIVTest ON HIVTest.PersonId = b.PersonId LEFT OUTER JOIN
                             (SELECT he.PersonId, he.PatientEncounterID, lk.ItemName AS FinalResult
							   FROM  dbo.HtsEncounter AS he INNER JOIN
								dbo.HtsEncounterResult AS her ON he.Id = her.HtsEncounterId INNER JOIN
								dbo.PatientEncounter AS pe ON pe.Id = he.PatientEncounterID LEFT OUTER JOIN
								dbo.LookupItemView AS lk1 ON lk1.ItemId = pe.EncounterTypeId LEFT OUTER JOIN
								dbo.LookupItemView AS lk ON lk.ItemId = her.FinalResult
								WHERE  (lk1.ItemName = 'pnc-encounter')) AS z ON z.PersonId = b.PersonId
left join (select pc.PatientId,pc.PatientMasterVisitId,lt.[Name],CASE WHEN pc.CounsellingTopicId  = 0 then 'No' when pc.CounsellingTopicId > 0 then 'Yes' end as Counselling,pc.CounsellingTopicId,pc.CounsellingDate
 from PatientCounselling pc
 inner join LookupItem lt on lt.Id=pc.CounsellingTopicId where [Name]='Infant Feeding')pcc on pcc.PatientId=b.Id and pcc.PatientMasterVisitId=d.Id
 left outer join 
	(SELECT distinct b.PatientId,b.PatientMasterVisitId,c.[ItemName] [CTX]
	FROM dbo.PatientDrugAdministration b inner join  [dbo].[LookupItemView]a  on b.DrugAdministered=a.itemid
	inner join [dbo].[LookupItemView]c on c.itemid=b.value
	where a.itemname ='Cotrimoxazole')CTX on CTX.PatientId=b.Id and CTX.PatientMasterVisitId=d.Id 

	 left outer join 
	(SELECT distinct b.PatientId,b.PatientMasterVisitId,c.[ItemName] [hae]
	FROM dbo.PatientDrugAdministration b inner join  [dbo].[LookupItemView]a  on b.DrugAdministered=a.itemid
	inner join [dbo].[LookupItemView]c on c.itemid=b.value
	where a.itemname ='Haematinics given')hae on hae.PatientId=b.Id and hae.PatientMasterVisitId=d.Id
	left join (SELECT    distinct    a.PatientId, a.PatientMasterVisitId,d.itemname ReferredFrom, e.itemname ReferredTo
	FROM            dbo.PMTCTReferral a INNER JOIN
							 dbo.PatientEncounter b  ON a.PatientMasterVisitId = b.PatientMasterVisitId LEFT OUTER JOIN
							 dbo.LookupItemView c ON c.ItemId = b.EncounterTypeId LEFT OUTER JOIN
							 dbo.LookupItemView d ON d.ItemId = a.ReferredFrom LEFT OUTER JOIN
							 dbo.LookupItemView e ON e.ItemId = a.ReferredTo
							 )ref on ref.PatientId=b.Id and ref.PatientMasterVisitId=d.Id 

LEFT JOIN (select distinct *  from (select  * ,ROW_NUMBER() OVER(partition by tc.PatientId,tc.PatientMasterVisitId order by tc.CreateDate desc)rownum 
	from(SELECT  [PatientMasterVisitId]
		  ,[PatientId]
		  ,[AppointmentDate]
		  ,[AppointmentReason]=(SELECT  TOP 1 ItemName
		  FROM            [dbo].[LookupItemView]
		  WHERE        ItemId = [ReasonId])
		  ,[Description]
		  ,DeleteFlag
		  ,CreateDate
	  FROM [dbo].[PatientAppointment]
	  where deleteflag = 0 and serviceareaid=3)
	  tc where tc.AppointmentReason='Follow Up')tc where tc.rownum=1
	  )TCAs on TCAs.PatientId=b.Id and TCAs.PatientMasterVisitId=d.Id 
WHERE        (h.Name = 'PNC')
