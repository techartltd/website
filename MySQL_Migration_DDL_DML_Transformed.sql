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
                         when "Other" then 5622 else "" end) as Marital_status,
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
                         when "Other" then 5622
                         else "" end) as Occupation,
        (case Education_level
                         when "Primary School" then 1713
                         when "Secondary School" then 1714
                         when "University" then 159785
                         when "College" then 159785
                         when "NONE" then 1107
                         when "Other" then 5622
                         else "" end) as Education_level,
        Dead,
        Death_date
    FROM migration_st.st_demographics;

-- 2. Create HIV Enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_hiv_enrollment;
CREATE TABLE migration_tr.tr_hiv_enrollment as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Sex,
    UPN,
    Encounter_Date,
    Encounter_ID,
    (case Patient_Type when 'New' then 164144
                      when 'Transfer-In' then 160563
                      when 'Transit' then 164931 else '' end) as Patient_Type,
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
                      when 'Other' then 5622 else '' end) as Entry_point,
    TI_Facility,
    Date_first_enrolled_in_care,
    Transfer_in_date,
    Date_started_art_at_transferring_facility,
    Date_confirmed_hiv_positive,
    Facility_confirmed_hiv_positive,
    Baseline_arv_use,
    (case Purpose_of_baseline_arv_use when 'PMTCT' then 1148
                                      when 'PEP' then 1691
                                      when 'ART' then 1181 else '' end) as Purpose_of_baseline_arv_use,
    (case Baseline_arv_regimen when 'AF2D (TDF + 3TC + ATV/r)' then 164512
                               when 'AF2A (TDF + 3TC + NVP)' then 162565
                               when 'AF2B (TDF + 3TC + EFV)' then 164505
                               when 'AF1A (AZT + 3TC + NVP' then 1652
                               when 'AF1B (AZT + 3TC + EFV)' then 160124
                               when 'AF4B (ABC + 3TC + EFV)' then 162563
                               when 'AF4A (ABC + 3TC + NVP)' then 162199
                               when 'CF2A (ABC + 3TC + NVP)' then 162199
                               when 'CF2D (ABC + 3TC + LPV/r)' then 162200
                               when 'CF2B (ABC + 3TC + EFV)' then 162563 else '' end) as Baseline_arv_regimen,
    Baseline_arv_regimen_line,
    Baseline_arv_date_last_used,
    (case Baseline_who_stage when 'Stage1' then 1204
                             when 'Stage2' then 1205
                             when 'Stage3' then 1206
                             when 'Stage4' then 1207
                             when 'Unknown' then 1067 else '' end) as Baseline_who_stage,
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
  FROM migration_st.st_hiv_enrollment;

-- 3. Create Triage transformed table
DROP TABLE IF EXISTS migration_tr.tr_triage;
CREATE TABLE migration_tr.tr_triage as
  select
      Person_Id,
      First_Name,
      Middle_Name,
      Last_Name,
      DOB,
      Sex,
      UPN,
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
  FROM migration_st.st_triage;


-- 4. Create hts initial transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_initial;
CREATE TABLE migration_tr.tr_hts_initial as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Sex,
    UPN,
    Encounter_Date,
    Encounter_ID,
    (case Pop_Type
         when "General Population" then 164928
         when "Key Population" then 164929
         when "Priority Population" then 138643  else '' end)as Pop_Type,
    (case Key_Pop_Type
          when "Male Sex Worker" then 165084
          when "People who Inject with Drugs" then 105
          when "Female Sex Worker" then 160579
          when "Men having Sex with Men" then 160578
          when "other" then 5622  else '' end) as Key_Pop_Type,
    (case Priority_Pop_Type
           when "Fisher folk" then 159674
           when "Truck driver" then 162198
           when "Adolescent and young girls" then 160549
           when "Prisoner" then 162277
           when "other" then 5622  else '' end) as Priority_Pop_Type,
   (case Patient_disabled
           when "Yes" then 1065
           when "No" then 1066  else '' end)as Patient_disabled,
   (case Disability
          when "D: Deaf/Hearing impaired" then 120291
          when "B: Blind/Visually impaired" then 147215
          when "M: Mentally Challenged" then 151342
          when "P: Physically Challenged" then  164538
          when "Other" then 5622 else '' end)as Disability,
    (case Ever_Tested
       when "Yes" then 1065
       when "No" then 1066  else '' end)as Ever_Tested,
    (case Self_Tested
          when "Yes" then 1065
          when "No" then 1066  else '' end)as Self_Tested,
    (case HTS_Strategy
           when "NP: Non-Patients" then 164953
           when "HP: Health Facility Patients" then 164955
           when "VI: Integrated VCT sites" then 164954 else '' end )as HTS_Strategy,
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
           when "HBTC" then 159938  else '' end)as HTS_Entry_Point,
    (case Consented
            when "Yes" then 1065
            when "No" then 1066  else '' end)as Consented,
    (case Tested_As
             when "C: Couple (includes polygamous)" then 164957
             when "I: Individual" then 164958  else '' end)as Tested_As,
     (case Test_1_Kit_Name
              when "First Response" then 164961
              when "Determine" then 164960
              when "Other" then 1175  else '' end) as Test_1_Kit_Name,
      Test_1_Lot_Number,
      Test_1_Expiry_Date,
    (case Test_1_Final_Result
             when "Positive" then 703
             when "Negative" then 664
             when "Inconclusive" then 1138  else '' end)as  Test_1_Final_Result,
    (case Test_2_Kit_Name
              when "First Response" then 164961
              when "Determine" then 164960
              when "Other" then 1175  else '' end)as  Test_2_Kit_Name,
    Test_2_Lot_Number,
    Test_2_Expiry_Date,
    (case Test_2_Final_Result
               when "Positive" then 703
               when "Negative" then 664
               when "Inconclusive" then 1138  else '' end)as  Test_2_Final_Result,
    (case  Final_Result
             when "Positive" then 703
             when "Negative" then 664
             when "Inconclusive" then 1138  else '' end)as  Final_Result,
     (case Result_given
                when "Yes" then 1065
                when "No" then 1066  else '' end)as Result_given,
     (case Couple_Discordant
                when "Yes" then 1065
                when "No" then 1066  else '' end)as Couple_Discordant,
     (case Tb_Screening_Results
                  when "NS: No Signs" then 1660
                  when "PrTB: Presumed TB" then 142177
                  when "TB Confirmed" then 1662
                  when "ND: Not Done" then 160737
                  when "TBRx: On TB treatment" then 1111 else '' end)as Tb_Screening_Results,
      Remarks
      FROM migration_st.st_hts_initial where TestType = "Initial Test";

-- 5. Create hts retest transformed table
DROP TABLE IF EXISTS migration_tr.tr_hts_retest;
CREATE TABLE migration_tr.tr_hts_retest as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Sex,
    UPN,
    Encounter_Date,
    Encounter_ID,
    (case Pop_Type
     when "General Population" then 164928
     when "Key Population" then 164929
     when "Priority Population" then 138643  else '' end)as Pop_Type,
    (case Key_Pop_Type
     when "Male Sex Worker" then 165084
     when "People who Inject with Drugs" then 105
     when "Female Sex Worker" then 160579
     when "Men having Sex with Men" then 160578
     when "other" then 5622  else '' end) as Key_Pop_Type,
    (case Priority_Pop_Type
     when "Fisher folk" then 159674
     when "Truck driver" then 162198
     when "Adolescent and young girls" then 160549
     when "Prisoner" then 162277
     when "other" then 5622  else '' end) as Priority_Pop_Type,
    (case Patient_disabled
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Patient_disabled,
    (case Disability
     when "D: Deaf/Hearing impaired" then 120291
     when "B: Blind/Visually impaired" then 147215
     when "M: Mentally Challenged" then 151342
     when "P: Physically Challenged" then  164538
     when "Other" then 5622 else '' end)as Disability,
    (case Ever_Tested
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Ever_Tested,
    (case Self_Tested
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Self_Tested,
    (case HTS_Strategy
     when "NP: Non-Patients" then 164953
     when "HP: Health Facility Patients" then 164955
     when "VI: Integrated VCT sites" then 164954 else '' end )as HTS_Strategy,
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
     when "HBTC" then 159938  else '' end)as HTS_Entry_Point,
    (case Consented
     when "Yes" then 1065
     when "No" then 1066  else '' end)as Consented,
    (case Tested_As
     when "C: Couple (includes polygamous)" then 164957
     when "I: Individual" then 164958  else '' end)as Tested_As,
    (case Test_1_Kit_Name
     when "First Response" then 164961
     when "Determine" then 164960
     when "Other" then 1175  else '' end) as Test_1_Kit_Name,
    Test_1_Lot_Number,
    Test_1_Expiry_Date,
    (case Test_1_Final_Result
         when "Positive" then 703
         when "Negative" then 664
         when "Inconclusive" then 1138  else '' end)as  Test_1_Final_Result,
    (case Test_2_Kit_Name
         when "First Response" then 164961
         when "Determine" then 164960
         when "Other" then 1175  else '' end)as  Test_2_Kit_Name,
    Test_2_Lot_Number,
    Test_2_Expiry_Date,
    (case Test_2_Final_Result
         when "Positive" then 703
         when "Negative" then 664
         when "Inconclusive" then 1138  else '' end)as  Test_2_Final_Result,
    (case  Final_Result
          when "Positive" then 703
          when "Negative" then 664
          when "Inconclusive" then 1138  else '' end)as  Final_Result,
    (case Result_given
         when "Yes" then 1065
         when "No" then 1066  else '' end)as Result_given,
    (case Couple_Discordant
         when "Yes" then 1065
         when "No" then 1066  else '' end)as Couple_Discordant,
        (case Tb_Screening_Results
         when "NS: No Signs" then 1660
         when "PrTB: Presumed TB" then 142177
         when "TB Confirmed" then 1662
         when "ND: Not Done" then 160737
         when "TBRx: On TB treatment" then 1111 else '' end)as Tb_Screening_Results,
    Remarks
  FROM migration_st.st_hts_retest where TestType = "Repeat Test";
  
  -- 6. HTS Client Tracing transformed table

-- 7. HTS Client Referral transformed table

-- 8. HTS Client Linkage transformed table

-- 9. HTS Contact Listing transformed table

-- 10. Create patient program transformed table
DROP TABLE IF EXISTS migration_tr.tr_program_enrollment;
CREATE TABLE migration_tr.tr_program_enrollment as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Sex,
    UPN,
    Encounter_Date,
    Encounter_ID,
    Program,
    Date_Enrolled,
    Date_Completed
  FROM migration_st.st_program_enrollment;

-- 11. Discontinuation transformed table
DROP TABLE IF EXISTS migration_tr.tr_program_discontinuation;
CREATE TABLE migration_tr.tr_program_discontinuation as
  select
    Person_Id,
    First_Name,
    Middle_Name,
    Last_Name,
    DOB,
    Sex,
    UPN,
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
	 when "Unknown" then 1067 else "" end) as Care_Ending_Reason,
    Facility_Transfered_To,
    Death_Date
  FROM migration_st.st_program_discontinuation;
  
-- 12. IPT Screening transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_screening;
CREATE TABLE migration_tr.tr_ipt_screening
    select
      Person_Id,
      UPN,
      Encounter_Date,
      Encounter_ID,
      (case Yellow_urine
           when "Yes" then 162311
           when "No" then 1066  else '' end)as Yellow_urine,
      (case Numbness
           when "Yes" then 132652
           when "No" then 1066  else '' end)as Numbness,
      (case Yellow_eyes
           when "Yes" then 5192
           when "No" then 1066  else '' end)as Yellow_eyes,
      (case Tenderness
           when "Yes" then 124994
           when "No" then 1066  else '' end)as Tenderness,
      IPT_Start_Date
    FROM migration_st.st_ipt_screening;

-- 13. IPT program Enrollment transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_program;
CREATE TABLE migration_tr.tr_ipt_program
    select
    Person_Id,
    UPN,
    Encounter_Date,
    Encounter_ID,
    IPT_Start_Date,
    Indication_for_IPT,
    (case IPT_Outcome when "TransferredOut" then 159492
       when "Died" then 160034
       when "Discontinued" then 159836
       when "LostToFollowUp" then 5240
       when "Completed" then 1267
       when "Unknown" then 1067 else "" end) as IPT_Outcome,
    Outcome_Date
    FROM migration_st.st_ipt_program;

-- 14. IPT program Followup transformed table
DROP TABLE IF EXISTS migration_tr.tr_ipt_followup;
CREATE TABLE migration_tr.tr_ipt_followup
    select
        Person_Id,
        UPN,
        Encounter_Date,
        Encounter_ID,
        Ipt_due_date,
        Date_collected_ipt,
        Weight,
       (case Hepatotoxity
           when "Yes" then 1065
           when "No" then 1066  else '' end)as Hepatotoxity,
       (case Peripheral_neuropathy
         when "Yes" then 1065
         when "No" then 1066  else '' end)as Peripheral_neuropathy,
       (case Rash
         when "Yes" then 1065
         when "No" then 1066  else '' end)as Rash,
       (case Adherence
         when "Good(Missed<3/month)" then 159405
         when "Fair(Missed4-8/month)" then 159406
         when "Bad()Missed 9" then 159407 else '' end)as Adherence,
        AdheranceMeasurement_Action,
        IPT_Outcome,
        Outcome_Date
    FROM migration_st.st_ipt_followup;
	
-- 15. Regimen History transformed table
DROP TABLE IF EXISTS migration_tr.tr_regimen_history;
CREATE TABLE migration_tr.tr_regimen_history
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
         when "Non-ART" then 5622 else '' end)as Program,
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
          when "EH"  then 1108  else "" end ) as Regimen_Name,
      (case Regimen_Line
           when "AdultARTFirstLine"   then 164506
           when "PMTCTHEIMotherRegimen"   then 164506
           when "PaedsARTFirstLine"   then 164507
           when "AdultARTSecondLine"  then 164513
           when "AdultThirdlineRegimen"  then 164513
           when "PaedsARTSecondLine"  then  164514
           when "PaedsThirdlineRegimen"  then  164514
           when "PaedsThirdlineRegimen"  then  164514
           when "PePRegimen"  then  164506
           when "PrEPRegimen"  then  164506
           when "OtherPREPRegimen"  then  164506
           when "PreferredPREPRegimen"  then  164506
           when "TBRegimen"  then  1111 else "" end ) as Regimen_Line,
      Date_Started,
      Date_Stopped,
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
           when "EH"  then 1108  else "" end ) as Regimen_Discontinued,
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
           when "EH"  then 1108  else "" end ) as RegimenSwitchTo,
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
           when "EH"  then 1108  else "" end ) as CurrentRegimen
      FROM migration_st.st_regimen_history where Date_Started != "" ;
	
	-- 16. HIV Followup transformed table
  DROP TABLE IF EXISTS migration_tr.tr_hiv_followup;
 CREATE TABLE migration_tr.tr_hiv_followup
    select
  Person_Id,
  Encounter_Date,
  Encounter_ID,
  (case Visit_scheduled when "Yes" then 1
                        when "No" then 2 else "" end )as Visit_scheduled,
  (case Visit_by when "S" then 978
                 when "TS" then 161642 else "" end )as Visit_by,
  Visit_by_other,
  (case Nutritional_status when "Normal" then 978
                           when "Severe Acute Malnutrition" then 163302
                           when "Moderate Acute Malnutrition" then 163303
                           when "Overweight/Obese" then 114413 else "" end )as Nutritional_status,
  (case Population_type when "General Population" then 164928
                        when "Key Population" then 164929 else "" end) as Population_type,
  (case Key_population_type when "People who Inject with Drugs" then 105
                            when "Men having Sex with Men" then 160578
                            when "Male Sex Worker" then 160578
                            when "Female Sex Worker" then 160579
                            when "Other" then 5622 else "" end) as Key_population_type,
  (case Who_stage when "Stage1" then 1204
                  when "Stage2" then 1205
                  when "Stage3" then 1206
                  when "Stage4" then 1207 else "" end )as Who_stage,
  (case Presenting_complaints
       when "Yes" then 1065
       when "No" then 1066  else '' end)as Presenting_complaints,
  (case Complaint
       when "Weight loss" then 832
       when "Vomiting" then 122983
       when "Vertigo" then 111525
       when "Urinary symptoms Pain/frequency/Urgency" then 160208
       when "Tremors" then 112200
       when "Swollen legs" then 125198
       when "Sweating-excessive" then 140941
       when "Sore Throat" then 158843
       when "Sleep disturbance" then 141597
       when "Shoulder pain" then 126535
       when "Scrotal pain" then 131032
       when "Runny/blocked nose" then 113224
       when "Ringing/Buzzing ears" then 117698
       when "Red eye" then 127777
       when "Rash" then 512
       when "Poor Vision" then 5953
       when "Pelvic pain" then 131034
       when "Pain when swallowing" then 125225
       when "Numbness" then 132653
       when "Night Sweats" then 133027
       when "Neck pain" then 133469
       when "Nausea" then 5978
       when "Muscle pain" then 133632
       when "Muscle cramps" then 133028
       when "Mouth ulcers" then 111721
       when "Mouth pain/burning" then 131015
       when "Mental status, acute change (coma, lethargy)" then 144576
       when "Memory loss" then 121657
       when "Lymphadenopathy" then 135488
       when "Loss of appetite" then 135595
       when "Leg pain" then 114395
       when "Joint Pain" then 116558
       when "Itchiness/Pruritus" then 879
       when "Hypotension/Shock" then 116214
       when "Hearing loss" then 117698
       when "Headache" then 139084
       when "Genital skin lesion/Ulcer" then 135462
       when "Genital Discharge" then 123396
       when "Flank pain" then 140070
       when "Fever" then 140238
       when "Fatigue/weakness" then 162626
       when "Facial pain" then 114399
       when "Eye pain" then 131040
       when "Epigastric Pain" then 141128
       when "Ear pain" then 141585
       when "Dizziness" then 141830
       when "Difficulty in swallowing" then 118789
       when "Difficult in breathing" then 122496
       when "Diarrhoea" then 142412
       when "Crying infant" then 143129
       when "Cough" then 143264
       when "Convulsions/Seizure" then 206
       when "Confusion/Delirium" then 119574
       when "Cold/Chills" then 871
       when "Chest pain" then 120749
       when "Breast pain" then 131021
       when "Bloody Urine" then 840
       when "Back pain" then 148035
       when "Anxiety, depression" then 119537
       when "Abnormal uterine bleeding" then 141631
       when "Abdominal pain" then 151
       when "Other" then 5622  else '' end)as Complaint,
  Duration,
  Onset_Date,
  Clinical_notes,
  (case Has_known_allergies
       when "Yes" then 1065
       when "No" then 1066  else '' end)as Has_known_allergies,
  (case Allergies_causative_agents
       when "Ragweed" then 162541
       when "Pollen" then 162540
       when "Mold" then 162539
       when "Latex" then 162538
       when "Dust" then 162537
       when "Bee stings" then 162536
       when "Adhesive tape" then 162542
       when "Wheat" then 162177
       when "Strawberries" then 162548
       when "Soy" then 162176
       when "Shellfish" then 162175
       when "Peanuts" then 162172
       when "Milk protein" then 162547
       when "Fish" then 162546
       when "Eggs" then 162171
       when "Dairy food" then 162545
       when "Chocolate" then 162544
       when "Caffeine" then 72609
       when "Beef" then 162543
       when "Zidovudine" then 86663
       when "Tetracyline" then 84893
       when "Tenofovir" then 84795
       when "Sulfonamides" then 162170
       when "Stavudine" then 84309
       when "Statins" then 162307
       when "Rifampin" then 767
       when "Quinidine" then 83018
       when "Pyrazinamide" then 82900
       when "Procainamide" then 82559
       when "Phenytoin" then 82023
       when "Phenolphthaleins" then 81959
       when "Penicillins" then 81724
       when "Penicillamine" then 81723
       when "Non-steroidal anti-inflammatory drugs" then 162306
       when "Nitrofurans" then 158005
       when "Nevirapine" then 80586
       when "Morphine" then 80106
       when "Lopinavir/ritonavir" then 794
       when "Isoniazid" then 78280
       when "Hydralazine" then 77675
       when "Heparins" then 162305
       when "Griseofulvin" then 77164
       when "Ethambutol" then 75948
       when "Erythromycins" then 162302
       when "Efavirenz" then 75523
       when "Didanosine" then 74807
       when "Codeine" then 73667
       when "Choloroquine" then 73300
       when "Cephalosporins" then 162301
       when "Carbamazepine" then 72822
       when "Atazanavir" then 71647
       when "Aspirin" then 155175
       when "ARBs (angiotensin II receptor blockers)" then 162299
       when "Aminoglycosides" then 155060
       when "Allopurinol" then 70878
       when "ACE inhibitors" then 162298
       when "Abacavir" then 70056
       when "Other" then 5622 else '' end)as Allergies_causative_agents,
  (case Allergies_reactions
       when "Unknown" then 1067
       when "Anaemia" then 121629
       when "Anaphylaxis" then 148888
       when "Angioedema" then 148787
       when "Arrhythmia" then 120148
       when "Bronchospasm" then 108
       when "Cough" then 143264
       when "Diarrhea" then 142412
       when "Dystonia" then 118773
       when "Fever" then 140238
       when "Flushing" then 140039
       when "GI upset" then 139581
       when "Headache" then 139084
       when "Hepatotoxicity" then 159098
       when "Hives" then 111061
       when "Hypertension" then 117399
       when "Itching" then 879
       when "Mental status change" then 121677
       when "Musculoskeletal pain" then 159347
       when "Myalgia" then 121
       when "Rash" then 512
       when "Other" then 5622   else '' end)as Allergies_reactions,
  (case Allergies_severity
       when "Mild" then 160754
       when "Moderate" then 160755
       when "Severe" then 160756
       when "Fatal" then 160758
       when "Unknown" then 1067  else '' end)as Allergies_severity,
  (case Has_Chronic_illnesses_cormobidities
       when "Yes" then 1065
       when "No" then 1066  else '' end)as Has_Chronic_illnesses_cormobidities,
  (case Chronic_illnesses_name
       when "Alzheimer's Disease and other Dementias" then 149019
       when "Arthritis" then 148432
       when "Asthma" then 153754
       when "Cancer" then 159351
       when "Cardiovascular diseases" then 119270
       when "Chronic hepatitis" then 120637
       when "Chronic Kidney Disease" then 145438
       when "Chronic Obstructive Pulmonary Disease (COPD)" then 1295
       when "Chronic renal failure" then 120576
       when "Cystic Fibrosis" then 119692
       when "Deafness and hearing impairment" then 120291
       when "Diabetes" then 119481
       when "Endometriosis" then 118631
       when "Epilepsy" then 117855
       when "Glaucoma" then 117789
       when "Heart Disease" then 139071
       when "Hyperlipidaemia" then 115728
       when "Hypertension" then 117399
       when "Hypothyroidism" then 117321
       when "Mental illness" then 151342
       when "Multiple Sclerosis" then 133687
       when "Obesity" then 115115
       when "Osteoporosis" then 114662
       when "Sickle Cell Anemia" then 117703
       when "Thyroid disease" then 118976 else '' end)as Chronic_illnesses_name,
  Chronic_illnesses_onset_date,
(case Has_adverse_drug_reaction
       when "Yes" then 1065
       when "No" then 1066  else '' end)as Has_adverse_drug_reaction,
  (case Medicine_causing_drug_reaction
       when "Ragweed" then 162541
       when "Pollen" then 162540
       when "Mold" then 162539
       when "Latex" then 162538
       when "Dust" then 162537
       when "Bee stings" then 162536
       when "Adhesive tape" then 162542
       when "Wheat" then 162177
       when "Strawberries" then 162548
       when "Soy" then 162176
       when "Shellfish" then 162175
       when "Peanuts" then 162172
       when "Milk protein" then 162547
       when "Fish" then 162546
       when "Eggs" then 162171
       when "Dairy food" then 162545
       when "Chocolate" then 162544
       when "Caffeine" then 72609
       when "Beef" then 162543
       when "Zidovudine" then 86663
       when "Tetracyline" then 84893
       when "Tenofovir" then 84795
       when "Sulfonamides" then 162170
       when "Stavudine" then 84309
       when "Statins" then 162307
       when "Rifampin" then 767
       when "Quinidine" then 83018
       when "Pyrazinamide" then 82900
       when "Procainamide" then 82559
       when "Phenytoin" then 82023
       when "Phenolphthaleins" then 81959
       when "Penicillins" then 81724
       when "Penicillamine" then 81723
       when "Non-steroidal anti-inflammatory drugs" then 162306
       when "Nitrofurans" then 158005
       when "Nevirapine" then 80586
       when "Morphine" then 80106
       when "Lopinavir/ritonavir" then 794
       when "Isoniazid" then 78280
       when "Hydralazine" then 77675
       when "Heparins" then 162305
       when "Griseofulvin" then 77164
       when "Ethambutol" then 75948
       when "Erythromycins" then 162302
       when "Efavirenz" then 75523
       when "Didanosine" then 74807
       when "Codeine" then 73667
       when "Choloroquine" then 73300
       when "Cephalosporins" then 162301
       when "Carbamazepine" then 72822
       when "Atazanavir" then 71647
       when "Aspirin" then 155175
       when "ARBs (angiotensin II receptor blockers)" then 162299
       when "Aminoglycosides" then 155060
       when "Allopurinol" then 70878
       when "ACE inhibitors" then 162298
       when "Abacavir" then 70056
       when "Other" then 5622 else '' end)as Medicine_causing_drug_reaction,
  (case Drug_reaction
       when "Unknown" then 1067
       when "Anaemia" then 121629
       when "Anaphylaxis" then 148888
       when "Angioedema" then 148787
       when "Arrhythmia" then 120148
       when "Bronchospasm" then 108
       when "Cough" then 143264
       when "Diarrhea" then 142412
       when "Dystonia" then 118773
       when "Fever" then 140238
       when "Flushing" then 140039
       when "GI upset" then 139581
       when "Headache" then 139084
       when "Hepatotoxicity" then 159098
       when "Hives" then 111061
       when "Hypertension" then 117399
       when "Itching" then 879
       when "Mental status change" then 121677
       when "Musculoskeletal pain" then 159347
       when "Myalgia" then 121
       when "Rash" then 512
       when "Other" then 5622   else '' end)as Drug_reaction,
  (case Drug_reaction_severity
       when "Mild" then 160754
       when "Moderate" then 160755
       when "Severe" then 160756
       when "Fatal" then 160758
       when "Unknown" then 1067  else '' end)as Drug_reaction_severity,
  Drug_reaction_onset_date,
 (case Drug_reaction_action_taken
       when "CONTINUE REGIMEN" then 1257
       when "SWITCHED REGIMEN" then 1259
       when "CHANGED DOSE" then 981
       when "SUBSTITUTED DRUG" then 1258
       when "NONE" then 1107
       when "STOP" then 1260
       when "OTHER" then 5622  else '' end)as Drug_reaction_action_taken,
 (case Vaccinations_today
       when "OPV" then 783
       when "Pneumococcal" then 162342
       when "Rota" then 83531
       when "HBV" then 782
       when "Flu" then 5261
       when "Other" then 5622  else '' end)as Vaccinations_today,
  Vaccination_Date,
  Last_menstrual_period,
  (case Pregnancy_status
       when "Pregnant" then 1065
       when "Not Pregnant" then 1066 else '' end)as Pregnancy_status,
  (case Wants_pregnancy
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Wants_pregnancy,
  (case Pregnancy_outcome
       when "STILLBIRTH" then 125872
       when "Term birth of newborn" then 1395
       when "Liveborn, (Single, Twin, or Multiple)" then 151849
       when "Unknown" then 1067 else '' end)as Pregnancy_outcome,
  Anc_number,
  (case Anc_profile
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Anc_profile,
  Expected_delivery_date,
  Gravida,
  Parity,
  (case Family_planning_status
       when "Family Planning" then 965
       when "No Family Planning" then 160652
       when "Wants Family Planning" then 1360 else '' end)as Family_planning_status,
 (case Family_planning_method when "Emergency contraceptive pills" then 160570
                              when "Oral Contraceptives Pills" then 780
                              when "Injectible" then 5279
                              when "Implant" then 1359
                              when "Intrauterine Device" then 5275
                              when "Lactational Amenorhea Method" then 136163
                              when "Diaphram/Cervical Cap"  then 5278
                              when "Fertility Awareness" then 5277
                              when "Tubal Ligation"  then 1472
                              when "Condoms" then 190
                              when "Vasectomy" then 1489 else "" end) as Family_planning_method,
 (case Reason_not_using_family_planning when "Not Sexually Active now" then 160573
       when "Currently Pregnant" then 1434
       when "Thinks can’t get pregnant" then 160572
       when "Wants to get pregnant" then 160571 else "" end) as Reason_not_using_family_planning,
  (case General_examinations_findings when "Oral thrush" then 5334
       when "Lymph nodes axillary" then 126952
       when "Finger Clubbing" then 140125
       when "Pallor" then 5245
       when "Oedema" then 460
       when "Lymph nodes inguinal" then 126939
       when "Dehydration" then 142630
       when "Lethargic" then 116334
       when "Jaundice" then 136443
       when "Cyanosis" then 143050
       when "Wasting" then 823
       when "None" then  1107 else "" end) as General_examinations_findings,
  (case System_review_finding
       when "Yes" then 1115
       when "No" then 1116 else '' end)as System_review_finding,
 (case Skin
       when "Skin Eruptions/Rashes" then 1249
       when "Sores" then 1249
       when "Oral sores" then 5244
       when "Growths/Swellings" then 125201
       when "Itching" then 136455
       when "Abscess" then 150555
       when "Swelling/Growth" then 125201
       when "Hair Loss" then 135591
       when "Kaposi Sarcoma" then 507 else '' end)as Skin,
  Skin_finding_notes,
  (case Eyes
       when "Irritation" then 123074
       when "Visual Disturbance" then 123074
       when "Excessive tearing" then 140940
       when "Eye pain" then 131040
       when "Eye redness" then 127777
       when "Light sensitive" then 140827
       when "Itchy eyes" then 139100 else '' end)as Eyes,
  Eyes_finding_notes,
  (case ENT
       when "Pain" then 160285
       when "Discharge" then 128055
       when "Sore Throat" then 158843
       when "Tinnitus" then 123588
       when "Apnea" then 117698
       when "Hearing disorder" then 117698
       when "Dental caries" then 119558
       when "Erythema" then 118536
       when "Frequent colds" then 106
       when "Gingival bleeding" then 147230
       when "Hairy cell leukoplakia" then 135841
       when "Hoarseness" then 138554
       when "Kaposi Sarcoma" then 507
       when "Masses" then 152228
       when "Nasal discharge" then 152228
       when "Nosebleed" then 133499
       when "Nasal discharge" then 128055
       when "Post nasal discharge" then 110099
       when "Sinus problems" then 126423
       when "Snoring" then 126318
       when "Oral sores" then 5244
       when "Thrush" then 5334
       when "Toothache" then 124601
       when "Ulcers" then 123919
       when "Vertigo" then 111525 else '' end)as ENT,
  ENT_finding_notes,
      (case Chest
       when "Bronchial breathing" then 146893
       when "Crackles" then 127640
       when "Dullness" then 145712
       when "Reduced breathing" then 164440
       when "Respiratory distress" then 127639
       when "Wheezing" then 5209 else '' end)as Chest,
  Chest_finding_notes,
  (case CVS
       when "Elevated blood pressure" then 140147
       when "Irregular heartbeat" then 136522
       when "Cardiac murmur" then 562
       when "Cardiac rub" then 130560  else '' end)as CVS,
  CVS_finding_notes,
  (case Abdomen
       when "Abdominal distension" then 150915
       when "Distension" then 150915
       when "Hepatomegaly" then 5008
       when "Abdominal mass" then 5103
       when "Mass" then 5103
       when "Splenomegaly" then 5009
       when "Abdominal tenderness" then 5105
       when "Tenderness" then 5105 else '' end)as Abdomen,
  Abdomen_finding_notes,
 (case CNS
       when "Altered sensations" then 118872
       when "Bulging fontenelle" then 1836
       when "Abnormal reflexes" then 150817
       when "Confusion" then 120345
       when "Confused" then 120345
       when "Limb weakness" then 157498
       when "Stiff neck" then 112721
       when "Kernicterus" then 136282 else '' end)as CNS,
  CNS_finding_notes,
 (case Genitourinary
       when "Bleeding" then 147241
       when "Rectal discharge" then 154311
       when "Urethral discharge" then 123529
       when "Vaginal discharge" then 123396
       when "Ulceration" then 124087 else '' end)as Genitourinary,
  Genitourinary_finding_notes,
  Diagnosis,
  Treatment_plan,
  (case Ctx_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else '' end)as Ctx_adherence,
  (case Ctx_dispensed
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Ctx_dispensed,
  (case Dapsone_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else '' end)as Dapsone_adherence,
  (case Dapsone_dispensed
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Dapsone_dispensed,
  (case Morisky_forget_taking_drugs
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_forget_taking_drugs,
  (case Morisky_careless_taking_drugs
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_careless_taking_drugs,
  (case Morisky_stop_taking_drugs_feeling_worse
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_feeling_worse,
  (case Morisky_stop_taking_drugs_feeling_better
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_feeling_better,
  (case Morisky_took_drugs_yesterday
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_took_drugs_yesterday,
  (case Morisky_stop_taking_drugs_symptoms_under_control
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_stop_taking_drugs_symptoms_under_control,
  (case Morisky_feel_under_pressure_on_treatment_plan
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Morisky_feel_under_pressure_on_treatment_plan,
  (case Morisky_how_often_difficulty_remembering
       when "Sometimes" then 1385
       when "Once in a while" then 159416
       when "Never/Rarely" then 1090
       when "Usually" then 1804
       when "All the time" then 1358 else '' end)as Morisky_how_often_difficulty_remembering,
  (case Arv_adherence
       when "Good" then 159405
       when "Fair" then 163794
       when "Inadequate" then 159407
       when "Poor" then 159407 else '' end)as Arv_adherence,
  (case Condom_provided
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Condom_provided,
  (case Screened_for_substance_abuse
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Screened_for_substance_abuse,
  (case Pwp_disclosure
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Pwp_disclosure,
  (case Pwp_partner_tested
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Pwp_partner_tested,
  (case Cacx_screening
       when "Yes" then 1065
       when "yes" then 1065
       when "No" then 1066
       when "Never" then 1090
       when "Not Applicable" then 1175 end)as Cacx_screening,
  (case Screened_for_sti
       when "Yes" then 1065
       when "No" then 1066 else '' end)as Screened_for_sti,
  (case Stability
       when "Stable" then 1
       when "Unstable" then 2 else '' end)as Stability,
  Next_appointment_date,
(case Next_appointment_reason
       when "Follow Up" then 160523
       when "Lab Tests" then 1283
       when "Counseling" then 159382
       when "Pharmacy Refill" then 160521
       when "Treatment Preparation" then 159382
       when "ART Fast Track Referral" then 160521
       when "Other" then 5622 else '' end)as Next_appointment_reason,
  (case Appointment_type
       when "Standard Care" then 164942
       when "Express Care" then 164943
       when "Fast Track" then 164943
       when "Facility ART Distribution Group" then 164946
       when "Community Based Dispensing" then 164944
       when "Community ART Distribution - HCW Led" then 164944
       when "Community ART Distribution - Peer Led" then 164945
       when "Other" then 5622 else '' end)as Appointment_type,
  (case Differentiated_care
       when "Yes" then 164947
       when "No" then 164942 else '' end)as Differentiated_care,
  Voided
 FROM migration_st.st_hiv_followup ;





	
	
	
	
	
	