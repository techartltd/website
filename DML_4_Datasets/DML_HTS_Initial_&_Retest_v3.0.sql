

SELECT hts.Person_Id
	,hts.Patient_Id
	,hts.Encounter_Date
	,hts.Encounter_ID
	,hts.Pop_Type
	,hts.Key_Pop_Type
	,hts.Priority_Pop_Type
	,hts.Patient_disabled
	,hts.Disability
	,hts.Ever_Tested
	,hts.Self_Tested
	,hts.MonthSinceSelfTest
	,hts.MonthsSinceLastTest
	,hts.HTS_Strategy
	,hts.HTS_Entry_Point
	,hts.Consented
	,hts.TestedAs
	,CASE 
		WHEN hts.Test_1_Final_Result = 'Positive'
			AND ROW_NUMBER() OVER (
				PARTITION BY hts.Person_Id ORDER BY hts.Encounter_ID ASC
				) > 1
			THEN 'Repeat Test'
		ELSE hts.TestType
		END AS TestType
	,hts.Test_1_Kit_Name
	,hts.Test_1_Lot_Number
	,hts.Test_1_Expiry_Date
	,hts.Test_1_Final_Result
	,hts.Test_2_Kit_Name
	,hts.Test_2_Lot_Number
	,hts.Test_2_Expiry_Date
	,hts.Test_2_Final_Result
	,hts.Final_Result
	,hts.Result_given
	,hts.Couple_Discordant
	,hts.TB_SCreening_Results
	,hts.Remarks
	,hts.Voided
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
			,Main.Disability AS "Disability"
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

UNION

SELECT *
FROM (
	SELECT hts.Person_Id
		,hts.Patient_Id
		,hts.Encounter_Date
		,NULL Encounter_ID
		,hts.Pop_Type
		,hts.Key_Pop_Type
		,hts.Priority_Pop_Type
		,hts.Patient_disabled
		,hts.Disability
		,hts.Ever_Tested
		,hts.Self_Tested
		,hts.MonthSinceSelfTest
		,hts.MonthsSinceLastTest
		,hts.HTS_Strategy
		,hts.HTS_Entry_Point
		,hts.Consented
		,hts.TestedAs
		,'Repeat Test' AS TestType
		,NULL Test_1_Kit_Name
		,NULL Test_1_Lot_Number
		,NULL Test_1_Expiry_Date
		,hts.Test_1_Final_Result
		,NULL Test_2_Kit_Name
		,NULL Test_2_Lot_Number
		,NULL Test_2_Expiry_Date
		,hts.Test_2_Final_Result
		,hts.Final_Result
		,hts.Result_given
		,hts.Couple_Discordant
		,hts.TB_SCreening_Results
		,hts.Remarks
		,hts.Voided
		,hts.CreatedBy
		hts.CreateDate
	
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
			,PE.CreateDate
			,PE.createdby as CreatedBy
		FROM HtsEncounter HE
		LEFT JOIN HtsEncounterResult HER ON HER.HtsEncounterId = HE.Id
		INNER JOIN PatientEncounter PE ON PE.Id = HE.PatientEncounterID
		INNER JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
		INNER JOIN Person P ON P.Id = HE.PersonId
		INNER JOIN Patient PT ON PT.PersonId = P.Id
		LEFT JOIN (
			SELECT Main.Person_Id
				,Main.Disability AS "Disability"
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
							AND CD.DeleteFlag = 0
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
	) htsp
WHERE htsp.Test_1_Final_Result = 'Positive'
	AND htsp.Person_Id NOT IN (
		SELECT htspr.Person_Id
		FROM (
			SELECT HE.PersonId Person_Id
				,ROW_NUMBER() OVER (
					PARTITION BY HE.PersonId ORDER BY HE.Id ASC
					) AS rownum
			FROM HtsEncounter HE
			LEFT JOIN HtsEncounterResult HER ON HER.HtsEncounterId = HE.Id
			INNER JOIN PatientEncounter PE ON PE.Id = HE.PatientEncounterID
			INNER JOIN PatientMasterVisit PM ON PM.Id = PE.PatientMasterVisitId
			INNER JOIN Person P ON P.Id = HE.PersonId
			INNER JOIN Patient PT ON PT.PersonId = P.Id
			LEFT JOIN (
				SELECT Main.Person_Id
					,Main.Disability AS "Disability"
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
			) htspr
		WHERE htspr.rownum = 2
		)

