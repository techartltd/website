 
 
 --MCH Delivery
 
 

EXEC Pr_opendecryptedsession;


SELECT p.id AS Person_Id,
       d.visitdate AS Encounter_Date,
       NULL AS Encounter_ID,
       h.identifiervalue AS Admission_Number,
       I.lmp,
       I.edd,
       I.ageatmenarche AS AgeAtMenarche,
       I.parity AS Parity,
       I.parity2 AS Plus,
       I.gravidae,
       I.gestation AS Gestation_Weeks,
       pd.diagnosis AS Diagnosis,
       pd.managementplan AS ManagementPlan,
       delivery.durationoflabour AS Duration_Labour,
       delivery.modeofdelivery AS Delivery_Mode,
       delivery.dateofdelivery AS Delivery_Date_Time,
       delivery.timeofdelivery AS DeliveryTime,
       delivery.bloodlossclassification AS Blood_Loss,
       delivery.bloodlosscapacity AS [Blood_LossValue(mls)],
       delivery.mothercondition AS Mother_Condition,
       delivery.placentacomplete,
       delivery.maternaldeathaudited AS Death_Audited,
       delivery.maternaldeathauditdate,
       CASE
           WHEN dbbi.resuscitationdone = 1 THEN 'Yes'
           WHEN dbbi.resuscitationdone = 0 THEN 'No'
           ELSE NULL
       END AS ResuscitationDone,
       delivery.deliverycomplicationsexperienced AS Delivery_Complications,
       NULL AS delivery_Complications_Type,
       delivery.deliverycomplicationnotes AS Deilvery_Complications_Other ,
       NULL Delivery_Place,
            delivery.deliveryconductedby AS Delivery_Conducted_By,
            NULL AS Delivery_Cadre,
            NULL AS Delivery_Outcome,
            PatOutcome.datedischarged AS Delivery_DischargeDate,
            NULL Baby_Name,
                 Baby_Sex=
  (SELECT TOP 1 itemname
   FROM [dbo].[lookupitemview]
   WHERE itemid = dbbi.sex),
                 dbbi.birthweight AS Baby_Weight,
                 PatOutcome.outcomestatus AS Baby_Condition,
                 CASE
                     WHEN dbbi.birthdeformity = 0 THEN 'No'
                     WHEN dbbi.birthdeformity = 1 THEN 'Yes'
                     ELSE NULL
                 END AS Birth_Deformity,
                 CASE
                     WHEN dbbi.teogiven = 0 THEN 'No'
                     WHEN dbbi.teogiven = 1 THEN 'Yes'
                     ELSE NULL
                 END AS TEO_Birth,
                 CASE
                     WHEN dbbi.breastfedwithinhr = 0 THEN 'No'
                     WHEN dbbi.breastfedwithinhr = 1 THEN 'Yes'
                     ELSE NULL
                 END AS BF_At_Birth_Less_1_hr,
                 apgar.apgar1min AS Apgar_1,
                 apgar.apgar5min AS Apgar_5,
                 apgar.apgar10min AS Apgar_10,
                 dbbi.birthnotificationnumber,
                 dbbi.birthcomments,
                 HIVTest.onekitid AS Test_1_kit_name,
                 HIVTest.onelotnumber AS Test_1_kit_lot_no,
                 HIVTest.oneexpirydate AS Test_1_kit_expiry,
                 HIVTest.finaltestoneresult AS Test_1_result,
                 HIVTest.twokitid AS Test_2_kit_name,
                 HIVTest.twolotnumber AS Test_2_kit_lot_no,
                 HIVTest.twoexpirydate AS Test_2_kit_expiry,
                 HIVTest.finaltesttworesult AS Test_2_result,
                 z.finalresult AS Final_test_Result,
                 HIVTest.testtype AS Test_Type,
                 HIVTest.finalresultgiven AS Patient_given_result,
                 partnerTesting.partnertested AS Partner_hiv_tested,
                 partnerTesting.partnerhivresult AS Partner_hiv_status,
                 NULL AS Next_HIV_Date,
                 tst.finding AS TestedForSyphillis,
                 tss.finding AS Syphillis_Treated,
                 CTX.ctx AS Prophylaxis_given,
                 [azt for baby] AS Baby_azt_dispensed,
                 [nvp for baby] AS Baby_nvp_dispensed,
                 HAARTMAT.[started haart mat],
                 HAARTANC.[started haart in anc],
                 VITS.[vitaminasupplementation],
                 TCAs.[description] AS Clinical_notes,
                 TCAs.appointmentdate AS Next_Appointment_Date,
                 d.deleteflag AS Voided 
FROM person p
INNER JOIN patient b ON b.personid = p.id
INNER JOIN patientmastervisit d ON b.id = d.patientid
INNER JOIN
  (SELECT a.patientid,
          enrollmentdate,
          identifiervalue,
          NAME,
          visitdate,
          patientmastervisitid,
          visittype,
          [visitnumber],
          [dayspostpartum]
   FROM patientenrollment a
   INNER JOIN servicearea b ON a.serviceareaid = b.id
   INNER JOIN patientidentifier c ON c.patientid = a.patientid
   INNER JOIN serviceareaidentifiers d ON c.identifiertypeid = d.identifierid
   AND b.id = d.serviceareaid
   INNER JOIN dbo.visitdetails AS g ON a.patientid = g.patientid
   AND b.id = g.serviceareaid
   WHERE b.NAME = 'Maternity') AS h ON b.id = h.patientid
AND d.id = h.patientmastervisitid
LEFT JOIN dbo.pregnancy AS I ON b.id = I.patientid
AND I.patientmastervisitid = h.patientmastervisitid
LEFT JOIN
  (SELECT DISTINCT delivery.deliveryid,
                   [patientmastervisitid],
                   [durationoflabour],
                   [dateofdelivery],
                   [timeofdelivery],
                   lkup2.itemname ModeOfDelivery,
                   lkup3.itemname [PlacentaComplete],
                   [bloodlosscapacity],
                   lkup4.itemname [MotherCondition],
                   lkup.itemname [DeliveryComplicationsExperienced],
                   [deliverycomplicationnotes],
                   [deliveryconductedby],
                   [maternaldeathauditdate],
                   lt.[name] AS MaternalDeathAudited,
                   lkbl.itemname AS [BloodLossClassification]
   FROM dbo.patientdelivery AS delivery
   LEFT JOIN dbo.lookupitemview AS lkup2 ON lkup2.itemid = delivery.[modeofdelivery]
   LEFT JOIN dbo.lookupitemview AS lkup3 ON lkup3.itemid = delivery.[placentacomplete]
   LEFT JOIN dbo.lookupitemview AS lkup4 ON lkup4.itemid = delivery.[mothercondition]
   LEFT JOIN dbo.lookupitemview AS lkup ON lkup.itemid = delivery.[deliverycomplicationsexperienced]
   LEFT JOIN dbo.lookupitemview AS lkbl ON lkbl.itemid = delivery.bloodlossclassification
   LEFT JOIN lookupitem lt ON lt.id = delivery.maternaldeathaudited) delivery ON delivery.patientmastervisitid = d.id
LEFT JOIN dbo.deliveredbabybirthinformation dbbi ON dbbi.patientmastervisitid = d.id
AND delivery.deliveryid = dbbi.deliveryid
LEFT JOIN
  (SELECT b.patientid,
          [patientmastervisitid],
          [datedischarged],
          [OutcomeStatus]=
     (SELECT TOP 1 itemname
      FROM [dbo].[lookupitemview]
      WHERE itemid = a.[outcomestatus]),
          [outcomedescription]
   FROM [dbo].[patientoutcome]a
   INNER JOIN patientmastervisit b ON a.patientmastervisitid = b.id
   WHERE a.deleteflag = 0)PatOutcome ON PatOutcome.patientid = b.id
AND PatOutcome.patientmastervisitid = d.id
LEFT JOIN
  (SELECT deliveredbabybirthinformationid,
          Max(apgar1min)APGAR1min,
          Max(apgar1min)APGAR5min,
          Max(apgar1min)APGAR10min
   FROM
     (SELECT a.id,
             a.[deliveredbabybirthinformationid],
             APGAR1min=
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 1 min') ,
             APGAR5min=
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 5 min') ,
             APGAR10min =
        (SELECT TOP 1 score
         FROM [dbo].[lookupitemview]
         WHERE itemid = a.[apgarscoreid]
           AND itemname = 'Apgar Score 10 min')
      FROM [dbo].[deliveredbabyapgarscore] a
      INNER JOIN [dbo].[deliveredbabybirthinformation]b ON a.[deliveredbabybirthinformationid] = b.[id])a GROUP  BY deliveredbabybirthinformationid)apgar ON apgar.deliveredbabybirthinformationid = dbbi.id
LEFT OUTER JOIN ------------------HIV tests

  (SELECT DISTINCT e.personid,
                   Isnull(Cast((CASE e.encountertype
                                    WHEN 1 THEN 'Initial Test'
                                    WHEN 2 THEN 'Repeat Test'
                                END) AS VARCHAR(50)), 'Initial') AS TestType,
                   one.kitid AS OneKitId,
                   one.kitlotnumber AS OneLotNumber ,
                   one.outcome AS FinalTestOneResult,
                   one.encountertype AS encounterone ,
                   two.outcome AS FinalTestTwoResult,
                   one.expirydate AS OneExpiryDate,
                   two.kitid AS twokitid,
                   two.kitlotnumber AS twolotnumber ,
                   two.expirydate AS twoexpirydate,
                   one.encountertype AS encountertwo ,
                   FinalResultGiven =
     (SELECT TOP 1 itemname
      FROM [dbo].[lookupitemview]
      WHERE itemid = e.finalresultgiven)
   FROM testing t
   INNER JOIN [htsencounter] e ON t .htsencounterid = e.id
   LEFT JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
   INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
   LEFT OUTER JOIN
     (SELECT DISTINCT htsencounterid,
                      b.itemname kitid,
                      kitlotnumber,
                      expirydate,
                      personid,
                      l.itemname AS outcome,
                      e.encountertype
      FROM [testing] t
      INNER JOIN [htsencounter] e ON t.htsencounterid = e.id
      INNER JOIN [lookupitemview] l ON l.itemid = t.outcome
      INNER JOIN lookupitemview b ON b.itemid = t.kitid
      INNER JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
      INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
      WHERE e.encountertype = 1
        AND t.testround = 1
        AND c.itemname = 'maternity-encounter') one ON one.personid = e.personid
   FULL OUTER JOIN
     (SELECT DISTINCT htsencounterid,
                      b.itemname kitid,
                      kitlotnumber,
                      expirydate,
                      personid,
                      l.itemname AS outcome,
                      e.encountertype
      FROM [testing] t
      INNER JOIN [htsencounter] e ON t.htsencounterid = e.id
      INNER JOIN [lookupitemview] l ON l.itemid = t.outcome
      INNER JOIN lookupitemview b ON b.itemid = t.kitid
      INNER JOIN [dbo].[patientencounter] pe ON pe.id = e.patientencounterid
      INNER JOIN lookupitemview c ON c.itemid = pe.encountertypeid
      WHERE t.testround = 2
        AND c.itemname = 'maternity-encounter') two ON two.personid = e.personid
   WHERE c.itemname = 'maternity-encounter')HIVTest ON HIVTest.personid = b.personid
LEFT OUTER JOIN
  (SELECT he.personid,
          he.patientencounterid,
          lk.itemname AS FinalResult
   FROM dbo.htsencounter AS he
   INNER JOIN dbo.htsencounterresult AS her ON he.id = her.htsencounterid
   INNER JOIN dbo.patientencounter AS pe ON pe.id = he.patientencounterid
   LEFT OUTER JOIN dbo.lookupitemview AS lk1 ON lk1.itemid = pe.encountertypeid
   LEFT OUTER JOIN dbo.lookupitemview AS lk ON lk.itemid = her.finalresult
   WHERE (lk1.itemname = 'Maternity')) AS z ON z.personid = b.personid
LEFT OUTER JOIN
  (SELECT DISTINCT a.patientid,
                   a.patientmastervisitid,
                   d.itemname [PartnerTested],
                   e.itemname [PartnerHIVResult]
   FROM [dbo].[patientpartnertesting] a
   INNER JOIN dbo.patientencounter b ON a.patientmastervisitid = b.patientmastervisitid
   LEFT OUTER JOIN dbo.lookupitemview c ON c.itemid = b.encountertypeid
   LEFT OUTER JOIN dbo.lookupitemview d ON d.itemid = a.[partnertested]
   LEFT OUTER JOIN dbo.lookupitemview e ON e.itemid = a.[partnerhivresult]
   WHERE (c.itemname = 'maternity-encounter')) partnerTesting ON partnerTesting.patientid = b.id
AND partnerTesting.patientmastervisitid = d.id
LEFT JOIN
  (SELECT b.id PatientId,
          [orderedbydate],
          [reportedbydate],
          [testresults],
          [testresults1],
          [visitdate]
   FROM [dbo].[vw_patientlaboratory] a
   INNER JOIN patient b ON b.ptn_pk = a.ptn_pk
   WHERE testname LIKE '%RPR%'
     AND hasresult = 1)RPRLab ON RPRLab.patientid = b.id
AND RPRLab.orderedbydate = d.[visitdate]
LEFT JOIN
  (SELECT pe.patientid,
          pe.patientmastervisitid,
          pe.examinationtypeid,
          lm.[name] AS ExaminationType,
          pe.examid,
          lt.[name] AS ExaminationName,
          pe.findingid AS FindingId,
          ltf.[name] AS Finding,
          pe.deleteflag,
          pe.createby
   FROM physicalexamination pe
   LEFT JOIN lookupmaster lm ON lm.id = pe.examinationtypeid
   INNER JOIN lookupitem lt ON lt.id = pe.examid
   LEFT JOIN lookupitem ltf ON ltf.id = pe.findingid
   WHERE lt.[name] = 'Treated Syphilis')tss ON tss.patientid = b.id
AND tss.patientmastervisitid = d.id
LEFT JOIN
  (SELECT pe.patientid,
          pe.patientmastervisitid,
          pe.examinationtypeid,
          lm.[name] AS ExaminationType,
          pe.examid,
          lt.[name] AS ExaminationName,
          pe.findingid AS FindingId,
          ltf.[name] AS Finding,
          pe.deleteflag,
          pe.createby
   FROM physicalexamination pe
   LEFT JOIN lookupmaster lm ON lm.id = pe.examinationtypeid
   INNER JOIN lookupitem lt ON lt.id = pe.examid
   LEFT JOIN lookupitem ltf ON ltf.id = pe.findingid
   WHERE lt.[name] = 'Treated For Syphilis') tst ON tst.patientid = b.id
AND tst.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [CTX]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE a.itemname = 'Cotrimoxazole')CTX ON CTX.patientid = b.id
AND CTX.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   [itemname] [AZT for Baby]
   FROM [dbo].[lookupitemview]a
   INNER JOIN dbo.patientdrugadministration b ON b.value = a.itemid
   WHERE description = 'AZT for the baby dispensed'
     OR description = 'Infant Provided With ARV prophylaxis' )AZTBaby ON AZTBaby.patientid = b.id
AND AZTBaby.patientmastervisitid = d.id
LEFT OUTER JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   [itemname] [NVP for Baby]
   FROM [dbo].[lookupitemview]a
   INNER JOIN dbo.patientdrugadministration b ON b.value = a.itemid
   WHERE description = 'NVP for the baby dispensed') NVPBaby ON NVPBaby.patientid = b.id
AND NVPBaby.patientmastervisitid = d.id
LEFT JOIN
  (SELECT DISTINCT *
   FROM
     (SELECT *,
             Row_number() OVER(PARTITION BY tc.patientid, tc.patientmastervisitid
                               ORDER BY tc.createdate DESC)rownum
      FROM
        (SELECT [patientmastervisitid],
                [patientid],
                [appointmentdate],
                [AppointmentReason]=
           (SELECT TOP 1 itemname
            FROM [dbo].[lookupitemview]
            WHERE itemid = [reasonid]),
                [description],
                deleteflag,
                createdate
         FROM [dbo].[patientappointment]
         WHERE deleteflag = 0
           AND serviceareaid = 3) tc
      WHERE tc.appointmentreason = 'Follow Up')tc
   WHERE tc.rownum = 1)TCAs ON TCAs.patientid = b.id
AND TCAs.patientmastervisitid = d.id
LEFT JOIN
  (SELECT *
   FROM patientdiagnosis pd
   WHERE (pd.deleteflag IS NULL
          OR pd.deleteflag = 0))pd ON pd.patientmastervisitid = d.id
AND pd.patientid = b.id
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [Started HAART in ANC]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'Started HAART in ANC')HAARTANC ON HAARTANC.patientid = b.id
AND HAARTANC.patientmastervisitid = d.id
LEFT OUTER JOIN dbo.patientdiagnosis AS diag ON diag.patientmastervisitid = d.id
LEFT OUTER JOIN dbo.patientvitals AS k ON d.id = k.patientmastervisitid
AND b.id = k.patientid
AND k.visitdate = d.visitdate
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [Started HAART MAT]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'ARVs Started in Maternity')HAARTMAT ON HAARTMAT.patientid = b.id
AND HAARTMAT.patientmastervisitid = d.id
LEFT JOIN
  (SELECT DISTINCT b.patientid,
                   b.patientmastervisitid,
                   c.[itemname] [VitaminASupplementation]
   FROM dbo.patientdrugadministration b
   INNER JOIN [dbo].[lookupitemview]a ON b.drugadministered = a.itemid
   INNER JOIN [dbo].[lookupitemview]c ON c.itemid = b.value
   WHERE b.[description] = 'Vitamin A Supplementation')VITS ON VITS.patientid = b.id
AND VITS.patientmastervisitid = d.id
