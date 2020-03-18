select 
T.PersonID Person_Id,
T.DateTracingDone Encounter_Date,
NULL Encounter_ID,
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE ItemId = T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId = T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT ItemName FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
OtherReasonSpecify = T.OtherReasonSpecify,
Remarks = T.Remarks,
NULL Voided
from Tracing T
WHERE T.TracingType = (SELECT ItemId FROM LookupItemView WHERE MasterName='TracingType' AND ItemName = 'Enrolment');