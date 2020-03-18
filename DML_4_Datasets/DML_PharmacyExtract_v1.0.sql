select 
P.PersonId,
OPPO.OrderedByDate,
NULL Encounter_ID,
RM.RegimenType,
CASE WHEN (select top 1 DrugTypeName from VW_Drug where Drug_pk = DPPO.Drug_Pk) = 'ARV Medication' THEN 'Yes' ELSE 'No' END Is_arv,
CASE WHEN (select DrugName from VW_Drug where DrugName like '%Sulfa/TMX-Cotrimoxazole%' AND Drug_pk = DPPO.Drug_Pk) IS NOT NULL THEN 'Yes' ELSE 'No' END Is_ctx,
CASE WHEN (select DrugName from VW_Drug where DrugName like '%Dapsone%' AND Drug_pk = DPPO.Drug_Pk) IS NOT NULL THEN 'Yes' ELSE 'No' END Is_dapsone,
(select top 1 DrugName from VW_Drug where Drug_pk = DPPO.Drug_Pk) Drug_name,
Dose = (1),
Unit = (select StrengthName from mst_Strength where StrengthId = (SELECT top 1 StrengthId FROM Lnk_DrugStrength where DrugId=DPPO.Drug_Pk)),
Frequency = (select top 1 Name from mst_Frequency where FrequencyID = DPPO.FrequencyID),
Duration = (DPPO.Duration),
Duration_units  = ('days'),  
Prescription_provider = (Select UserFirstName + ' '+ UserLastName from mst_User where UserID = OPPO.UserID),
Dispensing_provider = (Select UserFirstName + ' '+ UserLastName from mst_User where UserID = DPPO.UserID),
Regimen_line = (CASE when OPPO.RegimenLine < 5 and  OPPO.PatientMasterVisitId is null then 
(select [Name]  from mst_RegimenLine where Id=OPPO.RegimenLine) 
WHEN  OPPO.PatientMasterVisitId is not null  then  (select  top 1 [Name] from LookupItem where Id=OPPO.RegimenLine) end),
Date_of_refill = (DATEADD(DAY, DPPO.Duration, OPPO.DispensedByDate))

from ord_PatientPharmacyOrder OPPO
LEFT JOIN dtl_RegimenMap RM ON RM.OrderID = OPPO.ptn_pharmacy_pk
LEFT JOIN dtl_PatientPharmacyOrder DPPO ON OPPO.ptn_pharmacy_pk = DPPO.ptn_pharmacy_pk
LEFT JOIN Patient P ON P.ptn_pk = OPPO.Ptn_pk
order by OPPO.DispensedByDate asc
