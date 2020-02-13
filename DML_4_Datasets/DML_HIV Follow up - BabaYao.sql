 -- 12 HIV Follow up

 exec pr_OpenDecryptedSession;

  select  P.Id as Person_Id,
   format(cast(pmv.VisitDate as date),'yyyy-MM-dd') AS Encounter_Date
,NULL as Encounter_ID
 , CASE WHEN pmv.VisitScheduled='0' then 'No' when pmv.VisitScheduled='1' then 'Yes' end as Visit_scheduled,
ltv.[Name] as Visit_by,
NULL Visit_by_other
,psc.ItemDisplayName as Nutritional_status,
pop.PopulationType as Population_type,
pop.Population_Type as Key_population_type,
pws.WHO_Stage as Who_stage,
 CASE WHEN pres.PresentingComplaint is null then 'No' else 'Yes' end as Presenting_complaints,
pres.PresentingComplaint as Complaint,
NULL as Duration,
NULL as Onset_Date,
cl.ClinicalNotes as Clinical_notes,
CASE WHEN paa.Has_Known_allergies is null then 'No' else paa.Has_Known_allergies end as Has_Known_allergies,
paa.Allergies_causative_agents,
paa.Allergies_reactions,
paa.Allergies_severity,
chr.Has_Chronic_illnesses_cormobidities,
chr.Chronic_illnesses_name,
chr.Chronic_illnesses_onset_date,
CASE WHEN paa.Has_Known_allergies is null then 'No' else paa.Has_Known_allergies end as Has_adverse_drug_reaction,
paa.Allergies_causative_agents as Medicine_causing_drug_reaction,
paa.Allergies_reactions as Drug_reaction,
paa.Allergies_severity as Drug_reaction_severity,
paa.OnsetDate as Drug_reaction_onset_date,
NULL as Drug_reaction_action_taken,
vss.Vaccinations_today,
vss.VaccineStage as Vaccine_Stage,
vss.VaccineDate as Vaccination_Date,
pov.LMP as Last_menstrual_period,
pov.PregnancyStatus as Pregnancy_status,
pov.PlanningGetPregnant as Wants_pregnancy,
pov.Outcome as Pregnancy_outcome,
panc.IdentifierValue as Anc_number,
pov.Anc_profile,
pov.EDD  as Expected_delivery_date,
pov.Gravidae as Gravida,
pov.Parity as Parity_term,
pov.Parity2 as Parity_abortion,
pfm.FamilyPlanningStatus as Family_planning_status,
pfm.FamilyPlanningMethod as Family_planning_method,
pfm.Reason_not_using_family_planning,
ge.Exam as General_examinations_findings,
CASE when srs.System_review_finding is null then 'No' else srs.System_review_finding end as System_review_finding,
sk.Findings as Skin,
sk.FindingsNotes as Skin_finding_notes,
ey.Findings as Eyes,
ey.FindingsNotes as Eyes_Finding_notes,
ent.Findings as ENT,
ent.FindingsNotes as ENT_finding_notes,
ch.Findings as Chest,
ch.FindingsNotes as Chest_finding_notes,
cvs.Findings as CVS,
cvs.FindingsNotes as CVS_finding_notes,
ab.Findings as Abdomen,
ab.FindingsNotes as Abdomen_finding_notes,
cns.Findings as CNS,
cns.FindingsNotes as CNS_finding_notes,
gn.Findings as Genitourinary,
gn.FindingsNotes as Genitourinary_finding_notes,
pd.Diagnosis as Diagnosis,
pd.ManagementPlan as Treatment_plan,
ctx.ScoreName as Ctx_adherence,
CASE when ctx.VisitDate  is not null then 'Yes' else' No' end as Ctx_dispensed,
NULL as Dapsone_adherence,
NULL as Dapsone_dispensed,
adass.Morisky_forget_taking_drugs,
adass.Morisky_careless_taking_drugs,
adass.Morisky_stop_taking_drugs_feeling_worse,
adass.Morisky_stop_taking_drugs_feeling_better,
adass.Morisky_took_drugs_yesterday,
adass.Morisky_stop_taking_drugs_symptoms_under_control,
adass.Morisky_feel_under_pressure_on_treatment_plan,
adass.Morisky_how_often_difficulty_remembering,
adv.ScoreName as Arv_adherence,
phdp.Condom_Provided,
phdp.Screened_for_substance_abuse,
phdp.Pwp_Disclosure,
phdp.Pwp_partner_tested,
cacx.ScreeningValue  as Cacx_Screening,
phdp.Screened_for_sti,
scp.PartnerNotification as Sti_partner_notification,
pcc.Stability as Stability,
 format(cast(papp.Next_appointment_date as date),'yyyy-MM-dd') AS Next_appointment_date,
papp.Next_appointment_reason,
papp.Appointment_type,
pdd.DifferentiatedCare as Differentiated_care,
'0' as Voided   

  from Person P
   INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientEncounter pe on pe.PatientId=PT.Id
   inner join 
LookupItem lt  on lt.Id=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
inner join mst_User u on u.UserID=pe.CreatedBy
inner join LookupItem ltv on ltv.Id=pmv.VisitBy
left join (
select pvs.Patientid,pvs.PatientMasterVisitId,pmv.VisitDate,
pvs.[Weight] ,pvs.[Height],pvs.BPSystolic as Systolic_pressure,
pvs.BPDiastolic as Diastolic_pressure,
pvs.Temperature,pvs.HeartRate as Pulse_rate,
pvs.RespiratoryRate as Respiratory_rate,
pvs.SpO2 as Oxygen_Saturation,
pvs.BMI as BMI,
pvs.Muac as Muac
from PatientVitals pvs 
inner join  PatientMasterVisit pmv on pvs.PatientMasterVisitId=pmv.Id
 inner join Patient p on p.Id=pmv.PatientId
 )pvs on pvs.PatientId=pe.PatientId
 and pvs.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select psc.PatientId,psc.PatientMasterVisitId,psc.ItemDisplayName,psc.DeleteFlag,psc.Active from( select  psc.PatientId,psc.PatientMasterVisitId ,psc.ScreeningTypeId,(select [Name] from LookupMaster where Id =psc.ScreeningTypeId) as MasterName
  ,psc.ScreeningValueId,(select DisplayName from LookupItem where Id=psc.ScreeningValueId) as ItemDisplayName,psc.DeleteFlag,psc.Active
   from PatientScreening psc
   )psc where psc.MasterName='NutritionStatus' and (psc.DeleteFlag=0 or psc.DeleteFlag is null))
   psc on psc.PatientMasterVisitId=pe.PatientMasterVisitId and psc.PatientId =pe.PatientId
  left Join(select t.PersonId,t.PopulationType,t.Population_Type,t.CreateDate from (
select pp.Id,pp.PersonId,pp.PopulationType,pp.PopulationCategory,lt.DisplayName as Population_Type,pp.CreateDate,ROW_NUMBER() OVER(partition
by pp.PersonId order by pp.CreateDate desc) rownum
 from PatientPopulation pp
left join LookupItemView lt on lt.ItemId=pp.PopulationCategory
where (DeleteFlag=0 or DeleteFlag is null))t where t.rownum=1) pop on pop.PersonId=P.Id
left join (select * from(select pws.PatientId,pws.PatientMasterVisitId,pws.WHOStage,ltv.itemName as WHO_Stage,ROW_NUMBER() OVER(partition by
pws.PatientId,pws.PatientMasterVisitId order by pws.PatientMasterVisitId)rownum from PatientWHOStage pws
inner join LookupItemView ltv on ltv.MasterName='WHOStage' and pws.WHOStage=ltv.ItemId)pw where pw.rownum=1
)pws on pws.PatientId=pe.PatientMasterVisitId and pws.PatientId=pe.PatientId
left join (select PatientId,PatientMasterVisitId,PresentingComplaintsId,PresentingComplaint from (select  PatientId,PatientMasterVisitId,PresentingComplaintsId,CreatedBy,CreatedDate,lt.DisplayName as PresentingComplaint,
ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by CreatedDate desc)rownum
 from PresentingComplaints pres
 inner join LookupItem lt on lt.Id=pres.PresentingComplaintsId
 ) pre where rownum='1')pres on pres.PatientId=pe.PatientId and pres.PatientMasterVisitId=pe.PatientMasterVisitId
 left join(select t.PatientId,t.PatientMasterVisitId,t.ClinicalNotes from(select PatientId,PatientMasterVisitId ,ClinicalNotes,NotesCategoryId,DeleteFlag ,CreateDate,Active,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by CreateDate desc )rownum
 from PatientClinicalNotes where 
 NotesCategoryId is null and (DeleteFlag is null or DeleteFlag=0)) t where t.rownum='1')cl on cl.PatientId=pe.PatientId and cl.PatientMasterVisitId=pe.PatientMasterVisitId
 left join PatientIcf pic on pic.PatientId=pe.PatientId and pic.PatientMasterVisitId =pe.PatientMasterVisitId
left join(select pic.PatientId,pic.PatientMasterVisitId,pic.SputumSmear,CASE WHEN ltv.itemName = 'Ordered'
 then ltv.ItemName else NULL end as Spatum_smear_Ordered,
 CASE when  ltv.ItemName != 'Ordered' then ltv.DisplayName
else NULL end as Spatum_smear_result,
  pic.ChestXray,
CASE when glv.itemName='Ordered' then glv.DisplayName else NULL end as 
Genexpert_ordered,
CASE when  glv.ItemName != 'Ordered' then glv.DisplayName
else NULL end as Geneexpert_result,
CASE when clv.itemName='Ordered' then clv.DisplayName else NULL end as 
Chest_xray_ordered
,CASE when  clv.ItemName != 'Ordered' then clv.DisplayName
else NULL end as Chest_xray_result
,pic.GeneXpert,glv.DisplayName
from PatientIcfAction pic
left join LookupItemView ltv on ltv.ItemId=pic.SputumSmear and ltv.MasterName='SputumSmear'
left join LookupItemView glv on glv.ItemId=pic.GeneXpert and glv.MasterName='GeneExpert'
left Join LookupItemView clv on clv.ItemId=pic.ChestXray and clv.MasterName='ChestXray')
picf on picf.PatientId=pe.PatientId and picf.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select psc.Patientid,psc.PatientMasterVisitId ,psc.ScreeningValueId,lt.[Name],lti.DisplayName as  Tb_Status
 from PatientScreening psc
 inner join LookupItem lt on lt.Id= psc.ScreeningValueId
 inner join LookupMasterItem lti on lti.LookupItemId=lt.Id
 inner join LookupMaster lm on lm.Id=lti.LookupMasterId
  where lm.[Name] ='TBFindings' and (psc.DeleteFlag = 0 or psc.DeleteFlag is null))ptb on
  ptb.PatientId=pe.PatientId and ptb.PatientMasterVisitId=pe.PatientMasterVisitId
  left join (select * from (select *,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by PatientMasterVisitId desc)rownum from PatientIcfAction where DeleteFlag is null or DeleteFlag =0)pia where pia.rownum=1)pia on pia.PatientId =pe.PatientId
  and pia.PatientMasterVisitId=pe.PatientMasterVisitId
  left join (select tt.PatientId,tt.PatientMasterVisitId,tt.TBRxEndDate,tt.TBRxStartDate,tt.RegimenId,li.DisplayName as [RegimenName] from (select tt.PatientId,tt.PatientMasterVisitId,tt.TBRxStartDate,tt.TBRxEndDate,tt.RegimenId,ROW_NUMBER() OVER(partition by tt.PatientId,tt.PatientMasterVisitId order by tt.PatientMasterVisitId desc)rownum from TuberclosisTreatment tt)tt
  inner join LookupItem li on li.Id=tt.RegimenId
   where tt.rownum=1)trx on trx.PatientId=pe.PatientId and trx.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select PatientId,PatientMasterVisitId,OnsetDate ,AllergenName as Allergies_causative_agents,ReactionName as Allergies_reactions,'Yes' as Has_Known_allergies,
SeverityName as Allergies_severity,ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by  PatientMasterVisitId desc)rownum

 from PatientAllergyView)pav where pav.rownum =1)paa on paa.PatientId=pe.PatientId and paa.PatientMasterVisitId =pe.PatientMasterVisitId
 left join (select * from (select PatientId,PatientMasterVisitId ,ChronicIllness as Chronic_illnesses_name,
OnsetDate as Chronic_illnesses_onset_date ,'Yes' as Has_Chronic_illnesses_cormobidities,
ROW_NUMBER() OVER(partition by PatientId,PatientMasterVisitId order by  PatientMasterVisitId desc)rownum

 from PatientChronicIllnessView)pav where pav.rownum =1
)chr on chr.PatientId =pe.PatientId and chr.PatientMasterVisitId =pe.PatientMasterVisitId
left join(
 select  distinct  vs.PatientId,vs.PatientMasterVisitId,vs.PeriodId,vs.Vaccinations_today,lti.DisplayName as VaccineStage,vs.VaccinationStage,vs.VaccineStageId,vs.VaccineDate from (select v.PatientId,v.PatientMasterVisitId,v.Vaccine,lt.DisplayName as [Vaccinations_today],CASE WHEN 
 isNumeric(v.VaccineStage) =1  then v.VaccineStage else NULL end as VaccineStage ,v.VaccineStageId,ltt.DisplayName as [VaccinationStage],v.PeriodId,v.VaccineDate from Vaccination v
 left join LookupItem ltt on ltt.Id=v.VaccineStageId
 left join LookupItem lt on lt.Id=v.Vaccine) vs
 left join LookupItem lti on lti.id=vs.VaccineStage )vss on vss.PatientId=pe.PatientId and vss.PatientMasterVisitId=pe.PatientMasterVisitId
 left join (
SELECT        dbo.PregnancyIndicator.Id,dbo.Pregnancy.Gravidae,dbo.Pregnancy.Parity,dbo.Pregnancy.Parity2, dbo.PregnancyIndicator.PatientId, dbo.PregnancyIndicator.PatientMasterVisitId, dbo.PregnancyIndicator.LMP, dbo.PregnancyIndicator.EDD,CASE WHEN dbo.PregnancyIndicator.ANCProfile='1' then 'Yes' when dbo.PregnancyIndicator.ANCProfile='0' then 'No' end as Anc_Profile,

                             (SELECT        TOP (1) DisplayName
                               FROM            dbo.LookupItemView
                               WHERE        (ItemId = dbo.PregnancyIndicator.PregnancyStatusId) AND (MasterName = 'PregnancyStatus')) AS PregnancyStatus,
                             (SELECT        TOP (1) DisplayName
                               FROM            dbo.LookupItemView AS LookupItemView_1
                               WHERE        (ItemId = dbo.Pregnancy.Outcome)) AS Outcome,
							   PregnancyIndicator.PregnancyStatusId,
							   Pregnancy.Outcome OutcomeStatus,
							   PregnancyIndicator.PlanningToGetPregnant,
							   lt.[Name] as [PlanningGetPregnant]
							
FROM            dbo.Pregnancy  inner JOIN
                         dbo.PregnancyIndicator ON dbo.PregnancyIndicator.PatientId = dbo.Pregnancy.PatientId AND dbo.PregnancyIndicator.PatientMasterVisitId = dbo.Pregnancy.PatientMasterVisitId
						 left join LookupItem lt on lt.Id=PregnancyIndicator.PlanningToGetPregnant)pov on pov.PatientId =pe.PatientId and pov.PatientMasterVisitId=pe.PatientMasterVisitId
left join( select * from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag,ROW_NUMBER() OVER(partition by pid.PatientId order by pid.CreateDate desc) rownum from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  where pdd.[Code]= 'ANCNumber'
and (pid.DeleteFlag is null or pid.DeleteFlag =0))pidd where pidd.rownum ='1')panc on panc.PatientId=pe.PatientId
left join(select p.PatientId,p.PatientMasterVisitId,p.FamilyPlanningStatusId,ltr.DisplayName as [Reason_not_using_family_planning],lt.[DisplayName] as FamilyPlanningStatus,ltf.DisplayName as FamilyPlanningMethod from  PatientFamilyPlanning p
left join PatientFamilyPlanningMethod pfm on pfm.PatientFPId=p.Id
left join LookupItem ltf on ltf.Id =pfm.FPMethodId
inner join LookupItem lt on lt.Id =p.FamilyPlanningStatusId
left join LookupItem ltr on ltr.Id=p.ReasonNotOnFPId
)pfm on pfm.PatientId=pe.PatientId and pfm.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e
)ex where ex.ExaminationType='GeneralExamination'
)ex where ex.rownum ='1') ge on ge.PatientId=pe.PatientId and ge.PatientMasterVisitId =pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Eyes'

)ex 
where ex.rownum ='1'
)ey on ey.PatientId =pe.PatientId and ey.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Skin'

)ex 
where ex.rownum ='1'
)sk on sk.PatientId =pe.PatientId and sk.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Chest'

)ex 
where ex.rownum ='1'
)ch on ch.PatientId =pe.PatientId and ch.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='ENT'

)ex 
where ex.rownum ='1'
)ent on ent.PatientId =pe.PatientId and ent.PatientMasterVisitId=pe.PatientMasterVisitId



left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='CVS'

)ex 
where ex.rownum ='1'
)cvs on cvs.PatientId =pe.PatientId and cvs.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='Abdomen'

)ex 
where ex.rownum ='1'
)ab on ab.PatientId =pe.PatientId and ab.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam='CNS'

)ex 
where ex.rownum ='1'
)cns on cns.PatientId =pe.PatientId and cns.PatientMasterVisitId=pe.PatientMasterVisitId
left join (select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' and Ex.Exam like 'Genito-urinary'

)ex 
where ex.rownum ='1'

)gn on gn.PatientId =pe.PatientId and gn.PatientMasterVisitId=pe.PatientMasterVisitId

left join (select * from (SELECT *,ROW_NUMBER() OVER(partition by ex.PatientMasterVisitId,ex.PatientId order by ex.CreateDate desc)rownum FROM(SELECT       
    Id,
    PatientMasterVisitId,
    PatientId,
    ExaminationTypeId,
	(SELECT top 1 l.Name FROM LookupMaster l WHERE l.Id=e.ExaminationTypeId) ExaminationType,
	ExamId, 
	(SELECT top 1 l.DisplayName FROM LookupItem l WHERE l.Id=e.ExamId) Exam,
	DeleteFlag,
	CreateBy,	  
	CreateDate,
	FindingId, 
	(SELECT top 1 l.ItemName FROM LookupItemView l WHERE l.ItemId=e.FindingId) Findings,
    FindingsNotes,'Yes' as System_review_finding
FROM            dbo.PhysicalExamination e

)ex where ex.ExaminationType='ReviewOfSystems' 

)ex 
where ex.rownum ='1'
)
srs on srs.PatientId =pe.PatientId and srs.PatientMasterVisitId=pe.PatientMasterVisitId


left join(select  * from (select * ,ROW_NUMBER() OVER(partition by pd.PatientId
,pd.PatientMasterVisitId order by pd.CreateDate desc)rownum from (select pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan ,ic.[Name] as Diagnosis,pd.CreateDate from (
select   pd.PatientId,pd.PatientMasterVisitId,CASE WHEN isNumeric(pd.Diagnosis)= 0 then NULL else pd.Diagnosis end as Diagnosis,pd.ManagementPlan,pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 0 and pd.DeleteFlag is null or pd.DeleteFlag=0 
)pd 
inner join mst_ICDCodes ic on ic.Id=pd.Diagnosis
union all
select   pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,pd.Diagnosis,
pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 1 and pd.DeleteFlag is null or pd.DeleteFlag =0
and ISNUMERIC(pd.Diagnosis) =0
union all

select pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,lt.DisplayName as [Diagnosis],pd.CreateDate from (
select   pd.PatientId,pd.PatientMasterVisitId,pd.ManagementPlan,pd.Diagnosis,
pd.CreateDate from PatientDiagnosis pd
where pd.LookupTableFlag= 1 and pd.DeleteFlag is null or pd.DeleteFlag =0
and ISNUMERIC(pd.Diagnosis) =1)pd inner join LookupItem lt on lt.Id=pd.Diagnosis

 )pd)pd where pd.rownum =1)pd on pd.PatientId=pe.PatientId and pd.PatientMasterVisitId=pe.PatientMasterVisitId

 left join(select * from (select ao.Id,ao.PatientId,ao.PatientMasterVisitId,ao.Score,ROW_NUMBER() OVER(partition by ao.PatientId,
 ao.PatientMasterVisitId order by ao.CreateDate desc)rownum,
ao.AdherenceType,lm.[Name] as AdherenceTypeName, lti.DisplayName as ScoreName ,ao.DeleteFlag,pmv.VisitDate from AdherenceOutcome  ao
inner join  LookupMaster  lm on lm.Id=ao.AdherenceType
inner join LookupItem lti on lti.Id=ao.Score
inner join PatientMasterVisit pmv on pmv.Id =ao.PatientMasterVisitId
WHERE lm.[Name]='ARVAdherence' and (ao.DeleteFlag is null or ao.DeleteFlag  =0))adv where adv.rownum ='1')adv
on adv.PatientId =pe.PatientId and adv.PatientMasterVisitId=pe.PatientMasterVisitId

 left join(select * from (select ao.Id,ao.PatientId,ao.PatientMasterVisitId,ao.Score,ROW_NUMBER() OVER(partition by ao.PatientId,
 ao.PatientMasterVisitId order by ao.CreateDate desc)rownum,
ao.AdherenceType,lm.[Name] as AdherenceTypeName, lti.DisplayName as ScoreName ,ao.DeleteFlag,pmv.VisitDate from AdherenceOutcome  ao
inner join  LookupMaster  lm on lm.Id=ao.AdherenceType
inner join LookupItem lti on lti.Id=ao.Score
inner join PatientMasterVisit pmv on pmv.Id =ao.PatientMasterVisitId
WHERE lm.[Name]='CTXAdherence' and (ao.DeleteFlag is null or ao.DeleteFlag  =0))adv where adv.rownum ='1')ctx
on ctx.PatientId =pe.PatientId and ctx.PatientMasterVisitId=pe.PatientMasterVisitId

left join(select * from (select  a.PatientId,a.PatientMasterVisitId,case when a.ForgetMedicine=0 then 'No' when a.ForgetMedicine='1' then 'Yes' end  as  Morisky_forget_taking_drugs,
CASE WHEN a.CarelessAboutMedicine= 0 then 'No' WHEN a.CarelessAboutMedicine ='1' then 'Yes' end  as Morisky_careless_taking_drugs,
CASE WHEN a.FeelWorse= 0 then 'No' WHEN a.FeelWorse='1' then 'Yes' end  as Morisky_stop_taking_drugs_feeling_worse,
CASE WHEN a.FeelBetter= 0 then 'No'  when a.FeelBetter ='1' then 'Yes' end  as Morisky_stop_taking_drugs_feeling_better,
CASE WHEN a.TakeMedicine =0 then 'No' when a.TakeMedicine ='1' then 'Yes' end as Morisky_took_drugs_yesterday,
CASE WHEN a.StopMedicine=0 then 'No' when a.StopMedicine ='1' then 'Yes' end  as Morisky_stop_taking_drugs_symptoms_under_control,
CASE WHEN a.UnderPressure=0 then 'No' when a.UnderPressure ='1' then 'Yes' end  as Morisky_feel_under_pressure_on_treatment_plan,
CASE WHEN a.DifficultyRemembering=0 then 'Never/Rarely' 
WHEN a.DifficultyRemembering=0.25 then 'Once in a while'
WHEN a.DifficultyRemembering=0.5 then 'Sometimes'
WHEN a.DifficultyRemembering=0.75 then 'Usually'
WHEN a.DifficultyRemembering=1 then 'All the Time' end 
 as Morisky_how_often_difficulty_remembering ,ROW_NUMBER() OVER(partition by a.PatientId,a.PatientMasterVisitId order by a.Id desc)rownum
 from AdherenceAssessment a where Deleteflag =0 )
 ad where ad.rownum='1')adass on adass.PatientId=pe.PatientId and adass.PatientMasterVisitId=pe.PatientMasterVisitId
 left join (select  * from (select   pd.PatientId,pd.PatientMasterVisitId,CASE when pcd.DisplayName is not null then 'Yes' else 'No' end  as Condom_Provided,pd.DeleteFlag ,
CASE when SA.DisplayName  is not null then 'Yes' else' No' end as Screened_for_substance_abuse,
CASE when dis.DisplayName is not null then 'Yes' else 'No' end  as Pwp_Disclosure,
CASE when pt.DisplayName is not null then 'Yes' else 'No' end  as  Pwp_partner_tested,
CASE when st.DisplayName is not null then 'Yes' else 'No' end  as  Screened_for_sti
,ROW_NUMBER() OVER(partition by pd.PatientId,pd.PatientMasterVisitId order by pd.Id desc)rownum
from 
 PatientPHDP pd
 left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='CD')pcd on pcd.PatientMasterVisitId=pd.PatientMasterVisitId 
 left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='SA')SA on SA.PatientMasterVisitId=pd.PatientMasterVisitId
 left join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='DIS')dis on dis.PatientMasterVisitId=pd.PatientMasterVisitId
left  join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='STI')st on st.PatientMasterVisitId=pd.PatientMasterVisitId
 left join (select pd.PatientId,pd.PatientMasterVisitId,pd.Phdp ,l.DisplayName from 
 PatientPHDP pd  inner join LookupItem l on l.Id=pd.Phdp and l.[Name]='PT')pt on pt.PatientMasterVisitId=pd.PatientMasterVisitId
  --left join LookupItem lt on lt.Id=pd.Phdp and lt.[Name]='SA'

 where  pd.DeleteFlag is null  or pd.DeleteFlag=0)pd where pd.rownum= '1') phdp on  phdp.PatientId=pe.PatientId and  phdp.PatientMasterVisitId=pe.PatientMasterVisitId
 left join(select pa.PatientId,pa.PatientMasterVisitId,pa.AppointmentReason as Next_appointment_reason,pa.Appointment_type,pa.AppointmentDate as Next_appointment_date from(select pa.PatientId,pa.PatientMasterVisitId,pa.AppointmentDate,pa.DifferentiatedCareId ,pa.ReasonId,li.DisplayName as AppointmentReason,ROW_NUMBER() OVER(partition by pa.PatientId,pa.PatientMasterVisitId order by pa.CreateDate desc)rownum ,lt.DisplayName as Appointment_type,pa.DeleteFlag,pa.ServiceAreaId,pa.CreateDate from PatientAppointment pa
inner join LookupItem li on li.Id =pa.ReasonId
inner join LookupItem lt on lt.Id=pa.DifferentiatedCareId 

where pa.DeleteFlag is null or pa.DeleteFlag= 0
)pa where  pa.rownum =1
)papp on papp.PatientId=pe.PatientId and papp.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select pc.PatientId,pc.PatientMasterVisitId,CASE WHEN  pc.Categorization =2 then 'Unstable' WHEN pc.Categorization =1 then 'Stable' end as Stability
,ROW_NUMBER( )OVER(partition by pc.PatientId ,pc.PatientMasterVisitId order by pc.id desc)rownum   from PatientCategorization pc)pc where pc.rownum=1)pcc on pcc.PatientId=pe.PatientId
and pcc.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select pad.PatientId,pad.PatientMasterVisitId,'Yes'   as DifferentiatedCare from PatientArtDistribution pad where DeleteFlag = 0 or DeleteFlag is null)pdd
on pdd.PatientId =pe.PatientId and pdd.PatientMasterVisitId=pe.PatientMasterVisitId
left join(select * from (select psc.PatientId,psc.PatientMasterVisitId,lm.[DisplayName] as ScreeningType,psc.DeleteFlag,psc.VisitDate,psc.ScreeningDate,psc.CreateDate,
lt.DisplayName as ScreeningValue,ROW_NUMBER() OVER(partition by psc.PatientId,psc.PatientMasterVisitId  order by psc.CreateDate desc)rownum
 from PatientScreening  psc
 inner join LookupMaster lm on lm.[Id] =psc.ScreeningTypeId
 inner join LookupItem lt on  lt.Id=psc.ScreeningValueId
 where lm.[Name] ='CacxScreening' and (psc.DeleteFlag is null or psc.DeleteFlag =0))psc where psc.rownum='1')cacx on cacx.PatientId=pe.PatientId and
 cacx.PatientMasterVisitId=pe.PatientMasterVisitId
 left join (select  scp.PatientId,scp.PatientMasterVisitId,scp.Name as PartnerNotification from(select  sc.PatientId,sc.PatientMasterVisitId,sc.ScreeningTypeId,sc.ScreeningValueId,li.Name,ROW_NUMBER() OVER(partition by sc.PatientId,sc.PatientMasterVisitid order by sc.Id desc )rownum from PatientScreening sc
 inner join LookupMaster lm on lm.Id=sc.ScreeningTypeId and lm.Name='STIPartnerNotification'
 inner join LookupItem li on li.Id=sc.ScreeningValueId 
 where sc.DeleteFlag is null or sc.DeleteFlag =0)scp where scp.rownum='1')scp on scp.PatientId=pe.PatientId and scp.PatientMasterVisitId=pe.PatientMasterVisitId
 where lt.[Name]='ccc-encounter' 
 

 