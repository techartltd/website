-- Migration Scripts : Staging to be run First before loading MSSQL Data
-- Description : Creates tables for RAW Data from IQCARE 
DROP DATABASE IF EXISTS migration_st;
CREATE DATABASE migration_st;
-- DDL
-- Staging Database Scripts
-- 1. Demographics/Registration  DDL
DROP TABLE IF EXISTS migration_st.st_demographics;
CREATE TABLE migration_st.st_demographics
(
  Person_Id             INT(11),
  First_Name            VARCHAR(100),
  Middle_Name           VARCHAR(100),
  Last_Name             VARCHAR(100),
  Nickname              VARCHAR(100),
  DOB                   DATE NULL,
  Exact_DOB             VARCHAR(100),
  Sex                   VARCHAR(50),
  UPN                   VARCHAR(300),
  Encounter_Date        DATE,
  Encounter_ID          VARCHAR(100),
  National_id_no        VARCHAR(100),
  Patient_clinic_number VARCHAR(100),
  Birth_certificate     VARCHAR(100),
  Birth_notification    VARCHAR(100),
  Hei_no                VARCHAR(100),
  Passport              VARCHAR(100),
  Alien_registration    VARCHAR(100),
  Phone_number          VARCHAR(100),
  Alternate_Phone_number VARCHAR(100),
  Postal_Address        VARCHAR(100),
  Email_address         VARCHAR(100),
  County                VARCHAR(100),
  Sub_county            VARCHAR(100),
  Ward                  VARCHAR(100),
  Village               VARCHAR(255),
  Landmark              VARCHAR(255),
  Nearest_Health_Centre VARCHAR(255),
  Next_of_kin           VARCHAR(255),
  Next_of_kin_phone     VARCHAR(255),
  Next_of_kin_relationship VARCHAR(255),
  Next_of_kin_address   VARCHAR(100),
  Marital_status        VARCHAR(255),
  Occupation            VARCHAR(255),
  Education_level       VARCHAR(255),
  Dead                  VARCHAR(100),
  Death_date            DATE DEFAULT NULL,
  Consent               VARCHAR(255),
  Consent_decline_reason VARCHAR(255),
  voided                INT(11)
);

-- 2. HIV Enrollment
DROP TABLE IF EXISTS migration_st.st_hiv_enrollment;
CREATE TABLE migration_st.st_hiv_enrollment
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(20) NOT NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Patient_Type                     VARCHAR(100),
  Entry_point                      VARCHAR(100),
  TI_Facility                      VARCHAR(100),
  Date_first_enrolled_in_care       DATE,
  Transfer_in_date                  DATE,
  Date_started_art_at_transferring_facility DATE,
  Date_confirmed_hiv_positive       DATE,
  Facility_confirmed_hiv_positive   VARCHAR(100),
  Baseline_arv_use                  VARCHAR(100),
  Purpose_of_baseline_arv_use       VARCHAR(100),
  Baseline_arv_regimen              VARCHAR(100),
  Baseline_arv_regimen_line         VARCHAR(100),
  Baseline_arv_date_last_used       DATE,
  Baseline_who_stage                VARCHAR(50),
  Baseline_cd4_results              INT(11),
  Baseline_cd4_date                 DATE,
  Baseline_vl_results               INT(11),
  Baseline_vl_date                  DATE,
  Baseline_vl_ldl_results           INT(11),
  Baseline_vl_ldl_date              DATE,
  Baseline_HBV_Infected             VARCHAR(50),
  Baseline_TB_Infected              VARCHAR(50),
  Baseline_Pregnant                 VARCHAR(50),
  Baseline_Breastfeeding            VARCHAR(50),
  Baseline_Weight                   DOUBLE,
  Baseline_Height                   DOUBLE,
  Baseline_BMI                      DOUBLE,
  Name_of_treatment_supporter       VARCHAR(255),
  Relationship_of_treatment_supporter INT(11),
  Treatment_supporter_telephone      VARCHAR(100),
  Treatment_supporter_address        VARCHAR(100),
  voided                             INT(11)
);

-- 3. Triage
DROP TABLE IF EXISTS migration_st.st_triage;
CREATE TABLE migration_st.st_triage
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(20) NOT NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Visit_reason                     VARCHAR(255),
  Systolic_pressure                DOUBLE,
  Diastolic_pressure               DOUBLE,
  Respiratory_rate                 DOUBLE,
  Pulse_rate                       DOUBLE,
  Oxygen_saturation                DOUBLE,
  Weight                           DOUBLE,
  Height                           DOUBLE,
  Temperature                      DOUBLE,
  BMI                              DOUBLE,
  Muac                             DOUBLE,
  Weight_for_age_zscore            VARCHAR(100),
  Weight_for_height_zscore         VARCHAR(100),
  BMI_Zscore                       VARCHAR(100),
  Head_circumference               DOUBLE,
  Nutritional_status               INT(11),
  Last_menstrual_period            DATE,
  Nurse_comments                   VARCHAR(255),
  Voided                           INT(11)
);

-- 4. HTS Initial Encounter
DROP TABLE IF EXISTS migration_st.st_hts_initial;
CREATE TABLE migration_st.st_hts_initial
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(50) NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Pop_Type                         VARCHAR(50),
  Key_Pop_Type                     VARCHAR(50),
  Priority_Pop_Type                VARCHAR(50),
  Patient_disabled                 VARCHAR(50),
  Disability                       VARCHAR(100),
  Ever_Tested                      VARCHAR(50),
  Self_Tested                      VARCHAR(50),
  HTS_Strategy                     VARCHAR(100),
  HTS_Entry_Point                  VARCHAR(100),
  Consented                        VARCHAR(50),
  Tested_As                        VARCHAR(100),
  TestType                         VARCHAR(50),
  Test_1_Kit_Name                  VARCHAR(100),
  Test_1_Lot_Number                VARCHAR(100),
  Test_1_Expiry_Date               DATE,
  Test_1_Final_Result              VARCHAR(100),
  Test_2_Kit_Name                  VARCHAR(100),
  Test_2_Lot_Number                VARCHAR(100),
  Test_2_Expiry_Date               DATE,
  Test_2_Final_Result              VARCHAR(100),
  Final_Result                     VARCHAR(100),
  Result_given                     VARCHAR(50),
  Couple_Discordant                VARCHAR(50),
  Tb_Screening_Results             VARCHAR(100),
  Remarks                          VARCHAR(255),
  Voided                           INT(11)
);

-- 5. HTS Retest Encounter
DROP TABLE IF EXISTS migration_st.st_hts_retest;
CREATE TABLE migration_st.st_hts_retest
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(50) NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Pop_Type                         VARCHAR(50),
  Key_Pop_Type                     VARCHAR(50),
  Priority_Pop_Type                VARCHAR(50),
  Patient_disabled                 VARCHAR(50),
  Disability                       VARCHAR(100),
  Ever_Tested                      VARCHAR(50),
  Self_Tested                      VARCHAR(50),
  HTS_Strategy                     VARCHAR(100),
  HTS_Entry_Point                  VARCHAR(100),
  Consented                        VARCHAR(50),
  Tested_As                        VARCHAR(100),
  TestType                         VARCHAR(50),
  Test_1_Kit_Name                  VARCHAR(100),
  Test_1_Lot_Number                VARCHAR(100),
  Test_1_Expiry_Date               DATE,
  Test_1_Final_Result              VARCHAR(100),
  Test_2_Kit_Name                  VARCHAR(100),
  Test_2_Lot_Number                VARCHAR(100),
  Test_2_Expiry_Date               DATE,
  Test_2_Final_Result              VARCHAR(100),
  Final_Result                     VARCHAR(100),
  Result_given                     VARCHAR(50),
  Couple_Discordant                VARCHAR(50),
  Tb_Screening_Results             VARCHAR(100),
  Remarks                          VARCHAR(255),
  Voided                           INT(11)
);


-- 6. Program Enrollment
DROP TABLE IF EXISTS migration_st.st_program_enrollment;
CREATE TABLE migration_st.st_program_enrollment
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(20) NOT NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE
);

-- 7. Program Discontinuation
DROP TABLE IF EXISTS migration_st.st_program_discontinuation;
CREATE TABLE migration_st.st_program_discontinuation
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(20) NOT NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE,
  Care_Ending_Reason               VARCHAR(255),
  Facility_Transfered_To           VARCHAR(255),
  Death_Date                       DATE
);

-- 6. IPT Program 
DROP TABLE IF EXISTS migration_st.st_program_enrollment;
CREATE TABLE migration_st.st_program_enrollment
(
  Person_Id                        INT(11),
  First_Name                       VARCHAR(100) NOT NULL,
  Middle_Name                      VARCHAR(100) NULL,
  Last_Name                        VARCHAR(100) NULL,
  DOB                              DATE NOT NULL,
  Sex                              VARCHAR(10) NOT NULL,
  UPN                              VARCHAR(20) NOT NULL,
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE
);



