 SELECT DISTINCT
            b.PersonId as Person_Id,NULL as Encounter_ID,NULL as Encounter_Date,a.PopulationType as Population_Type,
            CASE WHEN a.PopulationType = 'Key Population'
                THEN case when c.ItemName in ('SW','PWID','FSW','MSM','Other')then c.ItemName  else 'Other' end
				 ELSE NULL end as Key_Population_Type,
				 a.DeleteFlag as Voided,
				 a.CreateDate
     FROM dbo.PatientPopulation AS a
	 
          INNER JOIN dbo.Patient AS b ON a.PersonId = b.PersonId
          LEFT OUTER JOIN dbo.LookupItemView AS c ON a.PopulationCategory = c.ItemId
     WHERE(a.DeleteFlag = 0);