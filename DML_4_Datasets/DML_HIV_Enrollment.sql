-- -----------------------------2. HIV Enrollment DML ---------------------------------------------

exec pr_OpenDecryptedSession;


SELECT
  P.Id as Person_Id, 
 UPN =(select top 1 pdd.IdentifierValue from (select pid.PatientId,pid.IdentifierTypeId,pid.IdentifierValue,pdd.Code,pdd.DisplayName,pdd.[Name],pid.CreateDate,pid.DeleteFlag from PatientIdentifier pid
inner join (
select id.Id,id.[Name],id.[Code],id.[DisplayName]  from Identifiers id
inner join  IdentifierType it on it.Id =id.IdentifierType
where it.Name='Patient')pdd on pdd.Id=pid.IdentifierTypeId  ) pdd where pdd.PatientId = PT.Id and pdd.[Code]='CCCNumber' and pdd.DeleteFlag=0 order by pdd.CreateDate desc ),
  format(cast(PE.EnrollmentDate as date),'yyyy-MM-dd') AS Encounter_Date,
  NULL Encounter_ID,
  Patient_Type=(select itemName from LookupItemView where MasterName='PatientType' and itemId=PT.PatientType),
  ent.Entry_point, 
  pti.FacilityFrom AS TI_Facility,
  PE.EnrollmentDate as Date_First_enrolled_in_care,
  bas.TransferInDate as Transfer_In_Date,
  bas.ARTInitiationDate as Date_started_art_at_transferring_facility,
  bas.HIVDiagnosisDate as Date_Confirmed_hiv_positive,
  bas.FacilityFrom as Facility_confirmed_hiv_positive,
  bas.HistoryARTUse as Baseline_arv_use,
  parv.Purpose  as Purpose_of_Baseline_arv_use, 
  bas.CurrentTreatmentName as Baseline_arv_regimen,
  bas.RegimenName as Baseline_arv_regimen_line,
  parv.DateLastUsed as Baseline_arv_date_last_used,
  bas.EnrollmentWHOStageName as Baseline_who_stage,
  bas.CD4Count as Baseline_cd4_results,
  bas.EnrollmentDate as Baseline_cd4_date,
  bas.BaselineViralload as Baseline_vl_results,
  bas.BaselineViralloadDate as Baseline_vl_date,
  NULL as Baseline_vl_ldl_results,
  NULL as Baseline_vl_ldl_date,
  bas.HBVInfected  as Baseline_HBV_Infected,
  bas.TBinfected as Baseline_TB_Infected,
  bas.Pregnant as Baseline_Pregnant,
  bas.BreastFeeding as Baseline_BreastFeeding,
  bas.[Weight] as Baseline_Weight,
  bas.[Height] as Baseline_Height,
  bas.BMI as Baseline_BMI,
  treatmentl.Name_of_treatment_supporter,
  treatmentl.Relationship_of_treatment_supporter,
  treatmentl.Treatment_supporter_telephone,
  treatmentl.Treatment_supporter_address,  
  0 as Voided
FROM Person P
INNER JOIN Patient PT ON PT.PersonId = P.Id
  INNER JOIN PatientEnrollment PE ON PE.PatientId = PT.Id
  left JOIN (select * from (select  *,ROW_NUMBER() OVER(partition by PersonId order by CreateDate desc)rownum from PersonLocation where (DeleteFlag =0 or DeleteFlag is null))PLL where PLL.rownum='1') PL ON PL.PersonId = P.Id
  left  join (select ent.PatientId,ent.Entry_point from (select se.PatientId,se.EntryPointId,lt.DisplayName as Entry_point,ROW_NUMBER() OVER(partition
by se.PatientId order by CreateDate desc)rownum from ServiceEntryPoint  se
inner join LookupItem lt on lt.Id=se.EntryPointId
where se.DeleteFlag <> 1)ent where ent.rownum='1')ent on ent.PatientId=PT.Id
left join(select * from (select * ,ROW_NUMBER() OVER(partition by ph.PatientId order by PatientMasterVisitId desc)rownum
 from PatientARVHistory  ph)parv where parv.rownum=1)parv on parv.PatientId=PT.Id
  left join mst_Patient mst on mst.Ptn_Pk=PT.ptn_pk
  left join PatientTransferIn pti on pti.PatientId =PT.Id
  left join 
  (select pts.PersonId,pts.SupporterId,CAST(DECRYPTBYKEY(pts.MobileContact)AS VARCHAR(100)) as Treatment_supporter_telephone,
pt.FirstName + ' ' + pt.MiddleName + ' ' + pt.LastName as Name_of_treatment_supporter,
pcv.PhysicalAddress as Treatment_supporter_address ,rel.[Name]  as Relationship_of_treatment_supporter
 from PatientTreatmentSupporter pts
 left join Patient pat on pat.PersonId=pts.PersonId
left join PersonView pt on pt.Id=pts.SupporterId 
left join PersonContactView pcv on pcv.PersonId=pts.SupporterId
left join  LookupItem lt on lt.Id=pts.ContactCategory
left join PersonRelationship prl on prl.PersonId =pts.SupporterId and prl.PatientId =pat.Id
left join LookupItem rel on rel.Id=prl.RelationshipTypeId
where (lt.Name='TreatmentSupporter' or pts.ContactCategory=1))treatmentl on treatmentl.PersonId=P.Id
  left join (select * from(select * ,ROW_NUMBER() OVER(partition by PatientId order by PatientMasterVisitId)rownum from PatientBaselineView)rte
where rte.rownum=1) bas on bas.PatientId=PT.Id


  LEFT OUTER JOIN (
                    SELECT
                      PatientId,
                      ExitReason,
                      ExitDate
                    FROM dbo.PatientCareending where deleteflag=0
                    UNION
                    SELECT dbo.Patient.Id AS PatientId
                      ,CASE (SELECT TOP 1 Name FROM mst_Decode WHERE CodeID=23 AND ID = (SELECT TOP 1 PatientExitReason FROM dtl_PatientCareEnded WHERE Ptn_Pk = dbo.Patient.ptn_pk AND CareEnded=1))
                       WHEN 'Lost to follow-up'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'LostToFollowUp')
                       WHEN 'HIV Negative'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'HIV Negative')
                       WHEN 'Death'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Death')
                       WHEN 'Confirmed HIV Negative'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Confirmed HIV Negative')
                       WHEN 'Transfer to ART'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       WHEN 'Transfer to another LPTF'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       WHEN 'Discharged at 18 months'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Confirmed HIV Negative')
                       WHEN 'Transfered out'
                         THEN (SELECT TOP 1 ItemId FROM LookupItemView WHERE MasterName = 'CareEnded' AND ItemName = 'Transfer Out')
                       END AS ExitReason,
                      CareEndedDate
                    FROM dbo.dtl_PatientCareEnded
                      INNER JOIN dbo.Patient ON dbo.dtl_PatientCareEnded.Ptn_Pk = dbo.Patient.ptn_pk
                    WHERE dbo.Patient.Id NOT IN (SELECT PatientId FROM dbo.PatientCareending where deleteflag=0)
                  ) AS ptC ON PT.Id = ptC.PatientId
WHERE

 PE.ServiceAreaId=1 