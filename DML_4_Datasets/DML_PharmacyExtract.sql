exec pr_OpenDecryptedSession
select p.PersonId,
CAST(DECRYPTBYKEY(pe.FirstName) as varchar(100)) as First_Name
,CAST(DECRYPTBYKEY(pe.MidName) as varchar(100))
as Middle_Name
,CAST(DECRYPTBYKEY(pe.LastName) as varchar(100)) as Last_Name,
pe.DateOfBirth,
(select top 1 [Name] from LookupItem where Id=pe.Sex) as Gender,
p.PersonId as UPN,
v.VisitDate as EncounterDate,
dpo.Drug,
dcc.[Name] as TreatmentProgram,
CASE when dcc.[Name]   in ('ART','PMTCT','HBV','Hepatitis B') and   dpo.Prophylaxis = 'No'
then 'Yes'   end as Is_arv,
NULL Is_ctx,
NULL Is_dapsone,
dpo.Prophylaxis,
dpo.StrengthName,
dpo.Drug as Drug_name, 
dpo.SingleDose as Dose,
dpo.MorningDose,
dpo.MiddayDose,
dpo.EveningDose,
dpo.NightDose,
NULL as Unit,
dpo.FrequencyName as Frequency,
dpo.FrequencyMultiplier,
dpo.Duration,
dpo.Duration_units,
NULL Duration_in_days,
dpo.OrderedQuantity,
dpo.DispensedQuantity,
dpo.BatchName,
dpo.ExpiryDate,
oby.UserName as Prescription_providerName,
pho.OrderedBy  as Prescription_provider,
dby.UserName  as Dispensing_providerName,
pho.DispensedBy as Dispensing_Provider,
CASE when pho.RegimenLine < 5 and  pho.PatientMasterVisitId is null then (select [Name]  from mst_RegimenLine where Id=pho.RegimenLine) 
WHEN  pho.PatientMasterVisitId is not null  then  (select  top 1 [Name] from LookupItem where Id=pho.RegimenLine ) end as RegimenLine,
artv.Regimen as Regimen,
artv.TreatmentPlanText as TreatmentPlan,
artv.TreatmentPlanReason as TreatmentPlanReason,
NULL as Adverse_effects,
NULL as Date_of_refill,
pho.DeleteFlag as Voided,
NULL as Date_Voided

from ord_PatientPharmacyOrder pho
left join Patient p on p.ptn_pk=pho.Ptn_pk
left join Person pe on pe.Id=p.PersonId
left join(select dc.ID,dc.[Name]
  from mst_Decode dc
inner join mst_Code  c  on c.CodeID=dc.CodeID
 where c.[Name]='Treatment Program') dcc on dcc.ID=pho.ProgID
left join mst_User oby on oby.UserID =pho.OrderedBy
left join mst_User dby on dby.UserID =pho.DispensedBy
left join ord_Visit v on v.Visit_Id=pho.VisitID
 left join (
select artt.PatientId,artt.PatientMasterVisitId,artt.RegimenLineId,artt.TreatmentStatusId,artt.CreateBy,artt.CreateDate,
(lti.name + '(' + lti.displayname + ')') as Regimen 
,lti.Id as RegimenId,
ltt.DisplayName as TreatmentPlanText,
ltt.Id as TreatmentPlan,
ltrr.Id as TreatmentPlanReasonId,
ltrr.DisplayName as TreatmentPlanReason
from ARVTreatmentTracker artt
 left join LookupItem lti on lti.Id=artt.RegimenId
left join LookupItem ltt on ltt.Id =artt.TreatmentStatusId

left join LookupItem ltrr on ltrr.Id =artt.TreatmentStatusReasonId
where artt.RegimenId > 0
)artv on artv.PatientMasterVisitId=pho.PatientMasterVisitId and artv.RegimenLineId=pho.RegimenLine
left join(select ptn_pharmacy_pk,ms.ItemName as Drug ,mst.StrengthName
as StrengthName,msf.[Name] as FrequencyName
,msf.[multiplier] as FrequencyMultiplier,
dpo.SingleDose,dpo.Duration,NULL as Duration_units,
NULL as Unit,
dpo.OrderedQuantity,
dpo.DispensedQuantity,
CASE WHEN dpo.Prophylaxis=0 then 'No'
when dpo.Prophylaxis=1 then 'Yes' end as Prophylaxis,
ba.[Name] as BatchName,
ba.ExpiryDate,
dpo.MorningDose,
dpo.MiddayDose,
dpo.EveningDose,
dpo.NightDose

 from dtl_PatientPharmacyOrder
dpo
left join Mst_ItemMaster ms on ms.Item_PK=dpo.Drug_Pk
left join mst_Strength mst on mst.StrengthId=dpo.StrengthID
left join mst_Frequency msf on msf.ID=dpo.Id
left join Mst_Batch ba on ba.Id=dpo.BatchNo
)dpo on dpo.ptn_pharmacy_pk=pho.ptn_pharmacy_pk


