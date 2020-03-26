select p.PersonId as Person_Id
,pmv.VisitDate as Encounter_Date,
NULL as Encounter_ID,
ahsq1.Answer as AcceptedHivStatus,
ahsq2.Answer as AppropiateDisclosureUnderWay,
uhq1.Answer as UnderstandingHIVAffectBody,
uhq2.Answer as UndestandingARTHowWorks,
uhq3.Answer as UnderstandSideEffects,
uhq4.Answer as UnderstandBenefitAdherence,
uhq5.Answer as UnderstandConsequenceNonAdherence,
dr1.ClinicalNotes as AboutTypicalDay,
dr2.ClinicalNotes as TellHowYouTakeEachMedicine,
dr3.ClinicalNotes as DoIncaseofVisitTravel,
dr4.ClinicalNotes as WhoIsThePrimaryGiverLevelCommitment,
pcq1.ClinicalNotes as WhodoyouliveWith,
pcq2.ClinicalNotes as WhoIsAwareHivStatus,
pcq3screen.Answer as SupportSystem,
pcq3.ClinicalNotes as SupportSystemNotes,
pcq4screen.Answer as ChangesRelationshipFamilyMembers,
pcq4.ClinicalNotes as ChangesRelationshipFamilyMembersNotes,
pcq5screen.Answer as BotherFindHivStatus,
pcq5.ClinicalNotes as BotherFindHivStatusNotes,
pcq6screen.Answer as TreatDifferently,
pcq6.ClinicalNotes as TreatDifferentlyNotes,
pcq7screen.Answer as   Stigma,
pcq7.ClinicalNotes as StigmaNotes,
pcq8screen.Answer as   StopMedicineReligousBelief,
pcq8.ClinicalNotes as StopMedicineReligousBeliefNotes,
rnq1.Answer as ReferredToOtherServices,
rnq2.Answer as AttendAppointments,
rnq3.ClinicalNotes as NeedReorganizedReferrals

 from PatientEncounter pe
inner join
(select * from LookupItemView where MasterName='EncounterType'
and ItemName='Adherence-Barriers')ab on ab.ItemId=pe.EncounterTypeId
inner join PatientMasterVisit pmv on pmv.Id=pe.PatientMasterVisitId
and pmv.PatientId=pe.PatientId
inner join Patient p on p.Id=pe.PatientId
left  join (select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='AHSQuestion1' and lt.MasterName='AwarenessofHIVStatus'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) ahsq1 on ahsq1.PatientId=p.id  and ahsq1.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='AHSQuestion2' and lt.MasterName='AwarenessofHIVStatus'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) ahsq2 on ahsq2.PatientId=p.id  and ahsq2.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='UHIQ1' and lt.MasterName='UnderstandingOfHIVInfection'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) uhq1 on  uhq1.PatientId=p.id  and uhq1.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='UHIQ2' and lt.MasterName='UnderstandingOfHIVInfection'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) uhq2 on  uhq2.PatientId=p.id  and uhq2.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='UHIQ3' and lt.MasterName='UnderstandingOfHIVInfection'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) uhq3 on  uhq3.PatientId=p.id  and uhq3.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='UHIQ4' and lt.MasterName='UnderstandingOfHIVInfection'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) uhq4 on  uhq4.PatientId=p.id  and uhq4.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='UHIQ5' and lt.MasterName='UnderstandingOfHIVInfection'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) uhq5 on  uhq5.PatientId=p.id  and uhq5.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DR1' and lt.MasterName='DailyRoutine'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dr1 on  dr1.PatientId=p.id  and dr1.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DR2' and lt.MasterName='DailyRoutine'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dr2 on  dr2.PatientId=p.id  and dr2.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DR3' and lt.MasterName='DailyRoutine'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dr3 on  dr3.PatientId=p.id  and dr3.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='DR4' and lt.MasterName='DailyRoutine'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) dr4 on  dr4.PatientId=p.id  and dr4.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ1' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq1 on  pcq1.PatientId=p.id  and pcq1.PatientMasterVisitId=pmv.Id
left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ2' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq2 on  pcq2.PatientId=p.id  and pcq2.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ3' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq3screen on  pcq3screen.PatientId=p.id  and pcq3screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ3' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq3 on  pcq3.PatientId=p.id  and pcq3.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ4' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq4screen on  pcq4screen.PatientId=p.id  and pcq4screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ4' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq4 on  pcq4.PatientId=p.id  and pcq4.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ5' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq5screen on  pcq5screen.PatientId=p.id  and pcq5screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ5' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq5 on  pcq5.PatientId=p.id  and pcq5.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ6' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq6screen on  pcq6screen.PatientId=p.id  and pcq6screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ6' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq6 on  pcq6.PatientId=p.id  and pcq6.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ7' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq7screen on  pcq7screen.PatientId=p.id  and pcq7screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ7' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq7 on  pcq7.PatientId=p.id  and pcq7.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='PCQ8' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq8screen on  pcq8screen.PatientId=p.id  and pcq7screen.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='PCQ8' and lt.MasterName='PsychosocialCircumstances'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) pcq8 on  pcq8.PatientId=p.id  and pcq8.PatientMasterVisitId=pmv.Id


left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='RNQ1' and lt.MasterName='ReferralsNetworks'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) rnq1 on  rnq1.PatientId=p.id  and rnq1.PatientMasterVisitId=pmv.Id

left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,(select top 1 [Name] from LookupItem lt where lt.Id= ps.ScreeningValueId) as Answer  from PatientScreening ps
inner join LookupItemView lt on lt.ItemId=ps.ScreeningCategoryId
where lt.ItemName='RNQ2' and lt.MasterName='ReferralsNetworks'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) rnq2 on  rnq2.PatientId=p.id  and rnq2.PatientMasterVisitId=pmv.Id



left join(select  ps.PatientId,ps.PatientMasterVisitId,ps.DeleteFlag,lt.ItemDisplayName as Question,ps.ClinicalNotes
 from PatientClinicalNotes ps
inner join LookupItemView lt on lt.ItemId=ps.NotesCategoryId
where lt.ItemName='RNQ3' and lt.MasterName='ReferralsNetworks'
and (ps.DeleteFlag is null or ps.DeleteFlag =0)
) rnq3 on  rnq3.PatientId=p.id  and rnq3.PatientMasterVisitId=pmv.Id

