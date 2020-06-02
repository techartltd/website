select
ds.Person_Id as Person_Id,
ds.ptn_pk,
ds.DispensedByDate as Encounter_Date,
NULL as Encounter_ID,
(SELECT Name FROM mst_Decode dc where dc.ID = ds.ProgID) as Program,
dbo.fn_ARTRegimenORDER(REPLACE(REPLACE(REPLACE (REPLACE(ds.RegimenType, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP'),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r')) as Regimen,
CASE WHEN ds.RowNum =1 THEN 'STARTED' ELSE 'SWITCH' END as Drug_Event,
dbo.fn_ARTRegimenORDER(REPLACE(REPLACE(REPLACE (REPLACE(ds.RegimenType, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP'),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r')) as Regimen_Name,
AT.RegimenLine as RegimenLine,
ds.DispensedByDate as Date_Started,
LEAD(ds.DispensedByDate) OVER (PARTITION BY ds.ptn_pk ORDER BY ds.DispensedByDate ASC) as 'Date_Stopped',
REPLACE(REPLACE(REPLACE (CASE WHEN (LEAD(ds.DispensedByDate) OVER (PARTITION BY ds.ptn_pk ORDER BY ds.DispensedByDate ASC)) IS NOT NULL THEN REPLACE(ds.RegimenType, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP') ELSE null end,'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') as Regimen_Discontinued,
LEAD(ds.DispensedByDate) OVER (PARTITION BY ds.ptn_pk ORDER BY ds.DispensedByDate ASC) as [Date_Discontinued],
'' as Reason_Discontinued
,REPLACE(REPLACE(REPLACE (LEAD(REPLACE(ds.RegimenType, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP')) OVER (PARTITION BY ds.ptn_pk ORDER BY ds.DispensedByDate ASC),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') as RegimenSwitchTo
,REPLACE(REPLACE(REPLACE (LAST_VALUE(REPLACE(ds.RegimenType, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP')) OVER (PARTITION BY ds.ptn_pk ORDER BY ds.DispensedByDate asc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') as CurrentRegimen
,0 as Voided
,NULL as Date_Voided

from (select 
*,
(
		CASE 
			WHEN DispensedByDate IS NOT NULL
				THEN ROW_NUMBER() OVER (
						PARTITION BY (
							CASE 
								WHEN DispensedByDate IS NOT NULL
									THEN ptn_pk
								ELSE 0
								END
							) ORDER BY DispensedByDate asc
						)
			END
		) AS RowNum,
		(
		CASE 
			WHEN DispensedByDate IS NOT NULL
				THEN ROW_NUMBER() OVER (
						PARTITION BY (
							CASE 
								WHEN DispensedByDate IS NOT NULL
									THEN ptn_pk
								ELSE 0
								END
							) ORDER BY DispensedByDate desc
						)
			END
		) AS RowNumDesc

from (select 
pt.PersonId as Person_Id,
r.Ptn_Pk,
r.RegimenType, 
o.OrderedByDate, 
o.DispensedByDate,
o.ProgID,
o.ptn_pharmacy_pk,
ROW_NUMBER() OVER (PARTITION BY r.Ptn_pk, dbo.fn_ARTRegimenORDER(REPLACE(REPLACE(REPLACE (REPLACE(
	CASE WHEN r.RegimenType IN ('3TC/ATV/AZT/r','3TC/ATR/AZT','3TC/AZT/ATV/r','ATV/r/3TC/AZT','AZT/3TC/ATV/r','3TC/ATV/AZT','3TC/AZT/ATV','ATV/3TC/AZT') then  'AZT+3TC+ATV/r' 
		when r.RegimenType in  ('3TC/ATV/r/TDF','3TC/TDF/ATV/r','ATV/r/3TC/TDF','3TC/ATV/TDF','3TC/TDF/ATV','ATV/3TC/TDF') then  'TDF+3TC+ATV/r' 
		when r.RegimenType in  ('3TC/LPV/r/TDF','3TC/TDF/LPV/r','LPV/r/3TC/TDF') then  'TDF+3TC+LPV/r'
		when r.RegimenType in  ('3TC/ABC/ATV/r','ABC/3TC/ATV/r','3TC/ABC/ATV') then  'ABC+3TC+ATV/r'               
		when r.RegimenType in  ('3TC/ABC/LPV/r','ABC/3TC/LPV/r','LPV/r/ABC/3TC')  then 'ABC+3TC+LPV/r'   
		when r.RegimenType in  ('3TC/LPV/r/AZT','AZT/3TC/LPV/r','LPV/r/3TC/AZT','3TC/AZT/LPV/r') then  'AZT+3TC+LPV/r'
		when r.RegimenType in  ('3TC/ATR/TDF') then 'TDF+3TC+ATV/r'
	ELSE r.RegimenType END
	, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP'),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r')), rn1 - rn2 ORDER BY DispensedByDate) rn
from dtl_RegimenMap r
inner join ord_PatientPharmacyOrder o on o.ptn_pharmacy_pk = r.OrderID
inner join Patient pt on pt.ptn_pk = r.Ptn_Pk
left join ord_Visit ov on o.VisitID = ov.Visit_Id
left join mst_Decode dc on dc.ID = o.ProgID
inner join (SELECT d.ptn_pharmacy_pk,
        ROW_NUMBER() OVER (PARTITION BY f.ptn_pk ORDER BY d.DispensedByDate) rn1,
        ROW_NUMBER() OVER (PARTITION BY dbo.fn_ARTRegimenORDER(REPLACE(REPLACE(REPLACE (REPLACE(
		CASE WHEN f.RegimenType IN ('3TC/ATV/AZT/r','3TC/ATR/AZT','3TC/AZT/ATV/r','ATV/r/3TC/AZT','AZT/3TC/ATV/r','3TC/ATV/AZT','3TC/AZT/ATV','ATV/3TC/AZT') then  'AZT+3TC+ATV/r' 
			when f.RegimenType in  ('3TC/ATV/r/TDF','3TC/TDF/ATV/r','ATV/r/3TC/TDF','3TC/ATV/TDF','3TC/TDF/ATV','ATV/3TC/TDF') then  'TDF+3TC+ATV/r' 
			when f.RegimenType in  ('3TC/LPV/r/TDF','3TC/TDF/LPV/r','LPV/r/3TC/TDF') then  'TDF+3TC+LPV/r'
			when f.RegimenType in  ('3TC/ABC/ATV/r','ABC/3TC/ATV/r','3TC/ABC/ATV') then  'ABC+3TC+ATV/r'               
			when f.RegimenType in  ('3TC/ABC/LPV/r','ABC/3TC/LPV/r','LPV/r/ABC/3TC')  then 'ABC+3TC+LPV/r'   
			when f.RegimenType in  ('3TC/LPV/r/AZT','AZT/3TC/LPV/r','LPV/r/3TC/AZT','3TC/AZT/LPV/r') then  'AZT+3TC+LPV/r'
			when f.RegimenType in  ('3TC/ATR/TDF') then 'TDF+3TC+ATV/r'
			ELSE f.RegimenType END
		
		, 'AF1A(AZT + 3TC + NVP)', 'AZT+3TC+NVP'),'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r')), f.ptn_pk ORDER BY d.DispensedByDate) rn2
    FROM dtl_RegimenMap f
	inner join ord_PatientPharmacyOrder d on d.ptn_pharmacy_pk = f.OrderID) w on w.ptn_pharmacy_pk = o.ptn_pharmacy_pk
	where o.DispensedByDate IS NOT NULL AND o.ProgID IN (SELECT ID FROM mst_Decode WHERE Name IN ('ART', 'PMTCT'))
) ev 
where ev.rn = 1 and ev.DispensedByDate is not null
) ds
left join (select 
R.ptn_pk,
O.ptn_pharmacy_pk,
CASE WHEN B.DisplayName IS NOT NULL THEN B.DisplayName ELSE 
ISNULL((SELECT  TOP 1 DisplayName FROM LookupItem WHERE Name IN (SELECT CASE MasterName WHEN 'AdultFirstLineRegimen' THEN 'AdultARTFirstLine' WHEN 'AdultSecondlineRegimen' THEN 'AdultARTSecondLine' WHEN 'AdultThirdlineRegimen' THEN 'AdultARTThirdLine' WHEN 'PaedsFirstLineRegimen' THEN 'PaedsARTFirstLine' WHEN 'PaedsSecondlineRegimen' THEN 'PaedsARTSecondLine' WHEN 'PaedsThirdlineRegimen' THEN 'PaedsARTThirdLine' END FROM LookupItemView WHERE ItemName IN 
(CASE (isnull(ascii(SUBSTRING(R.regimentype, 1, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 2, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 3, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 4, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 5, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 6, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 7, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 8, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 9, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 10, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 11, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 12, 1)),0) +
	   isnull(ascii(SUBSTRING(R.regimentype, 13, 1)),0)) 
WHEN 779 /*'3TC/AZT/NVP'*/ THEN CASE WHEN R.age >= 15 THEN 'AF1A' ELSE 'CF1A' END /*'AZT + 3TC + NVP'*/ 
WHEN 760 /*'3TC/AZT/EFV'*/ THEN CASE WHEN R.age >= 15 THEN 'AF1B' ELSE 'CF1B' END /*'AZT + 3TC + EFV '*/
WHEN 758/*'3TC/AZT/DTG'*/ THEN CASE WHEN R.age >= 15 THEN 'AF1D' END /*'AZT + 3TC + DTG '*/
WHEN 762 /*'3TC/NVP/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2A' ELSE 'CF4A' END /*TDF + 3TC + NVP*/
WHEN 743 /*'3TC/EFV/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2B' ELSE 'CF4B' END /*'TDF + 3TC + EFV'*/ 
  --WHEN 914 /*'3TC/ATV/r/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2D' ELSE 'CF4D' END /*'TDF + 3TC + ATV/r'*/
  --WHEN 753 /*'3TC/ATV/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2D' ELSE 'CF4D' END /*'TDF + 3TC + ATV/r'*/
  WHEN 741 /*'3TC/DTG/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2E' END /*'TDF + 3TC + DTG'*/
  WHEN 867 /*'3TC/LOPr/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2F' ELSE 'CF4C' END /*'TDF + 3TC + LPV/r'*/ 
  WHEN 921 /*'3TC/LPV/r/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2F' ELSE 'CF4C' END /*'TDF + 3TC + LPV/r'*/
  --WHEN 741 /*'3TC/RAL/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2G' END /*'TDF + 3TC + RAL'*/
WHEN 933 /*'FTC/ATV/r/TDF'*/ THEN CASE WHEN R.age >= 15 THEN 'AF2H' END /*'TDF + FTC + ATV/r'*/
WHEN 738 /*'3TC/ABC/NVP'*/ THEN CASE WHEN R.age >= 15 THEN 'AF4A' ELSE 'CF2A' END /*'ABC + 3TC + NVP'*/
WHEN 719 /*'3TC/ABC/EFV'*/ THEN CASE WHEN R.age >= 15 THEN 'AF4B' ELSE 'CF2B' END /*'ABC + 3TC + EFV'*/
  WHEN 717 /*'3TC/ABC/DTG'*/ THEN CASE WHEN R.age >= 15 THEN 'AF4C' END /*'ABC + 3TC + DTG'*/
WHEN 938 /*'3TC/AZT/LPV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS1A' ELSE 'CS1A' END /*'AZT + 3TC + LPV/r'*/ 
WHEN 884 /*'3TC/AZT/LOPr'*/ THEN CASE WHEN R.age >= 15 THEN 'AS1A' ELSE 'CS1A' END /*'AZT + 3TC + LPV/r'*/ 
WHEN 770 /*'3TC/AZT/ATV'*/ THEN CASE WHEN R.age >= 15 THEN 'AS1B' ELSE 'CS1B' END /*'AZT + 3TC + ATV/r'*/ 
WHEN 931 /*'3TC/AZT/ATV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS1B' ELSE 'CS1B' END /*'AZT + 3TC + ATV/r'*/
  WHEN 921 /*'3TC/TDF/LPV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS2A' END /*'TDF + 3TC + LPV/r'*/
  WHEN 867 /*'3TC/TDF/LOPr'*/ THEN CASE WHEN R.age >= 15 THEN 'AS2A' END /*'TDF + 3TC + LPV/r'*/
  WHEN 753 /*'3TC/TDF/ATV'*/ THEN CASE WHEN R.age >= 15 THEN 'AS2C' END /*'TDF + 3TC + ATV/r'*/ 
  WHEN 914 /*'3TC/TDF/ATV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS2C' END /*'TDF + 3TC + ATV/r'*/
WHEN 843 /*'3TC/ABC/LOPr'*/ THEN CASE WHEN R.age >= 15 THEN 'AS5A' ELSE 'CS2A' END /*'ABC + 3TC + LPV/r'*/ 
WHEN 897 /*'3TC/ABC/LPV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS5A' ELSE 'CS2A' END /*'ABC + 3TC + LPV/r'*/ 
WHEN 890 /*'3TC/ABC/ATV/r'*/ THEN CASE WHEN R.age >= 15 THEN 'AS5B' ELSE 'CS2C' END /*'ABC + 3TC + ATV/r'*/
WHEN 729 /*'3TC/ABC/ATV'*/ THEN CASE WHEN R.age >= 15 THEN 'AS5B' ELSE 'CS2C' END /*'ABC + 3TC + ATV/r'*/ 
END))),
(SELECT TOP 1 Name FROM lookupitem WHERE Name = 'Unknown'))

END AS RegimenLine

from RegimenMapView R 
INNER JOIN ord_PatientPharmacyOrder O ON O.VisitID = R.Visit_Pk
left join (select * from (select 
Id, 
Name, 
DisplayName 
from LookupItem where Name in ('AdultARTThirdLine','AdultARTSecondLine', 'AdultARTFirstLine', 'PaedsARTFirstLine', 'PaedsARTSecondLine', 'PaedsARTThirdLine')) T) B on B.Id = O.RegimenLine) AT ON AT.ptn_pharmacy_pk = ds.ptn_pharmacy_pk
order by ds.Ptn_Pk, ds.DispensedByDate