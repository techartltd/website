--stores DWAPI metrics to be shipping by DWAPI before migration
USE [IQCare_Siaya]
GO

/****** Object:  Table [dbo].[DWAPI_Migration_Metrics]    Script Date: 3/20/2020 4:43:06 AM ******/
DROP TABLE if exists [dbo].[DWAPI_Migration_Metrics]
GO

/****** Object:  Table [dbo].[DWAPI_Migration_Metrics]    Script Date: 3/20/2020 4:43:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DWAPI_Migration_Metrics](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Dataset] [nvarchar](50) NOT NULL,
	[Metric] [nvarchar](50) NOT NULL,
	[MetricValue] [nvarchar](50) NOT NULL,
	[SiteCode] [int] NULL,
        [FacilityName] [nvarchar](180) NULL,
        [Emr] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL DEFAULT GETDATE(),       
) ON [PRIMARY]
GO
-- check IQCare version
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT  'EMR', 'Version', VersionName FROM AppAdmin;
-- counts all Persons found 
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'persons', COUNT(*) FROM Person;
-- counts deleted Persons found 
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'deleted persons', COUNT(*) FROM Person WHERE DeleteFlag = 1;
 -- counts all patients found
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'patients', COUNT(*) FROM Patient;
 -- counts deleted patients found
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'deleted patients', COUNT(*) FROM Patient WHERE DeleteFlag = 1;

-- counts ONLY CCC patient (that is anyone who has ccc number in patient identifiers)
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'ccc patients', COUNT(*) FROM Patient WHERE ID in (SELECT distinct PatientId FROM PatientIdentifier WHERE IdentifierTypeId = 1 and DeleteFlag = 0) 

-- SELECTs Persons who are not patients
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'persons not patients', COUNT(*) FROM Person WHERE Id not in (SELECT PersonId FROM Patient WHERE DeleteFlag = 0)

--SELECTs all treatment supporters
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'treatment supporters', COUNT(*) FROM PatientTreatmentSupporter pts

--SELECTs ONLY treatment supporters who are patient also
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'treatment supporters who are patients', COUNT(*) FROM PatientTreatmentSupporter pts WHERE pts.SupporterId in (SELECT PersONId FROM Patient)


-- all patient contacts
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'person contacts - relationships', COUNT(*) FROM PersonRelationship

-- count of repeated ccc numbers
drop table if exists #DuplicateCCC
SELECT IdentifierValue RepeatedCCCNumbers, COUNT(*) Repeated into #DuplicateCCC FROM PatientIdentifier I
inner join Patient p ON i.PatientId = p.Id WHERE  IdentifierTypeId = 1  group by IdentifierValue having COUNT(*) > 1
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'CCC', '# of ccc numbers used more than once', sum(Repeated) FROM #DuplicateCCC



-- counts all Persons by gender
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'Person - ' + l.ItemName, COUNT(*) FROM Person p 
left join LookupItemView l ON p.Sex = l.ItemId  WHERE l.MasterName = 'Gender' or l.MasterName = 'Unknown' 
group by l.ItemName

-- counts all patients by gender
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'Patient - ' + l.ItemName, COUNT(*) FROM Person p 
left join LookupItemView l ON p.Sex = l.ItemId  WHERE ( l.MasterName = 'Gender' or l.MasterName = 'Unknown' )
and id in (SELECT persONid FROM patient WHERE DeleteFlag = 0 )
group by l.ItemName, p.Sex 

-- counts all patients by type
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Demographics', 'Patient - ' + l.ItemName, COUNT(*) FROM Patient p 
left join LookupItemView l ON p.PatientType = l.ItemId  WHERE  l.MasterName = 'PatientType' 
group by l.ItemName

-- pateint by service enrolment
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Enrolment',  i.Name, COUNT(*) FROM PatientIdentifier p 
join Identifiers i ON i.Id = p.IdentifierTypeId WHERE i.DeleteFlag = 0 group by IdentifierTypeId, i.Name

-- pateint by care termination
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) SELECT 'Care Termination',  l.ItemDisplayName, COUNT(*) FROM PatientCareending p
join LookupItemView l ON p.ExitReasON = l.ItemId WHERE p.ExitDate is not null group by l.ItemDisplayName



-- Selects Patients who have been screen for TB
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  
Select 'HIV TB Screening','Number of TB Screening',COUNT(*)Total from PatientIcf A
INNER JOIN PatientMasterVisit V on V.ID=A.[PatientMasterVisitId] and A.[PatientId]=V.PatientId

-- Selects Patients who have been screen for IPT
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  
Select 'IPT Screening','Number of Patient Screened for IPT',COUNT(*)Total FROM [PatientIptWorkup] pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId

-- Selects Patients who have been enrolled into IPT Program 
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  
Select 'IPT Enrollment','Number Enrolled into IPT',COUNT(*)Total FROM [PatientIpt] pipt
INNER JOIN PatientMasterVisit pmv ON pmv.Id = pipt.PatientMasterVisitId

---Relationship
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
Select 'Patient Relations','Number of Patient Relations',COUNT(*)Total
From Patient P
Inner Join PersonRelationship PR On P.Id = PR.PatientId
Inner Join Person R On R.Id = PR.PersonId
Where p.DeleteFlag = 0 And PR.DeleteFlag = 0 And R.DeleteFlag = 0 

---- Patient Program Enrollment
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
SELECT 'Patient Program Enrollment', 'Number Enrolled in all Programs ', Count(*)Total
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
INNER JOIN (SELECT distinct pce.PatientId,pce.Code,pce.Enrollment,pce.ExitDate
	FROM (SELECT pce.PatientId,pce.ReenrollmentDate AS Enrollment
			,pce.Code,CASE WHEN pce.ExitDate > pce.ReenrollmentDate THEN pce.ExitDate
				ELSE NULL END AS ExitDate
		FROM (SELECT pe.PatientId,pe.EnrollmentDate,sa.Code,pce.ExitDate,pre.ReenrollmentDate
			FROM PatientEnrollment pe
			INNER JOIN PatientCareending pce ON pce.PatientId = pe.PatientId
			INNER JOIN PatientReenrollment pre ON pre.PatientId = pce.PatientId
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			WHERE pce.DeleteFlag = '1') pce
		UNION
		SELECT pce.PatientId,pce.EnrollmentDate AS Enrollment,pce.Code,pce.ExitDate
		FROM (SELECT pe.PatientId,sa.Code,pe.EnrollmentDate,pce.ExitDate
			FROM PatientEnrollment pe
			INNER JOIN ServiceArea sa ON sa.Id = pe.ServiceAreaId
			LEFT JOIN PatientCareending pce ON pce.PatientId = pe.PatientId) pce 
		UNION 
		SELECT pce.PatientId,pce.ReenrollmentDate AS Enrollment,pce.Code
			,CASE WHEN pce.ExitDate > pce.ReenrollmentDate THEN pce.ExitDate
				ELSE NULL END AS ExitDate
		FROM (SELECT Distinct p.ID PatientId,pe.[StartDate] EnrollmentDate
				,CASE WHEN ModuleName in ('CCC Patient Card MoH 257','HIV Care/ART Card (UG)','HIVCARE-STATICFORM','SMART ART FORM') THEN 'CCC' 
						WHEN ModuleName in ('TB Module','TB') THEN 'TB' 
						WHEN ModuleName in ('PM/SCM With Same point dispense','PM/SCM') THEN 'PM/SCM'
						WHEN ModuleName in ('ANC Maternity and Postnatal') THEN 'PMTCT'  
						ELSE UPPER(ModuleName) END as Code
				,pce.CareEndedDate ExitDate
				,pre.ReEnrollDate ReenrollmentDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p on p.ptn_pk=pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			INNER JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			INNER JOIN [dbo].[Lnk_PatientReEnrollment] pre ON pre.Ptn_Pk = pce.Ptn_Pk and pre.Ptn_Pk = pe.Ptn_Pk
			LEFT JOIN mst_Decode lti ON lti.[ID] = pce.[PatientExitReason] and pce.Ptn_Pk = pe.Ptn_Pk
			WHERE pce.CareEnded=0 and  pe.ptn_pk  not in (SELECT Distinct p.ptn_pk FROM PatientEnrollment pe INNER JOIN Patient p on p.Id=pe.PatientId)
			) pce
		UNION	
		SELECT pce.PatientId,pce.EnrollmentDate AS Enrollment,pce.Code,pce.ExitDate
		FROM (SELECT Distinct p.ID PatientId,pe.[StartDate] EnrollmentDate
				,CASE WHEN ModuleName in ('CCC Patient Card MoH 257','HIV Care/ART Card (UG)','HIVCARE-STATICFORM','SMART ART FORM') THEN 'CCC' 
						WHEN ModuleName in ('TB Module','TB') THEN 'TB' 
						WHEN ModuleName in ('PM/SCM With Same point dispense','PM/SCM') THEN 'PM/SCM'
						WHEN ModuleName in ('ANC Maternity and Postnatal') THEN 'PMTCT'  
						ELSE UPPER(ModuleName) END as Code,pce.CareEndedDate ExitDate
			FROM [dbo].[Lnk_PatientProgramStart] pe
			INNER JOIN Patient p on p.ptn_pk=pe.ptn_pk
			INNER JOIN mst_module sa ON sa.ModuleID = pe.[ModuleId]
			LEFT JOIN dtl_PatientCareEnded pce ON pce.Ptn_Pk = pe.Ptn_Pk
			where   pe.ptn_pk  not in (SELECT Distinct p.ptn_pk FROM PatientEnrollment pe 
			INNER JOIN Patient p on p.Id=pe.PatientId)) pce 
		) pce 
	) pe ON pe.PatientId = PT.Id
	
---- ART Preparation
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'ART Treatment Preparation', 'Number of Patients Assessed for ART', COUNT(*)Total FROM ( 
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date
from PatientSupportSystemCriteria part
inner join Patient p on p.Id=part.PatientId
inner join PatientMasterVisit pmv on pmv.Id=part.PatientMasterVisitId
UNION
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date
from PatientPsychosocialCriteria part
inner join Patient p on p.Id=part.PatientId
inner join PatientMasterVisit pmv on pmv.Id=part.PatientMasterVisitId) A

-- Counts all Family Members HIV History
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'HIV Family History', 'Number of Family Members HIV History', COUNT(*)Total FROM (
Select distinct  p.PersonId as Person_Id, pr.PersonId as Relative_Person_Id, pr.CreateDate as Encounter_Date
From Patient P
Inner join PersonRelationship pr on pr.PatientId=p.Id
left join Person pre on pre.Id=pr.PersonId
LEFT JOIN (SELECT [Ptn_pk] ,a.CreateDate FROM [dbo].[dtl_FamilyInfo] a
  INNER JOIN [mst_HIVCareStatus] c on c.id=a.[HivCareStatus]
  where a.deleteflag=0) relpatient on relpatient.ptn_pk=p.ptn_pk and p.id=pr.patientid and pr.createdate=relpatient.CreateDate
 left join PatientLinkage plink on plink.PersonId=pr.PersonId)A

select * from DWAPI_Migration_Metrics

-- depression screening
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  select 'Depression Screening', 'Patients screened', count (*) from (
select distinct pe.PatientId ,pmv.VisitDate
 from  PatientEncounter pe
inner join
(select * from LookupItemView where MasterName='EncounterType'
and ItemName in('DepressionScreening','Adherence-Barriers') )ab on ab.ItemId=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
and pmv.PatientId=pe.PatientId) a


-- followup education
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  

select 'Followup Education', 'Patients screened', count (*) from (
select distinct p.PersonId as Person_Id,fe.VisitDate as Encounter_Date,NULL as Encounter_ID,
mct.[Name]
as CounsellingType,
mctt.[Name] as CounsellingTopic,
fe.Comments

from dtl_FollowupEducation fe
inner join Patient p on p.ptn_pk=fe.Ptn_pk
inner join mst_CouncellingType mct on mct.ID=fe.CouncellingTypeId
inner join mst_CouncellingTopic mctt on mctt.ID=fe.CouncellingTopicId) a


-- Adherence Barriers
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)  

select 'Adherence Barriers', 'Patients screened', count (*) from (
select pe.PatientId
,pmv.VisitDate
 from PatientEncounter pe
inner join
(select * from LookupItemView where MasterName='EncounterType'
and ItemName='Adherence-Barriers')ab on ab.ItemId=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
and pmv.PatientId=pe.PatientId 
) a

--OVC Enrollments
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
SELECT 'OVC Enrollment', 'Total Number of OVC Enrollments', count(p.PersonId)Total
FROM  Patient p
INNER JOIN PatientEnrollment pe on  p.Id=pe.PatientId
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId 
WHERE sa.Code='OVC' 

--OVC Outcomes
INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
SELECT 'OVC Outcome', 'Total Number of OVC Outcomes', count(p.PersonId)Total
FROM PatientCareending  pce
INNER JOIN Patient p on pce.PatientId=p.Id
INNER JOIN PatientEnrollment pe on  pe.Id=pce.PatientEnrollmentId
INNER JOIN ServiceArea sa on sa.Id=pe.ServiceAreaId 
WHERE sa.Code='OVC' 
