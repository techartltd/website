 SELECT DISTINCT
            b.PersonId as Person_Id,NULL as Encounter_ID,NULL as Encounter_Date,a.PopulationType as Population_Type,
            CASE WHEN a.PopulationType = 'Key Population'
                THEN case when c.ItemName in ('SW','PWID','FSW','MSM','Other')then c.ItemName  else 'Other' end
				 ELSE NULL end as Key_Population_Type,
				 NULL as Priority_Pop_Type,
				 a.DeleteFlag as Voided,
				 a.CreateDate,
				 a.CreatedBy

     FROM dbo.PatientPopulation AS a
	 
          INNER JOIN dbo.Patient AS b ON a.PersonId = b.PersonId
          LEFT OUTER JOIN dbo.LookupItemView AS c ON a.PopulationCategory = c.ItemId
     --WHERE (a.DeleteFlag = 0)
	 union all

	 select pr.PersonId as Person_Id,NULL as Encounter_ID,NULL as Encounter_Date,'Priority Population' as Population_Type,NULL,(select top 1.[Name] from LookupItem where Id=pr.PriorityId) as Priority_Pop_Type,pr.DeleteFlag as Voided,pr.CreateDate,pr.CreatedBy from PersonPriority pr 
	 