SELECT
P.PersonId Person_Id,
MP.Ptn_Pk,
format(cast(OV.VisitDate AS DATE), 'yyyy-MM-dd') AS Encounter_Date,
NULL AS Encounter_ID,
CASE WHEN ISNULL(PAE.Scheduled, '0') = '0' THEN 'No' WHEN PAE.Scheduled = '1' THEN 'Yes' END AS Visit_scheduled,
CASE (select Name from mst_bluedecode where codeid=8 and (DeleteFlag = 0 or DeleteFlag IS NULL) and ID = OV.TypeofVisit)
WHEN 'SF - Self' THEN 'S' WHEN 'TS - Treatment Supporter' THEN 'TS' ELSE 'S' END AS Visit_by,
NULL Visit_by_other,
NULL AS Nutritional_status,
CASE(select Name from mst_Decode where CodeID = 22  and (DeleteFlag = 0 or DeleteFlag IS NULL) AND ID = PS.WHOStage)
WHEN '1' THEN 'Stage1' WHEN '2' THEN 'Stage2' WHEN '3' THEN 'Stage3' WHEN '4' THEN 'Stage4' WHEN 'N/A' THEN NULL WHEN 'T1' THEN 'Stage1' WHEN 'T2' THEN 'Stage2' WHEN 'T3' THEN 'Stage3' WHEN 'T4' THEN 'Stage4' ELSE NULL END AS Who_stage,
NULL AS Clinical_notes,
NULL as Last_menstrual_period,
NULL as Pregnancy_status,
CASE WHEN (select Name from mst_bluedeCode where CodeID = 15 and (DeleteFlag = 0 or DeleteFlag IS NULL) AND ID = PC.FamilyPlanningStatus) = 'Wants Family Planning' THEN 'Yes' ELSE 'No' END as Wants_pregnancy,
NULL as Pregnancy_outcome,
NULL as Anc_number,
NULL AS Anc_profile,
NULL  as Expected_delivery_date,
NULL as Gravida,
NULL as Parity_term,
NULL as Parity_abortion,
(select Name from mst_bluedeCode where CodeID = 15 and (DeleteFlag = 0 or DeleteFlag IS NULL) AND ID = PC.FamilyPlanningStatus) as Family_planning_status,
NULL Reason_not_using_family_planning,
NULL as General_examinations_findings,
NULL as System_review_finding,
NULL as Skin,
NULL as Skin_finding_notes,
NULL as Eyes,
NULL as Eyes_Finding_notes,
NULL as ENT,
NULL as ENT_finding_notes,
NULL as Chest,
NULL as Chest_finding_notes,
NULL as CVS,
NULL as CVS_finding_notes,
NULL as Abdomen,
NULL as Abdomen_finding_notes,
NULL as CNS,
NULL as CNS_finding_notes,
NULL as Genitourinary,
NULL as Genitourinary_finding_notes,
NULL as Treatment_plan,
NULL as Ctx_adherence,
NULL as Ctx_dispensed,
NULL as Dapsone_adherence,
NULL as Dapsone_dispensed,
NULL Morisky_forget_taking_drugs,
NULL Morisky_careless_taking_drugs,
NULL Morisky_stop_taking_drugs_feeling_worse,
NULL Morisky_stop_taking_drugs_feeling_better,
NULL Morisky_took_drugs_yesterday,
NULL Morisky_stop_taking_drugs_symptoms_under_control,
NULL Morisky_feel_under_pressure_on_treatment_plan,
NULL Morisky_how_often_difficulty_remembering,
NULL as Arv_adherence,
NULL Condom_Provided,
NULL Screened_for_substance_abuse,
NULL Pwp_Disclosure,
NULL Pwp_partner_tested,
NULL as Cacx_Screening,
NULL Screened_for_sti,
NULL as Sti_partner_notification,
NULL as Stability,
format(cast(CASE 
WHEN bapp.AppDate IS NULL 
	THEN	(select TOP 1 
		dateadd(day,d.Duration,o.DispensedByDate) as ExpectedReturn
		from ord_PatientPharmacyOrder o
		inner join ord_Visit kth on kth.Visit_Id = o.VisitID
		inner join dtl_PatientPharmacyOrder d on d.ptn_pharmacy_pk = o.ptn_pharmacy_pk
		WHERE kth.VisitType = 4 AND d.Prophylaxis = 0  AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT')) AND o.DispensedByDate IS NOT NULL AND kth.VisitDate = OV.VisitDate and kth.Ptn_pk = OV.Ptn_Pk AND PatientMasterVisitId IS NULL) 
WHEN (select TOP 1 
	dateadd(day,d.Duration,o.DispensedByDate) as ExpectedReturn
	from ord_PatientPharmacyOrder o
	inner join ord_Visit kth on kth.Visit_Id = o.VisitID
	inner join dtl_PatientPharmacyOrder d on d.ptn_pharmacy_pk = o.ptn_pharmacy_pk
	WHERE kth.VisitType = 4 AND d.Prophylaxis = 0  AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT')) AND o.DispensedByDate IS NOT NULL AND kth.VisitDate = OV.VisitDate and kth.Ptn_pk = OV.Ptn_Pk AND PatientMasterVisitId IS NULL)  > bapp.AppDate 
THEN (select TOP 1 
	dateadd(day,d.Duration,o.DispensedByDate) as ExpectedReturn
	from ord_PatientPharmacyOrder o
	inner join ord_Visit kth on kth.Visit_Id = o.VisitID
	inner join dtl_PatientPharmacyOrder d on d.ptn_pharmacy_pk = o.ptn_pharmacy_pk
	WHERE kth.VisitType = 4 AND d.Prophylaxis = 0  AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT')) AND o.DispensedByDate IS NOT NULL AND kth.VisitDate = OV.VisitDate and kth.Ptn_pk = OV.Ptn_Pk AND PatientMasterVisitId IS NULL) 
WHEN bapp.AppDate > (select TOP 1 
	dateadd(day,d.Duration,o.DispensedByDate) as ExpectedReturn
	from ord_PatientPharmacyOrder o
	inner join ord_Visit kth on kth.Visit_Id = o.VisitID
	inner join dtl_PatientPharmacyOrder d on d.ptn_pharmacy_pk = o.ptn_pharmacy_pk
	WHERE kth.VisitType = 4 AND d.Prophylaxis = 0  AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT')) AND o.DispensedByDate IS NOT NULL AND kth.VisitDate = OV.VisitDate and kth.Ptn_pk = OV.Ptn_Pk AND PatientMasterVisitId IS NULL) 
THEN bapp.AppDate 
ELSE bapp.AppDate END AS DATE), 'yyyy-MM-dd') AS Next_appointment_date,
NULL Next_appointment_reason,
NULL Appointment_type,
NULL as Differentiated_care,
NULL as Voided

FROM ord_Visit OV
LEFT JOIN mst_Patient MP ON MP.Ptn_Pk = OV.Ptn_Pk
LEFT JOIN Patient P ON P.ptn_pk = MP.Ptn_Pk
LEFT JOIN dtl_PatientARTEncounter PAE ON PAE.Visit_Id = OV.Visit_Id
LEFT JOIN dtl_PatientStage PS ON PS.Visit_Pk = OV.Visit_Id
LEFT JOIN dtl_PatientDisease PDS ON PDS.Visit_Pk = OV.Visit_Id AND MP.Ptn_Pk = PDS.Ptn_Pk
LEFT JOIN dtl_patientCounseling PC ON PC.Visit_pk = OV.Visit_Id AND PC.Ptn_pk = MP.Ptn_Pk
LEFT JOIN (
		SELECT a.appdate,
		b.Name,
		a.Ptn_pk,
		a.Visit_pk
		FROM dtl_patientappointment a
		INNER JOIN mst_decode b ON a.appstatus = b.id
		WHERE a.deleteflag = 0 AND format(cast(a.AppDate AS DATE), 'yyyy-MM-dd') <> '1900-01-01' AND a.ModuleId IN(SELECT m.ModuleID FROM mst_module m WHERE m.ModuleName='CCC Patient Card MoH 257')) bapp ON bapp.Visit_pk = OV.Visit_Id
WHERE OV.VisitType=17 and MP.DeleteFlag = 0