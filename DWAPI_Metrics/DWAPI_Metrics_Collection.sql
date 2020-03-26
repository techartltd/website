--stores DWAPI metrics to be shipping by DWAPI before migration
USE [IQCare]
GO

/****** Object:  Table [dbo].[DWAPI_Migration_Metrics]    Script Date: 3/20/2020 4:43:06 AM ******/
DROP TABLE [dbo].[DWAPI_Migration_Metrics]
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
	[MetricValue] [nvarchar](50) NOT NULL
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

select * from DWAPI_Migration_Metrics