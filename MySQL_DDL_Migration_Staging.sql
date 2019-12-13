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
  Patient_Id             INT(11),
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

-- 6. HTS Client Tracing
DROP TABLE IF EXISTS migration_st.st_hts_tracing;
CREATE TABLE migration_st.st_hts_tracing
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Contact_Type                     VARCHAR(100),
  Contact_Outcome                  VARCHAR(100),
  Reason_uncontacted               VARCHAR(255),
  Voided                           INT(11)
);

-- 7. HTS Referral
DROP TABLE IF EXISTS migration_st.st_hts_referral;
CREATE TABLE migration_st.st_hts_referral
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Facility_Referred                VARCHAR(255),
  Date_To_Be_Enrolled              DATE,
  Remarks                          VARCHAR(255),
  Voided                           INT(11)
);
-- 8. HTS Linkage
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
  Remarks                          VARCHAR(255),
  Voided                           INT(11)
);

-- 9. HTS Contact Listing
DROP TABLE IF EXISTS migration_st.st_hts_contact_listing;
CREATE TABLE migration_st.st_hts_contact_listing
(
  Person_Id                        INT(11),
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
  Currently_Living_With_Index      VARCHAR(100),
  IPV_Physically_Hurt              VARCHAR(50),
  IPV_Threatened_Hurt              VARCHAR(50),
  IPV_Physically_Hurt              VARCHAR(50),
  IPV_Sexual_Hurt                  VARCHAR(50),
  IPV_Outcome                      VARCHAR(50),
  HIV_Status                       VARCHAR(100),
  PNS_Approach                     VARCHAR(100),
  Contact_Type                     VARCHAR(100),
  Contact_Outcome                  VARCHAR(100),
  Reason_uncontacted               VARCHAR(255),
  Booking_Date                     DATE,
  Consent_For_Testing              VARCHAR(50),
  Date_Reminded                    DATE,
  Voided                           INT(11)
);

-- 10. Program Enrollment
DROP TABLE IF EXISTS migration_st.st_program_enrollment;
CREATE TABLE migration_st.st_program_enrollment
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Program                          VARCHAR(100),
  Date_Enrolled                    DATE,
  Date_Completed                   DATE
);

-- 11. Program Discontinuation
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
  Presenting_complaints 	          VARCHAR(200),
  Complaint                         VARCHAR(255),
  Duration                          VARCHAR(100),
  Onset_Date                        DATE,
  Clinical_notes                    VARCHAR(1600),
  Has_known_allergies               VARCHAR(200),
  Allergies_causative_agents        VARCHAR(200),
  Allergies_reactions               VARCHAR(200),
  Allergies_severity                VARCHAR(200),
  Has_Chronic_illnesses_cormobidities VARCHAR(200),
  Chronic_illnesses_name            VARCHAR(200),
  Chronic_illnesses_onset_date      DATE,
  Has_adverse_drug_reaction         VARCHAR(200),
  Medicine_causing_drug_reaction    VARCHAR(200),
  Drug_reaction                    VARCHAR(200),
  Drug_reaction_severity            VARCHAR(200),
  Drug_reaction_onset_date          DATE,
  Drug_reaction_action_taken        VARCHAR(200),
  Vaccinations_today                VARCHAR(200),
  Vaccine_Stage			              	VARCHAR(200),
  Vaccination_Date 		            	DATE,
  Last_menstrual_period             DATE,
  Pregnancy_status                  VARCHAR(200),
  Wants_pregnancy                   VARCHAR(200),
  Pregnancy_outcome                 VARCHAR(200),
  Anc_number                        VARCHAR(100),
  Anc_profile                       VARCHAR(100),
  Expected_delivery_date            DATE,
  Gravida                           INT(11),
  Parity                            INT(11),
  Family_planning_status            VARCHAR(100),
  Family_planning_method            VARCHAR(255),
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
  Diagnosis                         VARCHAR(200),
  Treatment_plan                    VARCHAR(255),
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
  Stability                         VARCHAR(200),
  Next_appointment_date             DATE,
  Next_appointment_reason           VARCHAR(255),
  Appointment_type                  VARCHAR(200),
  Differentiated_care               VARCHAR(200),
  Voided                            INT(11)
);


-- 17. Laboratory Extract
DROP TABLE IF EXISTS migration_st.st_laboratory_extract
CREATE TABLE migration_st.st_laboratory_extract
	Person_Id int(11),
	Encounter_Date  DATE,
	Encounter_ID VARCHAR(50),
	Lab_test VARCHAR(180) ,
	Urgency VARCHAR(50),
	Test_Result     VARCHAR(180) ,
	Date_test_Requested DATE,
	Date_test_result_received DATE,
	Test_Requested_By VARCHAR(200),
	PreClinicLabDate DATE,
	ClinicalOrderNotes VARCHAR(200),
	OrderNumber VARCHAR(50),
	CreateDate DATE,
	CreatedBy  VARCHAR(101) ,
	OrderStatus VARCHAR(50),
	DeletedBy VARCHAR(101),
	DeleteDate DATE ,
	DeleteReason VARCHAR(250),
	ResultStatus VARCHAR(50) ,
	StatusDate DATE,
	LabResult VARCHAR(500) ,
	ResultValue decimal(18, 2) ,
	ResultText VARCHAR(500) ,
	ResultOption VARCHAR(50) ,
	Undetectable int(1) ,
	DetectionLimit decimal(18, 2),
	ResultUnit varchar(50) ,
	HasResult int(1) ,
	LabTestName VARCHAR(250) ,
	ParameterName varchar(250) ,
	LabDepartmentName varchar(50),
    Voided INT(11),
);

-- 18. Pharmacy Extract
DROP TABLE IF EXISTS migration_st.st_pharmacy_extract;
CREATE TABLE migration_st.st_pharmacy_extract
(
  Person_Id       INT(11),
  Encounter_Date  DATE,
  Encounter_ID    VARCHAR(50),
  Drug            VARCHAR(100),
  Is_arv          VARCHAR(50),
  Is_ctx          VARCHAR(50),
  Is_dapsone      VARCHAR(50),
  Drug_name       VARCHAR(255),
  Dose            VARCHAR(50),
  Unit            VARCHAR(50),
  Frequency       VARCHAR(50),
  Duration        VARCHAR(50),
  Duration_units  VARCHAR(20) ,
  Duration_in_days  VARCHAR(50),
  Prescription_provider VARCHAR(50),
  Dispensing_provider VARCHAR(50),
  Regimen          VARCHAR(50),
  Adverse_effects  VARCHAR(100),
  Date_of_refill   DATE,
  Voided INT(11),
  Date_voided      DATE

);

-- 19.  MCH Enrollment
DROP TABLE IF EXISTS migration_st.st_mch_enrollment;
CREATE TABLE migration_st.st_mch_enrollment
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Anc_number                       VARCHAR(50),
  Gestation_in_weeks               INT(11),
  Parity                           INT(11),
  Parity_abortion                  INT(11),
  Gravida                          INT(11),
  EDD                              DATE,
  Edd_ultrasound                   DATE,
  Age_at_menarche                  INT(11),
  Tb_screening                     VARCHAR(50),
  lmp                              DATE,
  lmp_estimated                    VARCHAR(50),
  First_anc_visit_date             DATE,
  Hiv_status                       VARCHAR(50),
  Hiv_test_date                    DATE,
  Partner_hiv_status               VARCHAR(50),
  Partner_hiv_test_date            DATE,
  Blood_group                      VARCHAR(100),
  Syphilis_serology                VARCHAR(100),
  Bs_for_mps                       VARCHAR(100),
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
  Voided                           INT(11)
);

-- 20.  MCH ANC Visit
DROP TABLE IF EXISTS migration_st.st_mch_antenatal_visit;
CREATE TABLE migration_st.st_mch_antenatal_visit
(
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  Anc_visit_number                 INT(11),
  Anc_number                       VARCHAR(50),
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
  Hemoglobin                       DOUBLE,
  Breast_exam_done                 VARCHAR(50),
  Pallor                           VARCHAR(50),
  Maturity                         INT(11),
  Fundal_height                    DOUBLE,
  Fetal_presentation               VARCHAR(100),
  Lie                              VARCHAR(100),
  Fetal_heart_rate                 INT(11),
  Fetal_movement                   VARCHAR(50),
  Who_stage                        INT(11),
  Cd4                              INT(11),
  Viral_load_sample_taken          VARCHAR(100),
  Viral_load                       INT(11),
  Ldl                              VARCHAR(100),
  Arv_status                       INT(11),
  Test_1_kit_name                  VARCHAR(50),
  Test_1_kit_lot_no                VARCHAR(50) DEFAULT NULL,
  Test_1_kit_expiry                DATE DEFAULT NULL,
  Test_1_result                    VARCHAR(50) DEFAULT NULL,
  Test_2_kit_name                  VARCHAR(50),
  Test_2_kit_lot_no                VARCHAR(50) DEFAULT NULL,
  Test_2_kit_expiry                DATE DEFAULT NULL,
  Test_2_result                    VARCHAR(50) DEFAULT NULL,
  Final_test_result                VARCHAR(50) DEFAULT NULL,
  Patient_given_result             VARCHAR(50) DEFAULT NULL,
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
  Anc_exercises                    VARCHAR(50),
  Tb_screening                     VARCHAR(50),
  Cacx_screening                   VARCHAR(50),
  Cacx_screening_method            VARCHAR(50),
  Prophylaxis_given                VARCHAR(50),
  Baby_azt_dispensed               VARCHAR(50),
  Baby_nvp_dispensed               VARCHAR(50),
  Has_other_illnes                 VARCHAR(50),
  Illnes_name                      VARCHAR(100),
  Illnes_Onset_Date                DATE,
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

-- 21. MCH Delivery
DROP TABLE IF EXISTS migration_st.st_mch_delivery;
CREATE TABLE migration_st.st_mch_delivery (
  Person_Id                       	    	  	INT(11),
  Encounter_Date                              DATE,
  Encounter_ID                                VARCHAR(50),
  Admission_number			                     	VARCHAR(200),
  Gestation_Weeks		        			            INT(50),
  Duration_Labour			                      	INT(50),
  Delivery_Mode				                        VARCHAR(200),
  Delivery_Date_TIme                     			DATE,
  Placenta_Complete	   				                VARCHAR(100),
  Blood_Loss							                    VARCHAR(100),
  Mother_Condition                          	VARCHAR(100),
  Death_Audited				                        VARCHAR(100),
  Resuscitation_Done					                VARCHAR(100),
  Delivery_Complications				          		VARCHAR(100),
  Delivery_Complications_Type		        			VARCHAR(200),
  Delivery_Complications_Other	        			VARCHAR(255),
  Delivery_Place							              	VARCHAR(200),
  Delivery_Conducted_By					             	VARCHAR(200),
  Delivery_Cadre								              VARCHAR(100),
  Delivery_Outcome							              VARCHAR(100),
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
  Syphilis_Treated                            VARCHAR(50),
  Prophylaxis_given                           VARCHAR(50),
  Baby_azt_dispensed                          VARCHAR(50),
  Baby_nvp_dispensed                          VARCHAR(50),
  Clinical_notes                              VARCHAR(200),
  Next_Appointment_Date                       DATE,
  Voided                                     INT(11)
);

-- 22. MCH Discharge
DROP TABLE IF EXISTS migration_st.st_mch_discharge;
CREATE TABLE migration_st.st_mch_discharge (
  Person_Id                       	    	  	INT(11),
  Encounter_Date                              DATE,
  Encounter_ID                                VARCHAR(50),
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
  Clinical_notes                              VARCHAR(255),
  Next_Appointment_Date                       DATE,
  Voided                                     INT(11)
);

-- 23. MCH PNC Visit
DROP TABLE IF EXISTS migration_st.st_mch_pnc_visit;
CREATE TABLE migration_st.st_mch_pnc_visit (
  Person_Id                        INT(11),
  Encounter_Date                   DATE,
  Encounter_ID                     VARCHAR(50),
  PNC_Register_number			     VARCHAR(100),
  PNC_VisitNumber                  INT(11),
  Delivery_Date  					 DATE,
  Mode_Of_Delivery				 VARCHAR(255),
  Place_Of_delivery				 VARCHAR(255),
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
  General_Condition			     VARCHAR(200),
  Pallor				     		 VARCHAR(100),
  Breast_Examination				 VARCHAR(100),
  PPH						         VARCHAR(100),
  CS_Scar					         VARCHAR(100),
  Haemoglobin				         DOUBLE,
  Involution_Of_Uterus	     	 VARCHAR(100),
  Condition_Of_Episiotomy	         VARCHAR(100),
  Lochia							 VARCHAR(100),
  Councelling_On_Infant_Feeding	 VARCHAR(100),
  Councelling_On_FamilyPlanning	 VARCHAR(100),
  Delivery_outcome				 VARCHAR(100),
  Baby_Condition					 VARCHAR(100),
  Feeding_Method					 VARCHAR(100),
  Umblical_Cord				   	 VARCHAR(100),
  Immunization_Started		     VARCHAR(100),
  Test_1_kit_name                  VARCHAR(50),
  Test_1_kit_lot_no                VARCHAR(50),
  Test_1_kit_expiry                DATE,
  Test_1_result                    VARCHAR(50),
  Test_2_kit_name                  VARCHAR(50),
  Test_2_kit_lot_no                VARCHAR(50),
  Test_2_kit_expiry                DATE,
  Test_2_result                    VARCHAR(50),
  Final_test_result                VARCHAR(50),
  Test_Type                        VARCHAR(50),
  Patient_given_result             VARCHAR(50),
  Partner_hiv_tested               VARCHAR(50),
  Partner_hiv_status               VARCHAR(50),
  Prophylaxis_given                VARCHAR(50),
  Baby_azt_dispensed               VARCHAR(50),
  Baby_nvp_dispensed               VARCHAR(50),
  Pnc_exercises	                 VARCHAR(50),
  Maternal_condition				 VARCHAR(255),
  Iron_supplementation			 VARCHAR(50),
  CaCx_screening					 VARCHAR(50),
  CaCx_screening_method			 VARCHAR(200),
  Fistula_screening			     VARCHAR(50),
  On_FP	                         VARCHAR(50),
  FP_Method			             VARCHAR(255),
  Referred_From					 VARCHAR(255),
  Referred_To					     VARCHAR(255),
  Clinical_notes                   VARCHAR(255),
  Next_Appointment_Date            DATE
);
