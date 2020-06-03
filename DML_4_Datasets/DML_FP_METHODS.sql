
SELECT p.PersonId as Person_Id,pmv.VisitDate as  Encounter_Date,NULL as Encounter_ID,(select top 1.[DisplayName]  from LookupItem lt where lt.Id=pfm.FPMethodId) as Family_Planning_Method

from PatientFamilyPlanningMethod pfm 
inner join Patient p on p.Id=pfm.PatientId
left join PatientFamilyPlanning pfp on pfp.Id=pfm.PatientFPId
inner join PatientMasterVisit pmv on pmv.Id=pfp.PatientMasterVisitId
left join Person pe on pe.Id=p.PersonId
INNER JOIN LookupItem lki 
ON lki.Id = pfm.FPMethodId
union
select pa.PersonId as Person_Id,V.VisitDate as Encounter_Date,NULL as Encounter_ID,
(select top 1.[Name]  from mst_BlueDecode lt where lt.Id=pfp.FamilyPlanningMethod)
as Family_Planning_Method  from dtl_PatientFamilyPlanning pfp
left join mst_Patient p on p.Ptn_Pk=pfp.Ptn_Pk
left join ord_Visit v on v.Visit_Id=pfp.Visit_Id
left join Patient pa on pa.Ptn_Pk=pfp.Ptn_Pk

