SELECT * from (
select DISTINCT p.PersonId as Person_Id , 
v.VisitDate as Encounter_Date,
NULL as Encounter_ID,
vlw.LabTestName as Lab_Test,
PT.Reasons AS Lab_Reason,
NULL as Urgency, 
CASE WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NOT NULL 
		  THEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption)
	 WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NULL AND Undetectable=1 AND HasResult=1 THEN 'LDL' END AS Test_Result,
plo.OrderDate as Date_test_Requested,
OT.ResultDate as Date_test_result_received,
u.UserFirstName + ' ' + u.UserLastName as Test_Requested_By,
plo.PreClinicLabDate,
plo.ClinicalOrderNotes,
plo.OrderNumber,
plo.CreateDate,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=plo.CreatedBy) 
as CreatedBy,
plo.OrderStatus,
(select  usr.UserFirstName + ' ' + usr.UserLastName  from mst_User usr where usr.UserID=plo.DeletedBy) as DeletedBy ,
plo.DeleteDate,
plo.DeleteReason,
 plo.DeleteFlag as Voided,
 OT.ResultStatus,
 OT.StatusDate,
CASE WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NOT NULL 
		  THEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption)
	 WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NULL AND Undetectable=1 AND HasResult=1 THEN 'LDL' END AS LabResult,
 r.ResultValue,
 r.ResultText,
 r.ResultOption,
r.Undetectable,
 r.DetectionLimit,
 r.ResultUnit,
 r.HasResult,
 vlw.LabTestName,
vlw.ParameterName,
 vlw.LabDepartmentName

from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
LEFT JOIN PatientLabTracker PT on PT.LabOrderId=plo.Id
inner join Patient  p on p.ptn_pk=plo.Ptn_Pk
inner join ord_Visit v on v.Visit_Id=plo.VisitId
left join mst_User u on u.UserID=plo.OrderedBy
left join (Select	P.Id	ParameterId	,P.ParameterName,P.ReferenceId ParameterReferenceId
			,T.Id	LabTestId
			,T.Name	LabTestName
			,T.ReferenceId TestReferenceId
			,T.IsGroup
			,T.DepartmentId
			,D.LabDepartmentName
			, T.DeleteFlag TestDeleteFlag
			,T.Active TestActive
			,P.DeleteFlag ParameterDeleteFlag
	From mst_LabTestMaster T
	Inner Join Mst_LabTestParameter P On T.Id = P.LabTestId
	Left Outer Join mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID)
	vlw on vlw.ParameterId=r.ParameterId
	where  plo.DeleteFlag=0
)B
