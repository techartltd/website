-- 1. Demographics
declare @PersonsCount integer, @PersonsMaleCount int, @PersonsFemaleCount int, 
@PatientCount integer,  
@PersonsNotPatients integer, 
@PatientInCCC int, 
@TreatmentSupporters int, 
@TreatmentSupporterWhoIsPatient int, 
@Contacts int, 
@DuplicateCCCNumber int,
@PatientCountDeleted int, @PersonsCountDeleted int

-- counts all persons found 
select @PersonsCount = count(*) from Person 

-- counts deleted persons found 
select @PersonsCountDeleted = count(*) from Person where DeleteFlag = 1

 -- counts all patients found
select @PatientCount = count(*) from Patient

-- counts ONLY CCC patient (that is anyone who has ccc number in patient identifiers)
select @PatientInCCC = count(*) from Patient where id in (select distinct PatientId from PatientIdentifier where IdentifierTypeId = 1 and DeleteFlag = 0) 

--patient who are marked as deleted
select @PatientCountDeleted = count(*) from Patient where DeleteFlag = 1

-- selects persons who are not patients
select @PersonsNotPatients = count(*) from Person where Id not in (select PersonId from Patient where DeleteFlag = 0)

--selects all treatment supporters
select @TreatmentSupporters = count(*) from PatientTreatmentSupporter pts

--selects ONLY treatment supporters who are patient also
select @TreatmentSupporterWhoIsPatient = count(*) from PatientTreatmentSupporter pts where pts.SupporterId in (select PersonId from Patient)

-- all patient contacts
select @Contacts = count(*) from PersonRelationship

-- repeated CCC number
drop table if exists #DuplicateCCC
select IdentifierValue RepeatedCCCNumbers, count(*) Repeated into #DuplicateCCC from PatientIdentifier I
inner join Patient p on i.PatientId = p.Id where  IdentifierTypeId = 1  group by IdentifierValue having count(*) > 1
select @DuplicateCCCNumber = sum(Repeated) from #DuplicateCCC

select @PersonsCount Persons , @PersonsCountDeleted DeletedPersons,
@PatientCount Patients, 
@PatientCountDeleted DeletedPatients, 
@PatientCount - @PatientCountDeleted  NetPatient, 
(@PersonsCount - @PatientCount) PersonsPatientDiff,  
@PersonsNotPatients PersonsNotPatient, 
@TreatmentSupporters TreatmentSupporters, 
@TreatmentSupporterWhoIsPatient TreatmentSupporterWhoIsPatient,
(@PersonsNotPatients - (@PersonsCount - @PatientCount)) Disparity,
@Contacts NextOfKin, 
@PatientInCCC PatientInCCC,
@DuplicateCCCNumber RepeatedCCCNumbers

-- counts all persons by gender
select  ItemName Gender, count(*) PersonsByGender from Person p 
left join LookupItemView l on p.Sex = l.ItemId  where l.MasterName = 'Gender' or l.MasterName = 'Unknown' 
group by l.ItemName, p.Sex 
-- counts all patients by gender
select  ItemName Gender, count(*) PatientByGender from Person p 
left join LookupItemView l on p.Sex = l.ItemId  where ( l.MasterName = 'Gender' or l.MasterName = 'Unknown' )
and id in (select personid from patient where DeleteFlag = 0 )
group by l.ItemName, p.Sex 
-- counts all patients by type
select  ItemName PateintType, count(*) PatientByType from Patient p 
left join LookupItemView l on p.PatientType = l.ItemId  where  l.MasterName = 'PatientType' 
group by l.ItemName

-- pateint by service enrolment
select p.IdentifierTypeId, i.Name [Service Name], count(IdentifierTypeId) PatientsPerService from PatientIdentifier p join Identifiers i on i.Id = p.IdentifierTypeId where i.DeleteFlag = 0 group by IdentifierTypeId, i.Name

-- pateint by care termination
select l.ItemDisplayName [Care End Reason], count(*) NoOfPatients from PatientCareending p join LookupItemView l on p.ExitReason = l.ItemId where p.ExitDate is not null group by l.ItemDisplayName

-- repeated CCC number
select * from #DuplicateCCC

select l.ItemDisplayName [PatientRelationship], count(*) NoOfContacts from PersonRelationship p join LookupItemView l on p.RelationshipTypeId = l.ItemId where MasterName like '%Relationship%' group by l.ItemDisplayName


--select IdentifierValue, count(*) from PatientIdentifier I
--inner join Patient p on i.PatientId = p.Id where IdentifierTypeId = 1  group by IdentifierValue having count(*) > 1

SELECT *  FROM PatientEnrollment PTE INNER JOIN PatientIdentifier PIE ON PIE.PatientEnrollmentId = PTE.Id 
INNER JOIN PATIENT PT ON PTE.PatientId = PT.Id WHERE PTE.ServiceAreaId = 1 AND PIE.DeleteFlag = 0 AND PTE.DeleteFlag = 0 