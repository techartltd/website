
select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID
,(select top 1.[Name] from LookupItem li where li.Id=pce.ExitReason)as 
Discontinuation_Reason,pce.ExitDate as ExitDate,
pce.DateOfDeath,
pce.TransferOutfacility as Transfer_Facility,
NULL as Transfer_Date,
pce.DeleteFlag as Voided
  from PatientCareending  pce
  inner join Patient p on pce.PatientId=p.Id
  inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId
inner join PatientEnrollment pe on  pe.Id=pce.PatientEnrollmentId
inner join ServiceArea sa on sa.Id=pe.ServiceAreaId 
where sa.Code='OTZ' 

