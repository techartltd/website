SELECT p.Id AS Person_Id
	,d.visitdate AS Encounter_Date
	,NULL AS Encounter_ID
	,NULL AS Pregnancy_Order
	,h.VisitNumber AS Number_ANC_Visits_Attended
	,NULL AS Place_of_Delivery
	,pr.Gravidae AS Maturity_in_weeks
	,delivery.DurationOfLabour AS Duration_Of_Labour
	,delivery.ModeOfDelivery AS Type_of_Delivery
	,dbbi.BirthWeight AS Birth_Weight
	,(
		SELECT TOP 1 itemname
		FROM [dbo].[lookupitemview]
		WHERE itemid = dbbi.sex
		) AS Sex
	,NULL AS Outcome
	,NULL AS Puerperium_events
	,h.DeleteFlag AS Voided
FROM person p
INNER JOIN patient b ON b.personid = p.id
INNER JOIN patientmastervisit d ON b.id = d.PatientId
INNER JOIN (
	SELECT a.patientid
		,enrollmentdate
		,identifiervalue
		,NAME
		,visitdate
		,patientmastervisitid
		,visittype
		,[visitnumber]
		,[dayspostpartum]
		,g.DeleteFlag
	FROM patientenrollment a
	INNER JOIN servicearea b ON a.serviceareaid = b.id
	INNER JOIN patientidentifier c ON c.patientid = a.patientid
	INNER JOIN serviceareaidentifiers d ON c.identifiertypeid = d.identifierid
		AND b.id = d.serviceareaid
	INNER JOIN dbo.visitdetails AS g ON a.patientid = g.patientid
		AND b.id = g.serviceareaid
	WHERE b.NAME = 'Maternity'
	) AS h ON b.id = h.patientid
	AND h.PatientMasterVisitId = d.Id
LEFT JOIN (
	SELECT DISTINCT delivery.deliveryid
		,[patientmastervisitid]
		,[durationoflabour]
		,[dateofdelivery]
		,[timeofdelivery]
		,lkup2.itemname ModeOfDelivery
		,lkup3.itemname [PlacentaComplete]
		,[bloodlosscapacity]
		,lkup4.itemname [MotherCondition]
		,lkup.itemname [DeliveryComplicationsExperienced]
		,[deliverycomplicationnotes]
		,[deliveryconductedby]
		,[maternaldeathauditdate]
		,lt.[name] AS MaternalDeathAudited
		,lkbl.itemname AS [BloodLossClassification]
	FROM dbo.patientdelivery AS delivery
	LEFT JOIN dbo.lookupitemview AS lkup2 ON lkup2.itemid = delivery.[modeofdelivery]
	LEFT JOIN dbo.lookupitemview AS lkup3 ON lkup3.itemid = delivery.[placentacomplete]
	LEFT JOIN dbo.lookupitemview AS lkup4 ON lkup4.itemid = delivery.[mothercondition]
	LEFT JOIN dbo.lookupitemview AS lkup ON lkup.itemid = delivery.[deliverycomplicationsexperienced]
	LEFT JOIN dbo.lookupitemview AS lkbl ON lkbl.itemid = delivery.bloodlossclassification
	LEFT JOIN lookupitem lt ON lt.id = delivery.maternaldeathaudited
	) delivery ON delivery.patientmastervisitid = d.id
LEFT JOIN Pregnancy pr ON pr.PatientId = b.Id
	AND pr.PatientMasterVisitId = d.Id
LEFT JOIN dbo.deliveredbabybirthinformation dbbi ON dbbi.patientmastervisitid = d.id
	AND delivery.deliveryid = dbbi.deliveryid

