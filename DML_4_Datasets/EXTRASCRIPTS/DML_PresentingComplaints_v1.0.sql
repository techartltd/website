
select pe.Id as Person_Id,pmv.VisitDate as Encounter_Date,NULL as Encounter_ID,(select top 1 li.[Name]  from LookupItem li where li.Id =psc.PresentingComplaintsId) as Presenting_complaints,ch.PresentingComplaint as Complaint,NULL as Duration,psc.onsetDate as Onset_Date,psh.CreatedBy,psh.CreatedDate
 from(select pcs.PatientId,pcs.PatientMasterVisitId,pcs.CreatedBy,pcs.CreatedDate from PresentingComplaints pcs
union
select  ch.PatientId,ch.PatientMasterVisitId,ch.CreateBy as CreatedBy,ch.CreateDate from ComplaintsHistory  ch 
where ch.AnyComplaint =1
)psh 
left join Patient p on p.Id=psh.PatientId
left join Person pe on pe.Id=p.PersonId
left join PatientMasterVisit pmv on pmv.Id=psh.PatientMasterVisitId
left join PresentingComplaints psc on psc.PatientId=psh.PatientId
and psc.PatientMasterVisitId=psh.PatientMasterVisitId
left join ComplaintsHistory ch on ch.PatientId=psh.PatientId
and ch.PatientMasterVisitId=psh.PatientMasterVisitId
