select DISTINCT paa.PatientId, p.PersonId  as Person_Id,pmv.VisitDate as Encounter_Date
,NULL as Encounter_ID,
(select top 1 DisplayName from LookupItem li where li.Id=paa.ArtRefillModel) as Refill_Model,
NULL as Condoms_Dispensed,
CASE when paa.MissedArvDoses=0 then 'No' when paa.MissedArvDoses=1 then 'Yes' end as Missed_doses,
CASE when paa.Fatigue=0 then 'No' when paa.Fatigue=1 then 'Yes' end as Fatigue,
CASE when paa.Cough=0 then 'No' when paa.Cough=1 then 'Yes' end as Cough,
CASE when paa.Fever=0 then 'No' when paa.Fever=1 then 'Yes' end as Fever,
CASE when paa.Rash=0 then 'No' when paa.Rash=1 then 'Yes' end as Rash,
CASE when paa.Nausea=0 then 'No' when paa.Nausea=1 then 'Yes' end as Nausea_vomiting,
CASE when paa.GenitalSore=0 then 'No' when paa.GenitalSore=1 then 'Yes' end as Genital_sore_discharge,
CASE when paa.Diarrhea=0 then 'No' when paa.Diarrhea=1 then 'Yes' end as Diarrhea,
paa.OtherSymptom as Other_symptoms,
CASE when paa.NewMedication =0 then 'No' when paa.NewMedication=1 then 'Yes' end as Other_medications,
paa.NewMedicationText as Other_medications_specify,
(select top 1 DisplayName from LookupItem li where li.Id=paa.PregnancyStatus)as Pregnancy_Status,
CASE when paa.FamilyPlanning =0 then 'No' when paa.FamilyPlanning=1 then 'Yes' end as FP_use,
paa.FamilyPlanningMethod as FP_use_specify,
NULL as Reason_not_using_FP,
CASE when paa.ReferedToClinic= 0 then 'No' when paa.ReferedToClinic=1 then 'Yes' end as Referred,
NULL as Referral_Specify,
paa.ReferedToClinicDate as Next_Appointment_Date,
paa.DeleteFlag as Voided,
paa.CreateDate,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=paa.CreatedBy) 
as CreatedBy
 from PatientArtDistribution paa
inner join Patient p on p.Id=paa.PatientId
inner join PatientMasterVisit pmv on pmv.Id=paa.PatientMasterVisitId
and pmv.PatientId=paa.PatientId
where paa.DeleteFlag=0
order by 5
