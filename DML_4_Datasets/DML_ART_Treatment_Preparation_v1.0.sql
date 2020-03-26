select distinct p.PersonId as Person_Id,pmv.VisitDate as Encounter_Date,NULL
   as Encounter_ID,
   psc.Understands_hiv_art_benefits,
   psc.Screened_negative_substance_abuse,
   psc.Screened_negative_psychiatric_illness,
   psc.HIV_status_disclosure,
   psc.Trained_drug_admin,
   psc.Informed_drug_side_effects,
   psc.Caregiver_committed,
   psc.Adherance_barriers_identified,
   psc.Caregiver_location_contacts_known,
   psc.Ready_to_start_art,
   pssc.Identified_drug_time,
   pssc.Treatment_supporter_engaged,
   pssc.Support_grp_meeting_awareness,
   pssc.Enrolled_in_reminder_system,
   pssc.Other_support_systems,
   part.DeleteFlag,
   cast(created_at as date)created_at,
   created_by
  from (
  select  psc.PatientId,psc.PatientMasterVisitId,psc.DeleteFlag,psc.[CreateDate] created_at
				,psc.[CreatedBy] created_by from PatientSupportSystemCriteria 
  psc
  union 
  select  pscr.PatientId,pscr.PatientMasterVisitId,pscr.DeleteFlag,pscr.[CreateDate] created_at
				,pscr.[CreatedBy] created_by from PatientPsychosocialCriteria pscr
  )part   inner join Patient p on p.Id=part.PatientId
  inner join PatientMasterVisit pmv on pmv.Id=part.PatientMasterVisitId
 left join(select  psc.PatientId,psc.PatientMasterVisitId,
 CASE when psc.BenefitART ='1' then 'Yes' when psc.BenefitART='0' then 'No'
 end as  Understands_hiv_art_benefits,
 CASE when psc.Alcohol='1' then 'Yes' when psc.Alcohol='0' then 'No'
 end as Screened_negative_substance_abuse,
 CASE when psc.Depression ='1' then 'Yes' when psc.Depression='0' then 
 'No' end as Screened_negative_psychiatric_illness,
 CASE when psc.Disclosure='1' then 'Yes' when psc.Disclosure='0' then
 'No' end as HIV_status_disclosure,
 CASE when psc.AdministerART='1' then 'Yes' when psc.AdministerART='0' then
 'No' end as Trained_drug_admin,
 CASE when psc.effectsART='1' then 'Yes' when psc.effectsART='0' then 'No' end as
 Informed_drug_side_effects,
 CASE when psc.dependents='1' then 'Yes' when psc.dependents='0' then 'No' end as Caregiver_committed,
 CASE when psc.AdherenceBarriers='1' then 'Yes' when psc.AdherenceBarriers='0' then 'No'
 end as Adherance_barriers_identified,
 CASE when psc.AccurateLocator='1' then 'Yes' when psc.AccurateLocator='0' then 'No'
 end as Caregiver_location_contacts_known,
CASE when psc.StartART ='1' then 'Yes' when psc.StartART='0' then 'No' end as
 Ready_to_start_art

  from  PatientPsychosocialCriteria psc
 
)psc on psc.PatientId=part.PatientId  
and psc.PatientMasterVisitId =part.PatientMasterVisitId
left join (
select psc.PatientId,psc.PatientMasterVisitId,
  CASE when psc.TakingART='1' then 'Yes' when psc.TakingART='0' then 'No' end 
  as Identified_drug_time,
  CASE when psc.TSIdentified='1' then 'Yes' when psc.TSIdentified='0' then 'No'
  end as Treatment_supporter_engaged,
  CASE when psc.supportGroup='1' then 'Yes' when psc.supportGroup='0' then 'No'
  end as Support_grp_meeting_awareness,
  CASE when psc.EnrollSMSReminder='1' then 'Yes' when 
  psc.EnrollSMSReminder='0' then 'No' end as Enrolled_in_reminder_system,
  CASE when psc.OtherSupportSystems='1' then 'Yes' when 
  psc.OtherSupportSystems='0' then 'No' end as Other_support_systems
   from PatientSupportSystemCriteria psc)
   pssc on pssc.PatientId=part.PatientId and pssc.PatientMasterVisitId=part.PatientMasterVisitId
   
   