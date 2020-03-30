

--3 Triage
SELECT P.PersonId Person_Id
	,P.Id Patient_Id
	,Encounter_Date = format(cast(PM.VisitDate AS DATE), 'yyyy-MM-dd')
	,Encounter_ID = PM.Id
	,Visit_reason = NULL
	,Systolic_pressure = CAST(PV.BPSystolic AS DECIMAL)
	,Diastolic_pressure = CAST(PV.BPDiastolic AS DECIMAL)
	,Respiratory_rate = PV.RespiratoryRate
	,Pulse_rate = PV.HeartRate
	,Oxygen_saturation = PV.SpO2
	,Weight = PV.Weight
	,Height = PV.Height
	,Temperature = PV.Temperature
	,BMI = PV.BMI
	,Muac = PV.Muac
	,Weight_for_age_zscore = PV.WeightForAge
	,Weight_for_height_zscore = PV.WeightForHeight
	,BMI_Zscore = PV.BMIZ
	,Head_circumference = PV.HeadCircumference
	,NULL AS Nutritional_status
	,format(cast(PIR.LMP AS DATE), 'yyyy-MM-dd') AS Last_menstrual_period
	,CAST(PV.NursesComments AS VARCHAR(MAX)) AS Nurse_Comments
	,PV.DeleteFlag AS Voided
FROM [dbo].[PatientVitals] PV
INNER JOIN Patient P ON P.Id = PV.PatientId
INNER JOIN PatientMasterVisit PM ON PM.Id = PV.PatientMasterVisitId
LEFT JOIN PregnancyIndicator PIR ON PIR.PatientMasterVisitId = PM.Id

UNION

SELECT Person_Id = P.PersonId
	,P.Id Patient_Id
	,Encounter_Date = format(cast(OV.VisitDate AS DATE), 'yyyy-MM-dd')
	,Encounter_ID = OV.Visit_Id
	,Visit_reason = NULL
	,Systolic_pressure = DPV.BPSystolic
	,Diastolic_pressure = DPV.BPDiastolic
	,Respiratory_rate = NULL
	,Pulse_rate = NULL
	,Oxygen_saturation = DPV.SP02
	,Weight = DPV.Weight
	,Height = DPV.Height
	,Temperature = DPV.TEMP
	,BMI = NULL
	,Muac = DPV.Muac
	,Weight_for_age_zscore = NULL
	,Weight_for_height_zscore = NULL
	,BMI_Zscore = NULL
	,Head_circumference = NULL
	,NULL AS Nutritional_status
	,format(cast(PCS.LMP AS DATE), 'yyyy-MM-dd') AS Last_menstrual_period
	,NULL AS Nurse_Comments
	,0 AS Voided
FROM dtl_PatientVitals DPV
INNER JOIN Patient P ON p.ptn_pk = DPV.Ptn_pk
INNER JOIN ord_Visit OV ON OV.Visit_Id = DPV.Visit_pk
INNER JOIN dtl_PatientClinicalStatus PCS ON PCS.Visit_pk = OV.Visit_Id;

-- KEY POPULATION
SELECT PersonId Person_Id
	,Pop_Type = PopulationType
	,Key_Pop_Type = (
		SELECT ItemName
		FROM LookupItemView LK
		WHERE LK.ItemId = PopulationCategory
			AND MasterName = 'KeyPopulation'
		)
	,Voided = DeleteFlag
FROM [dbo].[PatientPopulation]

-- DISABILITIES
SELECT PersonId Person_Id
	,Encounter_ID = PatientEncounterID
	,Disability = (
		SELECT ItemName
		FROM LookupItemView
		WHERE MasterName = 'Disabilities' AND ItemId = CD.DisabilityId
		)
	,DeleteFlag Voided
FROM ClientDisability CD


