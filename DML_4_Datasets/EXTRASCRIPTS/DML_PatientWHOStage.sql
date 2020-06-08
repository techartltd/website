select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,
NULL as EncounterID,NULL as WABStage,(select 
li.[Name] from LookupItem li where li.Id=pw.WHOStage)WHOStage,pmv.CreateDate,
CASE when pmv.CreatedBy=0 then pe.createdby else pmv.CreatedBy end as CreatedBy,pmv.DeleteFlag as Voided
 from PatientWHOStage pw
inner join Patient p on p.Id=pw.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pw.PatientMasterVisitId
left join PatientEncounter pe on pe.PatientMasterVisitId=pmv.Id
union
select P.PersonId as Person_Id,v.VisitDate as Encounter_Date,NULL as EncounterID
,(select dc.[Name] from mst_Decode dc where dc.Id=pst.WABStage)WABStage,
(select  dc.[Name] from mst_Decode dc where dc.Id=pst.WHOStage )WHOStage,pst.CreateDate,pst.UserID as CreatedBy,
v.DeleteFlag as Voided
 from dtl_PatientStage pst
 inner join ord_Visit v on v.Visit_Id=pst.Visit_Pk
 left join Patient p on p.ptn_pk=pst.Ptn_pk

