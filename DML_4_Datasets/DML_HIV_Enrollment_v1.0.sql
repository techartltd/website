

-- -----------------------------2. HIV Enrollment DML ---------------------------------------------
EXEC pr_OpenDecryptedSession;

SELECT DISTINCT P.Id AS Person_Id
	,UPN = (
		SELECT TOP 1 pdd.IdentifierValue
		FROM (
			SELECT pid.PatientId
				,pid.IdentifierTypeId
				,pid.IdentifierValue
				,pdd.Code
				,pdd.DisplayName
				,pdd.[Name]
				,pid.CreateDate
				,pid.DeleteFlag
			FROM PatientIdentifier pid
			INNER JOIN (
				SELECT id.Id
					,id.[Name]
					,id.[Code]
					,id.[DisplayName]
				FROM Identifiers id
				INNER JOIN IdentifierType it ON it.Id = id.IdentifierType
				WHERE it.Name = 'Patient'
				) pdd ON pdd.Id = pid.IdentifierTypeId
			) pdd
		WHERE pdd.PatientId = PT.Id
			AND pdd.[Code] = 'CCCNumber'
			AND pdd.DeleteFlag = 0
		ORDER BY pdd.CreateDate DESC
		)
	,format(cast(PE.EnrollmentDate AS DATE), 'yyyy-MM-dd') AS Encounter_Date
	,NULL Encounter_ID
	,Patient_Type = (
		SELECT itemName
		FROM LookupItemView
		WHERE MasterName = 'PatientType'
			AND itemId = PT.PatientType
		)
	,ent.Entry_point
	,pti.FacilityFrom AS TI_Facility
	,PE.EnrollmentDate AS Date_First_enrolled_in_care
	,bas.TransferInDate AS Transfer_In_Date
	,bas.ARTInitiationDate AS Date_started_art_at_transferring_facility
	,bas.HIVDiagnosisDate AS Date_Confirmed_hiv_positive
	,bas.FacilityFrom AS Facility_confirmed_hiv_positive
	,bas.HistoryARTUse AS Baseline_arv_use
	,parv.Purpose AS Purpose_of_Baseline_arv_use
	,bas.CurrentTreatmentName AS Baseline_arv_regimen
	,bas.RegimenName AS Baseline_arv_regimen_line
	,parv.DateLastUsed AS Baseline_arv_date_last_used
	,bas.EnrollmentWHOStageName AS Baseline_who_stage
	,bas.CD4Count AS Baseline_cd4_results
	,bas.EnrollmentDate AS Baseline_cd4_date
	,bas.BaselineViralload AS Baseline_vl_results
	,bas.BaselineViralloadDate AS Baseline_vl_date
	,NULL AS Baseline_vl_ldl_results
	,NULL AS Baseline_vl_ldl_date
	,bas.HBVInfected AS Baseline_HBV_Infected
	,bas.TBinfected AS Baseline_TB_Infected
	,bas.Pregnant AS Baseline_Pregnant
	,bas.BreastFeeding AS Baseline_BreastFeeding
	,bas.[Weight] AS Baseline_Weight
	,bas.[Height] AS Baseline_Height
	,bas.BMI AS Baseline_BMI
	,treatmentl.Name_of_treatment_supporter
	,treatmentl.Relationship_of_treatment_supporter
	,treatmentl.Treatment_supporter_telephone
	,treatmentl.Treatment_supporter_address
	,0 AS Voided
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY PersonId ORDER BY CreateDate DESC
				) rownum
		FROM PersonLocation
		WHERE (
				DeleteFlag = 0
				OR DeleteFlag IS NULL
				)
		) PLL
	WHERE PLL.rownum = '1'
	) PL ON PL.PersonId = P.Id
LEFT JOIN (
	SELECT ent.PatientId
		,ent.Entry_point
	FROM (
		SELECT se.PatientId
			,se.EntryPointId
			,lt.DisplayName AS Entry_point
			,ROW_NUMBER() OVER (
				PARTITION BY se.PatientId ORDER BY CreateDate DESC
				) rownum
		FROM ServiceEntryPoint se
		INNER JOIN LookupItem lt ON lt.Id = se.EntryPointId
		WHERE se.DeleteFlag <> 1
		) ent
	WHERE ent.rownum = '1'
	) ent ON ent.PatientId = PT.Id
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ph.PatientId ORDER BY PatientMasterVisitId DESC
				) rownum
		FROM PatientARVHistory ph
		) parv
	WHERE parv.rownum = 1
	) parv ON parv.PatientId = PT.Id
LEFT JOIN mst_Patient mst ON mst.Ptn_Pk = PT.ptn_pk
LEFT JOIN PatientTransferIn pti ON pti.PatientId = PT.Id
LEFT JOIN (
	SELECT pts.PersonId
		,pts.SupporterId
		,CAST(DECRYPTBYKEY(pts.MobileContact) AS VARCHAR(100)) AS Treatment_supporter_telephone
		,pt.FirstName + ' ' + pt.MiddleName + ' ' + pt.LastName AS Name_of_treatment_supporter
		,pcv.PhysicalAddress AS Treatment_supporter_address
		,rel.[Name] AS Relationship_of_treatment_supporter
	FROM PatientTreatmentSupporter pts
	LEFT JOIN Patient pat ON pat.PersonId = pts.PersonId
	LEFT JOIN PersonView pt ON pt.Id = pts.SupporterId
	LEFT JOIN PersonContactView pcv ON pcv.PersonId = pts.SupporterId
	LEFT JOIN LookupItem lt ON lt.Id = pts.ContactCategory
	LEFT JOIN PersonRelationship prl ON prl.PersonId = pts.SupporterId
		AND prl.PatientId = pat.Id
	LEFT JOIN LookupItem rel ON rel.Id = prl.RelationshipTypeId
	WHERE (
			lt.Name = 'TreatmentSupporter'
			OR pts.ContactCategory = 1
			)
	) treatmentl ON treatmentl.PersonId = P.Id
LEFT JOIN (
	SELECT *
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY PatientId ORDER BY PatientMasterVisitId
				) rownum
		FROM PatientBaselineView
		) rte
	WHERE rte.rownum = 1
	) bas ON bas.PatientId = PT.Id
LEFT OUTER JOIN (
	SELECT PatientId
		,ExitReason
		,ExitDate
	FROM dbo.PatientCareending
	WHERE deleteflag = 0
	
	UNION
	
	SELECT dbo.Patient.Id AS PatientId
		,CASE (
				SELECT TOP 1 Name
				FROM mst_Decode
				WHERE CodeID = 23
					AND ID = (
						SELECT TOP 1 PatientExitReason
						FROM dtl_PatientCareEnded
						WHERE Ptn_Pk = dbo.Patient.ptn_pk
							AND CareEnded = 1
						)
				)
			WHEN 'Lost to follow-up'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'LostToFollowUp'
						)
			WHEN 'HIV Negative'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'HIV Negative'
						)
			WHEN 'Death'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Death'
						)
			WHEN 'Confirmed HIV Negative'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Confirmed HIV Negative'
						)
			WHEN 'Transfer to ART'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Transfer Out'
						)
			WHEN 'Transfer to another LPTF'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Transfer Out'
						)
			WHEN 'Discharged at 18 months'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Confirmed HIV Negative'
						)
			WHEN 'Transfered out'
				THEN (
						SELECT TOP 1 ItemId
						FROM LookupItemView
						WHERE MasterName = 'CareEnded'
							AND ItemName = 'Transfer Out'
						)
			END AS ExitReason
		,CareEndedDate
	FROM dbo.dtl_PatientCareEnded
	INNER JOIN dbo.Patient ON dbo.dtl_PatientCareEnded.Ptn_Pk = dbo.Patient.ptn_pk
	WHERE dbo.Patient.Id NOT IN (
			SELECT PatientId
			FROM dbo.PatientCareending
			WHERE deleteflag = 0
			)
	) AS ptC ON PT.Id = ptC.PatientId
WHERE PE.ServiceAreaId = 1

