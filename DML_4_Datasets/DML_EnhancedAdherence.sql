select * from ( select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'1' as Session_number,
pilladh.Answer as Pill_Count,
NULL as Arv_adherence,
mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
uvfeel.Answer as Vl_results_feeling,
uvcause.Answer as Cause_of_high_vl,
NULL as Way_Forward,
cognhiv.Answer as  Patient_hiv_knowledge,
behhiv.Answer as Patient_drugs_uptake,
behhiv2.Answer as  Patient_drugs_reminder_tools,
behhiv3.Answer as Patient_drugs_uptake_during_travels,
behhiv4.Answer as Patient_drugs_side_effects_response,
behhiv5.Answer as Patient_drugs_uptake_most_difficult_times,
emq1.Answer as   Patient_drugs_daily_uptake_feeling,
emq2.Answer as Patient_ambitions,
sociq1.Answer as Patient_has_people_to_talk,
sociq2.Answer as Patient_enlisting_social_support,
sociq3.Answer as Patient_income_sources,
sociq4scr.Answer as Patient_challenges_reaching_clinicScreening,
sociq4.Answer as Patient_challenges_reaching_clinic,
sociq5scr.Answer as Patient_worried_of_accidental_disclosureScreening,
sociq5.Answer	as  Patient_worried_of_accidental_disclosure,
sociq6scr.Answer as Patient_treated_differentlyScreening,
sociq6.Answer as Patient_treated_differently,
sociq7scr.Answer as Stigma_hinders_adherenceScreening,
sociq7.Answer as Stigma_hinders_adherence,
sociq8scr.Answer as Patient_tried_faith_healingScreening,
sociq8.Answer as Patient_tried_faith_healing,
NULL as Patient_adherence_improved,
NULL as Patient_doses_missed,
NULL as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='PillAdherence' and lt.ItemName='PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas4screeningNotes' and lt.ItemName='mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas4screeningNotes' and lt.ItemName='mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas8screeningNotes' and lt.ItemName='mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId
and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='mmas8screeningNotes' and lt.ItemName='mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId
and mmas8Adher.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ1')lt
on lt.ItemId=pc.NotesCategoryId
)uvfeel on uvfeel.PatientMasterVisitId=pd.PatientMasterVisitId
and uvfeel.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ2')lt
on lt.ItemId=pc.NotesCategoryId
)uvcause on uvcause.PatientMasterVisitId=pd.PatientMasterVisitId
and uvcause.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='CognitiveBarriers' and lt.ItemName='CognitiveBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)cognhiv on cognhiv.PatientMasterVisitId=pd.PatientMasterVisitId and cognhiv.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv on behhiv.PatientMasterVisitId=pd.PatientMasterVisitId
and behhiv.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv2 on behhiv2.PatientMasterVisitId=pd.PatientMasterVisitId
 and behhiv2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ3')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv3 on behhiv3.PatientMasterVisitId=pd.PatientMasterVisitId
and behhiv3.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ4')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv4 on behhiv4.PatientMasterVisitId=pd.PatientMasterVisitId and behhiv4.PatientId =pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='BehaviouralBarriers' and lt.ItemName='BehaviouralBarriersQ5')lt
on lt.ItemId=pc.NotesCategoryId
)behhiv5 on behhiv5.PatientMasterVisitId=pd.PatientMasterVisitId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EmotionalBarriers' and lt.ItemName='EmotionalBarriersQ1')lt
on lt.ItemId=pc.NotesCategoryId
)emq1 on emq1.PatientMasterVisitId=pd.PatientMasterVisitId and emq1.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EmotionalBarriers' and lt.ItemName='EmotionalBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)emq2 on emq2.PatientMasterVisitId=pd.PatientMasterVisitId
 and emq2.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq1 on sociq1.PatientMasterVisitId =pd.PatientMasterVisitId and 
sociq1.PatientId =pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ2')lt
on lt.ItemId=pc.NotesCategoryId
)sociq2 on sociq2.PatientMasterVisitId=pd.PatientMasterVisitId
and sociq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sociq3 on sociq3.PatientMasterVisitId=pd.PatientMasterVisitId and sociq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq4Scr on sociq4Scr.PatientMasterVisitId =pd.PatientMasterVisitId and sociq4Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ4')lt
on lt.ItemId=pc.NotesCategoryId
)sociq4 on sociq4.PatientMasterVisitId=pd.PatientMasterVisitId and sociq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sociq5 on sociq5.PatientMasterVisitId=pd.PatientMasterVisitId and sociq5.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ5')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq5Scr on sociq5Scr.PatientMasterVisitId =pd.PatientMasterVisitId
and sociq5Scr.PatientId=pd.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ6')lt
on lt.ItemId=pc.NotesCategoryId
)sociq6 on sociq6.PatientMasterVisitId=pd.PatientMasterVisitId
and sociq6.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ6')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq6Scr on sociq6Scr.PatientMasterVisitId =pd.PatientMasterVisitId
and sociq6Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ7')lt
on lt.ItemId=pc.NotesCategoryId
)sociq7 on sociq7.PatientMasterVisitId=pd.PatientMasterVisitId

and sociq7.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ7')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq7Scr on sociq7Scr.PatientMasterVisitId =pd.PatientMasterVisitId and
sociq7Scr.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ8')lt
on lt.ItemId=pc.NotesCategoryId
)sociq8 on sociq8.PatientMasterVisitId=pd.PatientMasterVisitId and sociq8.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SocioEconomicBarriers' and lt.ItemName='SocioEconomicBarriersQ8')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sociq8Scr on sociq8Scr.PatientMasterVisitId =pd.PatientMasterVisitId and sociq8Scr.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId
 and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId
and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session1PillAdherence' and lt.ItemName='Session1FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId
and session1followup.PatientId=pd.PatientId



union 

select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'2' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence,
mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2PillAdherence' and lt.ItemName='Session2PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas4screeningNotes' and lt.ItemName='Session2mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas4screeningNotes' and lt.ItemName='Session2mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas8screeningNotes' and lt.ItemName='Session2mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2mmas8screeningNotes' and lt.ItemName='Session2mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=mmas8Adher.PatientId


left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='UnderstandingViralLoad' and lt.ItemName='UVLQ1')lt
on lt.ItemId=pc.NotesCategoryId
)uvfeel on uvfeel.PatientMasterVisitId=pd.PatientMasterVisitId and uvfeel.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=sessionrefq3.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2ReferralsNetworks' and lt.ItemName='Session2ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId =pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2PillAdherence' and lt.ItemName='Session2FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2AdherenceReviews'
and lt.ItemName='Session2AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session2AdherenceReviews'
and lt.ItemName='Session2AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session2AdherenceReviews' and lt.ItemName='Session2AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId

union

select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'3' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence
,mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3PillAdherence' and lt.ItemName='Session3PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas4screeningNotes' and lt.ItemName='Session3mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas4screeningNotes' and lt.ItemName='Session3mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas8screeningNotes' and lt.ItemName='Session3mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3mmas8screeningNotes' and lt.ItemName='Session3mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3ReferralsNetworks' and lt.ItemName='Session3ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3PillAdherence' and lt.ItemName='Session3FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3AdherenceReviews'
and lt.ItemName='Session3AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session3AdherenceReviews'
and lt.ItemName='Session3AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session3AdherenceReviews' and lt.ItemName='Session3AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId



union 



select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'4' as Session_number,pilladh.Answer as Pill_Count,
NULL as Arv_adherence
,mmas4Adhr.Answer as MMAS4AdherenceRating,
mmas4Score.Answer  as MMAS4Score,
mmas8score.Answer as MMAS8Score,
mmas8Adher.Answer as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
NULL as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
adhrevq1.Answer as Patient_adherence_improved,
adhrevq2.Answer as Patient_doses_missed,
adhrevq3.Answer as Review_and_Barriers_to_adherence,
sessionrefq1.Answer as Other_referrals,
sessionrefq2.Answer as Appointments_honoured,
sessionrefq3.Answer as Referral_experience,
sessionrefq4.Answer as Home_visit_benefit,
sessionrefq5.Answer as Adherence_Plan,
session1followup.Answer as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd
left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4PillAdherence' and lt.ItemName='Session4PillAdherenceQ1')lt
on lt.ItemId=pc.NotesCategoryId)
pilladh  on pilladh.PatientMasterVisitId=pd.PatientMasterVisitId and pilladh.PatientId=pd.PatientId


left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas4screeningNotes' and lt.ItemName='Session4mmas4Adherence')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Adhr  on mmas4Adhr.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Adhr.PatientId=pd.PatientId

left join (select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question ,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas4screeningNotes' and lt.ItemName='Session4mmas4Score')lt
on lt.ItemId=pc.NotesCategoryId)
mmas4Score  on mmas4Score.PatientMasterVisitId=pd.PatientMasterVisitId and mmas4Score.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas8screeningNotes' and lt.ItemName='Session4mmas8Score')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8score on mmas8score.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8score.PatientId=pd.PatientId



left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4mmas8screeningNotes' and lt.ItemName='Session4mmas8Adherence')lt
on lt.ItemId=pc.NotesCategoryId
)mmas8Adher on mmas8Adher.PatientMasterVisitId =pd.PatientMasterVisitId and mmas8Adher.PatientId=pd.PatientId


left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'SessionReferralsNetworks' and lt.ItemName='SessionReferralsNetworksQ1')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq1 on sessionrefq1.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq1.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq2 on sessionrefq2.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ3')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq3 on sessionrefq3.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq3.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ4')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
sessionrefq4 on sessionrefq4.PatientMasterVisitId =pd.PatientMasterVisitId and sessionrefq4.PatientId=pd.PatientId
left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4ReferralsNetworks' and lt.ItemName='Session4ReferralsNetworksQ5')lt
on lt.ItemId=pc.NotesCategoryId
)sessionrefq5 on sessionrefq5.PatientMasterVisitId=pd.PatientMasterVisitId and sessionrefq5.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4PillAdherence' and lt.ItemName='Session4FollowupDate')lt
on lt.ItemId=pc.NotesCategoryId
)session1followup on session1followup.PatientMasterVisitId=pd.PatientMasterVisitId and session1followup.PatientId=pd.PatientId
left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4AdherenceReviews'
and lt.ItemName='Session4AdherenceReviewsQ1'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq1 on adhrevq1.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq1.PatientId=pd.PatientId

left join (select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'Session4AdherenceReviews'
and lt.ItemName='Session4AdherenceReviewsQ2'
)lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
adhrevq2 on adhrevq2.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq2.PatientId=pd.PatientId

left join(select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='Session4AdherenceReviews' and lt.ItemName='Session4AdherenceReviewsQ3')lt
on lt.ItemId=pc.NotesCategoryId
) adhrevq3 on adhrevq3.PatientMasterVisitId=pd.PatientMasterVisitId and adhrevq3.PatientId=pd.PatientId

union


select pd.PersonId as Person_Id,pd.VisitDate as Encounter_Date,
NULL as Encounter_ID,'5' as Session_number,NULL as Pill_Count,NULL as Arv_adherence,
NULL as MMAS4AdherenceRating,
NULL as MMAS4Score,
NULL as MMAS8Score,
NULL as MMAS8AdherenceRating,
NULL as Has_vl_results,
NULL as Vl_results_suppressed,
NULL as Vl_results_feeling,
NULL as Cause_of_high_vl,
EndSessQ1.Answer as Way_Forward,
NULL as  Patient_hiv_knowledge,
NULL as Patient_drugs_uptake,
NULL as  Patient_drugs_reminder_tools,
NULL as Patient_drugs_uptake_during_travels,
NULL as Patient_drugs_side_effects_response,
NULL as Patient_drugs_uptake_most_difficult_times,
NULL as   Patient_drugs_daily_uptake_feeling,
NULL as Patient_ambitions,
NULL as Patient_has_people_to_talk,
NULL as Patient_enlisting_social_support,
NULL as Patient_income_sources,
NULL as Patient_challenges_reaching_clinicScreening,
NULL as Patient_challenges_reaching_clinic,
NULL as Patient_worried_of_accidental_disclosureScreening,
NULL	as  Patient_worried_of_accidental_disclosure,
NULL as Patient_treated_differentlyScreening,
NULL as Patient_treated_differently,
NULL as Stigma_hinders_adherenceScreening,
NULL as Stigma_hinders_adherence,
NULL as Patient_tried_faith_healingScreening,
NULL as Patient_tried_faith_healing,
NULL as Patient_adherence_improved,
NULL as Patient_doses_missed,
NULL as Review_and_Barriers_to_adherence,
NULL as Other_referrals,
NULL as Appointments_honoured,
NULL as Referral_experience,
NULL as Home_visit_benefit,
NULL as Adherence_Plan,
NULL as Next_Appointment_Date,
pd.DeleteFlag as Voided
  from (select pe.PatientId,pe.PatientMasterVisitId,pe.DeleteFlag,p.PersonId,pe.EncounterTypeId,lt.ItemName,pm.VisitDate from PatientEncounter pe
inner join PatientMasterVisit pm on pe.PatientMasterVisitId=pm.Id
inner join Patient p on p.Id =pe.PatientId
inner join LookupItemView lt on lt.ItemId=pe.EncounterTypeId
where lt.ItemName='EnhanceAdherence'
)pd left join(
select  pc.PatientId,pc.PatientMasterVisitId,lt.DisplayName as Question,lt.ItemName ,pc.ClinicalNotes as Answer
  from PatientClinicalNotes pc
inner join (select * from LookupItemView lt where lt.MasterName='EndSessionViralLoad' and lt.ItemName='EndSessionViralLoadQ1')lt
on lt.ItemId=pc.NotesCategoryId
)EndSessQ1 on  EndSessQ1.PatientMasterVisitId =pd.PatientMasterVisitId and EndSessQ1.PatientId=pd.PatientId
left join(
select  psc.PatientId,psc.PatientMasterVisitId,lt.ItemDisplayName as Question,lt.ItemName ,li.[Name] as Answer
  from PatientScreening psc
inner join (select * from LookupItemView lt where lt.MasterName like 'EndSessionViralLoad' and lt.ItemName='EndSessionViralLoadQ2')lt
on lt.ItemId=psc.ScreeningCategoryId
left join LookupItem li on li.Id=psc.ScreeningValueId)
EndSessQ2 on EndSessQ2.PatientMasterVisitId =pd.PatientMasterVisitId and EndSessQ2.PatientId=pd.PatientId


)t
