-- 4. HTS Initial Test 
exec pr_OpenDecryptedSession;

select P.Id as Person_Id,  
  hr.VisitDate as Encounter_Date,
  NULL Encounter_ID,
  PopType.PopulationType as Pop_Type,
  kpop.Population_Type as Key_Pop_Type ,
  prio.Population_Type as Priority_Pop_Type,
  Patient_disabled = (SELECT (case when hr.Disability != '' then 'Yes' else 'No' end)),
  hr.Disability,
  hr.TestedBefore as Ever_Tested,
  hr.clientSelfTestesd as Self_Tested,
  hr.StrategyHTS as HTS_Strategy,
  hr.[TestEntryPoint] as HTS_Entry_Point,
  hr.Consent as Consented,
  hr.ClientTestedAs as TestedAs,
  hr.TestType,
  hr.TestKitName1 as Test_1_Kit_Name,
  hr.TestKitLotNumber1 as Test_1_Lot_Number,
  hr.TestKitExpiryDate1 as Test_1_Expiry_Date,
  hr.FinalTestOneResult as Test_1_Final_Result,
  hr.TestKitName_2 as Test_2_Kit_Name,
  hr.TestKitLotNumber_2 as Test_2_Lot_Number,
  hr.TestKitExpiryDate_2 as Test_2_Expiry_Date,
  hr.FinalResultTestTwo as Test_2_Final_Result,
  hr.finalResultHTS as Final_Result,
  hr.FinalResultsGiven as Result_given,
  hr.CoupleDiscordant as Couple_Discordant,
  hr.TBScreeningHTS as TB_SCreening_Results,
  hr.Remarks as Remarks, 
  0 as Voided
 from HTS_LAB_Register hr
inner join Patient pat on pat.Id=hr.PatientID
inner join Person P on P.Id=pat.PersonId
 INNER JOIN PatientIdentifier PI ON PI.PatientId = hr.PatientID
left join(
select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)
and pp.PopulationType ='Key Population'
)t where rownum='1')kpop on kpop.PersonId=P.Id
left join(select pr.PersonId,pr.PopulationType,pr.Population_Type,pr.CreateDate from (select pr.Id,pr.PersonId,pr.PriorityId as PopulationCategory,
(select DisplayName from  LookupMaster where Name = 'PriorityPopulation') as PopulationType ,
(select l.DisplayName from LookupItem l where l.Id=pr.PriorityId) as Population_Type,pr.CreateDate,
ROW_NUMBER() OVER(partition
by pr.PersonId order by pr.CreateDate desc) rownum
from PersonPriority pr
)pr where rownum='1'
)prio on prio.PersonId=P.Id
left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)

)t where rownum='1')PopType on PopType.PersonId=P.Id
where (hr.TestType= 'Initial Test' or hr.TestType='Initial')


-- 5. HTS Retest Test
exec pr_OpenDecryptedSession;

select P.Id as Person_Id, 
  hr.VisitDate as Encounter_Date,
  NULL Encounter_ID,
  PopType.PopulationType as Pop_Type,
  kpop.Population_Type as Key_Pop_Type ,
  prio.Population_Type as Priority_Pop_Type,
  Patient_disabled = (SELECT (case when hr.Disability != '' then 'Yes' else 'No' end)),
  hr.Disability,
  hr.TestedBefore as Ever_Tested,
  hr.clientSelfTestesd as Self_Tested,
  hr.StrategyHTS as HTS_Strategy,
  hr.[TestEntryPoint] as HTS_Entry_Point,
  hr.Consent as Consented,
  hr.ClientTestedAs as TestedAs,
  hr.TestType,
  hr.TestKitName1 as Test_1_Kit_Name,
  hr.TestKitLotNumber1 as Test_1_Lot_Number,
  hr.TestKitExpiryDate1 as Test_1_Expiry_Date,
  hr.FinalTestOneResult as Test_1_Final_Result,
  hr.TestKitName_2 as Test_2_Kit_Name,
  hr.TestKitLotNumber_2 as Test_2_Lot_Number,
  hr.TestKitExpiryDate_2 as Test_2_Expiry_Date,
  hr.FinalResultTestTwo as Test_2_Final_Result,
  hr.finalResultHTS as Final_Result,
  hr.FinalResultsGiven as Result_given,
  hr.CoupleDiscordant as Couple_Discordant,
  hr.TBScreeningHTS as TB_SCreening_Results,
  hr.Remarks as Remarks, 
  0 as Voided
 from HTS_LAB_Register hr
inner join Patient pat on pat.Id=hr.PatientID
inner join Person P on P.Id=pat.PersonId
 INNER JOIN PatientIdentifier PI ON PI.PatientId = hr.PatientID
left join(
select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)
and pp.PopulationType ='Key Population'
)t where rownum='1')kpop on kpop.PersonId=P.Id
left join(select pr.PersonId,pr.PopulationType,pr.Population_Type,pr.CreateDate from (select pr.Id,pr.PersonId,pr.PriorityId as PopulationCategory,
(select DisplayName from  LookupMaster where Name = 'PriorityPopulation') as PopulationType ,
(select l.DisplayName from LookupItem l where l.Id=pr.PriorityId) as Population_Type,pr.CreateDate,
ROW_NUMBER() OVER(partition
by pr.PersonId order by pr.CreateDate desc) rownum
from PersonPriority pr
)pr where rownum='1'
)prio on prio.PersonId=P.Id
left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null)

)t where rownum='1')PopType on PopType.PersonId=P.Id
where hr.TestType='Repeat Test'
