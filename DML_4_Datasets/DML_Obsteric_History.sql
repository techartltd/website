SELECT  p.Id as Person_Id, 
d.visitdate AS Encounter_Date,
       NULL AS Encounter_ID,
	   NULL as Pregnancy_Order,
	   h.VisitNumber as Number_ANC_Visits_Attended,
	   NULL as Place_of_Delivery,
	   pr.Gravidae as Maturity_in_weeks,
	   delivery.DurationOfLabour as Duration_Of_Labour,
	   delivery.ModeOfDelivery as Type_of_Delivery,
	   dbbi.BirthWeight as Birth_Weight,
	   (SELECT TOP 1 itemname
   FROM [dbo].[lookupitemview]
   WHERE itemid = dbbi.sex) as  Sex,
   NULL as Outcome,
   NULL as Puerperium_events,
  h.DeleteFlag as Voided
FROM person p
INNER JOIN patient b ON b.personid = p.id
INNER JOIN patientmastervisit d ON b.id=d.PatientId
INNER JOIN
  (SELECT a.patientid,
          enrollmentdate,
          identifiervalue,
          NAME,
          visitdate,
          patientmastervisitid,
          visittype,
          [visitnumber],
          [dayspostpartum],
		  g.DeleteFlag
   FROM patientenrollment a
   INNER JOIN servicearea b ON a.serviceareaid = b.id
   INNER JOIN patientidentifier c ON c.patientid = a.patientid
   INNER JOIN serviceareaidentifiers d ON c.identifiertypeid = d.identifierid
   AND b.id = d.serviceareaid
   INNER JOIN dbo.visitdetails AS g ON a.patientid = g.patientid
   AND b.id = g.serviceareaid
   WHERE b.NAME = 'Maternity') AS h ON b.id = h.patientid and h.PatientMasterVisitId=d.Id
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
   left join Pregnancy pr on pr.PatientId=b.Id and pr.PatientMasterVisitId=d.Id
   LEFT JOIN dbo.deliveredbabybirthinformation dbbi ON dbbi.patientmastervisitid = d.id
AND delivery.deliveryid = dbbi.deliveryid
