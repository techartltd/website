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


INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'ART Fast Track','Number of FastTracks', COUNT(*) 
FROM (select * from PatientArtDistribution paa) B

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'ART Fast Track',Refill_Model, COUNT(*) 
FROM (select (select top 1 DisplayName from LookupItem li where li.Id=paa.ArtRefillModel) as Refill_Model
from PatientArtDistribution paa) B
group by Refill_Model

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
Select 'Labs','Number of Lab Tests (ALL)',COUNT(*)Total 
from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
inner join ord_Visit v on v.Visit_Id=plo.VisitId
where  (v.DeleteFlag=0 or v.DeleteFlag is null) OR plo.DeleteFlag=0

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
SELECT 'Labs', Concat(OrderStatus,'  |  ',AvailResults)Results,Count(*) TotalLabTests FROM (
SELECT 
 CASE WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NOT NULL 
		OR (COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NULL AND Undetectable=1 AND HasResult=1)
		  THEN 'With Results'
	 ELSE 'No Results'END AS AvailResults,
plo.OrderStatus
from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
inner join ord_Visit v on v.Visit_Id=plo.VisitId
where  (v.DeleteFlag=0 or v.DeleteFlag is null) OR plo.DeleteFlag=0) A
Group by OrderStatus,AvailResults

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 

SELECT 'Labs',concat(LabTestName,'  |  ',Min(cast(OrderDate as Date)),'  |  ', Max(cast(OrderDate as Date)))LabsWithDates, Count(*) As Total from (
SELECT LabTestName, OrderDate FROM ord_LabOrder	 plo 
INNER JOIN dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
INNER JOIN  dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
INNER JOIN ord_Visit v on v.Visit_Id=plo.VisitId
LEFT JOIN mst_User u on u.UserID=plo.OrderedBy
LEFT JOIN (Select	P.Id ParameterId,P.ParameterName,T.Name AS	LabTestName 
	From mst_LabTestMaster T
	INNER JOIN Mst_LabTestParameter P On T.Id = P.LabTestId
	LEFT OUTER JOIN mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID
	)vlw on vlw.ParameterId=r.ParameterId
	  where   plo.DeleteFlag=0 OR (v.DeleteFlag=0 or v.DeleteFlag is null))B
Group by LabTestName
order by LabTestName

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'Defaulter Tracing', 'Number of LTFU', Count(*)Total FROM (
select (select top 1. [Name] from Lookupitem where id= pce.ExitReason) as ExitReason,
pce.DeleteFlag
from PatientCareending pce
inner join Patient p on p.Id=pce.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId and pce.patientId=pmv.PatientId
)pce
where pce.ExitReason='LostToFollowUp' and pce.DeleteFlag=0


INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'Alcohol Screening','Number of Patients', COUNT(*) 
from  (
select DISTINCT pt.PersonId,pe.VisitDate,pdr.Answer as DrinkAlcoholMorethanSips,
pc2ma.Answer as SmokeAnyMarijuana,
pcq3.Answer as UseAnythingElseGetHigh,
crs1.Answer as CARDrivenandHigh,
crs2.Answer as UseDrugorAlcoholRelax,
crs3.Answer as UseDrugByYourself,
crs4.Answer as ForgetWhileUsingAlcohol,
crs5.Answer as FamilyTellYouCutDownDrugs,
crs6.Answer as TroubleWhileUsingDrugs,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided

from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType')liv on liv.ItemId=pe.EncounterTypeId
			where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id
inner join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pcss on pcss.PatientId=pe.PatientId and pcss.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdr on pdr.PatientId=pe.PatientId and pdr.PatientMasterVisitId=pe.PatientMasterVisitId

left join( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)pc2ma on pc2ma.PatientId=pe.PatientId
  and pc2ma.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScreeningQuestions'  and ItemName='CRAFFTScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  )pcq3 on pcq3.PatientId=pe.PatientId and pcq3.PatientMasterVisitId=pe.PatientMasterVisitId

left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs1 on crs1.PatientId=pe.PatientId and crs1.PatientMasterVisitId=pe.PatientMasterVisitId



  left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs2 on crs2.PatientId=pe.PatientId and crs2.PatientMasterVisitId=pe.PatientMasterVisitId


   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs3 on crs3.PatientId=pe.PatientId and crs3.PatientMasterVisitId=pe.PatientMasterVisitId



   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs4 on crs4.PatientId=pe.PatientId and crs4.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion5'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs5 on crs5.PatientId=pe.PatientId and crs5.PatientMasterVisitId=pe.PatientMasterVisitId

   left join ( select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='CRAFFTScoreQuestions'  and ItemName='CRAFFTScoreQuestion6'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId
  ) crs6 on crs6.PatientId=pe.PatientId and crs6.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholRiskLevel')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)arll on arll.PatientId=pe.PatientId and arll.PatientMasterVisitId=pe.PatientMasterVisitId


  left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholScore')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)als on als.PatientId=pe.PatientId and als.PatientMasterVisitId=pe.PatientMasterVisitId



left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocialHistory' and lt.ItemName='SocialNotes')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitId) BB


INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'Alcohol Screening','Number of Patients', COUNT(*) 
from  (
select DISTINCT pt.PersonId,pe.VisitDate as Encounter_Date,NULL as Encounter_ID 
,pdra.Answer as DrinkAlcohol
,pss.Answer as Smoke
,pudd.Answer as UseDrugs,
trss.Answer as [TriedStopSmoking],
asq1.Answer as FeltCutDownDrinkingorDrugUse,
asq2.Answer as AnnoyedByCriticizingDrinkingorDrugUse,
asq3.Answer as FeltGuiltyDrinkingorDrugUse,
asq4.Answer as UseToSteadyNervesGetRidHangover,
arll.Answer as AlcoholRiskLevel,
als.Answer as AlcoholScore,
sh.Answer as Notes,
pe.DeleteFlag as Voided
from Patient pt
inner join(
select pe.PatientId,pe.EncounterTypeId,pe.PatientMasterVisitId,pmv.VisitDate,pmv.DeleteFlag  from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join (select * from LookupItemView where MasterName='EncounterType' OR MasterName='SocialHistoryQuestions' )
liv on liv.ItemId=pe.EncounterTypeId
where liv.ItemName='AlcoholandDrugAbuseScreening'
)pe on pe.PatientId=pt.Id

inner join(select psc.PatientId,psc.PatientMasterVisitId from PatientScreening psc where
			ScreeningCategoryID in (select Distinct itemID from LookupItemView where MasterName='SocialHistoryQuestions')
 )psq on psq.PatientId=pe.PatientId and psq.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='DrinkAlcohol'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pdra on pdra.PatientId=pe.PatientId and pdra.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='Smoke'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pss on pss.PatientId=pe.PatientId and pss.PatientMasterVisitId=pe.PatientMasterVisitId
  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SocialHistoryQuestions'  and ItemName='UseDrugs'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  pudd on pudd.PatientId=pe.PatientId and pudd.PatientMasterVisitId=pe.PatientMasterVisitId

   left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='SmokingScreeningQuestions'  and ItemName='SmokingScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  trss on trss.PatientId=pe.PatientId and trss.PatientMasterVisitId=pe.PatientMasterVisitId


  left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion1'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq1 on asq1.PatientId=pe.PatientId and asq1.PatientMasterVisitId=pe.PatientMasterVisitId

    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion2'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq2 on asq2.PatientId=pe.PatientId and asq2.PatientMasterVisitId=pe.PatientMasterVisitId

  
    left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion3'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq3 on asq3.PatientId=pe.PatientId and asq3.PatientMasterVisitId=pe.PatientMasterVisitId


      left join(select psc.PatientId,psc.PatientMasterVisitId,psc.ScreeningTypeId,psc.DeleteFlag,
  lti.[Name] as Answer from PatientScreening psc
   inner join(
  select * from LookupItemView where MasterName='AlcoholScreeningQuestions'  and ItemName='AlcoholScreeningQuestion4'
  )ltv on ltv.ItemId=psc.ScreeningCategoryId
  left join LookupItem lti on lti.Id=psc.ScreeningValueId)
  asq4 on asq4.PatientId=pe.PatientId and asq4.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholRiskLevel')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)arll on arll.PatientId=pe.PatientId and arll.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='AlcoholScreeningNotes' and lt.ItemName='AlcoholScore')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)als on als.PatientId=pe.PatientId and als.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select  *  from (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,pc.DeleteFlag ,lt.ItemName ,pc.ClinicalNotes as Answer,
  ROW_NUMBER() OVER(partition by pc.PatientId,pc.PatientMasterVisitId order by pc.Id desc)rownum
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocialHistory' and lt.ItemName='SocialNotes')lt
on lt.ItemId=pc.NotesCategoryId
where (pc.DeleteFlag is null or pc.DeleteFlag=0)
)pc where pc.rownum='1'
)sh on sh.PatientId=pe.PatientId and sh.PatientMasterVisitId=pe.PatientMasterVisitID
)BB



--PatientEnrolled in each year based on servicearea



INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
select  'ServiceArea: ' + ptt.Code  ,
'Number of Patients Enrolled Based on the ServiceArea:' + ptt.Code + ' and Year:'  + CAST(Year(ptt.Enrollment) as varchar(max))  ,Count (ptt.PatientId) as  Total  from (SELECT distinct pce.PatientId,pce.Code,pce.Enrollment,pce.ExitDate
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
)ptt

 group by Year(ptt.Enrollment),ptt.Code
order by ptt.Code  desc ,Year(ptt.Enrollment)  desc
