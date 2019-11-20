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

-- 6. Create patient program transformed table
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

-- 7. Discontinuation transformed table
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
     when "Other" then 5622 when "Unknown" then 1067 else "" end) as Care_Ending_Reason,
    Facility_Transfered_To,
    Death_Date
  FROM migration_st.st_program_discontinuation;
  
-- 8. IPT Screening transformed table
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

-- 9. IPT program Enrollment transformed table
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

-- 10. IPT program Followup transformed table
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
	
-- 11. Regimen History transformed table
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
    FROM migration_st.st_regimen_history;
	
	
	
	
	
	
	
	