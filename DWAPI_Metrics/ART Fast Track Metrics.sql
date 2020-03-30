INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'ART Fast Track','Number of FastTracks', COUNT(*) 
FROM (select * from PatientArtDistribution paa) B

INSERT INTO DWAPI_Migration_Metrics (Dataset, Metric, MetricValue)
SELECT 'ART Fast Track',Refill_Model, COUNT(*) 
FROM (select (select top 1 DisplayName from LookupItem li where li.Id=paa.ArtRefillModel) as Refill_Model
from PatientArtDistribution paa) B
group by Refill_Model