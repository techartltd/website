
--6. HTS Client Tracing
SELECT 
PersonID,
Encounter_Date = T.DateTracingDone,
Encounter_ID = T.Id,
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT ItemName FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
T.OtherReasonSpecify,
T.Remarks,
T.DeleteFlag Voided

FROM Tracing T

--7 HTS Client Referral
select r.PersonId,r.ReferralDate  as Encounter_Date,NULL Encounter_ID, CASE WHEN r.OtherFacility is not null then r.OtherFacility else fc.FacilityName  end as Facility_Referred,
r.ExpectedDate as Date_To_Be_Enrolled
 from Referral r
 left join mst_Facility fc on fc.PosID=r.ToFacility

 --8-HTS Client Linkage
 select pl.PersonId,pl.LinkageDate as Encounter_Date
 ,NULL as Encounter_ID,pl.Facility as Facility_Linked,pl.CCCNumber as CCC_Number,
 pl.HealthWorker as Health_Worker_Handed_To,pl.Cadre,CASE WHEN pl.Enrolled ='1' then pl.LinkageDate end as Date_Enrolled,pl.ArtStartDate,pl.Comments as Remarks,pl.DeleteFlag as Voided
   from PatientLinkage pl