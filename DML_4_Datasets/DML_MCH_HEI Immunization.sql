 -- 28. HEI Immunization
	
	
select  p.PersonId,v.VisitDate as Encounter_Date,NULL Encounter_ID,imm.BCG,
imm.BCG_Date,imm.BCG_Period,
imm.OPV_Birth,imm.OPV_Birth_Date,imm.OPV_Birth_Period,
imm.[OPV_1],imm.[OPV_1_Date],imm.[OPV_1_Period],
imm.[OPV_2],imm.[OPV_2_Date],imm.[OPV_2_Period],
imm.[OPV_3],imm.[OPV_3_Date],imm.[OPV_3_Period],
imm.DPT_Hep_B_Hib_1,imm.DPT_Hep_B_Hib_2,imm.DPT_Hep_B_Hib_3,
imm.IPV,imm.IPV_Date,imm.IPV_Period,
imm.ROTA_1,
imm.ROTA_1_Date,
imm.ROTA_1_Period,
imm.ROTA_2,
imm.ROTA_2_Date,
imm.ROTA_2_Period,
convert(varchar(50), NULL) as   Measles_rubella_1 ,
convert(varchar(50), NULL)  as Measles_rubella_2,
convert(varchar(50), NULL) as Yellow_fever,
imm.Measles_6_months,imm.Measles_6_Date,imm.Measles_6_Period,
imm.Measles_9_Months,imm.Measles_9_Date,imm.Measles_9_Period,
imm.Measles_18_Months,imm.Measles_18_Date,imm.Measles_18_Period,
imm.Pentavalent_1,imm.Pentavalent_1_Date,imm.Pentavalent_1_Period,
imm.Pentavalent_2,imm.Pentavalent_2_Date,imm.Pentavalent_2_Period,
imm.Pentavalent_3,imm.Pentavalent_3_Date,imm.Pentavalent_3_Period,
imm.[PCV_10_1]  ,imm.[PCV_10_1_Date],imm.[PCV_10_1_Period],
imm.[PCV_10_2],imm.[PCV_10_2_Date],imm.[PCV_10_2_Period],
imm.[PCV_10_3],imm.[PCV_10_3_Date],imm.[PCV_10_3_Period],
imm.Other,imm.Other_Date,imm.Other_Period,
imm.VitaminA_6_months,
imm.VitaminA_1_yr,
imm.VitaminA_1_and_half_yr,
imm.VitaminA_2_yr,
imm.VitaminA2_to_5_yr,
imm.fully_immunized,
imm.Voided

  from  HEIEncounter he 
inner join PatientMasterVisit v on v.Id=he.PatientMasterVisitId
inner join Patient p on he.PatientId=p.Id
inner join  PatientEnrollment pe on p.Id =pe.PatientId
inner join Person per on per.Id=p.PersonId 
left join  (
select r.PatientId,r.PatientMasterVisitId,r.BCG,cast(r.BCG_Date as datetime) as BCG_Date,r.BCG_Period,r.[OPV 0] as OPV_Birth,CAST(r.[OPV 0_Date] as datetime) as [OPV_Birth_Date],r.[OPV 0_Period] as [OPV_Birth_Period],
r.[OPV 1] as OPV_1,CAST(r.[OPV 1_Date] as datetime) as [OPV_1_Date]  ,r.[OPV 1_Period] as OPV_1_Period,r.[OPV 2] as OPV_2,cast(r.[OPV 2_Date] as datetime) as [OPV_2_Date]  ,r.[OPV 2_Period] as OPV_2_Period
,r.[OPV 3] as OPV_3 ,cast (r.[OPV 3_Date] as datetime) as [OPV_3_Date] ,r.[OPV 3_Period] as OPV_3_Period 
,r.IPV,cast(r.IPV_Date as datetime) as IPV_Date,r.IPV_Period,NULL DPT_Hep_B_Hib_1  ,
NULL DPT_Hep_B_Hib_2  ,NULL DPT_Hep_B_Hib_3,r.[PCV-10 1] as PCV_10_1,cast(r.[PCV-10 1_Date] as datetime) as [PCV_10_1_Date]  
 ,r.[PCV-10 1_Period] as PCV_10_1_Period, r.[PCV-10 2] as PCV_10_2 ,cast(r.[PCV-10 2_Date] as datetime) as [PCV_10_2_Date],r.[PCV-10 2_Period]
 as PCV_10_2_Period
 ,r.[PCV-10 3] as PCV_10_3,
cast(r.[PCV-10 3_Date] as datetime) as [PCV_10_3_Date] ,r.[PCV-10 3_Period] as PCV_10_3_Period,
r.[Rota virus 1] as ROTA_1,cast(r.[Rota virus 1_Date] as datetime) as ROTA_1_Date,r.[Rota virus 1_Period] as ROTA_1_Period,r.[Rota Virus 2] as ROTA_2,
cast(r.[Rota Virus 2_Date] as datetime) as ROTA_2_Date,r.[Rota Virus 2_Period] as ROTA_2_Period,
r.[Measles 6 Months] as Measles_6_months,
cast(r.[Measles 6 Months_Date] as datetime) as  Measles_6_Date
,r.[Measles 6 Months_Period] as Measles_6_Period,
r.[Measles 9 Months] as Measles_9_Months
,cast(r.[Measles 9 Months_Date] as datetime)  as Measles_9_Date,r.[Measles 9 Months_Period] as Measles_9_Period
,r.[Measles 18 Months] as Measles_18_Months ,
cast(r.[Measles 18 Months_Date] as datetime)  as Measles_18_Date 
,r.[Measles 18 Months_Period] as Measles_18_Period,
r.Other,cast(r.Other_Date as datetime) as Other_Date,r.Other_Period,

r.[Pentavalent 1] as Pentavalent_1,cast(r.[Pentavalent 1_Date] as datetime) as Pentavalent_1_Date,r.[Pentavalent 1_Period] as Pentavalent_1_Period 
,r.[Pentavalent 2] as  Pentavalent_2,cast(r.[Pentavalent 2_Date] as datetime) as  Pentavalent_2_Date,r.[Pentavalent 2_Period] as Pentavalent_2_Period,r.[Pentavalent 3] as Pentavalent_3 ,
cast(r.[Pentavalent 3_Date] as datetime) as Pentavalent_3_Date 
,r.[Pentavalent 3_Period] as Pentavalent_3_Period,
convert(varchar(50), NULL) as VitaminA_6_months,
convert(varchar(50), NULL) as VitaminA_1_yr,
convert(varchar(50), NULL) as VitaminA_1_and_half_yr,
convert(varchar(50), NULL) as VitaminA_2_yr,
convert(varchar(50), NULL) as VitaminA2_to_5_yr,
CONVERT(Datetime,NULL) as  fully_immunized,
r.DeleteFlag  as Voided
 from(
 select  v.PatientId,v.PatientMasterVisitId,v.DeleteFlag,ColumnName,ValueVaccine from(
select PatientId,PatientMasterVisitId,Vaccine,lti.[Name] as Immunization,VaccineStage,lt.[Name] as Stage,v.VaccineDate,v.DeleteFlag from Vaccination v
left join LookupItem lti on lti.Id=v.Vaccine
left join LookupItem lt on lt.Id=v.VaccineStage
where (v.DeleteFlag is null or v.DeleteFlag =0)
)v
cross apply( 

select (v.Immunization) ,'YES' union all
select (v.Immunization +'_Period' ),CAST(v.Stage as varchar(max)) union all
select (v.Immunization + '_Date' )
,CAST(v.VaccineDate as varchar(max))
) c( ColumnName,ValueVaccine) 
)t pivot 
(
 max(ValueVaccine) 
 for columnname in ([Measles 18 Months],[Measles 18 Months_Period],[Measles 18 Months_Date],[Measles 9 Months],[Measles 9 Months_Period],[Measles 9 Months_Date],[Measles 6 Months],[Measles 6 Months_Period]
 ,[Measles 6 Months_Date],IPV,IPV_Period,IPV_Date,[Rota Virus 2],[Rota Virus 2_Period],[Rota Virus 2_Date],[Rota virus 1],[Rota virus 1_Period],[Rota virus 1_Date],
 [PCV-10 3], [PCV-10 3_Period], [PCV-10 3_Date],
[PCV-10 2],[PCV-10 2_Period],[PCV-10 2_Date],[PCV-10 1],[PCV-10 1_Period],[PCV-10 1_Date],[Pentavalent 3],[Pentavalent 3_Period],[Pentavalent 3_Date]
,[Pentavalent 2] ,[Pentavalent 2_Period],[Pentavalent 2_Date]
,[Pentavalent 1],[Pentavalent 1_Period],[Pentavalent 1_Date]
,[OPV 3],[OPV 3_Period],[OPV 3_Date]
,[OPV 2],[OPV 2_Period],[OPV 2_Date]
,[OPV 1],[OPV 1_Period],[OPV 1_Date]
,[OPV 0],[OPV 0_Period],[OPV 0_Date]
,BCG,BCG_Period,BCG_Date
,Other,Other_Period,Other_Date )
)r)imm on imm.PatientId=he.PatientId and imm.PatientMasterVisitId=v.Id
