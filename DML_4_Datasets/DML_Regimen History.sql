
-- 15. Regimen History
exec pr_OpenDecryptedSession;

 select p.Id  as Person_Id,part.DispensedByDate as Encounter_Date
, 'NULL' as Encounter_ID,
 pstart.TreatmentProgram as Program,
 NULL as Regimen,
 pstart.Regimen as Regimen_Name,
 pstart.RegimenLine as Regimen_Line,
 pstart.DispensedByDate as Date_Started, 
  pr.VisitDate as Date_Stopped
 ,CASE WHEN pr.VisitDate is not null then pstart.Regimen else NULL end  as Regimen_Discontinued
 ,pr.VisitDate as [Date_Discontinued],
 pr.TreatmentReason  as Reason_Discontinued
,pr.Regimen as RegimenSwitchTo
 ,part.Regimen as CurrentRegimen
 ,0 as Voided
 ,NULL as Date_Voided
  from (select distinct PatientId from PatientTreatmentTrackerView pt)ptr 
  inner join Patient pt on pt.Id=ptr.PatientId
left join Person p on p.Id =pt.PersonId
left join (
select  pts.PatientId,lt.DisplayName as [Regimen],pts.RegimenLine,pts.TreatmentStatus,pts.DispensedByDate,pts.VisitDate,pts.TreatmentProgram from (select tv.PatientId,tv.RegimenId,tv.Regimen,tv.RegimenLine,tv.TreatmentStatusId,tv.TreatmentStatus,tv.DispensedByDate,tv.VisitDate,dc.[Name] as TreatmentProgram,
ROW_NUMBER() OVER(partition by tv.PatientId order by tv.PatientMasterVisitId desc)rownum
 from PatientTreatmentTrackerView tv
 left join ord_PatientPharmacyOrder pho on pho.PatientMasterVisitId =tv.PatientMasterVisitId
 left join mst_Decode dc on dc.ID =pho.ProgID
 )pts 
 inner join LookupItem lt on lt.Id=pts.RegimenId
 where pts.rownum =1
 )part on part.PatientId=pt.Id
left join(select  pts.PatientId,lt.DisplayName as [Regimen],pts.RegimenLine,pts.TreatmentStatus,pts.DispensedByDate,pts.VisitDate,pts.TreatmentProgram from (select tv.PatientId,tv.RegimenId,tv.Regimen,tv.RegimenLine,tv.TreatmentStatusId,tv.TreatmentStatus,tv.DispensedByDate,tv.VisitDate,
ROW_NUMBER() OVER(partition by tv.PatientId order by tv.PatientMasterVisitId asc)rownum, dc.[Name] as TreatmentProgram
 from PatientTreatmentTrackerView tv
  left join ord_PatientPharmacyOrder pho on pho.PatientMasterVisitId =tv.PatientMasterVisitId
   left join mst_Decode dc on dc.ID =pho.ProgID
 )pts 
 inner join LookupItem lt on lt.Id=pts.RegimenId
 where pts.rownum =1
)pstart  on pstart.PatientId=pt.Id
left join(
select pr.PatientId,pr.RegimenLine,pr.Regimen,pr.TreatmentStatus,pr.VisitDate,pr.DispensedByDate,pr.TreatmentReason from (select p.PatientId,p.RegimenId,p.RegimenLine,ltr.DisplayName as [Regimen],p.TreatmentReason,p.TreatmentStatus,p.TreatmentStatusId,p.VisitDate,p.DispensedByDate,ROW_NUMBER() 
 OVER(Partition by p.PatientId order by p.PatientMasterVisitId desc)rownum  from PatientTreatmentTrackerView   p
inner join LookupItem lt on lt.Id=p.TreatmentStatusId
inner join LookupItem ltr on ltr.Id=p.RegimenId
left join LookupItem lts on lts.Id =p.TreatmentStatusReasonId
where lt.[Name]='DrugSwitches')pr  where pr.rownum='1'
)pr on pr.PatientId=pt.Id
