
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