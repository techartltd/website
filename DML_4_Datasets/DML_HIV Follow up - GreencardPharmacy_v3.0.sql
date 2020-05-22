SELECT 

P.PersonId Person_Id,
P.Ptn_Pk,
format(cast(coalesce(PD.DispensedByDate,PD.OrderedByDate,PD.VisitDate) AS DATE), 'yyyy-MM-dd') AS Encounter_Date,
NULL AS Encounter_ID,
NULL AS Visit_scheduled,
NULL AS Visit_by,
NULL Visit_by_other,
NULL AS Nutritional_status,
NULL AS Who_stage,
NULL AS Clinical_notes,
NULL as Last_menstrual_period,
NULL as Pregnancy_status,
NULL as Wants_pregnancy,
NULL as Pregnancy_outcome,
NULL as Anc_number,
NULL AS Anc_profile,
NULL  as Expected_delivery_date,
NULL as Gravida,
NULL as Parity_term,
NULL as Parity_abortion,
NULL as Family_planning_status,
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
format(cast(PD.ExpectedReturn AS DATE), 'yyyy-MM-dd') AS Next_appointment_date,
NULL Next_appointment_reason,
NULL Appointment_type,
NULL as Differentiated_care,
NULL as Voided

FROM(SELECT 
dateadd(day, ro.Duration, o.DispensedByDate) AS ExpectedReturn, 
PM.PatientId,
PM.VisitDate,
o.DispensedByDate,
o.OrderedByDate

FROM ord_PatientPharmacyOrder o
INNER JOIN dtl_PatientPharmacyOrder ro on ro.ptn_pharmacy_pk = o.ptn_pharmacy_pk
LEFT JOIN PatientMasterVisit PM on PM.Id = o.PatientMasterVisitId
LEFT JOIN PatientEncounter PE ON PE.PatientMasterVisitId = PM.Id
WHERE o.DispensedByDate is not null AND ro.Prophylaxis = 0  AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT')) AND o.PatientMasterVisitId IS NOT NULL AND PE.EncounterTypeId = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'EncounterType' AND ItemName = 'Pharmacy-encounter')) PD
LEFT JOIN (
SELECT 
PM.VisitDate,
PM.PatientId

FROM PatientEncounter PE
LEFT JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
LEFT JOIN Patient P ON P.Id = PM.PatientId
WHERE PE.EncounterTypeId = (SELECT ItemId FROM LookupItemView WHERE MasterName = 'EncounterType' AND ItemName = 'ccc-encounter')
) PDR ON PDR.PatientId = PD.PatientId AND format(cast(PDR.VisitDate AS DATE), 'yyyy-MM-dd') = format(cast(PD.VisitDate AS DATE), 'yyyy-MM-dd')
INNER JOIN Patient P ON P.Id = PD.PatientId
WHERE PDR.VisitDate IS NULL