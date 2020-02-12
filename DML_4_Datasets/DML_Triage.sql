--3 Triage
exec pr_OpenDecryptedSession;

SELECT
  P.Id,  
  format(cast(PM.VisitDate as date),'yyyy-MM-dd') AS Encounter_Date,
  NULL Visit_reason,
  PV.BPSystolic as Systolic_pressure,
  PV.BPDiastolic as Diastolic_pressure,
  PV.RespiratoryRate,
  PV.HeartRate as Pulse_rate,
  PV.SpO2 as Oxygen_saturation,
  Weight = PV.Weight,
  PV.Height,
  PV.Temperature, 
  PV.BMI as BMI,
  PV.Muac as Muac,
  PV.WeightForAge as Weight_for_age_zscore,
  PV.WeightForHeight as Weight_for_height_zscore,
  PV.BMIZ as BMI_Zscore,
  PV.HeadCircumference as Head_Circumference,
  NUll as Nutritional_status,
  lmp.LMP as Last_menstrual_period,
  NUll as Nurse_Comments,
  PV.DeleteFlag as Voided
FROM Person P
  INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientVitals PV ON PV.PatientId = PT.Id
  INNER JOIN PatientMasterVisit PM ON PM.PatientId = PT.Id
  INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
  INNER JOIN PatientIdentifier PI ON PI.PatientId = PT.Id AND PI.PatientEnrollmentId = PE.Id
  INNER JOIN Identifiers I on PI.IdentifierTypeId=I.Id
  LEFT JOIN (select lm.PatientId,lm.LMP  from(select pid.PatientId,pid.PatientMasterVisitId,pid.LMP,ROW_NUMBER() OVER(Partition by pid.PatientId order by pid.PatientMasterVisitId desc)rownum
 from PregnancyIndicator pid
 where pid.LMP is not null)lm where lm.rownum='1') lmp on lmp.PatientId =PT.Id