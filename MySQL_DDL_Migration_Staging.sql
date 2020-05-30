-- Migration Scripts : Staging to be run First before loading MSSQL Data
-- Description : Creates tables for RAW Data from IQCARE
-- Run First
DROP DATABASE IF EXISTS migration_st;
CREATE DATABASE migration_st;
-- DDL
-- Staging Database Scripts
-- 1. Demographics/Registration  DDL
DROP TABLE IF EXISTS migration_st.st_demographics;
CREATE TABLE migration_st.st_demographics
(
  Person_Id             INT(11),  
  Patient_Id            INT(11),
  Ptn_PK                INT(11),
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
  UPN                              VARCHAR(20),
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
  Relationship_of_treatment_supporter VARCHAR(100),
  Treatment_supporter_telephone      VARCHAR(100),
  Treatment_supporter_address        VARCHAR(100),
  voided                             INT(11)
);

-- 3. Triage
DROP TABLE IF EXISTS migration_st.st_triage;
CREATE TABLE migration_st.st_triage
(
  Person_Id                        INT(11),
  Patient_Id                       INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Visit_reason                     VARCHAR(255),
  Systolic_pressure                VARCHAR(100),
  Diastolic_pressure               VARCHAR(100),
  Respiratory_rate                 VARCHAR(100),
  Pulse_rate                       VARCHAR(100),
  Oxygen_saturation                VARCHAR(100),
  Weight                           VARCHAR(100),
  Height                           VARCHAR(100),
  Temperature                      VARCHAR(100),
  BMI                              VARCHAR(100),
  Muac                             VARCHAR(100),
  Weight_for_age_zscore            VARCHAR(100),
  Weight_for_height_zscore         VARCHAR(100),
  BMI_Zscore                       VARCHAR(100),
  Head_circumference               VARCHAR(100),
  Nutritional_status               VARCHAR(100),
  Last_menstrual_period            DATE,
  Nurse_comments                   TEXT,
  Voided                           INT(11)
);


-- 4. HTS TEST Encounter
DROP TABLE IF EXISTS migration_st.st_hts_test;
CREATE TABLE migration_st.st_hts_test
(
  Person_Id                        INT(11),
  Patient_Id                       INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Pop_Type                         VARCHAR(50),
  Key_Pop_Type                     VARCHAR(50),
  Priority_Pop_Type                VARCHAR(50),
  Patient_disabled                 VARCHAR(50),
  Disability                       VARCHAR(100),
  Ever_Tested                      VARCHAR(50),
  Self_Tested                      VARCHAR(50),
  MonthSinceSelfTest               VARCHAR(50),
  MonthsSinceLastTest              VARCHAR(50),
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
  Remarks                          TEXT,
  Voided                           INT(11)
);

-- 5. HTS Client Tracing
DROP TABLE IF EXISTS migration_st.st_hts_tracing;
CREATE TABLE migration_st.st_hts_tracing
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Contact_Type                     VARCHAR(100),
  Contact_Outcome                  VARCHAR(100),
  Reason_uncontacted               VARCHAR(255),
  OtherReasonSpecify               VARCHAR(255),
  Remarks                          TEXT,
  Voided                           INT(11)
);

-- 6. HTS Referral
DROP TABLE IF EXISTS migration_st.st_hts_referral;
CREATE TABLE migration_st.st_hts_referral
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Facility_Referred                VARCHAR(255),
  Date_To_Be_Enrolled              DATE,
  Remarks                          TEXT,
  Voided                           INT(11)
);
-- 7. HTS Linkage
DROP TABLE IF EXISTS migration_st.st_hts_linkage;
CREATE TABLE migration_st.st_hts_linkage
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Facility_Linked                  VARCHAR(255),
  CCC_Number                       VARCHAR(100),
  Health_Worker_Handed_To          VARCHAR(255),
  Cadre                            VARCHAR(100),
  Date_Enrolled                    DATE,
  ART_Start_Date                   DATE,
  Remarks                          TEXT,
  Voided                           INT(11)
);

-- 8. HTS Contact Listing
DROP TABLE IF EXISTS migration_st.st_hts_contact_listing;
CREATE TABLE migration_st.st_hts_contact_listing
(
  Person_Id                        INT(11),
  Patient_Id                       INT(11),
  Contact_Person_Id                INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Consent                          VARCHAR(50),
  First_Name                       VARCHAR(100),
  Middle_Name                      VARCHAR(100),
  Last_Name                        VARCHAR(100),
  Sex                              VARCHAR(50),
  DoB                              DATE,
  Marital_Status                   VARCHAR(100),
  Physical_Address                 VARCHAR(255),
  Phone_Number                     VARCHAR(100),
  Relationship_To_Index            VARCHAR(100),
  PNSScreeningDate 					DATE,
  Currently_Living_With_Index      VARCHAR(100),
  IPV_Physically_Hurt              VARCHAR(50),
  IPV_Threatened_Hurt              VARCHAR(50),
  IPV_Sexual_Hurt                  VARCHAR(50),
  IPV_Outcome                      VARCHAR(50),
  HIV_Status                       VARCHAR(100),
  PNS_Approach                     VARCHAR(100),
  DateTracingDone					DATE,
  Contact_Type                     VARCHAR(100),
  Contact_Outcome                  VARCHAR(100),
  Reason_uncontacted               VARCHAR(255),
  Booking_Date                     DATE,
  Consent_For_Testing              VARCHAR(50),
  Date_Reminded                    DATE,
  Voided                           INT(11)
);

-- 9. Program Enrollment
DROP TABLE IF EXISTS migration_st.st_program_enrollment;
CREATE TABLE migration_st.st_program_enrollment
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE,
  Created_At                       DATETIME,
  Created_By                       INT(11)
);

-- 10. Program Discontinuation
DROP TABLE IF EXISTS migration_st.st_program_discontinuation;
CREATE TABLE migration_st.st_program_discontinuation
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE,
  Care_Ending_Reason               VARCHAR(255),
  Facility_Transfered_To           VARCHAR(255),
  Death_Date                       DATE
);


-- 11. TB Screening
DROP TABLE IF EXISTS migration_st.st_tb_screening;
CREATE TABLE migration_st.st_tb_screening
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Cough                            VARCHAR(100),
  Fever                            VARCHAR(100),
  Weight_loss                      VARCHAR(100),
  Night_sweats                     VARCHAR(100),
  Tests_Ordered                    VARCHAR(100),
  Sputum_Smear                     VARCHAR(100),
  X_ray                            VARCHAR(100),
  Gene_xpert                       VARCHAR(100),
  Contact_tb_case                  VARCHAR(100),
  Lethergy                         VARCHAR(100), 
  Referral                         VARCHAR(100),
  Clinical_diagnosis               VARCHAR(100),
  Invitation_contacts              VARCHAR(100),
  Evaluated_for_IPT                VARCHAR(100),
  TB_results                       VARCHAR(100),
  created_at                       DATETIME,
  created_by                       INT(11)
);


-- 12. IPT Program Screening
DROP TABLE IF EXISTS migration_st.st_ipt_screening;
CREATE TABLE migration_st.st_ipt_screening
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Yellow_urine                     VARCHAR(100),
  Numbness                         VARCHAR(100),
  Yellow_eyes                      VARCHAR(100),
  Tenderness                       VARCHAR(100),
  IPT_Start_Date                   DATE
);

-- 13. IPT Program Enrollment
DROP TABLE IF EXISTS migration_st.st_ipt_program;
CREATE TABLE migration_st.st_ipt_program
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  IPT_Start_Date                   DATE,
  Indication_for_IPT               VARCHAR(100),
  IPT_Outcome                      VARCHAR(100),
  Outcome_Date                     DATE
);



-- 14. IPT Program Followup
DROP TABLE IF EXISTS migration_st.st_ipt_followup;
CREATE TABLE migration_st.st_ipt_followup
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Ipt_due_date                     DATE DEFAULT NULL,
  Date_collected_ipt               DATE DEFAULT NULL,
  Weight                           DOUBLE,
  Hepatotoxity                     VARCHAR(100) DEFAULT NULL,
  Hepatotoxity_Action			         VARCHAR(400) DEFAULT NULL,
  Peripheral_neuropathy            VARCHAR(100) DEFAULT NULL ,
  Peripheralneuropathy_Action		   VARCHAR(400) DEFAULT NULL,
  Rash                             VARCHAR(100),
  Rash_Action						           VARCHAR(100) DEFAULT NULL,
  Adherence                        VARCHAR(100),
  AdheranceMeasurement_Action		   VARCHAR(500),
  IPT_Outcome                      VARCHAR(100),
  Outcome_Date                     DATE
);

-- 15. Regimen History
DROP TABLE IF EXISTS migration_st.st_regimen_history;
CREATE TABLE migration_st.st_regimen_history
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Regimen                          VARCHAR(200),
  Regimen_Name                     VARCHAR(200),
  Regimen_Line                     VARCHAR(200),
  Date_Started                     DATE,
  Date_Stopped                     DATE,
  Regimen_Discontinued             VARCHAR(200),
  Date_Discontinued                DATE,
  Reason_Discontinued              VARCHAR(255),
  RegimenSwitchTo                  VARCHAR(255),
  CurrentRegimen                   VARCHAR(255),
  Voided                           INT(11),
  Date_voided                      DATE
);

-- 16. HIV Followup
DROP TABLE IF EXISTS migration_st.st_hiv_followup;
CREATE TABLE migration_st.st_hiv_followup
(
  Person_Id                          INT(100),
  Encounter_Date                    DATE,
  Encounter_ID                  		VARCHAR(100),
  Visit_scheduled            	    	VARCHAR(100),
  Visit_by                  	      VARCHAR(100),
  Visit_by_other           		      VARCHAR(100),
  Nutritional_status                VARCHAR(200),
  Population_type                   VARCHAR(200),
  Key_population_type               VARCHAR(200),
  Who_stage            		          VARCHAR(200),
  Clinical_notes                    VARCHAR(1600),
  Last_menstrual_period             DATE,
  Pregnancy_status                  VARCHAR(200),
  FP_status                        VARCHAR(200),
  Wants_pregnancy                   VARCHAR(200),
  Reason_not_using_FP            	 VARCHAR(100),
  Pregnancy_outcome                 VARCHAR(200),
  Anc_number                        VARCHAR(100),
  Anc_profile                       VARCHAR(100),
  Expected_delivery_date            DATE,
  Gravida                           INT(11),
  Parity_term                       INT(11),
  Parity_abortion                   INT(11),
  Family_planning_status            VARCHAR(100),
  Reason_not_using_family_planning  VARCHAR(255),
  General_examinations_findings     VARCHAR(100),
  System_review_finding             VARCHAR(200),
  Skin                              VARCHAR(200),
  Skin_finding_notes                VARCHAR(200),
  Eyes                              VARCHAR(200),
  Eyes_finding_notes                VARCHAR(200),
  ENT                               VARCHAR(200),
  ENT_finding_notes                 VARCHAR(200),
  Chest                             VARCHAR(200),
  Chest_finding_notes               VARCHAR(200),
  CVS                               VARCHAR(200),
  CVS_finding_notes                 VARCHAR(200),
  Abdomen                           VARCHAR(200),
  Abdomen_finding_notes             VARCHAR(200),
  CNS                               VARCHAR(200),
  CNS_finding_notes                 VARCHAR(200),
  Genitourinary                     VARCHAR(200),
  Genitourinary_finding_notes       VARCHAR(200),
  Treatment_plan                    TEXT,
  Ctx_adherence                     VARCHAR(200),
  Ctx_dispensed                     VARCHAR(100),
  Dapsone_adherence                 VARCHAR(200),
  Dapsone_dispensed                 VARCHAR(200),
  Morisky_forget_taking_drugs       VARCHAR(200),
  Morisky_careless_taking_drugs     VARCHAR(200),
  Morisky_stop_taking_drugs_feeling_worse   VARCHAR(200),
  Morisky_stop_taking_drugs_feeling_better  VARCHAR(200),
  Morisky_took_drugs_yesterday      VARCHAR(200),
  Morisky_stop_taking_drugs_symptoms_under_control  VARCHAR(200),
  Morisky_feel_under_pressure_on_treatment_plan     VARCHAR(200),
  Morisky_how_often_difficulty_remembering    VARCHAR(200),
  Arv_adherence                     VARCHAR(200),
  Condom_provided                   VARCHAR(100),
  Screened_for_substance_abuse      VARCHAR(100),
  Pwp_disclosure                    VARCHAR(100),
  Pwp_partner_tested                VARCHAR(100),
  Cacx_screening                    VARCHAR(100),
  Screened_for_sti                  VARCHAR(100),
  Sti_partner_notification          VARCHAR(100),
  Stability                         VARCHAR(200),
  Next_appointment_date             DATE,
  Next_appointment_reason           VARCHAR(255),
  Appointment_type                  VARCHAR(200),
  Differentiated_care               VARCHAR(200),
  Voided                            INT(11)
);



-- 17. Laboratory Extract
DROP TABLE IF EXISTS migration_st.st_laboratory;
CREATE TABLE migration_st.st_laboratory
(
  Person_Id       INT(11),
  Encounter_Date  DATE,
  Encounter_ID    VARCHAR(50),
  Lab_test        VARCHAR(180),
  CD4             VARCHAR(180),
  CD4PERCENT      VARCHAR(180),
  VIRALLOAD       VARCHAR(180),
  VIRALLOADUNDETECTABLE  VARCHAR(180),
  STOREPLASMA     VARCHAR(180),
  HCT             VARCHAR(180),
  HB              VARCHAR(180),
  WBC             VARCHAR(180),
  WBCDIFF         VARCHAR(180),
  WBCDIFF_NEUT    VARCHAR(180),
  WBCDIFF_NEUT_PERCENT VARCHAR(180),
  WBCDIFF_LYMPH   VARCHAR(180),
  WBCDIFF_LYMPH_PERCENT VARCHAR(180),
  WBCDIFF_MONO   VARCHAR(180),
  WBCDIFF_MONO_PERCENT VARCHAR(180),
  WBCDIFF_EOSIN   VARCHAR(180),
  WBCDIFF_EOSIN_PERCENT VARCHAR(180),
  PLATELETS       VARCHAR(180),
  AST_SGOT        VARCHAR(180),
  ALT_SGPT        VARCHAR(180),
  CREATININE      VARCHAR(180),
  CREATININEMM    VARCHAR(180),
  AMYLASE         VARCHAR(180),
  PREGNANCY       VARCHAR(180),
  MALARIA         VARCHAR(180),
  SERUMCRYPTO     VARCHAR(180),
  SPUTUMAFB1      VARCHAR(180),
  SPUTUMAFB2      VARCHAR(180),
  SPUTUMAFB3      VARCHAR(180),
  SPUTUMGRAMSTAIN VARCHAR(180),
  URINALYSIS      VARCHAR(180),
  STOOLSTATUS     VARCHAR(180),
  URINALYSIS_SPECGRAV VARCHAR(180),
  URINALYSIS_GLUCOSE VARCHAR(180),
  URINALYSIS_KETONE VARCHAR(180),
  URINALYSIS_PROTEIN VARCHAR(180),
  URINALYSIS_LEUKEST VARCHAR(180),
  URINALYSIS_NITRATE VARCHAR(180),
  URINALYSIS_BLOOD  VARCHAR(180),
  URINALYSISMICROSCOPICBLOOD VARCHAR(180),
  URINALYSISMICROSCOPICWBC VARCHAR(180),
  URINALYSISMICROSCOPICBACTERIA VARCHAR(180),
  URINALYSISMICROSCOPICCASTS VARCHAR(180),
  CULTURESENSITIVITY  VARCHAR(180),
  STOOL               VARCHAR(180),
  URINECULTURE_SENSIVITY VARCHAR(180),
  CSFCRYPTO           VARCHAR(180),
  CSFINDIAINK         VARCHAR(180),
  CSFGRAMSTAIN        VARCHAR(180),
  CSFCULTURE          VARCHAR(180),
  CSFBIOCHEMISTRY     VARCHAR(180),
  GLUCOSEMG           VARCHAR(180),
  GLUCOSEMM           VARCHAR(180),
  ESR                 VARCHAR(180),
  CELLCOUNTNEUTROPHILS VARCHAR(180),
  CELLCOUNTLYMPHOCYTES VARCHAR(180),
  PROTEIN              VARCHAR(180),
  PROTEINMG            VARCHAR(180),
  PROTEINMM            VARCHAR(180),
  HIVRAPIDTEST         VARCHAR(180),
  CSFBIOCHEMISTRY_GLUCOSE VARCHAR(180),
  CELLCOUNTRBCS        VARCHAR(180),
  RBC                  VARCHAR(180),
  CELLCOUNTWBCS        VARCHAR(180),
  ALBUMIN_MG_DL_       VARCHAR(180),
  COLPOSCOPY_CERVICALCA_FEMALEONLY_ VARCHAR(180),
  CYTOMEGALOVIRUS_CMV_   VARCHAR(180),
  EPSTEINBARRVIRUS_EBV_  VARCHAR(180),
  HDL_MG_DL_             VARCHAR(180),
  HEPATITISAAB_TOTAL     VARCHAR(180),
  HEPATITISAAB_IGM       VARCHAR(180),
  HEPATITISBCORE_ANTIBODYIGM_HBSAB_ VARCHAR(180),
  HEPATITISBCORE_ANTIBODY_TOTAL VARCHAR(180),
  HEPATITISBSURFACE_ANTIBODY_HBSAB_ VARCHAR(180),
  HEPATITISBSURFACE_ANTIGEN_HBSAG_ VARCHAR(180),
  LDL_MG_DL_             VARCHAR(180),
  PAPSMEAR_CERVICALCA_FEMALEONLY_ VARCHAR(180),
  GONORRHEA               VARCHAR(180),
  CHLAMYDIA               VARCHAR(180),
  RECTALPAPSMEAR          VARCHAR(180),
  SYPHILIS_FTA_           VARCHAR(180),
  SYPHILIS_RPR_           VARCHAR(180),
  TOTALCHOLESTEROL_MG_DL_ VARCHAR(180),
  TOXOPLASMAIGGANTIBODY   VARCHAR(180),
  TRIGLYCERIDES_MG_DL_    VARCHAR(180),
  VAGINALINSPECTIONWITHACETICACID_VIA_ VARCHAR(180),
  VARICELLA_CHICKENPOX_    VARCHAR(180),
  HEPATITISCANTIBODY       VARCHAR(180),
  HIVCONFIRM               VARCHAR(180),
  PCR                      VARCHAR(180),
  RDT                      VARCHAR(180),
  MPS                      VARCHAR(180),
  SPECIES_REPORT           VARCHAR(180),
  CAS                      VARCHAR(180),
  SAFB                     VARCHAR(180),
  QBL                      VARCHAR(180),
  GeneXpert                VARCHAR(180),
  Urgency         VARCHAR(50),
  Test_result     VARCHAR(200),
  Lab_Reason      TEXT,
  Date_test_requested DATE,
  Date_test_result_received DATE,
  Test_requested_by VARCHAR(100),
  OrderStatus      VARCHAR(100),
  PreClinicLabDate  DATE,
  ClinicalOrderNotes  TEXT,
  OrderNumber      VARCHAR(100),
  CreateDate       DATE,
  CreatedBy        VARCHAR(100),
  DeletedBy        VARCHAR(100),
  DeleteDate       DATE,
  DeleteReason     VARCHAR(200),
  ResultStatus     VARCHAR(100),
  StatusDate       DATE,
  LabResult        VARCHAR(200),
  ResultValue      VARCHAR(200),
  ResultText       VARCHAR(200),
  ResultOption     VARCHAR(200),
  Undetectable     VARCHAR(200),
  DetectionLimit   VARCHAR(200),
  ResultUnit       VARCHAR(200),
  HasResult        VARCHAR(200),
  LabTestName      VARCHAR(200),
  ParameterName    VARCHAR(200),
  LabDepartmentName VARCHAR(200),
  Voided           INT(11)
);
-- 19. Pharmacy Extract

DROP TABLE IF EXISTS pharmacy_extract;
CREATE TABLE pharmacy_extract
(
  Person_Id       INT(11),
  First_Name      VARCHAR(100) NOT NULL,
  Middle_Name     VARCHAR(100) NULL,
  Last_Name       VARCHAR(100) NULL,
  DOB             DATE         NOT NULL,
  Sex             VARCHAR(10)  NOT NULL,
  UPN             VARCHAR(20)  NOT NULL,
  Encounter_Date  DATE,
  Drug            VARCHAR(100),
  TreatmentProgram VARCHAR(100),
  Is_arv          VARCHAR(50),
  Is_ctx          VARCHAR(50),
  Is_dapsone      VARCHAR(50),
  Prophylaxis	 VARCHAR(50),
  StrengthName		VARCHAR(255),
  Drug_name       VARCHAR(255),
  Dose            VARCHAR(50),
  MorningDose		VARCHAR(50),
  MiddayDose	VARCHAR(50),
  EveningDose	VARCHAR(50),
  NightDose		VARCHAR(50),
  Unit            VARCHAR(50),
  Frequency       VARCHAR(50),
  FrequencyMultiplier	VARCHAR(50),
  Duration        VARCHAR(50),
  Duration_units  VARCHAR(20) ,
  Duration_in_days  VARCHAR(50),
  OrderedQuantity  VARCHAR(100),
  DispensedQuantity VARCHAR(100),
  BatchName VARCHAR(50),
  ExpiryDate DATE,
  Prescription_providerName VARCHAR(50),
  Prescription_provider VARCHAR(50),
  Dispensing_providerName varchar(50),
  Dispensing_provider VARCHAR(50),
  RegimenLine     VARCHAR(50),
  Regimen          VARCHAR(50),
  TreatmentPlan			VARCHAR(50),
  TreatmentPlanReason  VARCHAR(50),
  Adverse_effects  VARCHAR(100),
  Date_of_refill   DATE,
  Voided INT(11),
  Date_voided      DATE

);
-- 20_21.  MCH Enrollment and ANC Visit
DROP TABLE IF EXISTS migration_st.st_mch_enrollment_visit;
CREATE TABLE migration_st.st_mch_enrollment_visit
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Parity                           INT(11),
  Parity_abortion                  INT(11),
  Gravida                          INT(11),
  LMP                              DATE,
  EDD                              DATE,
  Age_at_menarche                  INT(11),
  CervicalCancerComment            VARCHAR(200),
  On_ART_Before_First_ANC          VARCHAR(50),
  Started_ART_ANC                  VARCHAR(50),
  Deworming                        VARCHAR(100),
  IPT_1_3                          VARCHAR(100),
  TT_Dose                          VARCHAR(100),
  Supplementation                  VARCHAR(100),
  Received_ITN                     VARCHAR(100),
  Partner_tested                   VARCHAR(100),
  PartnerHIVResult                 VARCHAR(100),
  Anc_visit_number                 VARCHAR(100),
  Anc_number                       VARCHAR(50),
  Temperature                      DOUBLE,
  Pulse_rate                       DOUBLE,
  Systolic_bp                      DOUBLE,
  Diastolic_bp                     DOUBLE,
  Respiratory_rate                 DOUBLE,
  Oxygen_saturation                VARCHAR(100),
  Weight                           DOUBLE,
  Height                           DOUBLE,
  BMI                              DOUBLE,
  Muac                             DOUBLE,
  Hemoglobin                       DOUBLE,
  Breast_exam_done                 VARCHAR(50),
  Pallor                           VARCHAR(50),
  Maturity                         INT(11),
  Fundal_height                    DOUBLE,
  Fetal_presentation               VARCHAR(100),
  Lie                              VARCHAR(100),
  Fetal_heart_rate                 INT(11),
  Fetal_movement                   VARCHAR(50),
  Who_stage                        VARCHAR(100),
  Cd4                              VARCHAR(100),
  Viral_load_sample_taken          VARCHAR(100),
  Viral_load                       VARCHAR(100),
  Ldl                              VARCHAR(100),
  Hiv_status                       VARCHAR(100),
  Test_1_kit_name                  VARCHAR(50),
  Test_1_kit_lot_no                VARCHAR(50),
  Test_1_kit_expiry                DATE,
  Test_1_result                    VARCHAR(50),
  Test_2_kit_name                  VARCHAR(50),
  Test_2_kit_lot_no                VARCHAR(50),
  Test_2_kit_expiry                DATE,
  Test_2_result                    VARCHAR(50),
  Final_test_result                VARCHAR(50),
  Patient_given_result             VARCHAR(50),
  Partner_hiv_tested               VARCHAR(50),
  Partner_hiv_status               VARCHAR(50),
  Urine_microscopy                 VARCHAR(255),
  Urinary_albumin                  VARCHAR(100),
  Glucose_measurement              VARCHAR(100),
  Urine_ph                         INT(11),
  Urine_gravity                    INT(11),
  Urine_nitrite_test               VARCHAR(100),
  Urine_leukocyte_esterace_test    VARCHAR(100),
  Urinary_ketone                   VARCHAR(100),
  Urine_bile_salt_test             VARCHAR(100),
  Urine_bile_pigment_test          VARCHAR(100),
  Urine_colour                     VARCHAR(100),
  Urine_turbidity                  VARCHAR(100),
  Urine_dipstick_for_blood         VARCHAR(100),
  Syphilis_test_status             VARCHAR(50),
  Syphilis_treated_status          VARCHAR(50),
  Bs_for_mps                       VARCHAR(100),
  Blood_group                      VARCHAR(100),
  Anc_exercises                    VARCHAR(50),
  Tb_screening                     VARCHAR(50),
  Cacx_screening                   VARCHAR(50),
  Cacx_screening_method            VARCHAR(50),
  Prophylaxis_given                VARCHAR(50),
  Baby_azt_dispensed               VARCHAR(50),
  Baby_nvp_dispensed               VARCHAR(50),
  Drug                             VARCHAR(50),
  Dose                             INT(11),
  Units                            VARCHAR(50),
  Frequency                        VARCHAR(50),
  Duration                         INT(11),
  Duration_units                   VARCHAR(50),
  Anc_counselled                   VARCHAR(50),
  Counselled_subject               VARCHAR(100),
  Referred_from                    VARCHAR(100),
  Referred_to                      VARCHAR(100),
  Next_appointment_date            DATE,
  Clinical_notes                   VARCHAR(100),
  Voided                           INT(11)
);



-- 21_22.  MCH Delivery and Discharge
DROP TABLE IF EXISTS migration_st.st_mch_delivery_discharge;
CREATE TABLE migration_st.st_mch_delivery_discharge
(
  Person_Id                       	    	  	INT(11),
  Encounter_Date                              DATE,
  Encounter_ID                                VARCHAR(50),
  Admission_number			                      VARCHAR(200),
  Gestation_Weeks		        		          	  INT(50),
  Duration_Labour			                        INT(50),
  Delivery_Mode				                        VARCHAR(200),
  Delivery_Date_TIme                          DATE,
  DeliveryTime                                VARCHAR(200),
  Placenta_Complete	   				                VARCHAR(100),
  Blood_Loss_Coded						            	  VARCHAR(100),
  Blood_Loss							                    VARCHAR(100),
  Diagnosis							                      VARCHAR(100),
  ManagementPlan					              		  VARCHAR(100),
  Mother_Condition                            VARCHAR(100),
  Death_Audited				                        VARCHAR(100),
  Death_Audit_Date                            DATE,
  Resuscitation_Done					                VARCHAR(100),
  Delivery_Complications				              VARCHAR(100),
  Delivery_Complications_Type		              VARCHAR(200),
  Delivery_Complications_Other	          	  VARCHAR(255),
  Delivery_Place						              	  VARCHAR(200),
  Delivery_Conducted_By					              VARCHAR(200),
  Delivery_Cadre						              	  VARCHAR(100),
  Delivery_Outcome					            		  VARCHAR(100),
  Baby_Name                                   VARCHAR(200),
  Baby_Sex                                    VARCHAR(100),
  Baby_Weight                                 DOUBLE,
  Baby_Condition                              VARCHAR(200),
  Birth_Deformity                             VARCHAR(200),
  TEO_Birth                                   VARCHAR(100),
  BF_At_Birth_Less_1_hr                       VARCHAR(100),
  Apgar_1                                     INT(50),
  Apgar_5                                     INT(50),
  Apgar_10                                    INT(50),
  Test_1_kit_name                             VARCHAR(50),
  Test_1_kit_lot_no                           VARCHAR(50),
  Test_1_kit_expiry                           DATE,
  Test_1_result                               VARCHAR(50),
  Test_2_kit_name                             VARCHAR(50),
  Test_2_kit_lot_no                           VARCHAR(50),
  Test_2_kit_expiry                           DATE,
  Test_2_result                               VARCHAR(50),
  Final_test_result                           VARCHAR(50),
  Test_Type                                   VARCHAR(50),
  Patient_given_result                        VARCHAR(50),
  Partner_hiv_tested                          VARCHAR(50),
  Partner_hiv_status                          VARCHAR(50),
  Next_HIV_Date                               DATE,
  Syphilis_Tested                             VARCHAR(50),
  Syphilis_Treated                            VARCHAR(50),
  Prophylaxis_given                           VARCHAR(50),
  Baby_azt_dispensed                          VARCHAR(50),
  Baby_nvp_dispensed                          VARCHAR(50),
  Clinical_notes                              TEXT,
  Discharge_Date                              DATE,
  Vitamin_A_Supplimentation                   VARCHAR(50),
  Started_ART_In_ANC                          VARCHAR(50),
  Started_ART_In_Mat                          VARCHAR(50),
  Counselled_Infant_Feeding                   VARCHAR(50),
  Baby_Status_On_Discharge                    VARCHAR(200),
  Mother_Status_On_Discharge                  VARCHAR(200),
  Birth_Notification_Number                   VARCHAR(200),
  Referred_From                               VARCHAR(200),
  Referred_To                                 VARCHAR(200),
  Next_Appointment_Date                       DATE,
  Appointment_Reason                          VARCHAR(200),
  Voided                                     INT(11)
);

-- 23. MCH PNC Visit
DROP TABLE IF EXISTS migration_st.st_mch_pnc_visit;
CREATE TABLE migration_st.st_mch_pnc_visit (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  PNC_Register_number			   VARCHAR(100),
  PNC_VisitNumber                  INT(11),
  Delivery_Date  				   DATE,
  Mode_Of_Delivery				   VARCHAR(255),
  Place_Of_delivery				   VARCHAR(255),
  Temperature                      DOUBLE,
  Pulse_rate                       DOUBLE,
  Systolic_bp                      DOUBLE,
  Diastolic_bp                     DOUBLE,
  Respiratory_rate                 DOUBLE,
  Oxygen_saturation                INT(11),
  Weight                           DOUBLE,
  Height                           DOUBLE,
  BMI                              DOUBLE,
  Muac                             DOUBLE,
  General_Condition			       VARCHAR(200),
  Pallor				     	   VARCHAR(100),
  Breast_Examination			   VARCHAR(100),
  PPH						       VARCHAR(100),
  CS_Scar					       VARCHAR(100),
  Haemoglobin				       DOUBLE,
  Involution_Of_Uterus	     	   VARCHAR(100),
  Condition_Of_Episiotomy	       VARCHAR(100),
  Lochia						   VARCHAR(100),
  Counselling_On_Infant_Feeding	   VARCHAR(100),
  Counselling_On_FamilyPlanning	   VARCHAR(100),
  Delivery_outcome				   VARCHAR(100),
  Baby_Condition				   VARCHAR(100),
  Breast_Feeding				   VARCHAR(100),
  Feeding_Method				   VARCHAR(100),
  Umblical_Cord				   	   VARCHAR(100),
  Immunization_Started		       VARCHAR(100),
  DaysPostPartum                   VARCHAR(100),
  Test_1_kit_name                  VARCHAR(50),
  Test_1_kit_lot_no                VARCHAR(50),
  Test_1_kit_expiry                DATE,
  Test_1_result                    VARCHAR(50),
  Test_2_kit_name                  VARCHAR(50),
  Test_2_kit_lot_no                VARCHAR(50),
  Test_2_kit_expiry                DATE,
  Test_2_result                    VARCHAR(50),
  Final_test_result                VARCHAR(50),
  Test_type                        VARCHAR(50),
  Patient_given_result             VARCHAR(50),
  Partner_hiv_tested               VARCHAR(50),
  Partner_hiv_status               VARCHAR(50),
  Prophylaxis_given                VARCHAR(50),
  Baby_azt_dispensed               VARCHAR(50),
  Baby_nvp_dispensed               VARCHAR(50),
  HAART_PNC						   VARCHAR(50),
  Pnc_exercises	                   VARCHAR(50),
  Maternal_condition			   VARCHAR(255),
  Iron_supplementation			   VARCHAR(50),
  CaCx_screening				   VARCHAR(50),
  CaCx_screening_method			   VARCHAR(200),
  Fistula_screening			       VARCHAR(50),
  On_FP	                           VARCHAR(50),
  FP_Method			               VARCHAR(255),
  Referred_From					   VARCHAR(255),
  Referred_To					   VARCHAR(255),
  Diagnosis						   VARCHAR(500),
  Clinical_notes                   VARCHAR(255),
  Next_Appointment_Date            DATE
);

-- 24. HEI Enrollment
DROP TABLE IF EXISTS migration_st.st_hei_enrollment;
CREATE TABLE migration_st.st_hei_enrollment (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Gestation_at_birth 			   DOUBLE,
  Birth_weight 			           DOUBLE,
  Child_exposed 				   VARCHAR(100),
  Hei_id_number 				   VARCHAR(100),
  Spd_number 					   VARCHAR(100),
  Birth_length 					   VARCHAR(100),
  Birth_order 					   VARCHAR(100),
  Birth_type            		   VARCHAR(50),
  Place_of_delivery 	    	   VARCHAR(100),
  Mode_of_delivery 				   VARCHAR(100),
  Birth_notification_number 	   VARCHAR(50),
  Date_birth_notification_number_issued 	DATE,
  Birth_certificate_number 		    VARCHAR(100),
  Date_first_enrolled_in_hei_care 	DATE,
  Birth_registration_place 			VARCHAR(50),
  Birth_registration_date 			DATE,
  Health_Facility_name              VARCHAR(100),
  Community_HealthWorkers_name 		VARCHAR(100),
  Alternative_Contact_name 		  	VARCHAR(100),
  Contacts_For_Alternative_Contact 	VARCHAR(100),
  Need_for_special_care 		    VARCHAR(100),
  Reason_for_special_care 		  	VARCHAR(100),
  TB_contact_history_in_household 	VARCHAR(100),
  Mother_alive 					    VARCHAR(100),
  Mother_breastfeeding 	    	    VARCHAR(100),
  Referral_source 		      	    VARCHAR(100),
  Transfer_in 			        	VARCHAR(100),
  Transfer_in_date 			      	DATE,
  Facility_transferred_from 		VARCHAR(50),
  District_transferred_from 		VARCHAR(50),
  Child_arv_prophylaxis 			VARCHAR(100),
  Mother_on_NVP_during_breastfeeding 	VARCHAR(100),
  Infant_mother_link 				VARCHAR(100),
  Mother_on_pmtct_drugs 		  	VARCHAR(100),
  Mother_on_pmtct_drugs_regimen		VARCHAR(100),
  Mother_on_pmtct_other_regimen 	VARCHAR(300),
  Mother_on_art_at_infant_enrollment 	VARCHAR(100),
  Mother_drug_regimen 				    VARCHAR(100),
  Infant_prophylaxis 		    	VARCHAR(100),
  Infant_prophylaxis_other 	  		VARCHAR(200),
  Mother_linked_to_care             VARCHAR(100),
  Mother_ccc_number 			    VARCHAR(100),
  Voided                           INT(11)
);


-- 25. HEI Followup
DROP TABLE IF EXISTS migration_st.st_hei_followup;
CREATE TABLE migration_st.st_hei_followup (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Weight                          DOUBLE,
  Height                          DOUBLE,
  Primary_care_give			      		VARCHAR(100),
  Infant_feeding                  VARCHAR(100),
  TB_Assessment_Outcome				    VARCHAR(100),
  Social_smile_milestone_Under_2Months   VARCHAR(100),
  Social_smile_milestone_2Months          VARCHAR(100),
  Head_control_milestone_3Months          VARCHAR(100),
  Head_control_milestone_4Months          VARCHAR(100),
  Hand_extension_milestone_9months          VARCHAR(100),
  Sitting_milestone_12months          VARCHAR(100),
  Standing_milestone_15months          VARCHAR(100),
  Walking_milestone_18months          VARCHAR(100),
  Talking_milestone_36months          VARCHAR(100),
  First_DNA_PCRSampleDate             DATE,
  First_DNA_PCRResult                 VARCHAR(100),
  First_DNA_PCRResultDate              DATE,
  Second_DNA_PCRSampleDate             DATE,
  Second_DNA_PCRResult                 VARCHAR(100),
  Second_DNA_PCRResultDate              DATE,
  Third_DNA_PCRSampleDate               DATE,
  Third_DNA_PCRResult                   VARCHAR(100),
  Third_DNA_PCRResultDate               DATE,
  ConfimatoryPCR_SampleDate             DATE,
  ConfirmatoryPCR_Result                VARCHAR(100),
  ConfimatoryPCR_ResultDate              DATE,
  RepeatConfirmatoryPCR_SampleDate       DATE,
  RepeatConfirmatoryPCR_Result           VARCHAR(100),
  RepeatConfirmatoryPCR_ResultDate       DATE,
  BaselineViralLoadSampleDate            DATE,
  BaselineViralLoadResult                VARCHAR(100),
  BaselineViralLoadResultDate            DATE,
  Final_AntibodySampleDate               DATE,
  Final_AntibodyResult                   VARCHAR(100),
  Final_AntibodyResultDate               DATE,
  -- Review_of_systems_developmental VARCHAR(100),
  ARV_prophylaxis_received         VARCHAR(100),
  ARV_prophylaxis_Other_received  VARCHAR(100),
  Dna_pcr_sample_date             DATE,
  Dna_pcr_contextual_status       VARCHAR(100),
  Dna_pcr_results                  VARCHAR(100),
  Dna_pcr_dbs_sample_code          VARCHAR(100),
  Dna_pcr_results_date            DATE,
  Azt_given                       VARCHAR(100),
  Nvp_given                       VARCHAR(100),
  Ctx_given                       VARCHAR(100),
  First_antibody_sample_date      DATE,
  First_antibody_result           VARCHAR(100),
  First_antibody_dbs_sample_code  VARCHAR(100),
  First_antibody_result_date      DATE,
  Final_antibody_sample_date      DATE,
  Final_antibody_result           VARCHAR(100),
  Final_antibody_dbs_sample_code VARCHAR(100),
  Final_antibody_result_date     DATE,
  Tetracycline_Eye_Ointment  	   VARCHAR(100),
  Pupil 								         VARCHAR(100),
  Sight              				    	VARCHAR(100),
  Squint				                 VARCHAR(100),
  Deworming_Drug                 VARCHAR(100),
  Deworming_Dosage_Units         VARCHAR(100),
  Date_of_next_appointment       DATE,
  Comments                       VARCHAR(100),
  Voided                          INT(11)
);


-- 26. HEI Outcome
DROP TABLE IF EXISTS migration_st.st_hei_outcome;
CREATE TABLE migration_st.st_hei_outcome (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Child_hei_outcomes_exit_date     DATE,
  Child_hei_outcomes_HIV_status    VARCHAR(255),
  Voided                           INT(11)
);

-- 27. HEI Immunization
DROP TABLE IF EXISTS migration_st.st_hei_immunization;
CREATE TABLE migration_st.st_hei_immunization (
  Person_Id				  INT(11),
  Encounter_Date		  DATE,
  Encounter_ID			  VARCHAR(50),
  BCG                     VARCHAR(50),
  BCG_Date 				  DATE,
  BCG_Period 			  VARCHAR(50),
  OPV_birth               VARCHAR(50),
  OPV_Birth_Date          DATE,
  OPV_Birth_Period  	  VARCHAR(50),
  OPV_1                   VARCHAR(50),
  OPV_1_Date 			  DATE,
  OPV_1_Period 		      VARCHAR(50),
  OPV_2                   VARCHAR(50),
  OPV_2_Date              DATE,
  OPV_2_Period   		  VARCHAR(100),
  OPV_3                   VARCHAR(50),
  OPV_3_Date              DATE,
  OPV_3_Period		      VARCHAR(50),
  DPT_Hep_B_Hib_1         VARCHAR(50),
  DPT_Hep_B_Hib_2         VARCHAR(50),
  DPT_Hep_B_Hib_3         VARCHAR(50),
  IPV                     VARCHAR(50),
  IPV_Date				  DATE,
  IPV_Period			  VARCHAR(50),
  ROTA_1 				  VARCHAR(100),
  ROTA_1_Date  		      DATE,
  ROTA_1_Period   	      VARCHAR(100),
  ROTA_2  			      VARCHAR(100),
  ROTA_2_Date  		      DATE,
  ROTA_2_Period 	      VARCHAR(100),
  Measles_rubella_1       VARCHAR(50),
  Measles_rubella_2       VARCHAR(50),
  Yellow_fever 		      VARCHAR(50),
  Measles_6_months 	      VARCHAR(100),
  Measles_6_Date          DATE,
  Measles_6_Period        VARCHAR(100),
  Measles_9_Months        VARCHAR(100),
  Measles_9_Date          DATE,
  Measles_9_Period        VARCHAR(100),
  Measles_18_Months       VARCHAR(100),
  Measles_18_Date         DATE,
  Measles_18_Period       VARCHAR(100),
  Pentavalent_1           VARCHAR(100),
  Pentavalent_1_Date      DATE,
  Pentavalent_1_Period    VARCHAR(100),
  Pentavalent_2           VARCHAR(100),
  Pentavalent_2_Date      DATE,
  Pentavalent_2_Period    VARCHAR(100),
  Pentavalent_3           VARCHAR(100),
  Pentavalent_3_Date      DATE,
  Pentavalent_3_Period    VARCHAR(100),
  PCV_10_1                VARCHAR(50),
  PCV_10_1_Date 	      DATE,
  PCV_10_1_Period		  VARCHAR(50),
  PCV_10_2 				  VARCHAR(50),
  PCV_10_2_Date  		  DATE,
  PCV_10_2_Period  		  VARCHAR(50),
  PCV_10_3 			      VARCHAR(50),
  PCV_10_3_Date  		  DATE,
  PCV_10_3_Period 		  VARCHAR(50),
  Other 				  VARCHAR(50),
  Other_Date 			  DATE,
  Other_Period            VARCHAR(50),
  VitaminA_6_months       VARCHAR(50),
  VitaminA_1_yr           VARCHAR(50),
  VitaminA_1_and_half_yr  VARCHAR(50),
  VitaminA_2_yr           VARCHAR(50),
  VitaminA2_to_5_yr      VARCHAR(50),
  fully_immunized         DATE,
  Voided                  INT(11)
);

-- 28. ART Treatment preparation
DROP TABLE IF EXISTS migration_st.st_art_preparation;
CREATE TABLE migration_st.st_art_preparation (
  Person_Id                           INT(11),
  Encounter_Date                      DATE,
  Encounter_ID                        VARCHAR(50),
  Understands_hiv_art_benefits        varchar(10),
  Screened_negative_substance_abuse varchar(10),
  Screened_negative_psychiatric_illness varchar(10),
  HIV_status_disclosure                varchar(10),
  Trained_drug_admin                   varchar(10),
  Informed_drug_side_effects           varchar(10),
  Caregiver_committed                  varchar(10),
  Adherance_barriers_identified        varchar(10),
  Caregiver_location_contacts_known    varchar(10),
  Ready_to_start_art                   varchar(10),
  Identified_drug_time                 varchar(10),
  Treatment_supporter_engaged          varchar(10),
  Support_grp_meeting_awareness        varchar(10),
  Enrolled_in_reminder_system          varchar(10),
  Other_support_systems                varchar(10),
  Voided                              INT(11)
);


-- 29. Enhanced Adherence Screening
DROP TABLE IF EXISTS migration_st.st_enhanced_adherence;
CREATE TABLE migration_st.st_enhanced_adherence (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Session_number                   INT(50),
  First_session_date               DATE,
  Pill_count                       varchar(100),
  Arv_adherence                    varchar(100),
  MMAS4AdherenceRating             varchar(255),
  MMAS4Score                       varchar(255),
  MMAS8Score                       varchar(255),
  MMAS8AdherenceRating             varchar(255),
  Has_vl_results                   varchar(100),
  Vl_results_suppressed            varchar(100),
  Vl_results_feeling               varchar(255),
  Cause_of_high_vl                 varchar(255),
  Way_forward                      varchar(255),
  Patient_hiv_knowledge            varchar(255),
  Patient_drugs_uptake             varchar(255),
  Patient_drugs_reminder_tools     varchar(255),
  Patient_drugs_uptake_during_travels varchar(255),
  Patient_drugs_side_effects_response varchar(255),
  Patient_drugs_uptake_most_difficult_times varchar(255),
  Patient_drugs_daily_uptake_feeling varchar(255),
  Patient_ambitions                  varchar(255),
  Patient_has_people_to_talk         varchar(100),
  Patient_enlisting_social_support   varchar(255),
  Patient_income_sources             varchar(255),
  Patient_challenges_reaching_clinicScreening varchar(255),
  Patient_challenges_reaching_clinic varchar(100),
  Patient_worried_of_accidental_disclosureScreening varchar(100),
  Patient_worried_of_accidental_disclosure varchar(100),
  Patient_treated_differentlyScreening varchar(100),
  Patient_treated_differently        varchar(100),
  Stigma_hinders_adherenceScreening  varchar(100),
  Stigma_hinders_adherence           varchar(100),
  Patient_tried_faith_healingScreening varchar(100),
  Patient_tried_faith_healing        varchar(100),
  Patient_adherence_improved         varchar(100),
  Patient_doses_missed               varchar(100),
  Review_and_barriers_to_adherence   TEXT,
  Other_referrals                    varchar(100),
  Appointments_honoured              varchar(100),
  Referral_experience                varchar(255),
  Home_visit_benefit                 varchar(100),
  Adherence_plan                     varchar(255),
  Next_appointment_date              varchar(255),
  Voided                             INT(11)
);


-- 30. Defaulter tracing
DROP TABLE IF EXISTS migration_st.st_defaulter_tracing;
CREATE TABLE migration_st.st_defaulter_tracing (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Tracing_type                     VARCHAR(100),
  Tracing_outcome                  VARCHAR(100),
  Attempt_number                   VARCHAR(100),
  Is_final_trace                   VARCHAR(100),
  True_status                      VARCHAR(100),
  Cause_of_death                   VARCHAR(100),
  Comments                         VARCHAR(100),
  Voided                           INT(11)
);


-- 31. Gender Based Violence Screening (Grouped)
DROP TABLE IF EXISTS migration_st.st_gbv_screening;
CREATE TABLE migration_st.st_gbv_screening (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Violence_withing_past_year       VARCHAR(100),
  Physical_hurt                    VARCHAR(100),
  Threatens                        VARCHAR(100),
  Sexual_violence                  VARCHAR(100),
  Violence_from_unrelated_person   VARCHAR(100),
  Voided                           INT(11)
);

/* -- 32. Alcohol and drug abuse screening
DROP TABLE IF EXISTS migration_st.st_alcohol_screening;
CREATE TABLE migration_st.st_alcohol_screening (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Alcohol_frequency                VARCHAR(100),
  Smoking_frequency                VARCHAR(100),
  Drugs_frequency                  VARCHAR(100)
);
*/

-- 32A. Alcohol and drug abuse screening_cage
CREATE TABLE migration_st.st_cage_alcohol_screening (
  Person_Id     						      INT(11),
  Encounter_Date					      	DATE,
  Encounter_ID 						        VARCHAR(50),
  DrinkAlcohol 					        	VARCHAR(200),
  Smoke 							          	VARCHAR(200),
  UseDrugs						          	VARCHAR(200),
  TriedStopSmoking 				    		VARCHAR(200),
  FeltCutDownDrinkingorDrugUse 			VARCHAR(200),
  AnnoyedByCriticizingDrinkingorDrugUse   VARCHAR(200),
  FeltGuiltyDrinkingorDrugUse 			VARCHAR(200),
  UseToSteadyNervesGetRidHangover 		VARCHAR(200),
  AlcoholRiskLevel						    VARCHAR(200),
  AlcoholScore 						      	VARCHAR(200),
  Notes 								           VARCHAR(1000)

);


-- 32B. Alcohol and drug abuse screening_craft
CREATE TABLE migration_st.st_craft_alcohol_screening (
  Person_Id 						      INT(11),
  Encounter_Date				      DATE,
  DrinkAlcoholMorethanSips  	varchar(200),
  SmokeAnyMarijuana 				  varchar(200),
  UseAnythingElseGetHigh  		 varchar(200),
  CARDrivenandHigh 			    	varchar(200),
  UseDrugorAlcoholRelax 			varchar(200),
  UseDrugByYourself 			  	varchar(200),
  ForgetWhileUsingAlcohol 		varchar(200),
  FamilyTellYouCutDownDrugs 	varchar(200),
  TroubleWhileUsingDrugs 	  	varchar(200),
  AlcoholRiskLevel 			    	varchar(400),
  AlcoholScore 					      varchar(400),
  Notes 						        	varchar(400),
  Voided 						          INT(11)
);

-- 33. Creating OTZ enrollment table
DROP TABLE IF EXISTS migration_st.st_otz_enrolment;
CREATE TABLE migration_st.st_otz_enrolment (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Orientation                      VARCHAR(100),
  Leadership                       VARCHAR(100),
  Participation                    VARCHAR(100),
  Treatment_literacy               VARCHAR(100),
  Transition_to_adult_care         VARCHAR(10),
  Making_decision_future           VARCHAR(100),
  Srh                              VARCHAR(100),
  Beyond_third_ninety              VARCHAR(100),
  Transfer_in                      VARCHAR(100),
  Initial_Enrolment_Date           DATE,
  voided                           INT(11)
);

-- 34. Creating OTZ activity table
DROP TABLE IF EXISTS migration_st.st_otz_activity;
CREATE TABLE migration_st.st_otz_activity (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Orientation                      VARCHAR(255),
  Leadership                       VARCHAR(255),
  Participation                    VARCHAR(255),
  Treatment_Literacy               VARCHAR(255),
  Transition_to_Adult_Care         VARCHAR(255),
  Making_Decision_Future           VARCHAR(255),
  srh                              VARCHAR(255),
  Beyond_Third_Ninety              VARCHAR(255),
  Attended_Support_Group           VARCHAR(255),
  Remarks                          TEXT,
  Voided                           INT(11)
);

-- 35. Creating OVC enrollment table
DROP TABLE IF EXISTS migration_st.st_ovc_enrolment;
CREATE TABLE migration_st.st_ovc_enrolment (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Caregiver_enrolled_here          VARCHAR(255),
  Caregiver_name                   VARCHAR(255),
  Caregiver_gender                 VARCHAR(255),
  Relationship_to_Client           VARCHAR(255),
  Caregiver_Phone_Number           VARCHAR(255),
  Client_Enrolled_cpims            VARCHAR(255),
  Partner_Offering_OVC             VARCHAR(255),
  Voided                           INT(11)
);

-- 36. Creating OTZ Outcome table
DROP TABLE IF EXISTS migration_st.st_otz_outcome;
CREATE TABLE migration_st.st_otz_outcome (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Discontinuation_Reason           VARCHAR(255),
  Death_Date                       DATE,
  Transfer_Facility                VARCHAR(255),
  Transfer_Date                    DATE,
  Voided                           int(11)
);

-- 37. Creating OVC Outcome table
DROP TABLE IF EXISTS migration_st.st_ovc_outcome;
CREATE TABLE migration_st.st_ovc_outcome (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Exit_Reason                      VARCHAR(255),
  Transfer_Facility                VARCHAR(255),
  Transfer_Date                    DATE,
  Voided                           int(11)
);

-- 38. Creating Complaints table
DROP TABLE IF EXISTS migration_st.st_complaints;
CREATE TABLE migration_st.st_complaints (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Presenting_complaints 	         VARCHAR(200),
  Complaint                        VARCHAR(255),
  Duration                         VARCHAR(100),
  Onset_Date                       DATE,
  Voided                           int(11)
);

-- 39. Creating Allergies table
DROP TABLE IF EXISTS migration_st.st_allergies;
CREATE TABLE migration_st.st_allergies (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Has_known_allergies              VARCHAR(200),
  Allergies_causative_agents       VARCHAR(200),
  Allergies_reactions              VARCHAR(200),
  Allergies_severity               VARCHAR(200),
  Voided                           int(11)
);

-- 40. Creating Chronic Illness table
DROP TABLE IF EXISTS migration_st.st_chronic_illness;
CREATE TABLE migration_st.st_chronic_illness (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Has_Chronic_illnesses_cormobidities VARCHAR(200),
  Chronic_illnesses_name            VARCHAR(200),
  Chronic_illnesses_onset_date      DATE,
  Treatment 						VARCHAR(200),
  Dose								int(11),
  Duration						     int(11),
  Voided                           int(11)
);

-- 41. Creating Adverse Drug Reactions table
DROP TABLE IF EXISTS migration_st.st_drug_reactions;
CREATE TABLE migration_st.st_drug_reactions (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Has_adverse_drug_reaction        VARCHAR(200),
  Medicine_causing_drug_reaction   VARCHAR(200),
  Drug_reaction                    VARCHAR(200),
  Drug_reaction_severity           VARCHAR(200),
  Drug_reaction_onset_date         DATE,
  Drug_reaction_action_taken       VARCHAR(200),
  Voided                           int(11)
);

-- 42. Creating Family planning  table
DROP TABLE IF EXISTS migration_st.st_fp_methods;
CREATE TABLE migration_st.st_fp_methods (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Family_planning_method           VARCHAR(255),
  Voided                           int(11)
);

-- 43. Creating Diagnosis table
DROP TABLE IF EXISTS migration_st.st_diagnosis;
CREATE TABLE migration_st.st_diagnosis (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Diagnosis                        VARCHAR(200),
  ManagementPlan				  VARCHAR(300),
  Voided                           int(11)
);

-- 44. Creating Vaccinations table
DROP TABLE IF EXISTS migration_st.st_vaccinations;
CREATE TABLE migration_st.st_vaccinations (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Vaccinations_today                VARCHAR(200),
  Vaccine_Stage			              	VARCHAR(200),
  Vaccination_Date 		            	DATE,
  Voided                           int(11)
);

-- 45. Creating Family History table
DROP TABLE IF EXISTS migration_st.st_family_history;
CREATE TABLE migration_st.st_family_history (
  Person_Id                        INT(11),
  Relative_Person_Id				INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Name                             VARCHAR(255),
  RelativeFirst_Name 				VARCHAR(255),
  RelativeMiddle_Name				VARCHAR(255),
  RelativeLast_Name					VARCHAR(255),
  DoB								DATE,
  Age			              	         INT(11),
  Age_unit 		                   	 VARCHAR(200),
  Relationship 		                 VARCHAR(200),
  BaselineResult					VARCHAR(200),
  Hiv_status 		                   VARCHAR(100),
  In_Care 		                     VARCHAR(100),
  Linkage_CCC_Number 					VARCHAR(100),
  CCC_Number 		                   VARCHAR(200),
  Voided                           int(11)
);

-- 46. Creating ART Fast Track table
DROP TABLE IF EXISTS migration_st.st_family_history;
CREATE TABLE migration_st.st_family_history (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Refill_model                     VARCHAR(200),
  Condoms_dispensed     	         VARCHAR(100),
  Missed_doses                   	 VARCHAR(100),
  Fatigue                       	 VARCHAR(100),
  Cough                         	 VARCHAR(100),
  Fever                         	 VARCHAR(100),
  Rash                          	 VARCHAR(100),
  Nausea_vomiting                	 VARCHAR(100),
  Genital_sore_discharge         	 VARCHAR(100),
  Diarrhea                       	 VARCHAR(100),
  Other_symptoms                 	 TEXT,
  Other_medications                VARCHAR(50),
  Other_medications_specify      	 TEXT,
  Pregnancy_status               	 VARCHAR(50),
  FP_use                        	 VARCHAR(500),
  FP_use_specify                   TEXT,
  Reason_not_using_FP            	 VARCHAR(100),
  Referred                         VARCHAR(100),
  Referral_specify                 VARCHAR(100),
  Next_Appointment_Date            DATE,
  Voided                           int(11)
);

-- 47. Creating Users table
DROP TABLE IF EXISTS  migration_st.st_users;
CREATE TABLE migration_st.st_users
(
	User_Id			INT(11),
	First_Name		VARCHAR(100),
	Last_Name		VARCHAR(100),
	User_Name		VARCHAR(100),
	Status			VARCHAR(100),
	Designation		VARCHAR(100),
	GroupNames		VARCHAR(100),
	OpenMRS_User_Id INT(11)
);

-- 48. Creating Population_Type table
DROP TABLE IF EXISTS migration_st.st_population_type;
CREATE TABLE migration_st.st_population_type (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Population_Type                  VARCHAR(255),
  Key_Population_Type              VARCHAR(255),
  Voided                           int(11)
);

-- 49. Creating Disability table
DROP TABLE IF EXISTS migration_st.st_disability;
CREATE TABLE migration_st.st_disability (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Disability                       VARCHAR(100),
  Disability_Type                  VARCHAR(255),
  Voided                           int(11)
);

-- 50. Creating Initial HIV_Test table
DROP TABLE IF EXISTS migration_st.st_initial_hiv_test;
CREATE TABLE migration_st.st_initial_hiv_test (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Test_1_Kit_Name                  VARCHAR(100),
  Test_1_Lot_Number                VARCHAR(100),
  Test_1_Expiry_Date               DATE,
  Test_1_Final_Result              VARCHAR(100),
  Voided                           int(11)
);

-- 49. Creating Disability table
DROP TABLE IF EXISTS migration_st.st_disability;
CREATE TABLE migration_st.st_disability (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Disability                       VARCHAR(100),
  Disability_Type                  VARCHAR(255),
  Voided                           int(11)
);

-- 50. Creating Initial HIV_Test table
DROP TABLE IF EXISTS migration_st.st_initial_hiv_test;
CREATE TABLE migration_st.st_initial_hiv_test (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Test_1_Kit_Name                  VARCHAR(100),
  Test_1_Lot_Number                VARCHAR(100),
  Test_1_Expiry_Date               DATE,
  Test_1_Final_Result              VARCHAR(100),
  Voided                           int(11)
);

-- 51. Creating Confirmatory HIV_Test table
DROP TABLE IF EXISTS migration_st.st_confirmatory_test;
CREATE TABLE migration_st.st_confirmatory_test (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Test_2_Kit_Name                  VARCHAR(100),
  Test_2_Lot_Number                VARCHAR(100),
  Test_2_Expiry_Date               DATE,
  Test_2_Final_Result              VARCHAR(100),
  Final_Result                     VARCHAR(100),
  Result_given                     VARCHAR(50),
  Voided                           int(11)
);

-- 52. Creating obstetric history table
DROP TABLE IF EXISTS migration_st.st_obstetric_history;
CREATE TABLE migration_st.st_obstetric_history (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Pregnancy_order                  VARCHAR(100),
  Year                             VARCHAR(100),
  Number_ANC_Visits_Attended       VARCHAR(255),
  Place_of_delivery                VARCHAR(100),
  Maturity_in_weeks                VARCHAR(100),
  Duration_of_labour               VARCHAR(255),
  Type_of_delivery                 VARCHAR(255),
  Birth_weight                     VARCHAR(50),
  Sex                              VARCHAR(50),
  Outcome                          VARCHAR(255),
  Puerperium_events                VARCHAR(255),
  Voided                           int(11)
);


-- 53. Creating case summary table
DROP TABLE IF EXISTS migration_st.st_case_summary;
CREATE TABLE migration_st.st_case_summary

	Person_Id							int(11),
	Encounter_Date						DATE,				
	Encounter_ID						 VARCHAR(50),
	PrimaryReasonConsulation			VARCHAR(8000),
	CaseClinicalEvaluation				VARCHAR(8000),
	NoAdherenceCounsellingAssessment	VARCHAR(8000),
	HomeVisits36Months					VARCHAR(8000),
	SupportStructures					varchar(8000),
	EvidenceAdherenceConcerns			VARCHAR(8000),
	NoofDots36Months					VARCHAR(8000),
	NoofDots36Months2					VARCHAR(8000),
	RootCausePoorAdherence				VARCHAR(8000),
	EvaluationTreatmentFailure			VARCHAR(8000),
	EvaluationTreatmentFailureNotes		VARCHAR(8000),
	CommentonTreatment					VARCHAR(8000),
	DrugResistanceSensitivityTesting	VARCHAR(8000),
	MultidisciplinaryTeamDiscussedPatientCase VARCHAR(8000),
	MDTMembers								VARCHAR(8000)
);


-- 54. Creating depression screening table
DROP TABLE IF EXISTS migration_st.st_Depression_Screening;
CREATE TABLE migration_st.st_Depression_Screening
(
	Person_Id						int(11),
	Encounter_Date					DATE,
	Encounter_ID					VARCHAR(50),
	FeelingDownDepressed			VARCHAR(200),
	LittleNoInterest				VARCHAR(200),
	PHQLittleNoInterest				VARCHAR(200),
	PHQFeelingDownDepressed			VARCHAR(200),
	PHQTroubleSleeping				VARCHAR(200),
	PHQFeelingTiredLittleEnergy		VARCHAR(200),
	PHQPoorAppetiteOvereating		VARCHAR(200),
	PHQFeelingBadAboutYourSelf		VARCHAR(200),
	PHQTroubleConcentrating			VARCHAR(200),
	PHQMovingSpeakingSlowly			VARCHAR(200),
	RecommendedManagement			 VARCHAR(200),
	DepressionSeverity				VARCHAR(200),
	DepressionTotal					VARCHAR(200),
);


-- 55. Creating adherence barriers table
DROP TABLE IF EXISTS migration_st.st_Adherence_Barriers;
CREATE TABLE migration_st.st_Adherence_Barriers
(
	Person_Id								INT(11),
	Encounter_Date							DATE
	Encounter_ID							VARCHAR(50),
	AcceptedHivStatus						VARCHAR(200),
	AppropiateDisclosureUnderWay			VARCHAR(200),
	UnderstandingHIVAffectBody				VARCHAR(200),
	UndestandingARTHowWorks					VARCHAR(200),
	UnderstandSideEffects					VARCHAR(200),
	UnderstandBenefitAdherence				VARCHAR(200),
	UnderstandConsequenceNonAdherence		VARCHAR(200),
	AboutTypicalDay							VARCHAR(8000),
	TellHowYouTakeEachMedicine				VARCHAR(8000),
	DoIncaseofVisitTravel					VARCHAR(8000),
	WhoIsThePrimaryGiverLevelCommitment		VARCHAR(8000),
	WhodoyouliveWith						VARCHAR(8000),
	WhoIsAwareHivStatus						VARCHAR(8000),
	SupportSystem							VARCHAR(8000),
	SupportSystemNotes						VARCHAR(8000),
	ChangesRelationshipFamilyMembers		VARCHAR(8000),
	ChangesRelationshipFamilyMembersNotes	VARCHAR(8000),
	BotherFindHivStatus						VARCHAR(8000),
	BotherFindHivStatusNotes				VARCHAR(8000),
	TreatDifferently						VARCHAR(8000),
	TreatDifferentlyNotes					VARCHAR(8000),
	Stigma									VARCHAR(8000),
	StigmaNotes								VARCHAR(8000),
	StopMedicineReligousBelief				VARCHAR(8000),
	StopMedicineReligousBeliefNotes			VARCHAR(8000),
	ReferredToOtherServices					VARCHAR(8000),
	AttendAppointments						VARCHAR(8000),
	NeedReorganizedReferrals				VARCHAR(8000),
);


-- 56. Creating followup education table
DROP TABLE IF EXISTS migration_st.st_Followup_Education;
CREATE TABLE migration_st.st_Followup_Education
(
	Person_Id								int(11),
	Encounter_Date							DATE,				
	Encounter_ID							VARCHAR(50),
	CounsellingType							VARCHAR(200),
	CounsellingTopic						VARCHAR(200),
	Comments								VARCHAR(200),
)
