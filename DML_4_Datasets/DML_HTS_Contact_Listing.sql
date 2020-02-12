
   --9 HTC Contact Listing
   exec pr_OpenDecryptedSession
  select distinct p.PersonId as Person_Id,
  patr.PersonId as Contact_Person_Id,patr.Encounter_Date,NULL as Encounter_ID,
  	CASE WHEN patr.PersonId is not null then  'YES' end as Consent,
  patr.FirstName as First_Name,patr.MidName as Middle_Name,patr.LastName as Last_Name,
  patr.Sex,patr.DateOfBirth as DoB
  ,patr.MaritalStatus as Marital_Status
  ,patr.PhysicalAddress as Physical_Address
  ,patr.PhoneNumber as Phone_Number
  ,patr.RelationshipType as RelationShip_To_Index,
  PNS.ScreeningDate  as PNSScreeningDate,
  PNS.LivingWithClient as Currently_Living_With_Index,
  PNS.PnsPhysicallyHurt as IPV_Physically_Hurt,
  PNS.ThreatenedHurt as IPV_Threatened_Hurt,
  PNS.PnsForcedSexual as IPV_Sexual_Hurt,
  PNS.IPVOutcome as IPV_Outcome,
  PNS.HIVStatus as HIV_Status,
  PNS.PNSApproach as PNS_Approach,
  TC.Encounter_Date as DateTracingDone,
  TC.Contact_Type,
  TC.Contact_Outcome,
  TC.Reason_uncontacted,
  TC.Booking_Date as Booking_Date,
  TC.Consent_For_Testing,
  TC.Date_Reminded,
  0 as Voided
   from ( select  distinct pe.PatientId from PatientEnrollment  pe
  inner join ServiceArea sa on sa.Id=pe.ServiceAreaId
  where sa.Code='HTS'
  union 
  select distinct pt.Id
   from HtsEncounter e 
  inner join Patient pt on pt.PersonId=e.PersonId
  ) hts
  left join Patient p on p.Id=hts.PatientId
  left join Person per on per.Id=p.PersonId
 left join (SELECT
	ISNULL(ROW_NUMBER() OVER(ORDER BY PR.Id ASC), -1) AS RowID,
	PR.PersonId,
	PR.PatientId,
	CAST(DECRYPTBYKEY(P.[FirstName]) AS VARCHAR(50)) AS [FirstName],
	CAST(DECRYPTBYKEY(P.[MidName]) AS VARCHAR(50)) AS [MidName],
	CAST(DECRYPTBYKEY(P.[LastName]) AS VARCHAR(50)) AS [LastName],
	CAST(DECRYPTBYKEY(pc.MobileNumber) AS VARCHAR(50)) as PhoneNumber,
	P.DateOfBirth,
	P.Sex,
	CAST(DECRYPTBYKEY(pc.[PhysicalAddress]) AS VARCHAR(50)) AS [PhysicalAddress],
	Gender = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = P.Sex AND MasterName = 'Gender'),
	PR.RelationshipTypeId,
	MaritalStatus=(Select top 1 itemName from LookupItemView where itemId= pms.MaritalStatusId AND MasterName='MaritalStatus'),
	RelationshipType = (SELECT TOP 1 ItemName FROM LookupItemView WHERE ItemId = PR.RelationshipTypeId AND MasterName = 'Relationship'),
	PR.CreateDate as Encounter_Date
	
FROM [dbo].[PersonRelationship] PR
inner JOIN dbo.Patient AS PT ON PT.Id = PR.PatientId
left join PatientMaritalStatus pms on pms.PersonId=pr.PersonId
left JOIN [dbo].[Person] P ON P.Id = PR.PersonId
left join PersonContact pc on pc.PersonId=PR.PersonId
)patr on patr.PatientId=hts.PatientId
left join (select T.PersonId as PersonId,T.PatientId as PatientId
,T.PatientMasterVisitId as PatientMasterVisitId,
T.BookingDate as BookingDate
,T.Comment as Comment ,T.EligibleTesting as EligibleTesting ,T.HIVStatus as HIVStatus,
T.IPVOutcome as IPVOutcome,T.LivingWithClient as LivingWithClient
,T.Occupation as Occupation 
,T.PNSApproach as PNSApproach 
,T.PnsForcedSexual as PnsForcedSexual ,T.PnsPhysicallyHurt as PnsPhysicallyHurt
,T.PnsRelationship as PnsRelationship 
,T.PnsThreatenedHurt as ThreatenedHurt
,T.ScreeningDate as ScreeningDate 
, T.ScreeningHivStatus as ScreeningHivStatus
,T.VisitDate as VisitDate

from (SELECT distinct  a.[PersonId],b.[PatientId],pmv.VisitDate,[PatientMasterVisitId],b.[ScreeningDate],ScreeningCategory=
					(SELECT        TOP 1 ItemName
					  FROM            [dbo].[LookupItemView]
					  WHERE        ItemId = b.[ScreeningCategoryId]),ScreeningValue=
					(SELECT        TOP 1 ItemName
					  FROM            [dbo].[LookupItemView]
					  WHERE        ItemId = b.ScreeningValueId),[Occupation],[BookingDate] ,[Comment]
			FROM [dbo].[HtsScreening]a 
			inner join [dbo].[PatientScreening] b on b.Id=a.PatientScreeningId 
			left join PatientMasterVisit pmv on pmv.Id=b.PatientMasterVisitId
			left join [dbo].[HtsScreeningOptions] c on c.id=a.HtsScreeningOptionsId and a.personid=c.personid)y
				PIVOT (max(y.ScreeningValue) FOR ScreeningCategory IN (PnsRelationship ,PnsPhysicallyHurt,PnsThreatenedHurt,PnsForcedSexual,
			IPVOutcome,LivingWithClient,HIVStatus,PNSApproach,EligibleTesting,ScreeningHivStatus))T)PNS on PNS.PatientId=hts.PatientId and patr.PersonId=PNS.PersonId
left join (SELECT 
PersonID,
Encounter_Date = T.DateTracingDone,
Encounter_ID = T.Id,
Contact_Type = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Mode AND MasterName = 'TracingMode'),
Contact_Outcome = (SELECT ItemName FROM LookupItemView WHERE ItemId=T.Outcome AND MasterName = 'TracingOutcome'),
Reason_uncontacted = (SELECT ItemId FROM LookupItemView WHERE ItemId= T.ReasonNotContacted AND MasterName in ('TracingReasonNotContactedPhone','TracingReasonNotContactedPhysical')),
Consent_For_Testing=(SELECT [Name] from LookupItem where Id=  T.Consent),
T.OtherReasonSpecify,
T.DateBookedTesting as Booking_Date,
T.ReminderDate as Date_Reminded,
T.Remarks,
T.DeleteFlag Voided

FROM Tracing T

) TC on TC.PersonID=patr.PersonId  and TC.Encounter_Date=PNS.ScreeningDate

