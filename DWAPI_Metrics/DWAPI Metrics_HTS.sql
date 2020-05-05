

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HTSClientTracing'
	,'NumberofHTSClientTraced'
	,count(*) Total
FROM (
	SELECT T.PersonID AS Person_Id
		,Encounter_Date = T.DateTracingDone
		,Encounter_ID = NULL
		,Contact_Type = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Mode
				AND MasterName = 'TracingMode'
			)
		,Contact_Outcome = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Outcome
				AND MasterName = 'TracingOutcome'
			)
		,Reason_uncontacted = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.ReasonNotContacted
				AND MasterName IN (
					'TracingReasonNotContactedPhone'
					,'TracingReasonNotContactedPhysical'
					)
			)
		,T.OtherReasonSpecify
		,T.Remarks
		,T.DeleteFlag Voided
	FROM (
		SELECT re.PersonId
			,re.PatientId
			,re.FinalResult
		FROM (
			SELECT pe.PatientEncounterId
				,pe.PatientMasterVisitId
				,pe.PatientId
				,pe.PersonId
				,pe.FinalResult
				,ROW_NUMBER() OVER (
					PARTITION BY pe.PatientId ORDER BY pe.PatientMasterVisitId DESC
					) rownum
			FROM (
				SELECT DISTINCT PE.Id PatientEncounterId
					,PE.PatientMasterVisitId
					,PE.PatientId PatientId
					,HE.PersonId
					,ResultOne = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundOneTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,ResultTwo = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundTwoTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResult = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 FinalResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResultGiven = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = HE.FinalResultGiven
						)
				FROM [dbo].[PatientEncounter] PE
				INNER JOIN [dbo].[PatientMasterVisit] PM ON PM.Id = PE.PatientMasterVisitId
				INNER JOIN [dbo].[HtsEncounter] HE ON PE.Id = HE.PatientEncounterID
				) pe
			WHERE pe.FinalResult = 'Positive'
			) re
		WHERE re.rownum = 1
		) pep
	INNER JOIN Tracing T ON pep.PersonId = T.PersonID
	) t

---
INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HTS Client Tracing'
	,'# of Contacted'
	,count(*) Total
FROM (
	SELECT T.PersonID AS Person_Id
		,Encounter_Date = T.DateTracingDone
		,Encounter_ID = NULL
		,Contact_Type = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Mode
				AND MasterName = 'TracingMode'
			)
		,Contact_Outcome = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Outcome
				AND MasterName = 'TracingOutcome'
			)
		,Reason_uncontacted = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.ReasonNotContacted
				AND MasterName IN (
					'TracingReasonNotContactedPhone'
					,'TracingReasonNotContactedPhysical'
					)
			)
		,T.OtherReasonSpecify
		,T.Remarks
		,T.DeleteFlag Voided
	FROM (
		SELECT re.PersonId
			,re.PatientId
			,re.FinalResult
		FROM (
			SELECT pe.PatientEncounterId
				,pe.PatientMasterVisitId
				,pe.PatientId
				,pe.PersonId
				,pe.FinalResult
				,ROW_NUMBER() OVER (
					PARTITION BY pe.PatientId ORDER BY pe.PatientMasterVisitId DESC
					) rownum
			FROM (
				SELECT DISTINCT PE.Id PatientEncounterId
					,PE.PatientMasterVisitId
					,PE.PatientId PatientId
					,HE.PersonId
					,ResultOne = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundOneTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,ResultTwo = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundTwoTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResult = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 FinalResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResultGiven = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = HE.FinalResultGiven
						)
				FROM [dbo].[PatientEncounter] PE
				INNER JOIN [dbo].[PatientMasterVisit] PM ON PM.Id = PE.PatientMasterVisitId
				INNER JOIN [dbo].[HtsEncounter] HE ON PE.Id = HE.PatientEncounterID
				) pe
			WHERE pe.FinalResult = 'Positive'
			) re
		WHERE re.rownum = 1
		) pep
	INNER JOIN Tracing T ON pep.PersonId = T.PersonID
	) t
WHERE t.Contact_Outcome = 'Contacted'

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HTS Client Tracing'
	,'# of Contacted and Linked'
	,count(*) Total
FROM (
	SELECT T.PersonID AS Person_Id
		,Encounter_Date = T.DateTracingDone
		,Encounter_ID = NULL
		,Contact_Type = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Mode
				AND MasterName = 'TracingMode'
			)
		,Contact_Outcome = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.Outcome
				AND MasterName = 'TracingOutcome'
			)
		,Reason_uncontacted = (
			SELECT TOP 1 ItemName
			FROM LookupItemView
			WHERE ItemId = T.ReasonNotContacted
				AND MasterName IN (
					'TracingReasonNotContactedPhone'
					,'TracingReasonNotContactedPhysical'
					)
			)
		,T.OtherReasonSpecify
		,T.Remarks
		,T.DeleteFlag Voided
	FROM (
		SELECT re.PersonId
			,re.PatientId
			,re.FinalResult
		FROM (
			SELECT pe.PatientEncounterId
				,pe.PatientMasterVisitId
				,pe.PatientId
				,pe.PersonId
				,pe.FinalResult
				,ROW_NUMBER() OVER (
					PARTITION BY pe.PatientId ORDER BY pe.PatientMasterVisitId DESC
					) rownum
			FROM (
				SELECT DISTINCT PE.Id PatientEncounterId
					,PE.PatientMasterVisitId
					,PE.PatientId PatientId
					,HE.PersonId
					,ResultOne = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundOneTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,ResultTwo = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 RoundTwoTestResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResult = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = (
								SELECT TOP 1 FinalResult
								FROM [dbo].[HtsEncounterResult]
								WHERE HtsEncounterId = HE.Id
								ORDER BY Id DESC
								)
						)
					,FinalResultGiven = (
						SELECT TOP 1 ItemName
						FROM [dbo].[LookupItemView]
						WHERE ItemId = HE.FinalResultGiven
						)
				FROM [dbo].[PatientEncounter] PE
				INNER JOIN [dbo].[PatientMasterVisit] PM ON PM.Id = PE.PatientMasterVisitId
				INNER JOIN [dbo].[HtsEncounter] HE ON PE.Id = HE.PatientEncounterID
				) pe
			WHERE pe.FinalResult = 'Positive'
			) re
		WHERE re.rownum = 1
		) pep
	INNER JOIN Tracing T ON pep.PersonId = T.PersonID
	) t
WHERE t.Contact_Outcome = 'Contacted and Linked'

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HTS_Initial_&_Retest'
	,'Number of HTS Test that FinalResult was Negative'
	,count(*) Total
FROM (
	SELECT *
	FROM (
		SELECT HE.PersonId Person_Id
			,PT.Id Patient_Id
			,Encounter_Date = format(cast(PE.EncounterStartTime AS DATE), 'yyyy-MM-dd')
			,Encounter_ID = HE.Id
			,Pop_Type = PPL2.PopulationType
			,Key_Pop_Type = PPL2.KeyPop
			,Priority_Pop_Type = PPR2.PrioPop
			,Patient_disabled = (
				CASE ISNULL(PI.Disability, '')
					WHEN ''
						THEN 'No'
					ELSE 'Yes'
					END
				)
			,PI.Disability
			,Ever_Tested = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.EverTested
					AND MasterName = 'YesNo'
				)
			,Self_Tested = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.EverSelfTested
					AND MasterName = 'YesNo'
				)
			,HE.MonthSinceSelfTest
			,--added
			HE.MonthsSinceLastTest
			,--added
			HTS_Strategy = (
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'Strategy'
					AND ItemId = HE.TestingStrategy
				)
			,HTS_Entry_Point = (
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HTSEntryPoints'
					AND ItemId = HE.TestEntryPoint
				)
			,(
				SELECT TOP 1 ItemName
				FROM LookupItemView
				WHERE ItemId = (
						SELECT TOP 1 ConsentValue
						FROM PatientConsent
						WHERE PatientMasterVisitId = PM.Id
							AND ServiceAreaId = 2
							AND ConsentType = (
								SELECT ItemId
								FROM LookupItemView
								WHERE MasterName = 'ConsentType'
									AND ItemName = 'ConsentToBeTested'
								)
						ORDER BY Id DESC
						)
				) AS Consented
			,TestedAs = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.TestedAs
					AND MasterName = 'TestedAs'
				)
			,TestType = CASE HE.EncounterType
				WHEN 1
					THEN 'Initial Test'
				WHEN 2
					THEN 'Repeat Test'
				END
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVTestKits'
					AND ItemId = (
						SELECT TOP 1 KitId
						FROM Testing
						WHERE HtsEncounterId = HE.Id
							AND TestRound = 1
						ORDER BY Id DESC
						)
				) AS Test_1_Kit_Name
			,(
				SELECT TOP 1 KitLotNumber
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 1
				ORDER BY Id DESC
				) AS Test_1_Lot_Number
			,(
				SELECT TOP 1 ExpiryDate
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 1
				ORDER BY Id DESC
				) AS Test_1_Expiry_Date
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVFinalResults'
					AND ItemId = (
						SELECT TOP 1 RoundOneTestResult
						FROM HtsEncounterResult
						WHERE HtsEncounterId = HE.Id
						ORDER BY Id DESC
						)
				) AS Test_1_Final_Result
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVTestKits'
					AND ItemId = (
						SELECT TOP 1 KitId
						FROM Testing
						WHERE HtsEncounterId = HE.Id
							AND TestRound = 2
						ORDER BY Id DESC
						)
				) AS Test_2_Kit_Name
			,(
				SELECT TOP 1 KitLotNumber
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 2
				ORDER BY Id DESC
				) AS Test_2_Lot_Number
			,(
				SELECT TOP 1 ExpiryDate
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 2
				ORDER BY Id DESC
				) AS Test_2_Expiry_Date
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVFinalResults'
					AND ItemId = (
						SELECT TOP 1 RoundTwoTestResult
						FROM HtsEncounterResult
						WHERE HtsEncounterId = HE.Id
						ORDER BY Id DESC
						)
				) AS Test_2_Final_Result
			,Final_Result = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HER.FinalResult
					AND MasterName = 'HIVFinalResults'
				)
			,Result_given = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.FinalResultGiven
					AND MasterName = 'YesNo'
				)
			,Couple_Discordant = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.CoupleDiscordant
					AND MasterName = 'YesNoNA'
				)
			,TB_SCreening_Results = (
				SELECT TOP 1 ItemName
				FROM LookupItemView
				WHERE MasterName = 'TbScreening'
					AND ItemId = (
						SELECT TOP 1 ScreeningValueId
						FROM PatientScreening
						WHERE PatientMasterVisitId = PM.Id
							AND PatientId = PT.Id
							AND ScreeningTypeId = (
								SELECT TOP 1 MasterId
								FROM LookupItemView
								WHERE MasterName = 'TbScreening'
								)
						)
				)
			,HE.EncounterRemarks AS Remarks
			,0 AS Voided
		FROM HtsEncounter HE
		LEFT JOIN HtsEncounterResult HER ON HER.HtsEncounterId = HE.Id
		INNER JOIN PatientEncounter PE ON PE.Id = HE.PatientEncounterID
		INNER JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
		INNER JOIN Person P ON P.Id = HE.PersonId
		INNER JOIN Patient PT ON PT.PersonId = P.Id
		LEFT JOIN (
			SELECT Main.Person_Id
				,LEFT(Main.Disability, Len(Main.Disability) - 1) AS "Disability"
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView
								WHERE MasterName = 'Disabilities'
									AND ItemId = CD.DisabilityId
								) + ' , ' AS [text()]
						FROM ClientDisability CD
						INNER JOIN PatientEncounter PE ON PE.Id = CD.PatientEncounterID
						WHERE CD.PersonId = P.Id
						ORDER BY CD.PersonId
						FOR XML PATH('')
						) [Disability]
				FROM Person P
				) [Main]
			) PI ON PI.Person_Id = P.Id
		LEFT JOIN (
			SELECT PPL.Person_Id
				,PPL.PopulationType
				,PPL.KeyPop
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,PPT.PopulationType
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView LK
								WHERE LK.ItemId = PP.PopulationCategory
									AND MasterName = 'HTSKeyPopulation'
								) + ' , ' AS [text()]
						FROM PatientPopulation PP
						WHERE PP.PersonId = P.Id
						ORDER BY PP.PersonId
						FOR XML PATH('')
						) [KeyPop]
				FROM Person P
				LEFT JOIN PatientPopulation PPT ON PPT.PersonId = P.Id
				) PPL
			) PPL2 ON PPL2.Person_Id = P.Id
		LEFT JOIN (
			SELECT PPR.Person_Id
				,PPR.PrioPop
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView LK
								WHERE LK.ItemId = PP.PriorityId
									AND MasterName = 'PriorityPopulation'
								) + ' , ' AS [text()]
						FROM PersonPriority PP
						WHERE PP.PersonId = P.Id
						ORDER BY PP.PersonId
						FOR XML PATH('')
						) [PrioPop]
				FROM Person P
				LEFT JOIN PersonPriority PPY ON PPY.PersonId = P.Id
				) PPR
			) PPR2 ON PPR2.Person_Id = P.Id
		) hts
	WHERE hts.Final_Result = 'Negative'
	) hts

INSERT INTO DWAPI_Migration_Metrics (
	Dataset
	,Metric
	,MetricValue
	)
SELECT 'HTS_Initial_&_Retest'
	,'Number of HTS Test that FinalResult was Positive'
	,count(*) Total
FROM (
	SELECT *
	FROM (
		SELECT HE.PersonId Person_Id
			,PT.Id Patient_Id
			,Encounter_Date = format(cast(PE.EncounterStartTime AS DATE), 'yyyy-MM-dd')
			,Encounter_ID = HE.Id
			,Pop_Type = PPL2.PopulationType
			,Key_Pop_Type = PPL2.KeyPop
			,Priority_Pop_Type = PPR2.PrioPop
			,Patient_disabled = (
				CASE ISNULL(PI.Disability, '')
					WHEN ''
						THEN 'No'
					ELSE 'Yes'
					END
				)
			,PI.Disability
			,Ever_Tested = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.EverTested
					AND MasterName = 'YesNo'
				)
			,Self_Tested = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.EverSelfTested
					AND MasterName = 'YesNo'
				)
			,HE.MonthSinceSelfTest
			,--added
			HE.MonthsSinceLastTest
			,--added
			HTS_Strategy = (
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'Strategy'
					AND ItemId = HE.TestingStrategy
				)
			,HTS_Entry_Point = (
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HTSEntryPoints'
					AND ItemId = HE.TestEntryPoint
				)
			,(
				SELECT TOP 1 ItemName
				FROM LookupItemView
				WHERE ItemId = (
						SELECT TOP 1 ConsentValue
						FROM PatientConsent
						WHERE PatientMasterVisitId = PM.Id
							AND ServiceAreaId = 2
							AND ConsentType = (
								SELECT ItemId
								FROM LookupItemView
								WHERE MasterName = 'ConsentType'
									AND ItemName = 'ConsentToBeTested'
								)
						ORDER BY Id DESC
						)
				) AS Consented
			,TestedAs = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.TestedAs
					AND MasterName = 'TestedAs'
				)
			,TestType = CASE HE.EncounterType
				WHEN 1
					THEN 'Initial Test'
				WHEN 2
					THEN 'Repeat Test'
				END
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVTestKits'
					AND ItemId = (
						SELECT TOP 1 KitId
						FROM Testing
						WHERE HtsEncounterId = HE.Id
							AND TestRound = 1
						ORDER BY Id DESC
						)
				) AS Test_1_Kit_Name
			,(
				SELECT TOP 1 KitLotNumber
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 1
				ORDER BY Id DESC
				) AS Test_1_Lot_Number
			,(
				SELECT TOP 1 ExpiryDate
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 1
				ORDER BY Id DESC
				) AS Test_1_Expiry_Date
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVFinalResults'
					AND ItemId = (
						SELECT TOP 1 RoundOneTestResult
						FROM HtsEncounterResult
						WHERE HtsEncounterId = HE.Id
						ORDER BY Id DESC
						)
				) AS Test_1_Final_Result
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVTestKits'
					AND ItemId = (
						SELECT TOP 1 KitId
						FROM Testing
						WHERE HtsEncounterId = HE.Id
							AND TestRound = 2
						ORDER BY Id DESC
						)
				) AS Test_2_Kit_Name
			,(
				SELECT TOP 1 KitLotNumber
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 2
				ORDER BY Id DESC
				) AS Test_2_Lot_Number
			,(
				SELECT TOP 1 ExpiryDate
				FROM Testing
				WHERE HtsEncounterId = HE.Id
					AND TestRound = 2
				ORDER BY Id DESC
				) AS Test_2_Expiry_Date
			,(
				SELECT ItemName
				FROM LookupItemView
				WHERE MasterName = 'HIVFinalResults'
					AND ItemId = (
						SELECT TOP 1 RoundTwoTestResult
						FROM HtsEncounterResult
						WHERE HtsEncounterId = HE.Id
						ORDER BY Id DESC
						)
				) AS Test_2_Final_Result
			,Final_Result = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HER.FinalResult
					AND MasterName = 'HIVFinalResults'
				)
			,Result_given = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.FinalResultGiven
					AND MasterName = 'YesNo'
				)
			,Couple_Discordant = (
				SELECT ItemName
				FROM LookupItemView
				WHERE ItemId = HE.CoupleDiscordant
					AND MasterName = 'YesNoNA'
				)
			,TB_SCreening_Results = (
				SELECT TOP 1 ItemName
				FROM LookupItemView
				WHERE MasterName = 'TbScreening'
					AND ItemId = (
						SELECT TOP 1 ScreeningValueId
						FROM PatientScreening
						WHERE PatientMasterVisitId = PM.Id
							AND PatientId = PT.Id
							AND ScreeningTypeId = (
								SELECT TOP 1 MasterId
								FROM LookupItemView
								WHERE MasterName = 'TbScreening'
								)
						)
				)
			,HE.EncounterRemarks AS Remarks
			,0 AS Voided
		FROM HtsEncounter HE
		LEFT JOIN HtsEncounterResult HER ON HER.HtsEncounterId = HE.Id
		INNER JOIN PatientEncounter PE ON PE.Id = HE.PatientEncounterID
		INNER JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
		INNER JOIN Person P ON P.Id = HE.PersonId
		INNER JOIN Patient PT ON PT.PersonId = P.Id
		LEFT JOIN (
			SELECT Main.Person_Id
				,LEFT(Main.Disability, Len(Main.Disability) - 1) AS "Disability"
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView
								WHERE MasterName = 'Disabilities'
									AND ItemId = CD.DisabilityId
								) + ' , ' AS [text()]
						FROM ClientDisability CD
						INNER JOIN PatientEncounter PE ON PE.Id = CD.PatientEncounterID
						WHERE CD.PersonId = P.Id
						ORDER BY CD.PersonId
						FOR XML PATH('')
						) [Disability]
				FROM Person P
				) [Main]
			) PI ON PI.Person_Id = P.Id
		LEFT JOIN (
			SELECT PPL.Person_Id
				,PPL.PopulationType
				,PPL.KeyPop
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,PPT.PopulationType
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView LK
								WHERE LK.ItemId = PP.PopulationCategory
									AND MasterName = 'HTSKeyPopulation'
								) + ' , ' AS [text()]
						FROM PatientPopulation PP
						WHERE PP.PersonId = P.Id
						ORDER BY PP.PersonId
						FOR XML PATH('')
						) [KeyPop]
				FROM Person P
				LEFT JOIN PatientPopulation PPT ON PPT.PersonId = P.Id
				) PPL
			) PPL2 ON PPL2.Person_Id = P.Id
		LEFT JOIN (
			SELECT PPR.Person_Id
				,PPR.PrioPop
			FROM (
				SELECT DISTINCT P.Id Person_Id
					,(
						SELECT (
								SELECT ItemName
								FROM LookupItemView LK
								WHERE LK.ItemId = PP.PriorityId
									AND MasterName = 'PriorityPopulation'
								) + ' , ' AS [text()]
						FROM PersonPriority PP
						WHERE PP.PersonId = P.Id
						ORDER BY PP.PersonId
						FOR XML PATH('')
						) [PrioPop]
				FROM Person P
				LEFT JOIN PersonPriority PPY ON PPY.PersonId = P.Id
				) PPR
			) PPR2 ON PPR2.Person_Id = P.Id
		) hts
	WHERE hts.Final_Result = 'Positive'
	) hts

