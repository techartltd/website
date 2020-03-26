select p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID
,pce.ExitDate as ExitDate,(select top 1.[Name] from LookupItem li where li.Id=pce.ExitReason)as 
Exit_Reason,
pce.TransferOutfacility as Transfer_Facility,
CASE WHEN pce.ExitReason in (
select itemId from LookupItemView where MasterName like 'OVC_CareEndedOptions'
and  ItemName in ('TransferOutNonPepfarFacility','TransferOutPepfarFacility')) then 
pce.ExitDate else NULL end  as  Transfer_Date,
pce.DeleteFlag as Voided,
pce.CreatedBy created_by,
cast(pce.CreateDate as date) created_at
  from PatientCareending  pce
  inner join Patient p on pce.PatientId=p.Id
  inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId
inner join PatientEnrollment pe on  pe.Id=pce.PatientEnrollmentId
inner join ServiceArea sa on sa.Id=pe.ServiceAreaId 
where sa.Code='OVC' 
