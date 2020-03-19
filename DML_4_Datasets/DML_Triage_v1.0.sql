SELECT 
P.PersonId Person_Id,
P.Id Patient_Id,
Encounter_Date = format(cast(PM.VisitDate as date),'yyyy-MM-dd'),
Encounter_ID = PM.Id,
Visit_reason = NULL,
Systolic_pressure = CAST(PV.BPSystolic AS decimal),
Diastolic_pressure = CAST(PV.BPDiastolic AS decimal),
Respiratory_rate = PV.RespiratoryRate,
Pulse_rate = PV.HeartRate,
Oxygen_saturation = PV.SpO2,
Weight = PV.Weight,
Height = PV.Height,
Temperature = PV.Temperature,
BMI = PV.BMI,
Muac = PV.Muac,
Weight_for_age_zscore = PV.WeightForAge,
Weight_for_height_zscore = PV.WeightForHeight,
BMI_Zscore = PV.BMIZ,
Head_circumference = PV.HeadCircumference,
NUll as Nutritional_status,
format(cast(PIR.LMP as date),'yyyy-MM-dd') as Last_menstrual_period,
CAST(PV.NursesComments AS varchar(MAX)) as Nurse_Comments,
PV.DeleteFlag as Voided

FROM [dbo].[PatientVitals] PV
INNER JOIN Patient P ON P.Id = PV.PatientId
INNER JOIN PatientMasterVisit PM ON PM.Id = PV.PatientMasterVisitId
LEFT JOIN PregnancyIndicator PIR ON PIR.PatientMasterVisitId = PM.Id
UNION
SELECT
Person_Id = P.PersonId,
P.Id Patient_Id,
Encounter_Date = format(cast(OV.VisitDate as date),'yyyy-MM-dd'),
Encounter_ID = OV.Visit_Id,
Visit_reason = NULL,
Systolic_pressure = DPV.BPSystolic,
Diastolic_pressure = DPV.BPDiastolic,
Respiratory_rate = NULL,
Pulse_rate = NULL,
Oxygen_saturation = DPV.SP02,
Weight = DPV.Weight,
Height = DPV.Height,
Temperature = DPV.Temp,
BMI = NULL,
Muac = DPV.Muac,
Weight_for_age_zscore = NULL,
Weight_for_height_zscore = NULL,
BMI_Zscore = NULL,
Head_circumference = NULL,
NUll as Nutritional_status,
format(cast(PCS.LMP as date),'yyyy-MM-dd') as Last_menstrual_period,
NULL as Nurse_Comments,
0 as Voided

FROM dtl_PatientVitals DPV
left join Patient P on p.ptn_pk = DPV.Ptn_pk
left join ord_Visit OV ON OV.Visit_Id = DPV.Visit_pk
left join dtl_PatientClinicalStatus PCS ON PCS.Visit_pk = OV.Visit_Id;