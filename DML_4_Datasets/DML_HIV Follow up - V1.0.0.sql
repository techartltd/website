

SELECT P.PersonId Person_Id,
		P.ptn_pk
	,format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd') AS Encounter_Date
	,NULL Encounter_ID
	,CASE
		WHEN PM.VisitScheduled = '0'
			THEN 'No'
		WHEN PM.VisitScheduled = '1'
			THEN 'Yes'
		ELSE 'Yes'
		END AS Visit_scheduled
	,Visit_by = (
		SELECT TOP 1 ItemName
		FROM LookupItemView
		WHERE MasterName = 'VisitBy'
			AND ItemId = PM.VisitBy
		)
	,NULL Visit_by_other
	,Nutritional_status = (
		SELECT TOP 1 ItemDisplayName
		FROM LookupItemView
		WHERE ItemId = (
				SELECT TOP 1 ScreeningValueId
				FROM PatientScreening
				WHERE PatientMasterVisitId = PM.Id
					AND ScreeningTypeId = (
						SELECT TOP 1 MasterId
						FROM LookupItemView
						WHERE MasterName = 'NutritionStatus'
						)
				)
		)
	,Who_stage = (
		SELECT TOP 1 ItemName
		FROM LookupItemView
		WHERE MasterName = 'WHOStage'
			AND ItemId = (
				SELECT TOP 1 WHOStage
				FROM PatientWHOStage
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY Id DESC
				)
		)
	,Clinical_notes = (
		SELECT TOP 1 ClinicalNotes
		FROM PatientClinicalNotes
		WHERE PatientMasterVisitId = PM.Id
		ORDER BY Id DESC
		)
	,Last_menstrual_period = format(cast((
				SELECT TOP 1 LMP
				FROM PregnancyIndicator
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY Id DESC
				) AS DATE), 'yyyy-MM-dd')
	,Pregnancy_status = (
		SELECT TOP 1 DisplayName
		FROM LookupItemView
		WHERE itemid = (
				SELECT TOP 1 PregnancyStatusId
				FROM PregnancyIndicator
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY Id DESC
				)
		)
	,NULL Wants_pregnancy
	,Pregnancy_outcome = (
		SELECT TOP 1 ItemName
		FROM LookupItemView
		WHERE itemid = (
				SELECT TOP 1 Outcome
				FROM Pregnancy
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY ID DESC
				)
		)
	,NULL Anc_number
	,Anc_profile = CASE
		WHEN (
				SELECT TOP 1 ANCProfile
				FROM PregnancyIndicator
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY Id DESC
				) = '0'
			THEN 'No'
		ELSE 'Yes'
		END
	,Expected_delivery_date = format(cast((
				SELECT TOP 1 EDD
				FROM PregnancyIndicator
				WHERE PatientMasterVisitId = PM.Id
				ORDER BY Id DESC
				) AS DATE), 'yyyy-MM-dd')
	,Gravida = (
		SELECT TOP 1 Gravidae
		FROM Pregnancy
		WHERE PatientMasterVisitId = PM.Id
		)
	,Parity_term = (
		SELECT TOP 1 Parity
		FROM Pregnancy
		WHERE PatientMasterVisitId = PM.Id
		)
	,Parity_abortion = (
		SELECT TOP 1 Parity2
		FROM Pregnancy
		WHERE PatientMasterVisitId = PM.Id
		)
	,FamilyPlanningStatus = (SELECT DisplayName FROM LookupItem WHERE Id =(select top 1 FamilyPlanningStatusId from PatientFamilyPlanning P where P.PatientMasterVisitId = PM.Id))
	,Reason_not_using_family_planning = (SELECT DisplayName FROM LookupItem WHERE Id =(select TOP 1 ReasonNotOnFPId FROM PatientFamilyPlanning P where P.PatientMasterVisitId = PM.Id))
	,NULL General_examinations_findings
	,CASE WHEN ((select COUNT(Id) from PhysicalExamination where PatientMasterVisitId = PM.Id AND ExaminationTypeId=(SELECT top 1 MasterId FROM LookupItemView WHERE MasterName = 'ReviewOfSystems'))) > 0 THEN 'Yes' ELSE 'No' END System_review_finding
	,sk.Findings AS Skin
	,sk.FindingsNotes AS Skin_finding_notes
	,ey.Findings AS Eyes
	,ey.FindingsNotes AS Eyes_Finding_notes
	,ent.Findings AS ENT
	,ent.FindingsNotes AS ENT_finding_notes
	,ch.Findings AS Chest
	,ch.FindingsNotes AS Chest_finding_notes
	,cvs.Findings AS CVS
	,cvs.FindingsNotes AS CVS_finding_notes
	,ab.Findings AS Abdomen
	,ab.FindingsNotes AS Abdomen_finding_notes
	,cns.Findings AS CNS
	,cns.FindingsNotes AS CNS_finding_notes
	,gn.Findings AS Genitourinary
	,gn.FindingsNotes AS Genitourinary_finding_notes
	,NULL Treatment_plan
	,ctx.ScoreName AS Ctx_adherence
	,CASE
		WHEN ctx.VisitDate IS NOT NULL
			THEN 'Yes'
		ELSE ' No'
		END AS Ctx_dispensed
	,NULL AS Dapsone_adherence
	,NULL AS Dapsone_dispensed
	,adass.Morisky_forget_taking_drugs
	,adass.Morisky_careless_taking_drugs
	,adass.Morisky_stop_taking_drugs_feeling_worse
	,adass.Morisky_stop_taking_drugs_feeling_better
	,adass.Morisky_took_drugs_yesterday
	,adass.Morisky_stop_taking_drugs_symptoms_under_control
	,adass.Morisky_feel_under_pressure_on_treatment_plan
	,adass.Morisky_how_often_difficulty_remembering
	,adv.ScoreName AS Arv_adherence
	,Condom_Provided = CASE WHEN (select top 1 ItemName from LookupItemView where MasterName = 'PHDP' and ItemName = 'CD' AND ItemId = (select top 1 Phdp from PatientPHDP where PatientMasterVisitId = PM.Id AND PatientId = P.Id order by Id desc)) = 'CD' THEN 'Yes' ELSE 'No' END
	,Screened_for_substance_abuse = CASE WHEN (select top 1 ItemName from LookupItemView where MasterName = 'PHDP' and ItemName = 'SA' AND ItemId = (select top 1 Phdp from PatientPHDP where PatientMasterVisitId = PM.Id AND PatientId = P.Id order by Id desc)) = 'SA' THEN 'Yes' ELSE 'No' END
	,Pwp_Disclosure = CASE WHEN (select top 1 ItemName from LookupItemView where MasterName = 'PHDP' and ItemName = 'Disc' AND ItemId = (select top 1 Phdp from PatientPHDP where PatientMasterVisitId = PM.Id AND PatientId = P.Id order by Id desc)) = 'Disc' THEN 'Yes' ELSE 'No' END
	,Pwp_partner_tested = CASE WHEN (select top 1 ItemName from LookupItemView where MasterName = 'PHDP' and ItemName = 'PT' AND ItemId = (select top 1 Phdp from PatientPHDP where PatientMasterVisitId = PM.Id AND PatientId = P.Id order by Id desc)) = 'PT' THEN 'Yes' ELSE 'No' END
	,cacx.ScreeningValue AS Cacx_Screening
	,Screened_for_sti = CASE WHEN (select top 1 ItemName from LookupItemView where MasterName = 'PHDP' and ItemName = 'STI' AND ItemId = (select top 1 Phdp from PatientPHDP where PatientMasterVisitId = PM.Id AND PatientId = P.Id order by Id desc)) = 'STI' THEN 'Yes' ELSE 'No' END
	,scp.PartnerNotification AS Sti_partner_notification
	,pcc.Stability AS Stability
	,format(cast(papp.Next_appointment_date AS DATE), 'yyyy-MM-dd') AS Next_appointment_date
	,papp.Next_appointment_reason
	,papp.Appointment_type
	,pdd.DifferentiatedCare AS Differentiated_care
	,NULL AS Voided

FROM PatientEncounter PE
LEFT JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
LEFT JOIN Patient P ON P.Id = PM.PatientId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'Skin'
		) ex
	) sk ON sk.PatientId = PE.PatientId
	AND sk.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'Eyes'
		) ex
	WHERE ex.rownum = '1'
	) ey ON ey.PatientId = PE.PatientId
	AND ey.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'ENT'
		) ex
	WHERE ex.rownum = '1'
	) ent ON ent.PatientId = PE.PatientId
	AND ent.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT a.PatientId
			,a.PatientMasterVisitId
			,CASE
				WHEN a.ForgetMedicine = 0
					THEN 'No'
				WHEN a.ForgetMedicine = '1'
					THEN 'Yes'
				END AS Morisky_forget_taking_drugs
			,CASE
				WHEN a.CarelessAboutMedicine = 0
					THEN 'No'
				WHEN a.CarelessAboutMedicine = '1'
					THEN 'Yes'
				END AS Morisky_careless_taking_drugs
			,CASE
				WHEN a.FeelWorse = 0
					THEN 'No'
				WHEN a.FeelWorse = '1'
					THEN 'Yes'
				END AS Morisky_stop_taking_drugs_feeling_worse
			,CASE
				WHEN a.FeelBetter = 0
					THEN 'No'
				WHEN a.FeelBetter = '1'
					THEN 'Yes'
				END AS Morisky_stop_taking_drugs_feeling_better
			,CASE
				WHEN a.TakeMedicine = 0
					THEN 'No'
				WHEN a.TakeMedicine = '1'
					THEN 'Yes'
				END AS Morisky_took_drugs_yesterday
			,CASE
				WHEN a.StopMedicine = 0
					THEN 'No'
				WHEN a.StopMedicine = '1'
					THEN 'Yes'
				END AS Morisky_stop_taking_drugs_symptoms_under_control
			,CASE
				WHEN a.UnderPressure = 0
					THEN 'No'
				WHEN a.UnderPressure = '1'
					THEN 'Yes'
				END AS Morisky_feel_under_pressure_on_treatment_plan
			,CASE
				WHEN a.DifficultyRemembering = 0
					THEN 'Never/Rarely'
				WHEN a.DifficultyRemembering = 0.25
					THEN 'Once in a while'
				WHEN a.DifficultyRemembering = 0.5
					THEN 'Sometimes'
				WHEN a.DifficultyRemembering = 0.75
					THEN 'Usually'
				WHEN a.DifficultyRemembering = 1
					THEN 'All the Time'
				END AS Morisky_how_often_difficulty_remembering
			,ROW_NUMBER() OVER (
				PARTITION BY a.PatientId
				,a.PatientMasterVisitId ORDER BY a.Id DESC
				) rownum
		FROM AdherenceAssessment a
		WHERE Deleteflag = 0
		) ad
	WHERE ad.rownum = '1'
	) adass ON adass.PatientId = PE.PatientId
	AND adass.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'Chest'
		) ex
	WHERE ex.rownum = '1'
	) ch ON ch.PatientId = PE.PatientId
	AND ch.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'CVS'
		) ex
	WHERE ex.rownum = '1'
	) cvs ON cvs.PatientId = PE.PatientId
	AND cvs.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'Abdomen'
		) ex
	WHERE ex.rownum = '1'
	) ab ON ab.PatientId = PE.PatientId
	AND ab.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam = 'CNS'
		) ex
	WHERE ex.rownum = '1'
	) cns ON cns.PatientId = PE.PatientId
	AND cns.PatientMasterVisitId = PE.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ex.PatientMasterVisitId
				,ex.PatientId ORDER BY ex.CreateDate DESC
				) rownum
		FROM (
			SELECT Id
				,PatientMasterVisitId
				,PatientId
				,ExaminationTypeId
				,(
					SELECT TOP 1 l.Name
					FROM LookupMaster l
					WHERE l.Id = e.ExaminationTypeId
					) ExaminationType
				,ExamId
				,(
					SELECT TOP 1 l.DisplayName
					FROM LookupItem l
					WHERE l.Id = e.ExamId
					) Exam
				,DeleteFlag
				,CreateBy
				,CreateDate
				,FindingId
				,(
					SELECT TOP 1 l.ItemName
					FROM LookupItemView l
					WHERE l.ItemId = e.FindingId
					) Findings
				,FindingsNotes
			FROM dbo.PhysicalExamination e
			) ex
		WHERE ex.ExaminationType = 'ReviewOfSystems'
			AND Ex.Exam LIKE 'Genito-urinary'
		) ex
	WHERE ex.rownum = '1'
	) gn ON gn.PatientId = pe.PatientId
	AND gn.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT pa.PatientId
		,pa.PatientMasterVisitId
		,pa.AppointmentReason AS Next_appointment_reason
		,pa.Appointment_type
		,pa.AppointmentDate AS Next_appointment_date
	FROM (
		SELECT pa.PatientId
			,pa.PatientMasterVisitId
			,pa.AppointmentDate
			,pa.DifferentiatedCareId
			,pa.ReasonId
			,li.DisplayName AS AppointmentReason
			,ROW_NUMBER() OVER (
				PARTITION BY pa.PatientId
				,pa.PatientMasterVisitId ORDER BY pa.CreateDate DESC
				) rownum
			,lt.DisplayName AS Appointment_type
			,pa.DeleteFlag
			,pa.ServiceAreaId
			,pa.CreateDate
		FROM PatientAppointment pa
		INNER JOIN LookupItem li ON li.Id = pa.ReasonId
		INNER JOIN LookupItem lt ON lt.Id = pa.DifferentiatedCareId
		WHERE pa.DeleteFlag IS NULL
			OR pa.DeleteFlag = 0
		) pa
	WHERE pa.rownum = 1
	) papp ON papp.PatientId = pe.PatientId
	AND papp.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT pad.PatientId
		,pad.PatientMasterVisitId
		,'Yes' AS DifferentiatedCare
	FROM PatientArtDistribution pad
	WHERE DeleteFlag = 0
		OR DeleteFlag IS NULL
	) pdd ON pdd.PatientId = pe.PatientId
	AND pdd.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,CASE
				WHEN pc.Categorization = 2
					THEN 'Unstable'
				WHEN pc.Categorization = 1
					THEN 'Stable'
				END AS Stability
			,ROW_NUMBER() OVER (
				PARTITION BY pc.PatientId
				,pc.PatientMasterVisitId ORDER BY pc.id DESC
				) rownum
		FROM PatientCategorization pc
		) pc
	WHERE pc.rownum = 1
	) pcc ON pcc.PatientId = pe.PatientId
	AND pcc.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT scp.PatientId
		,scp.PatientMasterVisitId
		,scp.Name AS PartnerNotification
	FROM (
		SELECT sc.PatientId
			,sc.PatientMasterVisitId
			,sc.ScreeningTypeId
			,sc.ScreeningValueId
			,li.Name
			,ROW_NUMBER() OVER (
				PARTITION BY sc.PatientId
				,sc.PatientMasterVisitid ORDER BY sc.Id DESC
				) rownum
		FROM PatientScreening sc
		INNER JOIN LookupMaster lm ON lm.Id = sc.ScreeningTypeId
			AND lm.Name = 'STIPartnerNotification'
		INNER JOIN LookupItem li ON li.Id = sc.ScreeningValueId
		WHERE sc.DeleteFlag IS NULL
			OR sc.DeleteFlag = 0
		) scp
	WHERE scp.rownum = '1'
	) scp ON scp.PatientId = pe.PatientId
	AND scp.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lm.[DisplayName] AS ScreeningType
			,psc.DeleteFlag
			,psc.VisitDate
			,psc.ScreeningDate
			,psc.CreateDate
			,lt.DisplayName AS ScreeningValue
			,ROW_NUMBER() OVER (
				PARTITION BY psc.PatientId
				,psc.PatientMasterVisitId ORDER BY psc.CreateDate DESC
				) rownum
		FROM PatientScreening psc
		INNER JOIN LookupMaster lm ON lm.[Id] = psc.ScreeningTypeId
		INNER JOIN LookupItem lt ON lt.Id = psc.ScreeningValueId
		WHERE lm.[Name] = 'CacxScreening'
			AND (
				psc.DeleteFlag IS NULL
				OR psc.DeleteFlag = 0
				)
		) psc
	WHERE psc.rownum = '1'
	) cacx ON cacx.PatientId = pe.PatientId
	AND cacx.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT ao.Id
			,ao.PatientId
			,ao.PatientMasterVisitId
			,ao.Score
			,ROW_NUMBER() OVER (
				PARTITION BY ao.PatientId
				,ao.PatientMasterVisitId ORDER BY ao.CreateDate DESC
				) rownum
			,ao.AdherenceType
			,lm.[Name] AS AdherenceTypeName
			,lti.DisplayName AS ScoreName
			,ao.DeleteFlag
			,pmv.VisitDate
		FROM AdherenceOutcome ao
		INNER JOIN LookupMaster lm ON lm.Id = ao.AdherenceType
		INNER JOIN LookupItem lti ON lti.Id = ao.Score
		INNER JOIN PatientMasterVisit pmv ON pmv.Id = ao.PatientMasterVisitId
		WHERE lm.[Name] = 'CTXAdherence'
			AND (
				ao.DeleteFlag IS NULL
				OR ao.DeleteFlag = 0
				)
		) adv
	WHERE adv.rownum = '1'
	) ctx ON ctx.PatientId = pe.PatientId
	AND ctx.PatientMasterVisitId = pe.PatientMasterVisitId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT ao.Id
			,ao.PatientId
			,ao.PatientMasterVisitId
			,ao.Score
			,ROW_NUMBER() OVER (
				PARTITION BY ao.PatientId
				,ao.PatientMasterVisitId ORDER BY ao.CreateDate DESC
				) rownum
			,ao.AdherenceType
			,lm.[Name] AS AdherenceTypeName
			,lti.DisplayName AS ScoreName
			,ao.DeleteFlag
			,pmv.VisitDate
		FROM AdherenceOutcome ao
		INNER JOIN LookupMaster lm ON lm.Id = ao.AdherenceType
		INNER JOIN LookupItem lti ON lti.Id = ao.Score
		INNER JOIN PatientMasterVisit pmv ON pmv.Id = ao.PatientMasterVisitId
		WHERE lm.[Name] = 'ARVAdherence'
			AND (
				ao.DeleteFlag IS NULL
				OR ao.DeleteFlag = 0
				)
		) adv
	WHERE adv.rownum = '1'
	) adv ON adv.PatientId = pe.PatientId
	AND adv.PatientMasterVisitId = pe.PatientMasterVisitId
WHERE PE.EncounterTypeId = (
		SELECT ItemId
		FROM LookupItemView
		WHERE MasterName = 'EncounterType'
			AND ItemName = 'ccc-encounter'
		)

UNION

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
NULL AS Next_appointment_date,
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
WHERE OV.VisitType=17;


