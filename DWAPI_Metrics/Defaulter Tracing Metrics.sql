INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'Defaulter Tracing', 'Number of LTFU', Count(*)Total FROM (
select (select top 1. [Name] from Lookupitem where id= pce.ExitReason) as ExitReason,
pce.DeleteFlag
from PatientCareending pce
inner join Patient p on p.Id=pce.PatientId
inner join PatientMasterVisit pmv on pmv.Id=pce.PatientMasterVisitId and pce.patientId=pmv.PatientId
)pce
where pce.ExitReason='LostToFollowUp' and pce.DeleteFlag=0
