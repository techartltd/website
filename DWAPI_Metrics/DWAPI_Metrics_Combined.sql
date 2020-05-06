

--stores DWAPI metrics to be shipping by DWAPI before migration
USE [IQCare_Siaya]
GO

/****** Object:  Table [dbo].[DWAPI_Migration_Metrics]    Script Date: 3/20/2020 4:43:06 AM ******/
DROP TABLE if exists [dbo].[DWAPI_Migration_Metrics]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DWAPI_Migration_Metrics] (
	[ID] [int] IDENTITY(1, 1) NOT NULL
	,[Dataset] [nvarchar](50) NOT NULL
	,[Metric] [nvarchar](50) NOT NULL
	,[MetricValue] [nvarchar](50) NOT NULL
	,[SiteCode] [int] NULL
	,[FacilityName] [nvarchar](180) NULL
	,[Emr] [nvarchar](50) NULL
	,[CreateDate] [datetime] NULL DEFAULT GETDATE()
	,
	) ON [PRIMARY]
GO

-- check IQCare version
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'EMR'
	,'Version'
	,VersionName
FROM AppAdmin;

-- counts all Persons found 
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'persons'
	,COUNT(*)
FROM Person;

-- counts deleted Persons found 
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'deleted persons'
	,COUNT(*)
FROM Person
WHERE DeleteFlag = 1;

-- counts all patients found
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'patients'
	,COUNT(*)
FROM Patient;

-- counts deleted patients found
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'deleted patients'
	,COUNT(*)
FROM Patient
WHERE DeleteFlag = 1;

-- counts ONLY CCC patient (that is anyone who has ccc number in patient identifiers)
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'ccc patients'
	,COUNT(*)
FROM Patient
WHERE ID IN (
		SELECT DISTINCT PatientId
		FROM PatientIdentifier
		WHERE IdentifierTypeId = 1
			AND DeleteFlag = 0
		)

-- SELECTs Persons who are not patients
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'persons not patients'
	,COUNT(*)
FROM Person
WHERE Id NOT IN (
		SELECT PersonId
		FROM Patient
		WHERE DeleteFlag = 0
		)

--SELECTs all treatment supporters
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'treatment supporters'
	,COUNT(*)
FROM PatientTreatmentSupporter pts

--SELECTs ONLY treatment supporters who are patient also
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'treatment supporters who are patients'
	,COUNT(*)
FROM PatientTreatmentSupporter pts
WHERE pts.SupporterId IN (
		SELECT PersONId
		FROM Patient
		)

-- all patient contacts
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'person contacts - relationships'
	,COUNT(*)
FROM PersonRelationship

-- count of repeated ccc numbers
DROP TABLE

IF EXISTS #DuplicateCCC
	SELECT IdentifierValue RepeatedCCCNumbers
		,COUNT(*) Repeated
	INTO #DuplicateCCC
	FROM PatientIdentifier I
	INNER JOIN Patient p ON i.PatientId = p.Id
	WHERE IdentifierTypeId = 1
	GROUP BY IdentifierValue
	HAVING COUNT(*) > 1

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'CCC'
	,'# of ccc numbers used more than once'
	,sum(Repeated)
FROM #DuplicateCCC

-- counts all Persons by gender
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'Person - ' + l.ItemName
	,COUNT(*)
FROM Person p
LEFT JOIN LookupItemView l ON p.Sex = l.ItemId
WHERE l.MasterName = 'Gender'
	OR l.MasterName = 'Unknown'
GROUP BY l.ItemName

-- counts all patients by gender
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'Patient - ' + l.ItemName
	,COUNT(*)
FROM Person p
LEFT JOIN LookupItemView l ON p.Sex = l.ItemId
WHERE (
		l.MasterName = 'Gender'
		OR l.MasterName = 'Unknown'
		)
	AND id IN (
		SELECT persONid
		FROM patient
		WHERE DeleteFlag = 0
		)
GROUP BY l.ItemName
	,p.Sex

-- counts all patients by type
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Demographics'
	,'Patient - ' + l.ItemName
	,COUNT(*)
FROM Patient p
LEFT JOIN LookupItemView l ON p.PatientType = l.ItemId
WHERE l.MasterName = 'PatientType'
GROUP BY l.ItemName

-- pateint by service enrolment
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Enrolment'
	,i.Name
	,COUNT(*)
FROM PatientIdentifier p
JOIN Identifiers i ON i.Id = p.IdentifierTypeId
WHERE i.DeleteFlag = 0
GROUP BY IdentifierTypeId
	,i.Name

-- pateint by care termination
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Care Termination'
	,l.ItemDisplayName
	,COUNT(*)
FROM PatientCareending p
JOIN LookupItemView l ON p.ExitReasON = l.ItemId
WHERE p.ExitDate IS NOT NULL
GROUP BY l.ItemDisplayName

-- Selects Patients who have been screen for TB
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HIV TB Screening'
	,'Number of TB Screening'
	,COUNT(*) Total
FROM PatientIcf A
INNER JOIN PatientMasterVisit V ON V.ID = A.[PatientMasterVisitId]
	AND A.[PatientId] = V.PatientId

-- Selects Patients who have been screen for IPT
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'IPT Screening'
	,'Number of Patient Screened for IPT'
	,COUNT(*) Total
FROM [PatientIptWorkup] pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId

-- Selects Patients who have been enrolled into IPT Program 
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'IPT Enrollment'
	,'Number Enrolled into IPT'
	,COUNT(*) Total
FROM [PatientIpt] pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId

---Relationship
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Patient Relations'
	,'Number of Patient Relations'
	,COUNT(*) Total
FROM Patient P
INNER JOIN PersonRelationship PR ON P.Id = PR.PatientId
INNER JOIN Person R ON R.Id = PR.PersonId
WHERE p.DeleteFlag = 0
	AND PR.DeleteFlag = 0
	AND R.DeleteFlag = 0

---- Patient Program Enrollment
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Patient Program Enrollment'
	,'Number Enrolled in all Programs '
	,Count(*) Total
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN (
	SELECT DISTINCT pce.PatientId
		,pce.Code
		,pce.Enrollment
		,pce.ExitDate
	FROM (
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
		FROM (
			SELECT pe.PatientId
				,pe.EnrollmentDate
				,sa.Code
				,pce.ExitDate
				,pre.ReenrollmentDate
			FROM PatientEnrollment pe
			INNER JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			INNER JOIN PatientReenrollment pre ON pre.PatientId = pce.PatientId
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			WHERE pce.DeleteFlag = '1'
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.Code
			,pce.ExitDate
		FROM (
			SELECT pe.PatientId
				,sa.Code
				,pe.EnrollmentDate
				,pce.ExitDate
			FROM PatientEnrollment pe
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			LEFT JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
		FROM (
			SELECT DISTINCT p.ID PatientId
				,pe.[StartDate] EnrollmentDate
				,CASE 
					WHEN ModuleName IN (
							'CCC Patient Card MoH 257'
							,'HIV Care/ART Card (UG)'
							,'HIVCARE-STATICFORM'
							,'SMART ART FORM'
							)
						THEN 'CCC'
					WHEN ModuleName IN (
							'TB Module'
							,'TB'
							)
						THEN 'TB'
					WHEN ModuleName IN (
							'PM/SCM With Same point dispense'
							,'PM/SCM'
							)
						THEN 'PM/SCM'
					WHEN ModuleName IN ('ANC Maternity and Postnatal')
						THEN 'PMTCT'
					ELSE UPPER(ModuleName)
					END AS Code
				,pce.CareEndedDate ExitDate
				,pre.ReEnrollDate ReenrollmentDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p ON p.ptn_pk = pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			INNER JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			INNER JOIN [dbo].[Lnk_PatientReEnrollment] pre ON pre.Ptn_Pk = pce.Ptn_Pk
				AND pre.Ptn_Pk = pe.Ptn_Pk
			LEFT JOIN mst_Decode lti ON lti.[ID] = pce.[PatientExitReason]
				AND pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pce.CareEnded = 0
				AND pe.ptn_pk NOT IN (
					SELECT DISTINCT p.ptn_pk
					FROM PatientEnrollment pe
					INNER JOIN Patient p ON p.Id = pe.PatientId
					)
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.Code
			,pce.ExitDate
		FROM (
			SELECT DISTINCT p.ID PatientId
				,pe.[StartDate] EnrollmentDate
				,CASE 
					WHEN ModuleName IN (
							'CCC Patient Card MoH 257'
							,'HIV Care/ART Card (UG)'
							,'HIVCARE-STATICFORM'
							,'SMART ART FORM'
							)
						THEN 'CCC'
					WHEN ModuleName IN (
							'TB Module'
							,'TB'
							)
						THEN 'TB'
					WHEN ModuleName IN (
							'PM/SCM With Same point dispense'
							,'PM/SCM'
							)
						THEN 'PM/SCM'
					WHEN ModuleName IN ('ANC Maternity and Postnatal')
						THEN 'PMTCT'
					ELSE UPPER(ModuleName)
					END AS Code
				,pce.CareEndedDate ExitDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p ON p.ptn_pk = pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			LEFT JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pe.ptn_pk NOT IN (
					SELECT DISTINCT p.ptn_pk
					FROM PatientEnrollment pe
					INNER JOIN Patient p ON p.Id = pe.PatientId
					)
			) pce
		) pce
	) pe ON pe.PatientId = PT.Id

---- ART Preparation
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'ART Treatment Preparation'
	,'Number of Patients Assessed for ART'
	,COUNT(*) Total
FROM (
	SELECT p.PersonId AS Person_Id
		,pmv.VisitDate AS Encounter_Date
	FROM PatientSupportSystemCriteria part
	INNER JOIN Patient p ON p.Id = part.PatientId
	INNER JOIN PatientMasterVisit pmv ON pmv.Id = part.PatientMasterVisitId
	
	UNION
	
	SELECT p.PersonId AS Person_Id
		,pmv.VisitDate AS Encounter_Date
	FROM PatientPsychosocialCriteria part
	INNER JOIN Patient p ON p.Id = part.PatientId
	INNER JOIN PatientMasterVisit pmv ON pmv.Id = part.PatientMasterVisitId
	) A

-- Counts all Family Members HIV History
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HIV Family History'
	,'Number of Family Members HIV History'
	,COUNT(*) Total
FROM (
	SELECT DISTINCT p.PersonId AS Person_Id
		,pr.PersonId AS Relative_Person_Id
		,pr.CreateDate AS Encounter_Date
	FROM Patient P
	INNER JOIN PersonRelationship pr ON pr.PatientId = p.Id
	LEFT JOIN Person pre ON pre.Id = pr.PersonId
	LEFT JOIN (
		SELECT [Ptn_pk]
			,a.CreateDate
		FROM [dbo].[dtl_FamilyInfo] a
		INNER JOIN [mst_HIVCareStatus] c ON c.id = a.[HivCareStatus]
		WHERE a.deleteflag = 0
		) relpatient ON relpatient.ptn_pk = p.ptn_pk
		AND p.id = pr.patientid
		AND pr.createdate = relpatient.CreateDate
	LEFT JOIN PatientLinkage plink ON plink.PersonId = pr.PersonId
	) A

-- depression screening
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Depression Screening'
	,'Patients screened'
	,count(*)
FROM (
	SELECT DISTINCT pe.PatientId
		,pmv.VisitDate
	FROM PatientEncounter pe
	INNER JOIN (
		SELECT *
		FROM LookupItemView
		WHERE MasterName = 'EncounterType'
			AND ItemName IN (
				'DepressionScreening'
				,'Adherence-Barriers'
				)
		) ab ON ab.ItemId = pe.EncounterTypeId
	INNER JOIN PatientMasterVisit pmv ON pmv.Id = pe.PatientMasterVisitId
		AND pmv.PatientId = pe.PatientId
	) a

-- followup education
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Followup Education'
	,'Patients screened'
	,count(*)
FROM (
	SELECT DISTINCT p.PersonId AS Person_Id
		,fe.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,mct.[Name] AS CounsellingType
		,mctt.[Name] AS CounsellingTopic
		,fe.Comments
	FROM dtl_FollowupEducation fe
	INNER JOIN Patient p ON p.ptn_pk = fe.Ptn_pk
	INNER JOIN mst_CouncellingType mct ON mct.ID = fe.CouncellingTypeId
	INNER JOIN mst_CouncellingTopic mctt ON mctt.ID = fe.CouncellingTopicId
	) a

-- Adherence Barriers
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Adherence Barriers'
	,'Patients screened'
	,count(*)
FROM (
	SELECT pe.PatientId
		,pmv.VisitDate
	FROM PatientEncounter pe
	INNER JOIN (
		SELECT *
		FROM LookupItemView
		WHERE MasterName = 'EncounterType'
			AND ItemName = 'Adherence-Barriers'
		) ab ON ab.ItemId = pe.EncounterTypeId
	INNER JOIN PatientMasterVisit pmv ON pmv.Id = pe.PatientMasterVisitId
		AND pmv.PatientId = pe.PatientId
	) a

--OVC Enrollments
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'OVC Enrollment'
	,'Total Number of OVC Enrollments'
	,count(p.PersonId) Total
FROM Patient p
INNER JOIN PatientEnrollment pe ON p.Id = pe.PatientId
INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
WHERE sa.Code = 'OVC'

--OVC Outcomes
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'OVC Outcome'
	,'Total Number of OVC Outcomes'
	,count(p.PersonId) Total
FROM PatientCareending pce
INNER JOIN Patient p ON pce.PatientId = p.Id
INNER JOIN PatientEnrollment pe ON pe.Id = pce.PatientEnrollmentId
INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
WHERE sa.Code = 'OVC'

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'ART Fast Track'
	,'Number of FastTracks'
	,COUNT(*)
FROM (
	SELECT *
	FROM PatientArtDistribution paa
	) B

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'ART Fast Track'
	,Refill_Model
	,COUNT(*)
FROM (
	SELECT (
			SELECT TOP 1 DisplayName
			FROM LookupItem li
			WHERE li.Id = paa.ArtRefillModel
			) AS Refill_Model
	FROM PatientArtDistribution paa
	) B
GROUP BY Refill_Model

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Labs'
	,'Number of Lab Tests (ALL)'
	,COUNT(*) Total
FROM ord_LabOrder plo
INNER JOIN dtl_LabOrderTest OT ON OT.LabOrderId = plo.Id
INNER JOIN dtl_LabOrderTestResult r ON r.LabOrderTestId = OT.Id
INNER JOIN ord_Visit v ON v.Visit_Id = plo.VisitId
WHERE (
		v.DeleteFlag = 0
		OR v.DeleteFlag IS NULL
		)
	OR plo.DeleteFlag = 0

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Labs'
	,CONCAT (
		OrderStatus
		,'  |  '
		,AvailResults
		) Results
	,Count(*) TotalLabTests
FROM (
	SELECT CASE 
			WHEN COALESCE(CAST(r.ResultValue AS VARCHAR(20)), r.ResultText, r.ResultOption) IS NOT NULL
				OR (
					COALESCE(CAST(r.ResultValue AS VARCHAR(20)), r.ResultText, r.ResultOption) IS NULL
					AND Undetectable = 1
					AND HasResult = 1
					)
				THEN 'With Results'
			ELSE 'No Results'
			END AS AvailResults
		,plo.OrderStatus
	FROM ord_LabOrder plo
	INNER JOIN dtl_LabOrderTest OT ON OT.LabOrderId = plo.Id
	INNER JOIN dtl_LabOrderTestResult r ON r.LabOrderTestId = OT.Id
	INNER JOIN ord_Visit v ON v.Visit_Id = plo.VisitId
	WHERE (
			v.DeleteFlag = 0
			OR v.DeleteFlag IS NULL
			)
		OR plo.DeleteFlag = 0
	) A
GROUP BY OrderStatus
	,AvailResults

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Labs'
	,CONCAT (
		LabTestName
		,'  |  '
		,Min(cast(OrderDate AS DATE))
		,'  |  '
		,Max(cast(OrderDate AS DATE))
		) LabsWithDates
	,Count(*) AS Total
FROM (
	SELECT LabTestName
		,OrderDate
	FROM ord_LabOrder plo
	INNER JOIN dtl_LabOrderTest OT ON OT.LabOrderId = plo.Id
	INNER JOIN dtl_LabOrderTestResult r ON r.LabOrderTestId = OT.Id
	INNER JOIN ord_Visit v ON v.Visit_Id = plo.VisitId
	LEFT JOIN mst_User u ON u.UserID = plo.OrderedBy
	LEFT JOIN (
		SELECT P.Id ParameterId
			,P.ParameterName
			,T.Name AS LabTestName
		FROM mst_LabTestMaster T
		INNER JOIN Mst_LabTestParameter P ON T.Id = P.LabTestId
		LEFT OUTER JOIN mst_LabDepartment D ON T.DepartmentId = D.LabDepartmentID
		) vlw ON vlw.ParameterId = r.ParameterId
	WHERE plo.DeleteFlag = 0
		OR (
			v.DeleteFlag = 0
			OR v.DeleteFlag IS NULL
			)
	) B
GROUP BY LabTestName
ORDER BY LabTestName

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Defaulter Tracing'
	,'Number of LTFU'
	,Count(*) Total
FROM (
	SELECT (
			SELECT TOP 1. [Name]
			FROM Lookupitem
			WHERE id = pce.ExitReason
			) AS ExitReason
		,pce.DeleteFlag
	FROM PatientCareending pce
	INNER JOIN Patient p ON p.Id = pce.PatientId
	INNER JOIN PatientMasterVisit pmv ON pmv.Id = pce.PatientMasterVisitId
		AND pce.patientId = pmv.PatientId
	) pce
WHERE pce.ExitReason = 'LostToFollowUp'
	AND pce.DeleteFlag = 0

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Alcohol Screening'
	,'Number of Patients'
	,COUNT(*)
FROM (
	SELECT DISTINCT pt.PersonId
		,pe.VisitDate
		,pdr.Answer AS DrinkAlcoholMorethanSips
		,pc2ma.Answer AS SmokeAnyMarijuana
		,pcq3.Answer AS UseAnythingElseGetHigh
		,crs1.Answer AS CARDrivenandHigh
		,crs2.Answer AS UseDrugorAlcoholRelax
		,crs3.Answer AS UseDrugByYourself
		,crs4.Answer AS ForgetWhileUsingAlcohol
		,crs5.Answer AS FamilyTellYouCutDownDrugs
		,crs6.Answer AS TroubleWhileUsingDrugs
		,arll.Answer AS AlcoholRiskLevel
		,als.Answer AS AlcoholScore
		,sh.Answer AS Notes
		,pe.DeleteFlag AS Voided
	FROM Patient pt
	INNER JOIN (
		SELECT pe.PatientId
			,pe.EncounterTypeId
			,pe.PatientMasterVisitId
			,pmv.VisitDate
			,pmv.DeleteFlag
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pmv ON pmv.Id = pe.PatientMasterVisitId
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'EncounterType'
			) liv ON liv.ItemId = pe.EncounterTypeId
		WHERE liv.ItemName = 'AlcoholandDrugAbuseScreening'
		) pe ON pe.PatientId = pt.Id
	INNER JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScreeningQuestions'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pcss ON pcss.PatientId = pe.PatientId
		AND pcss.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScreeningQuestions'
				AND ItemName = 'CRAFFTScreeningQuestion1'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pdr ON pdr.PatientId = pe.PatientId
		AND pdr.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScreeningQuestions'
				AND ItemName = 'CRAFFTScreeningQuestion2'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pc2ma ON pc2ma.PatientId = pe.PatientId
		AND pc2ma.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScreeningQuestions'
				AND ItemName = 'CRAFFTScreeningQuestion3'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pcq3 ON pcq3.PatientId = pe.PatientId
		AND pcq3.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion1'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs1 ON crs1.PatientId = pe.PatientId
		AND crs1.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion2'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs2 ON crs2.PatientId = pe.PatientId
		AND crs2.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion3'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs3 ON crs3.PatientId = pe.PatientId
		AND crs3.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion4'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs4 ON crs4.PatientId = pe.PatientId
		AND crs4.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion5'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs5 ON crs5.PatientId = pe.PatientId
		AND crs5.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'CRAFFTScoreQuestions'
				AND ItemName = 'CRAFFTScoreQuestion6'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) crs6 ON crs6.PatientId = pe.PatientId
		AND crs6.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'AlcoholScreeningNotes'
					AND lt.ItemName = 'AlcoholRiskLevel'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) arll ON arll.PatientId = pe.PatientId
		AND arll.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'AlcoholScreeningNotes'
					AND lt.ItemName = 'AlcoholScore'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) als ON als.PatientId = pe.PatientId
		AND als.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'SocialHistory'
					AND lt.ItemName = 'SocialNotes'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) sh ON sh.PatientId = pe.PatientId
		AND sh.PatientMasterVisitId = pe.PatientMasterVisitId
	) BB

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Alcohol Screening'
	,'Number of Patients'
	,COUNT(*)
FROM (
	SELECT DISTINCT pt.PersonId
		,pe.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,pdra.Answer AS DrinkAlcohol
		,pss.Answer AS Smoke
		,pudd.Answer AS UseDrugs
		,trss.Answer AS [TriedStopSmoking]
		,asq1.Answer AS FeltCutDownDrinkingorDrugUse
		,asq2.Answer AS AnnoyedByCriticizingDrinkingorDrugUse
		,asq3.Answer AS FeltGuiltyDrinkingorDrugUse
		,asq4.Answer AS UseToSteadyNervesGetRidHangover
		,arll.Answer AS AlcoholRiskLevel
		,als.Answer AS AlcoholScore
		,sh.Answer AS Notes
		,pe.DeleteFlag AS Voided
	FROM Patient pt
	INNER JOIN (
		SELECT pe.PatientId
			,pe.EncounterTypeId
			,pe.PatientMasterVisitId
			,pmv.VisitDate
			,pmv.DeleteFlag
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pmv ON pmv.Id = pe.PatientMasterVisitId
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'EncounterType'
				OR MasterName = 'SocialHistoryQuestions'
			) liv ON liv.ItemId = pe.EncounterTypeId
		WHERE liv.ItemName = 'AlcoholandDrugAbuseScreening'
		) pe ON pe.PatientId = pt.Id
	INNER JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
		FROM PatientScreening psc
		WHERE ScreeningCategoryID IN (
				SELECT DISTINCT itemID
				FROM LookupItemView
				WHERE MasterName = 'SocialHistoryQuestions'
				)
		) psq ON psq.PatientId = pe.PatientId
		AND psq.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'SocialHistoryQuestions'
				AND ItemName = 'DrinkAlcohol'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pdra ON pdra.PatientId = pe.PatientId
		AND pdra.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'SocialHistoryQuestions'
				AND ItemName = 'Smoke'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pss ON pss.PatientId = pe.PatientId
		AND pss.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'SocialHistoryQuestions'
				AND ItemName = 'UseDrugs'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) pudd ON pudd.PatientId = pe.PatientId
		AND pudd.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'SmokingScreeningQuestions'
				AND ItemName = 'SmokingScreeningQuestion1'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) trss ON trss.PatientId = pe.PatientId
		AND trss.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'AlcoholScreeningQuestions'
				AND ItemName = 'AlcoholScreeningQuestion1'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) asq1 ON asq1.PatientId = pe.PatientId
		AND asq1.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'AlcoholScreeningQuestions'
				AND ItemName = 'AlcoholScreeningQuestion2'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) asq2 ON asq2.PatientId = pe.PatientId
		AND asq2.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'AlcoholScreeningQuestions'
				AND ItemName = 'AlcoholScreeningQuestion3'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) asq3 ON asq3.PatientId = pe.PatientId
		AND asq3.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,psc.ScreeningTypeId
			,psc.DeleteFlag
			,lti.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView
			WHERE MasterName = 'AlcoholScreeningQuestions'
				AND ItemName = 'AlcoholScreeningQuestion4'
			) ltv ON ltv.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem lti ON lti.Id = psc.ScreeningValueId
		) asq4 ON asq4.PatientId = pe.PatientId
		AND asq4.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'AlcoholScreeningNotes'
					AND lt.ItemName = 'AlcoholRiskLevel'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) arll ON arll.PatientId = pe.PatientId
		AND arll.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'AlcoholScreeningNotes'
					AND lt.ItemName = 'AlcoholScore'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) als ON als.PatientId = pe.PatientId
		AND als.PatientMasterVisitId = pe.PatientMasterVisitId
	LEFT JOIN (
		SELECT *
		FROM (
			SELECT pc.PatientId
				,pc.PatientMasterVisitId
				,lt.DisplayName AS Question
				,pc.DeleteFlag
				,lt.ItemName
				,pc.ClinicalNotes AS Answer
				,ROW_NUMBER() OVER (
					PARTITION BY pc.PatientId
					,pc.PatientMasterVisitId ORDER BY pc.Id DESC
					) rownum
			FROM PatientClinicalNotes pc
			INNER JOIN (
				SELECT *
				FROM LookupItemView lt
				WHERE lt.MasterName = 'SocialHistory'
					AND lt.ItemName = 'SocialNotes'
				) lt ON lt.ItemId = pc.NotesCategoryId
			WHERE (
					pc.DeleteFlag IS NULL
					OR pc.DeleteFlag = 0
					)
			) pc
		WHERE pc.rownum = '1'
		) sh ON sh.PatientId = pe.PatientId
		AND sh.PatientMasterVisitId = pe.PatientMasterVisitID
	) BB

--PatientEnrolled in each year based on servicearea
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'Patients Enrolled : ServiceArea: ' + ptt.Code
	,'Year:' + CAST(Year(ptt.Enrollment) AS VARCHAR(max))
	,Count(ptt.PatientId) AS Total
FROM (
	SELECT DISTINCT pce.PatientId
		,pce.Code
		,pce.Enrollment
		,pce.ExitDate
	FROM (
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
		FROM (
			SELECT pe.PatientId
				,pe.EnrollmentDate
				,sa.Code
				,pce.ExitDate
				,pre.ReenrollmentDate
			FROM PatientEnrollment pe
			INNER JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			INNER JOIN PatientReenrollment pre ON pre.PatientId = pce.PatientId
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			WHERE pce.DeleteFlag = '1'
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.Code
			,pce.ExitDate
		FROM (
			SELECT pe.PatientId
				,sa.Code
				,pe.EnrollmentDate
				,pce.ExitDate
			FROM PatientEnrollment pe
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			LEFT JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.ReenrollmentDate AS Enrollment
			,pce.Code
			,CASE 
				WHEN pce.ExitDate > pce.ReenrollmentDate
					THEN pce.ExitDate
				ELSE NULL
				END AS ExitDate
		FROM (
			SELECT DISTINCT p.ID PatientId
				,pe.[StartDate] EnrollmentDate
				,CASE 
					WHEN ModuleName IN (
							'CCC Patient Card MoH 257'
							,'HIV Care/ART Card (UG)'
							,'HIVCARE-STATICFORM'
							,'SMART ART FORM'
							)
						THEN 'CCC'
					WHEN ModuleName IN (
							'TB Module'
							,'TB'
							)
						THEN 'TB'
					WHEN ModuleName IN (
							'PM/SCM With Same point dispense'
							,'PM/SCM'
							)
						THEN 'PM/SCM'
					WHEN ModuleName IN ('ANC Maternity and Postnatal')
						THEN 'PMTCT'
					ELSE UPPER(ModuleName)
					END AS Code
				,pce.CareEndedDate ExitDate
				,pre.ReEnrollDate ReenrollmentDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p ON p.ptn_pk = pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			INNER JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			INNER JOIN [dbo].[Lnk_PatientReEnrollment] pre ON pre.Ptn_Pk = pce.Ptn_Pk
				AND pre.Ptn_Pk = pe.Ptn_Pk
			LEFT JOIN mst_Decode lti ON lti.[ID] = pce.[PatientExitReason]
				AND pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pce.CareEnded = 0
				AND pe.ptn_pk NOT IN (
					SELECT DISTINCT p.ptn_pk
					FROM PatientEnrollment pe
					INNER JOIN Patient p ON p.Id = pe.PatientId
					)
			) pce
		
		UNION
		
		SELECT pce.PatientId
			,pce.EnrollmentDate AS Enrollment
			,pce.Code
			,pce.ExitDate
		FROM (
			SELECT DISTINCT p.ID PatientId
				,pe.[StartDate] EnrollmentDate
				,CASE 
					WHEN ModuleName IN (
							'CCC Patient Card MoH 257'
							,'HIV Care/ART Card (UG)'
							,'HIVCARE-STATICFORM'
							,'SMART ART FORM'
							)
						THEN 'CCC'
					WHEN ModuleName IN (
							'TB Module'
							,'TB'
							)
						THEN 'TB'
					WHEN ModuleName IN (
							'PM/SCM With Same point dispense'
							,'PM/SCM'
							)
						THEN 'PM/SCM'
					WHEN ModuleName IN ('ANC Maternity and Postnatal')
						THEN 'PMTCT'
					ELSE UPPER(ModuleName)
					END AS Code
				,pce.CareEndedDate ExitDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p ON p.ptn_pk = pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			LEFT JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pe.ptn_pk NOT IN (
					SELECT DISTINCT p.ptn_pk
					FROM PatientEnrollment pe
					INNER JOIN Patient p ON p.Id = pe.PatientId
					)
			) pce
		) pce
	) ptt
GROUP BY Year(ptt.Enrollment)
	,ptt.Code
ORDER BY ptt.Code DESC
	,Year(ptt.Enrollment) DESC
	
--hts
INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 

--- 
INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced where Contact_Outcome is Contacted', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 
WHERE  t.contact_outcome = 'Contacted' 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced where Contact_Outcome is Contacted and Linked', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 
WHERE  t.contact_outcome = 'Contacted and Linked' 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTS_Initial_&_Retest', 
       'Number of HTS Test that FinalResult was Negative', 
       Count(*) Total 
FROM  (SELECT * 
       FROM  (SELECT HE.personid                               Person_Id, 
                     PT.id                                     Patient_Id, 
                     Encounter_Date = Format(Cast(PE.encounterstarttime AS DATE) 
                                      , 
                                      'yyyy-MM-dd'), 
                     Encounter_ID = HE.id, 
                     Pop_Type = PPL2.populationtype, 
                     Key_Pop_Type = PPL2.keypop, 
                     Priority_Pop_Type = PPR2.priopop, 
                     Patient_disabled = ( CASE Isnull(PI.disability, '') 
                                            WHEN '' THEN 'No' 
                                            ELSE 'Yes' 
                                          END ), 
                     PI.disability, 
                     Ever_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.evertested 
                                           AND mastername = 'YesNo'), 
                     Self_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.everselftested 
                                           AND mastername = 'YesNo'), 
                     HE.monthsinceselftest,--added 
                     HE.monthssincelasttest,--added 
                     HTS_Strategy = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  mastername = 'Strategy' 
                                            AND itemid = HE.testingstrategy), 
                     HTS_Entry_Point = (SELECT itemname 
                                        FROM   lookupitemview 
                                        WHERE  mastername = 'HTSEntryPoints' 
                                               AND itemid = HE.testentrypoint), 
                     (SELECT TOP 1 itemname 
                      FROM   lookupitemview 
                      WHERE  itemid = (SELECT TOP 1 consentvalue 
                                       FROM   patientconsent 
                                       WHERE  patientmastervisitid = PM.id 
                                              AND serviceareaid = 2 
                                              AND consenttype = (SELECT itemid 
                                                                 FROM 
                                                  lookupitemview 
                                                                 WHERE 
                                                  mastername = 'ConsentType' 
                                                  AND 
                                                  itemname = 'ConsentToBeTested' 
                                                                ) 
                                       ORDER  BY id DESC))     AS Consented, 
                     TestedAs = (SELECT itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = HE.testedas 
                                        AND mastername = 'TestedAs'), 
                     TestType = CASE HE.encountertype 
                                  WHEN 1 THEN 'Initial Test' 
                                  WHEN 2 THEN 'Repeat Test' 
                                END, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 1 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundonetestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Final_Result, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 2 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundtwotestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Final_Result, 
                     Final_Result = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HER.finalresult 
                                            AND mastername = 'HIVFinalResults'), 
                     Result_given = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HE.finalresultgiven 
                                            AND mastername = 'YesNo'), 
                     Couple_Discordant = (SELECT itemname 
                                          FROM   lookupitemview 
                                          WHERE  itemid = HE.couplediscordant 
                                                 AND mastername = 'YesNoNA'), 
                     TB_SCreening_Results = (SELECT TOP 1 itemname 
                                             FROM   lookupitemview 
                                             WHERE 
                     mastername = 'TbScreening' 
                     AND itemid = (SELECT TOP 1 
                                  screeningvalueid 
                                   FROM 
                         patientscreening 
                                   WHERE 
                         patientmastervisitid 
                         = PM.id 
                         AND patientid = 
                             PT.id 
                         AND screeningtypeid 
                             = 
                     ( 
                                 SELECT 
                     TOP 1 
                     masterid 
                                 FROM 
                     lookupitemview 
                                 WHERE 
                                 mastername = 
                                 'TbScreening'))) 
                            , 
                     HE.encounterremarks                       AS Remarks, 
                     0                                         AS Voided 
              FROM   htsencounter HE 
                     LEFT JOIN htsencounterresult HER 
                            ON HER.htsencounterid = HE.id 
                     INNER JOIN patientencounter PE 
                             ON PE.id = HE.patientencounterid 
                     INNER JOIN patientmastervisit PM 
                             ON PM.id = PE.patientmastervisitid 
                     INNER JOIN person P 
                             ON P.id = HE.personid 
                     INNER JOIN patient PT 
                             ON PT.personid = P.id 
                     LEFT JOIN (SELECT Main.person_id, 
LEFT(Main.disability, Len(Main.disability) - 1) 
AS 
                              "Disability" 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM   lookupitemview 
                          WHERE 
                 mastername = 'Disabilities' 
                 AND itemid = CD.disabilityid) 
                         + ' , ' AS [text()] 
                  FROM   clientdisability CD 
INNER JOIN patientencounter 
           PE 
        ON 
PE.id = CD.patientencounterid 
                  WHERE  CD.personid = P.id 
                  ORDER  BY CD.personid 
                  FOR xml path ('')) 
                 [Disability] 
 FROM   person P) [Main]) PI 
ON PI.person_id = P.id 
LEFT JOIN (SELECT PPL.person_id, 
PPL.populationtype, 
PPL.keypop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 PPT.populationtype, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
LK.itemid = PP.populationcategory 
AND mastername = 'HTSKeyPopulation') 
        + ' , ' AS [text()] 
 FROM   patientpopulation PP 
 WHERE  PP.personid = P.id 
 ORDER  BY PP.personid 
 FOR xml path ('')) [KeyPop] 
 FROM   person P 
        LEFT JOIN patientpopulation PPT 
               ON PPT.personid = P.id) PPL) 
PPL2 
ON PPL2.person_id = P.id 
LEFT JOIN (SELECT PPR.person_id, 
PPR.priopop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
                 LK.itemid = PP.priorityid 
                 AND mastername = 
                     'PriorityPopulation') 
                         + ' , ' AS [text()] 
                  FROM   personpriority PP 
                  WHERE  PP.personid = P.id 
                  ORDER  BY PP.personid 
                  FOR xml path ('')) [PrioPop] 
 FROM   person P 
        LEFT JOIN personpriority PPY 
               ON PPY.personid = P.id) PPR) 
PPR2 
ON PPR2.person_id = P.id)hts 
WHERE  hts.final_result = 'Negative')hts 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTS_Initial_&_Retest', 
       'Number of HTS Test that FinalResult was Positive', 
       Count(*) Total 
FROM  (SELECT * 
       FROM  (SELECT HE.personid                               Person_Id, 
                     PT.id                                     Patient_Id, 
                     Encounter_Date = Format(Cast(PE.encounterstarttime AS DATE) 
                                      , 
                                      'yyyy-MM-dd'), 
                     Encounter_ID = HE.id, 
                     Pop_Type = PPL2.populationtype, 
                     Key_Pop_Type = PPL2.keypop, 
                     Priority_Pop_Type = PPR2.priopop, 
                     Patient_disabled = ( CASE Isnull(PI.disability, '') 
                                            WHEN '' THEN 'No' 
                                            ELSE 'Yes' 
                                          END ), 
                     PI.disability, 
                     Ever_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.evertested 
                                           AND mastername = 'YesNo'), 
                     Self_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.everselftested 
                                           AND mastername = 'YesNo'), 
                     HE.monthsinceselftest,--added 
                     HE.monthssincelasttest,--added 
                     HTS_Strategy = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  mastername = 'Strategy' 
                                            AND itemid = HE.testingstrategy), 
                     HTS_Entry_Point = (SELECT itemname 
                                        FROM   lookupitemview 
                                        WHERE  mastername = 'HTSEntryPoints' 
                                               AND itemid = HE.testentrypoint), 
                     (SELECT TOP 1 itemname 
                      FROM   lookupitemview 
                      WHERE  itemid = (SELECT TOP 1 consentvalue 
                                       FROM   patientconsent 
                                       WHERE  patientmastervisitid = PM.id 
                                              AND serviceareaid = 2 
                                              AND consenttype = (SELECT itemid 
                                                                 FROM 
                                                  lookupitemview 
                                                                 WHERE 
                                                  mastername = 'ConsentType' 
                                                  AND 
                                                  itemname = 'ConsentToBeTested' 
                                                                ) 
                                       ORDER  BY id DESC))     AS Consented, 
                     TestedAs = (SELECT itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = HE.testedas 
                                        AND mastername = 'TestedAs'), 
                     TestType = CASE HE.encountertype 
                                  WHEN 1 THEN 'Initial Test' 
                                  WHEN 2 THEN 'Repeat Test' 
                                END, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 1 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundonetestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Final_Result, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 2 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundtwotestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Final_Result, 
                     Final_Result = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HER.finalresult 
                                            AND mastername = 'HIVFinalResults'), 
                     Result_given = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HE.finalresultgiven 
                                            AND mastername = 'YesNo'), 
                     Couple_Discordant = (SELECT itemname 
                                          FROM   lookupitemview 
                                          WHERE  itemid = HE.couplediscordant 
                                                 AND mastername = 'YesNoNA'), 
                     TB_SCreening_Results = (SELECT TOP 1 itemname 
                                             FROM   lookupitemview 
                                             WHERE 
                     mastername = 'TbScreening' 
                     AND itemid = (SELECT TOP 1 
                                  screeningvalueid 
                                   FROM 
                         patientscreening 
                                   WHERE 
                         patientmastervisitid 
                         = PM.id 
                         AND patientid = 
                             PT.id 
                         AND screeningtypeid 
                             = 
                     ( 
                                 SELECT 
                     TOP 1 
                     masterid 
                                 FROM 
                     lookupitemview 
                                 WHERE 
                                 mastername = 
                                 'TbScreening'))) 
                            , 
                     HE.encounterremarks                       AS Remarks, 
                     0                                         AS Voided 
              FROM   htsencounter HE 
                     LEFT JOIN htsencounterresult HER 
                            ON HER.htsencounterid = HE.id 
                     INNER JOIN patientencounter PE 
                             ON PE.id = HE.patientencounterid 
                     INNER JOIN patientmastervisit PM 
                             ON PM.id = PE.patientmastervisitid 
                     INNER JOIN person P 
                             ON P.id = HE.personid 
                     INNER JOIN patient PT 
                             ON PT.personid = P.id 
                     LEFT JOIN (SELECT Main.person_id, 
LEFT(Main.disability, Len(Main.disability) - 1) 
AS 
                              "Disability" 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM   lookupitemview 
                          WHERE 
                 mastername = 'Disabilities' 
                 AND itemid = CD.disabilityid) 
                         + ' , ' AS [text()] 
                  FROM   clientdisability CD 
INNER JOIN patientencounter 
           PE 
        ON 
PE.id = CD.patientencounterid 
                  WHERE  CD.personid = P.id 
                  ORDER  BY CD.personid 
                  FOR xml path ('')) 
                 [Disability] 
 FROM   person P) [Main]) PI 
ON PI.person_id = P.id 
LEFT JOIN (SELECT PPL.person_id, 
PPL.populationtype, 
PPL.keypop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 PPT.populationtype, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
LK.itemid = PP.populationcategory 
AND mastername = 'HTSKeyPopulation') 
        + ' , ' AS [text()] 
 FROM   patientpopulation PP 
 WHERE  PP.personid = P.id 
 ORDER  BY PP.personid 
 FOR xml path ('')) [KeyPop] 
 FROM   person P 
        LEFT JOIN patientpopulation PPT 
               ON PPT.personid = P.id) PPL) 
PPL2 
ON PPL2.person_id = P.id 
LEFT JOIN (SELECT PPR.person_id, 
PPR.priopop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
                 LK.itemid = PP.priorityid 
                 AND mastername = 
                     'PriorityPopulation') 
                         + ' , ' AS [text()] 
                  FROM   personpriority PP 
                  WHERE  PP.personid = P.id 
                  ORDER  BY PP.personid 
                  FOR xml path ('')) [PrioPop] 
 FROM   person P 
        LEFT JOIN personpriority PPY 
               ON PPY.personid = P.id) PPR) 
PPR2 
ON PPR2.person_id = P.id)hts 
WHERE  hts.final_result = 'Positive')hts 






UPDATE DWAPI_Migration_Metrics
SET SiteCode = (
		SELECT TOP 1 b.PosID
		FROM mst_patient a
		INNER JOIN mst_facility b ON a.LocationID = b.facilityid
		WHERE a.DeleteFlag = 0
			AND FacilityName <> 'Demo Facility'
		GROUP BY b.FacilityName
			,b.PosID
		HAVING count(locationid) IN (
				SELECT ID ID
				FROM (
					SELECT LocationID
						,Count(LocationID) ID
					FROM mst_patient
					WHERE DeleteFlag = 0
					GROUP BY LocationID
					) a
				)
		)
	,FacilityName = (
		SELECT TOP 1 b.FacilityName
		FROM mst_patient a
		INNER JOIN mst_facility b ON a.LocationID = b.facilityid
		WHERE a.DeleteFlag = 0
			AND FacilityName <> 'Demo Facility'
		GROUP BY b.FacilityName
			,b.PosID
		HAVING count(locationid) IN (
				SELECT ID ID
				FROM (
					SELECT LocationID
						,Count(LocationID) ID
					FROM mst_patient
					WHERE DeleteFlag = 0
					GROUP BY LocationID
					) a
				)
		)
	,Emr = (
		SELECT VersionName
		FROM AppAdmin
		)

SELECT *
FROM DWAPI_Migration_Metrics

