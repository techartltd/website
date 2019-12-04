-- 1. DEMOGRAPHICS
-- all persons
SET @PersonsCount = (SELECT count(*) from st_demographics);
-- deleted  persons
SET @PatientsCountDeleted = (SELECT count(*) from st_demographics where voided = 1);
-- all PATIENTS
SET @PatientsCount = (SELECT count(*) from st_demographics WHERE Patient_Id IS NOT NULL);
select @PatientInCCC = count(*)  from st_demographics where UPN is not null or UPN <> '' or length(trim(UPN)) > 0;
SET @PersonsMarkedAsDead = (SELECT count(*)  from st_demographics where Dead is not null);
SET @PatientsMarkedAsDead = (SELECT count(*)  from st_demographics where Dead is not null and Patient_Id is NOT NULL);

-- duplicate CCC numbers
DROP temporary TABLE IF EXISTS DuplicateCCC;
CREATE TEMPORARY TABLE DuplicateCCC select UPN, count(*) Repeated from st_demographics where  UPN is not null or UPN <> '' or length(trim(UPN)) <> 0 group by UPN having count(*) > 1 order by UPN ;
select sum(Repeated) into @DuplicateCCCNumber  from DuplicateCCC;

-- show stats
SELECT 
    @PersonsCount,
    @PatientsCount,
    @PatientsCountDeleted,
    @PatientInCCC,
    @DuplicateCCCNumber,
    @PersonsMarkedAsDead,
    @PatientsMarkedAsDead;

-- persons by gender
SELECT Sex, COUNT(*) PersonsByGender from st_demographics GROUP BY Sex;
-- patients by gender
SELECT Sex, COUNT(*) PatientByGender from st_demographics WHERE Patient_Id is not null GROUP BY Sex;

-- all duplicated CCCs
-- select *  from DuplicateCCC;