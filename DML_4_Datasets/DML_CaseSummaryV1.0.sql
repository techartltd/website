select p.PersonId as Person_Id
,pmv.VisitDate as Encounter_Date,
NULL as Encounter_ID,
prr.ClinicalNotes as PrimaryReasonConsulation,
cce.ClinicalNotes as CaseClinicalEvaluation,
cq1.ClinicalNotes as NoAdherenceCounsellingAssessment,
cq2.ClinicalNotes as HomeVisits36Months,
cq3.ClinicalNotes as SupportStructures,
cq4.ClinicalNotes as EvidenceAdherenceConcerns,
cq5.ClinicalNotes as NoofDots36Months,
cq6.ClinicalNotes as NoofDots36Months2,
cq7.ClinicalNotes as RootCausePoorAdherence,
cq8screen.Answer as EvaluationTreatmentFailure,
cq8.ClinicalNotes as EvaluationTreatmentFailureNotes,
cott.ClinicalNotes as CommentonTreatment,
drtd.ClinicalNotes as DrugResistanceSensitivityTesting,
mtd.ClinicalNotes as MultidisciplinaryTeamDiscussedPatientCase,
mdtmem.ClinicalNotes as MDTMembers,
pe.createdby as CreatedBy,
pe.CreateDate as  CreateDate
 from  PatientEncounter pe
inner join
(select * from LookupItemView where MasterName='EncounterType'
and ItemName = 'CaseSummary' )ab on ab.ItemId=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
and pmv.PatientId=pe.PatientId
inner join Patient p on p.Id=pe.PatientId
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PrimaryReason' and lt.MasterName='CaseSummary'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) prr on  prr.PatientId=p.id  and prr.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='CaseClinicalEvaluation' and lt.MasterName='CaseSummary'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cce on  cce.PatientId=p.id  and cce.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ1' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq1 on  cq1.PatientId=p.id  and cq1.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ2' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq2 on  cq2.PatientId=p.id  and cq2.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ3' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq3 on  cq3.PatientId=p.id  and cq3.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ4' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq4 on  cq4.PatientId=p.id  and cq4.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ5' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq5 on  cq5.PatientId=p.id  and cq5.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ6' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq6 on  cq6.PatientId=p.id  and cq6.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ7' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq7 on  cq7.PatientId=p.id  and cq7.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='ClinicalEvaluationQ8' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq8 on  cq8.PatientId=p.id  and cq8.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='ClinicalEvaluationQ8' and lt.MasterName='ClinicalEvaluation'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cq8screen on  cq8screen.PatientId=p.id  and cq8screen.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='CommentOnTreatment' and lt.MasterName='OtherRelevantARTHistory'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) cott on  cott.PatientId=p.id  and cott.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DrugResistanceTestDone' and lt.MasterName='OtherRelevantARTHistory'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) drtd on  drtd.PatientId=p.id  and drtd.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='MultidisciplinaryTeamDiscussedPatientCase' and lt.MasterName='OtherRelevantARTHistory'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) mtd on  mtd.PatientId=p.id  and mtd.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='MDTmembers' and lt.MasterName='OtherRelevantARTHistory'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) mdtmem on  mdtmem.PatientId=p.id  and mdtmem.PatientMasterVisitId=pmv.Id