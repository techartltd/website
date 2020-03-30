-- Migration Scripts : Transformation
-- Description Populates transformed data for loading to Spreadsheet module
-- Migration Scripts : Transformation to be run Third/Last for loading MySQL Data for migration
-- Run Third

DROP DATABASE IF EXISTS migration_tr;
CREATE DATABASE migration_tr;
-- DDL
-- Transformed Database Scripts
-- -------------------------- creating transformed patient demographics --------------------------------------
-- 1. Create demographics transformed table
DROP TABLE IF EXISTS migration_tr.tr_demographics;
CREATE TABLE migration_tr.tr_demographics as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Exact_DOB,
    Sex,
    UPN,
    Encounter_Date,
    Encounter_ID,
    National_id_no,
    Patient_clinic_number,
    Phone_number,
    Alternate_Phone_number,
    Postal_Address,
    Email_address,
    County,
    Sub_county,
    Ward,
    Village,
    Landmark,
    Nearest_Health_Centre,
    Next_of_kin,
    Next_of_kin_phone,
    Next_of_kin_relationship,
    Next_of_kin_address,
    (case Marital_status
       when "Divorced" then 1058
       when "Married Monogamous" then 5555
       when "Single" then 1057
       when "Cohabiting" then 5555
       when "Married Polygamous" then 159715
       when "Widowed" then 1059
       when "Separated" then 1056
       when "Unknown" then 1067
       when "Other" then 5622 else NULL end) as Marital_status,
    (case Occupation when "Farmer" then 1538
       when "Trader" then 1539
       when "Tailor" then 1539
       when "SelfEmployment" then 1539
       when "Saloonist" then 1539
       when "Employee" then 1540
       when "HouseKeeper" then 1540
       when "SecurityGuard" then 1540
       when "CasualLabouror" then 1540
       when "Hotelier" then 1540
       when "Student" then 159465
       when "Driver" then 159466
       when "None" then 1107
       when "Other" then 5622 else NULL end) as Occupation,
    (case Education_level
       when "Primary School" then 1713
       when "Secondary School" then 1714
       when "University" then 159785
       when "College" then 159785
       when "NONE" then 1107
       when "Other" then 5622 else NULL end) as Education_level,
    Dead,
    Death_date
  FROM migration_st.st_demographics;

-- 2. Create HIV Enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_hiv_enrollment;
CREATE TABLE migration_tr.tr_hiv_enrollment as
  select
    Person_Id,
    UPN,
    Encounter_Date,
    Encounter_ID,
    (case Patient_Type when 'New' then 164144
     when 'Transfer-In' then 160563
     when 'Transit' then 164931 else NULL end) as Patient_Type,
    (case Entry_point when 'VCT' then 160539
     when 'Volunatry Counselling Centre' then 160539
     when 'Comprehensive Care Clinic' then 162050
     when 'Medical out patient' then 160542
     when 'Outpatient Department' then 160542
     when 'Inpatient Adult' then 160536
     when 'Inpatient Child' then 160537
     when 'PMTCT' then 160536
     when 'Mother Child Health' then 159937
     when 'TB Clinic' then 160541
     when 'Unknown' then 162050
     when 'Other' then 5622 else NULL end) as Entry_point,
    TI_Facility,
    Date_first_enrolled_in_care,
    Transfer_in_date,
    Date_started_art_at_transferring_facility,
    Date_confirmed_hiv_positive,
    Facility_confirmed_hiv_positive,
    Baseline_arv_use,
    (case Purpose_of_baseline_arv_use when 'PMTCT' then 1148
     when 'PEP' then 1691
     when 'ART' then 1181 else NULL end) as Purpose_of_baseline_arv_use,
    (case Baseline_arv_regimen when 'AF2D (TDF + 3TC + ATV/r)' then 164512
     when 'AF2A (TDF + 3TC + NVP)' then 162565
     when 'AF2B (TDF + 3TC + EFV)' then 164505
     when 'AF1A (AZT + 3TC + NVP' then 1652
     when 'AF1B (AZT + 3TC + EFV)' then 160124
     when 'AF4B (ABC + 3TC + EFV)' then 162563
     when 'AF4A (ABC + 3TC + NVP)' then 162199
     when 'CF2A (ABC + 3TC + NVP)' then 162199
     when 'CF2D (ABC + 3TC + LPV/r)' then 162200
     when 'CF2B (ABC + 3TC + EFV)' then 162563 else NULL end) as Baseline_arv_regimen,
    Baseline_arv_regimen_line,
    Baseline_arv_date_last_used,
    (case Baseline_who_stage when 'Stage1' then 1204
     when 'Stage2' then 1205
     when 'Stage3' then 1206
     when 'Stage4' then 1207
     when 'Unknown' then 1067 else NULL end) as Baseline_who_stage,
    Baseline_cd4_results,
    Baseline_cd4_date,
    Baseline_vl_results,
    Baseline_vl_date,
    Baseline_vl_ldl_results,
    Baseline_vl_ldl_date,
    Baseline_HBV_Infected,
    Baseline_TB_Infected,
    Baseline_Pregnant,
    Baseline_Breastfeeding,
    Baseline_Weight,
    Baseline_Height,
    Baseline_BMI,
    Name_of_treatment_supporter,
    Relationship_of_treatment_supporter,
    Treatment_supporter_telephone,
    Treatment_supporter_address
  FROM migration_st.st_hiv_enrollment WHERE Encounter_Date != "" OR Encounter_Date IS NOT NULL
  GROUP BY Person_Id, Encounter_Date;


-- 3. Create Triage transformed table
DROP TABLE IF EXISTS migration_tr.tr_triage;
CREATE TABLE migration_tr.tr_triage as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Visit_reason,
    Systolic_pressure,
    Diastolic_pressure,
    Respiratory_rate,
    Pulse_rate,
    Oxygen_saturation,
    Weight,
    Height,
    Temperature,
    BMI,
    Muac,
    Nutritional_status,
    Last_menstrual_period,
    Nurse_comments
  FROM migration_st.st_triage
  WHERE Encounter_Date != "" OR Encounter_Date != NULL
  GROUP BY Person_Id, Encounter_Date;


-- 4. Create hts initial transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_initial;
CREATE TABLE migration_tr.tr_hts_initial as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Pop_Type
     when "General Population" then 164928
     when "Key Population" then 164929
     when "Priority Population" then 138643  else NULL end)as Pop_Type,
    (case Key_Pop_Type
     when "Male Sex Worker" then 165084
     when "People who Inject with Drugs" then 105
     when "Female Sex Worker" then 160579
     when "Men having Sex with Men" then 160578
     when "other" then 5622  else NULL end) as Key_Pop_Type,
    (case Priority_Pop_Type
     when "Fisher folk" then 159674
     when "Truck driver" then 162198
     when "Adolescent and young girls" then 160549
     when "Prisoner" then 162277
     when "other" then 5622  else NULL end) as Priority_Pop_Type,
    (case Patient_disabled
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Patient_disabled,
    (case Disability
     when "D: Deaf/Hearing impaired" then 120291
     when "B: Blind/Visually impaired" then 147215
     when "M: Mentally Challenged" then 151342
     when "P: Physically Challenged" then  164538
     when "Other" then 5622 else NULL end)as Disability,
    (case Ever_Tested
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Ever_Tested,
    (case Self_Tested
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Self_Tested,
    (case HTS_Strategy
     when "NP: Non-Patients" then 164953
     when "HP: Health Facility Patients" then 164955
     when "VI: Integrated VCT sites" then 164954 else NULL end )as HTS_Strategy,
    (case HTS_Entry_Point
     when "IPD-Adult" then 5485
     when "Maternity" then 160538
     when "MCH" then 160538
     when "OPD" then 160542
     when "Other" then 5622
     when "PNS" then 160538
     when "TB" then 160541
     when "Mobile Outreach" then 159939
     when "PeD" then 162181
     when "ANC" then 160538
     when "Outreach" then 159939
     when "PITC" then 160538
     when "PMTCT" then 160538
     when "CCC" then 162050
     when "IPD-Child" then 160538
     when "VCT" then 159940
     when "HBTC" then 159938  else NULL end)as HTS_Entry_Point,
    (case Consented
     when "Yes" then 1
     when "No" then 2  else NULL end)as Consented,
    (case Tested_As
     when "C: Couple (includes polygamous)" then 164957
     when "I: Individual" then 164958  else NULL end)as Tested_As,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end) as Test_1_Kit_Name,
    Test_1_Lot_Number,
    Test_1_Expiry_Date,
    (case Test_1_Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_1_Final_Result,
    (case Test_2_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end)as  Test_2_Kit_Name,
    Test_2_Lot_Number,
    Test_2_Expiry_Date,
    (case Test_2_Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_2_Final_Result,
    (case  Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Final_Result,
    (case Result_given
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Result_given,
    (case Couple_Discordant
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Couple_Discordant,
    (case Tb_Screening_Results
     when "NS: No Signs" then 1660
     when "PrTB: Presumed TB" then 142177
     when "TB Confirmed" then 1662
     when "ND: Not Done" then 160737
     when "TBRx: On TB treatment" then 1111 else NULL end)as Tb_Screening_Results,
    Remarks
  FROM migration_st.st_hts_initial where TestType = "Initial Test" AND
   (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 5. Create hts retest transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_retest;
CREATE TABLE migration_tr.tr_hts_retest as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Pop_Type
     when "General Population" then 164928
     when "Key Population" then 164929
     when "Priority Population" then 138643  else NULL end)as Pop_Type,
    (case Key_Pop_Type
     when "Male Sex Worker" then 165084
     when "People who Inject with Drugs" then 105
     when "Female Sex Worker" then 160579
     when "Men having Sex with Men" then 160578
     when "other" then 5622  else NULL end) as Key_Pop_Type,
    (case Priority_Pop_Type
     when "Fisher folk" then 159674
     when "Truck driver" then 162198
     when "Adolescent and young girls" then 160549
     when "Prisoner" then 162277
     when "other" then 5622  else NULL end) as Priority_Pop_Type,
    (case Patient_disabled
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Patient_disabled,
    (case Disability
     when "D: Deaf/Hearing impaired" then 120291
     when "B: Blind/Visually impaired" then 147215
     when "M: Mentally Challenged" then 151342
     when "P: Physically Challenged" then  164538
     when "Other" then 5622 else NULL end)as Disability,
    (case Ever_Tested
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Ever_Tested,
    (case Self_Tested
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Self_Tested,
    (case HTS_Strategy
     when "NP: Non-Patients" then 164953
     when "HP: Health Facility Patients" then 164955
     when "VI: Integrated VCT sites" then 164954 else NULL end )as HTS_Strategy,
    (case HTS_Entry_Point
     when "IPD-Adult" then 5485
     when "Maternity" then 160538
     when "MCH" then 160538
     when "OPD" then 160542
     when "Other" then 5622
     when "PNS" then 160538
     when "TB" then 160541
     when "Mobile Outreach" then 159939
     when "PeD" then 162181
     when "ANC" then 160538
     when "Outreach" then 159939
     when "PITC" then 160538
     when "PMTCT" then 160538
     when "CCC" then 162050
     when "IPD-Child" then 160538
     when "VCT" then 5415994085
     when "HBTC" then 159938  else NULL end)as HTS_Entry_Point,
    (case Consented
     when "Yes" then 1
     when "No" then 2  else NULL end)as Consented,
    (case Tested_As
     when "C: Couple (includes polygamous)" then 164957
     when "I: Individual" then 164958  else NULL end)as Tested_As,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end) as Test_1_Kit_Name,
    Test_1_Lot_Number,
    Test_1_Expiry_Date,
    (case Test_1_Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_1_Final_Result,
    (case Test_2_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end)as  Test_2_Kit_Name,
    Test_2_Lot_Number,
    Test_2_Expiry_Date,
    (case Test_2_Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_2_Final_Result,
    (case  Final_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Final_Result,
    (case Result_given
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Result_given,
    (case Couple_Discordant
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Couple_Discordant,
    (case Tb_Screening_Results
     when "NS: No Signs" then 1660
     when "PrTB: Presumed TB" then 142177
     when "TB Confirmed" then 1662
     when "ND: Not Done" then 160737
     when "TBRx: On TB treatment" then 1111 else NULL end)as Tb_Screening_Results,
    Remarks
  FROM migration_st.st_hts_retest where TestType = "Repeat Test" AND
  (Encounter_Date != "" OR Encounter_Date != NULL)
  GROUP BY Person_Id, Encounter_Date;
  
  -- 6. HTS Client Tracing transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_tracing;
CREATE TABLE migration_tr.tr_hts_tracing as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  (case Contact_Type
     when "Phone" then 1650
     when "Physical" then 164965 else NULL end) as Contact_Type,
  (case Contact_Outcome
     when "Contacted" then 1065
     when "Not Contacted" then 1118 else NULL end) as Contact_Outcome,
  (case Reason_uncontacted
     when "No locator information in record" then 165073
     when "Incorrect locator information in record" then 165072
     when "Died" then 160034
     when "Others" then 5622
     when "Migrated from reported location" then 160415
     when "Not found at home" then 1706
     when "Mteja, calls not going through, not picking calls" then 1567 else NULL end) as Reason_uncontacted,
  Remarks,
  Voided
FROM migration_st.st_hts_tracing WHERE
  (Encounter_Date != "" OR Encounter_Date != NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 7. HTS Client Referral transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_referral;
CREATE TABLE migration_tr.tr_hts_referral as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Facility_Referred,
    Date_To_Be_Enrolled,
    Remarks,
    Voided
  FROM migration_st.st_hts_referral WHERE
    (Encounter_Date != "" OR Encounter_Date != NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 8. HTS Client Linkage transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_linkage;
CREATE TABLE migration_tr.tr_hts_linkage as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Facility_Linked,
    CCC_Number,
    Health_Worker_Handed_To,
   (case Cadre
     when "Nurse" then 1577
     when "NURSE" then 1577
     when "Clinical Officer/Doctor" then 1574
     when "Community Health Worker" then 1555
     when "Employee" then 1540
     when "Other" then 5622
     when "COUNSELLOR" then 1577 else NULL end) as Cadre,
    Date_Enrolled,
    ART_Start_Date,
    Remarks,
    Voided
  FROM migration_st.st_hts_linkage WHERE
    (Encounter_Date != "" OR Encounter_Date != NULL)
  GROUP BY Person_Id, Encounter_Date;


-- 9. HTS Contact Listing transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_contact_listing;
CREATE TABLE migration_tr.tr_hts_contact_listing as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
  (case Consent
     when "YES" then 1065
     when "NO" then 1066 else NULL end) as Consent,
    First_Name,
    Middle_Name,
    Last_Name,
  (case Sex
     when "Male" then 1534
     when "Female" then  1535 else NULL end) as Sex,
    DoB,
   (case Marital_Status
     when "Divorced" then 1058
     when "Married Monogamous" then 5555
     when "Single" then 1057
     when "Cohabiting" then 5555
     when "Married Polygamous" then 159715
     when "Widowed" then 1059
     when "Separated" then 1056
     when "Unknown" then 1067
     when "Other" then 5622 else NULL end) as Marital_Status,
    Physical_Address,
    Phone_Number,
  (case Relationship_To_Index
     when "Mother" then 970
     when "Father" then 971
     when "Child - C" then 1528
     when "Sexual Partner (SP)" then 163565
     when "Co-Wife" then 162221
     when "Spouse" then 5617
     when "Sibling" then 972
     when "Unknown" then 1067
     when "Injectable Drug User (IDU)" then 157351
     when "Other" then 5622 else NULL end) as Relationship_To_Index,
    PNSScreeningDate,
   (case Currently_Living_With_Index
     when "Yes" then 1065
     when "No" then 1066
     when "Declined" then 162570  else NULL end) as Currently_Living_With_Index,
  (case IPV_Physically_Hurt
     when "Yes" then 1065
     when "No" then 1066
     when "N/A" then 1175 else NULL end) as IPV_Physically_Hurt,
  (case IPV_Threatened_Hurt
     when "Yes" then 1065
     when "No" then 1066
     when "N/A" then 1175 else NULL end) as IPV_Threatened_Hurt,
  (case IPV_Sexual_Hurt
     when "Yes" then 1065
     when "No" then 1066
     when "N/A" then 1175 else NULL end) as IPV_Sexual_Hurt,
  (case IPV_Outcome
     when "NA-CHILD" then 1066
     when "Sexual" then 1066
     when "Emotional" then 1066
     when "Physical" then 1066
     when "No IPV" then 1065
     when "No" then 1066
     when "N/A" then 1175 else NULL end) as IPV_Outcome,
  (case HIV_Status
     when "Positive" then 703
     when "Negative" then 664
     when "Unknown" then 1067 else NULL end)as HIV_Status,
  (case PNS_Approach
     when "Pr: Provider Referral" then 703
     when "Cr: Passive Referral" then 664
     when "D: Dual Referral" then 664
     when "Con: Contract Referral" then 664
     when "Unknown" then 1067 else NULL end)as PNS_Approach,
    DateTracingDone,
    (case Contact_Type
     when "Phone" then 1650
     when "Physical" then 164965 else NULL end) as Contact_Type,
    (case Contact_Outcome
     when "Contacted" then 1065
     when "Not Contacted" then 1118 else NULL end) as Contact_Outcome,
    (case Reason_uncontacted
     when "No locator information" then 165073
     when "Incorrect locator information" then 165072
     when "Died" then 160034
     when "Others" then 5622
     when "Migrated" then 160415
     when "Not found at home" then 1706
     when "Calls not going through" then 1567 else NULL end) as Reason_uncontacted,
    Booking_Date,
    Date_Reminded,
    Voided
  FROM migration_st.st_hts_contact_listing WHERE
    (Encounter_Date != "" OR Encounter_Date != NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 10. Create HIV  program enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_hiv_program_enrollment;
CREATE TABLE migration_tr.tr_hiv_program_enrollment as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Program,
    Date_Enrolled,
    Date_Completed
  FROM migration_st.st_hiv_program_enrollment WHERE  Program = "CCC"
  AND (Encounter_Date != "" OR Encounter_Date IS NOT NULL);

-- 11. Create HIV Program Discontinuation transformed table
DROP TABLE IF EXISTS migration_tr.tr_hiv_program_discontinuation;
CREATE TABLE migration_tr.tr_hiv_program_discontinuation as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Program,
    Date_Enrolled,
    Date_Completed,
    (case Care_Ending_Reason when "Transfer Out" then 159492
     when "Death" then 160034
     when "Lost To Follow Up" then 5240
     when "Confirmed HIV Negative" then 1403
     when "HIV Negative" then 1403
     when "Other" then 5622
     when "Unknown" then 1067 else NULL end) as Care_Ending_Reason,
    Facility_Transfered_To,
    Death_Date
  FROM migration_st.st_program_discontinuation  WHERE Program = "CCC"
  AND (Encounter_Date != "" OR Encounter_Date IS NOT NULL);
  
  --12 . TB Screening transformed table
DROP TABLE IF EXISTS migration_tr.tr_tb_screening;
CREATE TABLE migration_tr.tr_tb_screening
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      (case Cough
       when "Yes" then 159799
       when "No" then 1066  else NULL end)as Cough,
      (case Fever
       when "Yes" then 1494
       when "No" then 1066  else NULL end)as Fever,
      (case Weight_loss
       when "Yes" then 832
       when "No" then 1066  else NULL end)as Weight_loss,
      (case Night_sweats
       when "Yes" then 133027
       when "No" then 1066  else NULL end)as Night_sweats,
      (case Tests_Ordered
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Tests_Ordered,
      (case Sputum_Smear
       when "Positive" then 703
       when "Ordered" then 307
       when "Negative" then 664  else NULL end)as Sputum_Smear,
      (case X_ray 
       when "Ordered" then 12
       when "Suggestive" then 152526
       when "Normal" then 1115
       when "Not Done" then 1118
       when "NotDone" then 1118 else NULL end)as X_ray ,
      (case Gene_xpert
       when "Ordered" then 162202
       when "Negative" then 664
       when "Positive" then 162204
       when "Not Done" then 1118
       when "NotDone" then 1118  else NULL end)as Gene_xpert,     
      Contact_tb_case,
      Lethergy,       
      Referral,
      Clinical_diagnosis,
      (case Invitation_contacts
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Invitation_contacts,
      (case Evaluated_for_IPT
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Evaluated_for_IPT,
      (case TB_results
       when "No TB Signs" then 1660
       when "Presumed TB" then 142177
       when "TB Confirmed" then 1661
       when "TB Rx" then  1662
       when "INH" then 1679 
       when "TB Screening Not Done" then  160737 else NULL end)as TB_results
    FROM migration_st.st_tb_screening WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    GROUP BY Person_Id, Encounter_Date;
  
-- 13. IPT Screening transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_screening;
CREATE TABLE migration_tr.tr_ipt_screening as
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      (case Yellow_urine
       when "Yes" then 162311
       when "No" then 1066  else NULL end)as Yellow_urine,
      (case Numbness
       when "Yes" then 132652
       when "No" then 1066  else NULL end)as Numbness,
      (case Yellow_eyes
       when "Yes" then 5192
       when "No" then 1066  else NULL end)as Yellow_eyes,
      (case Tenderness
       when "Yes" then 124994
       when "No" then 1066  else NULL end)as Tenderness,
      IPT_Start_Date
    FROM migration_st.st_ipt_screening WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    GROUP BY Person_Id, Encounter_Date;

-- 14. IPT program Enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_program;
CREATE TABLE migration_tr.tr_ipt_program
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      IPT_Start_Date,
      Indication_for_IPT,
      (case IPT_Outcome when "TransferredOut" then 159492
       when "Died" then 160034
       when "Discontinued" then 159836
       when "LostToFollowUp" then 5240
       when "Completed" then 1267
       when "Unknown" then 1067 else NULL end) as IPT_Outcome,
      Outcome_Date
    FROM migration_st.st_ipt_program WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    GROUP BY Person_Id, Encounter_Date;

-- 15. IPT program Followup transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_followup;
CREATE TABLE migration_tr.tr_ipt_followup
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      Ipt_due_date,
      Date_collected_ipt,
      Weight,
      (case Hepatotoxity
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Hepatotoxity,
      (case Peripheral_neuropathy
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Peripheral_neuropathy,
      (case Rash
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Rash,
      (case Adherence
       when "Good(Missed<3/month)" then 159405
       when "Fair(Missed4-8/month)" then 159406
       when "Bad()Missed 9" then 159407 else NULL end)as Adherence,
      AdheranceMeasurement_Action,
      IPT_Outcome,
      Outcome_Date
    FROM migration_st.st_ipt_followup WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    GROUP BY Person_Id, Encounter_Date;

-- 16. HIV Regimen History transformed table
DROP TABLE IF EXISTS migration_tr.tr_hiv_regimen_history;
CREATE TABLE migration_tr.tr_hiv_regimen_history
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      (case Program
       when "ART" then 1255
       when "TB" then 1268
       when "PMTCT" then 1255
       when "PEP" then 1691
       when "PREP" then 165003
       when "HBV" then 111759
       when "Hepatitis B" then 111759
       when "Treatment" then 1255
       when "prophylaxis" then 1255
       when "Non-ART" then 5622 else NULL end)as Program,
      (case Drug_Event
       when "Start" then 1256
       when "Stop" then 1260
       when "Change" then 1259 else NULL end)as Drug_Event,
      (case Regimen_Name
       when "PM 8 SD Nevirapine (NVP)" then 80586
       when "PM1 AZT from 14Wks" then 86663
       when "TDF + 3TC + NVP"  then 162565
       when "PM 6 TDF + 3TC + NVP"  then 162565
       when "TDF + 3TC + NVP (children > 35kg)"  then 162565
       when "TDF + 3TC + EFV"  then 164505
       when "PM 9 TDF + 3TC + EFV"  then 164505
       when "AZT + 3TC + NVP"  then 1652
       when "PM2 NVP stat + AZT stat"  then 1652
       when "PM3 AZT + 3TC + NVP"  then 1652
       when "AZT + 3TC + EFV"  then 160124
       when "PM4 AZT + 3TC + EFV"  then 160124
       when "D4T + 3TC + NVP"  then 792
       when "D4T + 3TC + EFV"  then 160104
       when "TDF + 3TC + AZT"  then 164971
       when "AZT + 3TC + DTG"  then 164968
       when "TDF + 3TC + DTG"  then 164969
       when "ABC + 3TC + DTG"  then 164970
       when "AZT + 3TC + LPV/r"  then 162561
       when "AZT + 3TC + ATV/r"  then 164511
       when "AZT + 3TC + ATV/r (Adult PEP)"  then 164511
       when "PM 10 AZT + 3TC + ATV/r"  then 164511
       when "TDF + 3TC + LPV/r"  then 162201
       when "PM 7 TDF + 3TC + LPV/r"  then 162201
       when "TDF + 3TC + ATV/r"  then 164512
       when "TDF + 3TC + ATV/r (Adult PEP)"  then 164512
       when "PM 11 TDF + 3TC + ATV/r"  then 164512
       when "D4T + 3TC + LPV/r"  then 162560
       when "AZT + TDF + 3TC + LPV/r"  then 164972
       when "ETR + RAL + DRV + RTV"  then 164973
       when "ETR + TDF + 3TC + LPV/r"  then 164974
       when "ABC + 3TC + ATV/r"  then 165357
       when "ABC + 3TC + LPV/r"  then 162200
       when "ABC + 3TC + LPV/r (Paed PEP)"  then 162200
       when "ABC + 3TC + NVP"  then 162199
       when "ABC + 3TC + EFV"  then 162563
       when "AZT + 3TC + ABC"  then 817
       when "D4T + 3TC + ABC"  then 164975
       when "TDF + ABC + LPV/r"  then 162562
       when "ABC + DDI + LPV/r"  then 162559
       when "ABC + TDF + 3TC + LPV/r"  then 164976
       when "TDF+3TC" then 161364
       when "TDF + 3TC (PrEP)" then 161364
       when "TDF+FTC" then 104567
       when "TDF + FTC (PrEP)" then 104567
       when "DTG + DRV + RTV" then 164973
       when "DTG + DRV + RTV + ETV" then 164973
       when "RAL + DRV + RTV + ETV" then 164973
       when "RAL + other backbone ARVs" then 154378
       when "Any other 2nd line Paediatric regimens" then 162188
       when "Any other 2nd line Adult regimens" then 162188
       when "TDF" then 84795
       when "DTG" then 164967
       when "RHZE" then 1675
       when "RHZE" then 1675
       when "2SRHZE|4RHZE" then 1675
       when "RHZ"  then 768
       when "2RHZ|4rh"  then 768
       when "SRHZE"  then 1674
       when "RfbHZE"  then 164978
       when "RfbHZ"   then 164979
       when "SRfbHZE"  then 164980
       when "2SRHZE|1RHZE|5RHE"  then 164980
       when "S (1 gm vial)"  then 84360
       when "E" then 75948
       when "RH" then 1194
       when "2RHZE|10RH" then 1194
       when "2RHZE|4RH" then 1194
       when "RHE"  then 159851
       when "3RHZE|5RHE"  then 159851
       when "EH"  then 1108  else NULL end ) as Regimen_Name,
      Date_Started,
      (case Regimen_Discontinued
       when "PM 8 SD Nevirapine (NVP)" then 80586
       when "PM1 AZT from 14Wks" then 86663
       when "TDF + 3TC + NVP"  then 162565
       when "PM 6 TDF + 3TC + NVP"  then 162565
       when "TDF + 3TC + NVP (children > 35kg)"  then 162565
       when "TDF + 3TC + EFV"  then 164505
       when "PM 9 TDF + 3TC + EFV"  then 164505
       when "AZT + 3TC + NVP"  then 1652
       when "PM2 NVP stat + AZT stat"  then 1652
       when "PM3 AZT + 3TC + NVP"  then 1652
       when "AZT + 3TC + EFV"  then 160124
       when "PM4 AZT + 3TC + EFV"  then 160124
       when "D4T + 3TC + NVP"  then 792
       when "D4T + 3TC + EFV"  then 160104
       when "TDF + 3TC + AZT"  then 164971
       when "AZT + 3TC + DTG"  then 164968
       when "TDF + 3TC + DTG"  then 164969
       when "ABC + 3TC + DTG"  then 164970
       when "AZT + 3TC + LPV/r"  then 162561
       when "AZT + 3TC + ATV/r"  then 164511
       when "AZT + 3TC + ATV/r (Adult PEP)"  then 164511
       when "PM 10 AZT + 3TC + ATV/r"  then 164511
       when "TDF + 3TC + LPV/r"  then 162201
       when "PM 7 TDF + 3TC + LPV/r"  then 162201
       when "TDF + 3TC + ATV/r"  then 164512
       when "TDF + 3TC + ATV/r (Adult PEP)"  then 164512
       when "PM 11 TDF + 3TC + ATV/r"  then 164512
       when "D4T + 3TC + LPV/r"  then 162560
       when "AZT + TDF + 3TC + LPV/r"  then 164972
       when "ETR + RAL + DRV + RTV"  then 164973
       when "ETR + TDF + 3TC + LPV/r"  then 164974
       when "ABC + 3TC + ATV/r"  then 165357
       when "ABC + 3TC + LPV/r"  then 162200
       when "ABC + 3TC + LPV/r (Paed PEP)"  then 162200
       when "ABC + 3TC + NVP"  then 162199
       when "ABC + 3TC + EFV"  then 162563
       when "AZT + 3TC + ABC"  then 817
       when "D4T + 3TC + ABC"  then 164975
       when "TDF + ABC + LPV/r"  then 162562
       when "ABC + DDI + LPV/r"  then 162559
       when "ABC + TDF + 3TC + LPV/r"  then 164976
       when "TDF+3TC" then 161364
       when "TDF + 3TC (PrEP)" then 161364
       when "TDF+FTC" then 104567
       when "TDF + FTC (PrEP)" then 104567
       when "DTG + DRV + RTV" then 164973
       when "DTG + DRV + RTV + ETV" then 164973
       when "RAL + DRV + RTV + ETV" then 164973
       when "RAL + other backbone ARVs" then 154378
       when "Any other 2nd line Paediatric regimens" then 162188
       when "Any other 2nd line Adult regimens" then 162188
       when "TDF" then 84795
       when "DTG" then 164967
       when "RHZE" then 1675
       when "RHZE" then 1675
       when "2SRHZE|4RHZE" then 1675
       when "RHZ"  then 768
       when "2RHZ|4rh"  then 768
       when "SRHZE"  then 1674
       when "RfbHZE"  then 164978
       when "RfbHZ"   then 164979
       when "SRfbHZE"  then 164980
       when "2SRHZE|1RHZE|5RHE"  then 164980
       when "S (1 gm vial)"  then 84360
       when "E" then 75948
       when "RH" then 1194
       when "2RHZE|10RH" then 1194
       when "2RHZE|4RH" then 1194
       when "RHE"  then 159851
       when "3RHZE|5RHE"  then 159851
       when "EH"  then 1108  else NULL end ) as Regimen_Discontinued,
      Date_Discontinued,
      Reason_Discontinued,
      (case RegimenSwitchTo
       when "PM 8 SD Nevirapine (NVP)" then 80586
       when "PM1 AZT from 14Wks" then 86663
       when "TDF + 3TC + NVP"  then 162565
       when "PM 6 TDF + 3TC + NVP"  then 162565
       when "TDF + 3TC + NVP (children > 35kg)"  then 162565
       when "TDF + 3TC + EFV"  then 164505
       when "PM 9 TDF + 3TC + EFV"  then 164505
       when "AZT + 3TC + NVP"  then 1652
       when "PM2 NVP stat + AZT stat"  then 1652
       when "PM3 AZT + 3TC + NVP"  then 1652
       when "AZT + 3TC + EFV"  then 160124
       when "PM4 AZT + 3TC + EFV"  then 160124
       when "D4T + 3TC + NVP"  then 792
       when "D4T + 3TC + EFV"  then 160104
       when "TDF + 3TC + AZT"  then 164971
       when "AZT + 3TC + DTG"  then 164968
       when "TDF + 3TC + DTG"  then 164969
       when "ABC + 3TC + DTG"  then 164970
       when "AZT + 3TC + LPV/r"  then 162561
       when "AZT + 3TC + ATV/r"  then 164511
       when "AZT + 3TC + ATV/r (Adult PEP)"  then 164511
       when "PM 10 AZT + 3TC + ATV/r"  then 164511
       when "TDF + 3TC + LPV/r"  then 162201
       when "PM 7 TDF + 3TC + LPV/r"  then 162201
       when "TDF + 3TC + ATV/r"  then 164512
       when "TDF + 3TC + ATV/r (Adult PEP)"  then 164512
       when "PM 11 TDF + 3TC + ATV/r"  then 164512
       when "D4T + 3TC + LPV/r"  then 162560
       when "AZT + TDF + 3TC + LPV/r"  then 164972
       when "ETR + RAL + DRV + RTV"  then 164973
       when "ETR + TDF + 3TC + LPV/r"  then 164974
       when "ABC + 3TC + ATV/r"  then 165357
       when "ABC + 3TC + LPV/r"  then 162200
       when "ABC + 3TC + LPV/r (Paed PEP)"  then 162200
       when "ABC + 3TC + NVP"  then 162199
       when "ABC + 3TC + EFV"  then 162563
       when "AZT + 3TC + ABC"  then 817
       when "D4T + 3TC + ABC"  then 164975
       when "TDF + ABC + LPV/r"  then 162562
       when "ABC + DDI + LPV/r"  then 162559
       when "ABC + TDF + 3TC + LPV/r"  then 164976
       when "TDF+3TC" then 161364
       when "TDF + 3TC (PrEP)" then 161364
       when "TDF+FTC" then 104567
       when "TDF + FTC (PrEP)" then 104567
       when "DTG + DRV + RTV" then 164973
       when "DTG + DRV + RTV + ETV" then 164973
       when "RAL + DRV + RTV + ETV" then 164973
       when "RAL + other backbone ARVs" then 154378
       when "Any other 2nd line Paediatric regimens" then 162188
       when "Any other 2nd line Adult regimens" then 162188
       when "TDF" then 84795
       when "DTG" then 164967
       when "RHZE" then 1675
       when "RHZE" then 1675
       when "2SRHZE|4RHZE" then 1675
       when "RHZ"  then 768
       when "2RHZ|4rh"  then 768
       when "SRHZE"  then 1674
       when "RfbHZE"  then 164978
       when "RfbHZ"   then 164979
       when "SRfbHZE"  then 164980
       when "2SRHZE|1RHZE|5RHE"  then 164980
       when "S (1 gm vial)"  then 84360
       when "E" then 75948
       when "RH" then 1194
       when "2RHZE|10RH" then 1194
       when "2RHZE|4RH" then 1194
       when "RHE"  then 159851
       when "3RHZE|5RHE"  then 159851
       when "EH"  then 1108  else NULL end ) as RegimenSwitchTo,
      (case CurrentRegimen
       when "PM 8 SD Nevirapine (NVP)" then 80586
       when "PM1 AZT from 14Wks" then 86663
       when "TDF + 3TC + NVP"  then 162565
       when "PM 6 TDF + 3TC + NVP"  then 162565
       when "TDF + 3TC + NVP (children > 35kg)"  then 162565
       when "TDF + 3TC + EFV"  then 164505
       when "PM 9 TDF + 3TC + EFV"  then 164505
       when "AZT + 3TC + NVP"  then 1652
       when "PM2 NVP stat + AZT stat"  then 1652
       when "PM3 AZT + 3TC + NVP"  then 1652
       when "AZT + 3TC + EFV"  then 160124
       when "PM4 AZT + 3TC + EFV"  then 160124
       when "D4T + 3TC + NVP"  then 792
       when "D4T + 3TC + EFV"  then 160104
       when "TDF + 3TC + AZT"  then 164971
       when "AZT + 3TC + DTG"  then 164968
       when "TDF + 3TC + DTG"  then 164969
       when "ABC + 3TC + DTG"  then 164970
       when "AZT + 3TC + LPV/r"  then 162561
       when "AZT + 3TC + ATV/r"  then 164511
       when "AZT + 3TC + ATV/r (Adult PEP)"  then 164511
       when "PM 10 AZT + 3TC + ATV/r"  then 164511
       when "TDF + 3TC + LPV/r"  then 162201
       when "PM 7 TDF + 3TC + LPV/r"  then 162201
       when "TDF + 3TC + ATV/r"  then 164512
       when "TDF + 3TC + ATV/r (Adult PEP)"  then 164512
       when "PM 11 TDF + 3TC + ATV/r"  then 164512
       when "D4T + 3TC + LPV/r"  then 162560
       when "AZT + TDF + 3TC + LPV/r"  then 164972
       when "ETR + RAL + DRV + RTV"  then 164973
       when "ETR + TDF + 3TC + LPV/r"  then 164974
       when "ABC + 3TC + ATV/r"  then 165357
       when "ABC + 3TC + LPV/r"  then 162200
       when "ABC + 3TC + LPV/r (Paed PEP)"  then 162200
       when "ABC + 3TC + NVP"  then 162199
       when "ABC + 3TC + EFV"  then 162563
       when "AZT + 3TC + ABC"  then 817
       when "D4T + 3TC + ABC"  then 164975
       when "TDF + ABC + LPV/r"  then 162562
       when "ABC + DDI + LPV/r"  then 162559
       when "ABC + TDF + 3TC + LPV/r"  then 164976
       when "TDF+3TC" then 161364
       when "TDF + 3TC (PrEP)" then 161364
       when "TDF+FTC" then 104567
       when "TDF + FTC (PrEP)" then 104567
       when "DTG + DRV + RTV" then 164973
       when "DTG + DRV + RTV + ETV" then 164973
       when "RAL + DRV + RTV + ETV" then 164973
       when "RAL + other backbone ARVs" then 154378
       when "Any other 2nd line Paediatric regimens" then 162188
       when "Any other 2nd line Adult regimens" then 162188
       when "TDF" then 84795
       when "DTG" then 164967
       when "RHZE" then 1675
       when "RHZE" then 1675
       when "2SRHZE|4RHZE" then 1675
       when "RHZ"  then 768
       when "2RHZ|4rh"  then 768
       when "SRHZE"  then 1674
       when "RfbHZE"  then 164978
       when "RfbHZ"   then 164979
       when "SRfbHZE"  then 164980
       when "2SRHZE|1RHZE|5RHE"  then 164980
       when "S (1 gm vial)"  then 84360
       when "E" then 75948
       when "RH" then 1194
       when "2RHZE|10RH" then 1194
       when "2RHZE|4RH" then 1194
       when "RHE"  then 159851
       when "3RHZE|5RHE"  then 159851
       when "EH"  then 1108  else NULL end ) as CurrentRegimen
    FROM migration_st.st_regimen_history where (Date_Started != "" OR Date_Started IS NOT NULL) AND
   (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 17. HIV Followup transformed table
  DROP TABLE IF EXISTS migration_tr.tr_hiv_followup;
 CREATE TABLE migration_tr.tr_hiv_followup
    select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  (case Visit_scheduled when "Yes" then 1
                        when "No" then 2 else NULL end )as Visit_scheduled,
  (case Visit_by when "S" then 978
                 when "TS" then 161642 else NULL end )as Visit_by,
  Visit_by_other,
  (case Nutritional_status when "Normal" then 978
                           when "Severe Acute Malnutrition" then 163302
                           when "Moderate Acute Malnutrition" then 163303
                           when "Overweight/Obese" then 114413 else NULL end )as Nutritional_status,
  (case Population_type when "General Population" then 164928
                        when "Key Population" then 164929 else NULL end) as Population_type,
  (case Key_population_type when "People who Inject with Drugs" then 105 else NULL end) as Key_population_type_pwid,
  (case Key_population_type  when "Men having Sex with Men" then 160578 else NULL end) as Key_population_type_msm,
  (case Key_population_type when "Female Sex Worker" then 160579 else NULL end) as Key_population_type_fsw,
  (case Who_stage when "Stage1" then 1204
                  when "Stage2" then 1205
                  when "Stage3" then 1206
                  when "Stage4" then 1207 else NULL end )as Who_stage,
  (case Presenting_complaints
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Presenting_complaints,
--   (case Complaint
--        when "Weight loss" then 832
--        when "Vomiting" then 122983
--        when "Vertigo" then 111525
--        when "Urinary symptoms Pain/frequency/Urgency" then 160208
--        when "Tremors" then 112200
--        when "Swollen legs" then 125198
--        when "Sweating-excessive" then 140941
--        when "Sore Throat" then 158843
--        when "Sleep disturbance" then 141597
--        when "Shoulder pain" then 126535
--        when "Scrotal pain" then 131032
--        when "Runny/blocked nose" then 113224
--        when "Ringing/Buzzing ears" then 117698
--        when "Red eye" then 127777
--        when "Rash" then 512
--        when "Poor Vision" then 5953
--        when "Pelvic pain" then 131034
--        when "Pain when swallowing" then 125225
--        when "Numbness" then 132653
--        when "Night Sweats" then 133027
--        when "Neck pain" then 133469
--        when "Nausea" then 5978
--        when "Muscle pain" then 133632
--        when "Muscle cramps" then 133028
--        when "Mouth ulcers" then 111721
--        when "Mouth pain/burning" then 131015
--        when "Mental status, acute change (coma, lethargy)" then 144576
--        when "Memory loss" then 121657
--        when "Lymphadenopathy" then 135488
--        when "Loss of appetite" then 135595
--        when "Leg pain" then 114395
--        when "Joint Pain" then 116558
--        when "Itchiness/Pruritus" then 879
--        when "Hypotension/Shock" then 116214
--        when "Hearing loss" then 117698
--        when "Headache" then 139084
--        when "Genital skin lesion/Ulcer" then 135462
--        when "Genital Discharge" then 123396
--        when "Flank pain" then 140070
--        when "Fever" then 140238
--        when "Fatigue/weakness" then 162626
--        when "Facial pain" then 114399
--        when "Eye pain" then 131040
--        when "Epigastric Pain" then 141128
--        when "Ear pain" then 141585
--        when "Dizziness" then 141830
--        when "Difficulty in swallowing" then 118789
--        when "Difficult in breathing" then 122496
--        when "Diarrhoea" then 142412
--        when "Crying infant" then 143129
--        when "Cough" then 143264
--        when "Convulsions/Seizure" then 206
--        when "Confusion/Delirium" then 119574
--        when "Cold/Chills" then 871
--        when "Chest pain" then 120749
--        when "Breast pain" then 131021
--        when "Bloody Urine" then 840
--        when "Back pain" then 148035
--        when "Anxiety, depression" then 119537
--        when "Abnormal uterine bleeding" then 141631
--        when "Abdominal pain" then 151
--        when "Other" then 5622  else '' end)as Complaint,
--   Duration,
--   Onset_Date,
--   Clinical_notes,
  (case Has_known_allergies
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Has_known_allergies,
--   (case Allergies_causative_agents
--        when "Ragweed" then 162541
--        when "Pollen" then 162540
--        when "Mold" then 162539
--        when "Latex" then 162538
--        when "Dust" then 162537
--        when "Bee stings" then 162536
--        when "Adhesive tape" then 162542
--        when "Wheat" then 162177
--        when "Strawberries" then 162548
--        when "Soy" then 162176
--        when "Shellfish" then 162175
--        when "Peanuts" then 162172
--        when "Milk protein" then 162547
--        when "Fish" then 162546
--        when "Eggs" then 162171
--        when "Dairy food" then 162545
--        when "Chocolate" then 162544
--        when "Caffeine" then 72609
--        when "Beef" then 162543
--        when "Zidovudine" then 86663
--        when "Tetracyline" then 84893
--        when "Tenofovir" then 84795
--        when "Sulfonamides" then 162170
--        when "Stavudine" then 84309
--        when "Statins" then 162307
--        when "Rifampin" then 767
--        when "Quinidine" then 83018
--        when "Pyrazinamide" then 82900
--        when "Procainamide" then 82559
--        when "Phenytoin" then 82023
--        when "Phenolphthaleins" then 81959
--        when "Penicillins" then 81724
--        when "Penicillamine" then 81723
--        when "Non-steroidal anti-inflammatory drugs" then 162306
--        when "Nitrofurans" then 158005
--        when "Nevirapine" then 80586
--        when "Morphine" then 80106
--        when "Lopinavir/ritonavir" then 794
--        when "Isoniazid" then 78280
--        when "Hydralazine" then 77675
--        when "Heparins" then 162305
--        when "Griseofulvin" then 77164
--        when "Ethambutol" then 75948
--        when "Erythromycins" then 162302
--        when "Efavirenz" then 75523
--        when "Didanosine" then 74807
--        when "Codeine" then 73667
--        when "Choloroquine" then 73300
--        when "Cephalosporins" then 162301
--        when "Carbamazepine" then 72822
--        when "Atazanavir" then 71647
--        when "Aspirin" then 155175
--        when "ARBs (angiotensin II receptor blockers)" then 162299
--        when "Aminoglycosides" then 155060
--        when "Allopurinol" then 70878
--        when "ACE inhibitors" then 162298
--        when "Abacavir" then 70056
--        when "Other" then 5622 else '' end)as Allergies_causative_agents,
--   (case Allergies_reactions
--        when "Unknown" then 1067
--        when "Anaemia" then 121629
--        when "Anaphylaxis" then 148888
--        when "Angioedema" then 148787
--        when "Arrhythmia" then 120148
--        when "Bronchospasm" then 108
--        when "Cough" then 143264
--        when "Diarrhea" then 142412
--        when "Dystonia" then 118773
--        when "Fever" then 140238
--        when "Flushing" then 140039
--        when "GI upset" then 139581
--        when "Headache" then 139084
--        when "Hepatotoxicity" then 159098
--        when "Hives" then 111061
--        when "Hypertension" then 117399
--        when "Itching" then 879
--        when "Mental status change" then 121677
--        when "Musculoskeletal pain" then 159347
--        when "Myalgia" then 121
--        when "Rash" then 512
--        when "Other" then 5622   else '' end)as Allergies_reactions,
--   (case Allergies_severity
--        when "Mild" then 160754
--        when "Moderate" then 160755
--        when "Severe" then 160756
--        when "Fatal" then 160758
--        when "Unknown" then 1067  else '' end)as Allergies_severity,
  (case Has_Chronic_illnesses_cormobidities
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Has_Chronic_illnesses_cormobidities,
--   (case Chronic_illnesses_name
--        when "Alzheimer's Disease and other Dementias" then 149019
--        when "Arthritis" then 148432
--        when "Asthma" then 153754
--        when "Cancer" then 159351
--        when "Cardiovascular diseases" then 119270
--        when "Chronic hepatitis" then 120637
--        when "Chronic Kidney Disease" then 145438
--        when "Chronic Obstructive Pulmonary Disease (COPD)" then 1295
--        when "Chronic renal failure" then 120576
--        when "Cystic Fibrosis" then 119692
--        when "Deafness and hearing impairment" then 120291
--        when "Diabetes" then 119481
--        when "Endometriosis" then 118631
--        when "Epilepsy" then 117855
--        when "Glaucoma" then 117789
--        when "Heart Disease" then 139071
--        when "Hyperlipidaemia" then 115728
--        when "Hypertension" then 117399
--        when "Hypothyroidism" then 117321
--        when "Mental illness" then 151342
--        when "Multiple Sclerosis" then 133687
--        when "Obesity" then 115115
--        when "Osteoporosis" then 114662
--        when "Sickle Cell Anemia" then 117703
--        when "Thyroid disease" then 118976 else '' end)as Chronic_illnesses_name,
--   Chronic_illnesses_onset_date,
(case Has_adverse_drug_reaction
       when "Yes" then 1065
       when "No" then 1066  else NULL end)as Has_adverse_drug_reaction,
--   (case Medicine_causing_drug_reaction
--        when "Ragweed" then 162541
--        when "Pollen" then 162540
--        when "Mold" then 162539
--        when "Latex" then 162538
--        when "Dust" then 162537
--        when "Bee stings" then 162536
--        when "Adhesive tape" then 162542
--        when "Wheat" then 162177
--        when "Strawberries" then 162548
--        when "Soy" then 162176
--        when "Shellfish" then 162175
--        when "Peanuts" then 162172
--        when "Milk protein" then 162547
--        when "Fish" then 162546
--        when "Eggs" then 162171
--        when "Dairy food" then 162545
--        when "Chocolate" then 162544
--        when "Caffeine" then 72609
--        when "Beef" then 162543
--        when "Zidovudine" then 86663
--        when "Tetracyline" then 84893
--        when "Tenofovir" then 84795
--        when "Sulfonamides" then 162170
--        when "Stavudine" then 84309
--        when "Statins" then 162307
--        when "Rifampin" then 767
--        when "Quinidine" then 83018
--        when "Pyrazinamide" then 82900
--        when "Procainamide" then 82559
--        when "Phenytoin" then 82023
--        when "Phenolphthaleins" then 81959
--        when "Penicillins" then 81724
--        when "Penicillamine" then 81723
--        when "Non-steroidal anti-inflammatory drugs" then 162306
--        when "Nitrofurans" then 158005
--        when "Nevirapine" then 80586
--        when "Morphine" then 80106
--        when "Lopinavir/ritonavir" then 794
--        when "Isoniazid" then 78280
--        when "Hydralazine" then 77675
--        when "Heparins" then 162305
--        when "Griseofulvin" then 77164
--        when "Ethambutol" then 75948
--        when "Erythromycins" then 162302
--        when "Efavirenz" then 75523
--        when "Didanosine" then 74807
--        when "Codeine" then 73667
--        when "Choloroquine" then 73300
--        when "Cephalosporins" then 162301
--        when "Carbamazepine" then 72822
--        when "Atazanavir" then 71647
--        when "Aspirin" then 155175
--        when "ARBs (angiotensin II receptor blockers)" then 162299
--        when "Aminoglycosides" then 155060
--        when "Allopurinol" then 70878
--        when "ACE inhibitors" then 162298
--        when "Abacavir" then 70056
--        when "Other" then 5622 else '' end)as Medicine_causing_drug_reaction,
--   (case Drug_reaction
--        when "Unknown" then 1067
--        when "Anaemia" then 121629
--        when "Anaphylaxis" then 148888
--        when "Angioedema" then 148787
--        when "Arrhythmia" then 120148
--        when "Bronchospasm" then 108
--        when "Cough" then 143264
--        when "Diarrhea" then 142412
--        when "Dystonia" then 118773
--        when "Fever" then 140238
--        when "Flushing" then 140039
--        when "GI upset" then 139581
--        when "Headache" then 139084
--        when "Hepatotoxicity" then 159098
--        when "Hives" then 111061
--        when "Hypertension" then 117399
--        when "Itching" then 879
--        when "Mental status change" then 121677
--        when "Musculoskeletal pain" then 159347
--        when "Myalgia" then 121
--        when "Rash" then 512
--        when "Other" then 5622   else '' end)as Drug_reaction,
--   (case Drug_reaction_severity
--        when "Mild" then 160754
--        when "Moderate" then 160755
--        when "Severe" then 160756
--        when "Fatal" then 160758
--        when "Unknown" then 1067  else '' end)as Drug_reaction_severity,
--   Drug_reaction_onset_date,
--  (case Drug_reaction_action_taken
--        when "CONTINUE REGIMEN" then 1257
--        when "SWITCHED REGIMEN" then 1259
--        when "CHANGED DOSE" then 981
--        when "SUBSTITUTED DRUG" then 1258
--        when "NONE" then 1107
--        when "STOP" then 1260
--        when "OTHER" then 5622  else '' end)as Drug_reaction_action_taken,
   (case Vaccinations_today when "BCG" then 886 else NULL end)as Vaccinations_today_bcg,
   (case Vaccinations_today when "OPV" then 82215 when "IPV" then 82215 else NULL end)as Vaccinations_today_pv,
   (case Vaccinations_today when "Penta" then 1423 else NULL end)as Vaccinations_today_penta,
   (case Vaccinations_today when "Pneumococcal" then 162342 else NULL end)as Vaccinations_today_pcv,
   (case Vaccinations_today when "Measles" then 36 else NULL end)as Vaccinations_today_measles,
   (case Vaccinations_today when "HBV" then 782 else NULL end)as Vaccinations_today_hbv,
   (case Vaccinations_today when "Flu" then 5261 else NULL end)as Vaccinations_today_flu,
--    (case Vaccinations_today when "Rota" then 83531 else NULL end)as Vaccinations_today_rota,
   (case Vaccinations_today when "Other" then 5622 else NULL end)as Vaccinations_today_other,
   Null as Vaccinations_today_other_nc,
   Last_menstrual_period,
  (case Pregnancy_status
       when "Pregnant" then 1065
       when "Not Pregnant" then 1066 else NULL end)as Pregnancy_status,
  (case Wants_pregnancy
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Wants_pregnancy,
--   (case Pregnancy_outcome
--        when "STILLBIRTH" then 125872
--        when "Term birth of newborn" then 1395
--        when "Liveborn, (Single, Twin, or Multiple)" then 151849
--        when "Unknown" then 1067 else '' end)as Pregnancy_outcome,
  Anc_number,
  (case Anc_profile
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Anc_profile,
  Expected_delivery_date,
  Gravida,
  Parity_term,
  Parity_abortion,
  (case Family_planning_status
       when "Family Planning" then 965
       when "No Family Planning" then 160652
       when "Wants Family Planning" then 1360 else NULL end)as Family_planning_status,
--  (case Family_planning_method when "Emergency contraceptive pills" then 160570
--                               when "Oral Contraceptives Pills" then 780
--                               when "Injectible" then 5279
--                               when "Implant" then 1359
--                               when "Intrauterine Device" then 5275
--                               when "Lactational Amenorhea Method" then 136163
--                               when "Diaphram/Cervical Cap"  then 5278
--                               when "Fertility Awareness" then 5277
--                               when "Tubal Ligation"  then 1472
--                               when "Condoms" then 190
--                               when "Vasectomy" then 1489 else "" end) as Family_planning_method,
--  (case Reason_not_using_family_planning when "Not Sexually Active now" then 160573
--        when "Currently Pregnant" then 1434
--        when "Thinks can’t get pregnant" then 160572
--        when "Wants to get pregnant" then 160571 else "" end) as Reason_not_using_family_planning,
--   (case General_examinations_findings when "Oral thrush" then 5334
--        when "Lymph nodes axillary" then 126952
--        when "Finger Clubbing" then 140125
--        when "Pallor" then 5245
--        when "Oedema" then 460
--        when "Lymph nodes inguinal" then 126939
--        when "Dehydration" then 142630
--        when "Lethargic" then 116334
--        when "Jaundice" then 136443
--        when "Cyanosis" then 143050
--        when "Wasting" then 823
--        when "None" then  1107 else "" end) as General_examinations_findings,
--   (case System_review_finding
--        when "Yes" then 1115
--        when "No" then 1116 else '' end)as System_review_finding,
--  (case Skin
--        when "Skin Eruptions/Rashes" then 1249
--        when "Sores" then 1249
--        when "Oral sores" then 5244
--        when "Growths/Swellings" then 125201
--        when "Itching" then 136455
--        when "Abscess" then 150555
--        when "Swelling/Growth" then 125201
--        when "Hair Loss" then 135591
--        when "Kaposi Sarcoma" then 507 else '' end)as Skin,
--   Skin_finding_notes,
--   (case Eyes
--        when "Irritation" then 123074
--        when "Visual Disturbance" then 123074
--        when "Excessive tearing" then 140940
--        when "Eye pain" then 131040
--        when "Eye redness" then 127777
--        when "Light sensitive" then 140827
--        when "Itchy eyes" then 139100 else '' end)as Eyes,
--   Eyes_finding_notes,
--   (case ENT
--        when "Pain" then 160285
--        when "Discharge" then 128055
--        when "Sore Throat" then 158843
--        when "Tinnitus" then 123588
--        when "Apnea" then 117698
--        when "Hearing disorder" then 117698
--        when "Dental caries" then 119558
--        when "Erythema" then 118536
--        when "Frequent colds" then 106
--        when "Gingival bleeding" then 147230
--        when "Hairy cell leukoplakia" then 135841
--        when "Hoarseness" then 138554
--        when "Kaposi Sarcoma" then 507
--        when "Masses" then 152228
--        when "Nasal discharge" then 152228
--        when "Nosebleed" then 133499
--        when "Nasal discharge" then 128055
--        when "Post nasal discharge" then 110099
--        when "Sinus problems" then 126423
--        when "Snoring" then 126318
--        when "Oral sores" then 5244
--        when "Thrush" then 5334
--        when "Toothache" then 124601
--        when "Ulcers" then 123919
--        when "Vertigo" then 111525 else '' end)as ENT,
--   ENT_finding_notes,
--       (case Chest
--        when "Bronchial breathing" then 146893
--        when "Crackles" then 127640
--        when "Dullness" then 145712
--        when "Reduced breathing" then 164440
--        when "Respiratory distress" then 127639
--        when "Wheezing" then 5209 else '' end)as Chest,
--   Chest_finding_notes,
--   (case CVS
--        when "Elevated blood pressure" then 140147
--        when "Irregular heartbeat" then 136522
--        when "Cardiac murmur" then 562
--        when "Cardiac rub" then 130560  else '' end)as CVS,
--   CVS_finding_notes,
--   (case Abdomen
--        when "Abdominal distension" then 150915
--        when "Distension" then 150915
--        when "Hepatomegaly" then 5008
--        when "Abdominal mass" then 5103
--        when "Mass" then 5103
--        when "Splenomegaly" then 5009
--        when "Abdominal tenderness" then 5105
--        when "Tenderness" then 5105 else '' end)as Abdomen,
--   Abdomen_finding_notes,
--  (case CNS
--        when "Altered sensations" then 118872
--        when "Bulging fontenelle" then 1836
--        when "Abnormal reflexes" then 150817
--        when "Confusion" then 120345
--        when "Confused" then 120345
--        when "Limb weakness" then 157498
--        when "Stiff neck" then 112721
--        when "Kernicterus" then 136282 else '' end)as CNS,
--   CNS_finding_notes,
--  (case Genitourinary
--        when "Bleeding" then 147241
--        when "Rectal discharge" then 154311
--        when "Urethral discharge" then 123529
--        when "Vaginal discharge" then 123396
--        when "Ulceration" then 124087 else '' end)as Genitourinary,
--   Genitourinary_finding_notes,
--   Diagnosis,
--   Treatment_plan,
  (case Ctx_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else NULL end)as Ctx_adherence,
  (case Ctx_dispensed
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Ctx_dispensed,
  (case Dapsone_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else NULL end)as Dapsone_adherence,
  (case Dapsone_dispensed
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Dapsone_dispensed,
--   (case Morisky_forget_taking_drugs
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_forget_taking_drugs,
--   (case Morisky_careless_taking_drugs
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_careless_taking_drugs,
--   (case Morisky_stop_taking_drugs_feeling_worse
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_feeling_worse,
--   (case Morisky_stop_taking_drugs_feeling_better
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_feeling_better,
--   (case Morisky_took_drugs_yesterday
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_took_drugs_yesterday,
--   (case Morisky_stop_taking_drugs_symptoms_under_control
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_symptoms_under_control,
--   (case Morisky_feel_under_pressure_on_treatment_plan
--        when "Yes" then 1065
--        when "No" then 1066 else '' end)as Morisky_feel_under_pressure_on_treatment_plan,
--   (case Morisky_how_often_difficulty_remembering
--        when "Sometimes" then 1385
--        when "Once in a while" then 159416
--        when "Never/Rarely" then 1090
--        when "Usually" then 1804
--        when "All the time" then 1358 else '' end)as Morisky_how_often_difficulty_remembering,
  (case Arv_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else NULL end)as Arv_adherence,
  (case Condom_provided
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Condom_provided,
  (case Screened_for_substance_abuse
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Screened_for_substance_abuse,
  (case Pwp_disclosure
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Pwp_disclosure,
  (case Pwp_partner_tested
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Pwp_partner_tested,
  (case Cacx_screening
       when "Yes" then 1065
       when "yes" then 1065
       when "No" then 1066
       when "Never" then 1090
       when "Not Applicable" then 1175 end)as Cacx_screening,
  (case Screened_for_sti
       when "Yes" then 1065
       when "No" then 1066 else NULL end)as Screened_for_sti,
  (case Sti_partner_notification
       when "Yes" then 1065
       when "No" then 1066 when "Never" then 1066 when "N/A" then 1175 else NULL end)as Sti_partner_notification,
  (case Stability
       when "Stable" then 1
       when "Unstable" then 2 else NULL end)as Stability,
  Next_appointment_date,
(case Next_appointment_reason
       when "Follow Up" then 160523
       when "Lab Tests" then 1283
       when "Counseling" then 159382
       when "Pharmacy Refill" then 160521
       when "Treatment Preparation" then 159382
       when "ART Fast Track Referral" then 160521
       when "Other" then 5622 else NULL end)as Next_appointment_reason,
--   (case Appointment_type
--        when "Standard Care" then 164942
--        when "Express Care" then 164943
--        when "Fast Track" then 164943
--        when "Facility ART Distribution Group" then 164946
--        when "Community Based Dispensing" then 164944
--        when "Community ART Distribution - HCW Led" then 164944
--        when "Community ART Distribution - Peer Led" then 164945
--        when "Other" then 5622 else '' end)as Appointment_type,
  (case Differentiated_care
       when "Yes" then 164947
       when "No" then 164942 else NULL end)as Differentiated_care,
  Voided
 FROM migration_st.st_hiv_followup WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 18. Laboratory Extract transformed table
DROP TABLE IF EXISTS migration_tr.tr_laboratory;
CREATE TABLE migration_tr.tr_laboratory
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      LabTestName,
      Test_result,
      Date_test_requested ,
      Date_test_result_received ,
      OrderNumber,
      Urgency,
      (case Lab_test
       when "CD4" then 5497
       when "CD4PERCENT" then 730
       when "VIRALLOAD" then 856
       when "VIRALLOADUNDETECTABLE" then 1305
       when "HCT" then 1015
       when "HB" then 21
       when "WBC" then 678
       when "WBCDIFF" then 1026
       when "WBCDIFF_NEUT" then 1022
       when "WBCDIFF_NEUT%" then 1336
       when "WBCDIFF_LYMPH" then 1021
       when "WBCDIFF_LYMPH%" then 1338
       when "WBCDIFF_MONO" then 1023
       when "WBCDIFF_MONO%" then 1339
       when "WBCDIFF_EOSIN" then 1024
       when "WBCDIFF_EOSIN%" then 1340
       when "PLATELETS" then 729
       when "AST_SGOT" then 653
       when "ALT_SGPT" then 654
       when "CREATININE" then 790
       when "CREATININEMM" then 164364
       when "AMYLASE" then 1299
       when "PREGNANCY" then 1945
       when "MALARIA" then 32
       when "SERUMCRYPTO" then 163613
       when "SPUTUMAFB1" then 159866
       when "SPUTUMAFB2" then 159867
       when "SPUTUMAFB3" then 159869
       when "SPUTUMGRAMSTAIN" then 1367
       when "URINALYSIS" then 302
       when "URINALYSIS_SPECGRAV" then 161439
       when "URINALYSIS_GLUCOSE" then 159734
       when "URINALYSIS_KETONE" then 161442
       when "URINALYSIS_PROTEIN" then 163684
       when "URINALYSIS_LEUKEST" then 135850
       when "URINALYSIS_NITRATE" then 161440
       when "URINALYSIS_BLOOD" then 162096
       when "URINALYSISMICROSCOPICBLOOD" then 134191
       when "URINALYSISMICROSCOPICWBC" then 163684
       when "URINALYSISMICROSCOPICBACTERIA" then 163683
       when "URINALYSISMICROSCOPICCASTS" then 163696
       when "CULTURESENSITIVITY" then 161156
       when "STOOL" then 161451
       when "URINECULTURE_SENSIVITY" then 161156
       when "CSFCRYPTO" then 163613
       when "CSFCULTURE" then 159648
       when "CSFBIOCHEMISTRY" then 159645
       when "GLUCOSEMG" then 159647
       when "GLUCOSEMM" then 159647
       when "ESR" then 855
       when "CELLCOUNTNEUTROPHILS" then 1330
       when "CELLCOUNTLYMPHOCYTES" then 952
       when "PROTEIN" then 848
       when "PROTEINMG" then 848
       when "PROTEINMM" then 848
       when "HIVRAPIDTEST" then 163722
       when "CSFBIOCHEMISTRY_GLUCOSE" then 159647
       when "CELLCOUNTRBCS" then 679
       when "RBC" then 679
       when "CELLCOUNTWBCS" then 678
       when "ALBUMIN_MG_DL_" then 848
       when "COLPOSCOPY_CERVICALCA_FEMALEONLY_" then 160705
       when "CYTOMEGALOVIRUS_CMV_" then 161232
       when "HDL_MG_DL_" then 1007
       when "HEPATITISBSURFACE_ANTIGEN_HBSAG_" then 159430
       when "LDL_MG_DL_" then 1008
       when "PAPSMEAR_CERVICALCA_FEMALEONLY_" then 885
       when "GONORRHEA" then 1036
       when "RECTALPAPSMEAR" then 885
       when "SYPHILIS_FTA_" then 1031
       when "SYPHILIS_RPR_" then 1619
       when "TOTALCHOLESTEROL_MG_DL_" then 1006
       when "TOXOPLASMAIGGANTIBODY" then 160708
       when "TRIGLYCERIDES_MG_DL_" then 1009
       when "VAGINALINSPECTIONWITHACETICACID_VIA_" then 164805
       when "HEPATITISCANTIBODY" then 161471
       when "HIVCONFIRM" then 103
       when "PCR" then 844
       when "RDT" then 1643
       when "MPS" then 32
       when "SPECIES_REPORT" then 33
       when "CAS" then 32
       when "SAFB" then 308
       when "QBL" then 309
       when "GeneXpert" then 162202
       else NULL end)as Lab_test,
      CD4 ,
      CD4PERCENT,
      VIRALLOAD,
      VIRALLOADUNDETECTABLE,
      STOREPLASMA,
      HCT ,
      HB  ,
      WBC ,
      WBCDIFF,
      WBCDIFF_NEUT,
      WBCDIFF_NEUT_PERCENT,
      WBCDIFF_LYMPH,
      WBCDIFF_LYMPH_PERCENT,
      WBCDIFF_MONO,
      WBCDIFF_MONO_PERCENT,
      WBCDIFF_EOSIN,
      WBCDIFF_EOSIN_PERCENT,
      PLATELETS,
      AST_SGOT,
      ALT_SGPT,
      CREATININE,
      CREATININEMM,
      AMYLASE,
      PREGNANCY,
      MALARIA,
      SERUMCRYPTO,
      SPUTUMAFB1,
      SPUTUMAFB2,
      SPUTUMAFB3,
      SPUTUMGRAMSTAIN,
      URINALYSIS,
      STOOLSTATUS,
      URINALYSIS_SPECGRAV,
      URINALYSIS_GLUCOSE,
      URINALYSIS_KETONE,
      URINALYSIS_PROTEIN,
      URINALYSIS_LEUKEST,
      URINALYSIS_NITRATE,
      URINALYSIS_BLOOD,
      URINALYSISMICROSCOPICBLOOD,
      URINALYSISMICROSCOPICWBC,
      URINALYSISMICROSCOPICBACTERIA,
      URINALYSISMICROSCOPICCASTS,
      CULTURESENSITIVITY,
      STOOL   ,
      URINECULTURE_SENSIVITY,
      CSFCRYPTO,
      CSFINDIAINK,
      CSFGRAMSTAIN,
      CSFCULTURE,
      CSFBIOCHEMISTRY,
      GLUCOSEMG,
      GLUCOSEMM,
      ESR     ,
      CELLCOUNTNEUTROPHILS,
      CELLCOUNTLYMPHOCYTES,
      PROTEIN  ,
      PROTEINMG,
      PROTEINMM,
      HIVRAPIDTEST,
      CSFBIOCHEMISTRY_GLUCOSE,
      CELLCOUNTRBCS,
      RBC      ,
      CELLCOUNTWBCS,
      ALBUMIN_MG_DL_,
      COLPOSCOPY_CERVICALCA_FEMALEONLY_,
      CYTOMEGALOVIRUS_CMV_,
      EPSTEINBARRVIRUS_EBV_,
      HDL_MG_DL_ ,
      HEPATITISAAB_TOTAL,
      HEPATITISAAB_IGM,
      HEPATITISBCORE_ANTIBODYIGM_HBSAB_,
      HEPATITISBCORE_ANTIBODY_TOTAL,
      HEPATITISBSURFACE_ANTIBODY_HBSAB_,
      HEPATITISBSURFACE_ANTIGEN_HBSAG_,
      LDL_MG_DL_ ,
      PAPSMEAR_CERVICALCA_FEMALEONLY_,
      GONORRHEA   ,
      CHLAMYDIA   ,
      RECTALPAPSMEAR,
      SYPHILIS_FTA_,
      SYPHILIS_RPR_,
      TOTALCHOLESTEROL_MG_DL_,
      TOXOPLASMAIGGANTIBODY,
      TRIGLYCERIDES_MG_DL_,
      VAGINALINSPECTIONWITHACETICACID_VIA_,
      VARICELLA_CHICKENPOX_,
      HEPATITISCANTIBODY,
      HIVCONFIRM ,
      PCR,
      RDT,
      MPS,
      SPECIES_REPORT,
      CAS,
      SAFB,
      QBL,
      GeneXpert,
      Voided
    FROM migration_st.st_laboratory WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 18A. Laboratory Extract VL transformed table
DROP TABLE IF EXISTS migration_tr.tr_vital_labs_vl;
CREATE TABLE migration_tr.tr_vital_labs_vl
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      LabTestName,
      Test_result,
      Date_test_requested ,
      Date_test_result_received ,
      OrderNumber,
      Urgency,
      (case Lab_test
        when "VIRALLOAD" then 856
       else NULL end)as Lab_test,
       VIRALLOAD
    FROM migration_st.st_laboratory WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    AND Lab_test = "VIRALLOAD"
  GROUP BY Person_Id, Encounter_Date;

-- 18B. Laboratory Extract CD4 transformed table
DROP TABLE IF EXISTS migration_tr.tr_vital_labs_cd4;
CREATE TABLE migration_tr.tr_vital_labs_cd4
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      LabTestName,
      Test_result,
      Date_test_requested ,
      Date_test_result_received ,
      OrderNumber,
      Urgency,
      (case Lab_test
       when "CD4" then 5497
       else NULL end)as Lab_test,
      CD4
    FROM migration_st.st_laboratory WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    AND Lab_test = "CD4"
  GROUP BY Person_Id, Encounter_Date;

  -- 18C. Laboratory Extract CD4 PERCENT transformed table
DROP TABLE IF EXISTS migration_tr.tr_vital_labs_cd4_percent;
CREATE TABLE migration_tr.tr_vital_labs_cd4_percent
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      LabTestName,
      Test_result,
      Date_test_requested ,
      Date_test_result_received ,
      OrderNumber,
      Urgency,
      (case Lab_test
       when "CD4PERCENT" then 730
       else NULL end)as Lab_test,
      CD4PERCENT
      FROM migration_st.st_laboratory WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    AND Lab_test = "CD4PERCENT"
  GROUP BY Person_Id, Encounter_Date;

-- 18D. Laboratory Extract Vital transformed table
DROP TABLE IF EXISTS migration_tr.tr_vital_labs;
CREATE TABLE migration_tr.tr_vital_labs
    select
      Person_Id,
      Encounter_Date,
      Encounter_ID,
      LabTestName,
      Test_result,
      Date_test_requested ,
      Date_test_result_received ,
      OrderNumber,
      Urgency,
      (case Lab_test
        when "VIRALLOAD" then 856
		    when "CD4" then 5497
		    when "CD4PERCENT" then 730
            else NULL end)as Lab_test
    FROM migration_st.st_laboratory WHERE (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
    AND Lab_test in("VIRALLOAD","CD4","CD4PERCENT")
  GROUP BY Person_Id, Encounter_Date;
-- 19. Create Pharmacy Extract


-- 20. Create mch enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_mch_enrollment;
CREATE TABLE migration_tr.tr_mch_enrollment as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Anc_number,
    Parity,
    Parity_abortion,
    Gravida,
    EDD,
    Age_at_menarche,
    (case TB_screening_results
     when "No TB" then 1660
     when "PrTB" then 142177
     when "TBRx" then 1662
     when "Not Done" then 1118  else NULL end)as TB_screening_results,
    LMP,
    (case Hiv_status
     when "U" then 1067
     when "Negative" then 664
     when "Positive" then 703
     when "KP" then 703  when "N/A" then 1175 else NULL end) as Hiv_status,
    (case Partner_hiv_status
     when "Negative" then 664
     when "Positive" then 703
     when "Unknown" then 1067 else NULL end) as Partner_hiv_status,
    (case Syphilis_test_status
     when "yes" then 1065
     when "No" then 1066
     when "Positive" then 703
     when "Negative" then 664
     when "REACTIVE" then 1228
     when "NON-REACTIVE" then 1229
     when "POOR SAMPLE QUALITY" then 1304
     when "N/A" then 1175 else NULL end) as Syphilis_test_status,
    (case Bs_for_mps
     when "NEGATIVE" then 664
     when "POSITIVE" then 703
     when "INDETERMINATE" then 1138  else NULL end) as Bs_for_mps,
    (case Blood_group when "A POSITIVE" then 690 when "A NEGATIVE" then 692 when "B POSITIVE" then 694 when "B NEGATIVE" then 696 when "O POSITIVE" then 699
       when "O NEGATIVE" then 701 when "AB POSITIVE" then 1230 when "AB NEGATIVE" then 1231 else NULL end) as Blood_group,
    Urine_microscopy,
    (case Urinary_albumin
      when "Negative" then 664
      when "Trace - 15" then 1874
      when "One Plus(+) - 30" then 1362
      when "Two Plus(++) - 100" then 1363
      when "Three Plus(+++) - 300" then 1364
      when "Four Plus(++++) - 1000" then 1365 else "" end) as Urinary_albumin,
    (case Glucose_measurement
       when "Normal" then 1115
       when "Trace" then 1874
       when "One Plus(+)" then 1362
       when "Two Plus(++)" then 1363
       when "Three Plus(+++)" then 1364
       when "Four Plus(++++)" then 1365 else NULL end) as Glucose_measurement,
    Urine_ph,
    Urine_gravity,
    (case Urine_nitrite_test
      when "NEGATIVE" then 664
      when "POSITIVE" then 703
      when "One Plus(+)" then 1362
      when "Two Plus(++)" then 1363 else NULL end) as Urine_nitrite_test,
    (case Urine_leukocyte_esterace_test
       when "NEGATIVE" then 664
       when "Trace"  then 1874
       when "One Plus(+)" then 1362
       when "Two Plus(++)" then 1363
       when "Three Plus(+++)" then 1364 else NULL end) as Urine_leukocyte_esterace_test,
    (case Urinary_ketone
        when "NEGATIVE" then 664
        when "Trace - 5" then 1874
        when "One Plus(+) - 15" then 1362
        when "Two Plus(++) - 50" then 1363
        when "Three Plus(+++) - 150" then 1364  else NULL end) as Urinary_ketone,
    (case Urine_bile_salt_test
        when "Normal" then 1115
        when "Trace - 1"  then 1874
        when "One Plus(+) - 4" then 1362
        when "Two Plus(++) - 8" then 1363
        when "Three Plus(+++) - 12" then 1364 else NULL end) as Urine_bile_salt_test,
    (case Urine_bile_pigment_test
        when "NEGATIVE" then 664
        when "One Plus(+)" then 1362
        when "Two Plus(++)" then 1363
        when "Three Plus(+++)" then 1364 else NULL end) as Urine_bile_pigment_test,
    (case Urine_colour
         when "Colourless" then 162099
         when "Red color" then 127778
         when "Light yellow colour" then 162097
         when "Yellow-green colour" then 162105
         when "Dark yellow colour" then 162098
         when "Brown color" then 162100 else NULL end) as Urine_colour,
    (case Urine_turbidity
         when "Urine appears clear" then 162102
         when "Cloudy urine" then 162103
         when "Urine appears turbid" then 162104 else NULL end) as Urine_turbidity,
    (case Urine_dipstick_for_blood
         when "NEGATIVE"  then 664
         when "Trace" then 1874
         when "One Plus(+)" then 1362
         when "Two Plus(++)" then 1363
         when "Three Plus(+++)" then 1364 else NULL end) as Urine_dipstick_for_blood,
    Voided
  FROM migration_st.st_mch_enrollment_visit WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 21. Create mch visit transformed table
DROP TABLE IF EXISTS migration_tr.tr_mch_anc_visit;
CREATE TABLE migration_tr.tr_mch_anc_visit as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Anc_visit_number,
    Anc_number,
    Temperature,
    Pulse_rate,
    Systolic_bp,
    Diastolic_bp,
    Respiratory_rate,
    Oxygen_saturation,
    Weight,
    Height,
    Muac,
    Hemoglobin,
    (case Breast_exam_done
     when "yes" then 1065
     when "No" then 1066  when "N/A" then 1175 else NULL end) as Breast_exam_done,
    Pallor,
    Maturity,
    Fundal_height,
    Fetal_presentation,
    Lie,
    Fetal_heart_rate,
    Fetal_movement,
    (case Who_stage when "Stage1" then 1204
     when "Stage2" then 1205
     when "Stage3" then 1206
     when "Stage4" then 1207 else NULL end )as Who_stage,
    (case Viral_load_sample_taken
     when "yes" then 1065
     when "No" then 1066  when "N/A" then 1175 else NULL end) as Viral_load_sample_taken,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end) as Test_1_Kit_Name,
    Test_1_kit_lot_no,
    Test_1_kit_expiry,
    (case Test_1_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_1_Result,
    (case Test_2_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end)as  Test_2_Kit_Name,
    Test_2_kit_lot_no,
    Test_2_kit_expiry,
    (case Test_2_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_2_Result,
    (case  Final_test_result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Final_test_result,
    (case Patient_given_result
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Patient_given_result,
    (case Partner_tested
     when "Yes" then 1065
     when "No" then 1066  when "N/A" then 1175 else NULL end) as  Partner_tested,
    (case Partner_hiv_status
     when "Negative" then 664
     when  "Positive" then 703
     when "Unknown" then 1067 else NULL end) as Partner_hiv_status,
    Urine_microscopy,
    (case Urinary_albumin
      when "Negative" then 664
      when "Trace - 15" then 1874
      when "One Plus(+) - 30" then 1362
      when "Two Plus(++) - 100" then 1363
      when "Three Plus(+++) - 300" then 1364
      when "Four Plus(++++) - 1000" then 1365 else "" end) as Urinary_albumin,
    (case Glucose_measurement
       when "Normal" then 1115
       when "Trace" then 1874
       when "One Plus(+)" then 1362
       when "Two Plus(++)" then 1363
       when "Three Plus(+++)" then 1364
       when "Four Plus(++++)" then 1365 else NULL end) as Glucose_measurement,
    Urine_ph,
    Urine_gravity,
    (case Urine_nitrite_test
      when "NEGATIVE" then 664
      when "POSITIVE" then 703
      when "One Plus(+)" then 1362
      when "Two Plus(++)" then 1363 else NULL end) as Urine_nitrite_test,
    (case Urine_leukocyte_esterace_test
       when "NEGATIVE" then 664
       when "Trace"  then 1874
       when "One Plus(+)" then 1362
       when "Two Plus(++)" then 1363
       when "Three Plus(+++)" then 1364 else NULL end) as Urine_leukocyte_esterace_test,
    (case Urinary_ketone
        when "NEGATIVE" then 664
        when "Trace - 5" then 1874
        when "One Plus(+) - 15" then 1362
        when "Two Plus(++) - 50" then 1363
        when "Three Plus(+++) - 150" then 1364  else NULL end) as Urinary_ketone,
    (case Urine_bile_salt_test
        when "Normal" then 1115
        when "Trace - 1"  then 1874
        when "One Plus(+) - 4" then 1362
        when "Two Plus(++) - 8" then 1363
        when "Three Plus(+++) - 12" then 1364 else NULL end) as Urine_bile_salt_test,
    (case Urine_bile_pigment_test
        when "NEGATIVE" then 664
        when "One Plus(+)" then 1362
        when "Two Plus(++)" then 1363
        when "Three Plus(+++)" then 1364 else NULL end) as Urine_bile_pigment_test,
    (case Urine_colour
         when "Colourless" then 162099
         when "Red color" then 127778
         when "Light yellow colour" then 162097
         when "Yellow-green colour" then 162105
         when "Dark yellow colour" then 162098
         when "Brown color" then 162100 else NULL end) as Urine_colour,
    (case Urine_turbidity
         when "Urine appears clear" then 162102
         when "Cloudy urine" then 162103
         when "Urine appears turbid" then 162104 else NULL end) as Urine_turbidity,
    (case Urine_dipstick_for_blood
         when "NEGATIVE"  then 664
         when "Trace" then 1874
         when "One Plus(+)" then 1362
         when "Two Plus(++)" then 1363
         when "Three Plus(+++)" then 1364 else NULL end) as Urine_dipstick_for_blood,
    (case Syphilis_test_status
     when "No" then 1066
     when "yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Syphilis_test_status,
    (case Syphilis_treated_status
     when "Positive" then 703
     when "Negative" then 664
     when "Not Done" then 1118  else NULL end)as  Syphilis_treated_status,
    Bs_for_mps,
   (case Anc_exercises
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Anc_exercises,
    (case TB_screening_results
     when "No TB" then 1660
     when "PrTB" then 142177
     when "TBRx" then 1662
     when "Not Done" then 1118  else NULL end)as TB_screening_results,
    (case Cacx_screening
     when "No" then 1066
     when "yes" then 1066
     when "Confirmed" then 703
     when "Suspected" then 159393
     when "N/A" then 1175
     when "Normal" then 664
     when "Never" then 1090
     when "Not Done" then 1118 end)as Cacx_screening,
    (case Cacx_screening_method
     when "Pap Smear" then 885
     when "VIA" then 162816
     when "VIA/VILI" then 162816
     when "VILI" then 164977
     when "Other" then 5622
     when "Not Done" then 1118
     when "Not Applicable" then 1175 end)as Cacx_screening_method,
    (case Prophylaxis_given
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Prophylaxis_given,
    (case Baby_azt_dispensed
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else NULL end)as  Baby_azt_dispensed,
   (case Baby_nvp_dispensed
    when "No" then 1066
    when "Yes" then 1065
    when "N/A" then 1175  else NULL end)as  Baby_nvp_dispensed,
    (case Has_other_illnes
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Has_other_illnes,
    (case Drug
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Drug,
    (case Anc_counselled
     when "NO" then 1066
     when "YES" then 1065
     when "Unknown" then 1067  else NULL end)as  Anc_counselled,
    (case Counselled_subject
     when "Birth Plans" then 159758
     when "Danger Signs" then 159857
     when "HIV" then 1914
     when "Infant Feeding" then 161651
     when "Family Planning" then 156277
     when "Insecticide Treated Nets" then 1381
     when "Supplimental feeding" then 159854
     when "Breast Care" then 159856
     when "Unknown" then 1067  else NULL end)as  Counselled_subject,
    Referred_from,
    Referred_to,
    Next_appointment_date,
    Clinical_notes,
    Voided
  FROM migration_st.st_mch_enrollment_visit WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;


-- 22. Create mch delivery transformed table

DROP TABLE IF EXISTS migration_tr.tr_mch_delivery;
CREATE TABLE migration_tr.tr_mch_delivery as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  Admission_number,
  Gestation_Weeks,
  Duration_Labour,
(case Delivery_Mode
    when "SVD" then 1170
    when "Caesarean section" then 1171
    when "Breech" then 1172
    when "Assisted Vaginal Delivery" then 118159
    when "Other" then 5622 else NULL end) as Delivery_Mode,
  Delivery_Date_TIme,
  (case Placenta_Complete
        when "Yes" then 1065
        when "No" then 1066
        when "Unknown" then 1067 else NULL end) as Placenta_Complete,
  (case Blood_Loss
      when "Medium" then 1499
      when "None" then 1107
      when "Light" then 1498
      when "Heavy" then 1500 else NULL end) as Blood_Loss,
  (case Mother_Condition
      when "Alive" then 160429
      when "Dead" then 134612 else NULL end) as Mother_Condition,
  Death_Audited,
  (case Resuscitation_Done
        when "Yes" then 1065
        when "No" then 1066
        when "Unknown" then 1067 else NULL end) as Resuscitation_Done,
  Delivery_Complications,
  Delivery_Complications_Type,
  Delivery_Complications_Other,
 (case Delivery_Place
      when "Home" then 1536
      when "Health Facility" then 1588
      when "Other" then 5622
      when "Unknown" then 1067 else NULL end) as Delivery_Place,
  Delivery_Conducted_By,
  Delivery_Cadre,
  Delivery_Outcome,
  Baby_Name,
 (case Baby_Sex
      when "Male" then 1534
      when "Female" then  1535 else NULL end) as Baby_Sex,
  Baby_Weight,
  (case Baby_Condition
   when "Alive" then 151849
   when "Dead" then 125872  else NULL end) as Baby_Condition,
  (case Birth_Deformity
      when "Yes" then 155871
      when "No" then 1066
      when "Not applicable" then 1175  else NULL end) as Birth_Deformity,
  (case TEO_Birth
      when "Yes" then 84893
      when "No" then 1066
      when "Not applicable" then 1175 else NULL end) as TEO_Birth,
  (case BF_At_Birth_Less_1_hr
      when "Yes" then 1065
      when "No" then 1066 else NULL end) as BF_At_Birth_Less_1_hr,
  Apgar_1,
  Apgar_5,
  Apgar_10,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end) as Test_1_Kit_Name,
    Test_1_kit_lot_no,
    Test_1_kit_expiry,
    (case Test_1_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_1_Result,
    (case Test_2_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else NULL end)as  Test_2_Kit_Name,
    Test_2_kit_lot_no,
    Test_2_kit_expiry,
    (case Test_2_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Test_2_Result,
    (case  Final_test_result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else NULL end)as  Final_test_result,
    (case Patient_given_result
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Patient_given_result,
    (case Partner_hiv_tested
     when "Yes" then 1065
     when "No" then 1066  when "N/A" then 1175 else NULL end) as  Partner_hiv_tested,
    (case Partner_hiv_status
     when "Negative" then 664
     when  "Positive" then 703
     when "Unknown" then 1067 else NULL end) as Partner_hiv_status,
  (case Syphilis_Treated
     when "Positive" then 703
     when "Negative" then 664
     when "Not Done" then 1118  else NULL end) as  Syphilis_Treated,
 (case Prophylaxis_given
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Prophylaxis_given,
 (case Baby_azt_dispensed
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else NULL end)as  Baby_azt_dispensed,
 (case Baby_nvp_dispensed
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else NULL end)as  Baby_nvp_dispensed,
  Clinical_notes,
  Next_Appointment_Date,
  Voided
FROM migration_st.st_mch_delivery_discharge  WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 23. Create mch discharge transformed table

DROP TABLE IF EXISTS migration_tr.tr_mch_discharge;
CREATE TABLE migration_tr.tr_mch_discharge as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  Discharge_Date,
 (case Vitamin_A_Supplimentation
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Vitamin_A_Supplimentation,
  (case Counselled_Infant_Feeding
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Counselled_Infant_Feeding,
  (case Baby_Status_On_Discharge
     when "Alive" then 163016
     when "Dead" then 160432
     when "Unknown" then 1067  else NULL end)as  Baby_Status_On_Discharge,
  Mother_Status_On_Discharge,
  Birth_Notification_Number,
  Referred_From,
  Referred_To,
  Clinical_notes,
  Next_Appointment_Date,
  Voided
  FROM migration_st.st_mch_delivery_discharge WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 24. Create mch pnc transformed table

  DROP TABLE IF EXISTS migration_tr.tr_mch_pnc_visit;
  CREATE TABLE migration_tr.tr_mch_pnc_visit as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  PNC_Register_number,
  PNC_VisitNumber,
  Delivery_Date,
  Mode_Of_Delivery,
  Place_Of_delivery,
  Temperature,
  Pulse_rate,
  Systolic_bp,
  Diastolic_bp,
  Respiratory_rate,
  Oxygen_saturation,
  Weight,
  Height,
  BMI,
  Muac,
  General_Condition,
  (case Pallor
     when "Pallor" then 1065
     when "No" then 1066
     when "Unknown" then 1067  else NULL end)as  Pallor,
  (case Breast_Examination
     when "Mastitis" then 115915
     when "Engorged" then 127522
     when "Cracked" then 143242
     when "Normal" then 1115
     when "Unknown" then 1067  else NULL end)as  Breast_Examination,
  (case PPH
     when "PostPartumHaemorrhage" then 1065
     when "No" then 1066
     when "Unknown" then 1067  else NULL end)as  PPH,
  (case CS_Scar
     when "Infected" then 156794
     when "Gaping" then 145776
     when "Bleeding" then 145776
     when "Normal" then 162129
     when "N/A" then 1175
     when "Unknown" then 1067  else NULL end)as  CS_Scar,
  Haemoglobin,
 (case Involution_Of_Uterus
     when "Not Contracted" then 162111
     when "Contracted" then 123427
     when "Other" then 5622
     when "Other (Specify)" then 5622
     when "N/A" then 1175
     when "Unknown" then 1067  else NULL end)as  Involution_Of_Uterus,
 (case Condition_Of_Episiotomy
     when "Healed" then 159843
     when "Infected" then 113919
     when "Gaping" then 159841
     when "Repaired" then 159842
     when "N/A" then 1175
     when "Unknown" then 1067  else NULL end)as  Condition_Of_Episiotomy,
 (case Lochia
     when "Excessive" then 159845
     when "Foul smelling" then 159846
     when "Normal" then 159721
     when "Unknown" then 1067  else NULL end)as  Lochia,
(case Counselling_On_Infant_Feeding
     when "Yes" then 1065
     when "No" then 1066
     when "N/A" then 1175
     when "Unknown" then 1067  else NULL end)as  Counselling_On_Infant_Feeding,
  Counselling_On_FamilyPlanning,
  Delivery_outcome,
 (case Baby_Condition
     when "Unwell" then 162132
     when "Well" then 1855
     when "Unknown" then 1067  else NULL end)as  Baby_Condition,
  Feeding_Method,
  Umblical_Cord,
  Immunization_Started,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else '' end) as Test_1_Kit_Name,
    Test_1_kit_lot_no,
    Test_1_kit_expiry,
    (case Test_1_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else '' end)as  Test_1_Result,
    (case Test_2_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else '' end)as  Test_2_Kit_Name,
    Test_2_kit_lot_no,
    Test_2_kit_expiry,
    (case Test_2_Result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else '' end)as  Test_2_Result,
    (case  Final_test_result
     when "Positive" then 703
     when "Negative" then 664
     when "Inconclusive" then 1138  else '' end)as  Final_test_result,
    (case Patient_given_result
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Patient_given_result,
    (case Partner_hiv_tested
     when "Yes" then 1065
     when "No" then 1066  when "N/A" then 1175 else '' end) as  Partner_hiv_tested,
    (case Partner_hiv_status
     when "Negative" then 664
     when  "Positive" then 703
     when "Unknown" then 1067 else '' end) as Partner_hiv_status,
    (case Prophylaxis_given
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else '' end)as  Prophylaxis_given,
    (case Baby_azt_dispensed
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else '' end)as  Baby_azt_dispensed,
    (case Baby_nvp_dispensed
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else '' end)as  Baby_nvp_dispensed,
  (case Pnc_exercises
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else '' end)as  Pnc_exercises,
  Maternal_condition,
 (case Iron_supplementation
     when "No" then 1066
     when "Yes" then 1065
     when "N/A" then 1175  else '' end)as  Iron_supplementation,
    (case Cacx_screening
     when "No" then 1066
     when "yes" then 1066
     when "Confirmed" then 703
     when "Suspected" then 159393
     when "N/A" then 1175
     when "Normal" then 664
     when "Never" then 1090
     when "Not Done" then 1118 end)as Cacx_screening,
    (case Cacx_screening_method
     when "Pap Smear" then 885
     when "VIA" then 162816
     when "VIA/VILI" then 162816
     when "VILI" then 164977
     when "Other" then 5622
     when "Not Done" then 1118
     when "Not Applicable" then 1175 end)as Cacx_screening_method,
  Fistula_screening,
  (case On_FP
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else '' end)as  On_FP,
  (case FP_Method
     when "Vasectomy" then 1489
     when "Tubal Ligation /Female Sterilization" then 1472
     when "Fertility Awareness Method" then 5277
     when "Diaphragm/Cervical Cap" then 5278
     when "Lactational Amenorrhea Method" then 136163
     when "Intra Uterine Device" then 5275
     when "Implant" then 1359
     when "Injectable" then 5279
     when "Oral Contraceptive Pills" then 780
     when "Emergency Contraceptive Pills" then 160570
     when "Condoms" then 190
     when "Unknown" then 1067  else '' end)as  FP_Method,
  Referred_From,
  Referred_To,
  Clinical_notes,
  Next_Appointment_Date
  FROM migration_st.st_mch_pnc_visit WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

  -- 25. Create hei enrollments transformed table

DROP TABLE IF EXISTS migration_tr.tr_hei_enrollment;
CREATE TABLE migration_tr.tr_hei_enrollment as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Gestation_at_birth,
    Birth_weight,
    Child_exposed,
    Hei_id_number,
    Spd_number,
    Birth_length,
    Birth_order,
    Birth_type,
  (case Place_of_delivery
     when "Home" then 1536
     when "Health Facility" then 1589
     when "Other" then 5622
     when "Unknown" then 1067 else NULL end) as Place_of_delivery,
   (case Mode_of_delivery
    when "SVD" then 1170
    when "Caesarean section" then 1171
    when "Breech" then 1172
    when "Assisted Vaginal Delivery" then 118159
    when "Other" then 5622
    when "Unknown" then 1067  else NULL end) as  Mode_of_delivery,
    Birth_notification_number,
    Date_birth_notification_number_issued,
    Birth_certificate_number,
    Date_first_enrolled_in_hei_care,
    Birth_registration_place,
    Birth_registration_date,
    Mothers_name,
    Fathers_name,
    Guardians_name,
    Community_HealthWorkers_name,
    Alternative_Contact_name,
    Contacts_For_Alternative_Contact,
    Need_for_special_care,
    Reason_for_special_care,
    (case TB_contact_history_in_household
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  TB_contact_history_in_household,
    Mother_alive,
    (case Mother_breastfeeding
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Mother_breastfeeding,
    Referral_source,
    Transfer_in,
    Transfer_in_date,
    Facility_transferred_from,
    District_transferred_from,
    Mother_on_NVP_during_breastfeeding,
    Infant_mother_link,
   (case Mother_on_pmtct_drugs
     when "HAART" then 1065
     when "None" then 1066
     when "Other" then 1065
     when "Unknown" then 1067  else NULL end)as  Mother_on_pmtct_drugs,
   (case Mother_on_pmtct_drugs_regimen
      when "PM 8 SD Nevirapine (NVP)" then 80586
      when "PM1 AZT from 14Wks" then 86663
      when "PM 9 TDF + 3TC + EFV"  then 164505
      when "PM2 NVP stat + AZT stat"  then 1652
      when "PM3 AZT + 3TC + NVP"  then 1652
      when "PM4 AZT + 3TC + EFV"  then 160124
      when "PM 10 AZT + 3TC + ATV/r"  then 164511
      when "PM 7 TDF + 3TC + LPV/r"  then 162201
      when "PM 6 TDF + 3TC + NVP"  then 162565
      when "PM 10 AZT + 3TC + ATV/r"  then 164511
      when "PM 11 TDF + 3TC + ATV/r"  then 164512 else NULL end) as Mother_on_pmtct_drugs_regimen,
    Mother_on_pmtct_other_regimen,
  (case Mother_on_art_at_infant_enrollment
     when "No" then 1066
     when "Yes" then 1065
     when "Unknown" then 1067  else NULL end)as  Mother_on_art_at_infant_enrollment,
  (case Mother_drug_regimen
     when "PM 8 SD Nevirapine (NVP)" then 80586
     when "PM1 AZT from 14Wks" then 86663
     when "PM 9 TDF + 3TC + EFV"  then 164505
     when "PM2 NVP stat + AZT stat"  then 1652
     when "PM3 AZT + 3TC + NVP"  then 1652
     when "PM4 AZT + 3TC + EFV"  then 160124
     when "PM 10 AZT + 3TC + ATV/r"  then 164511
     when "PM 7 TDF + 3TC + LPV/r"  then 162201
     when "PM 6 TDF + 3TC + NVP"  then 162565
     when "PM 10 AZT + 3TC + ATV/r"  then 164511
     when "PM 11 TDF + 3TC + ATV/r"  then 164512 else NULL end) as Mother_drug_regimen,
   (case Infant_prophylaxis
     when "AZT liquid BID for 12 weeks" then 160123
     when "NVP liquid OD for 12 weeks" then 80586
     when "AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks" then 1652
     when "Other" then 5622
     when "None" then 1107  else NULL end)as  Infant_prophylaxis,
    Infant_prophylaxis_other,
    Mother_ccc_number,
    Voided
  FROM migration_st.st_hei_enrollment WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

  -- 26. Create HEI followup transformed table

DROP TABLE IF EXISTS migration_tr.tr_hei_followup;
CREATE TABLE migration_tr.tr_hei_followup as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Weight,
    Height,
    (case Primary_care_give
       when "Mother" then 970
       when "Father" then 971
       when "Unknown" then 1067 else NULL end) as Primary_care_give,
    (case Infant_feeding
           when "Breast Feeding (EBF)" then 5526
           when "Exclusive Replacement(ERF)" then 1595
           when "Mixed Feeding(MF)" then 6046 else "" end) as Infant_feeding,
    (case TB_Assessment_outcome
     when "No TB" then 1660
     when "PrTB" then 142177
     when "TBRx" then 1662
     when "INH" then 1679
     when "Not Done" then 1118  else '' end)as TB_Assessment_outcome,
    (case Social_smile_milestone_Under_2Months
       when "Regressed"  then 6025
       when "Delayed"  then 6022
       when "Normal"  then 162056   else NULL end)as Social_smile_milestone_Under_2Months,
    (case Social_smile_milestone_2Months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162056   else NULL end)as Social_smile_milestone_2Months,
    (case Head_control_milestone_3Months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162057   else NULL end)as Head_control_milestone_3Months,
    (case Head_control_milestone_4Months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162058   else NULL end)as Head_control_milestone_4Months,
    (case Hand_extension_milestone_9months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162059   else NULL end)as Hand_extension_milestone_9months,
    (case Sitting_milestone_12months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162061   else NULL end)as Sitting_milestone_12months,
    (case Standing_milestone_15months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162062   else NULL end)as Standing_milestone_15months,
    (case Walking_milestone_18months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162063   else NULL end)as Walking_milestone_18months,
    (case Talking_milestone_36months
     when "Regressed"  then 6025
     when "Delayed"  then 6022
     when "Normal"  then 162060   else NULL end)as Talking_milestone_36months,
    First_DNA_PCRSampleDate,
    First_DNA_PCRResult,
    First_DNA_PCRResultDate,
    Second_DNA_PCRSampleDate,
    Second_DNA_PCRResult,
    Second_DNA_PCRResultDate,
    Third_DNA_PCRSampleDate,
    Third_DNA_PCRResult,
    Third_DNA_PCRResultDate,
    ConfimatoryPCR_SampleDate,
    ConfirmatoryPCR_Result,
    ConfimatoryPCR_ResultDate,
    RepeatConfirmatoryPCR_SampleDate,
    RepeatConfirmatoryPCR_Result,
    RepeatConfirmatoryPCR_ResultDate,
    BaselineViralLoadSampleDate,
    BaselineViralLoadResult,
    BaselineViralLoadResultDate,
    Final_AntibodySampleDate,
    Final_AntibodyResult,
    Final_AntibodyResultDate,
    -- Review_of_systems_developmental VARCHAR(100),
    Dna_pcr_sample_date,
    Dna_pcr_contextual_status,
    Dna_pcr_results,
    Dna_pcr_dbs_sample_code,
    Dna_pcr_results_date,
    (case Azt_given
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Azt_given,
    (case Nvp_given
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Nvp_given,
    (case Ctx_given
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Ctx_given,
    (case ARV_prophylaxis_received
     when "AZT liquid BID for 12 weeks" then 160123
     when "NVP liquid OD for 12 weeks" then 80586
     when "AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks" then 1652
     when "Other" then 5622
     when "None" then 1107  else NULL end)as  ARV_prophylaxis_received,
    ARV_prophylaxis_Other_received,
    First_antibody_sample_date,
    First_antibody_result,
    First_antibody_dbs_sample_code,
    First_antibody_result_date,
    Final_antibody_sample_date,
    Final_antibody_result,
    Final_antibody_dbs_sample_code,
    Final_antibody_result_date,
    Tetracycline_Eye_Ointment,
    Pupil,
    Sight,
    Squint,
    Deworming_Drug,
    Deworming_Dosage_Units,
    Date_of_next_appointment,
    Comments,
    Voided
  FROM migration_st.st_hei_followup WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 27. Create hei outcome transformed table
DROP TABLE IF EXISTS migration_tr.tr_hei_outcome;
CREATE TABLE migration_tr.tr_hei_outcome as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    Child_hei_outcomes_exit_date,
    (case Child_hei_outcomes_HIV_status
     when "Died Child died before confirming the HIV status" then 160432
     when "Uninfected not Breastfed (UBFn)" then 1403
     when "Uninfected Breastfed (UBF)" then 1403
     when "Child transferred out to another facility before confirming HIV status (TO)" then 159492
     when "Status unknown because test was not done due to LTFU (TnD)" then 5240
     when "Infected BF Unknown (IBFu)" then 138571
     when "Infected not Breastfed (IBFn)" then 138571
     when "Infected Breastfed (IBF)" then 138571
     when "Unknown" then 1067 else NULL end) as Child_hei_outcomes_HIV_status
  FROM migration_st.st_hei_outcome WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 28. Create hei immunizations transformed table

DROP TABLE IF EXISTS migration_tr.tr_hei_immunization;
CREATE TABLE migration_tr.tr_hei_immunization as
  select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    BCG,
    BCG_Date,
    BCG_Period,
    OPV_birth,
    OPV_Birth_Date,
    OPV_Birth_Period,
    OPV_1,
    OPV_1_Date,
    OPV_1_Period,
    OPV_2,
    OPV_2_Date,
    OPV_2_Period,
    OPV_3,
    OPV_3_Date,
    OPV_3_Period,
    DPT_Hep_B_Hib_1,
    DPT_Hep_B_Hib_2,
    DPT_Hep_B_Hib_3,
    IPV,
    IPV_Date,
    IPV_Period,
    ROTA_1,
    ROTA_1_Date,
    ROTA_1_Period,
    ROTA_2,
    ROTA_2_Date,
    ROTA_2_Period,
    Measles_rubella_1,
    Measles_rubella_2,
    Yellow_fever,
    Measles_6_months,
    Measles_6_Date,
    Measles_6_Period,
    Measles_9_Months,
    Measles_9_Date,
    Measles_9_Period,
    Measles_18_Months,
    Measles_18_Date,
    Measles_18_Period,
    Pentavalent_1,
    Pentavalent_1_Date,
    Pentavalent_1_Period,
    Pentavalent_2,
    Pentavalent_2_Date,
    Pentavalent_2_Period,
    Pentavalent_3,
    Pentavalent_3_Date,
    Pentavalent_3_Period,
    PCV_10_1,
    PCV_10_1_Date,
    PCV_10_1_Period,
    PCV_10_2,
    PCV_10_2_Date,
    PCV_10_2_Period,
    PCV_10_3,
    PCV_10_3_Date,
    PCV_10_3_Period,
    Other,
    Other_Date,
    Other_Period,
    VitaminA_6_months,
    VitaminA_1_yr,
    VitaminA_1_and_half_yr,
    VitaminA_2_yr,
    VitaminA2_to_5_yr,
    fully_immunized,
    Voided
  FROM migration_st.st_hei_immunization WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 29. ART Treatment preparation
DROP TABLE IF EXISTS migration_tr.tr_art_preparation;
CREATE TABLE migration_tr.tr_art_preparation as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  (case Understands_hiv_art_benefits
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Understands_hiv_art_benefits,
  (case Screened_negative_substance_abuse
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Screened_negative_substance_abuse,
  (case Screened_negative_psychiatric_illness
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Screened_negative_psychiatric_illness,
  (case HIV_status_disclosure
     when "Yes" then 1
     when "No" then 2  else NULL end)as HIV_status_disclosure,
  (case Trained_drug_admin
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Trained_drug_admin,
  (case Informed_drug_side_effects
     when "Yes" then 1
     when "No" then 2  else NULL end)as Informed_drug_side_effects,
  (case Caregiver_committed
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Caregiver_committed,
  (case Adherance_barriers_identified
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Adherance_barriers_identified,
  (case Caregiver_location_contacts_known
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Caregiver_location_contacts_known,
  (case Ready_to_start_art
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Ready_to_start_art,
  (case Identified_drug_time
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Identified_drug_time,
  (case Treatment_supporter_engaged
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Treatment_supporter_engaged,
  (case Support_grp_meeting_awareness
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Support_grp_meeting_awareness,
  (case Enrolled_in_reminder_system
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Enrolled_in_reminder_system,
  (case Other_support_systems
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Other_support_systems,
  Voided
FROM migration_st.st_art_preparation WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 30. Enhanced Adherence Screening
DROP TABLE IF EXISTS migration_tr.tr_enhanced_adherence;
CREATE TABLE migration_tr.tr_enhanced_adherence as
  select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  Session_number,
  First_session_date,
  Pill_count,
  (case Arv_adherence
       when "Good" then 159405
       when "Inadequate" then 163794
       when "Poor" then 159407
       else NULL end)as Arv_adherence,
  (case Has_vl_results
     when "Yes" then 1065
     when "No" then 1066  else NULL end)as Has_vl_results,
  (case Vl_results_suppressed
    when "Suppressed" then 1302
    when "Unsuppresed" then 1066  else NULL end)as Vl_results_suppressed,
  Vl_results_feeling,
  Cause_of_high_vl,
  Way_forward,
  Patient_hiv_knowledge,
  Patient_drugs_uptake,
  Patient_drugs_reminder_tools,
  Patient_drugs_uptake_during_travels,
  Patient_drugs_side_effects_response,
  Patient_drugs_uptake_most_difficult_times,
  Patient_drugs_daily_uptake_feeling,
  Patient_ambitions,
  (case Patient_has_people_to_talk
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as  Patient_has_people_to_talk,
  Patient_enlisting_social_support,
  Patient_income_sources,
  (case Patient_challenges_reaching_clinic
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Patient_challenges_reaching_clinic,
  (case Patient_worried_of_accidental_disclosure
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Patient_worried_of_accidental_disclosure,
  (case Patient_treated_differently
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Patient_treated_differently,
  (case Stigma_hinders_adherence
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Stigma_hinders_adherence,
  (case Patient_tried_faith_healing
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Patient_tried_faith_healing,
  (case Patient_adherence_improved
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Patient_adherence_improved,
  (case Patient_doses_missed
    when "Yes" then 1
    when "No" then 0  else NULL end)as Patient_doses_missed,
  Review_and_barriers_to_adherence,
  (case Other_referrals
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Other_referrals,
  (case Appointments_honoured
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Appointments_honoured,
  Referral_experience,
  (case Home_visit_benefit
    when "Yes" then 1065
    when "No" then 1066  else NULL end)as Home_visit_benefit,
  Adherence_plan,
  Next_appointment_date,
  Voided
FROM migration_st.st_enhanced_adherence WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 31. Defaulter tracing
DROP TABLE IF EXISTS migration_tr.tr_defaulter_tracing;
CREATE TABLE migration_tr.tr_defaulter_tracing as
    select
          Person_Id,
          Encounter_Date,
          Encounter_ID,
          Tracing_type,
          (case Tracing_outcome
           when "Traced patient (unable to locate)" then 1118
           when "Traced and located" then 1267 when "Did not attempt to trace patient" then 1118 else NULL end)as Tracing_outcome,
           Attempt_number,
           Is_final_trace,
           True_status,
           (case Cause_of_death
           when "Other HIV disease resulting in other diseases or conditions leading to death" then 162574
           when "HIV disease resulting in cancer" then 116030 when "HIV disease resulting in TB" then 164500
           when "HIV disease resulting in other infectious and parasitic diseases" then 151522 when "Other natural causes not directly related to HIV" then 133481
           when "Non-natural causes (e.g, trauma, accident, suicide, war, etc)" then 1603 when "Unknown cause" then 5622 else NULL end)as Cause_of_death,
           Comments,
           Voided
    FROM migration_st.st_defaulter_tracing WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 32. Gender Based Violence Screening Grouped
DROP TABLE IF EXISTS migration_tr.tr_gbv_screening;
CREATE TABLE migration_tr.tr_gbv_screening as
    select
         Person_Id,
          Encounter_Date,
          Encounter_ID,
        (case Violence_withing_past_year
           when "Yes" then 1065
           when "No" then 1066 else NULL end)as Violence_withing_past_year,
        (case Physical_hurt
           when "Yes" then 158358
           when "No" then 1066 else NULL end)as Physical_hurt,
        (case Threatens
           when "Yes" then 118688
           when "No" then 1066 else NULL end)as Threatens,
        (case Sexual_violence
           when "Yes" then 152370
           when "No" then 1066 else NULL end)as Sexual_violence,
         (case Violence_from_unrelated_person
           when "Yes" then 1582
           when "No" then 1066 else NULL end)as Violence_from_unrelated_person,
          Voided
    FROM migration_st.st_gbv_screening;

-- 33. Alcohol and drug abuse screening
DROP TABLE IF EXISTS migration_tr.tr_alcohol_screening;
CREATE TABLE migration_tr.tr_alcohol_screening as
    select
       Person_Id,
        Encounter_Date,
        Encounter_ID,
        (case Alcohol_frequency
         when "Never" then 1090
         when "Monthly or less" then 1091
         when "2-4 times a month" then 1092
         when "2-3 times a week" then 1093
         when "4 or More Times a Week" then 1094 else NULL end) as Alcohol_frequency,
        (case Smoking_frequency
         when "Never smoked" then 1090
         when "Former smoker" then 156358
         when "Current some day smoker" then 163197
         when "Light tobacco smoker (<10 per day)" then 163196
         when "Heavy tobacco smoker (Over 10 per day)" then 163195
         when "Smoker current status uknown" then 163200 else NULL end) as Smoking_frequency,
       (case Drugs_frequency
         when "Never" then 1090
         when "Monthly or less" then 1091
         when "2-4 times a month" then 1092
         when "2-3 times a week" then 1093
         when "4 or More Times a Week" then 1094 else NULL end) as Drugs_frequency,
        Voided
    FROM migration_st.st_alcohol_screening;

-- 34. OTZ Enrolment
DROP TABLE IF EXISTS migration_tr.tr_otz_enrolment;
CREATE TABLE migration_tr.tr_otz_enrolment as
   select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Orientation when "Yes" then 1065 when NULL then 1066 else NULL end) as Orientation,
    (case Leadership when "Yes" then 1065 when NULL then 1066 else NULL end) as Leadership,
    (case Participation when "Yes" then 1065 when NULL then 1066 else NULL end) as Participation,
    (case Treatment_literacy when "Yes" then 1065 when NULL then 1066 else NULL end) as Treatment_literacy,
    (case Transition_to_adult_care when "Yes" then 1065 when NULL then 1066 else NULL end) as Transition_to_adult_care,
    (case Making_decision_future when "Yes" then 1065 when NULL then 1066 else NULL end) as Making_decision_future,
    (case Srh when "Yes" then 1065 when NULL then 1066 else NULL end) as Srh,
    (case Beyond_third_ninety when "Yes" then 1065 when NULL then 1066 else NULL end) as Beyond_third_ninety,
    (case Transfer_in when "Yes" then 1065 when NULL then 1066 else NULL end) as Transfer_in,
    Initial_Enrolment_Date,
    voided
    FROM migration_st.st_otz_enrolment WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 35. OTZ Activity
DROP TABLE IF EXISTS migration_tr.tr_otz_activity;
CREATE TABLE migration_tr.tr_otz_activity as
    select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Orientation when "Yes" then 1065 when NULL then 1066 else NULL end) as Orientation,
    (case Leadership when "Yes" then 1065 when NULL then 1066 else NULL end) as Leadership,
    (case Participation when "Yes" then 1065 when NULL then 1066 else NULL end) as Participation,
    (case Treatment_Literacy when "Yes" then 1065 when NULL then 1066 else NULL end) as Treatment_Literacy,
    (case Transition_to_Adult_Care when "Yes" then 1065 when NULL then 1066 else NULL end) as Transition_to_Adult_Care,
    (case Making_Decision_Future when "Yes" then 1065 when NULL then 1066 else NULL end) as Making_Decision_Future,
    (case srh when "Yes" then 1065 when NULL then 1066 else NULL end) as srh,
    (case Beyond_Third_Ninety when "Yes" then 1065 when NULL then 1066 else NULL end) as Beyond_Third_Ninety,
    (case Attended_Support_Group when "Yes" then 1065 when "No" then 1066 else NULL end) as Attended_Support_Group,
    Remarks,
    voided
    FROM migration_st.st_otz_activity WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

    -- 36. OTZ Outcome
DROP TABLE IF EXISTS migration_tr.tr_otz_outcome;
CREATE TABLE migration_tr.tr_otz_outcome as
    select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Discontinuation_Reason when "Transition to Adult care" then 165363 when "Opt out of OTZ" then 159836 else NULL end) as Discontinuation_Reason,
    Death_Date,
    Transfer_Facility,
    Transfer_Date,
    voided
    FROM migration_st.st_otz_outcome WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

-- 37. OVC Enrolment
DROP TABLE IF EXISTS migration_tr.tr_ovc_enrolment;
CREATE TABLE migration_tr.tr_ovc_enrolment as
    select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Caregiver_enrolled_here when "Yes" then 1065 when NULL then 1066 else NULL end) as Caregiver_enrolled_here,
    Caregiver_name,
    (case Caregiver_gender when "Female" then 1535 when "Male" then 1534 else NULL end) as Caregiver_gender,
    (case Relationship_to_Client when "Childrenshome" then 162722 when "Aunt" then 975 when "Uncle" then 974 when "Sibling" then 972 when "Parent" then 1527 else NULL end) as Relationship_to_Client,
    Caregiver_Phone_Number,
    (case Client_Enrolled_cpims when "Yes" then 1065 when "No" then 1066 else NULL end) as Client_Enrolled_cpims,
    Partner_Offering_OVC,
    voided
    FROM migration_st.st_ovc_enrolment WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

	    -- 38. OVC Outcome
DROP TABLE IF EXISTS migration_tr.tr_ovc_outcome;
CREATE TABLE migration_tr.tr_ovc_outcome as
    select
    Person_Id,
    Encounter_Date,
    Encounter_ID,
    (case Exit_Reason when "GraduatedOutOVC" then 1267 when "ExitWithoutGraduation" then 165219 when "TransferOutNonPepfarFacility" then 159492 when "TransferOutPepfarFacility" then 160036 else NULL end) as Exit_Reason,
    Transfer_Facility,
    Transfer_Date,
    voided
    FROM migration_st.st_ovc_outcome WHERE
       (Encounter_Date != "" OR Encounter_Date IS NOT NULL)
  GROUP BY Person_Id, Encounter_Date;

	
	
	
	
	
	