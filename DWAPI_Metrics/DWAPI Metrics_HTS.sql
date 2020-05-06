INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 

--- 
INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced where Contact_Outcome is Contacted', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 
WHERE  t.contact_outcome = 'Contacted' 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTSClientTracing', 
       'NumberofHTSClientTraced where Contact_Outcome is Contacted and Linked', 
       Count(*) Total 
FROM  (SELECT T.personid   AS Person_Id, 
              Encounter_Date = T.datetracingdone, 
              Encounter_ID = NULL, 
              Contact_Type = (SELECT TOP 1 itemname 
                              FROM   lookupitemview 
                              WHERE  itemid = T.mode 
                                     AND mastername = 'TracingMode'), 
              Contact_Outcome = (SELECT TOP 1 itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = T.outcome 
                                        AND mastername = 'TracingOutcome'), 
              Reason_uncontacted = 
              (SELECT TOP 1 itemname 
               FROM   lookupitemview 
               WHERE  itemid = T.reasonnotcontacted 
                      AND mastername IN ( 
                          'TracingReasonNotContactedPhone', 
                          'TracingReasonNotContactedPhysical' )), 
              T.otherreasonspecify, 
              T.remarks, 
              T.deleteflag Voided 
       FROM   (SELECT re.personid, 
                      re.patientid, 
                      re.finalresult 
               FROM   (SELECT pe.patientencounterid, 
                              pe.patientmastervisitid, 
                              pe.patientid, 
                              pe.personid, 
                              pe.finalresult, 
                              Row_number() 
                                OVER( 
                                  partition BY pe.patientid 
                                  ORDER BY pe.patientmastervisitid DESC)rownum 
                       FROM  (SELECT DISTINCT PE.id        PatientEncounterId, 
                                              PE.patientmastervisitid, 
                                              PE.patientid PatientId, 
                                              HE.personid, 
                                              ResultOne = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundonetestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              ResultTwo = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 roundtwotestresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResult = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE  itemid = 
                                              (SELECT TOP 1 finalresult 
                                               FROM   [dbo].[htsencounterresult] 
                                               WHERE  htsencounterid = HE.id 
                                               ORDER  BY id DESC)), 
                                              FinalResultGiven = 
                                              (SELECT TOP 1 itemname 
                                               FROM   [dbo].[lookupitemview] 
                                               WHERE 
                             itemid = HE.finalresultgiven) 
                              FROM   [dbo].[patientencounter] PE 
                                     INNER JOIN [dbo].[patientmastervisit] PM 
                                             ON PM.id = PE.patientmastervisitid 
                                     INNER JOIN [dbo].[htsencounter] HE 
                                             ON PE.id = HE.patientencounterid)pe 
                       WHERE  pe.finalresult = 'Positive') re 
               WHERE  re.rownum = 1)pep 
              INNER JOIN tracing T 
                      ON pep.personid = T.personid)t 
WHERE  t.contact_outcome = 'Contacted and Linked' 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTS_Initial_&_Retest', 
       'Number of HTS Test that FinalResult was Negative', 
       Count(*) Total 
FROM  (SELECT * 
       FROM  (SELECT HE.personid                               Person_Id, 
                     PT.id                                     Patient_Id, 
                     Encounter_Date = Format(Cast(PE.encounterstarttime AS DATE) 
                                      , 
                                      'yyyy-MM-dd'), 
                     Encounter_ID = HE.id, 
                     Pop_Type = PPL2.populationtype, 
                     Key_Pop_Type = PPL2.keypop, 
                     Priority_Pop_Type = PPR2.priopop, 
                     Patient_disabled = ( CASE Isnull(PI.disability, '') 
                                            WHEN '' THEN 'No' 
                                            ELSE 'Yes' 
                                          END ), 
                     PI.disability, 
                     Ever_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.evertested 
                                           AND mastername = 'YesNo'), 
                     Self_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.everselftested 
                                           AND mastername = 'YesNo'), 
                     HE.monthsinceselftest,--added 
                     HE.monthssincelasttest,--added 
                     HTS_Strategy = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  mastername = 'Strategy' 
                                            AND itemid = HE.testingstrategy), 
                     HTS_Entry_Point = (SELECT itemname 
                                        FROM   lookupitemview 
                                        WHERE  mastername = 'HTSEntryPoints' 
                                               AND itemid = HE.testentrypoint), 
                     (SELECT TOP 1 itemname 
                      FROM   lookupitemview 
                      WHERE  itemid = (SELECT TOP 1 consentvalue 
                                       FROM   patientconsent 
                                       WHERE  patientmastervisitid = PM.id 
                                              AND serviceareaid = 2 
                                              AND consenttype = (SELECT itemid 
                                                                 FROM 
                                                  lookupitemview 
                                                                 WHERE 
                                                  mastername = 'ConsentType' 
                                                  AND 
                                                  itemname = 'ConsentToBeTested' 
                                                                ) 
                                       ORDER  BY id DESC))     AS Consented, 
                     TestedAs = (SELECT itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = HE.testedas 
                                        AND mastername = 'TestedAs'), 
                     TestType = CASE HE.encountertype 
                                  WHEN 1 THEN 'Initial Test' 
                                  WHEN 2 THEN 'Repeat Test' 
                                END, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 1 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundonetestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Final_Result, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 2 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundtwotestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Final_Result, 
                     Final_Result = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HER.finalresult 
                                            AND mastername = 'HIVFinalResults'), 
                     Result_given = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HE.finalresultgiven 
                                            AND mastername = 'YesNo'), 
                     Couple_Discordant = (SELECT itemname 
                                          FROM   lookupitemview 
                                          WHERE  itemid = HE.couplediscordant 
                                                 AND mastername = 'YesNoNA'), 
                     TB_SCreening_Results = (SELECT TOP 1 itemname 
                                             FROM   lookupitemview 
                                             WHERE 
                     mastername = 'TbScreening' 
                     AND itemid = (SELECT TOP 1 
                                  screeningvalueid 
                                   FROM 
                         patientscreening 
                                   WHERE 
                         patientmastervisitid 
                         = PM.id 
                         AND patientid = 
                             PT.id 
                         AND screeningtypeid 
                             = 
                     ( 
                                 SELECT 
                     TOP 1 
                     masterid 
                                 FROM 
                     lookupitemview 
                                 WHERE 
                                 mastername = 
                                 'TbScreening'))) 
                            , 
                     HE.encounterremarks                       AS Remarks, 
                     0                                         AS Voided 
              FROM   htsencounter HE 
                     LEFT JOIN htsencounterresult HER 
                            ON HER.htsencounterid = HE.id 
                     INNER JOIN patientencounter PE 
                             ON PE.id = HE.patientencounterid 
                     INNER JOIN patientmastervisit PM 
                             ON PM.id = PE.patientmastervisitid 
                     INNER JOIN person P 
                             ON P.id = HE.personid 
                     INNER JOIN patient PT 
                             ON PT.personid = P.id 
                     LEFT JOIN (SELECT Main.person_id, 
LEFT(Main.disability, Len(Main.disability) - 1) 
AS 
                              "Disability" 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM   lookupitemview 
                          WHERE 
                 mastername = 'Disabilities' 
                 AND itemid = CD.disabilityid) 
                         + ' , ' AS [text()] 
                  FROM   clientdisability CD 
INNER JOIN patientencounter 
           PE 
        ON 
PE.id = CD.patientencounterid 
                  WHERE  CD.personid = P.id 
                  ORDER  BY CD.personid 
                  FOR xml path ('')) 
                 [Disability] 
 FROM   person P) [Main]) PI 
ON PI.person_id = P.id 
LEFT JOIN (SELECT PPL.person_id, 
PPL.populationtype, 
PPL.keypop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 PPT.populationtype, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
LK.itemid = PP.populationcategory 
AND mastername = 'HTSKeyPopulation') 
        + ' , ' AS [text()] 
 FROM   patientpopulation PP 
 WHERE  PP.personid = P.id 
 ORDER  BY PP.personid 
 FOR xml path ('')) [KeyPop] 
 FROM   person P 
        LEFT JOIN patientpopulation PPT 
               ON PPT.personid = P.id) PPL) 
PPL2 
ON PPL2.person_id = P.id 
LEFT JOIN (SELECT PPR.person_id, 
PPR.priopop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
                 LK.itemid = PP.priorityid 
                 AND mastername = 
                     'PriorityPopulation') 
                         + ' , ' AS [text()] 
                  FROM   personpriority PP 
                  WHERE  PP.personid = P.id 
                  ORDER  BY PP.personid 
                  FOR xml path ('')) [PrioPop] 
 FROM   person P 
        LEFT JOIN personpriority PPY 
               ON PPY.personid = P.id) PPR) 
PPR2 
ON PPR2.person_id = P.id)hts 
WHERE  hts.final_result = 'Negative')hts 

INSERT INTO dwapi_migration_metrics 
            (dataset, 
             metric, 
             metricvalue) 
SELECT 'HTS_Initial_&_Retest', 
       'Number of HTS Test that FinalResult was Positive', 
       Count(*) Total 
FROM  (SELECT * 
       FROM  (SELECT HE.personid                               Person_Id, 
                     PT.id                                     Patient_Id, 
                     Encounter_Date = Format(Cast(PE.encounterstarttime AS DATE) 
                                      , 
                                      'yyyy-MM-dd'), 
                     Encounter_ID = HE.id, 
                     Pop_Type = PPL2.populationtype, 
                     Key_Pop_Type = PPL2.keypop, 
                     Priority_Pop_Type = PPR2.priopop, 
                     Patient_disabled = ( CASE Isnull(PI.disability, '') 
                                            WHEN '' THEN 'No' 
                                            ELSE 'Yes' 
                                          END ), 
                     PI.disability, 
                     Ever_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.evertested 
                                           AND mastername = 'YesNo'), 
                     Self_Tested = (SELECT itemname 
                                    FROM   lookupitemview 
                                    WHERE  itemid = HE.everselftested 
                                           AND mastername = 'YesNo'), 
                     HE.monthsinceselftest,--added 
                     HE.monthssincelasttest,--added 
                     HTS_Strategy = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  mastername = 'Strategy' 
                                            AND itemid = HE.testingstrategy), 
                     HTS_Entry_Point = (SELECT itemname 
                                        FROM   lookupitemview 
                                        WHERE  mastername = 'HTSEntryPoints' 
                                               AND itemid = HE.testentrypoint), 
                     (SELECT TOP 1 itemname 
                      FROM   lookupitemview 
                      WHERE  itemid = (SELECT TOP 1 consentvalue 
                                       FROM   patientconsent 
                                       WHERE  patientmastervisitid = PM.id 
                                              AND serviceareaid = 2 
                                              AND consenttype = (SELECT itemid 
                                                                 FROM 
                                                  lookupitemview 
                                                                 WHERE 
                                                  mastername = 'ConsentType' 
                                                  AND 
                                                  itemname = 'ConsentToBeTested' 
                                                                ) 
                                       ORDER  BY id DESC))     AS Consented, 
                     TestedAs = (SELECT itemname 
                                 FROM   lookupitemview 
                                 WHERE  itemid = HE.testedas 
                                        AND mastername = 'TestedAs'), 
                     TestType = CASE HE.encountertype 
                                  WHEN 1 THEN 'Initial Test' 
                                  WHEN 2 THEN 'Repeat Test' 
                                END, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 1 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 1 
                      ORDER  BY id DESC)                       AS 
                     Test_1_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundonetestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_1_Final_Result, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVTestKits' 
                             AND itemid = (SELECT TOP 1 kitid 
                                           FROM   testing 
                                           WHERE  htsencounterid = HE.id 
                                                  AND testround = 2 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Kit_Name, 
                     (SELECT TOP 1 kitlotnumber 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Lot_Number, 
                     (SELECT TOP 1 expirydate 
                      FROM   testing 
                      WHERE  htsencounterid = HE.id 
                             AND testround = 2 
                      ORDER  BY id DESC)                       AS 
                     Test_2_Expiry_Date, 
                     (SELECT itemname 
                      FROM   lookupitemview 
                      WHERE  mastername = 'HIVFinalResults' 
                             AND itemid = (SELECT TOP 1 roundtwotestresult 
                                           FROM   htsencounterresult 
                                           WHERE  htsencounterid = HE.id 
                                           ORDER  BY id DESC)) AS 
                     Test_2_Final_Result, 
                     Final_Result = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HER.finalresult 
                                            AND mastername = 'HIVFinalResults'), 
                     Result_given = (SELECT itemname 
                                     FROM   lookupitemview 
                                     WHERE  itemid = HE.finalresultgiven 
                                            AND mastername = 'YesNo'), 
                     Couple_Discordant = (SELECT itemname 
                                          FROM   lookupitemview 
                                          WHERE  itemid = HE.couplediscordant 
                                                 AND mastername = 'YesNoNA'), 
                     TB_SCreening_Results = (SELECT TOP 1 itemname 
                                             FROM   lookupitemview 
                                             WHERE 
                     mastername = 'TbScreening' 
                     AND itemid = (SELECT TOP 1 
                                  screeningvalueid 
                                   FROM 
                         patientscreening 
                                   WHERE 
                         patientmastervisitid 
                         = PM.id 
                         AND patientid = 
                             PT.id 
                         AND screeningtypeid 
                             = 
                     ( 
                                 SELECT 
                     TOP 1 
                     masterid 
                                 FROM 
                     lookupitemview 
                                 WHERE 
                                 mastername = 
                                 'TbScreening'))) 
                            , 
                     HE.encounterremarks                       AS Remarks, 
                     0                                         AS Voided 
              FROM   htsencounter HE 
                     LEFT JOIN htsencounterresult HER 
                            ON HER.htsencounterid = HE.id 
                     INNER JOIN patientencounter PE 
                             ON PE.id = HE.patientencounterid 
                     INNER JOIN patientmastervisit PM 
                             ON PM.id = PE.patientmastervisitid 
                     INNER JOIN person P 
                             ON P.id = HE.personid 
                     INNER JOIN patient PT 
                             ON PT.personid = P.id 
                     LEFT JOIN (SELECT Main.person_id, 
LEFT(Main.disability, Len(Main.disability) - 1) 
AS 
                              "Disability" 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM   lookupitemview 
                          WHERE 
                 mastername = 'Disabilities' 
                 AND itemid = CD.disabilityid) 
                         + ' , ' AS [text()] 
                  FROM   clientdisability CD 
INNER JOIN patientencounter 
           PE 
        ON 
PE.id = CD.patientencounterid 
                  WHERE  CD.personid = P.id 
                  ORDER  BY CD.personid 
                  FOR xml path ('')) 
                 [Disability] 
 FROM   person P) [Main]) PI 
ON PI.person_id = P.id 
LEFT JOIN (SELECT PPL.person_id, 
PPL.populationtype, 
PPL.keypop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 PPT.populationtype, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
LK.itemid = PP.populationcategory 
AND mastername = 'HTSKeyPopulation') 
        + ' , ' AS [text()] 
 FROM   patientpopulation PP 
 WHERE  PP.personid = P.id 
 ORDER  BY PP.personid 
 FOR xml path ('')) [KeyPop] 
 FROM   person P 
        LEFT JOIN patientpopulation PPT 
               ON PPT.personid = P.id) PPL) 
PPL2 
ON PPL2.person_id = P.id 
LEFT JOIN (SELECT PPR.person_id, 
PPR.priopop 
FROM   (SELECT DISTINCT P.id                Person_Id, 
                 (SELECT (SELECT itemname 
                          FROM 
                 lookupitemview LK 
                          WHERE 
                 LK.itemid = PP.priorityid 
                 AND mastername = 
                     'PriorityPopulation') 
                         + ' , ' AS [text()] 
                  FROM   personpriority PP 
                  WHERE  PP.personid = P.id 
                  ORDER  BY PP.personid 
                  FOR xml path ('')) [PrioPop] 
 FROM   person P 
        LEFT JOIN personpriority PPY 
               ON PPY.personid = P.id) PPR) 
PPR2 
ON PPR2.person_id = P.id)hts 
WHERE  hts.final_result = 'Positive')hts 
