INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
Select 'Labs','Number of Lab Tests (ALL)',COUNT(*)Total 
from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
inner join ord_Visit v on v.Visit_Id=plo.VisitId
where  (v.DeleteFlag=0 or v.DeleteFlag is null) OR plo.DeleteFlag=0

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 
SELECT 'Labs', Concat(OrderStatus,'  |  ',AvailResults)Results,Count(*) TotalLabTests FROM (
SELECT 
 CASE WHEN COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NOT NULL 
		OR (COALESCE(CAST(r.ResultValue as VARCHAR(20)), r.ResultText,r.ResultOption) IS NULL AND Undetectable=1 AND HasResult=1)
		  THEN 'With Results'
	 ELSE 'No Results'END AS AvailResults,
plo.OrderStatus
from ord_LabOrder	 plo
inner join dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
inner join dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
inner join ord_Visit v on v.Visit_Id=plo.VisitId
where  (v.DeleteFlag=0 or v.DeleteFlag is null) OR plo.DeleteFlag=0) A
Group by OrderStatus,AvailResults

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue) 

SELECT 'Labs',concat(LabTestName,'  |  ',Min(cast(OrderDate as Date)),'  |  ', Max(cast(OrderDate as Date)))LabsWithDates, Count(*) As Total from (
SELECT LabTestName, OrderDate FROM ord_LabOrder	 plo 
INNER JOIN dtl_LabOrderTest OT on OT.LabOrderId=plo.Id
INNER JOIN  dtl_LabOrderTestResult r on r.LabOrderTestId=OT.Id
INNER JOIN ord_Visit v on v.Visit_Id=plo.VisitId
LEFT JOIN mst_User u on u.UserID=plo.OrderedBy
LEFT JOIN (Select	P.Id ParameterId,P.ParameterName,T.Name AS	LabTestName 
	From mst_LabTestMaster T
	INNER JOIN Mst_LabTestParameter P On T.Id = P.LabTestId
	LEFT OUTER JOIN mst_LabDepartment D On T.DepartmentId = D.LabDepartmentID
	)vlw on vlw.ParameterId=r.ParameterId
	  where   plo.DeleteFlag=0 OR (v.DeleteFlag=0 or v.DeleteFlag is null))B
Group by LabTestName
order by LabTestName