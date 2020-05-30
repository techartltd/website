select pd.Id,p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID,
CASE when pd.LookupTableFlag=1 and ISNUMERIC(pd.Diagnosis)=1 then (
select top 1 DisplayName from LookupItem where Id = pd.Diagnosis)
when pd.LookupTableFlag=0 then (Select top 1 mic.[Name] from mst_ICDCodes mic where mic.Id=pd.Diagnosis)else pd.Diagnosis  end as  Diagnosis,pd.ManagementPlan,pd.DeleteFlag
 from PatientDiagnosis pd
 inner join PatientMasterVisit pmv on pmv.Id=pd.PatientMasterVisitId
 inner join Patient p on p.Id=pd.PatientId


 

