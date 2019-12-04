-- 1. Demographics
declare @PersonsCount integer, @PersonsMaleCount int, @PersonsFemaleCount int, 
@PatientCount integer,  
@PersonsNotPatients integer, 
@PatientInCCC int, 
@TreatmentSupporters int, 
@TreatmentSupporterWhoIsPatient int, 
@CONtacts int, 
@DuplicateCCCNumber int,
@PatientCountDeleted int, @PersonsCountDeleted int, @IQCareVersion varchar(30)

-- check IQCare version
SELECT @IQCareVersion = VersionName FROM AppAdmin
Select @IQCareVersion [IQCare Version];

-- counts all Persons found 
SELECT @PersonsCount = COUNT(*) FROM Person

-- counts deleted Persons found 
SELECT @PersonsCountDeleted = COUNT(*) FROM PersON WHERE DeleteFlag = 1

 -- counts all patients found
SELECT @PatientCount = COUNT(*) FROM Patient

-- counts ONLY CCC patient (that is anyONe who has ccc number in patient identifiers)
SELECT @PatientInCCC = COUNT(*) FROM Patient WHERE id in (SELECT distinct PatientId FROM PatientIdentifier WHERE IdentifierTypeId = 1 and DeleteFlag = 0) 

--patient who are marked as deleted
SELECT @PatientCountDeleted = COUNT(*) FROM Patient WHERE DeleteFlag = 1

-- SELECTs Persons who are not patients
SELECT @PersonsNotPatients = COUNT(*) FROM PersON WHERE Id not in (SELECT PersONId FROM Patient WHERE DeleteFlag = 0)

--SELECTs all treatment supporters
SELECT @TreatmentSupporters = COUNT(*) FROM PatientTreatmentSupporter pts

--SELECTs ONLY treatment supporters who are patient also
SELECT @TreatmentSupporterWhoIsPatient = COUNT(*) FROM PatientTreatmentSupporter pts WHERE pts.SupporterId in (SELECT PersONId FROM Patient)

-- all patient cONtacts
SELECT @CONtacts = COUNT(*) FROM PersONRelatiONship

-- repeated CCC number
drop table if exists #DuplicateCCC
SELECT IdentifierValue RepeatedCCCNumbers, COUNT(*) Repeated into #DuplicateCCC FROM PatientIdentifier I
inner join Patient p ON i.PatientId = p.Id WHERE  IdentifierTypeId = 1  group by IdentifierValue having COUNT(*) > 1
SELECT @DuplicateCCCNumber = sum(Repeated) FROM #DuplicateCCC

SELECT @PersonsCount Persons , @PersonsCountDeleted DeletedPersons,
@PatientCount Patients, 
@PatientCountDeleted DeletedPatients, 
@PatientCount - @PatientCountDeleted  NetPatient, 
(@PersonsCount - @PatientCount) PersonsPatientDiff,  
@PersonsNotPatients PersonsNotPatient, 
@TreatmentSupporters TreatmentSupporters, 
@TreatmentSupporterWhoIsPatient TreatmentSupporterWhoIsPatient,
(@PersonsNotPatients - (@PersonsCount - @PatientCount)) Disparity,
@CONtacts NextOfKin, 
@PatientInCCC PatientInCCC,
@DuplicateCCCNumber RepeatedCCCNumbers

-- counts all Persons by gender
SELECT  ItemName Gender, COUNT(*) PersonsByGender FROM Person p 
left join LookupItemView l ON p.Sex = l.ItemId  WHERE l.MasterName = 'Gender' or l.MasterName = 'Unknown' 
group by l.ItemName

-- counts all patients by gender
SELECT  ItemName Gender, COUNT(*) PatientByGender FROM Person p 
left join LookupItemView l ON p.Sex = l.ItemId  WHERE ( l.MasterName = 'Gender' or l.MasterName = 'Unknown' )
and id in (SELECT persONid FROM patient WHERE DeleteFlag = 0 )
group by l.ItemName, p.Sex 

--select Sex, count(Sex) from Person group by Sex
--select COUNT(Sex) from Person
--select COUNT(*) from Person

-- counts all patients by type
SELECT  ItemName PateintType, COUNT(*) PatientByType FROM Patient p 
left join LookupItemView l ON p.PatientType = l.ItemId  WHERE  l.MasterName = 'PatientType' 
group by l.ItemName

-- pateint by service enrolment
SELECT p.IdentifierTypeId, i.Name [Service Name], COUNT(IdentifierTypeId) PatientsPerService FROM PatientIdentifier p join Identifiers i ON i.Id = p.IdentifierTypeId WHERE i.DeleteFlag = 0 group by IdentifierTypeId, i.Name

-- pateint by care termination
SELECT l.ItemDisplayName [Care End Reason], COUNT(*) NoOfPatients FROM PatientCareending p join LookupItemView l ON p.ExitReasON = l.ItemId WHERE p.ExitDate is not null group by l.ItemDisplayName

-- repeated CCC number
SELECT * FROM #DuplicateCCC

SELECT l.ItemDisplayName [PatientRelatiONship], COUNT(*) NoOfCONtacts FROM PersONRelatiONship p join LookupItemView l ON p.RelatiONshipTypeId = l.ItemId WHERE MasterName like '%RelatiONship%' group by l.ItemDisplayName

