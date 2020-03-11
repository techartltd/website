WITH a_CTE (PatientId, Ptn_Pk, RegimenType , DispensedByDate,  VisitDate, TreatmentProgram, RegimenLine, RowNum, PrevNum)  
AS  
-- Define the CTE query.  
(  
    SELECT PatientId, Ptn_Pk, RegimenType, DispensedByDate,  VisitDate, TreatmentProgram, replace(RegimenLine,'ART','') as RegimenLine, 
ROW_NUMBER() OVER(partition by ptn_pk ORDER BY DispensedByDate ASC)  as RowNum,  
ROW_NUMBER() OVER(partition by ptn_pk ORDER BY DispensedByDate ASC) -1 as PrevNum
FROM (SELECT distinct p.id  as PatientId, a.Ptn_Pk, a.RegimenType, b.DispensedByDate, ov.VisitDate,dc.Name as TreatmentProgram, lt.Name as RegimenLine,
ROW_NUMBER() OVER (PARTITION BY a.Ptn_Pk,regimentype ORDER BY DispensedByDate asc) AS rn
From dtl_regimenmap a
inner join patient p on a.Ptn_Pk=p.ptn_pk
Inner Join ord_PatientPharmacyOrder b On a.OrderID = b.ptn_pharmacy_pk 
 left join ord_Visit ov on b.VisitID = ov.Visit_Id
 left join mst_Decode dc on dc.ID =b.ProgID 
 left join LookupItem lt on lt.Id=b.RegimenLine 
And b.ProgID In (222,223)) b
WHERE rn = 1
) 

 select p.Id  as Person_Id,part.DispensedByDate as Encounter_Date
, 'NULL' as Encounter_ID,
 pstart.TreatmentProgram as Program,
 NULL as Regimen,
 pstart.Regimen as Regimen_Name,
 pstart.RegimenLine as Regimen_Line,
 pstart.DispensedByDate as Date_Started, 
  pr.VisitDate as Date_Stopped
 ,pr.Prev_Reg  as Regimen_Discontinued
 ,pr.VisitDate as [Date_Discontinued],
 --pr.TreatmentReason  as Reason_Discontinued
 ''  as Reason_Discontinued
,pr.Regimen as RegimenSwitchTo
 ,part.Regimen as CurrentRegimen
 ,0 as Voided
 ,NULL as Date_Voided
  from (select distinct Ptn_Pk from dtl_RegimenMap pt)ptr 
  inner join Patient pt on pt.ptn_pk=ptr.Ptn_Pk
left join Person p on p.Id =pt.PersonId

-- current regimen
left join (
SELECT PatientId,replace(regimentype,'/','+') as Regimen, DispensedByDate, VisitDate, TreatmentProgram, replace(RegimenLine,'ART','') as RegimenLine
FROM (SELECT distinct p.id  as PatientId, a.Ptn_Pk, a.regimentype, b.DispensedByDate, ov.VisitDate,dc.Name as TreatmentProgram, lt.Name as RegimenLine , 
ROW_NUMBER() OVER (PARTITION BY a.ptn_pk ORDER BY DispensedByDate desc) AS rn
From dtl_regimenmap a
inner join patient p on a.Ptn_Pk=p.ptn_pk
Inner Join ord_PatientPharmacyOrder b On a.OrderID = b.ptn_pharmacy_pk And b.ProgID In (222,223)
 left join ord_Visit ov on b.VisitID = ov.Visit_Id
 left join mst_Decode dc on dc.ID =b.ProgID 
 left join LookupItem lt on lt.Id=b.RegimenLine
) a
WHERE rn = 1 and DispensedByDate is not null 
 )part on part.PatientId=pt.Id

 -- start regimen
left join(SELECT PatientId,replace(regimentype,'/','+') as Regimen, DispensedByDate, VisitDate, TreatmentProgram, replace(RegimenLine,'ART','') as RegimenLine
FROM (SELECT distinct p.id  as PatientId, a.Ptn_Pk, a.regimentype, b.DispensedByDate, ov.VisitDate,dc.Name as TreatmentProgram, lt.Name as RegimenLine , 
ROW_NUMBER() OVER (PARTITION BY a.ptn_pk ORDER BY DispensedByDate asc) AS rn
From dtl_regimenmap a
inner join patient p on a.Ptn_Pk=p.ptn_pk
Inner Join ord_PatientPharmacyOrder b On a.OrderID = b.ptn_pharmacy_pk And b.ProgID In (222,223)
 left join ord_Visit ov on b.VisitID = ov.Visit_Id
 left join mst_Decode dc on dc.ID =b.ProgID 
 left join LookupItem lt on lt.Id=b.RegimenLine
) a
WHERE rn = 1 and DispensedByDate is not null 
)pstart  on pstart.PatientId=pt.Id

-- switches
left join(
Select  PatientId, Ptn_Pk, replace(RegimenType,'/','+') as Regimen, DispensedByDate,  VisitDate, TreatmentProgram, 
replace(RegimenLine,'ART','') as RegimenLine, RowNum   
,case when RowNum>1 then LAG(replace(RegimenType,'/','+')) OVER (ORDER BY ptn_pk,RowNum) else null end as 'Prev_Reg' 
from a_CTE b
where RowNum>1
)pr on pr.PatientId=pt.Id
--where pt.Ptn_Pk=101