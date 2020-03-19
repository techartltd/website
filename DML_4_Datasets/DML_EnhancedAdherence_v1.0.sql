

SELECT *
FROM (
	SELECT pd.PersonId AS Person_Id
		,pd.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,'1' AS Session_number
		,pilladh.Answer AS Pill_Count
		,NULL AS Arv_adherence
		,mmas4Adhr.Answer AS MMAS4AdherenceRating
		,mmas4Score.Answer AS MMAS4Score
		,mmas8score.Answer AS MMAS8Score
		,mmas8Adher.Answer AS MMAS8AdherenceRating
		,NULL AS Has_vl_results
		,NULL AS Vl_results_suppressed
		,uvfeel.Answer AS Vl_results_feeling
		,uvcause.Answer AS Cause_of_high_vl
		,NULL AS Way_Forward
		,cognhiv.Answer AS Patient_hiv_knowledge
		,behhiv.Answer AS Patient_drugs_uptake
		,behhiv2.Answer AS Patient_drugs_reminder_tools
		,behhiv3.Answer AS Patient_drugs_uptake_during_travels
		,behhiv4.Answer AS Patient_drugs_side_effects_response
		,behhiv5.Answer AS Patient_drugs_uptake_most_difficult_times
		,emq1.Answer AS Patient_drugs_daily_uptake_feeling
		,emq2.Answer AS Patient_ambitions
		,sociq1.Answer AS Patient_has_people_to_talk
		,sociq2.Answer AS Patient_enlisting_social_support
		,sociq3.Answer AS Patient_income_sources
		,sociq4scr.Answer AS Patient_challenges_reaching_clinicScreening
		,sociq4.Answer AS Patient_challenges_reaching_clinic
		,sociq5scr.Answer AS Patient_worried_of_accidental_disclosureScreening
		,sociq5.Answer AS Patient_worried_of_accidental_disclosure
		,sociq6scr.Answer AS Patient_treated_differentlyScreening
		,sociq6.Answer AS Patient_treated_differently
		,sociq7scr.Answer AS Stigma_hinders_adherenceScreening
		,sociq7.Answer AS Stigma_hinders_adherence
		,sociq8scr.Answer AS Patient_tried_faith_healingScreening
		,sociq8.Answer AS Patient_tried_faith_healing
		,NULL AS Patient_adherence_improved
		,NULL AS Patient_doses_missed
		,NULL AS Review_and_Barriers_to_adherence
		,sessionrefq1.Answer AS Other_referrals
		,sessionrefq2.Answer AS Appointments_honoured
		,sessionrefq3.Answer AS Referral_experience
		,sessionrefq4.Answer AS Home_visit_benefit
		,sessionrefq5.Answer AS Adherence_Plan
		,session1followup.Answer AS Next_Appointment_Date
		,pd.DeleteFlag AS Voided
	FROM (
		SELECT pe.PatientId
			,pe.PatientMasterVisitId
			,pe.DeleteFlag
			,p.PersonId
			,pe.EncounterTypeId
			,lt.ItemName
			,pm.VisitDate
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pm ON pe.PatientMasterVisitId = pm.Id
		INNER JOIN Patient p ON p.Id = pe.PatientId
		INNER JOIN LookupItemView lt ON lt.ItemId = pe.EncounterTypeId
		WHERE lt.ItemName = 'EnhanceAdherence'
		) pd
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'PillAdherence'
				AND lt.ItemName = 'PillAdherenceQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) pilladh ON pilladh.PatientMasterVisitId = pd.PatientMasterVisitId
		AND pilladh.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'mmas4screeningNotes'
				AND lt.ItemName = 'mmas4Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Adhr ON mmas4Adhr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Adhr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'mmas4screeningNotes'
				AND lt.ItemName = 'mmas4Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Score ON mmas4Score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'mmas8screeningNotes'
				AND lt.ItemName = 'mmas8Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8score ON mmas8score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'mmas8screeningNotes'
				AND lt.ItemName = 'mmas8Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8Adher ON mmas8Adher.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8Adher.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'UnderstandingViralLoad'
				AND lt.ItemName = 'UVLQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) uvfeel ON uvfeel.PatientMasterVisitId = pd.PatientMasterVisitId
		AND uvfeel.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'UnderstandingViralLoad'
				AND lt.ItemName = 'UVLQ2'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) uvcause ON uvcause.PatientMasterVisitId = pd.PatientMasterVisitId
		AND uvcause.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'CognitiveBarriers'
				AND lt.ItemName = 'CognitiveBarriersQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) cognhiv ON cognhiv.PatientMasterVisitId = pd.PatientMasterVisitId
		AND cognhiv.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'BehaviouralBarriers'
				AND lt.ItemName = 'BehaviouralBarriersQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) behhiv ON behhiv.PatientMasterVisitId = pd.PatientMasterVisitId
		AND behhiv.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'BehaviouralBarriers'
				AND lt.ItemName = 'BehaviouralBarriersQ2'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) behhiv2 ON behhiv2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND behhiv2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'BehaviouralBarriers'
				AND lt.ItemName = 'BehaviouralBarriersQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) behhiv3 ON behhiv3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND behhiv3.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'BehaviouralBarriers'
				AND lt.ItemName = 'BehaviouralBarriersQ4'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) behhiv4 ON behhiv4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND behhiv4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'BehaviouralBarriers'
				AND lt.ItemName = 'BehaviouralBarriersQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) behhiv5 ON behhiv5.PatientMasterVisitId = pd.PatientMasterVisitId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'EmotionalBarriers'
				AND lt.ItemName = 'EmotionalBarriersQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) emq1 ON emq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND emq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'EmotionalBarriers'
				AND lt.ItemName = 'EmotionalBarriersQ2'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) emq2 ON emq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND emq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq1 ON sociq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ2'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq2 ON sociq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq3 ON sociq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq3.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ4'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq4Scr ON sociq4Scr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq4Scr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ4'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq4 ON sociq4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq5 ON sociq5.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq5.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ5'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq5Scr ON sociq5Scr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq5Scr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ6'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq6 ON sociq6.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq6.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ6'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq6Scr ON sociq6Scr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq6Scr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ7'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq7 ON sociq7.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq7.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ7'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq7Scr ON sociq7Scr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq7Scr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ8'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sociq8 ON sociq8.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq8.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SocioEconomicBarriers'
				AND lt.ItemName = 'SocioEconomicBarriersQ8'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sociq8Scr ON sociq8Scr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sociq8Scr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq1 ON sessionrefq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq2 ON sessionrefq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq3 ON sessionrefq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq3.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ4'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq4 ON sessionrefq4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq5 ON sessionrefq5.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq5.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session1PillAdherence'
				AND lt.ItemName = 'Session1FollowupDate'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) session1followup ON session1followup.PatientMasterVisitId = pd.PatientMasterVisitId
		AND session1followup.PatientId = pd.PatientId
	
	UNION
	
	SELECT pd.PersonId AS Person_Id
		,pd.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,'2' AS Session_number
		,pilladh.Answer AS Pill_Count
		,NULL AS Arv_adherence
		,mmas4Adhr.Answer AS MMAS4AdherenceRating
		,mmas4Score.Answer AS MMAS4Score
		,mmas8score.Answer AS MMAS8Score
		,mmas8Adher.Answer AS MMAS8AdherenceRating
		,NULL AS Has_vl_results
		,NULL AS Vl_results_suppressed
		,NULL AS Vl_results_feeling
		,NULL AS Cause_of_high_vl
		,NULL AS Way_Forward
		,NULL AS Patient_hiv_knowledge
		,NULL AS Patient_drugs_uptake
		,NULL AS Patient_drugs_reminder_tools
		,NULL AS Patient_drugs_uptake_during_travels
		,NULL AS Patient_drugs_side_effects_response
		,NULL AS Patient_drugs_uptake_most_difficult_times
		,NULL AS Patient_drugs_daily_uptake_feeling
		,NULL AS Patient_ambitions
		,NULL AS Patient_has_people_to_talk
		,NULL AS Patient_enlisting_social_support
		,NULL AS Patient_income_sources
		,NULL AS Patient_challenges_reaching_clinicScreening
		,NULL AS Patient_challenges_reaching_clinic
		,NULL AS Patient_worried_of_accidental_disclosureScreening
		,NULL AS Patient_worried_of_accidental_disclosure
		,NULL AS Patient_treated_differentlyScreening
		,NULL AS Patient_treated_differently
		,NULL AS Stigma_hinders_adherenceScreening
		,NULL AS Stigma_hinders_adherence
		,NULL AS Patient_tried_faith_healingScreening
		,NULL AS Patient_tried_faith_healing
		,adhrevq1.Answer AS Patient_adherence_improved
		,adhrevq2.Answer AS Patient_doses_missed
		,adhrevq3.Answer AS Review_and_Barriers_to_adherence
		,sessionrefq1.Answer AS Other_referrals
		,sessionrefq2.Answer AS Appointments_honoured
		,sessionrefq3.Answer AS Referral_experience
		,sessionrefq4.Answer AS Home_visit_benefit
		,sessionrefq5.Answer AS Adherence_Plan
		,session1followup.Answer AS Next_Appointment_Date
		,pd.DeleteFlag AS Voided
	FROM (
		SELECT pe.PatientId
			,pe.PatientMasterVisitId
			,pe.DeleteFlag
			,p.PersonId
			,pe.EncounterTypeId
			,lt.ItemName
			,pm.VisitDate
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pm ON pe.PatientMasterVisitId = pm.Id
		INNER JOIN Patient p ON p.Id = pe.PatientId
		INNER JOIN LookupItemView lt ON lt.ItemId = pe.EncounterTypeId
		WHERE lt.ItemName = 'EnhanceAdherence'
		) pd
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2PillAdherence'
				AND lt.ItemName = 'Session2PillAdherenceQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) pilladh ON pilladh.PatientMasterVisitId = pd.PatientMasterVisitId
		AND pilladh.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2mmas4screeningNotes'
				AND lt.ItemName = 'Session2mmas4Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Adhr ON mmas4Adhr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Adhr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2mmas4screeningNotes'
				AND lt.ItemName = 'Session2mmas4Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Score ON mmas4Score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2mmas8screeningNotes'
				AND lt.ItemName = 'Session2mmas8Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8score ON mmas8score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2mmas8screeningNotes'
				AND lt.ItemName = 'Session2mmas8Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8Adher ON mmas8Adher.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8Adher.PatientId = mmas8Adher.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'UnderstandingViralLoad'
				AND lt.ItemName = 'UVLQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) uvfeel ON uvfeel.PatientMasterVisitId = pd.PatientMasterVisitId
		AND uvfeel.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq1 ON sessionrefq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session2ReferralsNetworks'
				AND lt.ItemName = 'Session2ReferralsNetworksQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq2 ON sessionrefq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2ReferralsNetworks'
				AND lt.ItemName = 'Session2ReferralsNetworksQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq3 ON sessionrefq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq3.PatientId = sessionrefq3.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session2ReferralsNetworks'
				AND lt.ItemName = 'Session2ReferralsNetworksQ4'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq4 ON sessionrefq4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2ReferralsNetworks'
				AND lt.ItemName = 'Session2ReferralsNetworksQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq5 ON sessionrefq5.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq5.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2PillAdherence'
				AND lt.ItemName = 'Session2FollowupDate'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) session1followup ON session1followup.PatientMasterVisitId = pd.PatientMasterVisitId
		AND session1followup.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session2AdherenceReviews'
				AND lt.ItemName = 'Session2AdherenceReviewsQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq1 ON adhrevq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session2AdherenceReviews'
				AND lt.ItemName = 'Session2AdherenceReviewsQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq2 ON adhrevq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session2AdherenceReviews'
				AND lt.ItemName = 'Session2AdherenceReviewsQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) adhrevq3 ON adhrevq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq3.PatientId = pd.PatientId
	
	UNION
	
	SELECT pd.PersonId AS Person_Id
		,pd.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,'3' AS Session_number
		,pilladh.Answer AS Pill_Count
		,NULL AS Arv_adherence
		,mmas4Adhr.Answer AS MMAS4AdherenceRating
		,mmas4Score.Answer AS MMAS4Score
		,mmas8score.Answer AS MMAS8Score
		,mmas8Adher.Answer AS MMAS8AdherenceRating
		,NULL AS Has_vl_results
		,NULL AS Vl_results_suppressed
		,NULL AS Vl_results_feeling
		,NULL AS Cause_of_high_vl
		,NULL AS Way_Forward
		,NULL AS Patient_hiv_knowledge
		,NULL AS Patient_drugs_uptake
		,NULL AS Patient_drugs_reminder_tools
		,NULL AS Patient_drugs_uptake_during_travels
		,NULL AS Patient_drugs_side_effects_response
		,NULL AS Patient_drugs_uptake_most_difficult_times
		,NULL AS Patient_drugs_daily_uptake_feeling
		,NULL AS Patient_ambitions
		,NULL AS Patient_has_people_to_talk
		,NULL AS Patient_enlisting_social_support
		,NULL AS Patient_income_sources
		,NULL AS Patient_challenges_reaching_clinicScreening
		,NULL AS Patient_challenges_reaching_clinic
		,NULL AS Patient_worried_of_accidental_disclosureScreening
		,NULL AS Patient_worried_of_accidental_disclosure
		,NULL AS Patient_treated_differentlyScreening
		,NULL AS Patient_treated_differently
		,NULL AS Stigma_hinders_adherenceScreening
		,NULL AS Stigma_hinders_adherence
		,NULL AS Patient_tried_faith_healingScreening
		,NULL AS Patient_tried_faith_healing
		,adhrevq1.Answer AS Patient_adherence_improved
		,adhrevq2.Answer AS Patient_doses_missed
		,adhrevq3.Answer AS Review_and_Barriers_to_adherence
		,sessionrefq1.Answer AS Other_referrals
		,sessionrefq2.Answer AS Appointments_honoured
		,sessionrefq3.Answer AS Referral_experience
		,sessionrefq4.Answer AS Home_visit_benefit
		,sessionrefq5.Answer AS Adherence_Plan
		,session1followup.Answer AS Next_Appointment_Date
		,pd.DeleteFlag AS Voided
	FROM (
		SELECT pe.PatientId
			,pe.PatientMasterVisitId
			,pe.DeleteFlag
			,p.PersonId
			,pe.EncounterTypeId
			,lt.ItemName
			,pm.VisitDate
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pm ON pe.PatientMasterVisitId = pm.Id
		INNER JOIN Patient p ON p.Id = pe.PatientId
		INNER JOIN LookupItemView lt ON lt.ItemId = pe.EncounterTypeId
		WHERE lt.ItemName = 'EnhanceAdherence'
		) pd
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3PillAdherence'
				AND lt.ItemName = 'Session3PillAdherenceQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) pilladh ON pilladh.PatientMasterVisitId = pd.PatientMasterVisitId
		AND pilladh.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3mmas4screeningNotes'
				AND lt.ItemName = 'Session3mmas4Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Adhr ON mmas4Adhr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Adhr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3mmas4screeningNotes'
				AND lt.ItemName = 'Session3mmas4Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Score ON mmas4Score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3mmas8screeningNotes'
				AND lt.ItemName = 'Session3mmas8Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8score ON mmas8score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3mmas8screeningNotes'
				AND lt.ItemName = 'Session3mmas8Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8Adher ON mmas8Adher.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8Adher.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq1 ON sessionrefq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session3ReferralsNetworks'
				AND lt.ItemName = 'Session3ReferralsNetworksQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq2 ON sessionrefq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3ReferralsNetworks'
				AND lt.ItemName = 'Session3ReferralsNetworksQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq3 ON sessionrefq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq3.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session3ReferralsNetworks'
				AND lt.ItemName = 'Session3ReferralsNetworksQ4'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq4 ON sessionrefq4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3ReferralsNetworks'
				AND lt.ItemName = 'Session3ReferralsNetworksQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq5 ON sessionrefq5.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq5.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3PillAdherence'
				AND lt.ItemName = 'Session3FollowupDate'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) session1followup ON session1followup.PatientMasterVisitId = pd.PatientMasterVisitId
		AND session1followup.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session3AdherenceReviews'
				AND lt.ItemName = 'Session3AdherenceReviewsQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq1 ON adhrevq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session3AdherenceReviews'
				AND lt.ItemName = 'Session3AdherenceReviewsQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq2 ON adhrevq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session3AdherenceReviews'
				AND lt.ItemName = 'Session3AdherenceReviewsQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) adhrevq3 ON adhrevq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq3.PatientId = pd.PatientId
	
	UNION
	
	SELECT pd.PersonId AS Person_Id
		,pd.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,'4' AS Session_number
		,pilladh.Answer AS Pill_Count
		,NULL AS Arv_adherence
		,mmas4Adhr.Answer AS MMAS4AdherenceRating
		,mmas4Score.Answer AS MMAS4Score
		,mmas8score.Answer AS MMAS8Score
		,mmas8Adher.Answer AS MMAS8AdherenceRating
		,NULL AS Has_vl_results
		,NULL AS Vl_results_suppressed
		,NULL AS Vl_results_feeling
		,NULL AS Cause_of_high_vl
		,NULL AS Way_Forward
		,NULL AS Patient_hiv_knowledge
		,NULL AS Patient_drugs_uptake
		,NULL AS Patient_drugs_reminder_tools
		,NULL AS Patient_drugs_uptake_during_travels
		,NULL AS Patient_drugs_side_effects_response
		,NULL AS Patient_drugs_uptake_most_difficult_times
		,NULL AS Patient_drugs_daily_uptake_feeling
		,NULL AS Patient_ambitions
		,NULL AS Patient_has_people_to_talk
		,NULL AS Patient_enlisting_social_support
		,NULL AS Patient_income_sources
		,NULL AS Patient_challenges_reaching_clinicScreening
		,NULL AS Patient_challenges_reaching_clinic
		,NULL AS Patient_worried_of_accidental_disclosureScreening
		,NULL AS Patient_worried_of_accidental_disclosure
		,NULL AS Patient_treated_differentlyScreening
		,NULL AS Patient_treated_differently
		,NULL AS Stigma_hinders_adherenceScreening
		,NULL AS Stigma_hinders_adherence
		,NULL AS Patient_tried_faith_healingScreening
		,NULL AS Patient_tried_faith_healing
		,adhrevq1.Answer AS Patient_adherence_improved
		,adhrevq2.Answer AS Patient_doses_missed
		,adhrevq3.Answer AS Review_and_Barriers_to_adherence
		,sessionrefq1.Answer AS Other_referrals
		,sessionrefq2.Answer AS Appointments_honoured
		,sessionrefq3.Answer AS Referral_experience
		,sessionrefq4.Answer AS Home_visit_benefit
		,sessionrefq5.Answer AS Adherence_Plan
		,session1followup.Answer AS Next_Appointment_Date
		,pd.DeleteFlag AS Voided
	FROM (
		SELECT pe.PatientId
			,pe.PatientMasterVisitId
			,pe.DeleteFlag
			,p.PersonId
			,pe.EncounterTypeId
			,lt.ItemName
			,pm.VisitDate
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pm ON pe.PatientMasterVisitId = pm.Id
		INNER JOIN Patient p ON p.Id = pe.PatientId
		INNER JOIN LookupItemView lt ON lt.ItemId = pe.EncounterTypeId
		WHERE lt.ItemName = 'EnhanceAdherence'
		) pd
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4PillAdherence'
				AND lt.ItemName = 'Session4PillAdherenceQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) pilladh ON pilladh.PatientMasterVisitId = pd.PatientMasterVisitId
		AND pilladh.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4mmas4screeningNotes'
				AND lt.ItemName = 'Session4mmas4Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Adhr ON mmas4Adhr.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Adhr.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4mmas4screeningNotes'
				AND lt.ItemName = 'Session4mmas4Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas4Score ON mmas4Score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas4Score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4mmas8screeningNotes'
				AND lt.ItemName = 'Session4mmas8Score'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8score ON mmas8score.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8score.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4mmas8screeningNotes'
				AND lt.ItemName = 'Session4mmas8Adherence'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) mmas8Adher ON mmas8Adher.PatientMasterVisitId = pd.PatientMasterVisitId
		AND mmas8Adher.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'SessionReferralsNetworks'
				AND lt.ItemName = 'SessionReferralsNetworksQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq1 ON sessionrefq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session4ReferralsNetworks'
				AND lt.ItemName = 'Session4ReferralsNetworksQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq2 ON sessionrefq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4ReferralsNetworks'
				AND lt.ItemName = 'Session4ReferralsNetworksQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq3 ON sessionrefq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq3.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session4ReferralsNetworks'
				AND lt.ItemName = 'Session4ReferralsNetworksQ4'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) sessionrefq4 ON sessionrefq4.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq4.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4ReferralsNetworks'
				AND lt.ItemName = 'Session4ReferralsNetworksQ5'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) sessionrefq5 ON sessionrefq5.PatientMasterVisitId = pd.PatientMasterVisitId
		AND sessionrefq5.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4PillAdherence'
				AND lt.ItemName = 'Session4FollowupDate'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) session1followup ON session1followup.PatientMasterVisitId = pd.PatientMasterVisitId
		AND session1followup.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session4AdherenceReviews'
				AND lt.ItemName = 'Session4AdherenceReviewsQ1'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq1 ON adhrevq1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'Session4AdherenceReviews'
				AND lt.ItemName = 'Session4AdherenceReviewsQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) adhrevq2 ON adhrevq2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq2.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'Session4AdherenceReviews'
				AND lt.ItemName = 'Session4AdherenceReviewsQ3'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) adhrevq3 ON adhrevq3.PatientMasterVisitId = pd.PatientMasterVisitId
		AND adhrevq3.PatientId = pd.PatientId
	
	UNION
	
	SELECT pd.PersonId AS Person_Id
		,pd.VisitDate AS Encounter_Date
		,NULL AS Encounter_ID
		,'5' AS Session_number
		,NULL AS Pill_Count
		,NULL AS Arv_adherence
		,NULL AS MMAS4AdherenceRating
		,NULL AS MMAS4Score
		,NULL AS MMAS8Score
		,NULL AS MMAS8AdherenceRating
		,NULL AS Has_vl_results
		,NULL AS Vl_results_suppressed
		,NULL AS Vl_results_feeling
		,NULL AS Cause_of_high_vl
		,EndSessQ1.Answer AS Way_Forward
		,NULL AS Patient_hiv_knowledge
		,NULL AS Patient_drugs_uptake
		,NULL AS Patient_drugs_reminder_tools
		,NULL AS Patient_drugs_uptake_during_travels
		,NULL AS Patient_drugs_side_effects_response
		,NULL AS Patient_drugs_uptake_most_difficult_times
		,NULL AS Patient_drugs_daily_uptake_feeling
		,NULL AS Patient_ambitions
		,NULL AS Patient_has_people_to_talk
		,NULL AS Patient_enlisting_social_support
		,NULL AS Patient_income_sources
		,NULL AS Patient_challenges_reaching_clinicScreening
		,NULL AS Patient_challenges_reaching_clinic
		,NULL AS Patient_worried_of_accidental_disclosureScreening
		,NULL AS Patient_worried_of_accidental_disclosure
		,NULL AS Patient_treated_differentlyScreening
		,NULL AS Patient_treated_differently
		,NULL AS Stigma_hinders_adherenceScreening
		,NULL AS Stigma_hinders_adherence
		,NULL AS Patient_tried_faith_healingScreening
		,NULL AS Patient_tried_faith_healing
		,NULL AS Patient_adherence_improved
		,NULL AS Patient_doses_missed
		,NULL AS Review_and_Barriers_to_adherence
		,NULL AS Other_referrals
		,NULL AS Appointments_honoured
		,NULL AS Referral_experience
		,NULL AS Home_visit_benefit
		,NULL AS Adherence_Plan
		,NULL AS Next_Appointment_Date
		,pd.DeleteFlag AS Voided
	FROM (
		SELECT pe.PatientId
			,pe.PatientMasterVisitId
			,pe.DeleteFlag
			,p.PersonId
			,pe.EncounterTypeId
			,lt.ItemName
			,pm.VisitDate
		FROM PatientEncounter pe
		INNER JOIN PatientMasterVisit pm ON pe.PatientMasterVisitId = pm.Id
		INNER JOIN Patient p ON p.Id = pe.PatientId
		INNER JOIN LookupItemView lt ON lt.ItemId = pe.EncounterTypeId
		WHERE lt.ItemName = 'EnhanceAdherence'
		) pd
	LEFT JOIN (
		SELECT pc.PatientId
			,pc.PatientMasterVisitId
			,lt.DisplayName AS Question
			,lt.ItemName
			,pc.ClinicalNotes AS Answer
		FROM PatientClinicalNotes pc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName = 'EndSessionViralLoad'
				AND lt.ItemName = 'EndSessionViralLoadQ1'
			) lt ON lt.ItemId = pc.NotesCategoryId
		) EndSessQ1 ON EndSessQ1.PatientMasterVisitId = pd.PatientMasterVisitId
		AND EndSessQ1.PatientId = pd.PatientId
	LEFT JOIN (
		SELECT psc.PatientId
			,psc.PatientMasterVisitId
			,lt.ItemDisplayName AS Question
			,lt.ItemName
			,li.[Name] AS Answer
		FROM PatientScreening psc
		INNER JOIN (
			SELECT *
			FROM LookupItemView lt
			WHERE lt.MasterName LIKE 'EndSessionViralLoad'
				AND lt.ItemName = 'EndSessionViralLoadQ2'
			) lt ON lt.ItemId = psc.ScreeningCategoryId
		LEFT JOIN LookupItem li ON li.Id = psc.ScreeningValueId
		) EndSessQ2 ON EndSessQ2.PatientMasterVisitId = pd.PatientMasterVisitId
		AND EndSessQ2.PatientId = pd.PatientId
	) t

