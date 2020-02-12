	
	---- 26. HEI Followup
	select  
 p.PersonId as Person_Id,
 pen.VisitDate as Encounter_Date,
 NULL as Encounter_ID,
he.BirthWeight as [Weight],
 pvs.Height as  [Height],
 (select lt.[Name]  from LookupItem lt where lt.Id=he.PrimaryCareGiverID) as Primary_Care_Give,
hf.InfantFeeding as Infant_Feeding,
tbs.ScreeningValue as TB_Assessment_Outcome,

m.[Social_smile_milestone_<2Months],
m.Social_smile_milestone_2Months,
m.Head_control_milestone_3Months,
m.Head_control_milestone_4Months,
m.Hand_extension_milestone_9months,
m.Sitting_milestone_12months,
m.Standing_milestone_15months,
m.Walking_milestone_18months,
m.Talking_milestone_36months,
rlabs.[1st_DNA_PCRSampleDate],
rlabs.[1st_DNA_PCRResult],
rlabs.[1st_DNA_PCRResultDate],
rlabs.[2nd_DNA_PCRSampleDate],
rlabs.[2nd_DNA_PCRResult],
rlabs.[2nd_DNA_PCRResultDate],
rlabs.[3rd_DNA_PCRSampleDate],
rlabs.[3rd_DNA_PCRResult],
rlabs.[3rd_DNA_PCRResultDate],
rlabs.ConfimatoryPCR_SampleDate,
rlabs.ConfirmatoryPCR_Result,
rlabs.ConfimatoryPCR_ResultDate,
rlabs.RepeatConfirmatoryPCR_SampleDate,
rlabs.RepeatConfirmatoryPCR_Result,
rlabs.RepeatConfirmatoryPCR_ResultDate,
rlabs.BaselineViralLoadSampleDate,
rlabs.BaselineViralLoadResult,
rlabs.BaselineViralLoadResultDate,
rlabs.Final_AntibodySampleDate,
rlabs.Final_AntibodyResult,
rlabs.Final_AntibodyResultDate,
NULL Dna_pcr_sample_date,
NULL Dna_pcr_contextual_status,
NULL Dna_pcr_result,
NULL Dna_pcr_results,
CASE WHEN ltazt.[Name]='AZT liquid BID for 12 weeks' then 'Yes' 
when ltazt.[Name]='AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks' then 'Yes'
end as Azt_given,
CASE WHEN ltazt.[Name]='NVP liquid OD for 12 weeks' then 'Yes'
when ltazt.[Name]='AZT liquid BID + NVP liquid OD for 6 weeks then NVP liquid OD for 6 weeks' then 'Yes'
end as NVP_Given,
NULL CTX_Given,
ltazt.[Name] as  [ARVProphylaxisReceived],
he.ArvProphylaxisOther as [OtherARVProphylaxisReceived],
NULL First_antibody_sample_date ,
NULL First_antibody_result,      
 NULL First_antibody_dbs_sample_code,
 NULL First_antibody_result_date,
 NULL Final_antibody_sample_date,  
 NULL Final_antibody_result,   
 NULL Final_antibody_dbs_sample_code,
NULL  Final_antibody_result_date,
NULL  Tetracycline_Eye_Ointment,
NULL Pupil,
NULL Sight,
NULL Squint,
NULL Deworming_Drug,
NULL Deworming_Dosage_Units,
heapp.AppointmentDate as [Date_of_next_appointment],
heapp.[Description] as [Comment],
he.DeleteFlag as Voided
 

  from HEIEncounter he
inner join Patient p on he.PatientId=p.Id
inner join (select pe.PatientId,pe.PatientMasterVisitId,pe.EncounterTypeId,pmv.VisitDate,ltv.ItemName as EncounterType from PatientEncounter pe
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId 
inner join LookupItemView ltv on ltv.ItemId=pe.EncounterTypeId and ltv.MasterName='EncounterType'
where ltv.ItemName='hei-encounter'
)pen
on pen.PatientId =he.PatientId and pen.PatientMasterVisitId=he.PatientMasterVisitId 
inner join Person per on per.Id=p.PersonId 
left join PatientVitals pvs on pvs.PatientId=he.PatientId  and pvs.PatientMasterVisitId=he.PatientMasterVisitId
left join(select hf.PatientId,hf.PatientMasterVisitId,hf.FeedingModeId,lt.[Name] as InfantFeeding,
						 CASE WHEN lt.[Name]='Not Breastfeeding' then 'No'
						 when lt.[Name] is not null  and lt.[Name] !='Not Breastfeeding' then 'Yes'
						 else null end as Feeding
						  from  HEIFeeding hf
						  left join LookupItem lt on lt.Id=hf.FeedingModeId)hf
						   on hf.PatientId=p.Id and hf.PatientMasterVisitId=he.PatientMasterVisitId
  left join(select * from (select  ps.PatientId,ps.PatientMasterVisitId,ps.ScreeningTypeId,ltv.[Name] as ScreeningType,ps.DeleteFlag,ROW_NUMBER() OVER(partition by ps.PatientId,ps.PatientMasterVisitId
  order by ps.Id desc)rownum,
lt.[Name] as ScreeningValue
 from PatientScreening ps
inner join LookupMaster ltv on ltv.Id=ps.ScreeningTypeId
inner join LookupItem lt on lt.Id=ps.ScreeningValueId
 where  ltv.[Name]='TbScreeningOutcome' and (ps.DeleteFlag is null or ps.DeleteFlag=0))ps where ps.rownum='1')tbs on tbs.PatientId=p.Id and tbs.PatientMasterVisitId=he.PatientMasterVisitId
left join(select   t.PatientId,t.PatientMasterVisitId,max(t.[<2 Months]) as [Social_smile_milestone_<2Months],
max(t.[2 Months]) as [Social_smile_milestone_2Months],
max(t.[3 Months]) as Head_control_milestone_3Months,
max(t.[4 Months]) as  Head_control_milestone_4Months,
max(t.[6 Months]) as Response_to_sound_milestone_6months,
max(t.[9 Months]) as Hand_extension_milestone_9months,
max(t.[12 Months]) as Sitting_milestone_12months,
max(t.[15 Months]) as Standing_milestone_15months,
max(t.[18 Months]) as Walking_milestone_18months,
max(t.[36 Months]) as Talking_milestone_36months
  from(select pmi.PatientId,pmi.PatientMasterVisitId,pmi.TypeAssessedId, lt.[Name] as MilestoneType
,pmi.StatusId,lti.[Name] as [Status],pmi.DeleteFlag ,pmi.DateAssessed from PatientMilestone pmi
inner join LookupItem lt on lt.Id=pmi.TypeAssessedId
inner join LookupItem lti on lti.Id=pmi.StatusId
where (pmi.DeleteFlag is null or pmi.DeleteFlag =0) )
m 
pivot (max(m.[Status]) for MilestoneType In ([<2 Months], [2 Months]
,[3 Months],[4 Months] ,[6 Months] ,[9 Months] ,[12 Months] ,[15 Months] ,[18 Months] ,[36 Months])

)T  group by T.PatientId,T.PatientMasterVisitId)m on m.PatientId=he.PatientId
and m.PatientMasterVisitId =he.PatientMasterVisitId
left join(select r.PatientId,r.PatientMasterVisitId,r.[1st DNA PCRResult] as [1st_DNA_PCRResult] 
,CAST(r.[1st DNA PCRSampleDate] as datetime) as [1st_DNA_PCRSampleDate]
,CAST(r.[1st DNA PCRResultDate] as datetime) as  [1st_DNA_PCRResultDate]
,r.[2nd DNA PCRResult] as [2nd_DNA_PCRResult]
,CAST(r.[2nd DNA PCRSampleDate] as datetime) as [2nd_DNA_PCRSampleDate]
,CAST(r.[2nd DNA PCRResultDate] as datetime) as [2nd_DNA_PCRResultDate]
,r.[3rd DNA PCRResult] as  [3rd_DNA_PCRResult]
,CAST(r.[3rd DNA PCRSampleDate] as datetime) as [3rd_DNA_PCRSampleDate]
,CAST(r.[3rd DNA PCRResultDate] as datetime) as [3rd_DNA_PCRResultDate]
,r.[Final AntibodyResult] as [Final_AntibodyResult]
,CAST(r.[Final AntibodySampleDate] as datetime) as [Final_AntibodySampleDate],
CAST(r.[Final AntibodyResultDate] as datetime) as Final_AntibodyResultDate,
r.[Confirmatory PCR (for  +ve)Result] as ConfirmatoryPCR_Result,
CAST(r.[Confirmatory PCR (for  +ve)SampleDate] as datetime) as ConfimatoryPCR_SampleDate
,CAST(r.[Confirmatory PCR (for  +ve)ResultDate] as datetime) as ConfimatoryPCR_ResultDate
,r.[Repeat confirmatory PCR (for +ve)Result] as RepeatConfirmatoryPCR_Result,
CAST(r.[Repeat confirmatory PCR (for +ve)SampleDate] as datetime) as RepeatConfirmatoryPCR_SampleDate
,CAST(r.[Repeat confirmatory PCR (for +ve)ResultDate] as datetime) as RepeatConfirmatoryPCR_ResultDate,
[Baseline Viral Load (for +ve)Result] as BaselineViralLoadResult
,CAST([Baseline Viral Load (for +ve)SampleDate] as datetime) as BaselineViralLoadSampleDate
,CAST([Baseline Viral Load (for +ve)ResultDate] as datetime) as BaselineViralLoadResultDate


 from (select heilabs.PatientId,heilabs.PatientMasterVisitId,ColumnName,ColumnValue from (select hes.PatientId,lab.PatientMasterVisitId,hes.LabOrderId,hes.HeiLabTestTypeId,ltv.ItemName,lab.SampleDate ,lab.ResultDate,COALESCE(CAST(lab.TestResults as VARCHAR),lab.TestResults1)Result from HeiLabTests hes 
inner join LookupItemView ltv on ltv.ItemId=hes.HeiLabTestTypeId  and ltv.MasterName='HeiHivTestTypes'
inner join (Select	O.Id				LabId
		,o.Ptn_Pk
		,o.PatientMasterVisitId
		,o.PatientId
		,O.LocationId
		,O.OrderedBy		OrderedByName
		,O.OrderNumber
		,o.OrderDate		OrderedByDate
		,Ot.ResultBy		ReportedByName
		,OT.ResultDate		ReportedByDate
		,O.OrderedBy		CheckedbyName
		,o.OrderDate		CheckedbyDate
		,O.PreClinicLabDate
		,LT.ParameterName	TestName
		,LT.ParameterId		TestId
		,LT.LabTestId		[Test GroupId]
		,lt.LabTestName		[Test GroupName]
		,LT.DepartmentId	LabDepartmentId
		,LT.LabDepartmentName
		,0					LabTypeId
		,'Additional Lab'	LabTypeName
		,R.ResultValue		TestResults
		,R.ResultText		TestResults1
		,R.ResultOptionId	 TestResultId
		,R.ResultOption		[Parameter Result]
		,R.Undetectable
		,R.DetectionLimit
		,R.ResultUnit
		,R.HasResult
		,V.VisitDate
		,Null				LabPeriod
		,LT.TestReferenceId
		,LT.ParameterReferenceId,
		plt.SampleDate,
	   plt.ResultDate,
	   plt.ResultOptions		
	From dbo.ord_LabOrder O
	left Join dtl_LabOrderTest OT On OT.LabOrderId = O.Id
	left Join dtl_LabOrderTestResult R On R.LabOrderTestId = OT.Id
	left join(	Select	P.Id	ParameterId
			,P.ParameterName
			,P.ReferenceId ParameterReferenceId
			,T.Id	LabTestId
			,T.Name	LabTestName
			,T.ReferenceId TestReferenceId
			,T.IsGroup
			,T.DepartmentId
			,D.LabDepartmentName
			, T.DeleteFlag TestDeleteFlag
			,T.Active TestActive
			,P.DeleteFlag ParameterDeleteFlag
	From mst_LabTestMaster T
	Inner Join Mst_LabTestParameter P On T.Id = P.LabTestId
	Left Outer Join mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID)LT on LT.ParameterID=R.ParameterId
	left join PatientLabTracker plt on plt.LabOrderId=O.Id
    left Join ord_Visit V On v.Visit_Id = O.VisitId
	Where  (O.DeleteFlag is null or O.DeleteFlag =0) ) lab on lab.LabId=hes.LabOrderId)heilabs
	cross apply(
	select (heilabs.ItemName + 'Result') , CAST(heilabs.Result as varchar(max))   union all
	select (heilabs.ItemName + 'SampleDate'),CAST( heilabs.SampleDate as varchar(max))  union all
	select (heilabs.ItemName   + 'ResultDate') ,CAST(heilabs.ResultDate as varchar(max))  
	)c(ColumnName,ColumnValue)
	)t pivot(
	max(ColumnValue)
	for columnname in ([1st DNA PCRResult],[1st DNA PCRSampleDate],[1st DNA PCRResultDate],[2nd DNA PCRResult],[2nd DNA PCRSampleDate]
,[2nd DNA PCRResultDate],[3rd DNA PCRResult],[3rd DNA PCRSampleDate],[3rd DNA PCRResultDate],[Final AntibodyResult],[Final AntibodySampleDate],[Final AntibodyResultDate],
[Confirmatory PCR (for  +ve)Result],[Confirmatory PCR (for  +ve)SampleDate],[Confirmatory PCR (for  +ve)ResultDate],[Repeat confirmatory PCR (for +ve)Result],
[Repeat confirmatory PCR (for +ve)SampleDate],[Repeat confirmatory PCR (for +ve)ResultDate],
[Baseline Viral Load (for +ve)Result],[Baseline Viral Load (for +ve)SampleDate],[Baseline Viral Load (for +ve)ResultDate])

)r)rlabs on rlabs.PatientId=he.PatientId and rlabs.PatientMasterVisitId=he.PatientMasterVisitId
left join LookupItem ltazt on ltazt.Id=he.ArvProphylaxisId
left join  (select * from (select pa.PatientId,pa.PatientMasterVisitId,pa.ServiceAreaId,sa.Code,pa.AppointmentDate,pa.[Description],pa.StatusDate
 as Comment,ROW_NUMBER() OVER(partition by pa.PatientId,pa.PatientMasterVisitId order by pa.Id desc)rownum from PatientAppointment pa 
 inner join ServiceArea sa on sa.Id=pa.ServiceAreaId
 where (pa.DeleteFlag is null or pa.DeleteFlag =0)
 and  sa.Code='HEI'

 )t where t.rownum='1')heapp on heapp.PatientMasterVisitId=he.PatientMasterVisitId  and heapp.PatientId=he.PatientId