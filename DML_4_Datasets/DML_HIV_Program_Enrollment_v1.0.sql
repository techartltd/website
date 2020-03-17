----10. Patient programs--HIV Program Enrollment

SELECT distinct P.Id AS Person_Id
	,pe.Enrollment AS Encounter_Date
	,NULL AS Encounter_ID
	,Code AS Program
	,pe.Enrollment AS Date_Enrolled
	,pe.ExitDate AS Date_Completed
	,Created_At
	,Created_By
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN (
	SELECT distinct --p.Ptn_PK
		pce.PatientId
		,pce.ServiceAreaId
		,pce.Code
		,pce.Enrollment
		,pce.ExitDate
		,created_at
		,created_by
	FROM (
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.ServiceAreaId
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
			,created_at
			,created_by
		FROM (
			SELECT pe.PatientId
				,pe.Id
				,pe.CareEnded
				,pce.Active
				,pce.DeleteFlag
				,pe.EnrollmentDate
				,pe.ServiceAreaId
				,sa.Code
				,pce.ExitDate
				,pce.ExitReason
				,pre.ReenrollmentDate
				,pe.[CreateDate] created_at
				,pe.[CreatedBy] created_by
			FROM PatientEnrollment pe
			INNER JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			INNER JOIN PatientReenrollment pre ON pre.PatientId = pce.PatientId
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			LEFT JOIN LookupItem lti ON lti.Id = pce.ExitReason
				AND pce.PatientEnrollmentId = pe.Id
			WHERE pce.DeleteFlag = '1'
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.ServiceAreaId
			,pce.Code
			,pce.ExitDate
			,created_at
			,created_by
		FROM (
			SELECT pe.PatientId
				,pe.CareEnded
				,pe.ServiceAreaId
				,sa.Code
				,pe.EnrollmentDate
				,pce.ExitDate
				,pce.DeleteFlag
				,pe.[CreateDate] created_at
				,pe.[CreatedBy] created_by
			FROM PatientEnrollment pe
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			LEFT JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			LEFT JOIN LookupItem lti ON lti.Id = pce.ExitReason
				AND pce.PatientEnrollmentId = pe.Id
			) pce 
		UNION 
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.ServiceAreaId
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
			,created_at
			,created_by
		FROM (
			SELECT Distinct 
				p.ID PatientId
				,pe.ptn_pk Id
				,pce.CareEnded
				,pe.[StartDate] EnrollmentDate
				,pe.[ModuleId]ServiceAreaId
				,CASE WHEN ModuleName in ('CCC Patient Card MoH 257','HIV Care/ART Card (UG)','HIVCARE-STATICFORM','SMART ART FORM') THEN 'CCC' 
						WHEN ModuleName in ('TB Module','TB') THEN 'TB' 
						WHEN ModuleName in ('PM/SCM With Same point dispense','PM/SCM') THEN 'PM/SCM'
						WHEN ModuleName in ('ANC Maternity and Postnatal') THEN 'PMTCT'  
						ELSE UPPER(ModuleName) END as Code
				,pce.CareEndedDate ExitDate
				,lti.NAME ExitReason
				,pre.ReEnrollDate ReenrollmentDate
				,pe.[CreateDate] created_at
				,pe.[UserID] created_by
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p on p.ptn_pk=pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			INNER JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			INNER JOIN [dbo].[Lnk_PatientReEnrollment] pre ON pre.Ptn_Pk = pce.Ptn_Pk and pre.Ptn_Pk = pe.Ptn_Pk
			LEFT JOIN mst_Decode lti ON lti.[ID] = pce.[PatientExitReason] and pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pce.CareEnded=0 and  pe.ptn_pk  not in (SELECT Distinct p.ptn_pk FROM PatientEnrollment pe INNER JOIN Patient p on p.Id=pe.PatientId)
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.ServiceAreaId
			,pce.Code
			,pce.ExitDate
			,created_at
			,created_by
		FROM (
			SELECT Distinct 
				p.ID PatientId
				,pe.ptn_pk Id
				,pce.CareEnded
				,pe.[StartDate] EnrollmentDate
				,pe.[ModuleId]ServiceAreaId
				,CASE WHEN ModuleName in ('CCC Patient Card MoH 257','HIV Care/ART Card (UG)','HIVCARE-STATICFORM','SMART ART FORM') THEN 'CCC' 
						WHEN ModuleName in ('TB Module','TB') THEN 'TB' 
						WHEN ModuleName in ('PM/SCM With Same point dispense','PM/SCM') THEN 'PM/SCM'
						WHEN ModuleName in ('ANC Maternity and Postnatal') THEN 'PMTCT'  
						ELSE UPPER(ModuleName) END as Code
				,pce.CareEndedDate ExitDate
				,lti.NAME ExitReason
				,pe.[CreateDate] created_at
				,pe.[UserID] created_by
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p on p.ptn_pk=pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			LEFT JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			LEFT JOIN mst_Decode lti ON lti.[ID] = pce.[PatientExitReason] 
			where   pe.ptn_pk  not in (SELECT Distinct p.ptn_pk FROM PatientEnrollment pe INNER JOIN Patient p on p.Id=pe.PatientId)
			) pce 
		) pce 
	) pe ON pe.PatientId = PT.Id