select 
R.PersonID Person_Id,
format(cast(R.ReferralDate AS DATE), 'yyyy-MM-dd') Encounter_Date,
NULL Encounter_ID,
Facility_Referred = CASE WHEN (SELECT Name FROM FacilityList WHERE MFLCode = R.ToFacility) IS NULL THEN 'OTHER' ELSE (SELECT Name FROM FacilityList WHERE MFLCode = R.ToFacility) END,
R.ExpectedDate Date_To_Be_Enrolled,
NULL Remarks,
R.DeleteFlag Voided

from Referral R
LEFT join HtsEncounter HE ON HE.PersonId = R.PersonId;